# Semendeferi et al. 2001 — Table 2 (brain + area 10 volumes)

Semendeferi K, Armstrong E, Schleicher A, Zilles K, Van Hoesen GW (2001). *Prefrontal Cortex in
Humans and Apes: A Comparative Study of Area 10.* Am J Phys Anthropol 114(3):224-241.

Full table title (for `__ReadMe.xlsx`): **"Table 2. Volumes of the brain and area 10 in all hominoids"**

## Source -> Snapshot
PDF p. 11 (text layer, clean). `Semendeferi_etal_2001_Table2_snapshot.csv` faithful (mm3, thousands
commas). Footnotes: brain = total brain; area 10 = right hemisphere; one individual/species;
gorilla area 10 = cortex of the frontal pole.

## Data readable
`Semendeferi_etal_2001_Table2.R` -> `Semendeferi_etal_2001_Table2.csv` (use this). `area10_volume_mm3`
= right-hemisphere frontopolar area 10.

## Provenance
Primary cytoarchitectonic volumetry, **C. & O. Vogt Institute (Zilles), Duesseldorf = Stephan/Zilles
collection** (brain volumes identical to the 1998 area-13 paper -> same specimens). Prefrontal subregion
(frontal pole area 10). n = 1 per species. Neuron/GLI tables -> `__merging_cellcounts`.

## Species note
Binomials from common names; reconcile to `_keys/Stephan/species_key.csv`.

Pipeline: Source -> Snapshot OK -> Data readable OK -> Species note (in progress) -> Online database
