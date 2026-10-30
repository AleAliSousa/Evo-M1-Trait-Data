# Sherwood et al. 2005 - Table 1 (medulla + orofacial motor nuclei volumes)
Sherwood CC, Holloway RL, Erwin JM, Schleicher A, Zilles K, Hof PR (2005).
*Cortical orofacial motor representation in Old World monkeys, great apes, and humans.* J Hum Evol 48(1):45-84 (doi:10.1016/j.jhevol.2004.10.003).
Full table title (for `__ReadMe.xlsx`): **"Table 1. Species means and standard deviations for volumes of medulla and orofacial motor nuclei (left side only) (mm3)"**

## Source -> Snapshot
PDF p.6 (text layer, clean). `Sherwood_etal_2005_Table1_snapshot.csv` = 47 species x N + Mean/SD for
Medulla, Vmo, VII, XII, in the printed column order (Medulla, Vmo, VII, XII). All volumes in **mm3**.
Values cross-checked against the page-6 text layer; species de-ligatured (e.g. "ru?caudatus" ->
"ruficaudatus") to the published binomials.

## Data readable
`Sherwood_etal_2005_Table1.R` -> `Sherwood_etal_2005_Table1.csv`/`.tsv` (use the csv): snake_case
columns `medulla_oblongata_mm3`, `trigeminal_motor_Vmo_mm3`, `facial_VII_mm3`, `hypoglossal_XII_mm3`
(+ `_SD`, `N`). The script also writes `__Public/comparative-data/Sherwood_etal_2005_Table1.tsv` for
the volume merge.

## Laterality (IMPORTANT)
Paper: *"Only one side was analyzed because previous studies have shown that cranial nerve motor nuclei
do not exhibit morphometric asymmetries."* So **Vmo, VII, XII are LEFT side only**; they map to
`*_left_Vol.mm3` terms and are registered in `__merging_volumes/laterality_known.csv`. The **medulla
oblongata** is the whole (midline) structure and maps to the existing `Medulla_oblongata_Vol.mm3`
(shared with Stephan 1981 / Zilles & Rehkamper 1988 -> independent cross-validation of medulla size).

## Merge
- team `Sherwood` (independent Tier-2 series). token `Sherwood_2005` (species_key already populated).
- term map: `__merging_volumes/standardized_term_by_reference/Sherwood_etal_2005_Table1_standardized_terms.csv`.
- encoding: `__ReadMe.xlsx` Item `Sherwood_etal_2005_Table1` -> `10.1016%2Fj.jhevol.2004.10.003_Table1`
  (already registered); the build script writes that DOI-coded TSV into `__Public/comparative-data/`.

Pipeline: Source -> Snapshot OK -> Data readable OK -> Species harmonized (token Sherwood_2005) -> In merge.

## Cited by DeCasien and Higham 2019
DeCasien and Higham 2019 cite this paper as a source of brain volume data.
But Sherwood et al do not give brain volume for any species in tables, and say they used brain volume 
from Stephan et al 1981 "for standardization" (not sure what that is, since they already mention correction 
factors), but do not give them in the paper.  In text they state brain volumes only for Pongo pygmaeus and Pan paniscus.
