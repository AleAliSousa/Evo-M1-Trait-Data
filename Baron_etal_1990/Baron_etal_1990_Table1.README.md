# Baron_etal_1990_Table1

## Source
Baron, G., Frahm, H. D., & Stephan, H. (1990). Comparison of brain structure volumes... trigeminal complex. Registry Item **Table 1**; DOI/PMID-coded TSV `PMID%3A2358663_Table1.tsv`.

**Trigeminal sensory complex volumes, percentages of OBL, and indices.** Volume is in mm³. Part of the **Stephan/Düsseldorf histological-volume collection**.

## Pipeline
raw → snapshot → R → usable csv/tsv. Files: `Baron_etal_1990_Table1_snapshot.xlsx` (sheet `Table1`), `Baron_etal_1990_Table1.R` → `Baron_etal_1990_Table1.csv` (+ TSV), `reference_tables/Baron_etal_1990_Table1_species_lookup.csv`, `reference_tables/Baron_etal_1990_Table1_definitions.csv`.

Structures: Complexus sensorius trigeminalis.

## Preparation → `Baron_etal_1990_Table1.csv`
The snapshot sketches printed Table 1 on PDF page 4 (printed page 196): two parallel panels, each with species, `Vol.`, `% of OBL`, and `Index`; printed group headings and semiaquatic asterisks remain in place. Volume cells were reoriented from the previous audited snapshot and the percentage and index cells were transcribed from the rendered source. The R reader gathers the two panels, joins printed names to analysis names using the lookup, and restores the established analysis order. The percentage and index fields are retained in the snapshot but are not part of this item's volume-only analysis CSV.

Run `Rscript --vanilla Baron_etal_1990/Baron_etal_1990_Table1.R` from the repository root. The resulting 78-row analysis CSV was compared cell for cell to its previous version and is unchanged; the public TSV is unchanged.

## Note
The previous snapshot alphabetized species and omitted the two printed columns and group structure. The corrected snapshot was checked against the rendered source page; human visual signoff remains open. Used in `__merging_volumes` (Tier 1, Stephan collection).
