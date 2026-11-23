# Iwaniuk et al. 2001 — Table 4 (primates: play, relative brain and neocortex)

Iwaniuk AN, Nelson JE, Pellis SM (2001). *Do big-brained animals play more? Comparative analyses
of play and relative brain size in mammals.* J Comp Psychol 115(1):29–41.
doi:10.1037/0735-7036.115.1.29

Full table title: **"Table 4. Play Scores and Relative Brain and Neocortex Sizes for the Primates
Examined."** 64 species.

## Source → Snapshot
PDF (paywalled); Table 4 entered by hand into `Iwaniuk_etal_2001_Table4_snapshot.xlsx` (frozen).

## Data readable
`Iwaniuk_etal_2001_Table4.R` → `Iwaniuk_etal_2001_Table4.csv` (**use this**). Expands shorthand
species names to full binomials, forward-fills `Family`, and corrects one spelling
(*Galago sengalensis* → *Galago senegalensis*). Columns defined in
`reference_tables/Iwaniuk_etal_2001_Table4_definitions.csv`.

## Species note
`Species` holds binomials as printed (shorthand expanded, one spelling fixed); reconcile to
`_keys/Stephan/species_key.csv`. `Brain size` and `Neocortex size` are relative (residual)
measures, not absolute volumes; `Neocortex size` is `NA` where the paper gives no value.

Pipeline: Source → Snapshot ✅ → Data readable ✅ → Species note ✅ → Online database ✅
(`10.1037%2F0735-7036.115.1.29_Table4.tsv` in `__Public/comparative-data/`)
