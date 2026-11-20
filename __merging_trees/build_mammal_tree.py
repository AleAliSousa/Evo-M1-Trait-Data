#!/usr/bin/env python3
"""
build_mammal_tree.py -- OFFLINE MIRROR of build_mammal_tree.R

`build_mammal_tree.R` is canonical (it uses ape, and R is what the rest of the repo
runs on). This mirror exists because the Cowork sandbox has no R: it reproduces the
same outputs byte-for-byte so the merge can be regenerated and checked without R.
Pure standard library -- no ape, no dendropy, no numpy.

WHAT IT DOES
  1. reads a published source tree (Newick or NEXUS-embedded Newick)
  2. resolves each name in species_universe.csv to a real tip via
     tree_tip_crosswalk.csv, using only candidates with auto_match = TRUE
     (resolve_tips.py -- the mirror of resolve_tips.R)
  3. prunes the tree to the matched tips (collapsing the resulting single-child
     nodes and summing their branch lengths, i.e. ape::keep.tip semantics)
  4. writes
       _keys/mammal_tree.nwk                        tips relabelled to the project's
                                                    accepted_name -- this is what
                                                    __ShinyApp/app.R matches against
       __merging_trees/mammal_tree_sourcelabels.nwk same topology, PUBLISHED tip
                                                    labels untouched
       __merging_trees/tree_coverage_report.csv     one row per universe name

NOTHING IS GRAFTED OR IMPUTED HERE. Every tip is a sequenced species in the source
tree; species absent from it are reported as absent. The wider products are
separate builds: build_mammal_trees_sample (Upham's completed trees) and
build_mammal_tree_augmented.R (locally added branches; R only, no mirror).

Paths: reads $EVOM1_REPO (default: this repo), writes $EVOM1_OUT (default: same).

Usage (from repo root):
    python3 __merging_trees/build_mammal_tree.py
    python3 __merging_trees/build_mammal_tree.py --tree path/to/tree.tre
"""

import argparse
import csv
import glob
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import resolve_tips as RT  # noqa: E402

REPO = RT.REPO          # read root: $EVOM1_REPO, default this repo
MERGE = os.path.join(REPO, "__merging_trees")

TREE_EXTS = ("nwk", "tre", "newick", "nex", "tree")
DEFAULT_SOURCE_DIR = os.path.join(REPO, "Upham_etal_2019")


# ---------------------------------------------------------------- newick I/O ---
class Node:
    __slots__ = ("label", "length", "children")

    def __init__(self, label=None, length=None):
        self.label = label
        self.length = length
        self.children = []

    @property
    def is_tip(self):
        return not self.children


def _strip_nexus(text):
    """Pull the Newick string out of a NEXUS trees block, applying the translate map."""
    if "#NEXUS" not in text.upper():
        return text
    trans = {}
    m = re.search(r"translate(.*?);", text, flags=re.S | re.I)
    if m:
        for line in m.group(1).split(","):
            parts = line.strip().split(None, 1)
            if len(parts) == 2:
                trans[parts[0]] = parts[1].strip().strip("'\"")
    m = re.search(r"^\s*tree\s+[^=]*=\s*(?:\[[^\]]*\]\s*)?(\(.*?;)",
                  text, flags=re.S | re.I | re.M)
    if not m:
        raise ValueError("NEXUS file contains no parsable tree statement")
    nwk = m.group(1)
    if trans:
        # replace bare integer tip labels with their translated names
        def sub(mo):
            return trans.get(mo.group(1), mo.group(1))
        nwk = re.sub(r"(?<=[(,])\s*(\d+)", lambda mo: sub(mo), nwk)
    return nwk


def read_newick(path):
    with open(path, encoding="utf-8-sig", errors="replace") as f:
        text = f.read()
    text = _strip_nexus(text)
    text = re.sub(r"\[[^\]]*\]", "", text)          # drop comments
    i = text.find("(")
    if i < 0:
        raise ValueError(f"no Newick tree found in {path}")
    text = text[i:]
    j = text.find(";")
    if j >= 0:
        text = text[: j + 1]

    pos = 0
    n = len(text)

    def parse_node():
        nonlocal pos
        node = Node()
        if text[pos] == "(":
            pos += 1
            while True:
                node.children.append(parse_node())
                if pos < n and text[pos] == ",":
                    pos += 1
                    continue
                if pos < n and text[pos] == ")":
                    pos += 1
                    break
                raise ValueError(f"malformed Newick near offset {pos}")
        # label
        start = pos
        if pos < n and text[pos] in "'\"":
            q = text[pos]
            pos += 1
            buf = []
            while pos < n and text[pos] != q:
                buf.append(text[pos])
                pos += 1
            pos += 1
            node.label = "".join(buf)
        else:
            while pos < n and text[pos] not in ":,();":
                pos += 1
            lab = text[start:pos].strip()
            node.label = lab or None
        # branch length
        if pos < n and text[pos] == ":":
            pos += 1
            start = pos
            while pos < n and (text[pos].isdigit() or text[pos] in ".eE+-"):
                pos += 1
            try:
                node.length = float(text[start:pos])
            except ValueError:
                node.length = None
        return node

    root = parse_node()
    return root


def fmt_len(x):
    """Match ape::write.tree exactly: it formats with sprintf("%.10g") (digits = 10).

    Until 2026-11 this used %.15g, which agreed with ape only while few branches
    were merged by pruning; at full coverage the summed lengths differ in the
    11th digit and the two builds stopped being byte-identical.
    """
    if x is None:
        return None
    return "%.10g" % x


def write_newick(root, path):
    out = []

    def emit(node, is_root=False):
        if node.children:
            out.append("(")
            for k, ch in enumerate(node.children):
                if k:
                    out.append(",")
                emit(ch)
            out.append(")")
        if node.label:
            out.append(node.label.replace(" ", "_"))
        if node.length is not None and not is_root:
            out.append(":" + fmt_len(node.length))

    emit(root, is_root=True)
    out.append(";")
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        f.write("".join(out) + "\n")


def tips(root):
    stack, acc = [root], []
    while stack:
        nd = stack.pop()
        if nd.is_tip:
            acc.append(nd)
        else:
            stack.extend(nd.children)
    return acc


def keep_tips(root, keep):
    """ape::keep.tip equivalent: prune to `keep`, collapse single-child nodes."""
    keep = set(keep)

    def rec(node):
        if node.is_tip:
            return node if node.label in keep else None
        kids = [k for k in (rec(c) for c in node.children) if k is not None]
        if not kids:
            return None
        if len(kids) == 1:
            child = kids[0]
            if node.length is not None or child.length is not None:
                child.length = (child.length or 0.0) + (node.length or 0.0)
            return child
        node.children = kids
        return node

    pruned = rec(root)
    if pruned is not None:
        pruned.length = None
    return pruned


def depths(root):
    """Root-to-tip path lengths, for the ultrametricity check."""
    acc = []

    def rec(nd, d):
        d += nd.length or 0.0
        if nd.is_tip:
            acc.append(d)
        else:
            for c in nd.children:
                rec(c, d)

    for c in root.children:
        rec(c, 0.0)
    return acc


# ------------------------------------------------------------------- helpers ---
def tip_binomial(label):
    """'Genus_species_FAMILY_ORDER' -> 'Genus species'  (Upham/VertLife convention)."""
    parts = re.split(r"[_\s]+", label.strip())
    parts = [p for p in parts if p]
    if len(parts) >= 2:
        return f"{parts[0]} {parts[1]}"
    return " ".join(parts)


def find_source_tree(explicit):
    if explicit:
        if not os.path.exists(explicit):
            sys.exit(f"ERROR: tree file not found: {explicit}")
        return explicit
    hits = []
    for ext in TREE_EXTS:
        hits += sorted(glob.glob(os.path.join(DEFAULT_SOURCE_DIR, f"*.{ext}")))
    if not hits:
        sys.exit(
            "ERROR: no source tree found in Upham_etal_2019/.\n"
            "       See Upham_etal_2019/Upham_etal_2019.README.md for the exact file\n"
            "       to download and where to put it, then re-run."
        )
    return hits[0]


# ---------------------------------------------------------------------- main ---
def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--tree", default=None, help="source tree file")
    args = ap.parse_args()

    src = find_source_tree(args.tree)
    root = read_newick(src)
    all_tips = tips(root)
    print(f"source tree : {os.path.relpath(src, REPO)}")
    print(f"  tips      : {len(all_tips)}")

    xw = RT.read_csv(RT.pipeline_file("tree_tip_crosswalk.csv"))
    universe = RT.read_csv(RT.pipeline_file("species_universe.csv"))
    # Upham et al.'s full species list: a species they recognise but did not
    # sequence is absent from this tree, never bridged to another tip.
    recognised = RT.upham_completed_taxa()
    report, keep, counts, order = RT.resolve_tips(
        xw, [t.label for t in all_tips], universe, recognised)

    # ---- prune ----------------------------------------------------------------
    keep_labels = [lab for lab, _ in keep]
    if len(keep_labels) < 4:
        sys.exit(f"ERROR: only {len(keep_labels)} species matched; PGLS needs >= 4.")

    pruned_src = keep_tips(read_newick(src), keep_labels)
    write_newick(pruned_src, RT.out_path("__merging_trees", "mammal_tree_sourcelabels.nwk"))

    pruned = keep_tips(read_newick(src), keep_labels)
    relab = {lab: acc.replace(" ", "_") for lab, acc in keep}
    for t in tips(pruned):
        t.label = relab.get(t.label, t.label)
    write_newick(pruned, RT.out_path("_keys", "mammal_tree.nwk"))

    d = depths(pruned)
    spread = (max(d) - min(d)) if d else 0.0
    ultra = spread <= 1e-3 * (max(d) if d else 1.0)

    RT.write_report(report, RT.out_path("__merging_trees", "tree_coverage_report.csv"))

    print(f"\nmatched {len(keep_labels)} / {len(order) - counts.get('out_of_scope', 0)} "
          f"in-scope names ({len(order)} universe names)")
    for k in sorted(counts):
        print(f"  {counts[k]:5d}  {k}")
    print(f"\nroot-to-tip spread: {spread:.6g}  "
          f"({'ultrametric' if ultra else 'NOT ultrametric -- check the source tree'})")
    print("wrote _keys/mammal_tree.nwk")
    print("wrote __merging_trees/mammal_tree_sourcelabels.nwk")
    print("wrote __merging_trees/tree_coverage_report.csv")
    return 0


if __name__ == "__main__":
    sys.exit(main())
