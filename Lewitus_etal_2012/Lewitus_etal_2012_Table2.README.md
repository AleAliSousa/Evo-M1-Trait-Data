# Lewitus et al. 2012 - Table 2 (species by placental characterization)

Lewitus, Sherwood & Hof (2012). Cellular signatures in the primary visual cortex of phylogeny and placentation. Brain Struct Funct 217(2):531-547. doi:10.1007/s00429-011-0338-5

## Source -> snapshot
PDF p.6 (journal p.536). Three columns (Haemochorial 37, Endotheliochorial 25, Epitheliochorial 11 names), ragged; the snapshot keeps the column layout. The build script melts to long format (species, placental_type): 73 rows.

## Fidelity checks
- Union of the three columns = 72 distinct species = Table 1's 71 + Manis gigantea.
- *Crocuta crocuta* is printed in BOTH Haemochorial (last entry) and Endotheliochorial; kept in both rows, as printed. Owner ruling needed before using this classification (the species has one placental type).
- *Manis gigantea* (Epitheliochorial) is not in Table 1 (no V1 data listed).

## Caveats
Secondary classification (Mossman 1987 per Methods), not measured by the authors.

## Build
`Lewitus_etal_2012_Table2.R` -> `..._Table2.csv` (73 rows). RA side-by-side check pending.
