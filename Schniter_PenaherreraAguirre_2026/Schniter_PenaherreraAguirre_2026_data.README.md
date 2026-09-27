# Schniter & Peñaherrera-Aguirre 2026 — Zenodo data (vocal repertoire size)

Schniter E, Peñaherrera-Aguirre M (2026). *Evolution of primate vocal repertoires: vocal systems
as embodied capital for mediating within-group conflict.* Primates.
doi:10.1007/s10329-026-01271-2

Species-level dataset (Zenodo, April 2026) for **42 primate species**. The trait of interest here
is **vocal repertoire size = the number of distinct vocalization types** a species produces.

## This is "number of vocalizations" data
Tagged `behavioural (vocal repertoire)` in `__ReadMe.xlsx`. Two repertoire columns are carried:

- `vocal_repertoire_size_MS2005` — the original values compiled by **McComb & Semple (2005)**.
- `vocal_repertoire_size_updated` — the paper's **contemporary update**; where a newer bioacoustic
  study was available the value was revised and its reference recorded in
  `repertoire_update_reference` (otherwise the value equals the MS2005 value).

This is the project's second vocal-repertoire count source, alongside **ManyPrimates 2022**
(`ManyPrimates__2022_speciespredictors`), which is built as a separate trait (both draw partly on
McComb & Semple 2005; kept separate at the curator's request, not merged).

## Source → Snapshot
Data live in the Zenodo `data` sheet of `ZenodoData_April2026.xlsx`. That sheet was frozen verbatim
(all 19 columns, 42 species) into `Schniter_Penaherrera-Aguirre_2026_data_snapshot.xlsx`
(sheet `data_snapshot`): row 1 = title, row 2 = header, values as distributed. The sheet also holds
body mass, longevity, endocranial volume, group size, conflict score and gut lengths — those are
kept in the snapshot for provenance but only the repertoire columns are built here.

## Data readable
`Schniter_Penaherrera-Aguirre_2026_data.R` → `Schniter_Penaherrera-Aguirre_2026_data.csv`
(**use this**) and the DOI-named TSV `10.1007%2Fs10329-026-01271-2_data.tsv` in
`__Public/comparative-data/`. Columns defined in
`reference_tables/Schniter_Penaherrera-Aguirre_2026_data_definitions.csv`.

## Species note
`Species` holds the contemporary binomial as printed; `Species_MS` keeps the McComb & Semple 2005
name and `Species_alt` any contemporary alternative (e.g. *Plecturocebus moloch* for *Callicebus
moloch*). Reconcile to `_keys/Stephan/species_key.csv`. 29 of 42 species resolve to species already
in the brain-data universe (`_keys/species_reference.csv`), so the trait correlates with brain data
for those species.

## Shiny app
Folded in as a correlatable trait via `____EvoM1_TraitTable/vocal_repertoire_schniter.xlsx`
(built by `EvoM1_read_vocal_schniter.R`) and registered in `__ShinyApp/build_data.R`.

Pipeline: Source → Snapshot ✅ → Data readable ✅ → Species note ✅ → TraitTable ✅ →
Online database ☐ (run the R script with the full repo mounted to write the DOI-named TSV).
