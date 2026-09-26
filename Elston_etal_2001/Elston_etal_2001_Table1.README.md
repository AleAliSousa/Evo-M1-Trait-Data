# Elston_etal_2001_Table1

Elston, G. N., Benavides-Piccione, R., & DeFelipe, J. (2001). The pyramidal cell in cognition: a
comparative study in human and monkey. *The Journal of Neuroscience*, 21:RC163 (1-5).
doi:10.1523/JNEUROSCI.21-17-j0002.2001

Source snapshot: `Elston_etal_2001_Table1_snapshot.csv` (hand-transcribed, verbatim copy of the
printed Table 1, "Peak branching complexity, size, and spine density of the basal dendrites of layer
III pyramidal cells," p. 2 of the article PDF).

## What we built
The paper folder had only the source PDF; this item had no snapshot, CSV, R script, README, or
definitions. Built now:

- **Source:** the article's own Table 1 (page 2), transcribed directly from the PDF text layer and
  cross-checked against the printed table.
- **Build:** `Elston_etal_2001_Table1.R` reads the frozen snapshot and writes:
  - `Elston_etal_2001_Table1.csv` (9 rows x 8 columns)
  - `__Public/comparative-data/10.1523%2FJNEUROSCI.21-17-j0002.2001_Table1.tsv` (public, DOI-encoded,
    added now — matches the registry's `Item encoded`)
- **Definitions:** `reference_tables/Elston_etal_2001_Table1_definitions.csv` (added now).

## Data role
**Primary.** Layer III pyramidal-neuron basal dendritic morphology — peak Sholl branching complexity,
basal dendritic field area, and maximum spine density — compared across 3 species (marmoset, macaque,
human) and 3 cortical regions (occipital, temporal, prefrontal) from a total sample of 344 neurons.

## Checks
- 9 rows (3 species x 3 regions), 8 columns, matching the printed table exactly, including the
  table's own mixed dispersion statistics: SD is reported for branching complexity and field area, but
  the spine-density rows report SEM (as explicitly labeled in the source table's own header — not
  altered here).

## Extraction / build record
Transcribed directly from the article PDF's Table 1 (page 2) by Microsoft Copilot (AI assistant) on
2026-09-25. The CSV, R script, public TSV, README, and definitions file were all built in this pass.
No prior build existed for this item.
