# Frahm_etal_1998_Table1

## Source
Frahm, H. D., Zilles, K., Schleicher, A., & Stephan, H. (1998). The size of the middle temporal area in primates. J Hirnforsch 39(1),45-54. PMID 9672110. Registry Item **Table 1**; DOI/PMID-coded TSV `PMID%3A9672110_Table1.tsv`.

**middle temporal area (MT) volumes.** Volumes in mm³ (body weight g, brain weight mg). Part of the **Stephan/Düsseldorf histological-volume collection**.

## Pipeline
raw → snapshot → R → usable csv/tsv. Files: `Frahm_etal_1998_Table1_snapshot.xlsx` (sheet `Table1`), `Frahm_etal_1998_Table1.R` → `Frahm_etal_1998_Table1.csv` (+ TSV), `reference_tables/Frahm_etal_1998_Table1_species_lookup.csv`, `reference_tables/Frahm_etal_1998_Table1_definitions.csv`.

Structures: Middle temporal visual area, Area striata grey matter, Corpus geniculatum laterale.

## Preparation → `Frahm_etal_1998_Table1.csv`
The snapshot sketches printed Table 1 on PDF page 2 (printed page 46): six columns in source order (`Species`, `BoW`, `BrW`, `AS`, `MT`, `CGL`), its five blocks of species in printed order, blank separators, units, and abbreviation notes. Sample sizes stay in the three printed species labels. The R reader extracts them, joins the source labels to analysis species names, and sorts the output into the established analysis order. No measurement is hardcoded in the reader.

Run `Rscript --vanilla Frahm_etal_1998/Frahm_etal_1998_Table1.R` from the repository root. The rebuilt 27-row analysis CSV was compared cell for cell with the previous version and is unchanged; its public TSV is unchanged.

## Note
The previous snapshot was built from curated data and alphabetized species while moving the weight columns. The corrected layout was checked against the rendered source page; human visual signoff remains open. Used in `__merging_volumes` (Tier 1, Stephan collection).
