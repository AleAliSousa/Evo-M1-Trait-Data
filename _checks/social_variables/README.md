# Social-variable coverage audit — 2026-10-22

Dunbar & Bever (1998) Tables 1–2 are now available as
`Social_group_size_DunbarBever1998 (count)` in the supplementary merge.
The Methods attribute carnivore group sizes to Gittleman (1989a,b): these are
secondary compilation values, not independent measurements by Dunbar & Bever.
Table 3 is genus-level and is excluded from this species-level addition.

Tables 1 and 2 have 15 and 43 rows. Eleven species overlap with identical group
sizes, leaving 47 species. Table 1 takes precedence within this paper. The
trailing printed footnotes 3, 4 and 5 are removed for matching (including
Procyon lotor3/lotor5); source CSVs and snapshots retain their original names.
No cross-publication averaging is performed. Overlapping compilations must not
be treated as independent observations. The group-size entries have not yet had
an exhaustive second visual transcription check.

`Social_system` is decoded at app load using Lewitus 2014 Table S2
(`pbio.1002000.s014.xlsx`): 1 solitary; 2 monogamous; 3 multi-male; 4 harem.
The raw source codes remain unchanged. Decoded values have `Value_num = NA`, so
these nominal categories cannot be treated as numeric scores. Unknown codes
raise an error. This improves labels but adds no species or independent evidence;
Lewitus's secondary provenance remains visible.

## Coverage

| Availability | All species before | After | Added | EvoM1 before | After | Added |
|---|---:|---:|---:|---:|---:|---:|
| Any social-group-size source | 802 | 843 | 41 | 16/25 | 16/25 | 0 |
| Social-system categories (Lewitus) | 62 | 62 | 0 | 17/25 | 17/25 | 0 |

The new Dunbar & Bever label itself covers 47 species, including one EvoM1
species, **Canis latrans** (2.1), which already has group-size data. Other
EvoM1 species are not filled by assigning wild relatives, genera, or broader
species concepts: notably Mustela putorius is not assigned to M. putorius furo.

Coverage uses the app's actual compiled rows and display aliases, with the
25-species EvoM1 cohort from `_keys/species_cohorts.csv`. Counts describe distinct
app species labels, not an exhaustive new taxonomic reconciliation. Twenty-two
new records retain unresolved printed names according to the house resolver.
The broad union includes source-specific population/foraging group-size labels
listed in `baseline_group_size_labels.csv`; it does not assert their numerical
interchangeability. The existing generic `Social_group_size (count)` label is
unchanged. The 41 gain is across available sources, not within that generic label.

## Files and verification

- `coverage_summary.csv`: counts and species added for each scope.
- `EvoM1_species_coverage.csv`: all 25 cohort species, before/after flags.
- `group_size_overlap_audit.csv`: original Dunbar & Bever and existing values side by side.
- `baseline_app_social_values.csv`: frozen pre-change app rows relevant to this audit.
- `baseline_group_size_labels.csv`: exact set of baseline group-size variables.

Run from repository root:

```
EVOM1_SOURCE=local Rscript _checks/social_variables/load_app.R /tmp/social_after.rds
Rscript _checks/social_variables/compare_coverage.R _checks/social_variables/baseline_app_social_values.csv /tmp/social_after.rds
```

The checker asserts all 25 cohort names, unique Dunbar & Bever species, unchanged
social-system species coverage, decoded labels, and absent numerical category
scores. The app's trait-authority check also passes. App data loading was tested
locally; no browser or hosted deployment test was performed.

The supplementary build was run, but pre-existing output rows were preserved
when saving this update to avoid unrelated name-resolver and locale-order changes.
Only the 47 new data rows and 22 new unresolved-name records were added.

## Zhu addition (2026-10-23)

`Zhu_coverage_summary.csv` compares the actual app before and after this addition.
`Zhu_EvoM1_coverage.csv` gives all 25 cohort members; `Zhu_category_overlap_audit.csv`
keeps existing category values beside Zhu's values. `Zhu_provenance_audit.csv`
links resolved/printed names to original table IDs, row IDs, reference codes,
and the primary/secondary role. `Zhu_baseline_categories.csv` freezes the prior
category rows. The validation script is `check_zhu_coverage.R`.

| Availability | Before | After | Additional |
|---|---:|---:|---:|
| Any social-organization/system category, all species | 76 | 1,025 | 949 |
| Any social-organization/system category, EvoM1 | 17 | 25 | 8 |
| Numerical group size, all species | 843 | 843 | 0 |
| Numerical group size, EvoM1 | 16 | 16 | 0 |

Zhu itself covers 1,008 species and 21/25 EvoM1 members. The combined category
union does not imply equivalence between social organization and mating-system
categories. Zhu lacks exact cohort matches for Gorilla gorilla gorilla,
Saimiri boliviensis boliviensis, Aotus nancymaae, and Mustela putorius furo;
existing sources provide their category coverage. No species-to-subspecies or
wild-to-domestic transfers were made.

Of the 1,008 Zhu labels, 563 are unresolved in the house taxonomic reference and
remain under printed names. Counts are therefore app-label coverage after the
existing resolver/display aliases, not a fully reconciled mammalian taxonomy.
A source-specific key prevents a legacy Rattus rattus -> Rattus norvegicus rule
from collapsing two separate Zhu species. All four variables have definitions
and valid trait authority; categorical values have no numeric scores. The local
app loader and authority checks pass; remote phylogeny downloads were unavailable
in this environment. No deployment was performed.

Recommended sequence: (1) reconcile Zhu's unresolved names and review references
for the eight newly covered EvoM1 taxa; (2) trace social classifications through
Lukas & Clutton-Brock 2013 (cited in 814 selected Zhu species rows, across traits,
not proof of 814 social-data attributions); (3) add population-level marsupial and
artiodactyl social-organization evidence; (4) target numerical group sizes for
the nine EvoM1 species still lacking them. Keep each observation's population,
adult/all-age denominator, aggregation statistic and wild/domestic context.
