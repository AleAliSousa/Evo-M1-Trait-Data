# Butti et al. 2009 — Table 1 (brain weight, body weight, EQ; 4 cetaceans)
Butti C, Sherwood CC, Hakeem AY, Allman JM, Hof PR (2009). *Total number and volume of Von Economo neurons in the cerebral cortex of cetaceans.* J Comp Neurol 515(2):243-259. doi:10.1002/cne.22055. PMID 19412956.
Full title (`__ReadMe.xlsx`): **"Table 1. Average Values of Brain Weight, Body Weight, and EQ for the Analyzed Species"**

## Source->Snapshot
`..._Table1_snapshot.csv`: 4 rows as printed, values verbatim including the thousands commas. Hand transcription — the paper is not open access and has no PMC copy, so there is nothing to scrape. Typed by Claude (AI assistant) on 10 September 2026 from page images supplied by M. Windley, and checked as below.

## Data readable
`..._Table1.R` -> `..._Table1.csv`/`.tsv` (use this): 4 rows, one per species. Brain weight converted to mg (the project unit) with the printed g kept alongside; body weight is already in g. Species harmonized via `_keys/Hof/species_key.csv`.

## SECONDARY DATA — do not merge
The footnote reads: *"Brain weight and body weight were unavailable for most of the specimens in this study. These values were taken from Marino et al. (2004) and Hof et al. (2005)."* None of this was measured here. `Data role` should be **secondary** in `__ReadMe.xlsx`, and the item kept out of the merges — otherwise four cetacean brain and body weights enter the database under Butti's name when they belong to Marino and Hof.

## The EQ checks the transcription
The paper does not print its formula, but `brain_g / (0.12 × body_g^0.67)` reproduces all four printed values to two decimal places:

| | recomputed | printed |
|---|---|---|
| *T. truncatus* | 4.1363 | 4.14 |
| *G. griseus* | 4.0090 | 4.01 |
| *D. leucas* | 2.2449 | 2.24 |
| *M. novaeangliae* | 0.4361 | 0.44 |

Four out of four is not coincidence, so the formula is identified and the build asserts it. Recorded as a check on the transcription, **not** as the paper's own statement of method. EQ itself is an index, carried with `role = note` and excluded from merging.

## Comparisons
None. The values are secondary; any audit belongs against Marino et al. (2004) and Hof et al. (2005) directly.

Pipeline: Source->Snapshot OK->Data readable OK->Species harmonized->Online database
