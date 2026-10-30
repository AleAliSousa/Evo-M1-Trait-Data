# Todorov et al. 2019 — sexual-dimorphism supplement

Todorov OS, Weisbecker V, Gilissen E, Zilles K, de Sousa AA (2019),
“Primate hippocampus size and organization are predicted by sociality but not
diet,” *Proceedings of the Royal Society B* 286:20191712.
DOI: [10.1098/rspb.2019.1712](https://doi.org/10.1098/rspb.2019.1712).

## Source and build

`rspb20191712_si_001.zip` is the article's electronic supplementary archive.
`Todorov_etal_2019_rspb20191712si001.R` extracts and validates its `dimorphdata.csv`
member, producing `Todorov_etal_2019_rspb20191712si001.csv`. The output has 12 species
and 19 variables. Values are natural-log sexual-dimorphism ratios,
`ln(male arithmetic mean / female arithmetic mean)`; they are not absolute
volumes.

The field dictionary is
`reference_tables/Todorov_etal_2019_rspb20191712si001_definitions.csv`.

## Provenance and merge treatment

The paper says that unpublished male and female brain-component records were
used to calculate sex averages, credits Heiko Frahm for supplying the data,
and uses anatomical definitions from Stephan et al. (1981). These are therefore
derived summaries of the Frahm/Stephan material, not a new independent set of
brain measurements.

Do not add this table to `__merging_volumes`: its values are log ratios rather
than absolute volumes, and treating them as another measurement team would
double-count the underlying specimens. The restricted companion reconstructs
the 12 species × 19 variables from the private Frahm specimen records and keeps
all specimen-level values out of this repository.

Pipeline: Source archive → public data readable ✅ → restricted provenance
comparison ✅ → merge volumes **not applicable**.
