# Lewitus et al. 2012 - Table 4 (observed and predicted glial cell density in V1, 8 primates)

Lewitus, Sherwood & Hof (2012). Cellular signatures in the primary visual cortex of phylogeny and placentation. Brain Struct Funct 217(2):531-547. doi:10.1007/s00429-011-0338-5

## Source -> snapshot
PDF p.9 (journal p.539). Clean born-digital text; transcribed from a render. 8 species, columns in printed order (two-level headers flattened with a colon).

## What is data
Only the **Observed value** (glial cell density in V1, cells/mm3, species mean; STEREOLOGY, Measure code ends .Stereology) is a measurement (role primary). Predicted value, % deviation and Within 95% PI come from the authors' regression of Old/New World monkeys (role derived; do not merge as observations).

## Fidelity checks
- % deviation (species mean) recomputed from observed/predicted: matches the printed integers for all 8 species when computed as (observed-predicted)/observed x100 (e.g. Homo 50.6 -> 51). The Methods text says the denominator is the predicted value; that would give ~102 for Homo. Table values kept as printed; flagged.
- Macaca fascicularis is an Old World monkey, i.e. part of the regression training set; its inclusion is as printed.

## Caveats
Per-species glial and neuronal densities for the rest of the ~71 species and glia:neuron ratios are not in the PDF text tables (only Fig. 3 group means, Fig. 4/5 plots, ESM). The ESM (now local; see `Lewitus_etal_2012_TableS1A`) holds only the 36 non-primate species, so the primate densities beyond these 8 are still not available locally.

## Build
`Lewitus_etal_2012_Table4.R` -> `..._Table4.csv` (8 rows). RA side-by-side check pending.
