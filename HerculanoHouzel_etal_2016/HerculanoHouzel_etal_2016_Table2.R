x <- readr::read_csv('frozen/HerculanoHouzel_etal_2016_Table2_snapshot.csv', show_col_types=FALSE)
readr::write_csv(x,'analysis/HerculanoHouzel_etal_2016_Table2.csv',na='')
readr::write_tsv(x,'public/HerculanoHouzel_etal_2016_Table2.tsv',na='')
