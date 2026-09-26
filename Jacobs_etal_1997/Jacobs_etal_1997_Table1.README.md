# Jacobs_etal_1997_Table1

Jacobs, B., Driscoll, L., & Schall, M. (1997). Life-span dendritic and spine changes in areas 10 and 18
of human cortex: a quantitative Golgi study. *The Journal of Comparative Neurology*, 386(4), 661-680.
doi:10.1002/(SICI)1096-9861(19971006)386:4<661::AID-CNE11>3.0.CO;2-N

Source snapshot: `Jacobs_etal_1997_Table1_snapshot.csv` (hand-transcribed, verbatim copy of the
printed Table 1, "Subject Summary," p. 3 of the article PDF).

## What we built
The paper folder had only the source PDF; this item had no snapshot, CSV, R script, README, or
definitions. Built now:

- **Source:** the article's own Table 1 (page 3), transcribed directly from the PDF text layer and
  cross-checked against the printed table and its footnotes.
- **Build:** `Jacobs_etal_1997_Table1.R` reads the frozen snapshot and writes:
  - `Jacobs_etal_1997_Table1.csv` (26 rows x 8 columns)
  - `__Public/comparative-data/10.1002%2F(sici)1096-9861(19971006)386%3A4%3C661%3A%3AAid-cne11%3E3.0.Co;2-n_Table1.tsv`
    (public, DOI-encoded, added now — matches the registry's `Item encoded`)
- **Definitions:** `reference_tables/Jacobs_etal_1997_Table1_definitions.csv` (added now).

## Data role
**Primary (specimen metadata).** Sex, age, body weight, autolysis time, cause of death, occupation/
education, and ethnicity for the 26 subjects (13 male, 13 female; ages 14-106 years) whose Golgi-
impregnated cortical tissue (areas 10 and 18) was quantified in this study. This is sample provenance
metadata, not a dendritic-morphology trait measurement in itself (see the sibling item
`Jacobs_etal_1997_Table2` for laminar/soma measures).

## Checks
- 26 rows, 8 columns, matching the printed table's subject count and content exactly, including the
  table's own footnotes (M69.1/M69.2 disambiguation for the two 69-year-old males; ethnicity noted only
  where it differs from the Caucasian majority).

## Extraction / build record
Transcribed directly from the article PDF's Table 1 (page 3) by Microsoft Copilot (AI assistant) on
2026-09-25. The CSV, R script, public TSV, README, and definitions file were all built in this pass.
No prior build existed for this item.
