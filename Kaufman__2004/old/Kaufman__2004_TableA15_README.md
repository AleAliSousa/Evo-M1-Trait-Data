# Kaufman (2004) — Table A15 dataset + comparison

## What this is

A tidy dataset built independently from the Kaufman (2004) dissertation's **Table A15,
"Species Means in Conscious Subjects,"** and an audit of that build against the manually
compiled tables already in this folder.

## Source

- **Primary:** `Kaufman__2004_dissertation.pdf`, Table A15, pages **169–176**
  (text extracted with `pdftotext -layout`).
- **Disambiguation only:** `Kaufman__2004_dissertation.xlsx`, sheets `Table 97`–`Table 104`
  (the digitized version of the same table), used to resolve cells the PDF rendered
  ambiguously.

Table A15 reports, for each genus × weighting × brain region × energetic measure, five
statistics: **N, Mean, SD, CV, and CV\*** (unbiased coefficient of variation).

- **Measures / units:** CMRgl (glucose) and CMRO2 (oxygen) in µmol/100 g/min; CBF (blood
  flow) in mL/100 g/min. The dissertation prints oxygen as "CMR02" (with a zero) in most
  places and "CMRO2" for Occipital Cortex — both normalized here to **CMRO2**.
- **Weightings:** `unweighted` (each study counts equally) and `weighted` (each individual
  counts equally).

## Files

| File | Description |
|------|-------------|
| `Kaufman__2004_A15_dataset_long.csv` | The built dataset. One row per species × weighting × region × measure; columns `N, Mean, SD, CV, CVstar`. 284 rows. |
| `Kaufman__2004_A15_comparison_long.csv` | Every statistic compared against each manual table (built value vs manual value, with match/mismatch status). |
| `Kaufman__2004_A15_comparison_mismatches.csv` | Only the rows that mismatch or are missing on one side. **This file is empty** (header only) — no discrepancies were found. |
| `build_kaufman.py` | Reproducible extraction: PDF → tidy dataset. |
| `compare_kaufman.py` | Reproducible audit against the two manual tables. |

## Dataset scope

12 genera (Homo, Macaca, Canis, Rattus, Mus, Lepus, Felis, Meriones, Ovis, Capra, Sus,
Equus) · 14 regions (Whole Brain, Cortex, Frontal/Parietal/Temporal/Auditory/Occipital/
Sensorimotor/Cingulate Cortex, Thalamus, Hippocampus, Basal Ganglia, Cerebellum, White
Matter) · 3 measures · 2 weightings · 5 statistics = **1,420 values**.

## Comparison result

The build was audited against **both** manual tables:

1. `comparison/.../Kaufman_energetics_weights.csv` (one row per species, both weightings)
2. `comparison/.../wholebrain_Kaufman2004.csv` + `partsbrain_Kaufman2004.csv`

| Manual table | Cells compared | Match | Mismatch | Built-only | Manual-only |
|--------------|---------------:|------:|---------:|-----------:|------------:|
| weights compilation | 1,420 | **1,420** | 0 | 0 | 0 |
| wholebrain + partsbrain | 1,420 | **1,420** | 0 | 0 | 0 |

The independent PDF extraction reproduces both manual tables **exactly**, and the two
manual tables are mutually consistent. (Verification: all manual columns parsed with none
dropped; a negative-control corruption of one value was correctly flagged as a mismatch.)

## Two OCR reconstructions (both confirmed against the manual tables)

- **Parietal Cortex · CMRgl · Homo · weighted — CV\*:** the PDF's bold rendering doubled
  the value so CV and CV\* (both 19.01) collapsed together. CV\* set to 19.01.
- **Cerebellum · CBF · Rattus · weighted:** one value was OCR-split ("15. 14") in the PDF,
  so this row was filled from the dissertation xlsx: N=14, Mean=112.57, SD=17.04, CV=15.14,
  CV\*=15.41.

Both reconstructed cells agree with the manual tables.
