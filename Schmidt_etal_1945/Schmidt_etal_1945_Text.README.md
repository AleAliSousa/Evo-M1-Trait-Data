# Schmidt_etal_1945_Text

**Item name** `Schmidt_etal_1945_Text` · **Item number** `text (constructed)` · **Item encoded (derived, awaiting registration)** `10.1152%2Fajplegacy.1945.143.1.33_Text`

Schmidt, C. F., Kety, S. S., & Pennes, H. H. (1945). The gaseous metabolism of the brain of the monkey. American Journal of Physiology, 143(1), 33-52. <https://doi.org/10.1152/ajplegacy.1945.143.1.33>

**Item full original title:** values printed in running text (constructed snapshot)

> **Not yet registered.** No `__ReadMe.xlsx` row exists for this item; the public TSV is named by the code the registry formula would build (DOI with `/` percent-encoded, `_`, item locus) — the Mink_etal_1981 convention — and must be renamed if the registry resolves differently. Paste `Schmidt_etal_1945_Text_registry_row.xlsx` to register.

## Source

PDF `schmidt_etal_1945.pdf` (copied from EndNote PDF/1682367563/), journal pp. 33-52 (PDF pages 1-20). Text layer: OCR text layer, unusable for tables (TABLE 4 is printed sideways); values read from 300/500-dpi renders.

3 printed numbers in the DISCUSSION (p. 46): the 4.5 restating TABLE 6's 'Normal' maximum and the mean/maximum CBF (60, 113) of the authors' earlier work (ref. 6, cited). The p. 33 list of literature QO2 values (in vitro and other species, a different unit) is not built.

## Pipeline

```
Source PDF
  -> Schmidt_etal_1945_extract_snapshot.R        verbatim printed block, refuses to overwrite a differing frozen copy
  -> Schmidt_etal_1945_Text_snapshot.csv   FROZEN: 3 printed numbers
  -> Schmidt_etal_1945_Text.R              parse + table checks (no values typed)
  -> Schmidt_etal_1945_Text.csv            3 rows (one per printed value)  ("use this")
  -> __Public/comparative-data/10.1152%2Fajplegacy.1945.143.1.33_Text.tsv
  -> reference_tables/Schmidt_etal_1945_Text_definitions.csv
  -> reference_tables/Schmidt_etal_1945_Text_references.csv   (cited_refs -> citation)
```

Build order: the table items before `Schmidt_etal_1945_Text.R` (its restatement checks read their CSVs).

## Who read the values, when, and how it was checked

Constructed by an AI assistant (Claude) on 2026-11-02: each passage was located via the text layer and then read and quoted from the page image (300/500-dpi). One snapshot row per printed number; columns up to `region_as_printed` are printed text, `curator_*` columns are the curator's classification (value role, cited keys, note) and the only constructed content.

## Table checks

Result of an actual R run (2026-11-02): **1 pass, 0 mismatch, 0 not evaluable.** Tolerance: half a unit in the last printed decimal of every input, propagated, plus half a unit of the printed result (significant-digit units for the scaled human values of Schmidt TABLE 6). 'Not evaluable' marks relations that hold only per animal (mean of products/ratios) or values that cannot be traced.

## Data role

**Proposed: `both`** — the `new`/`restatement`/`bound`/`range_*` rows are the authors' own measurements (primary); the rows with `value_role = cited` (other studies' values, secondary, never to be merged as this paper's data) and the `derived`/`assumed` rows.

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
<!-- errata:end -->
