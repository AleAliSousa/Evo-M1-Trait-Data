# Schmidt_etal_1945_TABLE4

**Item name** `Schmidt_etal_1945_TABLE4` · **Item number** `TABLE 4` · **Item encoded (derived, awaiting registration)** `10.1152%2Fajplegacy.1945.143.1.33_TABLE4`

Schmidt, C. F., Kety, S. S., & Pennes, H. H. (1945). The gaseous metabolism of the brain of the monkey. American Journal of Physiology, 143(1), 33-52. <https://doi.org/10.1152/ajplegacy.1945.143.1.33>

**Item full original title:** TABLE 4

> **Not yet registered.** No `__ReadMe.xlsx` row exists for this item; the public TSV is named by the code the registry formula would build (DOI with `/` percent-encoded, `_`, item locus) — the Mink_etal_1981 convention — and must be renamed if the registry resolves differently. Paste `Schmidt_etal_1945_TABLE4_registry_row.xlsx` to register.

## Source

PDF `schmidt_etal_1945.pdf` (copied from EndNote PDF/1682367563/), journal pp. 33-52 (PDF pages 1-20). Text layer: OCR text layer, unusable for tables (TABLE 4 is printed sideways); values read from 300/500-dpi renders.

Convulsants (metrazol, coramine, picrotoxin), benzedrine and pentothal. Printed sideways.

## Pipeline

```
Source PDF
  -> Schmidt_etal_1945_extract_snapshot.R        verbatim printed block, refuses to overwrite a differing frozen copy
  -> Schmidt_etal_1945_TABLE4_snapshot.csv   FROZEN: 51 printed rows
  -> Schmidt_etal_1945_TABLE4.R              parse + table checks (no values typed)
  -> Schmidt_etal_1945_TABLE4.csv            440 rows (one per printed value)  ("use this")
  -> __Public/comparative-data/10.1152%2Fajplegacy.1945.143.1.33_TABLE4.tsv
  -> reference_tables/Schmidt_etal_1945_TABLE4_definitions.csv
```

## Who read the values, when, and how it was checked

Transcribed **blind** by an AI assistant (Claude) on 2026-11-02 from 300-dpi page renders, with 500-dpi crops (rotated upright for sideways tables) read at 2-5x zoom, before any compilation value was looked at. The OCR text layer was used only to locate passages, never as the source of a value. After the snapshot was frozen, (1) the table's own arithmetic was run and (2) every row was re-read **across** against fresh crops, including every row a check flagged; no transcription error was found and no value was changed. Only then were the Kaufman/Karbowski copies compared (below).

### Structure of the snapshot

* One snapshot row per printed row: caption, header tiers, section rows, data rows and footnotes, in printed order; blank padding under spanning headers.
* A cell printed on two lines is one cell holding a newline; superscript footnote letters are written `^a`; `*`, `**` and parenthesised numbers are kept as printed; subscripts inline (CMRO2).

## Table checks

Result of an actual R run (2026-11-02): **107 pass, 11 mismatch, 0 not evaluable.** Tolerance: half a unit in the last printed decimal of every input, propagated, plus half a unit of the printed result (significant-digit units for the scaled human values of Schmidt TABLE 6). 'Not evaluable' marks relations that hold only per animal (mean of products/ratios) or values that cannot be traced.

Every mismatch is recorded as an erratum below (Schmidt_etal_1945-E011, Schmidt_etal_1945-E012, Schmidt_etal_1945-E013, Schmidt_etal_1945-E014, Schmidt_etal_1945-E015, Schmidt_etal_1945-E016, Schmidt_etal_1945-E017, Schmidt_etal_1945-E018, Schmidt_etal_1945-E019, Schmidt_etal_1945-E020, Schmidt_etal_1945-E021); the printed values are kept in the snapshot, CSV and TSV.

## Data role

**Proposed: `primary`** — the values are the authors' own measurements.

## Anesthesia and preparation

* **Preparation:** in vivo, monkeys; cerebral blood flow by bubble flow meter in the common carotid stream (basilar artery tied, external carotids/branches ligated), cerebral venous blood from both internal jugular veins; O2 uptake = A-V O2 x flow.
* **Anesthesia:** per arm in the `anesthesia` column (curated from METHODS).

## Species

`species_as_published` keeps the paper's naming (the tables print none). Proposed mapping: `reference_tables/Schmidt_etal_1945_species_key_proposed.csv` (7-column `_keys/General/species_key.csv` schema) — not adopted into `_keys/`.

METHODS: Indian rhesus monkeys (2.8-4.6 kg) **except 3 spider monkeys (ateles pentadactylus, 5-5.8 kg)**; the tables do not say which experiments. TABLE 1 expts 30 (5.8 kg) and 31 (5.3 kg) fall in the spider-monkey range and are flagged in `note` (curator inference); the third spider monkey cannot be identified. Pooled rows (TABLE 1 Average, TABLE 6) therefore probably mix genera.

## Compilation check (done after the snapshot was frozen)

Kaufman 2004 A14 row 78 CBF 46.9 ± 11.7 and CMRO2 165.18 ± 31.25 umol/100g/min (n = 11) = TABLE 1 'Average' row (46.9; 3.7 ml/100g/min x 44.643). The SDs are not printed: they equal the sample SD of the 11 printed TABLE 1 experiments (11.68; 0.704 -> 0.70 x 44.643 = 31.25), i.e. Kaufman computed them. Kaufman's anesthesia 'Thiopentone' is incomplete: the animals were anesthetized with nembutal (pentobarbital) ~20 mg/kg i.p., supplemented by 5-mg pentothal doses. Kaufman's species 'M mulatta' is probably not uniform: METHODS include 3 spider monkeys (5-5.8 kg) and TABLE 1 expts 30 and 31 weigh 5.8 and 5.3 kg (above the 2.8-4.6 kg rhesus range), so the TABLE 1 average likely pools Macaca with Ateles (curator inference, provisional). Mink 1981's 3.7 = TABLE 1 Average / TABLE 6 'Normal' mean. Kaufman flags the row explicitly_anesthetized and excludes it from the primary merge. TABLE 1 Average A-V CO2 and R.Q. and one experiment's O2 uptake are publication slips (errata E001-E003), not affecting the compiled 3.7 and 46.9.

Restricted comparison extract: `Evo-M1-Trait-Data-restricted/__energetics_comparison/primary_items_extract/schmidt_1945.csv`.

## Human visual check of snapshot

Not yet recorded. An RA should lay the snapshot beside the page and read a few rows across (including mid-table rows), then record `DDMMYYYY_initials` in the registry's `Human visual check of snapshot` column.

<!-- errata:begin -->
## Errata

Generated from `reference_tables/Schmidt_etal_1945_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| Schmidt_etal_1945-E011 | pct_O2_consumed_by_brain | TABLE4, p. 40, row expt 13, 'Metrazol 100 mg. i.a.', column '% by brain' | 13.8 |  | publication_error |  | proposed | % by brain = O2 up-take x brain weight/100 / Total x 100. With O2 up-take 5.17, Total 34 and brain weight 88 g: 13.38, vs printed 13.8 (allowance 0.26). | Printed value kept in the snapshot, CSV and TSV; detected by the item table_checks and every cell involved re-read on a fresh 500-dpi crop. |
| Schmidt_etal_1945-E012 | CMRO2_ml_100g_min | TABLE4, p. 40, row expt 13, 'Pentothal 5 mg. i.a.', column 'O2 uptake' | 2.89 |  | publication_error |  | proposed | O2 uptake = A-V O2 x blood flow / 100 (the paper's definition). The same row prints A-V O2 6.7 and blood flow 38.0: 6.7x38.0/100 = 2.546, vs printed 2.89 (difference -0.344, rounding allowance 0.027). Which of the three cells is misprinted cannot be decided from the table. | Printed value kept in the snapshot, CSV and TSV; detected by the item table_checks and every cell involved re-read on a fresh 500-dpi crop. |
| Schmidt_etal_1945-E013 | pct_O2_consumed_by_brain | TABLE4, p. 40, row expt 13, 'Pentothal 5 mg. i.a.', column '% by brain' | 9.3 |  | publication_error |  | proposed | % by brain = O2 up-take x brain weight/100 / Total x 100. With O2 up-take 2.89, Total 31 and brain weight 88 g: 8.20, vs printed 9.3 (allowance 0.20). O2 up-take / Total x 100 = 9.32, i.e. the printed value is close to the figure for a 100 g brain. | Printed value kept in the snapshot, CSV and TSV; detected by the item table_checks and every cell involved re-read on a fresh 500-dpi crop. |
| Schmidt_etal_1945-E014 | pct_O2_consumed_by_brain | TABLE4, p. 40, row expt 13, '8 min. later', column '% by brain' | 5.9 |  | publication_error |  | proposed | % by brain = O2 up-take x brain weight/100 / Total x 100. With O2 up-take 1.89, Total 29 and brain weight 88 g: 5.74, vs printed 5.9 (allowance 0.16). | Printed value kept in the snapshot, CSV and TSV; detected by the item table_checks and every cell involved re-read on a fresh 500-dpi crop. |
| Schmidt_etal_1945-E015 | pct_O2_consumed_by_brain | TABLE4, p. 40, row expt 14, 'Control (nat. resp.)', column '% by brain' | 11.6 |  | publication_error |  | proposed | % by brain = O2 up-take x brain weight/100 / Total x 100. With O2 up-take 3.36, Total 32.6 and brain weight 114 g: 11.75, vs printed 11.6 (allowance 0.09). | Printed value kept in the snapshot, CSV and TSV; detected by the item table_checks and every cell involved re-read on a fresh 500-dpi crop. |
| Schmidt_etal_1945-E016 | pct_O2_consumed_by_brain | TABLE4, p. 40, row expt 14, 'Pentothal 5 mg. i.a.', column '% by brain' | 8.9 |  | publication_error |  | proposed | % by brain = O2 up-take x brain weight/100 / Total x 100. With O2 up-take 2.15, Total 26 and brain weight 114 g: 9.43, vs printed 8.9 (allowance 0.25). | Printed value kept in the snapshot, CSV and TSV; detected by the item table_checks and every cell involved re-read on a fresh 500-dpi crop. |
| Schmidt_etal_1945-E017 | pct_O2_consumed_by_brain | TABLE4, p. 40, row expt 18, 'Control (nat. resp.)', column '% by brain' | 10.9 |  | publication_error |  | proposed | % by brain = O2 up-take x brain weight/100 / Total x 100. With O2 up-take 2.71, Total 29.4 and brain weight 102 g: 9.40, vs printed 10.9 (allowance 0.08). | Printed value kept in the snapshot, CSV and TSV; detected by the item table_checks and every cell involved re-read on a fresh 500-dpi crop. |
| Schmidt_etal_1945-E018 | pct_O2_consumed_by_brain | TABLE4, p. 40, row expt 18, 'Metrazol 100 mg. i.a.', column '% by brain' | 9.3 |  | publication_error |  | proposed | % by brain = O2 up-take x brain weight/100 / Total x 100. With O2 up-take 3.53, Total 33.3 and brain weight 102 g: 10.81, vs printed 9.3 (allowance 0.08). | Printed value kept in the snapshot, CSV and TSV; detected by the item table_checks and every cell involved re-read on a fresh 500-dpi crop. |
| Schmidt_etal_1945-E019 | pct_O2_consumed_by_brain | TABLE4, p. 40, row expt 24, 'Control (nat. resp.)', column '% by brain' | 6.2 |  | publication_error |  | proposed | % by brain = O2 up-take x brain weight/100 / Total x 100. With O2 up-take 3.85, Total 36 and brain weight 85 g: 9.09, vs printed 6.2 (allowance 0.19). | Printed value kept in the snapshot, CSV and TSV; detected by the item table_checks and every cell involved re-read on a fresh 500-dpi crop. |
| Schmidt_etal_1945-E020 | CMRO2_ml_100g_min | TABLE4, p. 40, row expt 24, 'Coramine 50 mg. i.a.', column 'O2 uptake' | 3.24 |  | publication_error |  | proposed | O2 uptake = A-V O2 x blood flow / 100 (the paper's definition). The same row prints A-V O2 5.2 and blood flow 64.4: 5.2x64.4/100 = 3.349, vs printed 3.24 (difference +0.109, rounding allowance 0.040). Which of the three cells is misprinted cannot be decided from the table. | Printed value kept in the snapshot, CSV and TSV; detected by the item table_checks and every cell involved re-read on a fresh 500-dpi crop. |
| Schmidt_etal_1945-E021 | AV_O2_difference_vol_pct | TABLE4, p. 40, row expt 27, '15 min. later', column 'A-VO2' | 8.7 |  | publication_error |  | proposed | A-V O2 = Art. - Vein O2 content. The row prints Art. 10.5 and Vein 2.2: 8.3, vs printed A-VO2 8.7. The row's O2 up-take 4.37 = 8.7 x 50.3/100 follows the PRINTED A-VO2, so the slip is in an O2-content cell or in A-VO2 itself. | Printed value kept in the snapshot, CSV and TSV; detected by the item table_checks and every cell involved re-read on a fresh 500-dpi crop. |

11 recorded, 11 open (proposed), 0 confirmed, 0 withdrawn.
<!-- errata:end -->
