# Semendeferi et al. 1998 — Table 2 (brain + area 13 volumes)

Semendeferi K, Armstrong E, Schleicher A, Zilles K, Van Hoesen GW (1998). *Limbic Frontal Cortex in
Hominoids: A Comparative Study of Area 13.* Am J Phys Anthropol 106(2):129-155.

Full table title (for `__ReadMe.xlsx`): **"Table 2. Volumes of the brain and area 13 in all hominoids"**

## Source -> Snapshot
PDF p. 15 (text layer, clean). `Semendeferi_etal_1998_Table2_snapshot.csv` faithful to print
(brain volumes with thousands commas; mm3). Footnotes: brain = total brain structure; area 13 =
right hemisphere; one individual per species.

## Data readable
`Semendeferi_etal_1998_Table2.R` -> `Semendeferi_etal_1998_Table2.csv` (use this): commas stripped,
species -> binomial. `area13_volume_mm3` = right-hemisphere orbitofrontal area 13.

## Provenance
Primary cytoarchitectonic volumetry from the **C. & O. Vogt Institute (Zilles/Schleicher), Duesseldorf
= the Stephan/Zilles collection** -> same brains as Stephan/Frahm (brain volumes match). Maps to a
prefrontal subregion (orbitofrontal area 13); not a whole Heiss lobe. n = 1 per species (6 hominoids).
Neuron/GLI tables (paper Tables 4-5) are a cell-count source for `__merging_cellcounts`.

## Species note
Binomials assigned from common names; reconcile to `_keys/Stephan/species_key.csv`.

Pipeline: Source -> Snapshot OK -> Data readable OK -> Species note (in progress) -> Online database
