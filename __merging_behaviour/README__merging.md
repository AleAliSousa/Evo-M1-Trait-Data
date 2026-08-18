# Merging behaviour data

A keyed comparative **behavioural** merge across several measure classes — **vocal repertoire size**,
**digital dexterity**, **quadrupedal walking gait**, **locomotor diversity**, **hand preference
(handedness)**, **manipulation complexity**, **hand morphology / tool use** (Baker et al. 2025),
**technical innovation / research effort** (Reader et al. 2011), and **motor pathway** — the
corticospinal / corticomotoneuronal termination grade (Bortoff & Strick 1993).
It produces the same long-table schema as the other
keyed merges (`__merging_body_ecology`, `__merging_brain_mass`): **one row per (Species, Measure)**
with the resolved `Value` plus source provenance (`n_sources`, `Teams`, `roles`, `value_min/max`).
The Shiny app loads it via `std_merge()`, exactly like body mass and brain mass.

## One variable per measure, from possibly several sources — never duplicated

Per `__HOWTO_build_a_dataset_file.md` §10 different measure classes are never pooled into one value:
each `Measure` is its own row/variable. Where a measure has more than one source, the value is
**resolved once** and the contributing sources are recorded as keys — the variable is **not**
duplicated. Two measures are multi-source and citation-dependent:

- **VocalRepertoire** — Schniter & Peñaherrera-Aguirre 2026 (primary, updated repertoire) +
  ManyPrimates 2022 (secondary). Both descend from McComb & Semple 2005 → **never averaged**; the
  resolved value is Schniter's, and where both report a species `value_min/value_max` show the spread
  (e.g. *Pan paniscus* value 11, min 11, max 38; `Value_median` is informational only).
- **Dexterity** — Heffner & Masterton 1975 (primary) + Iwaniuk 1999 (secondary). Iwaniuk is a
  re-analysis of the *same* data — identical values on every shared species → prefer Heffner.
- **Tool_use** — Heldstab 2016 (primary) + Baker et al. 2025 (secondary; presence 0/1 after
  Bentley-Condit & Smith 2010). Categorical → the resolved value is Heldstab's where present and
  Baker's elsewhere (Baker extends coverage from 37 to 188 species); the two are never averaged.

The other measures are single-source: Wimberly 2021 (gait), Granatosky 2018 (locomotion),
Caspar 2022 (handedness), Heldstab 2016 (manipulation complexity / extractive foraging), and
**Baker et al. 2025** for the remaining hand-morphology / tool-use measures below.

**Baker et al. 2025 (secondary compilation) contributes** — `Tool_Manufacture` and `True_Tool_Use`
(presence 0/1); `peak_workspace` (Feix et al. 2015 manipulability index); `relative_size` / `real_size`
(derived hand-size indices); and the **19 log10 hand-bone lengths** (`log10_mc/pp/ip/dp{1-5}_mm`;
digit 1 has no intermediate phalanx). These carry measure_class `manipulation` (tool use) or
`hand_morphology`. Values are left in the published **log10** units and are not back-transformed;
Lemelin (1996) restricted bone data is already `NA` in the source. Baker's brain/body/neocortex/
cerebellum columns are **not** ingested here — they belong to the volume/mass merges — and
Binocularity is sensory, not dexterity.

## Inputs

Composes the harmonised, `species_sci`-keyed trait tables in `____EvoM1_TraitTable/`
(`vocal_repertoire_schniter/manyprimates`, `gait`, `locomotion`, `handedness`, `manipulation`,
**`dexterity_baker`** — written by `EvoM1_read_dexterity_baker.R`; **`innovation_reader`** —
written by `EvoM1_read_innovation_reader.R`; **`corticospinal_terminations`** — written by
`EvoM1_read_corticospinal_terminations.R` from the Bortoff & Strick 1993 public TSV), plus
two dedicated dexterity inputs **`dexterity_heffner.xlsx`** / **`dexterity_iwaniuk.xlsx`** (written by
`EvoM1_read_dexterity_corticospinal*.R`). Dexterity has its own input tables because the
corticospinal-tract trait tables the app melts no longer carry the dexterity column — that would
duplicate this merge. The species key mirrors `build_data.R`: `species_sci` where present, else the
printed `Species`, cleaned.

## Outputs

- **`behaviour_long.csv`** — the keyed merge, app-facing. One row per (Species, Measure). Columns:
  `Species, measure_class, Measure, Units, Value, Value_median, n_sources, n_teams,
  n_teams_primary, primary_used, Teams, roles, value_min, value_max` (same schema as
  `body_ecology_long.csv`). **4,830 rows over 489 species**; multi-source rows: Dexterity (24
  species), VocalRepertoire (16), Tool_use (27, Heldstab∩Baker).
- **`behaviour_observations_long.csv`** — the raw per-source rows behind the resolution
  (`Species, measure_class, Measure, Team, role, Value`).
- **`behaviour_wide.csv`** — one row per species, resolved value per measure (overview).

## How the app shows it

`build_data.R` copies `behaviour_long.csv` into `__ShinyApp/data/` and the app reads it with
`std_merge(GH$behaviour, …, "Behaviour")`. Each measure appears **once** as
`"<Measure> (<Units>)"` under dataset **Behaviour**, with `Source = "EvoM1 <measure> merge (N sources)"`
and `N_sources`. No behavioural variable is melted from the trait tables any more, so nothing is
duplicated between datasets.

## Coverage

489 species. By measure class: hand_morphology 1,322 rows, behavioural_flexibility 1,666,
gait 598, research_effort 401, manipulation 343, locomotion 289, handedness 76, dexterity 66,
vocalization 65, **motor_pathway 4** (`CST_termination_grade` + `CM_connection_inference` for
*Sapajus apella* and *Saimiri sciureus*; `CM_monosynaptic` is all-NA at source and so contributes no
rows). Per measure: Duty_Factor/Gait/Phase 154, Foot_Posture 136, Locomotor_diversity_index
113, Arboreal_terrestrial 96, Intermembral_index 80, Dexterity 67, VocalRepertoire 65, Handedness
38, Manipulation/Extractive_foraging 37. Baker et al. 2025: Tool_use 188 (Heldstab 37 + 151 new),
Tool_Manufacture 41, True_Tool_Use 40, peak_workspace/relative_size/real_size 41, and the 19 log10
hand-bone lengths (per-bone 4–145; many Baker taxa are fossils with only bone data).

## Rebuild

Run `behaviour_compiled.R` (reads the harmonised trait tables + the two dexterity inputs; rebuild a
source trait table first if its snapshot/CSV changed), then re-run `__ShinyApp/build_data.R`.

## Not included / future
- **Brain-volume laterality/asymmetry** (a volume measure in `__merging_volumes`) and Eagleman's
  developmental *time-to-locomotion* (life-history, excluded from `__merging_sleep`) are different
  constructs, not behavioural traits.
- To add a future behavioural source, add a `grab(...)` call and a `META` row in
  `behaviour_compiled.R`; if it shares a measure with an existing source, set its priority/role.
