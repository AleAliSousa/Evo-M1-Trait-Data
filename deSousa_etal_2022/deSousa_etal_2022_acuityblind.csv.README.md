# de Sousa et al. 2022 — acuityblind.csv (mammalian visual acuity incl. blind species)

de Sousa AA, Todorov OS, Proulx MJ (2022). *A natural history of vertebrate vision loss: Insight
from mammalian vision for human visual function.* Neurosci Biobehav Rev 134:104550.
doi:10.1016/j.neubiorev.2022.104550.

Registry (`__ReadMe.xlsx`): Item **`deSousa_etal_2022_acuityblind.csv`**, encoded
`10.1016%2Fj.neubiorev.2022.104550_acuityblind.csv`. Progress stage / Snapshot cells to set:
Snapshot = "none - digital-native (acuityblind.csv; SHA-256
33ca27b69ae20b99950f762c16b37b84e98867d04a9b1659e2d7cb7dd7359baa)".

## What the data are
Visual acuity (cpd) for **120 mammal species**: 114 with estimates (behavioral tests, or
anatomical from peak ganglion-cell density when behavioral unavailable) + **6 subcutaneous-eyed
blind species coded 0 cpd** (Eremitalpa granti, Neurotrichus gibbsii, Notoryctes typhlops,
Nannospalax ehrenbergi, Talpa caeca, Talpa occidentalis). `MT` codes decoded: A = anatomical
(n=63), B = behavioral (n=51), C = blind-coded-0 (n=6) — **verified against SI Table 2
(mmc4.xlsx) per-order counts (exact match) and the paper text** (VA range 0–64.28 cpd, chimp
64.28, human 64 ✓).

## Source → Data readable (digital-native; no snapshot file)
`acuityblind.csv` is the paper's own analysis dataset (Alexandra is first author; SI File 1
points to https://doi.org/10.17870/bathspa.10275875). Frozen as-is with the SHA-256 above.
`deSousa_etal_2022_acuityblind.csv.R` → `deSousa_etal_2022_acuityblind.csv.csv` (**use this**;
double extension is the pipeline's `<Item name>.csv` convention with an item key that itself ends
in `.csv`). Columns in `reference_tables/deSousa_etal_2022_acuityblind.csv_definitions.csv`.
Built offline 2026-08-31 (Python mirror; no R in sandbox) — **re-run the .R in RStudio to confirm.**

## Data role — SECONDARY compilation
VA values are compiled from primaries (Veilleux & Kirk 2014, Kirk & Kay 2004, Heffner & Heffner
papers, etc.). **`Veilleux_Kirk_2014_SupplementalTable1` (built same day) is one of those
primaries and overlaps heavily**: 78 shared species, values identical except three rows this
dataset rounds to 2 dp (Desmodus rotundus 0.625→0.63, Artibeus jamaicensis and Phyllostomus
hastatus 0.167→0.17) — never treat the two items as independent; prefer the primary. This item's
unique contributions are the blind-coded-0 rows and the harmonized 120-species analysis set.
The PanTHERIA covariate columns (X*-coded) in the raw file are PanTHERIA's data (Jones et al.
2008), kept for reproducibility of the paper's analyses only — **never ingest them from here.**

Pipeline: Source (digital-native) ✅ → Data readable ✅ → Registry stage cells ⬜ → R rerun ⬜ → Merge ⬜
