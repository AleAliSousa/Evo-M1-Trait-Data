# Lázaro et al. 2021 — Table 3

“Geographic patterns in seasonal changes of body mass, skull, and brain size of common shrews,” *Ecology and Evolution* 11:2431–2448, DOI 10.1002/ece3.7238. The exact open-access PDF is in this folder. Table 3 is rotated on PDF page 11 (printed p. 2441). The nine source rows were manually frozen from the rendered table on 2026-11-24, retaining its three measurement blocks, population order, each stage's n/mean ± SE/period, and the printed change percentages. `BCH` is braincase height; corrected brain mass is printed in g/mm.

Run from repository root: `Rscript --vanilla Lázaro_etal_2021/Lázaro_etal_2021_Table3.R`. The reader uses only the frozen snapshot and writes analysis CSV and DOI-coded public TSV via `__ReadMeAddON.xlsx`. It compares printed change percentages with the displayed stage means and flags the one inconsistent row: Gugny braincase height prints 6.46 → 5.53 → 6.09 mm and −12.2% / +7.4%, whereas those means imply about −14.4% / +10.1%. The source values are retained without correction. The means and printed percentages are retained, with no recomputation replacing source values. Table 3 summarizes populations and seasons from data also represented in the two raw-data items; avoid treating the summary and raw rows as independent evidence. Human visual signoff remains pending. No figure-derived data were extracted.

Layout audit (2026-11-27): Compared the landscape Table 3 on PDF p. 11.
The snapshot now has the printed 12-column arrangement: one column for
measure-heading and population rows, three age-stage groups of n/mean ± SE/
period, and two change columns. It keeps the caption and BCH note. The R
reader propagates each measure heading to its population rows. The nine-row
analysis CSV rebuilt cell-identically, including the source's inconsistent
Gugny percentages noted above. Human source signoff remains independent.
