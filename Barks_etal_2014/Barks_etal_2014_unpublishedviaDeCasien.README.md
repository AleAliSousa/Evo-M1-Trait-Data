# Barks et al. 2014 individual regional volumes via DeCasien and Higham 2019

## Snapshot layout audit and correction (2026-11-27)

The former 33-row snapshot was a joined, renamed, selected-column analysis table. It did not preserve the source sheet's spatial layout. `Barks_etal_2014_unpublishedviaDeCasien_snapshot.xlsx` is now a byte-identical copy of the locally stored publisher MOESM3 workbook (`DeCasien_Higham_2019/41559_2019_969_MOESM3_ESM.xlsx`; SHA-256 `72f5c73d0ed17b1983276744bf97ca39af51aeeb01cc35558a4a4e0bb749ac64`). The relevant sheet, `Brain Region Data (mm3)`, has its original 38 columns and 400 rows. The Barks gorilla records are the 33 rows attributed to reference 65.

`Barks_etal_2014_unpublishedviaDeCasien.R` now selects those rows and joins `reference_tables/Barks_etal_2014_unpublishedviaDeCasien_specimen_map.csv` to add the Barks Table 1 specimen numbers and normalized species labels. Run `Rscript Barks_etal_2014/Barks_etal_2014_unpublishedviaDeCasien.R` from the repository root. The output remains 33 rows; all fields match the former analysis CSV semantically, with only insignificant floating-point serialization differences from reading the publisher workbook directly. This snapshot layout audit does not constitute independent human source signoff.
