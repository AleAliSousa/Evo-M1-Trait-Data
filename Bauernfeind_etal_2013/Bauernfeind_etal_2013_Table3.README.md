# Bauernfeind et al. 2013 — Table 3 (species averages, left & right insula)

Bauernfeind AL, et al. (2013) *J Hum Evol* 64(4):263–279.

Species-mean summary (mean ± SD) of left and right insular subdivision volumes in humans
and great apes — the species-level summary of the per-individual Tables 1 (left) and 2 (right).

## Pipeline
- **Source.** The article PDF and its Adobe PDF→Excel export (`bauernfeind_etal_2013.xlsx`).
- **Snapshot.** `Bauernfeind_etal_2013_Table3_snapshot.xlsx` (sheet `Table3`): faithful copy of
  the printed table — two side-by-side blocks (left | right), each with `n` and the five
  subdivisions (Granular, Dysgranular, Agranular, FI, Total) printed as `mean ± SD`
  (single value where n = 1); 6 species; volumes in cm³ as printed.
- **Data readable.** `Bauernfeind_etal_2013_Table3.R` reshapes to tidy long form
  (Species × hemisphere × subdivision), splitting `mean ± SD` into numeric `mean_mm3` /
  `sd_mm3` and converting cm³→mm³ (×1000) → `Bauernfeind_etal_2013_Table3.csv`.
- **Definitions.** `reference_tables/Bauernfeind_etal_2013_Table3_definitions.csv`.

## Note
Table 3 is kept for traceability only; it is **not** re-merged. The volume merge recomputes
species means from the per-individual Tables 1 and 2, so Table 3 serves as an independent
cross-check (its right-side means equal the means of the Table 2 individuals).
