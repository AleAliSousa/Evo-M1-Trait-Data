# Reproducible copy from frozen snapshot; no silent corrections
readr::write_csv(readr::read_csv('frozen/Krompecher_Lipak_1966_Table2_snapshot.csv', show_col_types=FALSE), 'analysis/Krompecher_Lipak_1966_Table2.csv', na='')
readr::write_tsv(readr::read_csv('frozen/Krompecher_Lipak_1966_Table2_snapshot.csv', show_col_types=FALSE), 'public/Krompecher_Lipak_1966_Table2.tsv', na='')
