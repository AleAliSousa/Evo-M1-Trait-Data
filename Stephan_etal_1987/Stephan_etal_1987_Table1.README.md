# Stephan_etal_1987_Table1

## Source
Stephan, H., Frahm, H. D., & Baron, G. (1987). Comparison of brain structure volumes... amygdaloid complex. (J. Hirnforsch.) Registry Item **Table 1**; DOI/PMID-coded TSV `PMID%3A3693895_Table1.tsv`.

**amygdaloid complex and its subdivisions.** Volumes in mm³ (body weight g, brain weight mg). Part of the **Stephan/Düsseldorf histological-volume collection**.

## Pipeline
raw → snapshots → R → usable csv/tsv. Files: `Stephan_etal_1987_Table1_snapshot.xlsx` (printed Table 1), `Stephan_etal_1987_Table2_snapshot.xlsx` (printed Table 2), `Stephan_etal_1987_Table1.R` → `Stephan_etal_1987_Table1.csv` (+ TSV), `reference_tables/Stephan_etal_1987_species_lookup.csv`, `reference_tables/Stephan_etal_1987_Table1_definitions.csv`.

Structures: Amygdala, Complexus centromedialis, Complexus corticobasolateralis, Nucleus amygdalae basalis pars magnocellularis, Nucleus tractus olfactorius.

## Preparation → `Stephan_etal_1987_Table1.csv`
The printed paper separates 44 non-primates in Table 1 (PDF page 3) from 45 primates in Table 2 (PDF page 4). Each snapshot sketches its own printed table: group headings and species in source order, five volume columns in `AMY, LAM, MCB, MAM, NTO` order, then five index columns. The R reader combines both snapshots, maps printed labels to the established analysis names, and restores the prior analysis order.

Run `Rscript --vanilla Stephan_etal_1987/Stephan_etal_1987_Table1.R` from the repository root. Its 89-row analysis CSV was compared cell for cell with the previous version and is unchanged; the public TSV is unchanged. The Table 2 reader was also run and its 45-row CSV is unchanged.

## Note
The previous Table 1 snapshot merged both printed tables, alphabetized species, and omitted the printed indices. The corrected tables were checked against rendered PDF pages; human visual signoff remains open. Used in `__merging_volumes` (Tier 1, Stephan collection).
