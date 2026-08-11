#!/usr/bin/env python3
"""Does body_ecology_compiled.R reproduce the retired Python builder?

`build_body_ecology_merge.py` was the multi-measure builder for __merging_body_ecology; the R twin
covered only the `mass` class. The Python was retired on 2026-08-07 and its scope folded into
`body_ecology_compiled.R`, so the R is now the single implementation. This script diffs the R's
current output against `_checks/body_ecology_fixture/` — the Python's last output, frozen.

    Rscript run_all_scripts_v2.R     # or EVOM1_ONLY='merging_body_ecology' Rscript run_all_scripts_v2.R
    python3 _checks/check_body_ecology_against_fixture.py

Exit status 0 if every file matches (or differs only by rounding), 1 otherwise. Comparison rules
are shared with compare_R_vs_python_builders.py: row order ignored, R `NA` == Python empty field,
R `TRUE` == Python `True`, numeric cells equal within a relative 1e-9, and a file whose only
mismatches are <= 1e-3 is reported as IDENTICAL_TO_ROUNDING rather than a disagreement.
"""
import csv, gzip, importlib.util, os, sys, tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(HERE)
FIXTURE = os.path.join(HERE, "body_ecology_fixture")
TARGET = os.path.join(REPO, "__merging_body_ecology")
FILES = ["body_ecology_source_columns.csv", "body_ecology_unfiltered.csv",
         "body_ecology_long.csv", "body_ecology_dedupe_report.csv", "body_ecology_wide.csv"]

# reuse the comparator rather than reimplementing it (the whole point of this cleanup)
_spec = importlib.util.spec_from_file_location(
    "cmp_builders", os.path.join(HERE, "compare_R_vs_python_builders.py"))
cmp_builders = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(cmp_builders)


def main():
    if not os.path.isdir(FIXTURE):
        sys.exit(f"no fixture at {FIXTURE}")
    worst, lines = "IDENTICAL", []
    tmp = tempfile.mkdtemp(prefix="be_fix_")
    for fn in FILES:
        gz = os.path.join(FIXTURE, fn + ".gz")
        cur = os.path.join(TARGET, fn)
        if not os.path.exists(gz):
            lines.append(f"  {fn:38s} SKIP     no fixture"); continue
        if not os.path.exists(cur):
            lines.append(f"  {fn:38s} MISSING  the R script did not write it"); worst = "DIFFERS"; continue
        ref = os.path.join(tmp, fn)
        with gzip.open(gz, "rt", encoding="utf-8") as f_in, open(ref, "w", encoding="utf-8") as f_out:
            f_out.write(f_in.read())
        verdict, detail = cmp_builders.compare(ref, cur, la="fixture", lb="R")
        lines.append(f"  {fn:38s} {verdict:22s} {detail}")
        if verdict == "DIFFERS":
            worst = "DIFFERS"
        elif verdict == "IDENTICAL_TO_ROUNDING" and worst == "IDENTICAL":
            worst = "IDENTICAL_TO_ROUNDING"
    print("body_ecology_compiled.R vs the frozen Python output\n")
    print("\n".join(lines))
    print(f"\noverall: {worst}")
    if worst == "DIFFERS":
        print("\nThe R does not reproduce the fixture. Either the port is incomplete, or the change\n"
              "was deliberate — if deliberate, record it in _checks/body_ecology_fixture/README.md.")
    return 0 if worst != "DIFFERS" else 1


if __name__ == "__main__":
    sys.exit(main())
