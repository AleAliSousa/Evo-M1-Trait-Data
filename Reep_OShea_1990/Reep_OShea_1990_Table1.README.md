# Reep & O'Shea 1990 — Table 1 (percent volume of the major brain regions in 4 Florida manatees)

Reep RL, O'Shea TJ (1990). *Regional brain morphometry and lissencephaly in the Sirenia.* Brain Behav Evol 35(4):185-194. doi:10.1159/000115866

## Source -> snapshot
`Reep_OShea_1990.pdf` (EndNote 2487; scanned, no text layer). Table 1 is on PDF p.5 (journal p.189). `..._Table1_snapshot.csv` is a **transcribed snapshot** (parameters as rows, specimens M-412, M-433, M-450, M-387 and printed Mean as columns; the "Specimen" spanning header is not a column). The CSV is transposed to one row per specimen (+ Mean row, 5 rows).

## Fidelity checks (build script output)
- cortex + basal ganglia/septum + amygdala = printed telencephalon total in all 5 columns (difference 0).
- Thalamus + hypothalamus = printed diencephalon total in all columns.
- Telencephalon + diencephalon + mesencephalon + pons + cerebellum + medulla = 99.88-99.97 % for each specimen (rounding / unmeasured remainder).
- Cortex as % of telencephalon recomputed: 89.46, 88.23, 90.32 (printed 90.31), 90.23: all agree to rounding.
- Mean column vs mean of the 4 specimens: agrees within 0.03 (cortex 63.84 vs 63.83; cerebellum 13.88 vs 13.85; likely unrounded means).

## Caveats
- Species is not printed in the table (caption: "Florida manatees"); `species` = *Trichechus manatus* from the Abstract/Methods (4 West Indian manatees). Individuals, not species means; M-387 is the best-preserved (perfused) brain with 49 sections, M-412/M-433/M-450 only 7-17 sections.
- Volume fractions are of fixed, embedded brain; shrinkage was not corrected for the percentages.
- Mean row has no brain weight (blank as printed).

## Lewitus et al. 2014 (ref 83)
Comparable quantities: `brain_weight_g` (392, 346, 455, 385 g), `pct_telencephalon_cortex` (neocortex fraction) and `cortex_pct_of_telencephalon`; Table 3 GI (1.06) is the lissencephaly measure.

## Build
`Reep_OShea_1990_Table1.R` -> `..._Table1.csv`. TSV skipped until the registry row is pasted into `__ReadMe.xlsx`. RA side-by-side check pending.
