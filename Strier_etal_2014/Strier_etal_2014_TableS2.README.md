# Strier_etal_2014_TableS2

Annual data on demographic and behavioral variation

## Source → Snapshot

Strier, K. B., Lee, P. C., & Ives, A. R. (2014). Behavioral flexibility and the evolution of primate social states. PLoS ONE, 9(12), e114099. https://doi.org/10.1371/journal.pone.0114099

Frozen source PDFs accompany this item. Published-table transcription preserving row/column order, labels and missing cells. Extracted by Codex on 2026-10-26; AI comparison against the source completed; human RA verification pending.

## Data readable

The R reader reads the frozen snapshot, performs documented transformations, and writes 486 rows to CSV and DOI-coded TSV.

## Interpretation and provenance

486 annual/group observations underlie the 29 TableS1 summaries. Observation rows are NOT independent species. Source row is a unique audit key. Published group identifiers can repeat across studies; two contiguous Papio cynocephalus blocks both use group 1 and overlapping years. Their separate study membership is recorded in reference_tables, supported by source order, year restarts, reference sets and agreement of each block's mean group size with TableS1 (38.33 and 47.13). References are annual-row-specific and may be subsets of a summary's reference set. Missing values remain missing. Sex ratios are preserved; population-level averages can differ from a ratio of printed counts, so an arithmetic mismatch is not automatically a publication error.

## Table checks

R run: 445 pass, 15 mismatch, 26 not_evaluable. Original values retained.

- study_05:2:1963: recomputed 0.571429, printed 0.51, tolerance 0.005.
- study_07:1:2000: recomputed 0.583969, printed 0.59, tolerance 0.005.
- study_10:1:1990: recomputed 0.571429, printed 0.59, tolerance 0.005.
- study_11:1:1987: recomputed 1.25, printed 1.34, tolerance 0.005.
- study_11:1:1991: recomputed 0.75, printed 0.8, tolerance 0.005.
- study_11:1:1996: recomputed 1.02439, printed 1.03, tolerance 0.005.
- study_11:1:2001: recomputed 0.8, printed 0.82, tolerance 0.005.
- study_12:1:1990: recomputed 0.3, printed 0.33, tolerance 0.005.
- study_12:1:1993: recomputed 0.3, printed 0.33, tolerance 0.005.
- study_16:1:1977: recomputed 0.933333, printed 1, tolerance 0.005.
- study_16:1:1979: recomputed 1.06667, printed 0.94, tolerance 0.005.
- study_16:1:1983: recomputed 1.16667, printed 0.86, tolerance 0.005.
- study_24:1:1999: recomputed 0.181818, printed 0.09, tolerance 0.005.
- study_26:6:2003: recomputed 0.3, printed 0.33, tolerance 0.005.
- study_28:3:1980: recomputed 5, printed 0.2, tolerance 0.005.

## Online database

Registered by item name in `__ReadMe.xlsx`; public TSV: `10.1371%2Fjournal.pone.0114099_TableS2.tsv`. All columns have item-scoped definitions. Source database/catalog intake only; aggregate merge pipelines are unchanged.

<!-- errata:begin -->
## Errata

Generated from `reference_tables/Strier_etal_2014_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| Strier_etal_2014-E001 | adult_sex_ratio | Table S2 source row 75; Chlorocebus aethiops; study_05:2:1963 | 0.51 |  | publication_ambiguity |  | proposed | Printed males=1.8, females=3.15; ratio=0.571428571428572; tolerance=0.005 | Source values retained. Population averaging can explain some differences; do not label every mismatch a numerical error or replace the printed ratio. |
| Strier_etal_2014-E002 | adult_sex_ratio | Table S2 source row 111; Gorilla beringei; study_07:1:2000 | 0.59 |  | publication_ambiguity |  | proposed | Printed males=3.06, females=5.24; ratio=0.583969465648855; tolerance=0.005 | Source values retained. Population averaging can explain some differences; do not label every mismatch a numerical error or replace the printed ratio. |
| Strier_etal_2014-E003 | adult_sex_ratio | Table S2 source row 239; Lagothrix lagotricha; study_10:1:1990 | 0.59 |  | publication_ambiguity |  | proposed | Printed males=4, females=7; ratio=0.571428571428571; tolerance=0.005 | Source values retained. Population averaging can explain some differences; do not label every mismatch a numerical error or replace the printed ratio. |
| Strier_etal_2014-E004 | adult_sex_ratio | Table S2 source row 243; Lemur catta; study_11:1:1987 | 1.34 |  | publication_ambiguity |  | proposed | Printed males=4.5, females=3.6; ratio=1.25; tolerance=0.005 | Source values retained. Population averaging can explain some differences; do not label every mismatch a numerical error or replace the printed ratio. |
| Strier_etal_2014-E005 | adult_sex_ratio | Table S2 source row 244; Lemur catta; study_11:1:1991 | 0.8 |  | publication_ambiguity |  | proposed | Printed males=4.2, females=5.6; ratio=0.75; tolerance=0.005 | Source values retained. Population averaging can explain some differences; do not label every mismatch a numerical error or replace the printed ratio. |
| Strier_etal_2014-E006 | adult_sex_ratio | Table S2 source row 245; Lemur catta; study_11:1:1996 | 1.03 |  | publication_ambiguity |  | proposed | Printed males=4.2, females=4.1; ratio=1.02439024390244; tolerance=0.005 | Source values retained. Population averaging can explain some differences; do not label every mismatch a numerical error or replace the printed ratio. |
| Strier_etal_2014-E007 | adult_sex_ratio | Table S2 source row 246; Lemur catta; study_11:1:2001 | 0.82 |  | publication_ambiguity |  | proposed | Printed males=3.2, females=4; ratio=0.8; tolerance=0.005 | Source values retained. Population averaging can explain some differences; do not label every mismatch a numerical error or replace the printed ratio. |
| Strier_etal_2014-E008 | adult_sex_ratio | Table S2 source row 248; Macaca maura; study_12:1:1990 | 0.33 |  | publication_ambiguity |  | proposed | Printed males=3, females=10; ratio=0.3; tolerance=0.005 | Source values retained. Population averaging can explain some differences; do not label every mismatch a numerical error or replace the printed ratio. |
| Strier_etal_2014-E009 | adult_sex_ratio | Table S2 source row 251; Macaca maura; study_12:1:1993 | 0.33 |  | publication_ambiguity |  | proposed | Printed males=3, females=10; ratio=0.3; tolerance=0.005 | Source values retained. Population averaging can explain some differences; do not label every mismatch a numerical error or replace the printed ratio. |
| Strier_etal_2014-E010 | adult_sex_ratio | Table S2 source row 306; Pan paniscus; study_16:1:1977 | 1 |  | publication_ambiguity |  | proposed | Printed males=14, females=15; ratio=0.933333333333333; tolerance=0.005 | Source values retained. Population averaging can explain some differences; do not label every mismatch a numerical error or replace the printed ratio. |
| Strier_etal_2014-E011 | adult_sex_ratio | Table S2 source row 307; Pan paniscus; study_16:1:1979 | 0.94 |  | publication_ambiguity |  | proposed | Printed males=16, females=15; ratio=1.06666666666667; tolerance=0.005 | Source values retained. Population averaging can explain some differences; do not label every mismatch a numerical error or replace the printed ratio. |
| Strier_etal_2014-E012 | adult_sex_ratio | Table S2 source row 310; Pan paniscus; study_16:1:1983 | 0.86 |  | publication_ambiguity |  | proposed | Printed males=21, females=18; ratio=1.16666666666667; tolerance=0.005 | Source values retained. Population averaging can explain some differences; do not label every mismatch a numerical error or replace the printed ratio. |
| Strier_etal_2014-E013 | adult_sex_ratio | Table S2 source row 349; Papio ursinus; study_24:1:1999 | 0.09 |  | publication_ambiguity |  | proposed | Printed males=1, females=8; ratio=0.181818181818182; tolerance=0.005 | Source values retained. Population averaging can explain some differences; do not label every mismatch a numerical error or replace the printed ratio. |
| Strier_etal_2014-E014 | adult_sex_ratio | Table S2 source row 390; Piliocolobus kirkii; study_26:6:2003 | 0.33 |  | publication_ambiguity |  | proposed | Printed males=3, females=10; ratio=0.3; tolerance=0.005 | Source values retained. Population averaging can explain some differences; do not label every mismatch a numerical error or replace the printed ratio. |
| Strier_etal_2014-E015 | adult_sex_ratio | Table S2 source row 434; Piliocolobus tephrosceles; study_28:3:1980 | 0.2 |  | publication_ambiguity |  | proposed | Printed males=5, females=1; ratio=5; tolerance=0.005 | Source values retained. Population averaging can explain some differences; do not label every mismatch a numerical error or replace the printed ratio. |
| Strier_etal_2014-E017 | source_key | Pan troglodytes verus source [22] | [22] |  | publication_ambiguity |  | proposed | Published TableS3 page2 jumps from [21] to [23]; all three bibliography pages checked. | Unresolved source key preserved; no inferred citation. |

16 recorded, 16 open (proposed), 0 confirmed, 0 withdrawn.
<!-- errata:end -->
