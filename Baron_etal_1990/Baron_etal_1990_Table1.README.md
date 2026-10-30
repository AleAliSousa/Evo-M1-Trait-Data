# Baron_etal_1990_Table1

## Source
Baron, G., Frahm, H. D., & Stephan, H. (1990). Comparison of brain structure volumes... trigeminal complex. Registry Item **Table 1**; DOI/PMID-coded TSV `PMID%3A2358663_Table1.tsv`.

**trigeminal sensory complex volumes.** Volumes in mm³ (body weight g, brain weight mg). Part of the **Stephan/Düsseldorf histological-volume collection**.

## Pipeline
raw → snapshot → R → usable csv/tsv. Files: `Baron_etal_1990_Table1_snapshot.xlsx` (sheet `Table1`), `Baron_etal_1990_Table1.R` → `Baron_etal_1990_Table1.csv` (+ TSV), `reference_tables/Baron_etal_1990_Table1_definitions.csv`, `comparison/Baron_1990.csv` (curated source, audited).

Structures: Complexus sensorius trigeminalis.

## Preparation → `Baron_etal_1990_Table1.csv`
One row per species. Values are taken from the curated comparison CSV `Baron_1990.csv` (the audited journal data) and laid out journal-style in the snapshot; the reformat cleans names and types values (already mm³). Verified against the comparison CSV: **0 value mismatches**.

## Note
Snapshot built from the curated `Baron_1990.csv`; detailed visual fidelity to the printed PDF table layout is a light follow-up (values are the audited source). Used in `__merging_volumes` (Tier 1 (Stephan collection, most-recent-date)).
