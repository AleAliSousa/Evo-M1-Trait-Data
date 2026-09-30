#!/usr/bin/env python3
"""Validate `_keys/taxon_clarity.csv` and report how much of the compilation
it covers.

Coverage is measured against `_keys/taxon_clarity_observed.csv`, which
`_keys/build_taxon_clarity_observed.py` regenerates from the merges. A pair is
judged if the register holds a row for its exact (source_publication,
printed_name), or a wildcard row for that printed_name with
source_publication = "*".

Exits non-zero on a malformed register -- an unknown clarity class, or an
inferred name with no basis, authority or confidence behind it. An incomplete
register is NOT an error: 10,681 pairs will not be judged by hand, and the
point of the coverage report is to aim the effort at the pairs that carry the
most values.

Usage (from the repo root):  python3 _checks/check_taxon_clarity.py
"""
import csv
import os
import sys
from collections import Counter, defaultdict

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
REG = os.path.join(REPO, "_keys", "taxon_clarity.csv")
OBS = os.path.join(REPO, "_keys", "taxon_clarity_observed.csv")

CLARITY = {
    "determinate",            # names one extant taxon; nothing to infer
    "subspecies_unstated",    # species rank given, subspecies not
    "domestication_unstated", # species given, wild vs domestic not
    "pre_split",              # referent spans >1 modern taxon (see taxon_concept_registry)
    "genus_indet",            # genus or common name only
    "disputed",               # sources conflict on identity
}
CONFIDENCE = {"high", "medium", "low", ""}


def load(path, what):
    if not os.path.exists(path):
        sys.exit(f"ERROR: {what} not found at {path}. "
                 f"Run python3 _keys/build_taxon_clarity_observed.py first.")
    with open(path, newline="", encoding="utf-8") as fh:
        return list(csv.DictReader(fh))


def main():
    reg = load(REG, "taxon_clarity.csv")
    obs = load(OBS, "taxon_clarity_observed.csv")

    errs = []
    for i, r in enumerate(reg, start=2):
        where = f"taxon_clarity.csv line {i} ({r['source_publication']} / {r['printed_name']})"
        if r["taxon_clarity"] not in CLARITY:
            errs.append(f"{where}: unknown taxon_clarity '{r['taxon_clarity']}'. "
                        f"Allowed: {', '.join(sorted(CLARITY))}")
        if r["inference_confidence"] not in CONFIDENCE:
            errs.append(f"{where}: unknown inference_confidence "
                        f"'{r['inference_confidence']}'")
        if not r["clarity_basis"].strip():
            errs.append(f"{where}: clarity_basis is empty; a clarity class "
                        f"with no stated evidence cannot be audited")
        # An inference is a claim about an animal, so it needs its warrant.
        if r["inferred_accepted_name"].strip():
            for col in ("inference_basis", "inference_authority",
                        "inference_confidence"):
                if not r[col].strip():
                    errs.append(f"{where}: inferred_accepted_name is set but "
                                f"{col} is empty")
        if r["taxon_clarity"] == "determinate" and \
                r["inferred_accepted_name"].strip() and \
                r["inferred_accepted_name"].strip() != r["printed_name"].strip():
            errs.append(f"{where}: clarity is 'determinate' but the inferred "
                        f"name differs from the printed name; that is a "
                        f"re-identification, which belongs in "
                        f"_keys/reidentifications.csv")

    exact = {(r["source_publication"], r["printed_name"]) for r in reg}
    wild = {r["printed_name"] for r in reg if r["source_publication"] == "*"}

    judged = unjudged = 0
    judged_vals = unjudged_vals = 0
    worklist = []
    for o in obs:
        key = (o["source_publication"], o["printed_name"])
        n = int(o["n_values"])
        if key in exact or o["printed_name"] in wild:
            judged += 1
            judged_vals += n
        else:
            unjudged += 1
            unjudged_vals += n
            worklist.append(o)

    tot_pairs = judged + unjudged
    tot_vals = judged_vals + unjudged_vals
    print(f"register: {len(reg)} rows "
          f"({len(wild)} wildcard printed names, "
          f"{len(exact) - len(wild)} source-specific)")
    print(f"clarity classes in use: "
          f"{dict(Counter(r['taxon_clarity'] for r in reg))}")
    print(f"\ncoverage against {tot_pairs} observed (source, printed_name) pairs:")
    print(f"  judged   {judged:6d} pairs  {judged_vals:7d} values  "
          f"({100*judged_vals/tot_vals:.1f}% of values)")
    print(f"  unjudged {unjudged:6d} pairs  {unjudged_vals:7d} values")

    # Pairs whose printed name resolves more than one way are the ones where an
    # unjudged taxon is already producing divergent species in the output.
    split = [o for o in worklist if int(o["n_resolutions"]) > 1]
    if split:
        print(f"\nunjudged AND resolving more than one way ({len(split)}) "
              f"-- these are actively inconsistent:")
        for o in sorted(split, key=lambda o: -int(o["n_values"])):
            print(f"  {o['printed_name']:28s} {o['source_publication']:36s} "
                  f"-> {o['resolves_to']}")

    single = [o for o in worklist if o["printed_word_count"] == "1"]
    print(f"\nunjudged pairs whose printed name is a single word "
          f"(common name, no binomial): {len(single)}")
    for o in sorted(single, key=lambda o: -int(o["n_values"]))[:10]:
        print(f"  {o['printed_name']:28s} n={o['n_values']:>5s}  "
              f"resolves_to={o['resolves_to'][:46]}")

    print(f"\nhighest-value unjudged pairs (the worklist):")
    for o in sorted(worklist, key=lambda o: -int(o["n_values"]))[:10]:
        print(f"  {o['printed_name']:34s} n={o['n_values']:>5s}  "
              f"{o['source_publication'][:40]}")

    if errs:
        print("\nregister problems:", file=sys.stderr)
        for e in errs:
            print("  - " + e, file=sys.stderr)
        sys.exit(f"\n{len(errs)} problem(s) in _keys/taxon_clarity.csv")
    print("\nOK: register is well-formed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
