# Stephan_etal_1984_Table1

## Source
Stephan, H., Baron, G., & Frahm, H. D. (1984). Comparative size of brains and brain components. (J. Hirnforsch.) Registry Item **Table 1**; DOI/PMID-coded TSV `PMID%3A6481154_Table1.tsv`.

**revised lateral geniculate nucleus (LGN) volumes.** Volumes in mm³ (body weight g, brain weight mg). Part of the **Stephan/Düsseldorf histological-volume collection**.

## Pipeline
raw → snapshot → R → usable csv/tsv. Files: `Stephan_etal_1984_Table1_snapshot.xlsx` (sheet `Table1`), `Stephan_etal_1984_Table1.R` → `Stephan_etal_1984_Table1.csv` (+ TSV), `reference_tables/Stephan_etal_1984_Table1_definitions.csv`, `comparison/Stephan_1984.csv` (curated source, audited).

Structures: Corpus geniculatum laterale.

## Preparation → `Stephan_etal_1984_Table1.csv`
One row per species. Values are taken from the curated comparison CSV `Stephan_1984.csv` (the audited journal data) and laid out journal-style in the snapshot; the reformat cleans names and types values (already mm³). Verified against the comparison CSV: **0 value mismatches**.

## Note
Snapshot built from the curated `Stephan_1984.csv`; detailed visual fidelity to the printed PDF table layout is a light follow-up (values are the audited source). Used in `__merging_volumes` (Tier 1 (Stephan collection, most-recent-date)).
