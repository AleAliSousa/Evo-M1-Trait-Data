# `_archive/` — finished one-off work

Retired scripts and reports from investigations that are done, kept as a record.
Both sweep runners skip this folder (`SKIP_PATTERNS` `^_archive/` in
`_run_all_scripts_v2.R`; `_run_all_scripts_v3.py` delegates to it). Nothing in
here is re-run unless someone does it on purpose.

**Rule.** `_checks/` holds only checks that will run again and the latest output
of each run. When a one-off investigation is finished, its scripts and reports
move here together, into `YYYY-MM_<topic>/`, with a short README. A file about a
single paper or merge goes to that folder instead.

| Folder | What |
|---|---|
| `2026-09_endnote_gap_search/` | EndNote search for un-ingested data papers |
| `2026-10_database_inventory_and_builds/` | 30–31 Oct registry/filesystem inventory and build passes |
| `2026-10_orlin_intake/` | Orlin folder scouting and four intake batches |
| `2026-10_social_variables_expansion/` | social-variable project (group size, censuses, Zhu/Lukas trace) |
| `registry_audits/` | dated registry audits and the worklists they produced |
| `script_repairs/` | post-sweep repair notes and the R-vs-Python decision record |
