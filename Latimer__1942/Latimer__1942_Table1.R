x <- readr::read_csv('frozen/Latimer__1942_Table1_spinal_cord_snapshot.csv', show_col_types=FALSE)
readr::write_csv(x,'analysis/Latimer__1942_Table1_spinal_cord.csv',na='')
readr::write_tsv(x,'public/Latimer__1942_Table1_spinal_cord.tsv',na='')
