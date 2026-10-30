# Sherwood et al. 2020 supplementary tables 1 and 2

Sherwood CC, Miller SB, Karl M, Stimpson CD, Phillips KA, Jacobs B, Hof PR, Raghanti MA, Smaers JB (2020). Invariant Synapse Density and Neuronal Connectivity Scaling in Primate Neocortical Evolution. *Cerebral Cortex* 30:5604–5615. doi:10.1093/cercor/bhaa149. [Article and supplementary files](https://pmc.ncbi.nlm.nih.gov/articles/PMC8463089/).

The two `*_snapshot.xlsx` files are copies of `suppl_table_1_bhaa149.xlsx` and `suppl_table_2_bhaa149.xlsx` from the main OneDrive checkout. They are frozen publisher inputs. Run each matching `.R` script to rebuild its analysis `.csv`.

## Supplementary Table 1: individuals

27 individual rows from 25 species. The output retains source row number, printed species, sex, age (years, including the text value `adult`), and sampled hemisphere. Its output contains no inferred specimen attributes. The two human and two chimpanzee rows remain distinct.

The source provides **no accession, house name, or institution per row**. Public crosswalk entries `SHERWOOD2020-S1-02` through `SHERWOOD2020-S1-28` are source-local identities, with `Sherwood2020-only` match status. They are not asserted to match animals in any other paper or collection. Ages and hemispheres are preserved in the row notes. The modern printed *Pongo pygmaeus* label links to the post-2001 narrow taxon concept; this does not identify a collection animal.

## Supplementary Table 2: species means

25 species rows, one per species, with brain mass (g), synapse and neuron densities (counts/mm³), and synapses per neuron (dimensionless). `Sherwood_etal_2020_SuppTable2.csv` preserves all 13 printed measures in wide form and adds the source row number. `Sherwood_etal_2020_SuppTable2_definitions.csv` maps each output column to its printed header and unit. The four synapses-per-neuron columns are formulas in the publisher workbook. The build uses their saved values and checks each against synapse density divided by neuron density.

The source prints species names with underscores in Table 2; these are retained in `species_as_published`. Table 2 values are species means, including for the two species with two sampled individuals. They are **not** additional individual specimens and are not added to the specimen crosswalk.

## Main-text specimen details and Karl et al. 2024 comparison

The Sherwood main text adds provenance not printed in Supplementary Table 1: all 27 brains were removed within 14 hours after death and immersion fixed in 10% formalin. The nonhuman specimens came from zoos and research centers, without a collection named for each row. The 29-year-old female and 19-year-old male human brains were supplied by the El Paso County coroner; the stated causes of death were sudden myocardial infarction and postoperative sepsis, respectively. These details are recorded in the public crosswalk notes.

Sherwood also describes a five-individual V1 electron-microscopy sample in the main text. The 19-year-old male human and 11-year-old male baboon probably reuse the corresponding Supplementary Table 1 individuals (same age and sex; the baboon uses the opposite hemisphere). The 16-year-old female lemur, 25-year-old male *Saimiri sciureus*, and 23-year-old female chimpanzee are additional to Supplementary Table 1. These five main-text rows have been added to the specimen crosswalk, reusing the two existing canonical IDs where the within-paper match is probable.

[Karl et al. 2024](../Karl_etal_2024/Karl_etal_2024_TABLE1.csv) reports five primate V1 individuals. Its lemur, squirrel monkey, and chimpanzee match the Sherwood electron-microscopy descriptions on species, sex, age, and hemisphere; shared authors and tissue methods make them probable repeated biological specimens. They share no printed accession. Their Karl rows are attached to the three Sherwood EM canonical IDs with `probable` status. The baboon age differs (Sherwood 11 years; Karl 7 years), despite an identical 174.3 g value for Karl's specimen brain mass and Sherwood's Table 2 species mean. The human descriptions agree on sex, age, and side, but the stated providers differ (El Paso County coroner versus NIH NeuroBioBank), and Karl's 1336 g is an imputed adult-male average. Neither is linked across papers. See `Sherwood2020_Karl2024_specimen_comparison.csv` for the five-row audit.

Sherwood Table 2 reports species means, V1 and IT layer-specific **volumetric** densities (counts/mm³), and their ratios. Karl Table 1 reports specimen-level full-depth V1 **areal** densities (counts/mm²). The density values cannot be directly subtracted or treated as independent measurements of the same quantity. For probable shared specimens, the two papers also should not be counted as independent biological replicates.

## Cross-paper correlation analysis

Run `Sherwood2020_Karl2024_correlation.R` to regenerate `Sherwood2020_Karl2024_correlation_pairs.csv`, `Sherwood2020_Karl2024_correlations.csv`, and `Sherwood2020_Karl2024_density_scatter.png`. The join uses **exact species names** only: *Homo sapiens*, *Lemur catta*, *Pan troglodytes*, and *Papio anubis* (n = 4). Karl's *Saimiri sciureus* is excluded because Sherwood Supplementary Table 2 has *Saimiri boliviensis*, a different species. Karl brain mass is specimen-level; Sherwood Table 2 brain mass is a species value and includes two-specimen means for human and chimpanzee. Karl's human brain mass is imputed from a published adult-male average.

Pearson correlations use log10-transformed positive values; Spearman correlations use ranks. These are descriptive cross-method associations at n = 4, without p-values. Brain mass agrees almost perfectly (Pearson r = 0.9996, Spearman rho = 1.0). Synapse density does **not** show a positive cross-paper association: r = -0.24 for Sherwood V1 II–III and -0.60 for V–VI (rho = -0.2 for either layer). Neuron density is positively associated (r = 0.82 and 0.61; rho = 1.0 and 0.4). Synapses per neuron are also positively associated (r = 0.68 and 0.64; rho = 0.8 for both).

Interpretation is narrow: the two studies differ in 2D versus 3D density units, full-depth versus layer-specific sampling, specimen versus species averaging, and potentially specimen reuse. Leave-one-species-out synapse-density r ranges from negative to positive, demonstrating sensitivity to a single species. These correlations are not estimates of measurement agreement or evidence of independent replication.
