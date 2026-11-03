# Schmidt_etal_1945_TABLE1

**Item name** `Schmidt_etal_1945_TABLE1` · **Item number** `TABLE 1` · **Item encoded (derived, awaiting registration)** `10.1152%2Fajplegacy.1945.143.1.33_TABLE1`

Schmidt, C. F., Kety, S. S., & Pennes, H. H. (1945). The gaseous metabolism of the brain of the monkey. American Journal of Physiology, 143(1), 33-52. <https://doi.org/10.1152/ajplegacy.1945.143.1.33>

**Item full original title:** TABLE 1

> **Not yet registered.** No `__ReadMe.xlsx` row exists for this item; the public TSV is named by the code the registry formula would build (DOI with `/` percent-encoded, `_`, item locus) — the Mink_etal_1981 convention — and must be renamed if the registry resolves differently. Paste `Schmidt_etal_1945_TABLE1_registry_row.xlsx` to register.

## Source

PDF `schmidt_etal_1945.pdf` (copied from EndNote PDF/1682367563/), journal pp. 33-52 (PDF pages 1-20). Text layer: OCR text layer, unusable for tables (TABLE 4 is printed sideways); values read from 300/500-dpi renders.

Eleven 'normal' experiments and their Average. **Kaufman 2004 and Mink 1981 use the Average row (CBF 46.9, O2 uptake 3.7).** Expts 30 and 31 (5.8 and 5.3 kg) are probably spider monkeys (see Species).

## Pipeline

```
Source PDF
  -> Schmidt_etal_1945_extract_snapshot.R        verbatim printed block, refuses to overwrite a differing frozen copy
  -> Schmidt_etal_1945_TABLE1_snapshot.csv   FROZEN: 17 printed rows
  -> Schmidt_etal_1945_TABLE1.R              parse + table checks (no values typed)
  -> Schmidt_etal_1945_TABLE1.csv            116 rows (one per printed value)  ("use this")
  -> __Public/comparative-data/10.1152%2Fajplegacy.1945.143.1.33_TABLE1.tsv
  -> reference_tables/Schmidt_etal_1945_TABLE1_definitions.csv
```

## Who read the values, when, and how it was checked

Transcribed **blind** by an AI assistant (Claude) on 2026-11-02 from 300-dpi page renders, with 500-dpi crops (rotated upright for sideways tables) read at 2-5x zoom, before any compilation value was looked at. The OCR text layer was used only to locate passages, never as the source of a value. After the snapshot was frozen, (1) the table's own arithmetic was run and (2) every row was re-read **across** against fresh crops, including every row a check flagged; no transcription error was found and no value was changed. Only then were the Kaufman/Karbowski copies compared (below).

### Structure of the snapshot

* One snapshot row per printed row: caption, header tiers, section rows, data rows and footnotes, in printed order; blank padding under spanning headers.
* A cell printed on two lines is one cell holding a newline; superscript footnote letters are written `^a`; `*`, `**` and parenthesised numbers are kept as printed; subscripts inline (CMRO2).

## Table checks

Result of an actual R run (2026-11-02): **36 pass, 5 mismatch, 0 not evaluable.** Tolerance: half a unit in the last printed decimal of every input, propagated, plus half a unit of the printed result (significant-digit units for the scaled human values of Schmidt TABLE 6). 'Not evaluable' marks relations that hold only per animal (mean of products/ratios) or values that cannot be traced.

Every mismatch is recorded as an erratum below (Schmidt_etal_1945-E001, Schmidt_etal_1945-E002, Schmidt_etal_1945-E003, Schmidt_etal_1945-E004, Schmidt_etal_1945-E005); the printed values are kept in the snapshot, CSV and TSV.

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
| Schmidt_etal_1945-E001 | pct_O2_consumed_by_brain | TABLE1, p. 37, row expt 14, 'Excellent—active movements', column '% by brain' | 11.7 |  | publication_error |  | proposed | % by brain = O2 up-take x brain weight/100 / Total x 100. With O2 up-take 3.4, Total 30 and brain weight 114 g: 12.92, vs printed 11.7 (allowance 0.46). | Printed value kept in the snapshot, CSV and TSV; detected by the item table_checks and every cell involved re-read on a fresh 500-dpi crop. |
| Schmidt_etal_1945-E002 | CMRO2_ml_100g_min | TABLE1, p. 37, row expt 22, 'Excellent—active movements', column 'O2 uptake' | 3.1 |  | publication_error |  | proposed | O2 uptake = A-V O2 x blood flow / 100 (the paper's definition). The same row prints A-V O2 7.8 and blood flow 41.0: 7.8x41.0/100 = 3.198, vs printed 3.1 (difference +0.098, rounding allowance 0.074). Which of the three cells is misprinted cannot be decided from the table. | Printed value kept in the snapshot, CSV and TSV; detected by the item table_checks and every cell involved re-read on a fresh 500-dpi crop. |
| Schmidt_etal_1945-E003 | pct_O2_consumed_by_brain | TABLE1, p. 37, row expt 30, 'Excellent—reflexes very active', column '% by brain' | 12.3 |  | publication_error |  | proposed | % by brain = O2 up-take x brain weight/100 / Total x 100. With O2 up-take 4.1, Total 37 and brain weight 105 g: 11.64, vs printed 12.3 (allowance 0.35). | Printed value kept in the snapshot, CSV and TSV; detected by the item table_checks and every cell involved re-read on a fresh 500-dpi crop. |
| Schmidt_etal_1945-E004 | AV_CO2_difference_vol_pct | TABLE 1, p. 37, row 'Average', column 'A-V diff. CO2' | 8.0 |  | publication_error | 7.9 | proposed | The mean of the 11 printed experiments is 7.864, which rounds to 7.9, not the printed 8.0 (allowance 0.1). | Printed value kept in the snapshot, CSV and TSV; detected by the item table_checks and every cell involved re-read on a fresh 500-dpi crop. |
| Schmidt_etal_1945-E005 | cerebral_RQ | TABLE 1, p. 37, row 'Average', column 'CEREBRAL R.Q.' | 1.00 |  | publication_ambiguity |  | proposed | The mean of the 11 printed R.Q. values is 0.974 (0.97), not the printed 1.00. The printed 1.00 equals the ratio of the printed Average A-V CO2 / A-V O2 (8.0/8.0), so the Average R.Q. was probably computed from the averages, one of which is itself off (see the A-V CO2 Average erratum). | Printed value kept in the snapshot, CSV and TSV; detected by the item table_checks and every cell involved re-read on a fresh 500-dpi crop. |

5 recorded, 5 open (proposed), 0 confirmed, 0 withdrawn.
<!-- errata:end -->
