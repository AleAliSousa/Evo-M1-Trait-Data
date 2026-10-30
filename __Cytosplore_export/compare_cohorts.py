#!/usr/bin/env python3
"""compare_cohorts.py -- one table of data availability across every built
cohort folder: output/cohort_comparison.csv, one row per variable, one
`n_species__<folder>` column per folder, where a folder is <cohort>, <cohort>_genus
or <cohort>_pooled_<mode> (wild/domestic pooling, see _keys/README_species_pooling.md),
plus cohort size and full-coverage counts per folder in cohort_comparison_sizes.csv.
Every folder under output/ that holds a variable dictionary is included, so new
pooling modes appear without changes here. Run by build_all_cohorts.sh."""
import csv, os, collections
csv.field_size_limit(10 ** 8)
HERE = os.path.dirname(os.path.abspath(__file__)); OUT = os.path.join(HERE, "output")
folders = sorted(d for d in os.listdir(OUT) if os.path.isdir(os.path.join(OUT, d)))
rows = collections.defaultdict(dict); meta = {}; sizes = {}
for f in folders:
    p = os.path.join(OUT, f, f"{f}_variable_dictionary.csv")
    if not os.path.exists(p): continue
    with open(os.path.join(OUT, f, f"{f}_species.csv"), encoding="utf-8", newline="") as fh:
        sizes[f] = sum(1 for _ in csv.DictReader(fh))
    with open(p, encoding="utf-8", newline="") as fh:
        for r in csv.DictReader(fh):
            rows[r["variable"]][f] = int(r["species_with_data"])
            meta[r["variable"]] = (r["domain"], r["unit"], r.get("m1_motor_related", ""))
cols = [f for f in folders if f in sizes]
out = []
for v in sorted(rows, key=lambda v: (meta[v][0], v)):
    rec = {"variable": v, "domain": meta[v][0], "unit": meta[v][1], "m1_motor_related": meta[v][2]}
    for f in cols:
        rec[f"n_species__{f}"] = rows[v].get(f, 0)
        rec[f"pct__{f}"] = round(100 * rows[v].get(f, 0) / sizes[f], 1)
    out.append(rec)
with open(os.path.join(OUT, "cohort_comparison.csv"), "w", encoding="utf-8", newline="") as fh:
    w = csv.DictWriter(fh, fieldnames=list(out[0].keys())); w.writeheader(); w.writerows(out)
with open(os.path.join(OUT, "cohort_comparison_sizes.csv"), "w", encoding="utf-8", newline="") as fh:
    w = csv.writer(fh); w.writerow(["folder", "n_cohort_species", "n_variables_with_data",
                                    "n_variables_full_coverage"])
    for f in cols:
        w.writerow([f, sizes[f], sum(1 for v in rows if rows[v].get(f, 0) > 0),
                    sum(1 for v in rows if rows[v].get(f, 0) == sizes[f])])
print(f"  wrote cohort_comparison.csv ({len(out)} variables x {len(cols)} folders) and cohort_comparison_sizes.csv")
