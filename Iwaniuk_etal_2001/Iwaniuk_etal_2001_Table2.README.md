# Iwaniuk et al. 2001 — Table 2 (muroid rodents: play scores and relative brain size)

Iwaniuk AN, Nelson JE, Pellis SM (2001). *Do big-brained animals play more? Comparative analyses
of play and relative brain size in mammals.* J Comp Psychol 115(1):29–41.
doi:10.1037/0735-7036.115.1.29

Full table title: **"Table 2. The Five Play Scores and Relative Brain Sizes for the Species of
Muroid Rodents Examined."** 23 species.

## Source → Snapshot
PDF (paywalled); Table 2 entered by hand into `Iwaniuk_etal_2001_Table2_snapshot.xlsx` (frozen,
with a title block and a footnote row).

## Data readable
`Iwaniuk_etal_2001_Table2.R` → `Iwaniuk_etal_2001_Table2.csv` (**use this**). Sets the real header
row, drops the title/footnote rows, prefixes the five play measures with `Play scores_`, expands
shorthand species names, and parses numbers. Columns defined in
`reference_tables/Iwaniuk_etal_2001_Table2_definitions.csv`.

## Species note
`Species` holds binomials expanded from the source shorthand (e.g. *M. montanus* →
*Microtus montanus*); reconcile to `_keys/Stephan/species_key.csv`. `Brain Size` is a relative
(residual) measure, not an absolute volume.

Pipeline: Source → Snapshot ✅ → Data readable ✅ → Species note ✅ → Online database ✅
(`10.1037%2F0735-7036.115.1.29_Table2.tsv` in `__Public/comparative-data/`)
