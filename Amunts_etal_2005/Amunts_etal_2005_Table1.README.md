# Amunts_etal_2005_Table1

Amunts, K., Kedo, O., Kindler, M., Pieperhoff, P., Mohlberg, H., Shah, N. J., Habel, U., Schneider, F., & Zilles, K. (2005). Cytoarchitectonic mapping of the human amygdala, hippocampal region and entorhinal cortex: intersubject variability and probability maps. Anatomy and Embryology, 210(5–6), 343–352. https://doi.org/10.1007/s00429-005-0025-5

Table 1 (p.346) is transcribed in source row/column order to the CSV snapshot, including the merged-header meaning, printed mean±SD cells and total columns. Ten brains (5 male, 5 female), mean age 64.9±16.9 years, no neurological/psychiatric history. Cytoarchitectonic planimetry of serial 20-μm sections; individual shrinkage factors correct histological volumes to estimated fresh-tissue volumes. These are not the volumes of the warped probability maps.

The analysis row retains left/right means and SDs for eight listed regions plus the two printed totals. Bilateral means are L+R; no bilateral SD is inferred because paired covariance is unpublished. CA1–3, dentate gyrus, subiculum and HATA remain distinct anatomical fields; CA1–3 is not relabelled CA1. Printed totals are used rather than replacing them with sums of rounded components.

AI visual comparison against the PDF was performed on 2026-10-25; human RA verification remains pending. Four sum checks pass at tolerances justified by integer rounding: amygdala component sums differ from the printed totals by −1/+1 mm3; hippocampal sums match exactly. The prose on p.349 prints right amygdala 1526 and hippocampus 4484, whereas Table 1 gives 1506 and 4884. The source discrepancy is recorded in errata; the dataset follows Table 1.

This is a Zilles/Amunts cohort, not a newly presumed independent laboratory sample. Bilateral volumes can enter the Zilles team in the volume merge; source-specific subregion boundaries are retained.

Built by Codex on 2026-10-25. Rebuild with `Rscript Amunts_etal_2005_Table1.R` from any directory. The script reads only the frozen source and live registry; no source download or manual output editing is required. Species labels remain as published; any later harmonisation belongs in the collection-scoped species key.

<!-- errata:begin -->
## Errata

Generated from `reference_tables/Amunts_etal_2005_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| Amunts_etal_2005-E001 | Amygdala_right_mean_mm3 | Table 1 p.346 versus Results p.349 | 1506 (Table 1); 1526 (prose) |  | publication_ambiguity |  | confirmed | Keep Table 1; true original measurement cannot be adjudicated from this paper. | Confirmed source inconsistency; no silent correction. |
| Amunts_etal_2005-E002 | Hippocampus_right_mean_mm3 | Table 1 p.346 versus Results p.349 | 4884 (Table 1); 4484 (prose) |  | publication_ambiguity |  | confirmed | Table 1 total agrees with its four component means; keep Table 1. | Confirmed source inconsistency; no silent correction. |

2 recorded, 0 open (proposed), 2 confirmed, 0 withdrawn.
<!-- errata:end -->
