# Sahlin_etal_1987_TABLEIV

**Item name** `Sahlin_etal_1987_TABLEIV` · **Item number** `TABLE IV` · **Item encoded (derived, awaiting registration)** `10.1016%2F0006-8993(87)90069-2_TABLEIV`

Sahlin, C., Brismar, J., Delgado, T., Owman, C., Salford, L. G., & Svendgaard, N.-A. (1987). Cerebrovascular and metabolic changes during the delayed vasospasm following experimental subarachnoid hemorrhage in baboons, and treatment with a calcium antagonist. Brain Research, 403(2), 313-332. <https://doi.org/10.1016/0006-8993(87)90069-2>

**Item full original title:** TABLE IV — Changes in CBF and CMRO2 one week following experimental SAH, expressed both as actual values and following correction to paCO2 = 40 mm Hg

> **Not yet registered.** No `__ReadMe.xlsx` row exists for this item; the public TSV is named by the code the registry formula would build (DOI with `/` percent-encoded, `_`, item locus) — the Mink_etal_1981 convention — and must be renamed if the registry resolves differently. Paste `Sahlin_etal_1987_TABLEIV_registry_row.xlsx` to register.

## Source

PDF `Sahlin-1987-Cerebrovascular and metabolic chan.pdf` (moved from cereb metabol refs/), journal pp. 313-332 (PDF pages 1-20). Text layer: usable OCR text layer (used only to locate passages; values read from 300/500-dpi renders).

Control (Before SAH) and one week after experimental subarachnoid haemorrhage, actual and paCO2-corrected values. **This is the arm Kaufman 2004 copied (Before SAH, actual).**

## Pipeline

```
Source PDF
  -> Sahlin_etal_1987_extract_snapshot.R        verbatim printed block, refuses to overwrite a differing frozen copy
  -> Sahlin_etal_1987_TABLEIV_snapshot.csv   FROZEN: 7 printed rows
  -> Sahlin_etal_1987_TABLEIV.R              parse + table checks (no values typed)
  -> Sahlin_etal_1987_TABLEIV.csv            8 rows (one per printed value)  ("use this")
  -> __Public/comparative-data/10.1016%2F0006-8993(87)90069-2_TABLEIV.tsv
  -> reference_tables/Sahlin_etal_1987_TABLEIV_definitions.csv
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

* **Preparation:** in vivo, adult baboons 8.9-21.8 kg; CBF by intra-arterial 133Xe clearance (right internal carotid injection, temporo-parietal detector); CMRO2 = CBF x arterial - superior sagittal sinus O2 content difference; experimental SAH = cisternal autologous blood x3 over 4 days, measured one week later.
* **Anesthesia:** per arm in the `anesthesia` column (curated from METHODS).

## Species

`species_as_published` keeps the paper's naming (the tables print none). Proposed mapping: `reference_tables/Sahlin_etal_1987_species_key_proposed.csv` (7-column `_keys/General/species_key.csv` schema) — not adopted into `_keys/`.

## Compilation check (done after the snapshot was frozen)

Kaufman 2004 A14 row 68 (CBF 63.2 ± 4.4, CMRO2 143.75 ± 5.80 umol/100g/min, n = 13, 'N 20') = TABLE IV 'Before SAH' actual (not paCO2-corrected) values 63.2 ± 4.4 and 3.22 ± 0.13 ml/100 g/min x 44.64, exact. The printed ± is S.E.M. but the compilation carries it as SD_raw (SD = SEM x sqrt(13) would be ~15.9 and ~0.47). Kaufman labels it 'Whole Brain (direct measurement)', yet the CBF is an intra-arterial 133Xe clearance over the temporo-parietal region and CMRO2 uses sagittal-sinus blood; anesthesia was N2O plus phencyclidine infusion (thiopental/phencyclidine induction). Karbowski 2007 S1 row 11 CMRO2 0.034 ± 0.006 ml/g/min is NOT the TABLE IV control (3.22 -> 0.032): 0.034 matches the 3.42 printed for 'Before SAH' normotension in TABLE VI (± 0.12, n = 7) and TABLE VII (nimodipine, ± 0.29, n = 5); the ± 0.006 is printed nowhere (it is consistent with TABLE VII SEM 0.29 x sqrt(5) = 0.65 -> 0.0065), so which arm Karbowski took is provisional (TABLE VII nimodipine arm most consistent). Karbowski's total O2 4.658 ml/min is not printed: the paper gives no brain weight (implies ~137 g brain). Merge species mapping 'Papio' -> Papio anubis conflicts with the printed Papio cynocephalus.

Restricted comparison extract: `Evo-M1-Trait-Data-restricted/__energetics_comparison/primary_items_extract/sahlin_1987.csv`.

## Human visual check of snapshot

Not yet recorded. An RA should lay the snapshot beside the page and read a few rows across (including mid-table rows), then record `DDMMYYYY_initials` in the registry's `Human visual check of snapshot` column.

<!-- errata:begin -->
<!-- errata:end -->
