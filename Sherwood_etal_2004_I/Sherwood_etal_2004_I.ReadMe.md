# Sherwood et al. 2004 (I) - Tables 4 & 5 (M1 GLI cytoarchitecture)
Sherwood CC, Holloway RL, Gannon PJ, Semendeferi K, Erwin JM, Zilles K, Hof PR (2004).
*Neuroanatomical basis of facial motor control in primates* / M1 cytoarchitecture series. Brain Behav Evol (doi:10.1159/000075672).

## NOT a volume dataset
Tables 4 & 5 report **grey-level index (GLI)** cytoarchitecture of primary motor cortex (M1):
Table 4 = mean GLI per cortical layer (II, III, V, VI) + cortical mean; Table 5 = 10 GLI-profile
feature vectors (moment descriptors of the depth profile). There are **no brain-structure volumes**,
so this folder is **not part of the volume merge** (`__merging_volumes/`). Built to the 4-file
convention as a standalone cytoarchitecture dataset.

## Source -> Snapshot
`Sherwood_etal_2004_l.xlsx` sheets `publishedTable4`/`publishedTable5` frozen as
`..._Table4_snapshot.csv` / `..._Table5_snapshot.csv` (faithful to print; Table 5 is transposed,
species in columns, as printed).

## Data readable
`Sherwood_etal_2004_I.R` -> `Sherwood_etal_2004_I_Table4.csv` and `..._Table5.csv` (tidy, species in
rows). `GLI_M1.csv` is a pre-existing convenience file joining Table 4 (layer GLI) and Table 5
(profile moments) by species.

## Note on __ReadMe.xlsx
`__ReadMe.xlsx` already lists `Sherwood_etal_2004_I_Table4`/`_Table5` (encoding 10.1159%2F000075672).
Those rows are for the GLI/cytoarchitecture data type, not the volume merge.

Pipeline: Source -> Snapshot OK -> Data readable OK -> standalone cytoarchitecture dataset (not in volume merge).
