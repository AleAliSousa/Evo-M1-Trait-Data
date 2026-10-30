# Frahm_etal_1997_Table1

## Source
Frahm, H. D., Rehkamper, G., & Nevo, E. (1997). Brain structure volumes in Spalax ehrenbergi... J Hirnforsch 38(2),209-222. PMID 9176733. Registry Item **Table 1**; DOI/PMID-coded TSV `PMID%3A9176733_Table1.tsv`.

**brain structure volumes in the mole rat Spalax ehrenbergi vs rat & insectivores.** Volumes in mm³ (body weight g, brain weight mg). Part of the **Stephan/Düsseldorf histological-volume collection**.

## Pipeline
raw → snapshot → R → usable csv/tsv. Files: `Frahm_etal_1997_Table1_snapshot.xlsx` (sheet `Table1`), `Frahm_etal_1997_Table1.R` → `Frahm_etal_1997_Table1.csv` (+ TSV), `reference_tables/Frahm_etal_1997_Table1_definitions.csv`, `comparison/Frahm_1997.csv` (curated source, audited).

Structures: Cerebellum, Diencephalon, Telencephalon, Bulbus olfactorius, Septum, Striatum, Schizo cortex, Hippocampus, Neocortex, Palaeocortex, Amygdala.

## Preparation → `Frahm_etal_1997_Table1.csv`
One row per species. Values are taken from the curated comparison CSV `Frahm_1997.csv` (the audited journal data) and laid out journal-style in the snapshot; the reformat cleans names and types values (already mm³). Verified against the comparison CSV: **0 value mismatches**.

## Note
Snapshot built from the curated `Frahm_1997.csv`; detailed visual fidelity to the printed PDF table layout is a light follow-up (values are the audited source). Used in `__merging_volumes` (Tier 1 (Stephan collection, most-recent-date)).
