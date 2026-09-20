## Schenker et al. 2005 — Table 1 (species mean volumes)

Schenker NM, Desgouttes A-M, Semendeferi K (2005). *Neural connectivity and cortical
substrates of cognition in hominoids.* Journal of Human Evolution 49(5):547–569.
doi:10.1016/j.jhevol.2005.06.004.

Registry (`__ReadMe.xlsx`): Item name **`Schenker_etal_2005_Table1`**, encoded
`10.1016%2Fj.jhevol.2005.06.004_Table1`.

### What the data are

Table 1 reports **species-level mean ± S.E.** volumes (cm³, both hemispheres combined) for
10 bilateral frontal- and temporal-lobe regions of interest, across **6 species**: *Homo
sapiens* (n=10), *Pan troglodytes* (n=5), *Pan paniscus* (n=3), *Gorilla gorilla* (n=2),
*Pongo pygmaeus* (n=4), *Hylobates lar* (n=3). The number of individuals per species is
printed in parentheses after the species name and is preserved as `n_individuals`. This is
a species-mean table, not an individual-specimen table — see `Appendix1` for the individual
records underlying these means.

### Source → Snapshot → Data readable

Printed Table 1 → **`Schenker_etal_2005_Table1_snapshot.xlsx`** (sheet `Table1`) →
`Schenker_etal_2005_Table1.R` → **`Schenker_etal_2005_Table1.csv`** (use this) + the public
TSV `__Public/comparative-data/10.1016%2Fj.jhevol.2005.06.004_Table1.tsv`. Columns:
`reference_tables/Schenker_etal_2005_definitions.csv` — one dictionary for the whole paper
(bare, no table number), shared with `Appendix1` since both tables define the same
anatomical/measure vocabulary.

### Build transformations

- Parses the printed `"mean ± S.E."` cells into separate `<region>_mean_cm3` /
  `<region>_SE_cm3` columns, one pair per region, mean immediately preceding its S.E.
- Parses `"Species (n)"` into `Species` and `n_individuals`.
- Values are stored as printed, in cm³.

### QA status

- Source: printed PDF table (p. 3038 of the typeset PDF, "Table 1 Mean volumes for each
  region of interest").
- Frozen snapshot: created; not yet visually re-checked side-by-side against the PDF by a
  second reviewer.
- Expected analysis rows: 6 species.
- Observation level: species mean.
- Cross-check: every value in the built CSV was checked cell-by-cell against the printed
  PDF table and matches exactly, including the outlying *Gorilla gorilla* temporal-core S.E.
  of 0.02 cm³.
