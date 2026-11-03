# Nilsson_Siesjö_1976_TABLEIII

**Item name** `Nilsson_Siesjö_1976_TABLEIII` · **Item number** `TABLE III` · **Item encoded (derived, awaiting registration)** `10.1111%2Fj.1748-1716.1976.tb10172.x_TABLEIII`

Nilsson, B., & Siesjö, B. K. (1976). A method for determining blood flow and oxygen consumption in the rat brain. Acta Physiologica Scandinavica, 96(1), 72-82. <https://doi.org/10.1111/j.1748-1716.1976.tb10172.x>

**Item full original title:** TABLE III. Mean arterial blood pressure (MABP), Paco2, arterial oxygen content ([To2]a), arteriovenous difference in oxygen content (AVDo2), CBF and CMRo2 in normocapnia, hypocapnia and hypercapnia. The values are means ±S.E.

> **Not yet registered.** No `__ReadMe.xlsx` row exists for this item; the public TSV is named by the code the registry formula would build (DOI with `/` percent-encoded, `_`, item locus) — the Mink_etal_1981 convention — and must be renamed if the registry resolves differently. Paste `Nilsson_Siesjö_1976_TABLEIII_registry_row.xlsx` to register.

## Source

PDF `Nilsson-1976-A method for determi.pdf` (copied from EndNote PDF/3443299141/), journal pp. 72-82 (PDF pages 1-11). Text layer: OCR text layer, garbled for the table (± read as k/&/+); values read from 300/500-dpi renders.

Normocapnia (n = 8), hypocapnia and hypercapnia (n = 4 each). The table prints no units; RESULTS (p. 77) give ml·(100 g)⁻¹·min⁻¹ for CBF and CMRo2. **Kaufman 2004 copied the Normocapnia row.**

## Pipeline

```
Source PDF
  -> Nilsson_Siesjö_1976_extract_snapshot.R        verbatim printed block, refuses to overwrite a differing frozen copy
  -> Nilsson_Siesjö_1976_TABLEIII_snapshot.csv   FROZEN: 5 printed rows
  -> Nilsson_Siesjö_1976_TABLEIII.R              parse + table checks (no values typed)
  -> Nilsson_Siesjö_1976_TABLEIII.csv            18 rows (one per printed value)  ("use this")
  -> __Public/comparative-data/10.1111%2Fj.1748-1716.1976.tb10172.x_TABLEIII.tsv
  -> reference_tables/Nilsson_Siesjö_1976_TABLEIII_definitions.csv
```

## Who read the values, when, and how it was checked

Transcribed **blind** by an AI assistant (Claude) on 2026-11-02 from 300-dpi page renders, with 500-dpi crops (rotated upright for sideways tables) read at 2-5x zoom, before any compilation value was looked at. The OCR text layer was used only to locate passages, never as the source of a value. After the snapshot was frozen, (1) the table's own arithmetic was run and (2) every row was re-read **across** against fresh crops, including every row a check flagged; no transcription error was found and no value was changed. Only then were the Kaufman/Karbowski copies compared (below).

### Structure of the snapshot

* One snapshot row per printed row: caption, header tiers, section rows, data rows and footnotes, in printed order; blank padding under spanning headers.
* A cell printed on two lines is one cell holding a newline; superscript footnote letters are written `^a`; `*`, `**` and parenthesised numbers are kept as printed; subscripts inline (CMRO2).

## Table checks

Result of an actual R run (2026-11-02): **0 pass, 0 mismatch, 3 not evaluable.** Tolerance: half a unit in the last printed decimal of every input, propagated, plus half a unit of the printed result (significant-digit units for the scaled human values of Schmidt TABLE 6). 'Not evaluable' marks relations that hold only per animal (mean of products/ratios) or values that cannot be traced.

## Data role

**Proposed: `primary`** — the values are the authors' own measurements.

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
