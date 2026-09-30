#!/usr/bin/env python3
"""Enumerate what each source PRINTS as a species name, and what the merges
currently resolve it to.

This is the observational half of the taxon-clarity register. It records only
what is in the data -- printed string, source, resolved name, value count --
and makes no judgement about whether a name is precise or what the animal
really is. Those live in the hand-curated `_keys/taxon_clarity.csv`, because a
judgement needs a stated basis and an author, and a script has neither.

Output: `_keys/taxon_clarity_observed.csv`, one row per
(source_publication, printed_name).

The useful column is `resolves_to`. Where it holds more than one value, the
SAME printed string in the SAME paper is being resolved differently by
different merges -- e.g. `Gorilla gorilla` becomes `Gorilla sp.` in the
volumes merge (genus-level lumping) but stays `Gorilla gorilla` in the
cell-count merge. That is a real inconsistency in the compilation and this is
the file that surfaces it.

Usage (from the repo root):  python3 _keys/build_taxon_clarity_observed.py
"""
import csv
import glob
import os
import re
import sys
from collections import defaultdict

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(REPO, "_keys", "taxon_clarity_observed.csv")

# A source token in the `Sources` column names a TABLE. House convention keys
# the variant map by PAPER (SPECIES_NAMING.md principle 3), so the table
# suffix is stripped to group tables of one paper onto one row. The observed
# tables are kept in their own column so nothing is lost.
TABLE_SUFFIX = re.compile(
    r"_(?:Table|TABLE|Tab|Fig|FIGURE|Figure|Supplementary|Supplemental|Sup)"
    r"[A-Za-z0-9._\-]*$"
)


def paper_of(token):
    prev = None
    cur = token
    # Some tokens are concatenations of several tables (the merge records a
    # value supported by more than one); strip repeatedly.
    while cur != prev:
        prev = cur
        cur = TABLE_SUFFIX.sub("", cur)
    return cur or token


def main():
    obs = defaultdict(lambda: {"tables": set(), "resolved": defaultdict(int)})
    files = sorted(glob.glob(os.path.join(REPO, "__merging_*", "*_long.csv")))
    used = 0
    for path in files:
        with open(path, newline="", encoding="utf-8") as fh:
            rd = csv.DictReader(fh)
            fn = set(rd.fieldnames or [])
            if not {"Species", "species_printed"} <= fn:
                continue
            used += 1
            src_col = "Sources" if "Sources" in fn else (
                "Source" if "Source" in fn else None)
            # A long file with no source column still has to be traceable, so
            # the merge that produced it stands in for the source rather than
            # every such row collapsing into one anonymous bucket.
            merge_tag = "(merge: %s)" % os.path.basename(os.path.dirname(path))
            for r in rd:
                printed = (r.get("species_printed") or "").strip()
                if not printed:
                    continue
                toks = [t.strip() for t in (r.get(src_col) or "").split(";")] \
                    if src_col else []
                toks = [t for t in toks if t] or [merge_tag]
                for t in toks:
                    e = obs[(paper_of(t), printed)]
                    e["tables"].add(t)
                    e["resolved"][r["Species"]] += 1

    rows = []
    for (paper, printed), e in obs.items():
        resolved = sorted(e["resolved"], key=lambda k: -e["resolved"][k])
        rows.append({
            "source_publication": paper,
            "printed_name": printed,
            "source_tables": "; ".join(sorted(e["tables"])),
            "n_values": sum(e["resolved"].values()),
            "resolves_to": "; ".join(resolved),
            "n_resolutions": len(resolved),
            "printed_word_count": len(printed.split()),
        })
    rows.sort(key=lambda r: (r["printed_name"], r["source_publication"]))

    with open(OUT, "w", newline="", encoding="utf-8") as fh:
        w = csv.DictWriter(fh, fieldnames=list(rows[0].keys()))
        w.writeheader()
        w.writerows(rows)

    split = [r for r in rows if r["n_resolutions"] > 1]
    print(f"read {used} long files with a species_printed column")
    print(f"wrote {len(rows)} (source_publication, printed_name) rows -> "
          f"_keys/taxon_clarity_observed.csv")
    print(f"{len(rows)} pairs, {len({r['printed_name'] for r in rows})} distinct printed names")
    print(f"{len(split)} pairs whose printed name resolves MORE THAN ONE WAY "
          f"across merges:")
    for r in sorted(split, key=lambda r: -r["n_values"])[:15]:
        print(f"  {r['printed_name']:32s} {r['source_publication']:34s} "
              f"-> {r['resolves_to']}")
    if len(split) > 15:
        print(f"  ... and {len(split) - 15} more")
    return 0


if __name__ == "__main__":
    sys.exit(main())
