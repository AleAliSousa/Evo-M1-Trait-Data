# GonzálezPardo_etal_2019_Table1

González-Pardo, H., Arias, J. L., Vallejo, G., & Conejo, N. M. (2019). Influence of environmental enrichment on the volume of brain regions sensitive to early life stress by maternal separation in rats. Psicothema, 31(1), 46–52. https://doi.org/10.7334/psicothema2018.290

**Item number:** Table 1. **Source:** [PDF p.4, printed p.49](https://www.psicothema.com/pdf/4513.pdf); PDF `rat2019.pdf` (SHA256 in reference_tables provenance).

## Source and build

Table 1. Mean estimated volume (mm³) of the selected ROI by MRI volumetry of the experimental groups

The `_snapshot.csv` is a frozen source-layout transcription, retaining headers, row/column order, all groups, missing cells, significance markers and notes. `GonzálezPardo_etal_2019_Table1_snapshot.R` writes only that snapshot and refuses a differing overwrite. `GonzálezPardo_etal_2019_Table1.R` reads its own snapshot, splits means and SEM, and writes the long analysis CSV. Source values are never inferred from percentages or altered to satisfy checks. Source PDF preserved untouched. AI extraction/check date: 2026-11-20; human RA visual signoff remains pending.

## Interpretation

Daily maternal separation 4 h on P2–21. Enrichment P21–60; all groups then standard same-treatment housing until P90. MRI n=5 male rats per group, not cohort n=10. Table labels PFC; methods say medial PFC. Methods mention VOIs corrected for total brain volume; retain reported mm3 without assuming raw unadjusted bilateral volume. Tables 1 and 2 disagree in several means; preserve both and analyze separately.

Species as published: Wistar rats. Accepted species: Rattus norvegicus. Primary data; group means, not individuals and not species means. No global trait merges or species keys edited.

## Registration and units

Main registry has no matching item as of 2026-11-20. Registry-row workbook is prepared against the live header schema. Owner pastes A-D and M onward, preserves E-L formulas, runs `_tools/file_list.R`, and verifies Item encoded. The R reader writes the public TSV only after the live main registry resolves exactly one Item name. No derived identifier is substituted for the registry. Analysis proceeds from the CSV independently of pending registration.

**2026-11-26 completion:** The matching main-registry row is now present. The source PDF confirms the author spelling González-Pardo; folder and item filenames were corrected accordingly. `Rscript --vanilla GonzálezPardo_etal_2019/GonzálezPardo_etal_2019_Table1.R` regenerated the CSV and `__Public/comparative-data/10.7334%2Fpsicothema2018.290_Table1.tsv` (16 matching parsed rows). Human visual signoff remains pending.

Physical units: volume mm3 (Sarabdjitsingh μl converted 1:1), area mm2, or source-normalized dimensionless values x1000. In Spinelli, areas are explicitly identified from footnote a; their source header is preserved in the snapshot. Normalized means are the published means of animal-level ratios, not ratios reconstructed from group means.

## Checks and limitations

No independent printed total or percent relation in this table is available for a within-item numerical check. Shape and positivity checks are structural checks only.
Tables 1 and 2 are not numerically interchangeable. Separate cross-item checks and the primary Table 1 versus hemisphere-table sensitivity are stored downstream in the nonhuman analysis repository; no source values are corrected.
