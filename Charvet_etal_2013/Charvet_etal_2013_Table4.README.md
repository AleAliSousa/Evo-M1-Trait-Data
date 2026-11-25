# Charvet et al. — Table 4: rostral and caudal neuron summaries

Charvet, C. J., Cahalane, D. J., & Finlay, B. L. *Systematic, cross-cortex variation in neuron numbers in rodents and primates*. DOI [10.1093/cercor/bht214](https://doi.org/10.1093/cercor/bht214). Online publication was 2013; the final issue was *Cerebral Cortex* 25(1):147–160 (2015). Source: `Charvet-2013-Systematic, Cross-Co.pdf`, PDF page 8, printed Table 4.

An AI assistant transcribed the six three-row species blocks on 2026-11-24 into `Charvet_etal_2013_Table4_snapshot.csv`, checking the strings against the rendered page. The snapshot preserves source order, blank repeated species cells, rostral and caudal mean (SE) strings, and each printed `Varies by` ratio. Run `Rscript --vanilla Charvet_etal_2013/Charvet_etal_2013_Table4.R` from the repository root. The reader reshapes to one row per species, splits means and SEs, and writes the analysis CSV and DOI-coded public TSV using the AddON item code. Values refer to neurons per mm² of cortical surface. Species labels remain as printed. Definitions and the paper's scientific names are in `reference_tables/`.

## Table checks and source anomalies

The reader checks 12 total-versus-layer-sum relations with a 0.5 neurons/mm² tolerance; all pass (largest absolute difference 0.30). It also checks 18 printed `Varies by` ratios against caudal mean divided by rostral mean with a 0.02 tolerance. Three source ratios disagree: Capuchin infragranular prints **1.23** versus calculated **1.2716**; Paca supragranular prints **3.09** versus **3.1364**; Paca infragranular prints **1.67** versus **0.5967** (approximately the reciprocal). The R run warns but keeps all printed ratios. Paca's caudal total SE prints `47 494`, exceeding its `39 521.35` mean; this is retained as 47,494 and flagged `caudal_se_exceeds_mean`. The unusual source spacing `96 68.87` for Paca's infragranular caudal mean is preserved in the snapshot and parsed as 9,668.87; the corresponding layer sum agrees with the total within 0.01.

Human visual signoff of the full snapshot remains pending. This is a table-derived item, so no figure replot applies.
