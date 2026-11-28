Hanson et al. 2018 - Table 2 (striatal neuron/glia density, ratio, soma area)
DOI: 10.1002/dneu.22554

Source
  Hanson_etal_2018.pdf, Table 2 (article page 536; PDF page 6).

Snapshot
  Hanson_etal_2018_Table2_snapshot.xlsx
  Full printed table: WS/TD values, percentage changes, t statistics, df, p values, signs and symbols.
  This snapshot requires visual sign-off against the source page before release.

Data readable (USE THIS)
  Hanson_etal_2018_Table2.R -> Hanson_etal_2018_Table2.csv
  Splits printed mean ± SEM values into numeric mean/SEM columns and keeps one row per region x group.
  The uncertainties are SEM: they reproduce the reported Welch t statistics as standard errors.

Online database
  __Public/comparative-data/10.1002%2Fdneu.22554_Table2.tsv

## Snapshot layout audit (2026-11-27)

Compared the workbook with printed Table 2 on PDF page 6. Restored blank first-column cells for TD and df rows, moved the printed percent-change/t-statistics/p-value labels into their first-column positions, and blanked the two unprinted first header cells. The R reader fills the TD measure label for analysis. `Rscript --vanilla Hanson_etal_2018/Hanson_etal_2018_Table2.R` rebuilt the eight-row CSV with unchanged SHA-256 `71c32a2c8739a1af9ef81b0a093ecd934a26ed6157ef68e1d8f9bd67fcb7b47b`. Human source signoff remains separate.
