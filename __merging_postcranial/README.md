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
| Item | Level | Role | Measures |
|---|---|---|---|
| Dupont_etal_2026_TableS3 | species, extant | primary | phalangeal index: forefoot digit I and III+IV, hindfoot digit I and III+IV |
| Dupont_etal_2026_TableS2 | specimen, fossil | primary | the same four indices |
| Granatosky__2018_TableS1 | species, extant | primary | intermembral index |
| Wimberly_etal_2021_MammalGait | species, extant | secondary | hindlimb length (mm) |
| Liu_etal_2016_TableS1 | specimen, extant primates | secondary | 7 hand-segment proportions; modelled workspace (WS) and global manipulation index (GMI) |
| Baker_etal_2025_SupplementaryData1 | mixed | secondary | 19 hand-bone lengths (log10 mm, as printed) |

How the mixed and fossil handling works:
- **Baker** rows whose `Individuals` is `taxon-level` pool at species level; rows with specimen IDs stay in the
  specimen table. Baker is a secondary compilation of other papers' measurements, so it is `secondary`; the
  `*` Lemelin restricted values are NA.
- **Fossils** are listed in `postcranial_fossil_taxa.csv` (item + printed name). Baker's 32 fossil/extinct taxa
  are routed to the specimen table with `fossil = TRUE`. This list is curator judgement from the taxon names and
  Baker's specimen IDs, not a database check; confirm against the Paleobiology Database.
- **Overlap warning.** Liu 2016 and Baker both descend from Feix et al. 2015 (Liu proportions, Liu WS/GMI,
  Baker `peak_workspace`), and Baker's bone lengths come from primary sources not yet in the repo. Both are
  therefore `secondary`; do not treat them as independent replicates of each other. Values of different
  `method` are never pooled.

Deliberately not ingested:
- Dupont `Time_Arboreal_pct` / `TimeArbo_*` (ecology, model inference) and body mass (stay in body_ecology).
- Baker `peak_workspace`, `relative_size`, `real_size` (not verified as postcranial anatomy; `peak_workspace`
  shares Feix 2015 with Liu).
- Wimberly `Foot_Posture`, MedinaGonzález `Posture` (categorical; the merge is numeric only).
- MedinaGonzález 2026 joint angles (limb kinematics, locomotion not anatomy).
- Frost 2000 (somatosensory cortical areas), Caspar 2022 and Püschel 2026 (handedness), Boyer-Harrington
  2018/2019 (cranial vascular canals). An earlier draft of this README listed these as postcranial candidates;
  that was wrong.

## Open items
- No `__ShinyApp` / variable-catalog registration yet (`_keys/variable_domain.csv` has no postcranial domain).
- Not yet in the species-audit regression tooling (its merge list is hard-coded).
- Unresolved fossil names: 8 from Dupont and 13 from Baker (`species_basis = unresolved`) pending a Paleobiology
  Database or source check. Wimberly also has 6 extant names that do not resolve (pre-existing, in that item).
- Categorical postcranial traits (foot posture) need a separate categorical table.
