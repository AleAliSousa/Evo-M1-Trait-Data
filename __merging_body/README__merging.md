# Merging body data: body mass + basal metabolic rate

Pipeline for compiling the **body** traits — the organism-level size/energetics
counterpart of `__merging_volumes/`, `__merging_cell_counts_isotropic_fractionator/`,
and `__merging_cerebral_metabolic_rate/`.

**Split note (2026-11-21).** This merge is the `mass` + `metabolic (body)` half of
the old `__merging_body_ecology` merge, split out unchanged (same harvest, pooling,
veto and species resolution; the old script's sections 1–2). The old merge's other
classes moved in the same split: `diet_ecology` → `__merging_ecology/`, and the
`life_history` measures → `__merging_life_history/` as additional sources (Option A).
One visible consequence: the long table's `species_printed` / `species_basis`
columns summarise the unfiltered rows of *this* merge (they used to summarise all
four classes), so they are narrower than in the old combined merge. Values are
unaffected.

| measure_class | Measure(s) |
|---|---|
| `mass` | `Body_Mass` (g) |
| `metabolic (body)` | `BMR_wholeanimal` (mL O2/h), `BMR_massspecific` (mL O2/h/g) |

## Body mass (mass class)

`Body_Mass (g)` is the authoritative species body-mass trait: every registered
source table carrying a species body-mass column is auto-detected and harvested
(see `body_source_columns.csv` for the per-file column pick), resolved to accepted
species, converted to grams, and pooled team/role-aware so the same specimens or
compilations are never double-counted (each team contributes one value — its own
mean; if any team is primary, only primary teams are pooled). Includes PHYLACINE
(Faurby et al. 2018, via the explicit `mass_g` column override) with its extinct
taxa, as in the old merge. The single value veto (Nudo 1995 FSU specimen weights)
lives in `body_value_flags.csv` and is enforced with an exact row-count check.

## Values not served (2026-11-24)

Two kinds of body-mass record are left out in section 1 of `body_compiled.R`;
each is listed, per species, in `body_not_served.csv` with its status and code.

- **PanTHERIA's missing-value code** (`missing_value_code`, 1,156 records).
  PanTHERIA (Jones et al. 2009) writes -999 where it has no value. Until
  24 November 2026 the merge read it as a body mass of -999 g and averaged it
  in: 1,069 served body masses were negative and 87 more were pulled down.
- **EltonTraits imputed body masses** (`imputed`, 1,359 records; owner
  decisions of 24 November 2026). EltonTraits codes each body mass:
  `BodyMass_SpecLevel` 1 = species-level data, 0 = inferred from genus or
  family typical values (812), 2 = phylogenetically imputed (547; Ref_178,
  Jetz & Freckleton). Codes 0 and 2 are not served. No separate trait
  "including imputations" is kept (owner, 24 November): the values stay in the
  register and in EltonTraits itself.

Together: 323 species lose a body mass that was only a code or an imputation
(150 of them leave the table, having nothing else served), and 1,626 pooled
body masses lose a source (1,582 of them change value) because a code or an
imputation no longer enters the mean.

## Body BMR (metabolic class)

Whole-body basal metabolic rate, harvested from **4 sources** and reconciled to a
common unit: Isler 2008 (`BMR (ml O2/h)`), the 2017 jhevol table (`BMR_kcal_day` →
converted at 1 kcal = 4184 J, 1 mL O2 = 20.1 J, so kcal/day × `4184/20.1/24` ≈
8.67 mL O2/h), Genoud 2018 (`brv.12350` `BMR.mlO2_h` — the bulk), and Lewitus 2014
(`Basal_metabolic_rate`, verified mL O2/h). Two **separate** measures (whole-animal
vs mass-specific kept apart, per the design decision):

- `BMR_wholeanimal` (**mL O2/h**) — pooled team/role-aware like the other measures.
- `BMR_massspecific` (**mL O2/h/g**) — **derived per source row** as whole-animal ÷
  that row's own body mass, then pooled. (No source reports a mass-specific rate
  directly; Genoud's `BMR_pct` is a % of predicted BMR, a different quantity, and is
  left in the source TSV, not merged.)

## Files

| file | contents |
|---|---|
| `body_compiled.R` | the build script (run from anywhere; it locates the repo root itself) |
| `body_source_columns.csv` | audit: per source file, the body-mass column picked and its unit |
| `body_unfiltered.csv` | one row per harvested record, pre-pooling (vetoed rows removed) |
| `body_vetoed_rows.csv` | rows removed by `body_value_flags.csv`, with the flag |
| `body_long.csv` | one row per Species × Measure: pooled `Value` (+ median, sources, teams, spread) |
| `body_wide.csv` | Species × Measure matrix of `Value` |
| `body_dedupe_report.csv` | multi-source groups with per-source values and disagreement flags |
| `body_not_served.csv` | records not served, one row per species: status (`imputed`, `missing_value_code`), code and reason |
| `body_value_flags.csv` | value vetoes (input; `skip` action, exact-count enforced) |
