# ManyPrimates 2022 — species_predictors.xlsx (vocal repertoire size)

ManyPrimates et al. (2022). *The evolution of primate short-term memory.* Animal Behavior and
Cognition, 9(4). doi:10.26451/abc.09.04.06.2022

Species-predictor compilation used by the ManyPrimates short-term-memory study, **41 primate
species**. The trait built here is **vocal repertoire size = number of vocalization types**, from
the column `vocal_repertoire (# vocalization types)` on the "Compilation for paper" sheet.

## This is "number of vocalizations" data
Tagged `behavioural (vocal repertoire)` in `__ReadMe.xlsx`. Each species carries its own primary
reference (`vocal_repertoire_source`) — a mix of species-specific bioacoustic studies, Dunn &
Smaers 2018, McComb & Semple 2005, and other compilations. 39 of 41 species have a value
(*Cercopithecus hamlyni* and *Allenopithecus nigroviridis* are blank).

Built as a **separate trait** from Schniter & Peñaherrera-Aguirre 2026 (`vocal_repertoire_schniter`)
at the curator's request; the two overlap in 16 species and both draw partly on McComb & Semple
2005, but are not merged.

## Source → Snapshot
The source `species_predictors.xlsx` (sheet "Compilation for paper") holds many ecological/
life-history predictors (colour vision, group size, home range, diet, body size, ...). Those are
sourced independently elsewhere in the repo and are **not** extracted here. Only the vocal-repertoire
block — species identifiers + `vocal_repertoire (# vocalization types)` + its Source + Comments —
was frozen into `ManyPrimates__2022_speciespredictors_snapshot.xlsx` (sheet
`speciespredictors_snap`): row 1 = title, row 2 = header, values verbatim.

## Data readable
`ManyPrimates__2022_speciespredictors.R` → `ManyPrimates__2022_speciespredictors.csv`
(**use this**) and the DOI-named TSV `10.26451%2Fabc.09.04.06.2022_speciespredictors.tsv` in
`__Public/comparative-data/`. Columns defined in
`reference_tables/ManyPrimates__2022_speciespredictors_definitions.csv`.

Note: the registry Item name for this row is the raw path `data/speciespredictors.xlsx`; the build
uses the filesystem-safe DOI-coded TSV name above, and the Shiny `source_manifest` resolves the
citation from the DOI prefix.

## Species note
`Species` = `species_latin` with underscores replaced by spaces. Reconcile to
`_keys/Stephan/species_key.csv`. 22 of 41 species resolve to species already in the brain-data
universe (`_keys/species_reference.csv`).

## Shiny app
Folded in as a correlatable trait via `____EvoM1_TraitTable/vocal_repertoire_manyprimates.xlsx`
(built by `EvoM1_read_vocal_manyprimates.R`) and registered in `__ShinyApp/build_data.R`.

Pipeline: Source → Snapshot ✅ → Data readable ✅ → Species note ✅ → TraitTable ✅ →
Online database ☐ (run the R script with the full repo mounted to write the DOI-named TSV).
