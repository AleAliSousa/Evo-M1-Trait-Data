# Caspar et al. 2022 — Supplementary File 3 (ecology, endocranial volume, tool use)

Caspar KR, Pallasdies F, Mader L, Sartorelli H, Begall S (2022). *The evolution and biological
correlates of hand preferences in anthropoid primates.* eLife 11:e77875. doi:10.7554/eLife.77875

The species-level predictor table behind the Table 1 handedness analysis: ecology, female
endocranial volume, and habitual tool use for the 38 anthropoid species (with sources).

## Source → Snapshot
Downloaded from the eLife article as `elife-77875-supp3-v1.xlsx` — this file **is** the frozen
snapshot (one sheet, 38 species). The header carries two `Reference` and two `Notes` columns
(one pair for endocranial volume, one for tool use).

## Data readable
`Caspar_etal_2022_Supplementaryfile3.R` → `Caspar_etal_2022_Supplementaryfile3.csv` (**use this**).
Reads the sheet by column position (because of the duplicate headers), gives the columns unique
names, parses the endocranial volume to numeric, and turns `N.A.`/blanks into `NA`. Columns defined
in `reference_tables/Caspar_etal_2022_Supplementaryfile3_definitions.csv`.

## Species note
`Species` holds the binomials as printed; a few are pooled labels (`Cercopithecus diana/roloway`,
`Pongo sp.`) and `name_in_tree` sometimes differs from `Species` (e.g. `Cebus_apella` for *Sapajus
apella*). The `female_endocranial_volume_ml` values (mostly Powell et al. 2017) may overlap the
repo's volume merge — check before combining. Reconcile to `_keys/Stephan/species_key.csv`.

Pipeline: Source → Snapshot ✅ → Data readable ✅ → Species note ✅ → Online database ✅
(`10.7554%2FeLife.77875_SupplementaryData3.tsv` in `__Public/comparative-data/`)
