# Laska_etal_2003_Table1

Source: https://doi.org/10.1023/B:JOEC.0000008009.85523.7a — Table 1.

Table1

Frozen source: `Laska_etal_2003_Table1_snapshot.csv`. The reader preserves printed labels and raw numeric strings, parses numbers without treating blanks as zero, and writes 4 analysis rows plus the public TSV.

Layout edit: restored the printed `Concentration of citric acid (mM) in the mixture` heading
above the 10, 30, and 50 mM columns. The shared R reader skips the first header row and records
physical snapshot rows 3–6. Rebuilt with the command below; all four measurements match the
previous analysis CSV, apart from their updated source-row identifiers.

Sucrose concentration needed for preference for a citric-acid/sucrose mixture over a 50 mM sucrose reference. The >1000 bound is censored, not an exact observation.

Build: frozen source → analysis CSV → registry-coded public TSV. Numeric source cells, intervals, censoring, missingness and printed species labels are retained.

Source inspection: assistant checked; no human visual sign-off claimed.

Rebuild: `Rscript Laska_etal_2003/Laska_etal_2003_Table1.R`.


Build: frozen source → analysis CSV → registry-coded public TSV. Numeric source cells, intervals, censoring, missingness and printed species labels are retained.

Source inspection: assistant checked; no human visual sign-off claimed.

Rebuild: `Rscript Laska_etal_2003/Laska_etal_2003_Table1.R`.
