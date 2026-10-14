# Pirlot_Jiao_1985_Table1

## Status: snapshot re-transcribed 2026-10-13, NOT FINISHED (human check and public TSV pending)

This README replaced a 4-line stub on 2026-10-13. On the same day the snapshot was re-transcribed from the printed table (see "Correction log") and the analysis CSV was regenerated from it. The R script, definitions, taxa file and registry row were not changed. The public TSV has **not** been updated yet (see Pending). No registry invariant is claimed passed.

## Source → snapshot

Pirlot, P., & Jiao, S. S. (1985). Quantitative morphology of the panda brain in comparison with the brains of the raccoon and the bear. *Journal für Hirnforschung*, 26(1), 17–22. PMID:3989277 (registry `DOI (or Alt)`: `PMID%3A3989277`).

Locus: **Table 1, "Percentile composition of total brain"**, printed p. 19 (PDF page 3 of `pirlot_jiao_1985.pdf`, held unchanged). Layout as printed:
- three species columns: Panda, Raccoon, Bear;
- ten component rows (BO, N, RH, S, D, St, H, M, C, O) plus a Total row;
- each cell holds the percent of total brain, with the absolute volume in mm³ in brackets below it.

Footnote: "In brackets, the absolute volumes in mm³."

Source format: scanned journal pages with an OCR text layer. The OCR is badly garbled (e.g. `Quantitativ e Morphol ogj'`) and unusable for numbers, but the table is legible on the page image.

`Pirlot_Jiao_1985_Table1_snapshot.csv` has 10 rows (components) and 6 value columns: `panda_volume_mm3, panda_percent, raccoon_volume_mm3, raccoon_percent, bear_volume_mm3, bear_percent`. Species binomials are in `reference_tables/Pirlot_Jiao_1985_Table1_taxa.csv`: *Ailuropoda melanoleuca*, *Procyon lotor* and *Ursus americanus*.

## Snapshot → data readable

Run `Pirlot_Jiao_1985_Table1.R` in a clean R session. It:
1. reads the snapshot;
2. stops unless it finds 10 rows;
3. adds `source`;
4. writes `Pirlot_Jiao_1985_Table1.csv`;
5. writes `<Item encoded>.tsv` (registry: `PMID%3A3989277_Table1`) to `__Public/comparative-data/` if the registry lookup succeeds.

The R script does not transform any values.

Method ("Materials, Techniques and Methods", p. 18): **one brain per species**. As far as the garbled text layer shows, the panda was a male of about 8 years obtained in Beijing. [TO CHECK: the sources of the raccoon and bear brains, the section thickness and the staining; the OCR text of the methods is too garbled to extract reliably.] The paper also prints Table 2 (percent of telencephalon) and Table 3 (progression indices). `Kamiya_Pirlot_1988_Table1` reuses the Table 3 indices for panda and bear.

Units: percent of total brain, and mm³ (the bracketed values in print).

Observation level: **one individual per species** (n = 1 each).

Data role: **primary** (the authors' own measurements).

## Correction log

**2026-10-13: snapshot re-transcribed.** The previous snapshot matched only 15 of the 60 printed cells. Percent and volume columns and species columns were mixed up, and its "volume" values were far too small to be mm³ (e.g. panda N 674.6 vs printed 136,435.71). It was replaced with the printed Table 1 values:
- each `<species>_percent` holds the printed upper value;
- each `<species>_volume_mm3` holds the printed bracketed value;
- numbers are kept as printed, including trailing zeros (e.g. `0.30`, `10559.60`).

Column names and row order are unchanged, so the R script and definitions still apply. One label differs from print: the printed component label `St` is kept as `ST` to match the existing definitions codes.

The transcription was done by an AI assistant from a rendered page image (250 dpi), not by a person. It is internally consistent: for each species the percentages sum to 100.00 and the volumes sum to the printed totals (211,809.35 / 35,856.76 / 140,347.58 mm³; panda volumes sum to 211,809.36, a 0.01 rounding difference). `Pirlot_Jiao_1985_Table1.csv` was regenerated with the same transformation as `Pirlot_Jiao_1985_Table1.R` (snapshot + `source` column, R `write.csv` formatting). R itself was not run. The same formatter reproduces the previous CSV byte-for-byte from the previous snapshot.

## QA and online database

Expected analysis rows: **10** components (the printed Total is not stored). Definitions: `reference_tables/Pirlot_Jiao_1985_Table1_definitions.csv`. Its column descriptions (volume mm³ + percent per species) fit the corrected layout. [TO CHECK: the definitions give the panda's age as ~7 yr; the garbled OCR suggests 8 years.]

Pending:
- human visual check of the 60 re-transcribed cells against p. 19;
- **re-run `Pirlot_Jiao_1985_Table1.R`** in R to rewrite the public TSV `PMID%3A3989277_Table1.tsv`, which still holds the old, wrong values;
- clean R build/validate.
