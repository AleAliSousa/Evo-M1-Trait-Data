# Chapelain & Hogervorst 2009 Table 6

Source: `Chapelain_Hogervorst_2009.pdf`, Data with first 50 frequency data points, printed p. 23 (PDF p. 9).
The frozen snapshot has the 29 named bonobos in source order and the printed
Total/mean line. Run `Rscript Chapelain_Hogervorst_2009/Chapelain_Hogervorst_2009_Table6_snapshot.R`
to verify the PDF extraction, then `Rscript Chapelain_Hogervorst_2009/Chapelain_Hogervorst_2009_Table6.R`
to rebuild the analysis CSV. The source page was visually inspected on
2026-11-26; no human visual signoff is claimed.

Each row retains right, left and total responses, printed HI and ABSHI,
binomial p, and handedness category. Right + left matches the printed total
for all 29 individuals; column sums match the printed Total/mean counts;
printed HI agrees with (right − left)/total within 0.001 rounding. The
`response_series` is first approximately 50 frequency responses. Tables 4–6 describe the **same 29 bonobos**
and are alternative views of one experiment; do not pool their rows as 87
independent specimens.

Table 6 prints a binomial p value of `1.112` for Mwindu. This is outside
the possible probability range and is retained as a source fault; exclude or
resolve that p value downstream, without altering the source table.

Main-registry registration and public TSV generation remain pending.
The proposed row is `Chapelain_Hogervorst_2009_Table6_registry_row.xlsx`.
