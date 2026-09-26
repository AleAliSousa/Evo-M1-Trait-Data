# Jacobs_etal_2001_Table1

Jacobs, B., Schall, M., Prather, M., Kapler, E., Driscoll, L., Baca, S., Jacobs, J., Ford, K.,
Wainwright, M., & Treml, M. (2001). Regional dendritic and spine variation in human cerebral cortex: a
quantitative Golgi study. *Cerebral Cortex*, 11(6), 558-571. doi:10.1093/cercor/11.6.558

Source snapshot: `Jacobs_etal_2001_Table1_snapshot.csv` (hand-transcribed, verbatim copy of the
printed Table 1, "Subject summary," p. 2 of the article PDF).

## What we built
The paper folder had only the source PDF; this item had no snapshot, CSV, R script, README, or
definitions. Built now:

- **Source:** the article's own Table 1 (page 2), transcribed directly from the PDF text layer and
  cross-checked against the printed table and its footnotes.
- **Build:** `Jacobs_etal_2001_Table1.R` reads the frozen snapshot and writes:
  - `Jacobs_etal_2001_Table1.csv` (10 rows x 7 columns)
  - `__Public/comparative-data/10.1093%2Fcercor%2F11.6.558_Table1.tsv` (public, DOI-encoded, added now
    — matches the registry's `Item encoded`)
- **Definitions:** `reference_tables/Jacobs_etal_2001_Table1_definitions.csv` (added now).

## Data role
**Primary (specimen metadata).** Sex, age, body weight, autolysis time, cause of death, and occupation/
education for the 10 subjects (5 male, 5 female) whose Golgi-impregnated cortical tissue across 8
Brodmann areas (BA3-1-2, BA4, BA22, BA44, BA6β, BA10, BA11, BA39) was quantified in this study. This is
sample provenance metadata, not a dendritic-morphology trait measurement in itself (see the sibling
item `Jacobs_etal_2001_Table2` for laminar/soma summary measures).

## Scope note
Per the table's own footnote, BA10 tissue from all subjects except F11 and F15 was used previously in
the sibling paper `Jacobs_etal_1997` — this item does not re-flag which individual rows overlap; consult
the source footnote for that detail if cross-paper specimen deduplication is needed downstream.

## Checks
- 10 rows, 7 columns, matching the printed table's subject count and content exactly.

## Extraction / build record
Transcribed directly from the article PDF's Table 1 (page 2) by Microsoft Copilot (AI assistant) on
2026-09-25. The CSV, R script, public TSV, README, and definitions file were all built in this pass.
No prior build existed for this item.
