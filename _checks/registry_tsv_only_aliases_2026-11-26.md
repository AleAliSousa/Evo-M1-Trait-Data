# Resolved TSV-only naming audit — 2026-11-26

All 33 rows previously flagged TSV-only by exact path now have their local CSV
at the registry's exact paper/item path. The check reports zero TSV-only rows.
The 22 additional rows with both filenames mismatched were also corrected.
See `registry_file_balance_2026-11-26.md` and
`registry_name_renames_2026-11-26.csv` for the current count and path history.

Recheck with `bash _tools/check_tsv_only_aliases.sh`.
