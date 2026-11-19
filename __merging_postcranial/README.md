# Postcranial anatomy, hand-use and limb-function merge

Collects limb, hand and foot anatomy together with the behaviour and function that travel with it in source
tables, kept apart by `measure_class`. Separate from `__merging_body_ecology`.

```sh
Rscript __merging_postcranial/postcranial_compiled.R
```

## measure_class
| class | content |
|---|---|
| `postcranial_morphology` | bone lengths, phalangeal and intermembral indices, hand-segment proportions, modelled hand workspace |
| `hand_use` | handedness index and strength, digital-dexterity scores |
| `limb_function` | gait (duty factor, phase), foot/limb posture, joint-angle kinematics and stride |

Handedness, dexterity, gait and posture are behaviour/function, not anatomy, but they are collected here because
they co-occur with hand and limb morphology in the same tables. Cranial vascular canal data (Boyer-Harrington)
model brain physiology and stay out.

## Outputs
- `postcranial_species_long.csv`: numeric extant species-level values, one row per (species, class, Measure, method).
  `postcranial_species_wide.csv` is the median-value wide form.
- `postcranial_specimen_long.csv`: numeric specimen-level rows (extant or fossil, `fossil` flag). Never pooled.
- `postcranial_record_long.csv`: numeric, one row per source record or sample (a video, an article, a study
  sample). Never pooled. Pool only deliberately, after deciding what a record is.
- `postcranial_categorical_long.csv`: categorical values (posture, gait). Never pooled; conflicting values from
  different sources are kept side by side.

## Defaults (change them in `postcranial_sources.csv`, not in the script)
1. Species-, specimen- and record-level rows stay in separate tables.
2. Fossils are specimen/taxon rows only and never enter the extant species pool (the script stops if a
   species-level source is flagged `fossil = TRUE`).
3. Methods stay separate: values pool only when species, class, Measure, Units and `method` are identical.
4. Raw lengths and derived indices are both kept, labelled by `value_type` (raw | derived | model_inference).
5. Where a species has only secondary rows the pooled Value comes from them with `primary_used = FALSE`.
6. **Copies, not links:** `cross_listed_from` (`<merge>:<Measure>:<Team>`) marks a column that the behaviour merge
   also carries. Never pool this merge with the behaviour merge. The script checks that each named
   Measure/Team exists in `__merging_behaviour/behaviour_observations_long.csv` and warns if not (none do now).

## Currently ingested
| Item | Level | Role | Class | Measures | Also in behaviour merge |
|---|---|---|---|---|---|
| Dupont_etal_2026_TableS3 | species, extant | primary | morphology | 4 phalangeal indices | no |
| Dupont_etal_2026_TableS2 | specimen, fossil | primary | morphology | the same 4 indices | no |
| Granatosky__2018_TableS1 | species | primary | morphology | intermembral index | yes |
| Wimberly_etal_2021_MammalGait | species | secondary | morphology | hindlimb length | no |
| Liu_etal_2016_TableS1 | specimen | secondary | morphology | 7 hand-segment proportions, WS, GMI | no |
| Baker_etal_2025_SupplementaryData1 | mixed | secondary | morphology | 19 hand-bone lengths (log10 mm) | yes |
| Caspar_etal_2022_Table1 | species | primary | hand_use | handedness index and strength | yes |
| Püschel_etal_2026_S1Data | record | secondary | hand_use | handedness index and strength per study sample | no |
| Heffner_Masterton_1975/1983, Iwaniuk_etal_1999 | species | primary | hand_use | dexterity scores (three different scales) | yes |
| Wimberly_etal_2021_MammalGait | species | primary | limb_function | duty factor, phase; categorical foot posture and gait | yes |
| MedinaGonzález__2026_SupplementaryFile3 | record | primary | limb_function | 40 joint-angle/excursion/stride columns; categorical limb posture | posture only |

Notes:
- **Baker** is a secondary compilation. Rows whose `Individuals` is `taxon-level` pool at species level; rows with
  specimen IDs stay in the specimen table. `*` Lemelin restricted values are NA.
- **Fossils** are listed in `postcranial_fossil_taxa.csv` (item + printed name). Baker's 32 extinct taxa are
  curator judgement from the names and specimen IDs, not a database check; confirm against the Paleobiology Database.
- **Overlaps.** Liu 2016 and Baker both descend from Feix et al. 2015 (Feix is not in the repo). Püschel 2026's
  handedness values are compiled partly from Caspar 2022. Heffner 1975 and 1983 overlap, and the Heffner and
  Iwaniuk dexterity scores use different scales: never pool them. Treat secondary sources as non-independent.
- **Medina-González 2026** rows are per source record (182 records for 77 species, up to 17 per species).

Deliberately not ingested:
- Dupont `Time_Arboreal_pct`/`TimeArbo_*` (ecology, model inference) and body mass (body_ecology).
- Baker `peak_workspace`, `relative_size`, `real_size` (not verified as postcranial; `peak_workspace` shares Feix 2015).
- Medina-González `Locomotor_habit`, `Top_speed_class`, body-mass columns (ecology/body size).
- Frost 2000 (somatosensory cortical areas), Boyer-Harrington 2018/2019 (cranial vascular canals).

## Adding a source
Add one row per source column to `postcranial_sources.csv` (item, folder, species column, optional id column,
level, fossil flag, source column, Measure, Units, value_type, method, role, type numeric|categorical,
measure_class, cross_listed_from). The item's analysis CSV must already exist.

## Open items
- Unresolved species labels (2 at build, both deliberate): `Horpyiocepalus leucogostra` (Heffner 1975 bat, genuinely
  ambiguous between Murina leucogaster and a Harpiocephalus species; see
  `Heffner_Masterton_1975/reference_tables/..._taxon_resolution.csv`) and `Panthera leo × tigris` (Medina-González,
  a hybrid, deliberately not assigned to either parent species).
- Fossil names resolved 2026-11-19 with GBIF and the Paleobiology Database (evidence in
  `Baker_etal_2025/reference_tables/Baker_etal_2025_taxon_resolution.csv` and
  `Dupont_etal_2026/reference_tables/Dupont_etal_2026_taxon_resolution.csv`): GBIF exact accepted species kept as
  printed, PBDB accepted species kept where GBIF lists a different treatment, Ectoconus majusculus -> Ectoconus
  ditrigonus and Godinotia neglecta -> Pronycticebus neglectus as PBDB synonyms, and three Messel taxa
  (Kopidodon macrognathus, Messelogale kessleri, Paroodectes feisti) kept as printed with `our_judgment`
  (species absent from GBIF and PBDB; lower confidence). The Baker fossil/extinct list itself is still curator
  judgement; PBDB confirms all of its names as fossil taxa except the three Messel ones, which are not indexed.
- **Registered (2026-11-19)** in `__ShinyApp/app.R` (`GH$postcranial`, Dataset label "Postcranial & limb function"),
  the dataset-name maps in `_keys/build_trait_authority.R` and `_checks/check_trait_authority.R`, the provenance
  map in `_keys/build_population_status.py`, `_keys/variable_domain.csv` (22 new labels; 5 reused existing rows)
  and `_keys/variable_definitions.csv` (22 rows, definitions from `__merging_postcranial_definitions.csv`).
  The app serves **only** `postcranial_species_long.csv`; specimen, fossil, record-level and categorical tables
  stay here. The app reads canonical files from GitHub, so it shows the data once this branch is merged.
- Derived tables not regenerated here (the build container cannot read accented paths, and a rebuild also
  re-seeds unrelated rows): re-run `_keys/build_population_status.py`, `_keys/build_trait_authority.R` and
  `_keys/build_variable_definitions.R` on a normal checkout after merging, and review that diff separately.
- Label collisions are deliberate: `Duty_Factor`, `Phase`, `Intermembral_index (ratio)` and the handedness labels
  match rows already in the catalog (domain = first row wins), and appear under both Datasets. The three dexterity
  scales have distinct labels so the app cannot pool them.
- The species-audit regression tooling does not list this merge.
- The three Wimberly/Heffner/Caspar pairs and Baker/Granatosky columns are duplicated across merges by design.
