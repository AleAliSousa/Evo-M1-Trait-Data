# Iwaniuk et al. 2001 — Table 3 (marsupials: play, EQ and neocortex)

Iwaniuk AN, Nelson JE, Pellis SM (2001). *Do big-brained animals play more? Comparative analyses
of play and relative brain size in mammals.* J Comp Psychol 115(1):29–41.
doi:10.1037/0735-7036.115.1.29

Full table title: **"Table 3. The Play Scores and Relative Brain (EQ) and Neocortex Sizes for the
Marsupials Examined."** 58 species.

## Source → Snapshot
PDF (paywalled); Table 3 entered by hand into `Iwaniuk_etal_2001_Table3_snapshot.xlsx` (frozen).

## Data readable
`Iwaniuk_etal_2001_Table3.R` → `Iwaniuk_etal_2001_Table3.csv` (**use this**). Forward-fills
`Family` to every row and splits the combined `2/3C` play-frequency codes into numeric
`Play frequency Minimum` / `Maximum`. Columns defined in
`reference_tables/Iwaniuk_etal_2001_Table3_definitions.csv`.

## Species note
`Species` holds binomials as printed; reconcile to `_keys/Stephan/species_key.csv`. `EQ` and
`Neocortex` are relative-size indices **as tabulated in the source** — confirm their scaling
against the paper before combining with brain/neocortex data from other tables.

Pipeline: Source → Snapshot ✅ → Data readable ✅ → Species note ✅ → Online database ✅
(`10.1037%2F0735-7036.115.1.29_Table3.tsv` in `__Public/comparative-data/`)
