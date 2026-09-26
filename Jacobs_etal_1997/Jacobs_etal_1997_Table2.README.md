# Jacobs_etal_1997_Table2

Jacobs, B., Driscoll, L., & Schall, M. (1997). Life-span dendritic and spine changes in areas 10 and 18
of human cortex: a quantitative Golgi study. *The Journal of Comparative Neurology*, 386(4), 661-680.
doi:10.1002/(SICI)1096-9861(19971006)386:4<661::AID-CNE11>3.0.CO;2-N

Source snapshot: `Jacobs_etal_1997_Table2_snapshot.csv` (hand-transcribed, verbatim copy of the
printed Table 2, "Laminar and Sampled Soma Depths (μm) and Soma Size (μm²)," p. 5 of the article PDF).

## What we built
The paper folder had only the source PDF; this item had no snapshot, CSV, R script, README, or
definitions. Built now:

- **Source:** the article's own Table 2 (page 5), transcribed directly from the PDF text layer and
  cross-checked against the printed table.
- **Build:** `Jacobs_etal_1997_Table2.R` reads the frozen snapshot and writes:
  - `Jacobs_etal_1997_Table2.csv` (4 rows x 14 columns)
  - `__Public/comparative-data/10.1002%2F(sici)1096-9861(19971006)386%3A4%3C661%3A%3AAid-cne11%3E3.0.Co;2-n_Table2.tsv`
    (public, DOI-encoded, added now — matches the registry's `Item encoded`)
- **Definitions:** `reference_tables/Jacobs_etal_1997_Table2_definitions.csv` (added now).

## Data role
**Primary.** Cortical laminar depths (layer I/II junction, layer II/III junction, layer III/IV
junction, gray/white matter junction) and sampled pyramidal-neuron soma depth/size, reported separately
for a younger (≤50 years, n=10) and older (>50 years, n=16) age group, and for Brodmann areas 10 and 18.
These measures were used in the study to confirm sampling consistency across age groups and cortical
areas before comparing dendritic measures.

## Checks
- 4 rows (2 age groups x 2 areas), 14 columns, matching the printed table exactly, including sampled
  soma size (printed in parentheses alongside soma depth in the source table).

## Extraction / build record
Transcribed directly from the article PDF's Table 2 (page 5) by Microsoft Copilot (AI assistant) on
2026-09-25. The CSV, R script, public TSV, README, and definitions file were all built in this pass.
No prior build existed for this item.
