Hanson et al. 2018 - Table 3 (caudate oligodendrocyte density and percent glia)
DOI: 10.1002/dneu.22554

Source
  Hanson_etal_2018.pdf, Table 3 (article page 539; PDF page 9).

Snapshot
  Hanson_etal_2018_Table3_snapshot.xlsx
  Full printed table: WS/TD values, t statistics, df, p values, percentage increases and symbols.
  This snapshot requires visual sign-off against the source page before release.

Data readable (USE THIS)
  Hanson_etal_2018_Table3.R -> Hanson_etal_2018_Table3.csv
  Splits printed mean ± SEM values and keeps one row per caudate region x group.
  The uncertainties are SEM: they reproduce the reported Welch t statistics as standard errors.

Online database
  __Public/comparative-data/10.1002%2Fdneu.22554_Table3.tsv

## Snapshot layout audit (2026-11-27)

Compared the workbook with the printed Table 3 on PDF page 9. Restored the blank first-column cells and the separate row labels for t-statistics, p-value, and average percent increase. The R reader now fills the repeated measure label only when constructing its analysis rows. Repaired the workbook's false A1 dimension and dangling drawing references. `Rscript --vanilla Hanson_etal_2018/Hanson_etal_2018_Table3.R` rebuilt the analysis CSV with its previous SHA-256 (`2508a1e8ee9d2ec64449a2d015f5afe0d4571b7903fa1271a405bf42056da763`). This is an assistant source-layout check, not human visual signoff.
