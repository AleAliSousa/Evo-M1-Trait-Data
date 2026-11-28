# Ashwell 2020 supplementary table

## Snapshot layout audit (2026-11-27)

Compared the local publisher DOCX table with the snapshot. The old workbook had
combined the two heading rows and removed three internal blank rows. Rebuilt the
snapshot as the full 164-row, 16-column source grid, including the separate
unit row and blank rows. The R reader starts at source row 4 and removes empty
rows while making the analysis table.

Run from repository root:
`Rscript Ashwell__2020/Ashwell__2020_SupplementaryTable.R`.
The derived CSV retained SHA-256
`94048811ab40b6992435dcb210e4feaec736daa7f0a9364c0388d8c09466fbc8`.
