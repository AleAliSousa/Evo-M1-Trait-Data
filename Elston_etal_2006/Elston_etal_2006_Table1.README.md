# Elston_etal_2006_Table1

Elston, G. N., Elston, A., Casagrande, V., Kaas, J. H., Van Essen, D. C., & Lund, J. S. (2006).
Specializations of the granular prefrontal cortex of primates: implications for cognitive processing.
*The Anatomical Record Part A*, 288A(1), 26-35. doi:10.1002/ar.a.20278

Source snapshot: `Elston_etal_2006_Table1_snapshot.csv` (hand-transcribed, verbatim copy of the printed
Table 1, "Cortical surface area (CSA), basal dendritic field area (BDFA) and total number of spines
(TNS) for pyramidal cells in the primary (V1) and second (V2) visual areas and granular prefrontal
cortex (gPFC)," p. 4 of the article PDF).

## What we built
The paper folder had only the source PDF; this item had no snapshot, CSV, R script, README, or
definitions. Built now:

- **Source:** the article's own Table 1 (page 4), transcribed directly from the PDF text layer and
  cross-checked against the printed table, including all lettered footnote codes.
- **Build:** `Elston_etal_2006_Table1.R` reads the frozen snapshot and writes:
  - `Elston_etal_2006_Table1.csv` (21 rows x 8 columns)
  - `__Public/comparative-data/10.1002%2Far.a.20278_Table1.tsv` (public, DOI-encoded, added now —
    matches the registry's `Item encoded`)
- **Definitions:** `reference_tables/Elston_etal_2006_Table1_definitions.csv` (added now).

## Data role
**Both primary and secondary, cell by cell.** This is a cross-study compilation table: each of the 3
variables (CSA, BDFA, TNS) for each of 7 species x 3 cortical regions carries its own lettered footnote
(a-w) identifying which published source that specific value comes from — some cells are this paper's
own new measurements ("present results," footnote `w`), others reuse values from Elston et al. (2001)
(footnote `t`) or earlier papers (footnotes `a` through `s`). No value has been re-derived or
recalculated; every number and its source footnote are carried through exactly as printed.

## Checks
- 21 rows (7 species x 3 cortical regions), 8 columns (3 measures, each with its own value + footnote-
  reference column), matching the printed table exactly, including missing cells (printed as an em
  dash in the source and left blank here) for V1 Homo BDFA/TNS, V2 Cercopithecus/Papio CSA, and gPFC
  Otolemur/Aotus CSA plus gPFC Aotus TNS.

## Extraction / build record
Transcribed directly from the article PDF's Table 1 (page 4) and its lettered footnote key by
Microsoft Copilot (AI assistant) on 2026-09-25. The CSV, R script, public TSV, README, and definitions
file were all built in this pass. No prior build existed for this item.
