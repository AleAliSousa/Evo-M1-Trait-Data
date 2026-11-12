# Andersen_etal_1992_Table5

**Item name** `Andersen_etal_1992_Table5` · **Item number** `Table 5` · **Item encoded** pending registration
(expected `10.1002%2Fcne.903260405_Table5`)

Andersen, B. B., Korbo, L., & Pakkenberg, B. (1992). A quantitative study of the human cerebellum with unbiased stereological techniques. *Journal of Comparative Neurology*, 326(4), 549–560. <https://doi.org/10.1002/cne.903260405>

**Item full original title:** TABLE 5. *Surface and Volume in Five Human Cerebella* (p. 559, PDF page 11).

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
  -> Andersen_etal_1992_Table5_snapshot.csv      FROZEN: hand transcription in the printed layout
  -> Andersen_etal_1992_Table5.R                 clean + reshape + table checks
  -> Andersen_etal_1992_Table5.csv               ("use this")
  -> __Public/comparative-data/<Item encoded>.tsv   (written once registered)
  -> reference_tables/Andersen_etal_1992_Table5_definitions.csv
```

## Who read the values, when, and how it was checked

Transcribed by an **AI assistant (Claude) on 2026-11-11** from 450-dpi renders of the page,
read row by row, typed directly into the frozen CSV (the build script contains no table values).
Checks: (1) the table's own arithmetic (below) — every recomputed mean and CV agrees with the print,
which also confirms the individual values; (2) a cross-check against an earlier staged extraction
(`s1a_stereology_extracted_values.csv`): every staged table value for this paper occurs in the
snapshots (the staged file is a cross-check only; the page image is the authority).

### Structure of the snapshot

Row 1 caption, row 2 the pial-surface row (printed above the rule), then the three printed
section headings (`Cerebellar volume (cm^3)`, `Average thickness of molecular layer (µm)`,
`Average thickness of granular layer (µm)`) as rows with an empty value cell, each followed by its
rows; rows printed indented keep two leading spaces; last row the printed legend.

## Table checks

(1) Cortex = Pars anterior + Pars posterior + Vermis + Flocculonodular lobe: 90.32 vs printed 90.4
(tolerance 0.205); (2) Total = Cortex + Dentate nuclei + White matter: 124.46 vs printed 125
(tolerance 0.605). **Actual R run 2026-11-11: 2 pass, 0 mismatch.**

## Units

Volumes are converted to the project unit **mm³** (`Vol.mm3` = cm³ × 1000). Pial surface (cm²) and
layer thickness (µm) stay in their printed units (`value.printed_unit`, `unit_as_printed`).
`Dentate nuclei` is printed plural; the paper does not say whether 0.96 cm³ is one or both nuclei
(the whole cerebellum was studied, so both is the likely reading — not asserted in the data).

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

Every row is a group mean of the five brains.

## Registration

Not yet in `__ReadMe.xlsx`. The proposed Sheet1 row is `Andersen_etal_1992_Table5_registry_row.xlsx` in this folder
(see its HOW_TO_PASTE sheet). Until the owner pastes it and runs `_tools/file_list.R`, the build
writes the CSV only and prints `not yet registered - TSV skipped`; once `Item encoded` resolves,
the same script writes `__Public/comparative-data/<Item encoded>.tsv`.

## Human visual check of snapshot

Pending. An AI assistant transcribed and checked the snapshot against the page images. A human
still needs to read a few rows **across** beside the page (including mid-table rows) and record
`DDMMYYYY_initials` in the `Human visual check of snapshot` column.
