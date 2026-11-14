# Soria_etal_2021_Traitdatareported

Soria, C. D. et al. (2021) COMBINE: a coalesced mammal database of intrinsic and extrinsic traits. Ecology 102(6):e03344. https://doi.org/10.1002/ecy.3344.
Data: `trait_data_reported.csv` (figshare 13028255, file 27703263), observed (non-imputed) values only; copied untouched to `Soria_etal_2021_Traitdatareported_snapshot.csv`.
Expected Item name `Soria_etal_2021_Traitdatareported`; Item encoded `10.1002%2Fecy.3344_Traitdatareported`.

6,263 rows, 60 published columns plus `source`. `species` = `iucn2020_binomial`; published `species` (epithet) renamed `species_epithet`.

## Cautions
- One row per (IUCN binomial, PHYLACINE binomial) pair: an IUCN binomial can occur on several rows with identical trait values. De-duplicate on `species` before pooling, or values are double-counted.
- Habitat flags (`freshwater`, `marine`, `terrestrial_non-volant`, `terrestrial_volant`) are non-exclusive and NA for 333 species; do not treat NA as 0.
- COMBINE also publishes `trait_data_imputed.csv` and `trait_data_sources.csv`; not built here.
- Most column definitions are not transcribed (see data paper); habitat, taxonomy and foraging-stratum columns are defined in the definitions file.
