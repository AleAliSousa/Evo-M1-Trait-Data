# Seelke etal 2014

Seelke, A. M.; Dooley, J. C.; Krubitzer, L. A. (2014). The cellular composition of the marsupial neocortex. J Comp Neurol :n/a-n/a. doi:10.1002/cne.23534

**Status: wired 2026-11-23** into `__merging_cell_counts_isotropic_fractionator` (Tables 3, 4 and 5; served in the compiled table under the dataset `Cell counts`). Added 2026-10-21 as a source candidate from the Lewitus et al. 2014 External Database S1 reference list (Lewitus ref 61; cellular composition of the marsupial neocortex); items built the same day (below).

PDF copied from the owner's EndNote library (record 2525). Lewitus's copy of any value from this paper is secondary, so prefer this original.

## In the merge (owner decision 2026-11-23)
- Served: the "Whole neocortex" row as structure `Neocortex`, and `V1`, `S1`, `A1`: weights (Table 3), cells, neurons, non-neurons and % neurons (Table 4), densities (Table 5). 52 values for *Monodelphis domestica*, team `Krubitzer`.
- Not served, each with a registered status and reason in `__merging_cell_counts_isotropic_fractionator/not_served.csv`: the "Σ neocortex" row (`second_measurement`: the neocortex of the other hemisphere of the same animals, dissected and summed; the neocortex is served from the intact hemisphere), "Rem Ctx" (`not_a_database_structure`), and Table 3's "% of Σ neocortex" (`no_measure_code`).
- One hemisphere: every weight and count in these tables is one hemisphere. Under the merge's hemisphere rule each is served twice: as the both-hemisphere estimate (2 × the printed value, doubled by this project and marked in `cell_counts_isotropic_fractionator_flags.csv`) under the plain label, e.g. `Neocortex_Mass.g` = 0.146 g, and as measured under `_unilateral_`, e.g. `Neocortex_unilateral_Mass.g` = 0.073 g. Percentages, densities and the derived non-neuron/neuron ratio are never doubled. Counts are served as counts (printed millions × 10^6) and densities per mg (printed millions per g × 1000). The printed ± is kept as `_pm` with the measured value, not as SD.
- Table 1 (animals) is not in the merge. Details: `__merging_cell_counts_isotropic_fractionator/WIRING_into_cell_counts_isotropic_fractionator.md`.

## Dataset items built 2026-10-21
- `Seelke_etal_2014_Table1` (5 animals: case, age, weight, sex)
- `Seelke_etal_2014_Table3` (cortical field weights, group mean +/-)
- `Seelke_etal_2014_Table4` (cells, % neurons, neurons, non-neurons per region; the Lewitus 2014 ref 61 quantities)
- `Seelke_etal_2014_Table5` (cell, neuron, non-neuron densities per region)
Each has its own `.README.md`. **Method note: this paper uses the isotropic fractionator (NeuN + DAPI nuclei counting, flow cytometry), not stereological sectioning**, contrary to the working assumption; the repo isotropic-fractionator codes (C.n, N.n, O.n, p.C.N) were used. Results are group means over n = 5 opossums (Monodelphis domestica).

## Tables not built
- Table 2 (NeuN antibody manufacturer, immunogen, dilution): methods reagent table, no species/specimen data.
