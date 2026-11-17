# Ten-folder physical-file coverage audit

The ten `metadata_sources.csv` manifests list 192 paper-local resource paths.
They also point to 39 registered item R builders through `builder_r` and to
39 public TSVs through `public_tsv_path`. All **44** files in the ten
`reference_tables/` subfolders have manifest rows and catalog field routes.

There are 54 physical files inside the paper folders that were not themselves
the `path` of an older `metadata_sources.csv` row. Thirty-nine are registered
item R builders named by `builder_r`. The other 15 are outside the active
ten-paper build. **All 54 now have their own rows in `pipeline_files.csv`.**
The 15 are marked ancillary or retired, so their registration does not make
them active metadata inputs.

| Location | Files | Classification |
| --- | --- | --- |
| `ManyPrimates__2022/` | `build_manyprimates_items.R`, `build_chivers_gautier.R`, `refresh_manyprimates_manifest.R` | Broader ManyPrimates and supplementary batch/manifest scripts; none is called by the ten-paper pilot or either registered ManyPrimates item builder. |
| `ManyPrimates__2022/` | `ManyPrimates_source_table_inventory_2026-10-21.xlsx`, `ManyPrimates_source_table_inventory_2026-10-21.json`, `ManyPrimates_source_review_2026-10-21.txt`, `ManyPrimates_supplements_to_find_2026-10-21.txt`, `ManyPrimates_supplement_downloads_2026-10-21.json`, `ManyPrimates_source_files_2026-10-21.json`, `ManyPrimates_missing_PDFs_2026-10-21.txt`, `ManyPrimates_etal_2022.txt` | Ancillary source-screening and retrieval records or source note; no active ten-paper item or metadata-gate read. |
| `Kaufman__2004/old/` | `Kaufman__2004_TableA15_README.md`, `Kaufman__2004_A15_comparison_mismatches.csv`, `Kaufman__2004_A15_comparison_long.csv` | Archived Table A15 comparison artifacts, not current item inputs or outputs. |
| `Kennedy_etal_1978/` | `Kennedy_etal_1978_extract_snapshot.R.retired` | Retired snapshot extraction script; current frozen snapshots and item builders are listed. |

The file-level registry has 315 paper-owned rows, including 39 item builders,
39 public TSVs, 30 manifest/self-registration rows, and these 15 ancillary or
retired files. The validator now scans every non-hidden physical file in all
ten paper folders and fails if any lacks a row. Lifecycle is distinct from
evidentiary authority: an archived comparison file remains findable without
becoming a source for the current metadata gate.
