# Open build and source decisions — 2026-11-26

Fresh checks: `python3 _tools/audit_registry_file_balance.py`; `python3 _tools/audit_folders.py`; top-level source/build-file scan; direct `__ReadMe.xlsx` Sheet1 and `SOURCE_DISPOSITION` search. Historical queue files are not used as current counts.

## Registered source without a tabular item

| Source | Status | Next action |
|---|---|---|
| Hawrylycz et al. 2012, Sheet1 row 420 | The six-donor Julich AHBA expression matrix exists in the separate `Analysis_region_celltype_human` folder. The paper folder holds atlas, sample-count, centroid-filled-region, and methods files. No Evo-M1 trait item has been selected. | Choose a defined regional gene score or other comparative output for a separate analysis, or move this source-only row to `SOURCE_DISPOSITION` after checking its existing path consumers. This is a source-scope decision, not an unrun R build. |

## Source files with incomplete or absent registered item

| Source item | Files verified | Remaining work |
|---|---|---|
| Stephan et al. 1987 Table 2 | Scanned source, 45-primate frozen snapshot, R reader and analysis CSV; only Table 1 is registered. | Finish item README/definitions as needed, add Table 2 registry row, run reader to produce DOI/PMID-coded public TSV, validate. |
| Herculano-Houzel et al. 2020 Table 3 | 13-species frozen snapshot, R reader, analysis CSV, detailed item README; Tables 1–2 are registered. | Add Table 3 registry row, run reader to produce public TSV, validate. Human visual source check remains pending. |
| Heuer et al. 2019 author `Data` | 65-case local measurement CSV checked against author GitHub stats; Table 1 and S1 are registered. | Freeze the author stats source locally, add reproducible reader and definitions, register a distinct Data item, write public TSV, validate. Keep its 3-D folding metric separate from the Zilles-method GI merge. |

## Held source data not available locally

| Source | Status | Next action |
|---|---|---|
| González-Lagos et al. 2010, 493-species trait table | The article PDF and a built 43-reference Appendix I item are held; the underlying species table and species-to-reference map are absent. | Obtain the original dataset from the authors or archive before selecting and building a trait item. |

The exact registry-path audit reports 1,295 CSV+TSV pairs, zero CSV-only, zero TSV-only, two non-tabular tree assets, and one neither (Hawrylycz) across 1,298 populated Sheet1 rows. The top-level folder scan found one source-bearing paper folder with no top-level item CSV or R reader: Hawrylycz. Other unmatched folders in the generic folder audit are empty placeholders or a non-paper directory. The Fu et al. 2013 Table 1 disposition conflict was stale: that item is already built and registered, so the conflict was closed in `_SOURCE_DISPOSITION_REGISTER.md`.

This audit identifies source/build-file and registration gaps; it does not close the active figure-replot backfill, human source-image signoff, merge eligibility, or every possible table inside already built publications.
