# Geiger_Magnes_1947_Text

**Item name** `Geiger_Magnes_1947_Text` · **Item number** `text (constructed)` · **Item encoded (derived, awaiting registration)** `10.1152%2Fajplegacy.1947.149.3.517_Text`

Geiger, A., & Magnes, J. (1947). The isolation of the cerebral circulation and the perfusion of the brain in the living cat. American Journal of Physiology, 149(3), 517-537. <https://doi.org/10.1152/ajplegacy.1947.149.3.517>

**Item full original title:** values printed in running text (constructed snapshot)

> **Not yet registered.** No `__ReadMe.xlsx` row exists for this item; the public TSV is named by the code the registry formula would build (DOI with `/` percent-encoded, `_`, item locus) — the Mink_etal_1981 convention — and must be renamed if the registry resolves differently. Paste `Geiger_Magnes_1947_Text_registry_row.xlsx` to register.

## Source

PDF `geiger_magnes_1947.pdf` (copied from EndNote PDF/3219674176/), journal pp. 517-537 (PDF pages 1-21). Text layer: OCR text layer, garbled (Table 1 printed sideways, low-contrast); values read from 300/500-dpi renders.

19 printed numbers: perfusion flow bounds, group O2 ranges (incl. the 4-5 that underlies Mink 1981's 4.5), the amytal experiments of figures 10-11, the cited Schmidt et al. 1945 flow range and the Summary restatements. Flow thresholds (80-90 ml) stated as conditions are not built. Figure-only values (Figs. 8-14) are not digitised: the tables and text carry every value the audit needs.

## Pipeline

```
Source PDF
  -> Geiger_Magnes_1947_extract_snapshot.R        verbatim printed block, refuses to overwrite a differing frozen copy
  -> Geiger_Magnes_1947_Text_snapshot.csv   FROZEN: 19 printed numbers
  -> Geiger_Magnes_1947_Text.R              parse + table checks (no values typed)
  -> Geiger_Magnes_1947_Text.csv            19 rows (one per printed value)  ("use this")
  -> __Public/comparative-data/10.1152%2Fajplegacy.1947.149.3.517_Text.tsv
  -> reference_tables/Geiger_Magnes_1947_Text_definitions.csv
  -> reference_tables/Geiger_Magnes_1947_Text_references.csv   (cited_refs -> citation)
```

Build order: the table items before `Geiger_Magnes_1947_Text.R` (its restatement checks read their CSVs).

## Who read the values, when, and how it was checked

Constructed by an AI assistant (Claude) on 2026-11-02: each passage was located via the text layer and then read and quoted from the page image (300/500-dpi). One snapshot row per printed number; columns up to `region_as_printed` are printed text, `curator_*` columns are the curator's classification (value role, cited keys, note) and the only constructed content.

## Table checks

No exact relation: the text gives ranges and single-experiment values that no table prints exactly.

## Data role

**Proposed: `both`** — the `new`/`restatement`/`bound`/`range_*` rows are the authors' own measurements (primary); the rows with `value_role = cited` (other studies' values, secondary, never to be merged as this paper's data) and the `derived`/`assumed` rows.

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
