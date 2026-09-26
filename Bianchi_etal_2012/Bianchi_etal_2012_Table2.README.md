# Bianchi_etal_2012_Table2

Bianchi, S., Stimpson, C. D., Bauernfeind, A. L., Schapiro, S. J., Baze, W. B., McArthur, M. J.,
Bronson, E., Hopkins, W. D., Semendeferi, K., Jacobs, B., Hof, P. R., & Sherwood, C. C. (2012).
Dendritic morphology of pyramidal neurons in the chimpanzee neocortex: regional specializations and
comparison to humans. *Cerebral Cortex*, 23(10), 2429-2436. doi:10.1093/cercor/bhs239

Source snapshot: `Bianchi_etal_2012_Table2_snapshot.csv` (hand-transcribed, verbatim copy of the
printed Table 2, "Dependent measures in areas 3b, 4, 18, and 10 in chimpanzees and humans," p. 4 of
the article PDF).

## What we built
The paper folder had only the source PDF; this item had no snapshot, CSV, R script, README, or
definitions. Built now:

- **Source:** the article's own Table 2 (page 4), transcribed directly from the PDF text layer and
  cross-checked against the printed table.
- **Build:** `Bianchi_etal_2012_Table2.R` reads the frozen snapshot and writes:
  - `Bianchi_etal_2012_Table2.csv` (8 rows x 18 columns)
  - `__Public/comparative-data/10.1093%2Fcercor%2Fbhs239_Table2.tsv` (public, DOI-encoded, added now
    — matches the registry's `Item encoded`)
- **Definitions:** `reference_tables/Bianchi_etal_2012_Table2_definitions.csv` (added now).

## Data role
**Primary quantitative table; human values reuse Jacobs 1997/2001.** Layer III pyramidal-neuron
dendritic morphology (cell soma area/depth, total dendritic length, mean segment length, dendritic
segment count, dendritic spine number and density, and dendritic tree count) for 4 cortical areas
(3b, 4, 18, 10) in chimpanzees (this paper's own Golgi data) and humans. Per the article's Methods, the
human comparison data were collected for the same 4 areas using the identical staining protocol,
section thickness, and experimental procedure as Jacobs et al. (1997, 2001) — this table does not
re-derive those human values, only reproduces them as printed alongside the new chimpanzee data.

## Checks
- 8 rows (4 areas x 2 species), 18 columns, matching the printed table exactly. Dendritic tree count
  is reported for chimpanzees only — left blank for humans, matching the source table's own omission.

## Extraction / build record
Transcribed directly from the article PDF's Table 2 (page 4) by Microsoft Copilot (AI assistant) on
2026-09-25. The CSV, R script, public TSV, README, and definitions file were all built in this pass.
No prior build existed for this item.
