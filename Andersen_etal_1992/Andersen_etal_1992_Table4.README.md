# Andersen_etal_1992_Table4

**Item name** `Andersen_etal_1992_Table4` · **Item number** `Table 4` · **Item encoded** pending registration
(expected `10.1002%2Fcne.903260405_Table4`)

Andersen, B. B., Korbo, L., & Pakkenberg, B. (1992). A quantitative study of the human cerebellum with unbiased stereological techniques. *Journal of Comparative Neurology*, 326(4), 549–560. <https://doi.org/10.1002/cne.903260405>

**Item full original title:** TABLE 4. *Total Cell Number in Five Human Cerebella (10⁶)* (p. 557, PDF page 9).

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
Source (scanned PDF, p. 557, PDF page 9)
  -> Andersen_etal_1992_Table4_snapshot.csv      FROZEN: hand transcription in the printed layout
  -> Andersen_etal_1992_Table4.R                 clean + reshape + table checks
  -> Andersen_etal_1992_Table4.csv               ("use this")
  -> __Public/comparative-data/<Item encoded>.tsv   (written once registered)
  -> reference_tables/Andersen_etal_1992_Table4_definitions.csv
```

## Who read the values, when, and how it was checked

Transcribed by an **AI assistant (Claude) on 2026-11-11** from 450-dpi renders of the page,
read row by row, typed directly into the frozen CSV (the build script contains no table values).
Checks: (1) the table's own arithmetic (below) — every recomputed mean and CV agrees with the print,
which also confirms the individual values; (2) a cross-check against an earlier staged extraction
(`s1a_stereology_extracted_values.csv`): every staged table value for this paper occurs in the
snapshots (the staged file is a cross-check only; the page image is the authority).

### Structure of the snapshot

Row 1 caption (with the footnote mark written `^1`), row 2 the printed header, rows 3–8 brains
1–5 and Mean, row 9 footnote 1. Cells keep the printed form `value (dispersion)` with thousands
commas; brain 4's dentate cell is the printed em dash `—`. In parentheses: **CE = SEM/mean** after
individual values, **CV = SD/mean** after the Mean (footnote 1). `/g` and `/m` = granular and
molecular layer.

## Table checks

Mean row = mean of brains 1–5 (dentate: 4 brains, the dash left out), tolerance = mean of the
inputs' half-units + half a unit of the printed mean; Mean-row CV = sample SD (n − 1)/mean,
tolerance = first-order propagation of the input half-units + 0.005.

**Result of an actual R run (2026-11-11): 14 pass, 0 mismatch, 0 not evaluable.** Largest
difference: Granule mean 101,160 vs printed 101,100 (tolerance 100).

Also consistent with the text (not a table check): sum of the six cortical means = 105,201.8 × 10^6
≈ the "105,000 × 10^6" total of the Abstract/Results; Purkinje : granule = 1 : 3,315 (text 1 : 3,300);
Purkinje per dentate neuron = 6.1 (text "six").

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

Not yet in `__ReadMe.xlsx`. The proposed Sheet1 row is `Andersen_etal_1992_Table4_registry_row.xlsx` in this folder
(see its HOW_TO_PASTE sheet). Until the owner pastes it and runs `_tools/file_list.R`, the build
writes the CSV only and prints `not yet registered - TSV skipped`; once `Item encoded` resolves,
the same script writes `__Public/comparative-data/<Item encoded>.tsv`.

## Human visual check of snapshot

Pending. An AI assistant transcribed and checked the snapshot against the page images. A human
still needs to read a few rows **across** beside the page (including mid-table rows) and record
`DDMMYYYY_initials` in the `Human visual check of snapshot` column.
