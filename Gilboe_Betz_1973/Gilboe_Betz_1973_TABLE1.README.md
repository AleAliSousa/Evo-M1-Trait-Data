# Gilboe_Betz_1973_TABLE1

**Item name** `Gilboe_Betz_1973_TABLE1` · **Item number** `TABLE 1` · **Item encoded (derived, awaiting registration)** `10.1152%2Fajplegacy.1973.224.3.588_TABLE1`

Gilboe, D. D., & Betz, A. L. (1973). Oxygen uptake in the isolated canine brain. American Journal of Physiology, 224(3), 588-595. <https://doi.org/10.1152/ajplegacy.1973.224.3.588>

**Item full original title:** TABLE 1. Conditions during perfusion of isolated brain

> **Not yet registered.** No `__ReadMe.xlsx` row exists for this item; the public TSV is named by the code the registry formula would build (DOI with `/` percent-encoded, `_`, item locus) — the Mink_etal_1981 convention — and must be renamed if the registry resolves differently. Paste `Gilboe_Betz_1973_TABLE1_registry_row.xlsx` to register.

## Source

PDF `gilboe_betz_1973.pdf` (copied from EndNote PDF/2362825621/), journal pp. 588-595 (PDF pages 1-8). Text layer: OCR text layer, partly garbled (± as zt/&); values read from 300/500-dpi renders.

Perfusion conditions incl. brain weight and blood flow rate, halothane vs sodium pentobarbital groups. Bracketed electrolyte values come from other experiments not in this study (kept as separate rows, bracketed_other_study = TRUE).

## Pipeline

```
Source PDF
  -> Gilboe_Betz_1973_extract_snapshot.R        verbatim printed block, refuses to overwrite a differing frozen copy
  -> Gilboe_Betz_1973_TABLE1_snapshot.csv   FROZEN: 16 printed rows
  -> Gilboe_Betz_1973_TABLE1.R              parse + table checks (no values typed)
  -> Gilboe_Betz_1973_TABLE1.csv            26 rows (one per printed value)  ("use this")
  -> __Public/comparative-data/10.1152%2Fajplegacy.1973.224.3.588_TABLE1.tsv
  -> reference_tables/Gilboe_Betz_1973_TABLE1_definitions.csv
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

* **Preparation:** isolated canine brain (left within the cranium), perfused at 37 C from a disc oxygenator with blood from compatible donors (dextran-diluted, Hct ~25%); adult mongrel dogs 15-20 kg.
* **Anesthesia:** per arm in the `anesthesia` column (curated from METHODS).

## Species

`species_as_published` keeps the paper's naming (the tables print none). Proposed mapping: `reference_tables/Gilboe_Betz_1973_species_key_proposed.csv` (7-column `_keys/General/species_key.csv` schema) — not adopted into `_keys/`.

## Compilation check (done after the snapshot was frozen)

Not in Kaufman 2004 or Karbowski 2007 (no rows in _compilation_rows_for_build.csv). Mink 1981 cites (ref. 32) dog brain O2 3.4 cm3/100 g/min: 3.4 is not printed verbatim; it is TABLE 2 (and abstract) halothane arm 3.39 ± 0.12 ml/100 g per min (SE, 100 determinations on 25 isolated brains) rounded to two figures. The other arm, sodium pentobarbital (2.54 ± 0.06), was not used. Caveats: isolated canine brain perfused from a disc oxygenator (not in vivo), halothane assumed to evaporate in the oxygenator; the discussion also cites another study's pentobarbital-dog value 3.37 ± 0.58 (n = 7, ref. 12) which also rounds to 3.4 but is not this paper's measurement.

Restricted comparison extract: `Evo-M1-Trait-Data-restricted/__energetics_comparison/primary_items_extract/gilboe_1973.csv`.

## Human visual check of snapshot

Not yet recorded. An RA should lay the snapshot beside the page and read a few rows across (including mid-table rows), then record `DDMMYYYY_initials` in the registry's `Human visual check of snapshot` column.

<!-- errata:begin -->
<!-- errata:end -->
