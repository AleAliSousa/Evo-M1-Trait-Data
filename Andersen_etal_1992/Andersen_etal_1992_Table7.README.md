# Andersen_etal_1992_Table7

**Item name** `Andersen_etal_1992_Table7` · **Item number** `Table 7` · **Item encoded** pending registration
(expected `10.1002%2Fcne.903260405_Table7`)

Andersen, B. B., Korbo, L., & Pakkenberg, B. (1992). A quantitative study of the human cerebellum with unbiased stereological techniques. *Journal of Comparative Neurology*, 326(4), 549–560. <https://doi.org/10.1002/cne.903260405>

**Item full original title:** TABLE 7. *The Mean and Overall Densities in Four Different Regions in the Human Cerebellum (10³ mm⁻³)* (p. 559, PDF page 11).

## Source

1992 journal article, scanned PDF (OCR text layer present but scrambled: table cells are
re-ordered and digits garbled, e.g. `Golgiig` for `Golgi/g`, `80.900` for `80,900`). All values were
therefore read from the page images. Copied into this folder with its original filename
`Andersen-1992-A quantitative study of the huma.pdf` from `_other_sources_metab_correlates_candidates/`.

Cohort: five normal Danish males, no neurological disorder, average age 74 (69–77; Table 1 of the
paper). Healthy subjects only — no disease group. Whole cerebellum (not one hemisphere).
Glycolmethacrylate embedding; average areal shrinkage 1.9% — "no net shrinkage was detectable"
(p. 557), so values are close to the fresh-tissue basis.

## Pipeline

```
Source (scanned PDF, p. 559, PDF page 11)
  -> Andersen_etal_1992_Table7_snapshot.csv      FROZEN: hand transcription in the printed layout
  -> Andersen_etal_1992_Table7.R                 clean + reshape + table checks
  -> Andersen_etal_1992_Table7.csv               ("use this")
  -> __Public/comparative-data/<Item encoded>.tsv   (written once registered)
  -> reference_tables/Andersen_etal_1992_Table7_definitions.csv
```

## Who read the values, when, and how it was checked

Transcribed by an **AI assistant (Claude) on 2026-11-11** from 450-dpi renders of the page,
read row by row, typed directly into the frozen CSV (the build script contains no table values).
Checks: (1) the table's own arithmetic (below) — every recomputed mean and CV agrees with the print,
which also confirms the individual values; (2) a cross-check against an earlier staged extraction
(`s1a_stereology_extracted_values.csv`): every staged table value for this paper occurs in the
snapshots (the staged file is a cross-check only; the page image is the authority).

### Structure of the snapshot

Row 1 caption (`(10^3 mm^-3)^1`), row 2 header, then for each region a heading row (value cells
empty) followed by brains 1–5 and Mean; then `Overall`; last row footnote 1. One snapshot row per
printed row. Some rows look bolder in the scan (e.g. Pars anterior 2, Vermis 2–3,
Flocculonodular 3–4 and Mean); no legend gives this meaning, so it is not reproduced.

## Table checks

For every region × cell type: Mean = mean of brains 1–5 and Mean-row CV = sample SD/mean of
brains 1–5 (same rules as Table 4). The Overall row (total number / total reference volume) cannot be
checked from the table: the layer volumes are not printed.
**Actual R run 2026-11-11: 48 pass, 0 mismatch, 0 not evaluable.**

## Reference spaces

Densities are per mm³ of the **granular layer** (granule, Purkinje, Golgi, glia in granular layer) or
of the **molecular layer** (glia and neurons in molecular layer), not per mm³ of whole cortex.
`density.per_mm3` = printed × 1000.

## Data role

**Proposed: `primary`** — the authors' own stereological estimates.

## Species names

The paper prints no binomial; the species is `human` (title/text), kept verbatim in
`species_as_published`. No `_keys/` file was edited. A proposed row (`human` → *Homo sapiens*,
NCBI 9606, collection General) is in `reference_tables/Andersen_etal_1992_species_key_proposed.csv`; adopt it
into `_keys/General/species_key.csv` before this item enters a species-resolving merge. The
counting method should also be recorded in `_keys/cell_count_methods/source_methods.csv`
(proposed: `STEREO_DISECTOR`; dentate nuclei by fractionator, target `cell_counts_histology`) — not done here (no `_keys/` edits).

## Observation level

Rows are **individual brains** plus the printed group **Mean** (`observation_level`). Use the Mean rows, or pool the individuals, before any species-level use.

## Registration

Not yet in `__ReadMe.xlsx`. The proposed Sheet1 row is `Andersen_etal_1992_Table7_registry_row.xlsx` in this folder
(see its HOW_TO_PASTE sheet). Until the owner pastes it and runs `_tools/file_list.R`, the build
writes the CSV only and prints `not yet registered - TSV skipped`; once `Item encoded` resolves,
the same script writes `__Public/comparative-data/<Item encoded>.tsv`.

## Human visual check of snapshot

Pending. An AI assistant transcribed and checked the snapshot against the page images. A human
still needs to read a few rows **across** beside the page (including mid-table rows) and record
`DDMMYYYY_initials` in the `Human visual check of snapshot` column.
