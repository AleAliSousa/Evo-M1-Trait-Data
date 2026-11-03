# Nemoto_etal_1994_TABLE2

**Item name** `Nemoto_etal_1994_TABLE2` · **Item number** `TABLE 2` · **Item encoded (derived, awaiting registration)** `10.1097%2F00008506-199407000-00004_TABLE2`

Nemoto, E. M., Yao, L., Yonas, H., & Darby, J. (1994). Compartmentation of whole brain blood flow and oxygen and glucose metabolism in monkeys. Journal of Neurosurgical Anesthesiology, 6(3), 170-174. <https://doi.org/10.1097/00008506-199407000-00004>

**Item full original title:** TABLE 2. Cerebral blood flow (CBF), cerebral metabolic rate of oxygen (CMRO2) and of glucose (CMRG) in six monkeys during the unanesthetized and thiopental-anesthetized states (isoelectric EEG) (values are X̄ ± SD)

> **Not yet registered.** No `__ReadMe.xlsx` row exists for this item; the public TSV is named by the code the registry formula would build (DOI with `/` percent-encoded, `_`, item locus) — the Mink_etal_1981 convention — and must be renamed if the registry resolves differently. Paste `Nemoto_etal_1994_TABLE2_registry_row.xlsx` to register.

## Source

PDF `Nemoto-1994-Compartmentation of.pdf` (copied from EndNote PDF/1539942437/), journal pp. 170-174 (PDF pages 1-5). Text layer: NO text layer (photographed pages); every value read from 300-dpi renders.

Three sequential whole-brain measurements in six conscious monkeys, then three under thiopental to isoelectric EEG (same animals). No text layer: every value read from the page image.

## Pipeline

```
Source PDF
  -> Nemoto_etal_1994_extract_snapshot.R        verbatim printed block, refuses to overwrite a differing frozen copy
  -> Nemoto_etal_1994_TABLE2_snapshot.csv   FROZEN: 11 printed rows
  -> Nemoto_etal_1994_TABLE2.R              parse + table checks (no values typed)
  -> Nemoto_etal_1994_TABLE2.csv            18 rows (one per printed value)  ("use this")
  -> __Public/comparative-data/10.1097%2F00008506-199407000-00004_TABLE2.tsv
  -> reference_tables/Nemoto_etal_1994_TABLE2_definitions.csv
```

## Who read the values, when, and how it was checked

Transcribed **blind** by an AI assistant (Claude) on 2026-11-02 from 300-dpi page renders, with 500-dpi crops (rotated upright for sideways tables) read at 2-5x zoom, before any compilation value was looked at. The OCR text layer was used only to locate passages, never as the source of a value. After the snapshot was frozen, (1) the table's own arithmetic was run and (2) every row was re-read **across** against fresh crops, including every row a check flagged; no transcription error was found and no value was changed. Only then were the Kaufman/Karbowski copies compared (below).

### Structure of the snapshot

* One snapshot row per printed row: caption, header tiers, section rows, data rows and footnotes, in printed order; blank padding under spanning headers.
* A cell printed on two lines is one cell holding a newline; superscript footnote letters are written `^a`; `*`, `**` and parenthesised numbers are kept as printed; subscripts inline (CMRO2).

## Table checks

This item prints no arithmetic relation of its own (no totals, sums or derived columns); no check is possible and none was invented.

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
<!-- errata:end -->
