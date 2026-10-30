# Stephan_etal_1987_Table1

## Source
Stephan, H., Frahm, H. D., & Baron, G. (1987). Comparison of brain structure volumes... amygdaloid complex. (J. Hirnforsch.) Registry Item **Table 1**; DOI/PMID-coded TSV `PMID%3A3693895_Table1.tsv`.

**amygdaloid complex and its subdivisions.** Volumes in mm³ (body weight g, brain weight mg). Part of the **Stephan/Düsseldorf histological-volume collection**.

## Pipeline
raw → snapshot → R → usable csv/tsv. Files: `Stephan_etal_1987_Table1_snapshot.xlsx` (sheet `Table1`), `Stephan_etal_1987_Table1.R` → `Stephan_etal_1987_Table1.csv` (+ TSV), `reference_tables/Stephan_etal_1987_Table1_definitions.csv`, `comparison/Stephan1987_AMY_vs_Barger2007_AC.csv` (curated source, audited).

Structures: Amygdala, Complexus centromedialis, Complexus corticobasolateralis, Nucleus amygdalae basalis pars magnocellularis, Nucleus tractus olfactorius.

## Preparation → `Stephan_etal_1987_Table1.csv`
One row per species. Values are taken from the curated comparison CSV `Stephan1987_AMY_vs_Barger2007_AC.csv` (the audited journal data) and laid out journal-style in the snapshot; the reformat cleans names and types values (already mm³). Verified against the comparison CSV: **0 value mismatches**.

## Note
Snapshot built from the curated `Stephan1987_AMY_vs_Barger2007_AC.csv`; detailed visual fidelity to the printed PDF table layout is a light follow-up (values are the audited source). Used in `__merging_volumes` (Tier 1 (Stephan collection, most-recent-date)).
