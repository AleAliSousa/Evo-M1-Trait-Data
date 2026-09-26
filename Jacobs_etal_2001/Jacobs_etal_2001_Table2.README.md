# Jacobs_etal_2001_Table2

Jacobs, B., Schall, M., Prather, M., Kapler, E., Driscoll, L., Baca, S., Jacobs, J., Ford, K.,
Wainwright, M., & Treml, M. (2001). Regional dendritic and spine variation in human cerebral cortex: a
quantitative Golgi study. *Cerebral Cortex*, 11(6), 558-571. doi:10.1093/cercor/11.6.558

Source snapshot: `Jacobs_etal_2001_Table2_snapshot.csv` (hand-transcribed, verbatim copy of the
printed Table 2, "Laminar and sampled soma depths (μm) and soma size (μm²)," p. 4 of the article PDF).

## What we built
The paper folder had only the source PDF; this item had no snapshot, CSV, R script, README, or
definitions. Built now:

- **Source:** the article's own Table 2 (page 4), transcribed directly from the PDF text layer and
  cross-checked against the printed table and its footnote.
- **Build:** `Jacobs_etal_2001_Table2.R` reads the frozen snapshot and writes:
  - `Jacobs_etal_2001_Table2.csv` (2 rows x 13 columns)
  - `__Public/comparative-data/10.1093%2Fcercor%2F11.6.558_Table2.tsv` (public, DOI-encoded, added now
    — matches the registry's `Item encoded`)
- **Definitions:** `reference_tables/Jacobs_etal_2001_Table2_definitions.csv` (added now).

## Data role
**Primary.** Cortical laminar depths (layer I/II junction, layer II/III junction, layer III/IV
junction, gray/white matter junction) and sampled pyramidal-neuron soma depth/size, summarized by
Benson's hierarchical integration-level grouping: Low integration (primary + unimodal regions: BA3-1-2,
BA4, BA22, BA44) vs. High integration (heteromodal + supramodal regions: BA6β, BA10, BA11, BA39). These
measures confirm sampling consistency across integration levels before comparing dendritic measures.

## Scope note
Unlike the sibling item `Jacobs_etal_1997_Table2` (which reports these measures separately by age
group AND cortical area), this table reports only 2 summary rows (Low vs. High integration level), per
the printed table's own layout — no per-area or per-age breakdown is given in this table.

## Checks
- 2 rows (Low and High integration levels), 13 columns, matching the printed table exactly.

## Extraction / build record
Transcribed directly from the article PDF's Table 2 (page 4) by Microsoft Copilot (AI assistant) on
2026-09-25. The CSV, R script, public TSV, README, and definitions file were all built in this pass.
No prior build existed for this item.
