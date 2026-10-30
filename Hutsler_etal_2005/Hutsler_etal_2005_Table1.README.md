# Hutsler et al. 2005 — Table 1

Exact capture of the 14 species, 32 specimens and tissue sources printed in Table 1. The clean table
adds project accepted names through paper-scoped `Hutsler2005` mappings. Until those mappings are
approved centrally, the script falls back to `PROPOSED_species_key_rows.csv`.

`regional_motor_premotor_sensory_subset` is true for all species except mouse. It identifies
membership only; it does not imply that species-level regional measurements were printed.

Pipeline: PDF p.73 → `Hutsler_etal_2005_Table1_snapshot.csv` →
`Hutsler_etal_2005_Table1.R` → `Hutsler_etal_2005_Table1.csv`.
