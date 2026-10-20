# `species_pooling.csv` — wild/domestic label pairs, and the read-time switch that uses them

This is step 4 of `TAXON_POOLING_DESIGN.md`, built for one axis only:
**domestication**. It declares which compiled species labels are the wild and
domestic forms of one animal, so that a *consumer* can choose to pool them.
Nothing in `__merging_*` reads this file, and nothing in `species_cohorts.csv`
changed: a cohort still reports what its own names hold unless the switch is
turned on.

## Format

One row per member of a pooling group.

| column | meaning |
|---|---|
| `pool_id` | the group (`Sus_scrofa`, `Mustela_putorius`) |
| `member` | a compiled species label, exactly as the `__merging_*` long files spell it (an `accepted_name` in `species_reference.csv`) |
| `axis` | `domestication` — the only axis implemented. `subspecies`, `sensu` and `indet` are reserved by the design doc and are **not** honoured by any consumer yet |
| `relation` | `wild_form` or `domestic_form`. A group has exactly one `domestic_form` and one or more `wild_form` rows |
| `basis` | why the two labels are one animal — required |
| `authority` | the taxonomy that says so (NCBI taxid, MDD) — required |
| `decided_by`, `decided_date`, `note` | provenance of the row |

Seeded 2026-10-20 with *Sus scrofa* / *Sus scrofa domesticus* and *Mustela
putorius* / *Mustela putorius furo*, the two pairs that block EvoM1 coverage.

## The switch: three modes

Implemented in `__Cytosplore_export/build_cytosplore_traits.R` (fourth CLI
argument) and in `__ShinyApp/app.R` (control on the **Cohort coverage** tab),
through the same function, the app's `cohort_species(ch, pooling = ...)`.

| mode | what a cohort member that is a `domestic_form` adopts | where the decision comes from |
|---|---|---|
| `off` (default) | only its own labels (`species_sci` / `lookup_name`) — today's behaviour, numbers identical | `species_cohorts.csv` |
| `domestic_evidence` | also the rows filed under its `wild_form` label whose `population_status` is `domestic` or `mixed` | `population_status.csv`, row by row |
| `all` | the whole `wild_form` label, as `lookup_name` pooling would | this file only |

A cohort member whose own label is a `wild_form` (none today) is never
touched: pooling runs from the domestic slot outwards, because that is the
slot the sequenced animals occupy.

### How a compiled row gets a population in `domestic_evidence` mode

The app's compiled table now carries a `Teams` column: the provenance tokens
of the merge row (the merge's `Teams`, `Sources` or `source` column, split on
`;`). Each token is looked up in `population_status.csv` by
`(source_table, accepted_name)`. The row's verdict is:

- `domestic` if every token is domestic;
- `wild` if every token is wild;
- `mixed` if any token is `mixed` or `domestic` and the rest are not all domestic;
- `unknown` otherwise (any token unknown or missing from the key, and no domestic/mixed token).

Rows with verdict `domestic` or `mixed` are adopted; `wild` and `unknown` are
not. So a body mass pooled by the merge from six polecat compilations and one
ferret study is `mixed` and *is* adopted — the key makes that visible in the
export (`population_verdict` column of the long table, `n_data_labels` in the
cells table) rather than hiding it.

### Outputs

- Builder: `__Cytosplore_export/output/<cohort>_pooled_<mode>/`, same files as the
  species-level folder, plus a `pooling_mode` column in the species table and a
  `population_verdict` column in the long table. `build_all_cohorts.sh` builds
  both pooled modes at species level for every cohort; `compare_cohorts.py`
  picks the folders up automatically.
- App: the Cohort coverage tab's checklist, trait availability, name variants
  and statistics all follow the selected mode; the download file name carries it.
- `_checks/check_cohort_coverage.R` reports the full-coverage count per mode for
  each cohort (report only; the pass/fail logic is unchanged and runs in `off`).

## Guard rails

- Every `member` must exist in `species_reference.csv`; the app stops with a
  message naming the row otherwise.
- A group needs exactly one `domestic_form`.
- The concept-boundary report in `check_cohort_coverage.R` still applies to
  the labels a cohort adopts; a `wild_form` label that the taxon-concept
  registry marks non-decomposable would be reported there.

## What this deliberately does not do

- It does not change any merge, any `*_long.csv`, or `species_cohorts.csv`.
- It does not pool the sensu-lato / re-identification cases
  (*Chlorocebus aethiops*, *Tupaia glis*, *Aotus trivirgatus*,
  *Saimiri sciureus*): those are naming facts for the resolver, not a
  population covariate (see `TAXON_POOLING_DESIGN.md`, "The two axes are
  different in kind").
- It does not decide which mode is right. `off` is the default everywhere.
