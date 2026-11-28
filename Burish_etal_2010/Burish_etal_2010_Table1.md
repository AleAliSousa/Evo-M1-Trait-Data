Source
1. Automatically read pdf into R from figshare link embedded in publication 
"https://ndownloader.figstatic.com/files/8705821"

--> Snapshot 
Fixed formatting

"Burish_etal_2010_SupplementaryTable1_snapshot.csv"

--> Data readable
Make data readable

--> Species update 
correct species name typo

Burish_etal_2010_SupplementaryTable1_snapshot.csv <-- USE THIS

--> Online database

Added TSV copy named with DOI to https://github.com/r03ert0/comparative-data

10.1159%2F000319019_SupplementaryTable1.tsv <-- ONLINE COPY

## Table 1 layout audit (2026-11-27)

Compared Table 1 on page 3 of the local article PDF. The snapshot already
retained its 15 printed columns, stacked mean/SD rows, and header line breaks;
the omitted printed caption has now been restored above the grid. The
snapshot extractor writes the caption and the R reader skips it. Run
`Rscript Burish_etal_2010/Burish_etal_2010_Table1_snapshot.R` followed by
`Rscript Burish_etal_2010/Burish_etal_2010_Table1.R` from the repository root.
The nine-row analysis CSV remained cell-identical. Independent human visual
signoff is separate.

