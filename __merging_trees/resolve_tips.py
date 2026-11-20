#!/usr/bin/env python3
"""
resolve_tips.py -- shared name -> tip resolution for the Python mirror builds.

MIRROR of resolve_tips.R (which is canonical; read its header for the rules).
Imported by build_mammal_tree.py and build_mammal_trees_sample.py. Keep in step.
"""
import csv
import os
import re

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.environ.get("EVOM1_REPO") or os.path.dirname(HERE)
OUT_ROOT = os.environ.get("EVOM1_OUT") or REPO

REPORT_COLS = ["accepted_name", "status", "matched_tip", "matched_via",
               "candidate_source", "family_expected", "order_expected",
               "n_auto_candidates", "n_review_candidates", "note"]


def out_path(*parts):
    p = os.path.join(OUT_ROOT, *parts)
    os.makedirs(os.path.dirname(p), exist_ok=True)
    return p


def pipeline_file(name):
    """A file the pipeline writes: prefer the write root, fall back to the repo."""
    p = os.path.join(OUT_ROOT, "__merging_trees", name)
    return p if os.path.exists(p) else os.path.join(REPO, "__merging_trees", name)


def read_csv(path):
    csv.field_size_limit(10 ** 9)
    with open(path, newline="", encoding="utf-8-sig") as f:
        return list(csv.DictReader(f))


def tip_binomial(label):
    parts = [p for p in re.split(r"[_\s]+", label.strip()) if p]
    return f"{parts[0]} {parts[1]}" if len(parts) >= 2 else " ".join(parts)


def upham_completed_taxa():
    """Upham et al. 2019's 5,911 species as lower-case binomials, or None."""
    f = os.path.join(REPO, "Upham_etal_2019", "Completed100_topoCons_NDexp", "config.yaml")
    if not os.path.exists(f):
        return None
    with open(f, encoding="utf-8") as fh:
        txt = " ".join(fh.read().split())
    m = re.search(r"names:\s*\[([^\]]*)\]", txt)
    if not m:
        return None
    names = [n.strip().strip("\"'") for n in m.group(1).split(",")]
    return {tip_binomial(n).lower() for n in names if n}


def resolve_tips(xw, tip_labels, universe=None, recognised=None):
    """Return (report_rows, keep, counts, order); keep = [(tip_label, accepted_name)]."""
    by_binom = {}
    for lab in tip_labels:
        by_binom.setdefault(tip_binomial(lab).lower(), lab)

    order, grouped = [], {}
    for r in xw:
        a = r["accepted_name"]
        if a not in grouped:
            grouped[a] = []
            order.append(a)
        grouped[a].append(r)
    for a in order:
        grouped[a].sort(key=lambda r: int(r["candidate_rank"] or 10 ** 6))

    uni = {u["accepted_name"]: u for u in (universe or [])}

    def blocked(acc):
        if recognised is None:
            return False
        own = " ".join(acc.split()[:2]).lower()
        return own in recognised and own not in by_binom

    resolved = {}
    for acc in order:
        hit = None
        if not blocked(acc):
            for r in grouped[acc]:
                if r["auto_match"] == "TRUE" and r["candidate_name"]:
                    lab = by_binom.get(r["candidate_name"].lower())
                    if lab:
                        hit = (r, lab)
                        break
        resolved[acc] = hit

    def claim_key(acc):
        hit = resolved[acc]
        u = uni.get(acc, {})
        src = hit[0]["candidate_source"] if hit else ""
        try:
            nt = int(u.get("n_tables") or 0)
        except ValueError:
            nt = 0
        return (hit is None,
                1 if src == "subspecies_parent" else 0,
                u.get("in_species_reference") != "TRUE",
                u.get("mdd_current") != "TRUE",
                0 if src == "accepted_name" else 1,
                -nt,
                acc.encode("utf-8"))

    report, keep, used, used_src, counts = {}, [], {}, {}, {}
    for acc in sorted(order, key=claim_key):
        rows = grouped[acc]
        review = [r for r in rows if r["auto_match"] == "FALSE" and r["candidate_name"]]
        auto = [r for r in rows if r["auto_match"] == "TRUE" and r["candidate_name"]]
        hit = resolved[acc]
        matched_tip = via = note = csrc = ""
        if hit:
            r, lab = hit
            csrc = r["candidate_source"]
            status = ("matched_direct" if csrc == "accepted_name"
                      else "matched_subspecies_parent" if csrc == "subspecies_parent"
                      else "matched_synonym")
            if lab in used:
                if csrc == "subspecies_parent":
                    status = "subspecies_of_matched_species"
                    note = (f"parent species tip is held by {used[lab]}; a species-level "
                            "tree cannot separate them, so this row is excluded from PGLS "
                            "rather than duplicating the tip")
                elif csrc == "accepted_name" and used_src[lab] == "accepted_name":
                    status = "conflict_tip_already_used"
                    note = (f"tip already assigned to {used[lab]}; "
                            "resolve in tree_tip_crosswalk.csv before use")
                else:
                    status = "synonym_of_matched_name"
                    note = (f"same taxon as {used[lab]}, which holds tip {lab} "
                            f"(reached here via {r['candidate_name']}, {csrc})")
            else:
                used[lab], used_src[lab] = acc, csrc
                keep.append((lab, acc))
                matched_tip, via = lab, r["candidate_name"]
                note = "" if status == "matched_direct" else r.get("note", "")
        elif any(r["candidate_source"] == "out_of_scope" for r in rows):
            status = "out_of_scope"
            note = next(r["note"] for r in rows if r["candidate_source"] == "out_of_scope")
        elif any(r["candidate_source"] == "none_possible" for r in rows):
            status = "unresolvable_placeholder"
            note = "genus-level name: no single tip can represent it"
        elif blocked(acc):
            status = "absent_from_tree"
            note = ("recognised as a species by the source taxonomy but not sampled in "
                    "this tree (no sequence data); not bridged to another tip")
        elif review:
            status = "absent_but_review_lead"
            note = ("not on tree under any auto_match name, but these review-only "
                    "candidates exist: "
                    + "; ".join(r["candidate_name"]
                                + (" [ON TREE]" if r["candidate_name"].lower() in by_binom
                                   else " [not on tree either]") for r in review))
        else:
            status = "absent_from_tree"
            note = "no candidate spelling occurs in the source tree"
        counts[status] = counts.get(status, 0) + 1
        report[acc] = {
            "accepted_name": acc, "status": status, "matched_tip": matched_tip,
            "matched_via": via, "candidate_source": csrc,
            "family_expected": rows[0].get("family_expected", ""),
            "order_expected": rows[0].get("order_expected", ""),
            "n_auto_candidates": len(auto), "n_review_candidates": len(review),
            "note": note,
        }
    # keep in species (crosswalk) order, as the R build does
    pos = {a: i for i, a in enumerate(order)}
    keep.sort(key=lambda t: pos[t[1]])
    return [report[a] for a in order], keep, counts, order


def write_report(rows, path):
    with open(path, "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=REPORT_COLS, quoting=csv.QUOTE_MINIMAL,
                           lineterminator="\n")
        w.writeheader()
        w.writerows(rows)
