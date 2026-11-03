# Geiger_Magnes_1947_TABLE1

**Item name** `Geiger_Magnes_1947_TABLE1` · **Item number** `TABLE 1` · **Item encoded (derived, awaiting registration)** `10.1152%2Fajplegacy.1947.149.3.517_TABLE1`

Geiger, A., & Magnes, J. (1947). The isolation of the cerebral circulation and the perfusion of the brain in the living cat. American Journal of Physiology, 149(3), 517-537. <https://doi.org/10.1152/ajplegacy.1947.149.3.517>

**Item full original title:** (no "TABLE 1" heading printed; the text calls it "table 1") The Oxygen consumption of the perfused brain (ml. O2 consumed per 100 grams brains per min.). Division into 3 groups according to functional state of brain

> **Not yet registered.** No `__ReadMe.xlsx` row exists for this item; the public TSV is named by the code the registry formula would build (DOI with `/` percent-encoded, `_`, item locus) — the Mink_etal_1981 convention — and must be renamed if the registry resolves differently. Paste `Geiger_Magnes_1947_TABLE1_registry_row.xlsx` to register.

## Source

PDF `geiger_magnes_1947.pdf` (copied from EndNote PDF/3219674176/), journal pp. 517-537 (PDF pages 1-21). Text layer: OCR text layer, garbled (Table 1 printed sideways, low-contrast); values read from 300/500-dpi renders.

O2 consumption per 15-min period of perfusion, three groups by functional state of the brain (A excellent activity, B reflexes only, C weak/no reflexes). Printed sideways; no 'TABLE 1' heading on the page. Mink 1981's cat value 4.5 is the midpoint of the group-A range the text prints (4-5).

## Pipeline

```
Source PDF
  -> Geiger_Magnes_1947_extract_snapshot.R        verbatim printed block, refuses to overwrite a differing frozen copy
  -> Geiger_Magnes_1947_TABLE1_snapshot.csv   FROZEN: 28 printed rows
  -> Geiger_Magnes_1947_TABLE1.R              parse + table checks (no values typed)
  -> Geiger_Magnes_1947_TABLE1.csv            127 rows (one per printed value)  ("use this")
  -> __Public/comparative-data/10.1152%2Fajplegacy.1947.149.3.517_TABLE1.tsv
  -> reference_tables/Geiger_Magnes_1947_TABLE1_definitions.csv
```

## Who read the values, when, and how it was checked

Transcribed **blind** by an AI assistant (Claude) on 2026-11-02 from 300-dpi page renders, with 500-dpi crops (rotated upright for sideways tables) read at 2-5x zoom, before any compilation value was looked at. The OCR text layer was used only to locate passages, never as the source of a value. After the snapshot was frozen, (1) the table's own arithmetic was run and (2) every row was re-read **across** against fresh crops, including every row a check flagged; no transcription error was found and no value was changed. Only then were the Kaufman/Karbowski copies compared (below).

### Structure of the snapshot

* One snapshot row per printed row: caption, header tiers, section rows, data rows and footnotes, in printed order; blank padding under spanning headers.
* A cell printed on two lines is one cell holding a newline; superscript footnote letters are written `^a`; `*`, `**` and parenthesised numbers are kept as printed; subscripts inline (CMRO2).

## Table checks

Result of an actual R run (2026-11-02): **15 pass, 0 mismatch, 0 not evaluable.** Tolerance: half a unit in the last printed decimal of every input, propagated, plus half a unit of the printed result (significant-digit units for the scaled human values of Schmidt TABLE 6). 'Not evaluable' marks relations that hold only per animal (mean of products/ratios) or values that cannot be traced.

## Data role

**Proposed: `primary`** — the values are the authors' own measurements.

## Anesthesia and preparation

* **Preparation:** perfused brain in the living cat: cerebral circulation isolated and perfused (pump, oxygenator) with defibrinated heparinized ox blood; brain in situ, animal alive.
* **Anesthesia:** per arm in the `anesthesia` column (curated from METHODS).

## Species

`species_as_published` keeps the paper's naming (the tables print none). Proposed mapping: `reference_tables/Geiger_Magnes_1947_species_key_proposed.csv` (7-column `_keys/General/species_key.csv` schema) — not adopted into `_keys/`.

## Compilation check (done after the snapshot was frozen)

Not in Kaufman 2004 or Karbowski 2007 (no rows in _compilation_rows_for_build.csv). Mink 1981 cites (ref. 30) cat brain O2 4.5 cm3/100 g/min: 4.5 is NOT printed as a summary value in the paper. TABLE 1 (unlabelled, called 'table 1' in the text; perfused brain of living cats, ether + Dial) gives group A (excellent cerebral activity) averages 4.95, 4.44, 4.36, 4.28, 4.01 ml/100 g/min over 0-75 min; the text (p. 526) and Summary 6 (p. 535) give group A as 'between 4 to 5' / '4-5 ml. per 100 grams per min.'. Mink's 4.5 is the midpoint of that printed range (single cells reading 4.50 occur only in experiments 23-5 at 30-45 min and 15-7 at 15-30 min). The preparation is a perfused (isolated-circulation) brain, not in vivo.

Restricted comparison extract: `Evo-M1-Trait-Data-restricted/__energetics_comparison/primary_items_extract/geiger_1947.csv`.

## Human visual check of snapshot

Not yet recorded. An RA should lay the snapshot beside the page and read a few rows across (including mid-table rows), then record `DDMMYYYY_initials` in the registry's `Human visual check of snapshot` column.

<!-- errata:begin -->
<!-- errata:end -->
