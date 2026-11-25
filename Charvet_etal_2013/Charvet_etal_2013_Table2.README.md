# Charvet et al. — Table 2: unilateral isocortical neuron estimates

The six Table 2 neuron coordinates for Figure 8 are included in `internal_checks/Charvet_etal_2013_Figure8_source_points.csv`, alongside 21 table-based comparison points. Their volume coordinates remain blank because Table 2 does not report them; the audit and replot command are in `internal_checks/Charvet_etal_2013_Figure8_source_points.README.md`.

Charvet, C. J., Cahalane, D. J., & Finlay, B. L. *Systematic, cross-cortex variation in neuron numbers in rodents and primates*. DOI [10.1093/cercor/bht214](https://doi.org/10.1093/cercor/bht214). Online publication was 2013; the final journal issue was *Cerebral Cortex* 25(1):147–160 (2015). Source: `Charvet-2013-Systematic, Cross-Co.pdf`, PDF page 4, printed Table 2.

An AI assistant transcribed the three printed count rows and six species columns on 2026-11-24, comparing the frozen `Charvet_etal_2013_Table2_snapshot.csv` with the rendered PDF page. The snapshot preserves the source order, layer labels and `10^6 neurons` note. Run `Rscript --vanilla Charvet_etal_2013/Charvet_etal_2013_Table2.R` from the repository root. The reader uses only this snapshot and writes the six-row analysis CSV and DOI-coded public TSV. Counts are multiplied by one million to represent neurons rather than millions of neurons. `Species` stays identical to the printed common-name label. Scientific identifications given in the paper's Methods are recorded separately in `reference_tables/Charvet_etal_2013_species_identifications.csv`.

## Table checks

The reader confirms that the layers II–IV and V–VI estimates sum to the total for all six species at the source precision. The R run passed. These are unilateral **isocortex** estimates, directly relevant to this paper's Figure 8; the figure's cortex-volume coordinates are not printed in Table 2 and must be reconstructed separately. Human visual signoff of the full snapshot remains pending. This item is table-derived, so no figure replot applies.
