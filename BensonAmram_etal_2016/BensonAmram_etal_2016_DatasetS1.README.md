# BensonAmram_etal_2016_DatasetS1

Benson-Amram, S., Dantzer, B., Stricker, G., Swanson, E. M., & Holekamp, K. E. (2016). Brain size predicts problem-solving ability in mammalian carnivores. Proceedings of the National Academy of Sciences, 113(9), 2532–2537. https://doi.org/10.1073/pnas.1505913113

Frozen workbook snapshot: byte-identical copy of the supplied `pnas.1505913113.sd01.xlsx` (SHA-256 `0d4f5aa6e38f144173d519a4d2c6a5a6a9f8b9d7d7a9fc721f2c3f4b77edafb1`). Reads `table s1 revised`. Includes all 495 trials, 140 individuals and 39 species. Keeps the published individual, zoo and trial identifiers; rows represent trials, not species means or separate brains. Dates are converted from Excel serials to ISO dates.

**Snapshot check (2026-11-27):** the snapshot is a direct copy of the supplied digital XLSX. `Rscript BensonAmram_etal_2016/BensonAmram_etal_2016_DatasetS1.R` rebuilt the 495-row analysis CSV with its prior SHA-256 `04b29ef0327a91fa306bc5d89a54610464f9308ce730edce21df52cd0a46d8bd`; the public TSV was unchanged. Independent human source signoff remains separate.

Puzzle-box success, latency, working time, behavioral diversity and dexterity are primary data. Diversity and dexterity were recorded only on first trials; source dashes remain missing rather than zero. The reward-retrieval field uses N to identify unretrieved rewards; missing cells are not converted to Yes. Original categorical responses are retained.

Brain/body values are explicitly credited to Finarelli and Flynn (2009), and regional endocast volumes to Swanson et al. (2012). These are secondary covariates repeated across trials. They must not enter a primary brain-volume merge from this item. Body kg converts to g; whole-brain mL converts to mm3; regional volumes already use mm3. The item references lookup preserves the cited origins. Group size is also a secondary species-level covariate.

Checks: 495/140/39 counts and unique individual–zoo–trial keys pass. The first-trial-only score check identifies one source exception: Dogo at WCSRC has diversity 8 and dexterity 9 on trial 3. Both values are retained and marked by `first_trial_score_exception`; see errata. The digital trial-level XLSX has `y` for **14 distinct Felidae individuals and 48 overall**. The PDF's Table S1 summary instead prints **15 and 49**; that printed aggregate is recorded as an error in the errata file, with **14 and 48** as the correction. The trial-level responses remain as supplied. The original XLSX is digital; no transcription visual-check date applies. This adds an observation-level cognition dataset without imposing an unrequested species aggregation or statistical model.

Built by Codex on 2026-10-25. Rebuild with `Rscript BensonAmram_etal_2016_DatasetS1.R` from any directory. The script reads only the frozen source and live registry; no source download or manual output editing is required. Species labels remain as published; any later harmonisation belongs in the collection-scoped species key.

<!-- errata:begin -->
## Errata

Generated from `reference_tables/BensonAmram_etal_2016_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| BensonAmram_etal_2016-E001 | behavioral_diversity | Dataset S1: Dogo, WCSRC, trial 3; footnote # | 8 |  | publication_ambiguity |  | confirmed | Workbook contains this score on trial 3 despite footnote saying first trial only. | Preserve source value and flag first_trial_score_exception; no inferred reassignment to trial 1. |
| BensonAmram_etal_2016-E002 | dexterity_score | Dataset S1: Dogo, WCSRC, trial 3; footnote # | 9 |  | publication_ambiguity |  | confirmed | Workbook contains this score on trial 3 despite footnote saying first trial only. | Preserve source value and flag first_trial_score_exception; no inferred reassignment to trial 1. |
| BensonAmram_etal_2016-E003 | successful_opening_box | pnas.201505913si.pdf, Table S1, PDF p. 4: Felidae / Sum or mean | 15 / 49 | 14 / 48 | publication_error | 14 / 48 | confirmed | The supplied digital Dataset S1 XLSX has 14 distinct Felidae individuals with a successful trial and 48 overall; its 495 trials and 140 tested individuals match the printed summary. The PDF prints 15 and 49 successful individuals. | Correction applies to the printed aggregate only; retain all trial-level responses as supplied. |

3 recorded, 0 open (proposed), 3 confirmed, 0 withdrawn.
<!-- errata:end -->
