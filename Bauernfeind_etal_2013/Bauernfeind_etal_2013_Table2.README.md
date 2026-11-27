# Bauernfeind et al. 2013 — Table 2 (right insula, per individual)

Bauernfeind AL, et al. (2013) *J Hum Evol* 64(4):263–279.
"A volumetric comparison of the insular cortex and its subregions in primates."

Right-hemisphere counterpart of Table 1 (left). Per-individual, shrinkage-corrected
volumes of the right insula and its cytoarchitectural subdivisions (granular,
dysgranular, agranular, frontoinsular/FI, total) in humans and great apes.

## Pipeline
- **Source.** The article PDF (`bauernfeind_etal_2013.pdf`, printed Table 2, p. 271) and
  its Adobe PDF→Excel export (`bauernfeind_etal_2013.xlsx`).
- **Snapshot.** `Bauernfeind_etal_2013_Table2_snapshot.xlsx` (sheet `Table2`): a faithful
  copy of the printed table — caption, volume-block heading, Species, Individual,
  Granular, Dysgranular, Agranular, FI, Total insula; 15 individuals; volumes in cm³ as printed.
  *Provenance:* values taken from the Adobe export and cross-checked against the paper's own
  Table 3 (right-side species means reproduce to ±rounding). This replaces an earlier
  auto-extraction attempt that did not yield a faithful table.
- **Data readable.** `Bauernfeind_etal_2013_Table2.R` expands the abbreviated species names,
  converts cm³→mm³ (×1000), tags the five insula columns with `_R` (right), and writes
  `Bauernfeind_etal_2013_Table2.csv` plus the DOI-coded TSV in `../__Public/comparative-data/`.
- **Definitions.** `reference_tables/Bauernfeind_etal_2013_Table2_definitions.csv`.

## Use in the merge
`__merging_volumes/volumes_compiled.R` combines Table 1 (left) and Table 2 (right) into
whole-insula both-hemisphere volumes (Phase-4 hemisphere reconciliation: both-sides =
left + right where both hemispheres were measured).

The caption and heading were restored from printed p. 271. Run
`Rscript --vanilla Bauernfeind_etal_2013/Bauernfeind_etal_2013_Table2.R` from
the repository root; the 15-row analysis CSV matched its pre-change version
cell for cell. The item already has an encoded registry row.
