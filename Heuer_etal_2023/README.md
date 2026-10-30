# Heuer et al. 2023 — cerebellar folding in mammals

Built from the authors' open release for **56 mammal species**. The author repository was frozen on
2026-08-15 at commit `8b603fb0bf711ece57ddb658d39d3fd5e01ff20e` (the same revision archived by
Software Heritage in the article):

> Heuer K, Traut N, de Sousa AA, Valk SL, Clavel J, Toro R. (2023). Diversity and
> evolution of cerebellar folding in mammals. *eLife* 12:e85907.
> https://doi.org/10.7554/eLife.85907

## Frozen evidence

- `Heuer_etal_2023_eLife85907.pdf`: version-of-record article (CC BY).
- `elife-85907-supp1-v2.xlsx`: journal species list.
- `source_data/data.csv`: untouched final phenotype table from the authors' repository.
- `source_data/01_...` through `05_...`: component measurements.
- `source_data/01_cb_data.csv`, `02_scale.csv`, `rosetta.csv`, and `load_data.R`: raw lookup and
  assembly files needed to audit the final columns.
- `LICENSE.author-repository.txt`: Apache-2.0 license for the author repository.

The frozen final phenotype `source_data/data.csv` has SHA-256
`55f462a7374dec84eed3e745b42292df9ccc6435dc7c4ef29b554df768fa4ece`.

`Heuer_etal_2023_Data.R` is the canonical build. It retains the released log fields and also
back-transforms the seven directly measured neuroanatomical variables to the millimetre units
defined in article Table 1. The two weight fields are *not* back-transformed: the upstream
`rosetta.csv` calls them `LogBodyWeight`/`LogBrainWeight`, while `load_data.R` renames them with a
`Log10` prefix without applying `log10()`. Keeping the values verbatim avoids guessing the base.

Outputs:

- `Heuer_etal_2023_Data.csv`
- `../__Public/comparative-data/10.7554%2FeLife.85907_Data.tsv`
- `../__merging_cerebellar_folding/{cerebellar_folding_long,cerebellar_folding_wide}.csv`

The merge treats the seven direct measurements as one primary team. It never pools them with
Ashwell 2020's PSA/ESA foliation index or with neocortical gyrification: those are different
measurement procedures. The Shiny app loads this as its own **Cerebellar folding** dataset.

## Registry status

`Heuer_etal_2023_Data` is registered in `__ReadMe.xlsx` with the stable DOI-coded public filename,
and the Shiny source manifest includes the 56-species table.
