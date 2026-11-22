# Titova_etal_2013_Figure3

Source: `Titova-2013-Anorexia nervosa is linked to redu.pdf`. PDF Figure 3 forest plot; printed numeric labels transcribed. Registry item: `Titova_etal_2013_Figure3` in `__ReadMe.xlsx`.

## Build

Global cerebrospinal fluid Cohen's D effect sizes for eight studies and one synthesis row in current anorexia nervosa versus healthy controls. The figure prints confidence intervals, p values and weights. These are standardized comparative effects, not absolute control/patient volumes. The meta-analysis reuses primary studies and should not be counted as independent primary observations.

Printed decimal commas parsed to decimal points. Source p=0 retained as printed text, not interpreted as exact probability zero. The source does not specify the CI level in the figure, so columns are labeled CI without assuming 95%.

From this paper folder, run:

```sh
Rscript Titova_etal_2013_Figure3.R
```

The script reads only `Titova_etal_2013_Figure3_snapshot.csv` for measurements and writes `Titova_etal_2013_Figure3.csv` plus the DOI-coded public TSV under `__Public/comparative-data/`. The snapshot is frozen; do not overwrite it when rebuilding. Definitions are in `reference_tables/Titova_etal_2013_Figure3_definitions.csv`.

## Source and verification

Replot command: Rscript Titova_etal_2013_Figure3_replot.R. The PNG was generated and compared with the PDF panel by AI; study order, effect-axis scale and printed CI bars are preserved. Box size/weight encoding and source red reference line are omitted; weights remain in the CSV. Human visual signoff pending.

No cross-paper merge is performed by this item build. Condition labels and source measurement scopes must be respected before any merge.
