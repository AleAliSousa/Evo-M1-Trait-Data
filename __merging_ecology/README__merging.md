# Merging ecology data: diet, foraging strata + activity pattern

Pipeline for compiling the **ecology** traits from Wilman et al. 2014
(EltonTraits), plus the Galán-Acedo et al. 2019 diel-activity gap-fill for
`Activity_pattern`.

**Split note (2026-11-21).** This merge is the `diet_ecology` class of the old
`__merging_body_ecology` merge, split out unchanged (the old script's sections 4
and 4b, pooling and species resolution verbatim). The old merge's other classes
moved in the same split: `mass` + `metabolic (body)` → `__merging_body/`, and the
`life_history` measures → `__merging_life_history/` as additional sources
(Option A). One visible consequence: the long table's `species_printed` /
`species_basis` columns summarise the unfiltered rows of *this* merge (they used
to summarise all four classes), so they are narrower than in the old combined
merge. Values are unaffected. The old merge's single value veto concerned a
body-mass source and moved to `__merging_body/body_value_flags.csv`; no veto
applies here, so this merge has no vetoed-rows output.

| measure_class | Measure(s) |
|---|---|
| `diet_ecology` | 10 diet %s, `Diet_breadth`; categorical `Diet_dominant`, `Trophic_guild`, `ForStrat_stratum`, `Activity_pattern` |

## Diet & ecology

Wilman 2014 (EltonTraits) is the single source, harvested at **full coverage** —
replacing the ~196-species subset that used to sit in the `diet_foraging.xlsx`
trait table (now superseded). Numeric measures (10 diet percentages +
`Diet_breadth`) pool as usual; the four **categorical** measures (`Diet_dominant`,
`Trophic_guild`, `ForStrat_stratum`, `Activity_pattern`) use the generalized
pooler — **mode** (primary-preferred) instead of mean, with a `MULTIPLE` flag in
the dedupe report if sources ever disagree (they don't here — single source).
Faithful to Wilman: Homo → Fruit / Herbivore / Ground / Diurnal; Panthera leo →
Endotherm vertebrates / Faunivore / Ground / Nocturnal.

## Update: Galán-Acedo et al. 2019 diel activity fills Activity_pattern gaps (2026-11-20)

`Activity_pattern` stays a Wilman/EltonTraits label: Wilman's value is the
value wherever Wilman reports the species (5,390 species). Galán-Acedo et
al. 2019 report the same quantity for primates as codes (D / N / CA) in
`GalánAcedo_etal_2019_DielActivity.csv` — the table `__merging_supplementary`
maps, unchanged, as `Activity_pattern_Galan2019`. Section 4b of
`ecology_compiled.R` maps the codes onto Wilman's words (D → Diurnal,
N → Nocturnal, CA → Cathemeral) and appends rows ONLY for species Wilman
lacks, so the precedence is structural: no Wilman row changes, and the pool
never has to arbitrate between the two sources. On the 323 species both
report, the mapped Galán codes agree with Wilman on 95.7% (audit,
2026-11-20); the fill adds 175 species, taking the label to 5,565 species
in the app. Zimmermann 2017's activity codes are a separate, case-
inconsistent vocabulary and stay a separate label.

## Files

| file | contents |
|---|---|
| `ecology_compiled.R` | the build script (run from anywhere; it locates the repo root itself) |
| `ecology_source_columns.csv` | the fixed source-column crosswalk (Wilman columns + the Galán gap-fill) |
| `ecology_unfiltered.csv` | one row per harvested record, pre-pooling (incl. the 175 Galán fill rows) |
| `ecology_long.csv` | one row per Species × Measure: pooled `Value` (+ median, sources, teams, spread) |
| `ecology_wide.csv` | Species × Measure matrix of `Value` |
| `ecology_dedupe_report.csv` | multi-source groups with per-source values and disagreement flags |
