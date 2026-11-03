# Nilsson_Siesjö_1976_Text

**Item name** `Nilsson_Siesjö_1976_Text` · **Item number** `text (constructed)` · **Item encoded (derived, awaiting registration)** `10.1111%2Fj.1748-1716.1976.tb10172.x_Text`

Nilsson, B., & Siesjö, B. K. (1976). A method for determining blood flow and oxygen consumption in the rat brain. Acta Physiologica Scandinavica, 96(1), 72-82. <https://doi.org/10.1111/j.1748-1716.1976.tb10172.x>

**Item full original title:** values printed in running text (constructed snapshot)

> **Not yet registered.** No `__ReadMe.xlsx` row exists for this item; the public TSV is named by the code the registry formula would build (DOI with `/` percent-encoded, `_`, item locus) — the Mink_etal_1981 convention — and must be renamed if the registry resolves differently. Paste `Nilsson_Siesjö_1976_Text_registry_row.xlsx` to register.

## Source

PDF `Nilsson-1976-A method for determi.pdf` (copied from EndNote PDF/3443299141/), journal pp. 72-82 (PDF pages 1-11). Text layer: OCR text layer, garbled for the table (± read as k/&/+); values read from 300/500-dpi renders.

15 printed numbers: abstract/results restatements of TABLE III (incl. the 7.6 that Mink 1981 cites), two 14C-ethanol whole-hemisphere CBF determinations printed only in the text (79 and 80), the p. 79 worked example, cited human/dog/rat literature values, and an extrapolated human-cortex CMRo2.

## Pipeline

```
Source PDF
  -> Nilsson_Siesjö_1976_extract_snapshot.R        verbatim printed block, refuses to overwrite a differing frozen copy
  -> Nilsson_Siesjö_1976_Text_snapshot.csv   FROZEN: 15 printed numbers
  -> Nilsson_Siesjö_1976_Text.R              parse + table checks (no values typed)
  -> Nilsson_Siesjö_1976_Text.csv            15 rows (one per printed value)  ("use this")
  -> __Public/comparative-data/10.1111%2Fj.1748-1716.1976.tb10172.x_Text.tsv
  -> reference_tables/Nilsson_Siesjö_1976_Text_definitions.csv
  -> reference_tables/Nilsson_Siesjö_1976_Text_references.csv   (cited_refs -> citation)
```

Build order: the table items before `Nilsson_Siesjö_1976_Text.R` (its restatement checks read their CSVs).

## Who read the values, when, and how it was checked

Constructed by an AI assistant (Claude) on 2026-11-02: each passage was located via the text layer and then read and quoted from the page image (300/500-dpi). One snapshot row per printed number; columns up to `region_as_printed` are printed text, `curator_*` columns are the curator's classification (value role, cited keys, note) and the only constructed content.

## Table checks

Result of an actual R run (2026-11-02): **6 pass, 0 mismatch, 0 not evaluable.** Tolerance: half a unit in the last printed decimal of every input, propagated, plus half a unit of the printed result (significant-digit units for the scaled human values of Schmidt TABLE 6). 'Not evaluable' marks relations that hold only per animal (mean of products/ratios) or values that cannot be traced.

## Data role

**Proposed: `both`** — the `new`/`restatement`/`bound`/`range_*` rows are the authors' own measurements (primary); the rows with `value_role = cited` (other studies' values, secondary, never to be merged as this paper's data) and the `derived`/`assumed` rows.

## Anesthesia and preparation

* **Preparation:** in vivo, male Wistar rats; CBF by 133Xenon Kety-Schmidt desaturation with retroglenoid-vein sampling (contralateral sinus compressed); CMRO2 = CBF x AVDO2.
* **Anesthesia:** per arm in the `anesthesia` column (curated from METHODS).

## Species

`species_as_published` keeps the paper's naming (the tables print none). Proposed mapping: `reference_tables/Nilsson_Siesjö_1976_species_key_proposed.csv` (7-column `_keys/General/species_key.csv` schema) — not adopted into `_keys/`.

## Compilation check (done after the snapshot was frozen)

Kaufman 2004 A14 row 167 CBF 79.5 ± 2.4 and CMRO2 338.39 ± 8.03 umol/100g/min (n = 8, 'N 20') = TABLE III Normocapnia 79.5 ± 2.4 and 7.58 ± 0.18 (x 44.643; the merge uses 44.64 -> 338.37), exact; dispersion is S.E. but carried as SD_raw. Anesthesia label matches (70% N2O after halothane induction, curarized, ventilated). The hypocapnia and hypercapnia arms are not compiled. Mink 1981's 7.6 cm3/100g/min = the abstract's rounded 7.6 ± 0.2 (TABLE III 7.58). No compilation error in the values.

Restricted comparison extract: `Evo-M1-Trait-Data-restricted/__energetics_comparison/primary_items_extract/nilsson_1976.csv`.

## Human visual check of snapshot

Not yet recorded. An RA should lay the snapshot beside the page and read a few rows across (including mid-table rows), then record `DDMMYYYY_initials` in the registry's `Human visual check of snapshot` column.

<!-- errata:begin -->
<!-- errata:end -->
