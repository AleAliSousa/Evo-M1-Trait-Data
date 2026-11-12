# Andersen_etal_1992_Table6

**Item name** `Andersen_etal_1992_Table6` · **Item number** `Table 6` · **Item encoded** pending registration
(expected `10.1002%2Fcne.903260405_Table6`)

Andersen, B. B., Korbo, L., & Pakkenberg, B. (1992). A quantitative study of the human cerebellum with unbiased stereological techniques. *Journal of Comparative Neurology*, 326(4), 549–560. <https://doi.org/10.1002/cne.903260405>

**Item full original title:** TABLE 6. *Total Number of Six Cell Types in Four Different Regions (10⁶)* (p. 559, PDF page 11).

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
  -> Andersen_etal_1992_Table6_snapshot.csv      FROZEN: hand transcription in the printed layout
  -> Andersen_etal_1992_Table6.R                 clean + reshape
  -> Andersen_etal_1992_Table6.csv               ("use this")
  -> __Public/comparative-data/<Item encoded>.tsv   (written once registered)
  -> reference_tables/Andersen_etal_1992_Table6_definitions.csv
```

## Who read the values, when, and how it was checked

Transcribed by an **AI assistant (Claude) on 2026-11-11** from 450-dpi renders of the page,
read row by row, typed directly into the frozen CSV (the build script contains no table values).
Checks: (1) the table's own arithmetic (below) — every recomputed mean and CV agrees with the print,
which also confirms the individual values; (2) a cross-check against an earlier staged extraction
(`s1a_stereology_extracted_values.csv`): every staged table value for this paper occurs in the
snapshots (the staged file is a cross-check only; the page image is the authority).

### Structure of the snapshot

Row 1 caption (`(10^6)^1`), row 2 the header (the printed `Flocculo-/nodular/lobe` and
`Pars/posterior` line-wraps joined into one cell each), rows 3–8 the six cell types, row 9
footnote 1. Several rows look bolder in the scan (Purkinje, Glial in molecular layer); no legend
gives this meaning, so it is not reproduced.

## Table checks

Table 6 prints no total of its own, so the item script `Andersen_etal_1992_Table6.R` carries no table
check and reads only its own snapshot.

**Cross-item check in `internal_checks/`** (build HOWTO 7b): sum of the four regions per cell type vs the
**Table 4 Mean** row (the four regions make up the cerebellar cortex), in
`internal_checks/Andersen_etal_1992_Table6_internal_check.R` (reads the Table 6 and Table 4 snapshots,
read-only), result in `internal_checks/Andersen_etal_1992_Table6_internal_check.csv`. Tolerance =
half-units of the four regional values + half a unit of the Table 4 mean. **Actual R run (temp copy,
2026-11-12): 6 pass, 0 mismatch.** Largest relative difference:
Granule 100,999 vs 101,100 (tolerance 200.5); Neurons in molecular layer 1,636 vs 1,630 (tolerance 16).

## Regions

`Pars anterior` and `Pars posterior` are hemispheric cortex **excluding** the vermis (Table 5 indents
all four as parts of Cortex and their volumes sum to the cortex).

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

Not yet in `__ReadMe.xlsx`. The proposed Sheet1 row is `Andersen_etal_1992_Table6_registry_row.xlsx` in this folder
(see its HOW_TO_PASTE sheet). Until the owner pastes it and runs `_tools/file_list.R`, the build
writes the CSV only and prints `not yet registered - TSV skipped`; once `Item encoded` resolves,
the same script writes `__Public/comparative-data/<Item encoded>.tsv`.

## Human visual check of snapshot

Pending. An AI assistant transcribed and checked the snapshot against the page images. A human
still needs to read a few rows **across** beside the page (including mid-table rows) and record
`DDMMYYYY_initials` in the `Human visual check of snapshot` column.
