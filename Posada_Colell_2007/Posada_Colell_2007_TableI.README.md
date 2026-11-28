# Posada_Colell_2007_TableI

Source: https://doi.org/10.1002/ajp.20355 — Table I.

TableI

Frozen source: `Posada_Colell_2007_TableI_snapshot.csv`. The reader preserves printed labels and raw numeric strings, parses numbers without treating blanks as zero, and writes 9 analysis rows plus the public TSV.

One male Xebo; differing session durations. Printed Agonistic percentage 2 and Uncovered total 3751 do not match displayed counts; preserve and flag, not correct. Total row repeats components.

Build: frozen source → analysis CSV → registry-coded public TSV. Numeric source cells, intervals, censoring, missingness and printed species labels are retained.

Source inspection: assistant checked; no human visual sign-off claimed.

Rebuild: `Rscript Posada_Colell_2007/Posada_Colell_2007_TableI.R`.


Build: frozen source → analysis CSV → registry-coded public TSV. Numeric source cells, intervals, censoring, missingness and printed species labels are retained.

Source inspection: assistant checked; no human visual sign-off claimed.

Rebuild: `Rscript Posada_Colell_2007/Posada_Colell_2007_TableI.R`.

## Snapshot layout and transcription correction (2026-11-27)

Restored the printed caption, Phases/Covered/Uncovered/Uncovered with mark header tiers and the separate Lookings section row. Restored printed percent signs and decimal commas. The source row says `Self-direct`, whereas the previous snapshot had `Self-directed`; the snapshot and analysis label now match the source. The R reader parses percentages and decimal commas and selects the nine data rows. The rebuilt numerical values are unchanged; `source_row` and raw source strings now refer to the corrected snapshot. Run `Rscript --vanilla Posada_Colell_2007/Posada_Colell_2007_TableI.R` from repository root. The Agonistic percent and Uncovered total inconsistencies are printed in the PDF and remain documented. Independent human source comparison remains separate.
