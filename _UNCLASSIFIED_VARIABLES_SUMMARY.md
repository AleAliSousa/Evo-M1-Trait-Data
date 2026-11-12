# Classifying the unclassified app variables (2026-11-06)

**Result:** 162 of 1388 app variables had no row in `_keys/variable_domain.csv`
(the banner said 164 of 1361 earlier). All 162 now have a domain and measure class.
`__ShinyApp/list_unclassified.R` reports 0 of 1388 unclassified.

## What was classified

| Group | Labels | Domain / class |
|---|---|---|
| Mirror tests | 65 | behaviour & cognition; `mirror_mark_test` (27), `mirror_behaviour_counts` (38) |
| Taste | 23 | sensory performance; `taste_psychophysics` |
| Cortical surface areas | 19 | brain structure & size; `cortical_surface` |
| Play | 19 | behaviour & cognition; `play` |
| Sociality (adult counts, monthly grooming) | 14 | behaviour & cognition; `sociality` |
| Brain-structure and cerebellar volumes | 11 | brain structure & size; `structure_volume` |
| Cerebral perfusion / metabolic rate | 7 | metabolism |
| Breeding season, estrus, overlap, seasonality | 4 | life history |

A count (`.N`, count, mean count/subject) is a feature of a trait, not a trait: the class
names what is counted (e.g. `Adult_females.N` is sociality), never "number".

## Consolidation

Done with `poolable_family` (the quantity) and `poolable_group` (the quantity as measured),
as in the secondary compilations. No labels were renamed or merged.

- Labels differing only by individual, test condition, month or hemisphere share family and group
  (Suarez 1981 individuals, Posada covered/marked/uncovered, Bartlett months): 43 families span more than one label.
- Separate groups within one family where the method differs: surface area absolute mm2 vs % of neocortex;
  taste detection vs preference vs avoidance; Smaers 2011 vs 2018 cerebellar partitions;
  Carnes/Lindenfors vs Kamilar 2013 adult counts (values disagree for shared species, e.g. Ateles 17 vs 4.1).
  The Plot tab warns when these are crossed (including mm2 vs %, which is a broad warning).
- Family/group was filled on 7 existing rows so they pair with the new ones: M1/V1/V2 `.mm2`,
  Lateral/MedialCerebellum_Vol, Adult_females/males_Kamilar2013.

## Definitions

`_keys/build_variable_definitions.R` gained a pass that takes definitions from the source item
via `*_observations_long.csv` (117 labels). 62 labels (mostly Galan 2019, PanTHERIA, Demirci)
still have no definition; they are outside this task.

## Files

- `_keys/classify_unclassified_labels.py` (new): rule-based classifier; errors on an unmatched label.
- `__ShinyApp/list_unclassified.R` (new): lists unclassified labels using the app's own startup.
- Changed: `_keys/variable_domain.csv`, `_keys/build_variable_definitions.R`,
  `_keys/variable_definitions.csv`, `__ShinyApp/data/source_manifest.csv`.

Re-run order after new merges:

    Rscript __ShinyApp/list_unclassified.R unclassified.csv
    python3 _keys/classify_unclassified_labels.py unclassified.csv
    Rscript _keys/build_variable_definitions.R
    LC_ALL=en_US.UTF-8 Rscript __ShinyApp/build_data.R

## Things to check

1. `__ShinyApp/data/supplementary_long.csv` was moved to the Trash (build_data.R refuses to run
   while it exists; it was a stale copy of the canonical merge file). It is tracked in git and shows
   as deleted. Restore from the Trash or `git checkout` if wanted.
2. `MacLarnon__1996/MacLarnon__1996_Table1.R` shows as modified; not edited by this work.
3. Run `build_data.R` in a UTF-8 locale; in a C locale it writes `<U+02C6>`-style escapes into
   `evom1_traits_long.csv`.
4. Nothing was committed or pushed.
