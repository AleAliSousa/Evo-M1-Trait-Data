# comparison/ — QA area (empty for now)

Drop the audited formatted master table here as `Matano_1999.csv` (structure/species rows),
then add the checking script `Matano_etal_1999_Table1_compare_to_Matano_1999_csv.R`
(copy from `../../Matano_etal_1985_a/comparison/` and repoint it).

The script should match the snapshot to `Matano_1999.csv` by species (paper name or
canonical) and confirm every volume column + body weight + n, reporting
`..._comparison_report_from_R.csv` and `..._comparison_mismatches_from_R.csv`.
