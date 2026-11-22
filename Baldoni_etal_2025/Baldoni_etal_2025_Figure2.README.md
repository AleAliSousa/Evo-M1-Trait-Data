# Baldoni_etal_2025_Figure2

Figure 2 of Baldoni et al. (2025), *Programmed seasonal brain shrinkage in the common shrew via water loss without cell death*. Article PDF: `Baldoni-2025-Programmed-seasonal-brain-shrinka.pdf`, page 6 (legend page 7). Deposited data and code: [Edmond doi:10.17617/3.J8V4QU](https://doi.org/10.17617/3.J8V4QU), local untouched download `doi-10.17617-3.j8v4qu.zip`.

## Frozen source and build

`Baldoni_etal_2025_Figure2_snapshot.csv` is an exact byte copy of the ZIP member `data/brain_cell_counts.csv`. It has 14 individual shrews, seven regional `*_all` counts and seven `*_neu` counts per individual, plus six glia columns. The R reader uses only that snapshot for measurements and writes `Baldoni_etal_2025_Figure2.csv` and the DOI-coded public TSV. The analysis file has 98 individual-by-region rows, including all 14 source animals, with separate exact total-cell, neuron and available glia counts.

From this folder:

```sh
Rscript Baldoni_etal_2025_Figure2.R
Rscript Baldoni_etal_2025_Figure2_replot.R
```

The authors' `script/cells.R` recodes the four **Summer Adult** animals as spring and excludes them from Figure 2. The five Summer Juvenile and five Winter Juvenile animals are marked `figure2_plotted=TRUE`; compare those two cohorts to reproduce the figure. The four additional adults remain available for other analyses and must not be silently pooled with the summer juveniles. Brain mass is converted from g to mg. The source has no olfactory-bulb glia field; `Glia.n` is missing for that region, not zero. Regions may overlap and are not an additive partition of the brain.

The source counts for animal `a` do not exactly satisfy total cells = neurons + glia for all brain (difference 13,619), caudoputamen (12,908), or amygdala (712). `All_minus_neurons_glia.n` records the check; the build reports 81 pass and three mismatches using a one-cell tolerance. The published deposited counts are unchanged.

## Figure replot and review

`Baldoni_etal_2025_Figure2_replot.R` reads the built item CSV directly and plots the exact individual points for the 10 animals included in Figure 2. It overlays approximate posterior means and 95% credible intervals from `reference_tables/Baldoni_etal_2025_Figure2_posterior_digitized.csv`, whose source pixel coordinates are preserved in `reference_tables/Baldoni_etal_2025_Figure2_posterior_pixels.csv`. These digitized summaries are **not** used in the public TSV, and no Bayesian model was refit. The replot preserves the two panels, seven facet identities, source order, linear cell-count axes and separate summer/winter series. Jitter positions and facet layout differ from the source. The PNG was run and visually checked by the assistant against PDF page 6; human visual signoff remains pending.
