# Bianchi_etal_2012_Table1

Bianchi, S., Stimpson, C. D., Bauernfeind, A. L., Schapiro, S. J., Baze, W. B., McArthur, M. J.,
Bronson, E., Hopkins, W. D., Semendeferi, K., Jacobs, B., Hof, P. R., & Sherwood, C. C. (2012).
Dendritic morphology of pyramidal neurons in the chimpanzee neocortex: regional specializations and
comparison to humans. *Cerebral Cortex*, 23(10), 2429-2436. doi:10.1093/cercor/bhs239

Source snapshot: `Bianchi_etal_2012_Table1_snapshot.csv` (hand-transcribed, verbatim copy of the
printed Table 1, "Demographic information for chimpanzee (N=7) and human samples (N=8)," p. 3 of the
article PDF).

## What we built
The paper folder had only the source PDF; this item had no snapshot, CSV, R script, README, or
definitions. Built now:

- **Source:** the article's own Table 1 (page 3), transcribed directly from the PDF text layer and
  cross-checked against the printed table.
- **Build:** `Bianchi_etal_2012_Table1.R` reads the frozen snapshot and writes:
  - `Bianchi_etal_2012_Table1.csv` (15 rows x 6 columns)
  - `__Public/comparative-data/10.1093%2Fcercor%2Fbhs239_Table1.tsv` (public, DOI-encoded, added now
    — matches the registry's `Item encoded`)
- **Definitions:** `reference_tables/Bianchi_etal_2012_Table1_definitions.csv` (added now).

## Data role
**Primary (specimen metadata).** Age, sex, post-mortem interval (PMI), and fixation duration for the
7 chimpanzee and 8 human specimens whose layer III pyramidal neurons were Golgi-stained and quantified
in this study (see the sibling item `Bianchi_etal_2012_Table2` for the resulting dendritic-morphology
measures). This is sample provenance metadata, not a trait measurement in itself.

## Checks
- 15 rows (7 chimpanzee + 8 human), 6 columns, matching the printed table exactly, including the
  approximate ("~4") PMI values printed for several chimpanzee specimens.

## Extraction / build record
Transcribed directly from the article PDF's Table 1 (page 3) by Microsoft Copilot (AI assistant) on
2026-09-25. The CSV, R script, public TSV, README, and definitions file were all built in this pass.
No prior build existed for this item.
