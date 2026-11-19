# Postcranial anatomy merge (scaffold)

Collects limb, hand and foot anatomy in one place, separate from `__merging_body_ecology`.

```sh
Rscript __merging_postcranial/postcranial_compiled.R
```

## Outputs
- `postcranial_species_long.csv`: extant species-level values, one row per (species, Measure, method), standard
  merge-long columns plus `value_type` (`raw` | `derived` | `model_inference`) and `method`.
- `postcranial_species_wide.csv`: median value, one column per `Measure [method]`.
- `postcranial_specimen_long.csv`: specimen-level rows (extant or fossil, `fossil` flag, `specimen_id`). Never pooled.

## Defaults (change them in `postcranial_sources.csv`, not in the script)
1. Species-level and specimen-level rows stay in separate tables.
2. Fossils are specimen/taxon rows only and never enter the extant species pool (the script stops if a
   species-level source is flagged `fossil = TRUE`).
3. Methods stay separate: values pool only when species, Measure, Units and `method` are identical.
4. Raw lengths and derived indices are both kept, labelled by `value_type`.
5. Only `primary` rows are pooled; `secondary` rows are kept with `primary_used = FALSE`.

## Adding a source
Add one row per source column to `postcranial_sources.csv` (item, folder, species column, optional specimen
column, level, fossil flag, source column, Measure, Units, value_type, method, role). The item's analysis CSV
must already exist (see the build-dataset-item workflow). Species names resolve through
`_keys/resolve_species.R` with `source_publication` = the paper folder.

## Currently ingested
| Item | Level | Measures |
|---|---|---|
| Dupont_etal_2026_TableS3 | species, extant | phalangeal index: forefoot digit I and III+IV, hindfoot digit I and III+IV |
| Dupont_etal_2026_TableS2 | specimen, fossil | the same four indices |
| Granatosky__2018_TableS1 | species, extant | intermembral index |

Not ingested from Dupont: `Time_Arboreal_pct` and the `TimeArbo_*` model inferences (ecology, not anatomy),
body mass (stays in body_ecology).

## Candidates to add (not yet built into this merge; confirm each is postcranial and has a built item)
Wimberly 2021 (hindlimb length, foot posture, gait), Liu 2016 (hand-bone lengths), Frost 2000 (digits,
hindlimb/trunk), Püschel 2026 and Caspar 2022 (humeral indices), MedinaGonzález 2026 (joint angles), Baker and
Boyer-Harrington (hand and thumb size). Most need their column names and units checked against their
definitions files first.

## Open items
- No `__ShinyApp` / variable-catalog registration yet (`_keys/variable_domain.csv` has no postcranial domain).
- Not yet in the species-audit regression tooling (its merge list is hard-coded).
- 8 Dupont fossil names are still `species_basis = unresolved` pending a Paleobiology Database or source check.
