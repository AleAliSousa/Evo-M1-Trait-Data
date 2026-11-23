# Pirlot_Jiao_1985_Table1

## Status: reader adapted to manual snapshot layout 2026-10-15, NOT FINISHED (human check and R build pending)

This README replaced a 4-line stub on 2026-10-13. On the same day the snapshot was re-transcribed from the printed table (see "Correction log") and the analysis CSV was regenerated from it; the R script, definitions, taxa file and registry row were not changed in that earlier step. Alexandra de Sousa rearranged the snapshot for visual comparison on 2026-10-14. The 2026-10-15 repair changes only the R reader and this README: the manually arranged snapshot, analysis CSV, public TSV, definitions, taxa file and registry are untouched. No R execution or registry invariant is claimed passed.

## Source → snapshot

Pirlot, P., & Jiao, S. S. (1985). Quantitative morphology of the panda brain in comparison with the brains of the raccoon and the bear. *Journal für Hirnforschung*, 26(1), 17–22. PMID:3989277 (registry `DOI (or Alt)`: `PMID%3A3989277`).

Locus: **Table 1, "Percentile composition of total brain"**, printed p. 19 (PDF page 3 of `pirlot_jiao_1985.pdf`, held unchanged). Layout as printed:
- three species columns: Panda, Raccoon, Bear;
- ten component rows (BO, N, RH, S, D, St, H, M, C, O) plus a Total row;
- each cell holds the percent of total brain, with the absolute volume in mm³ in brackets below it.

Footnote: "In brackets, the absolute volumes in mm³."

Source format: scanned journal pages with an OCR text layer. The OCR is badly garbled (e.g. `Quantitativ e Morphol ogj'`) and unusable for numbers, but the table is legible on the page image.

`Pirlot_Jiao_1985_Table1_snapshot.csv` now has four columns: an unlabelled component column, Panda, Raccoon and Bear. After a blank spacer row, each labelled percentage row is followed by an unlabelled absolute-volume row (mm³). The ten component pairs and the printed Total pair remain in source order. This manual arrangement keeps corresponding values easy to compare beside the PDF; parentheses and some trailing zeros are omitted, and the legacy label `ST` is retained for printed `St`. The snapshot is not rewritten by the R script.

The analysis CSV retains its existing columns: `component, panda_volume_mm3, panda_percent, raccoon_volume_mm3, raccoon_percent, bear_volume_mm3, bear_percent, source`. Species binomials are in `reference_tables/Pirlot_Jiao_1985_Table1_taxa.csv`: *Ailuropoda melanoleuca*, *Procyon lotor* and *Ursus americanus*.

## Snapshot → data readable

Run `Pirlot_Jiao_1985_Table1.R` with `Rscript` or RStudio's Source button in a clean R session. It:
1. reads the four-column snapshot and removes wholly blank spacer rows;
2. requires the expected species headers/order, ten component pairs followed by the Total pair, blank labels on the volume rows, and complete finite numeric cells;
3. reshapes each component's percentage/volume pair into the existing wide analysis columns, excluding only the Total pair;
4. adds `source`;
5. writes `Pirlot_Jiao_1985_Table1.csv`;
6. looks up `Item encoded` by exact `Item name` in the current `__ReadMe.xlsx` and writes its TSV to `__Public/comparative-data/` if the lookup succeeds.

The R script changes layout, not measured values: it neither recomputes percentages nor balances component volumes to the printed totals.

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

**2026-10-14 manual layout; 2026-10-15 reader repair.** Alexandra de Sousa manually rearranged the existing snapshot into the three printed species columns and percentage/volume row pairs, retaining the Total pair, to make side-by-side inspection easier. This layout edit is not recorded as a complete human numeric check. An AI assistant adapted the R reader and this README on 2026-10-15 without changing the snapshot. A Python decimal-based reshape check found all 60 component values identical to the existing analysis CSV; this is a layout/parity check, not R execution or a new transcription from the PDF. The panda component volumes still sum to 211,809.36 mm³ while the snapshot retains the printed total 211,809.35 mm³. The 0.01 difference is preserved, not corrected or normalised.

## QA and online database

Expected analysis rows: **10** components (the printed Total pair remains in the snapshot but is excluded from analysis). Definitions: `reference_tables/Pirlot_Jiao_1985_Table1_definitions.csv`. Its column descriptions (volume mm³ + percent per species) fit the unchanged analysis layout. [TO CHECK: the definitions give the panda's age as ~7 yr; the garbled OCR suggests 8 years.]

Pending:
- human visual check of the 60 re-transcribed cells against p. 19;
- **re-run `Pirlot_Jiao_1985_Table1.R`** in R to refresh the public TSV using the current registry's `Item encoded`; the public TSV was not checked or rewritten during this layout-only repair;
- clean R build/validate. R/Rscript is unavailable in the repair environment, so neither the updated reader nor the canonical audit/build/validate tools were executed.
