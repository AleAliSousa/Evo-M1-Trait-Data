# Jacobs_etal_2015_Table3

Jacobs, B., Harland, T., Kennedy, D., Schall, M., Wicinski, B., Butti, C., Hof, P. R., & Sherwood, C. C.
(2015). The neocortex of cetartiodactyls II: neuronal morphology of visual and motor cortices in the
giraffe (*Giraffa camelopardalis*). *Brain Structure and Function*, 220(5), 2851-2872.
doi:10.1007/s00429-014-0830-9

Source snapshot: `Jacobs_etal_2015_Table3_snapshot.csv` (hand-transcribed, verbatim copy of the printed
Table 3, "Evaluation of effects in initial exploratory models," p. 2863 of the article PDF).

## What we built
The folder had only the sibling item `Jacobs_etal_2015_Table1` built; Table 3 had no snapshot, CSV, R
script, README, or definitions. Built now:

- **Source:** the article's own Table 3 (page 2863), transcribed directly from the PDF text layer and
  cross-checked against the printed table.
- **Build:** `Jacobs_etal_2015_Table3.R` reads the frozen snapshot and writes:
  - `Jacobs_etal_2015_Table3.csv` (6 rows x 7 columns)
  - `__Public/comparative-data/10.1007%2Fs00429-014-0830-9_Table3.tsv` (public, DOI-encoded, added now
    — matches the registry's `Item encoded`)
- **Definitions:** `reference_tables/Jacobs_etal_2015_Table3_definitions.csv` (added now).

## Data role
**Primary.** GENLIN (generalized linear model) fit statistics for six dendritic/spine measures — DSC,
DSD, DSN, MSL, TDL, Vol (abbreviations defined in the paper's own Table 2) — evaluating whether Brain
(individual subject) and Region-within-Brain (motor vs. visual cortex) predict each measure in the
giraffe's pyramidal neuron sample. Only the DSD model was found to adequately fit the data, indicating a
significant motor-vs-visual regional difference for that measure specifically.

## Checks
- 6 rows (one per dependent variable), 7 columns, matching the printed table exactly, including all
  Wald/Pearson chi-square statistics, degrees of freedom, and p-value thresholds as printed (`n.s.` kept
  verbatim where the source reports no significant effect).

## Extraction / build record
Transcribed directly from the article PDF's Table 3 (page 2863) and its own footnotes by Microsoft
Copilot (AI assistant) on 2026-09-25. The CSV, R script, public TSV, README, and definitions file were
all built in this pass. No prior build existed for this item.
