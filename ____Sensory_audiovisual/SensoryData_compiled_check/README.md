# SensoryData_compiled — check fixture (not a source item)

**What this is.** The Bath "Sensory Data.xlsx" compilation (A. de Sousa + student
assistants, 2020–2022; frozen archive copy in `../_incoming_Bath_archive_20260814/`,
read-only) reshaped to a tidy long table. **It is not a paper**, so it is deliberately
NOT a source folder, NOT in `__ReadMe.xlsx`, and has NO public TSV (owner decision
2026-08-31, superseding the same-day Route-B registration, which was reverted).

**What it is for.** Each per-paper Route-A build (Heffner & Heffner 1992a, Koay et al
1998, Veilleux & Kirk 2014, …) is audited against this table in its `comparison/`
step: filter `SensoryData_compiled.csv` on the `reference` column (short codes as in
the workbook's per-value Reference columns; full citations in
`SensoryData_compiled_references.csv`) and require agreement or an explained mismatch.
The compilation's values must never be ingested directly — only the primary papers are.

**Files.** `SensoryData_compiled.csv` (763 rows = 167 species-rows × 15 traits;
`value_id` = `SensoryData_r<source excel row>_<trait>`), built by
`SensoryData_compiled.R` (canonical) / `SensoryData_compiled_mirror.py` (what actually
ran; no R in the build sandbox). `_definitions.csv` documents the traits,
`_references.csv` maps the 53 short reference codes to full citations.

**QC columns.** `qc_status`: 127 VA rows `quarantined_va_offset` (24-row offset error,
per-row audit in `../sensory_VA_offset_audit.csv`, status carried into `qc_note`);
3 `curator_flag` rows (beluga high-frequency conflict, Norway-rat localization
domestic/albino mix-up). `value_origin`: 17 values `digitised_from_figure` (≥4
decimals; chiefly Koay et al 1998 Fig. 6, Heffner 2018). `class`: 4 bird species —
any future sensory work gates on `class == "Mammalia"`.

See `../NOTE_sensory_audiovisual_intake.md` for the full archive audit and
`../SENSORY_AUDIOVISUAL_DATA_PLAN.md` for the per-paper extraction plan.
