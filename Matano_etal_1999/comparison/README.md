# comparison/ — QA area

The checking script is in place: `Matano_etal_1999_Table1_compare_to_Matano_1999_csv.R`
(adapted from `../../Matano_etal_1985_a/comparison/`, extended to the 7 measured
structures, portable path — no hard-coded absolute path).

**To run it, add one file:** `Matano_1999.csv` — the formatted master table with the
canonical column headers listed in the script's `csv_col` map
(`Medial_cerebellar_nuclei`, `Interpositus_cerebellar_nuclei`, `Lateral_cerebellar_nuclei`,
`Ventral_pons`, `Inferior_olive_principal`, `Inferior_olive_accessory`,
`Vestibular_complex`, `Body_weight_1999`, `Number_cerebellar_nuclei`, plus `Species`).

It matches the snapshot to `Matano_1999.csv` by species and reports
`..._comparison_report_from_R.csv` + `..._comparison_mismatches_from_R.csv`.
