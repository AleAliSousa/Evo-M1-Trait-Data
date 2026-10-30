#!/usr/bin/env python3
"""
build_mammal_tree.py -- OFFLINE MIRROR of build_mammal_tree.R

`build_mammal_tree.R` is canonical (it uses ape, and R is what the rest of the repo
runs on). This mirror exists because the Cowork sandbox has no R: it reproduces the
same outputs byte-for-byte so the merge can be regenerated and checked without R.
Pure standard library -- no ape, no dendropy, no numpy.

WHAT IT DOES
  1. reads a published source tree (Newick or NEXUS-embedded Newick)
  2. resolves each project species to a real tip via tree_tip_crosswalk.csv,
     using only candidates with auto_match = TRUE
  3. prunes the tree to the matched tips (collapsing the resulting single-child
     nodes and summing their branch lengths, i.e. ape::keep.tip semantics)
  4. writes
       _keys/mammal_tree.nwk                        tips relabelled to the project's
                                                    accepted_name -- this is what
                                                    __ShinyApp/app.R matches against
       __merging_trees/mammal_tree_sourcelabels.nwk same topology, PUBLISHED tip
                                                    labels untouched
       __merging_trees/tree_coverage_report.csv     one row per project species

NOTHING IS GRAFTED OR IMPUTED. Species absent from the source tree are reported as
absent and excluded, per __ShinyApp/PHYLO_SETUP.md and the deprecation of
_keys/extend_phylo.R.

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

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
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
    """Match R's write.tree number formatting closely enough to diff cleanly."""
    if x is None:
        return None
    s = "%.15g" % x
    return s


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
    by_binom = {}
    for t in all_tips:
        by_binom.setdefault(tip_binomial(t.label).lower(), t.label)
    print(f"source tree : {os.path.relpath(src, REPO)}")
    print(f"  tips      : {len(all_tips)}")

    with open(os.path.join(MERGE, "tree_tip_crosswalk.csv"),
              newline="", encoding="utf-8-sig") as f:
        xw = list(csv.DictReader(f))

    order = []
    grouped = {}
    for r in xw:
        a = r["accepted_name"]
        if a not in grouped:
            grouped[a] = []
            order.append(a)
        grouped[a].append(r)

    report, keep, dup_guard = [], [], {}
    counts = {}

    # Resolve every species against the tree first, WITHOUT claiming tips, so that
    # tip assignment can be done in a deterministic priority order below.
    resolved = {}
    for acc in order:
        rows = sorted(grouped[acc],
                      key=lambda r: int(r["candidate_rank"] or 10**6))
        auto = [r for r in rows if r["auto_match"] == "TRUE" and r["candidate_name"]]
        hit = None
        for r in auto:
            lab = by_binom.get(r["candidate_name"].lower())
            if lab:
                hit = (r, lab)
                break
        resolved[acc] = hit

    # Priority: a species matching a tip in its own right always beats a SUBSPECIES
    # falling back to that same tip. Otherwise "Cryptomys hottentotus" vs its two
    # subspecies would be decided by row order in the CSV.
    def claim_priority(acc):
        hit = resolved[acc]
        if hit is None:
            return (2, acc)
        return (1 if hit[0]["candidate_source"] == "subspecies_parent" else 0, acc)

    for acc in sorted(order, key=claim_priority):
        rows = sorted(grouped[acc],
                      key=lambda r: int(r["candidate_rank"] or 10**6))
        fam = rows[0].get("family_expected", "")
        orderr = rows[0].get("order_expected", "")

        review = [r for r in rows if r["auto_match"] == "FALSE" and r["candidate_name"]]
        auto = [r for r in rows if r["auto_match"] == "TRUE" and r["candidate_name"]]
        placeholder = any(r["candidate_source"] == "none_possible" for r in rows)
        hit = resolved[acc]

        if hit:
            r, lab = hit
            src_kind = r["candidate_source"]
            status = ("matched_direct" if src_kind == "accepted_name"
                      else "matched_subspecies_parent"
                      if src_kind == "subspecies_parent" else "matched_synonym")
            # two project species must never share one tip
            if lab in dup_guard:
                if src_kind == "subspecies_parent":
                    status = "subspecies_of_matched_species"
                    note = (f"parent species tip is held by {dup_guard[lab]}; a "
                            "species-level tree cannot separate them, so this row is "
                            "excluded from PGLS rather than duplicating the tip")
                else:
                    status = "conflict_tip_already_used"
                    note = (f"tip already assigned to {dup_guard[lab]}; "
                            "resolve in tree_tip_crosswalk.csv before use")
                matched_tip, via = "", ""
            else:
                dup_guard[lab] = acc
                keep.append((lab, acc))
                matched_tip, via = lab, r["candidate_name"]
                note = "" if status == "matched_direct" else r.get("note", "")
        else:
            matched_tip, via = "", ""
            if placeholder:
                status = "unresolvable_placeholder"
                note = "genus-level name: no single tip can represent it"
            elif review:
                status = "absent_but_review_lead"
                note = ("not on tree under any auto_match name, but these review-only "
                        "candidates exist: "
                        + "; ".join(
                            f"{r['candidate_name']}"
                            + (" [ON TREE]" if r["candidate_name"].lower() in by_binom
                               else " [not on tree either]")
                            for r in review))
            else:
                status = "absent_from_tree"
                note = "no candidate spelling occurs in the source tree"

        counts[status] = counts.get(status, 0) + 1
        report.append({
            "accepted_name": acc,
            "status": status,
            "matched_tip": matched_tip,
            "matched_via": via,
            "candidate_source": hit[0]["candidate_source"] if hit else "",
            "family_expected": fam,
            "order_expected": orderr,
            "n_auto_candidates": len(auto),
            "n_review_candidates": len(review),
            "note": note,
        })

    # ---- prune ----------------------------------------------------------------
    keep_labels = [lab for lab, _ in keep]
    if len(keep_labels) < 4:
        sys.exit(f"ERROR: only {len(keep_labels)} species matched; PGLS needs >= 4.")

    pruned_src = keep_tips(read_newick(src), keep_labels)
    write_newick(pruned_src, os.path.join(MERGE, "mammal_tree_sourcelabels.nwk"))

    pruned = keep_tips(read_newick(src), keep_labels)
    relab = {lab: acc.replace(" ", "_") for lab, acc in keep}
    for t in tips(pruned):
        t.label = relab.get(t.label, t.label)
    write_newick(pruned, os.path.join(REPO, "_keys", "mammal_tree.nwk"))

    d = depths(pruned)
    spread = (max(d) - min(d)) if d else 0.0
    ultra = spread <= 1e-3 * (max(d) if d else 1.0)

    # ---- report -------------------------------------------------------------
    # report follows species_reference.csv order, not the internal claim order
    rank = {a: i for i, a in enumerate(order)}
    report.sort(key=lambda r: rank[r["accepted_name"]])

    cols = ["accepted_name", "status", "matched_tip", "matched_via",
            "candidate_source", "family_expected", "order_expected",
            "n_auto_candidates", "n_review_candidates", "note"]
    with open(os.path.join(MERGE, "tree_coverage_report.csv"),
              "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=cols, quoting=csv.QUOTE_MINIMAL,
                           lineterminator="\n")
        w.writeheader()
        w.writerows(report)

    print(f"\nmatched {len(keep_labels)} / {len(order)} project species")
    for k in sorted(counts):
        print(f"  {counts[k]:4d}  {k}")
    print(f"\nroot-to-tip spread: {spread:.6g}  "
          f"({'ultrametric' if ultra else 'NOT ultrametric -- check the source tree'})")
    print("wrote _keys/mammal_tree.nwk")
    print("wrote __merging_trees/mammal_tree_sourcelabels.nwk")
    print("wrote __merging_trees/tree_coverage_report.csv")
    return 0


if __name__ == "__main__":
    sys.exit(main())
