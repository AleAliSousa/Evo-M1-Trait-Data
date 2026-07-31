# Merging body & ecology data

Pipeline for compiling **whole-organism** traits — the body/ecology counterpart of
`__merging_volumes/`, `__merging_cellcounts/`, and `__merging_cerebral_metabolic_rate/`.
These are organism-level measures (body mass, body BMR, ecology / life-history), a different
family from the brain-structure merges, so they get their own merge.

**Measure classes.** The table is keyed by `measure_class` so classes are added incrementally:

| measure_class | status | Measure(s) |
|---|---|---|
| `mass` | **built** | `Body_Mass` (g) |
| `metabolic (body)` | **built** | `BMR_wholeanimal` (mL O2/h), `BMR_massspecific` (mL O2/h/g) |
| `life_history` | **built** | `Maximum_longevity` (yr), `Gestation` (days), `Weaning_age` (days), `Litter_size` (count), `Female_sexual_maturity` (days) |
| `diet_ecology` | **built** | 10 diet %s, `Diet_breadth`; categorical `Diet_dominant`, `Trophic_guild`, `ForStrat_stratum`, `Activity_pattern` |

## Diet & ecology (diet_ecology class)

Wilman 2014 (EltonTraits) is the single source, harvested at **full coverage (5,397 mammals)** —
replacing the ~196-species subset that used to sit in the `diet_foraging.xlsx` trait table (now
superseded). Numeric measures (10 diet percentages + `Diet_breadth`) pool as usual; the four
**categorical** measures (`Diet_dominant`, `Trophic_guild`, `ForStrat_stratum`, `Activity_pattern`)
use the generalized pooler — **mode** (primary-preferred) instead of mean, with a `MULTIPLE` flag
in the dedupe report if sources ever disagree (they don't here — single source). Faithful to
Wilman: Homo → Fruit / Herbivore / Ground / Diurnal; Panthera leo → Endotherm vertebrates /
Faunivore / Ground / Nocturnal.

---

**All four measure classes are now built.** The `__merging_body_ecology` merge is the single
authoritative home for whole-organism traits (body mass, body BMR, life history, diet & ecology),
each surfaced once in the app with the matching raw trait-table columns superseded.

## Life history (life_history class)

Core numeric life-history measures, each in one unit (no cross-unit conversion needed).
**Gestation** and **Weaning_age** have 3 sources each and are pooled team/role-aware; the rest are
Lewitus 2014. Sources: Lewitus 2014 (`pbio.1002000` TableS1 — all five), Isler 2008
(`jhevol.2008` TableS3 — gestation + lactation length, used as the weaning-age proxy since
lactation ends at weaning), pnas 2009 (`0905777106` — gestation), fnins 2021 (`632853` —
time to weaning). Verified: Homo longevity 122.5 yr / gestation 272 d / weaning 910 d; Mus
gestation 18.75 d / litter 6; Macaca gestation 165.9 d (3 sources pooled). Coverage 92–125 species
per measure. The matching Lewitus trait-table columns (`Maximum_lifespan_yrs`, `Gestation_days`,
`Weaning_period_days`, `Litter_size`, `Female_sexual_maturity_days`) are **superseded** by this
class in the app. Lewitus's other life-history columns (litters/year, inter-litter interval, birth/
weaning weight, age at first breeding, male maturity) are left in the trait table, not yet merged.

## Body BMR (metabolic class)

Whole-body basal metabolic rate, harvested from **4 sources** and reconciled to a common unit:
Isler 2008 (`BMR (ml O2/h)`), the 2017 jhevol table (`BMR_kcal_day` → converted at
1 kcal = 4184 J, 1 mL O2 = 20.1 J, so kcal/day × `4184/20.1/24` ≈ 8.67 mL O2/h), Genoud 2018
(`brv.12350` `BMR.mlO2_h`, 1,727 species — the bulk), and Lewitus 2014 (`Basal_metabolic_rate`,
verified mL O2/h). Two **separate** measures (whole-animal vs mass-specific kept apart, per the
design decision):

- `BMR_wholeanimal` (**mL O2/h**) — pooled team/role-aware like the other measures.
- `BMR_massspecific` (**mL O2/h/g**) — **derived per source row** as whole-animal ÷ that row's own
  body mass, then pooled. (No source reports a mass-specific rate directly; Genoud's `BMR_pct` is a
  % of predicted BMR, a different quantity, and is left in the source TSV, not merged.)

Verified against the mouse-to-elephant curve: mass-specific BMR falls with body size —
Mus 2.15 > Microcebus 1.02 > Macaca 0.39 > Homo 0.20 mL O2/h/g; Homo whole-animal ≈ 12,925 mL O2/h.
843 species have whole-animal BMR, 839 mass-specific. Lewitus's `Basal_metabolic_rate` (which used
to surface via the trait table) is now **superseded** by this class in the app.

**Caveat:** the 4 BMR sources are compilations that partly cite the same primary studies (McNab
etc.); team/role-aware pooling treats each as its own team, so shared primaries can be
double-counted. Genoud 2018 dominates (single team for most species), limiting the effect, but a
future compilation-aware pass (like `__merging_cerebral_metabolic_rate`) would tighten it.

## Body mass (first class)

Harvested from **39 source tables** that record body mass. Each source's species-level
body-mass column is auto-selected (`body_ecology_source_columns.csv` logs the choice + unit for
audit), values are converted to the project unit **grams** (kg×1000, mg×0.001; unit-less
columns verified as g by magnitude), and species are resolved to the accepted binomial via the
combined `_keys/*/species_key.csv` + `species_reference.csv`.

### Preventing duplication — three mechanisms

Body mass is the most re-reported variable in the project, so the merge defeats three distinct
duplication modes:

1. **Same-specimen re-reporting.** Papers from one collection re-print body masses for the
   *same animals* (e.g. Stephan 1970/1981, Frahm, Baron, Matano are all the **Stephan
   collection**). The merge **collapses within a team** first (team from
   `_keys/team_grouping_crosswalk.csv`; papers not in a known collection are their own team),
   so a collection counts once.
2. **Compilation double-counting.** Secondary tables reprint other people's numbers. Each row
   carries a `role` (primary = measured the animal; secondary = looked-up/compilation, from
   `_keys/variable_catalog.csv`). Pooling is **primary-preferred**: if any team measured the
   species, only primary team-values set the headline; secondaries fill species with no primary.
3. **Unit / name double-entry** (g vs kg vs mg, `Body_weight` vs `Body_Mass.g`). Converted to
   one unit here and, in the app, unified by `_keys/variable_canonical.csv`.

### Pooling

`Value` = mean of the primary team-values (or all team-values if no primary), after within-team
collapse. `Value_median` is the same pooled with the **median** — use it as the robust headline
when a species is flagged for disagreement (the mean is dragged by source errors; e.g. Wilman
lists *Lagothrix cana* as 6 g). Every species measured by >1 source is written to
`body_ecology_dedupe_report.csv` with the per-source values and a `DISAGREEMENT>2x` flag
(151 species) — these are for review; most are sexual dimorphism, captive-vs-wild, or genuine
source typos.

## Steps

1. **Compile** — `build_body_ecology_merge.py` (the tested builder that generated the shipped
   CSVs; R was unavailable in the build environment, same arrangement as the metabolic and
   Karbowski builds) **or** the house-style twin `body_ecology_compiled.R` (same logic).

## Outputs

- **`body_ecology_long.csv`** — one row per Species × Measure:
  `Species, measure_class, Measure, Units, Value, Value_median, n_sources, n_teams,
  n_teams_primary, primary_used, Teams, roles, value_min, value_max`. **5,576 species**
  for body mass (all-mammal, since Wilman/EltonTraits is included).
- **`body_ecology_wide.csv`** — Species × Measure (`Body_Mass.g` so far).
- **`body_ecology_unfiltered.csv`** — every harvested row with full provenance
  (Species, Species_raw, Value_g, raw_value, raw_unit, Source, first_author, Year, Team, role);
  10,403 rows.
- **`body_ecology_dedupe_report.csv`** — cross-source disagreements (review list).
- **`body_ecology_source_columns.csv`** — which column + unit was taken from each source (audit).

## Known limitations

- Sources that use **common names** (Burish 2010 "Rhesus macaque", a few Heffner/Weaver rows —
  31 rows total, 0.3%) don't resolve to a binomial and stay unmerged. A common-name→binomial
  map would recover them.
- The all-mammal scope means most of the 5,576 species have a single (Wilman) source; the
  merge's pooling value-add is for the ~300 species measured by multiple sources.

## App integration (next)

Add `__merging_body_ecology/body_ecology_long.csv` as a dataset in `__ShinyApp/app.R`
(`load_compiled`), and drop the now-redundant raw body-mass columns from the other three tables'
canonical pooling so `Body_Mass (g)` has a single authoritative source. Not yet wired.
