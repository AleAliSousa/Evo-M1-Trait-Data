# Social-variable expansion — 22–23 October 2026

The `social_variables/` folder is the full working directory of the
social-variable project: Dunbar & Bever group sizes, the Zhu et al. 2023 /
Lukas provenance trace, primary population censuses, and the taxonomy
resolution behind them. Its own `social_variables/README.md` gives the detail.

Contents, by role:
- **Builders:** `build_population_censuses.py` froze the census source files
  that five paper folders cite as provenance (Jaeggi 2020, Modlinska & Stryjek
  2016, Norbury 1998, Qiu 2022, Ziege 2016). `apply_*_taxonomy.py`,
  `fetch_*_taxonomy.py` and `trace_zhu_lukas.py` are also here.
- **Checks:** `check_population_censuses.R`, `check_social_expansion.R`,
  `check_zhu_coverage.R` and `compare_coverage.R` tested the expansion when it was built.
- **Audits and worklists:** the `*_audit.csv`, `*_coverage*.csv` and
  `*_queue.csv` files, and the `*_evidence/` folders.

Status: finished. The resulting values live in the paper folders and
`__merging_supplementary/`. This folder used to sit in `_checks/`, so the sweep
re-queued its scripts on every run. Path strings were rewritten on the move,
and the Python scripts' repo-root depth was raised from `parents[2]` to
`parents[3]`, so the builders still resolve the repo root.
Moved here from `_checks/social_variables/` on 2026-11-11.
