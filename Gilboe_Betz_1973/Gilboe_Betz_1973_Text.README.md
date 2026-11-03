# Gilboe_Betz_1973_Text

**Item name** `Gilboe_Betz_1973_Text` · **Item number** `text (constructed)` · **Item encoded (derived, awaiting registration)** `10.1152%2Fajplegacy.1973.224.3.588_Text`

Gilboe, D. D., & Betz, A. L. (1973). Oxygen uptake in the isolated canine brain. American Journal of Physiology, 224(3), 588-595. <https://doi.org/10.1152/ajplegacy.1973.224.3.588>

**Item full original title:** values printed in running text (constructed snapshot)

> **Not yet registered.** No `__ReadMe.xlsx` row exists for this item; the public TSV is named by the code the registry formula would build (DOI with `/` percent-encoded, `_`, item locus) — the Mink_etal_1981 convention — and must be renamed if the registry resolves differently. Paste `Gilboe_Betz_1973_Text_registry_row.xlsx` to register.

## Source

PDF `gilboe_betz_1973.pdf` (copied from EndNote PDF/2362825621/), journal pp. 588-595 (PDF pages 1-8). Text layer: OCR text layer, partly garbled (± as zt/&); values read from 300/500-dpi renders.

15 printed numbers: abstract restatements of TABLE 2, seven literature values cited in the DISCUSSION (human, monkey, cat, dog; secondary, with reference keys), and footnote 1's regression slopes and intercepts (own data; intercept unit misprinted, erratum E001). Figure-only values (Figs. 2-4) not digitised.

## Pipeline

```
Source PDF
  -> Gilboe_Betz_1973_extract_snapshot.R        verbatim printed block, refuses to overwrite a differing frozen copy
  -> Gilboe_Betz_1973_Text_snapshot.csv   FROZEN: 15 printed numbers
  -> Gilboe_Betz_1973_Text.R              parse + table checks (no values typed)
  -> Gilboe_Betz_1973_Text.csv            15 rows (one per printed value)  ("use this")
  -> __Public/comparative-data/10.1152%2Fajplegacy.1973.224.3.588_Text.tsv
  -> reference_tables/Gilboe_Betz_1973_Text_definitions.csv
  -> reference_tables/Gilboe_Betz_1973_Text_references.csv   (cited_refs -> citation)
```

Build order: the table items before `Gilboe_Betz_1973_Text.R` (its restatement checks read their CSVs).

## Who read the values, when, and how it was checked

Constructed by an AI assistant (Claude) on 2026-11-02: each passage was located via the text layer and then read and quoted from the page image (300/500-dpi). One snapshot row per printed number; columns up to `region_as_printed` are printed text, `curator_*` columns are the curator's classification (value role, cited keys, note) and the only constructed content.

## Table checks

Result of an actual R run (2026-11-02): **8 pass, 0 mismatch, 0 not evaluable.** Tolerance: half a unit in the last printed decimal of every input, propagated, plus half a unit of the printed result (significant-digit units for the scaled human values of Schmidt TABLE 6). 'Not evaluable' marks relations that hold only per animal (mean of products/ratios) or values that cannot be traced.

Every mismatch is recorded as an erratum below (Gilboe_Betz_1973-E001); the printed values are kept in the snapshot, CSV and TSV.

## Data role

**Proposed: `both`** — the `new`/`restatement`/`bound`/`range_*` rows are the authors' own measurements (primary); the rows with `value_role = cited` (other studies' values, secondary, never to be merged as this paper's data) and the `derived`/`assumed` rows.

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
## Errata

Generated from `reference_tables/Gilboe_Betz_1973_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| Gilboe_Betz_1973-E001 | CMRO2_regression_intercept_ml_100g_min | Footnote 1, p. 593, intercepts of O2 uptake on time (halothane n = 163; sodium pentobarbital n = 245) | 3.70 mg/100 g per min; 2.58 mg/100 g per min |  | publication_ambiguity | 3.70 ml/100 g per min; 2.58 ml/100 g per min | proposed | The footnote prints the intercepts in 'mg/100 g per min' while the slopes in the same sentence are in 'ml/100 g per min²' and the intercepts (3.70, 2.58) sit next to the TABLE 2 O2 uptakes in ml (3.39, 2.54); 3.70 mg O2 would be only ~2.6 ml. The unit is almost certainly ml. | Values kept as printed; the extract converts them as ml with this erratum cited. |

1 recorded, 1 open (proposed), 0 confirmed, 0 withdrawn.
<!-- errata:end -->
