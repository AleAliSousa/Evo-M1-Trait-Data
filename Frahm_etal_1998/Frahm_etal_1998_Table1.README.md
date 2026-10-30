# Frahm_etal_1998_Table1

## Source
Frahm, H. D., Zilles, K., Schleicher, A., & Stephan, H. (1998). The size of the middle temporal area in primates. J Hirnforsch 39(1),45-54. PMID 9672110. Registry Item **Table 1**; DOI/PMID-coded TSV `PMID%3A9672110_Table1.tsv`.

**middle temporal area (MT) volumes.** Volumes in mm³ (body weight g, brain weight mg). Part of the **Stephan/Düsseldorf histological-volume collection**.

## Pipeline
raw → snapshot → R → usable csv/tsv. Files: `Frahm_etal_1998_Table1_snapshot.xlsx` (sheet `Table1`), `Frahm_etal_1998_Table1.R` → `Frahm_etal_1998_Table1.csv` (+ TSV), `reference_tables/Frahm_etal_1998_Table1_definitions.csv`, `comparison/Frahm_1998.csv` (curated source, audited).

Structures: Middle temporal visual area, Area striata grey matter, Corpus geniculatum laterale.

## Preparation → `Frahm_etal_1998_Table1.csv`
One row per species. Values are taken from the curated comparison CSV `Frahm_1998.csv` (the audited journal data) and laid out journal-style in the snapshot; the reformat cleans names and types values (already mm³). Verified against the comparison CSV: **0 value mismatches**.

## Note
Snapshot built from the curated `Frahm_1998.csv`; detailed visual fidelity to the printed PDF table layout is a light follow-up (values are the audited source). Used in `__merging_volumes` (Tier 1 (Stephan collection, most-recent-date)).
