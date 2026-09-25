# Jacobs_etal_2015_Table4

Jacobs, B., Harland, T., Kennedy, D., Schall, M., Wicinski, B., Butti, C., Hof, P. R., & Sherwood, C. C.
(2015). The neocortex of cetartiodactyls II: neuronal morphology of visual and motor cortices in the
giraffe (*Giraffa camelopardalis*). *Brain Structure and Function*, 220(5), 2851-2872.
doi:10.1007/s00429-014-0830-9

Source snapshot: `Jacobs_etal_2015_Table4_snapshot.csv` (hand-transcribed, verbatim copy of the printed
Table 4, "Demographics of species in pyramidal neuron comparisons," p. 2868 of the article PDF).

## What we built
The folder had only the sibling item `Jacobs_etal_2015_Table1` built; Table 4 had no snapshot, CSV, R
script, README, or definitions. Built now:

- **Source:** the article's own Table 4 (page 2868), transcribed directly from the PDF text layer and
  cross-checked against the printed table and its lettered footnotes.
- **Build:** `Jacobs_etal_2015_Table4.R` reads the frozen snapshot and writes:
  - `Jacobs_etal_2015_Table4.csv` (5 rows x 12 columns)
  - `__Public/comparative-data/10.1007%2Fs00429-014-0830-9_Table4.tsv` (public, DOI-encoded, added now
    — matches the registry's `Item encoded`)
- **Definitions:** `reference_tables/Jacobs_etal_2015_Table4_definitions.csv` (added now).

## Data role
**Primary (giraffe) + secondary (four comparison species).** Sample demographics for the cross-species
pyramidal-neuron comparison reported in the paper's Discussion: giraffe (this paper's own data) plus
African elephant (from Jacobs et al. 2011), humpback whale, minke whale, and bottlenose dolphin (from
Butti et al. 2014b), arranged by mean brain mass (high to low, as printed).

## Layout note
This item transposes the paper's printed layout (species as columns, demographic fields as rows) into
one row per species, each carrying all reported demographic fields as columns — no values were
otherwise re-derived or changed.

## Checks
- 5 rows (one per species), 12 columns, matching the printed table's content and species order (by
  descending brain mass) exactly, including all footnoted qualifiers (source study, fixation method and
  autolysis time, region sampled) reproduced verbatim.

## Extraction / build record
Transcribed directly from the article PDF's Table 4 (page 2868) and its own lettered footnotes by
Microsoft Copilot (AI assistant) on 2026-09-25. The CSV, R script, public TSV, README, and definitions
file were all built in this pass. No prior build existed for this item.
