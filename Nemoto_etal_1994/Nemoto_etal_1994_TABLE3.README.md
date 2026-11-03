# Nemoto_etal_1994_TABLE3

**Item name** `Nemoto_etal_1994_TABLE3` · **Item number** `TABLE 3` · **Item encoded (derived, awaiting registration)** `10.1097%2F00008506-199407000-00004_TABLE3`

Nemoto, E. M., Yao, L., Yonas, H., & Darby, J. (1994). Compartmentation of whole brain blood flow and oxygen and glucose metabolism in monkeys. Journal of Neurosurgical Anesthesiology, 6(3), 170-174. <https://doi.org/10.1097/00008506-199407000-00004>

**Item full original title:** TABLE 3. Compartmentation of cerebral blood flow (CBF), cerebral metabolic rate of oxygen (CMRO2), and of glucose (CMRG), and the oxygen-glucose index (OGI) in six normal rhesus monkeys (values are X̄ ± SD)

> **Not yet registered.** No `__ReadMe.xlsx` row exists for this item; the public TSV is named by the code the registry formula would build (DOI with `/` percent-encoded, `_`, item locus) — the Mink_etal_1981 convention — and must be renamed if the registry resolves differently. Paste `Nemoto_etal_1994_TABLE3_registry_row.xlsx` to register.

## Source

PDF `Nemoto-1994-Compartmentation of.pdf` (copied from EndNote PDF/1539942437/), journal pp. 170-174 (PDF pages 1-5). Text layer: NO text layer (photographed pages); every value read from 300-dpi renders.

Total (conscious), basal (isoelectric thiopental) and active (= total - basal) compartments. **Kaufman 2004 and Karbowski 2007 copied the Total column** (Kaufman: CBF, CMRO2 and CMRG; Karbowski: CMRO2 only, it has no CMRgl row for this paper). Its totals do not reproduce from TABLE 2 (errata E001-E006).

## Pipeline

```
Source PDF
  -> Nemoto_etal_1994_extract_snapshot.R        verbatim printed block, refuses to overwrite a differing frozen copy
  -> Nemoto_etal_1994_TABLE3_snapshot.csv   FROZEN: 11 printed rows
  -> Nemoto_etal_1994_TABLE3.R              parse + table checks (no values typed)
  -> Nemoto_etal_1994_TABLE3.csv            21 rows (one per printed value)  ("use this")
  -> __Public/comparative-data/10.1097%2F00008506-199407000-00004_TABLE3.tsv
  -> reference_tables/Nemoto_etal_1994_TABLE3_definitions.csv
```

TABLE 3's checks read the frozen TABLE 2 snapshot.

## Who read the values, when, and how it was checked

Transcribed **blind** by an AI assistant (Claude) on 2026-11-02 from 300-dpi page renders, with 500-dpi crops (rotated upright for sideways tables) read at 2-5x zoom, before any compilation value was looked at. The OCR text layer was used only to locate passages, never as the source of a value. After the snapshot was frozen, (1) the table's own arithmetic was run and (2) every row was re-read **across** against fresh crops, including every row a check flagged; no transcription error was found and no value was changed. Only then were the Kaufman/Karbowski copies compared (below).

### Structure of the snapshot

* One snapshot row per printed row: caption, header tiers, section rows, data rows and footnotes, in printed order; blank padding under spanning headers.
* A cell printed on two lines is one cell holding a newline; superscript footnote letters are written `^a`; `*`, `**` and parenthesised numbers are kept as printed; subscripts inline (CMRO2).

## Table checks

Result of an actual R run (2026-11-02): **6 pass, 6 mismatch, 3 not evaluable.** Tolerance: half a unit in the last printed decimal of every input, propagated, plus half a unit of the printed result (significant-digit units for the scaled human values of Schmidt TABLE 6). 'Not evaluable' marks relations that hold only per animal (mean of products/ratios) or values that cannot be traced.

Every mismatch is recorded as an erratum below (Nemoto_etal_1994-E001, Nemoto_etal_1994-E002, Nemoto_etal_1994-E003, Nemoto_etal_1994-E004, Nemoto_etal_1994-E005, Nemoto_etal_1994-E006); the printed values are kept in the snapshot, CSV and TSV.

## Data role

**Proposed: `primary`** — the values are the authors' own measurements.

## Anesthesia and preparation

* **Preparation:** in vivo, adult rhesus monkeys; whole-brain CBF by H2 clearance (platinum electrode in superior sagittal sinus); CMRO2 and CMRG = CBF x arterial - confluence-of-sinuses A-V difference.
* **Anesthesia:** per arm in the `anesthesia` column (curated from METHODS). Conscious arm: none: fully conscious, restrained in chair (surgery under ketamine 10 mg/kg i.m. + 10 mg/kg/h, >=2 h recovery; lidocaine jelly on wounds); thiopental arm: sodium thiopental 30 mg/kg i.v. then infusion titrated to isoelectric EEG; intubated, mechanically ventilated on room air; norepinephrine infusion to hold MAP ~100 mm Hg.

## Species

`species_as_published` keeps the paper's naming (the tables print none). Proposed mapping: `reference_tables/Nemoto_etal_1994_species_key_proposed.csv` (7-column `_keys/General/species_key.csv` schema) — not adopted into `_keys/`.

## Compilation check (done after the snapshot was frozen)

Kaufman 2004 A14 row 76 CMRO2 265.6 ± 24.1 umol/100g/min and CMRgl 44.9 ± 15.4 = TABLE 3 conscious 'Total' 5.95 ± 0.54 ml/100 g/min x 44.64 and 8.09 ± 2.78 mg/100 g/min / 0.18016, exact; Kaufman's CBF 76.1 ± 20.5 is not printed (TABLE 3 prints 76 ± 21; TABLE 2 rows 76/75/71 ± 18/23/19), so its extra digit has no printed source; Kaufman n = 3 whereas the paper has six monkeys (three measurements each). Karbowski 2007 S1 row 7 CMRO2 0.060 ± 0.005 ml/g/min = the same TABLE 3 Total rounded; its total O2 6.0 ml/min is not printed (no brain weight in the paper). Both compilations copied the conscious (unanesthetized) arm, correctly labelled conscious; neither carries the thiopental (basal) arm. NB the copied TABLE 3 Total does not equal the mean of the three conscious TABLE 2 measurements (CMRO2 5.59, CBF 74, CMRG 7.70): errata Nemoto_etal_1994-E001..E006 (publication_ambiguity/error); the compilation value faithfully reflects TABLE 3 and the abstract.

Restricted comparison extract: `Evo-M1-Trait-Data-restricted/__energetics_comparison/primary_items_extract/nemoto_1994.csv`.

## Human visual check of snapshot

Not yet recorded. An RA should lay the snapshot beside the page and read a few rows across (including mid-table rows), then record `DDMMYYYY_initials` in the registry's `Human visual check of snapshot` column.

<!-- errata:begin -->
## Errata

Generated from `reference_tables/Nemoto_etal_1994_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| Nemoto_etal_1994-E001 | CBF_ml_100g_min | TABLE 3, p. 173, row 'CBF', column 'Total' | 76 ± 21 |  | publication_ambiguity |  | proposed | RESULTS (p. 172) define Total as the average of the three conscious measurements, which TABLE 2 prints as 76 ± 18, 75 ± 23, 71 ± 19 (measurements 1-3, the same six monkeys each time): mean 74.000, not the printed Total 76. The abstract and RESULTS repeat the TABLE 3 value. Cannot tell from the paper which table is in error. | Kaufman 2004 carries CBF 76.1 +/- 20.5 (see the extract's compilation check). |
| Nemoto_etal_1994-E002 | CBF_ml_100g_min | TABLE 3, p. 173, row 'CBF', column 'Basal' | 48 ± 14^a |  | publication_ambiguity |  | proposed | METHODS define Basal as the isoelectric-EEG values; TABLE 2 prints measurements 4-6 as 49 ± 14, 47 ± 15, 43 ± 8: mean 46.333, not the printed Basal 48. Cannot tell which table is in error. | Printed value kept in the snapshot, CSV and TSV; detected by the item table_checks and every cell involved re-read on a fresh 500-dpi crop. |
| Nemoto_etal_1994-E003 | CMRO2_ml_100g_min | TABLE 3, p. 173, row 'CMRO2', column 'Total' | 5.95 ± 0.54 |  | publication_ambiguity |  | proposed | RESULTS (p. 172) define Total as the average of the three conscious measurements, which TABLE 2 prints as 5.70 ± 1.10, 5.40 ± 0.95, 5.66 ± 1.11 (measurements 1-3, the same six monkeys each time): mean 5.587, not the printed Total 5.95. The abstract and RESULTS repeat the TABLE 3 value. Cannot tell from the paper which table is in error. | Kaufman 2004 (265.6 umol/100g/min) and Karbowski 2007 (0.060 ml/g/min) both carry the TABLE 3 CMRO2 Total (5.95). |
| Nemoto_etal_1994-E004 | CMRgl_mg_100g_min | TABLE 3, p. 173, row 'CMRG', column 'Total' | 8.09 ± 2.78 |  | publication_ambiguity |  | proposed | RESULTS (p. 172) define Total as the average of the three conscious measurements, which TABLE 2 prints as 8.10 ± 2.10, 8.26 ± 3.37, 6.75 ± 1.95 (measurements 1-3, the same six monkeys each time): mean 7.703, not the printed Total 8.09. The abstract and RESULTS repeat the TABLE 3 value. Cannot tell from the paper which table is in error. | Kaufman 2004 carries the TABLE 3 CMRG Total (8.09 mg/100 g/min = 44.9 umol/100g/min); Karbowski 2007 has no CMRgl row for this paper. |
| Nemoto_etal_1994-E005 | CMRgl_mg_100g_min | TABLE 3, p. 173, row 'CMRG', column 'Basal' | 3.13 ± 0.77^a |  | publication_ambiguity |  | proposed | METHODS define Basal as the isoelectric-EEG values; TABLE 2 prints measurements 4-6 as 3.28 ± 1.11, 2.58 ± 0.95, 2.88 ± 0.78: mean 2.913, not the printed Basal 3.13. Cannot tell which table is in error. | Printed value kept in the snapshot, CSV and TSV; detected by the item table_checks and every cell involved re-read on a fresh 500-dpi crop. |
| Nemoto_etal_1994-E006 | CMRgl_mg_100g_min | TABLE 3, p. 173, row 'CMRG', column 'Active' | 5.32 ± 3.54^a |  | publication_error |  | proposed | METHODS define Active = Total - Basal. The same row prints Total 8.09 and Basal 3.13, giving 4.96; the printed Active is 5.32. A mean of per-animal differences equals the difference of the means when n is the same (6), so rounding cannot explain 0.36. | Printed value kept in the snapshot, CSV and TSV; detected by the item table_checks and every cell involved re-read on a fresh 500-dpi crop. |

6 recorded, 6 open (proposed), 0 confirmed, 0 withdrawn.
<!-- errata:end -->
