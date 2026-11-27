# Registry roles beyond data — 2026-11-27

Updated `__ReadMe.xlsx` Sheet1 column AP, `role other than data (metadata, internal check, cross-check)`, from 3 to 64 populated cells. The 61 newly classified item rows are listed in `registry_other_roles_2026-11-27.csv` with their registry titles and main-trait descriptions. The three owner-entered examples were preserved exactly.

## Conservative labels

- `references`: a bibliography, source list, or study citation mapping is the item's substantive use.
- `metadata`: a specimen/sample inventory, taxonomy, atlas crosswalk, processing-method record, or other descriptive context is the item's substantive use.
- `data, metadata`: the item reports measurements and substantial sample, source, method, or region metadata used alongside them.
- `internal check`: the source item supports a within-publication consistency check. This label was not assigned merely because a README documents validation of an ordinary data table.
- `source provenance`: an upstream atlas publication retained as the citation for a processed external analysis matrix rather than a standalone Evo-M1 item.

Combined labels reflect documented multiple roles. Blank AP cells mean that no distinct supporting role was verified in this pass, not that the item has no value beyond its data or that a review is complete. No new `cross-check` label was assigned without a documented comparison target and source relationship.

Only Sheet1 worksheet XML changed: the new AP cells were added and their row spans extended to column AP. The other workbook XML parts, formulas, cached values, and existing AP entries were preserved. `python3 _tools/check_readme_integrity.py` passed: Sheet1 1,322 rows, `SOURCE_DISPOSITION` 53 × 42, 1,295 public TSVs listed.

The separately run exact-path audit currently reports 1,271 both, 2 CSV-only, 24 TSV-only, 2 non-tabular trees, and 1 neither across 1,300 populated item rows. The same figures were present in the pre-edit workbook backup, so they are unrelated to the AP-column additions. Reconcile those path/name changes separately rather than altering the user's new registry details during this role pass.
