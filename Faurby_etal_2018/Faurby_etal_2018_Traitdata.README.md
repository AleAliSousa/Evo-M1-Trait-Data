# Faurby_etal_2018_Traitdata

Faurby, S. et al. (2018) PHYLACINE 1.2: The Phylogenetic Atlas of Mammal Macroecology. Ecology 99(11):2626. https://doi.org/10.1002/ecy.2443.
Data: `Trait_data.csv`, Zenodo record 4954990 (copy of the untouched download = `Faurby_etal_2018_Traitdata_snapshot.csv`, verified byte-identical); metadata `PHYLACINE_1.2_Metadata.pdf`.
Expected Item name `Faurby_etal_2018_Traitdata`; Item encoded `10.1002%2Fecy.2443_Traitdata`.

5,831 mammal species (extant + extinct since the last interglacial); 24 published columns plus `species` (derived) and `source`.

## Ecology fields
`terrestrial`, `marine`, `freshwater`, `aerial` are binary, non-exclusive "significant amount of time" flags taken from IUCN 2016-3.
`life_habit_method`: Reported 4,293; Taxonomic 1,162 (every bat scored aerial); Imputed 376. Filter on it when treating flags as observed.

## Files
Snapshot, `Faurby_etal_2018_Traitdata.R`, `Faurby_etal_2018_Traitdata.csv`, `reference_tables/Faurby_etal_2018_Traitdata_definitions.csv`, `Faurby_etal_2018_Traitdata_registry_row.xlsx`, `PHYLACINE_1.2_Metadata.pdf`.
Species names are as printed (underscore replaced by a space in `species`); not reconciled to a key.
