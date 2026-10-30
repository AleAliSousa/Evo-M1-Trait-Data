#!/usr/bin/env python3
"""
build_mammal_trees_sample.py -- OFFLINE MIRROR of build_mammal_trees_sample.R

Multi-tree companion to build_mammal_tree.py. The single MCC build stays canonical
for the Shiny app; THIS build turns the VertLife credible-set sample (100 complete
trees, set MamPhy_BDvr_Completed_5911sp_topoCons_NDexp) into a pruned, relabelled
multiPhylo sample for PGLS-across-trees sensitivity analyses.

  INPUT
    Upham_etal_2019/Completed100_topoCons_NDexp/output.nex
        frozen source: 100 trees drawn from Upham et al. 2019's 10k pseudoposterior
        (completed = no-DNA species placed by the AUTHORS' taxonomic imputation,
        different placement per tree; config.yaml in that folder records the job)
    __merging_trees/tree_tip_crosswalk.csv
        the same crosswalk the MCC build uses (auto_match gate, TREE_TIP_BRIDGES)

  OUTPUT
    _keys/mammal_trees_sample100.nwk
        100 Newick lines, tips = project accepted names -- read with
        ape::read.tree() (returns multiPhylo); subset per analysis with keep.tip()
    __merging_trees/mammal_trees_sample100_sourcelabels.nwk
        same 100 pruned trees, PUBLISHED tip labels untouched
    __merging_trees/tree_sample_ids.csv
        line number -> source tree ID (e.g. tree_9002), the provenance link back
        to Upham's posterior
    __merging_trees/tree_coverage_report_completed100.csv
        one row per project species, same columns as tree_coverage_report.csv

NOTHING IS GRAFTED OR IMPUTED LOCALLY. The completed set's imputed placements are
Upham et al.'s own, published per tree. All 100 trees share one tip set (verified),
so species resolution is done once and pruning applied per tree.

Usage (from repo root):
    python3 __merging_trees/build_mammal_trees_sample.py
"""

import csv
import os
import re
import sys

sys.setrecursionlimit(200000)

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MERGE = os.path.join(REPO, "__merging_trees")
SOURCE = os.path.join(REPO, "Upham_etal_2019",
                      "Completed100_topoCons_NDexp", "output.nex")

sys.path.insert(0, MERGE)
from build_mammal_tree import (Node, read_newick, write_newick, fmt_len,  # noqa: E402
                               tips, keep_tips, depths, tip_binomial)


def parse_newick_string(text):
    """Parse one Newick string (reuses build_mammal_tree's grammar via a temp shim)."""
    text = re.sub(r"\[[^\]]*\]", "", text)
    i = text.find("(")
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

    return parse_node()


def newick_string(root):
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
    return "".join(out)


def read_nexus_trees(path):
    """Return [(tree_id, newick_string)] from a NEXUS trees block (no translate map
    expected -- VertLife's tree-pruner writes labels inline; assert if one appears)."""
    with open(path, encoding="utf-8-sig", errors="replace") as f:
        text = f.read()
    if re.search(r"^\s*translate\b", text, flags=re.I | re.M):
        sys.exit("ERROR: NEXUS translate block found; this reader expects inline labels.")
    out = []
    for m in re.finditer(r"^\s*tree\s+(\S+)\s*=\s*(?:\[[^\]]*\]\s*)?(\(.*?;)",
                         text, flags=re.S | re.I | re.M):
        out.append((m.group(1), m.group(2)))
    if not out:
        sys.exit(f"ERROR: no trees found in {path}")
    return out


def main():
    if not os.path.exists(SOURCE):
        sys.exit(f"ERROR: source sample not found: {SOURCE}\n"
                 "       See Upham_etal_2019/Upham_etal_2019.README.md (Completed100 item).")

    trees_raw = read_nexus_trees(SOURCE)
    print(f"source sample : {os.path.relpath(SOURCE, REPO)}")
    print(f"  trees       : {len(trees_raw)}")

    first = parse_newick_string(trees_raw[0][1])
    all_tips = tips(first)
    tipset = frozenset(t.label for t in all_tips)
    print(f"  tips/tree   : {len(all_tips)}")

    by_binom = {}
    for t in all_tips:
        by_binom.setdefault(tip_binomial(t.label).lower(), t.label)

    # ---- resolve species once, exactly as build_mammal_tree does ----------------
    with open(os.path.join(MERGE, "tree_tip_crosswalk.csv"),
              newline="", encoding="utf-8-sig") as f:
        xw = list(csv.DictReader(f))

    order, grouped = [], {}
    for r in xw:
        a = r["accepted_name"]
        if a not in grouped:
            grouped[a] = []
            order.append(a)
        grouped[a].append(r)

    resolved = {}
    for acc in order:
        rows = sorted(grouped[acc], key=lambda r: int(r["candidate_rank"] or 10**6))
        auto = [r for r in rows if r["auto_match"] == "TRUE" and r["candidate_name"]]
        hit = None
        for r in auto:
            lab = by_binom.get(r["candidate_name"].lower())
            if lab:
                hit = (r, lab)
                break
        resolved[acc] = hit

    def claim_priority(acc):
        hit = resolved[acc]
        if hit is None:
            return (2, acc)
        return (1 if hit[0]["candidate_source"] == "subspecies_parent" else 0, acc)

    report, keep, dup_guard, counts = [], [], {}, {}
    for acc in sorted(order, key=claim_priority):
        rows = sorted(grouped[acc], key=lambda r: int(r["candidate_rank"] or 10**6))
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
            "accepted_name": acc, "status": status, "matched_tip": matched_tip,
            "matched_via": via,
            "candidate_source": hit[0]["candidate_source"] if hit else "",
            "family_expected": fam, "order_expected": orderr,
            "n_auto_candidates": len(auto), "n_review_candidates": len(review),
            "note": note,
        })

    keep_labels = [lab for lab, _ in keep]
    if len(keep_labels) < 4:
        sys.exit(f"ERROR: only {len(keep_labels)} species matched; PGLS needs >= 4.")
    relab = {lab: acc.replace(" ", "_") for lab, acc in keep}

    # ---- prune every tree --------------------------------------------------------
    src_lines, app_lines, ids = [], [], []
    worst_spread, worst_depth = 0.0, 1.0
    for k, (tree_id, nwk) in enumerate(trees_raw, start=1):
        root = parse_newick_string(nwk)
        tset = frozenset(t.label for t in tips(root))
        if tset != tipset:
            sys.exit(f"ERROR: tree {tree_id} has a different tip set from tree 1 -- "
                     "the sample is not one consistent taxon set.")
        pruned = keep_tips(root, keep_labels)
        src_lines.append(newick_string(pruned))
        for t in tips(pruned):
            t.label = relab.get(t.label, t.label)
        app_lines.append(newick_string(pruned))
        d = depths(pruned)
        spread = max(d) - min(d)
        if spread > worst_spread:
            worst_spread, worst_depth = spread, max(d)
        ids.append({"line": k, "tree_id": tree_id})

    with open(os.path.join(REPO, "_keys", "mammal_trees_sample100.nwk"),
              "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(app_lines) + "\n")
    with open(os.path.join(MERGE, "mammal_trees_sample100_sourcelabels.nwk"),
              "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(src_lines) + "\n")
    with open(os.path.join(MERGE, "tree_sample_ids.csv"),
              "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=["line", "tree_id"], lineterminator="\n")
        w.writeheader()
        w.writerows(ids)

    rank = {a: i for i, a in enumerate(order)}
    report.sort(key=lambda r: rank[r["accepted_name"]])
    cols = ["accepted_name", "status", "matched_tip", "matched_via",
            "candidate_source", "family_expected", "order_expected",
            "n_auto_candidates", "n_review_candidates", "note"]
    with open(os.path.join(MERGE, "tree_coverage_report_completed100.csv"),
              "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=cols, quoting=csv.QUOTE_MINIMAL,
                           lineterminator="\n")
        w.writeheader()
        w.writerows(report)

    print(f"\nmatched {len(keep_labels)} / {len(order)} project species")
    for k in sorted(counts):
        print(f"  {counts[k]:4d}  {k}")
    ultra = worst_spread <= 1e-3 * worst_depth
    print(f"\nworst root-to-tip spread across {len(trees_raw)} trees: "
          f"{worst_spread:.6g}  "
          f"({'ultrametric' if ultra else 'NOT ultrametric -- check the source'})")
    print("wrote _keys/mammal_trees_sample100.nwk")
    print("wrote __merging_trees/mammal_trees_sample100_sourcelabels.nwk")
    print("wrote __merging_trees/tree_sample_ids.csv")
    print("wrote __merging_trees/tree_coverage_report_completed100.csv")
    return 0


if __name__ == "__main__":
    sys.exit(main())
