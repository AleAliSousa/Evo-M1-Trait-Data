# Stage 11 — compiler decisions (contract shared by every `*_refs_check` pipeline)

Stages 01–10 of a refs_check pipeline establish, cell by cell, whether a
compilation reproduces the source it cites. Stage 11 answers a different
question: **what did the compiler decide**, so that the next compilation can
adopt the good decisions and avoid the bad ones. It reads only the pipeline's
own outputs (`01_baseline_listed_sources.csv`, `03_source_index.csv`,
`04_verified_against_listed.csv`, `FINAL_*.csv`, `REVIEW_QUEUE*.csv`, the
`findings/*.md` already written) and changes no value anywhere.

Helpers: `_tools/dataset_builder/compiler_decisions_helpers.R` (sourced via
`EVOM1_ROOT`). Script name: `scripts/qc_<name>/11_compiler_decisions.R`, run
last by the driver. Outputs go to `audit_out/findings/`:

| file | one row per | answers |
|---|---|---|
| `coverage_inverse.csv` | source-table cell the compilation did **not** take | included / excluded; accidental vs intentional |
| `error_taxonomy.csv` | compilation cell with a detected error, plus a `COUNT` block | common errors to watch for |
| `averaging_tests.csv` | compilation cell whose N disagrees with its source or whose value sits between candidate source values | if averaged, how |
| `source_priority.csv` | source pair (A, B) that both offered a value for the same cell | which datasets get priority |
| `discoveries.csv` | curatorial finding the compiler made (or the audit made about the compiler's key) | specimen identity, renaming, anatomical correspondence, recalculation |
| `COMPILER_DECISIONS.md` | — | the five tables summarised in prose with counts; nothing in it that is not in a CSV |

## 1. coverage_inverse.csv

Columns: `source_id, paper, species_norm, source_column, comp_column,
source_value, source_n, comp_has_cell, comp_source_for_cell, pattern, evidence`.

A cell of the source index is "not taken" when no compilation cell exists for
(`species_norm`, `comp_column`) **or** it exists but was taken from another
source. The source→compilation column map is **learned from the verified
matches** (stage 04 / FINAL): every (source_id, source_column) that produced a
match to a compilation column is mapped; index rows whose column never
matched anything are `pattern = unassessed` (the compilation may simply not
carry that variable), never "excluded".

`pattern` (one of):

- `taken_from_other_source` — the compilation has the cell, from a different source (this is a priority decision; it is also counted in source_priority.csv)
- `comp_has_cell_unattributed` — the compilation has the cell but the audit could attribute it to no source, while this source offers a value (a lead for the audit, not an exclusion)
- `whole_column` — the compilation never takes this `comp_column` from this source although the source publishes it for species the compilation covers
- `whole_taxon` — the species does not appear in the compilation at all
- `n_threshold` — `source_n` is below the smallest N the compilation did take from this source for this column
- `isolated_probable_accident` — the compilation took **other** columns from this species' row of the **same** source, and nothing above explains the gap
- `unassessed` — column not mapped, or species could not be normalised

Only `isolated_probable_accident` is asserted as probably accidental; the
others are patterns consistent with an intentional rule, and `evidence` says
which numbers support the pattern (e.g. "smallest N taken from this source for
Neocortex = 2; this row has N = 1").

## 2. error_taxonomy.csv

Columns: `row_id, species, comp_column, comp_value, source_value, mechanism,
verification_status, correction_reason, errata_id, evidence`. Mechanism
vocabulary (shared; a pipeline maps its own statuses onto it):

| mechanism | signature |
|---|---|
| `row_displacement` | value belongs to an adjacent / different species row of the same table |
| `digit_substitution` | one glyph differs from the print (3↔8, 2↔7, 1↔7, 0↔6, 5↔6) |
| `unit_or_reference_slip` | ×1000 / ÷1000, dB re 1 dyne/cm² vs SPL, cm³ vs mm³ |
| `structure_definition_drift` | figure reproduced under a structure or criterion the source does not share |
| `unrounded_working_value` | compilation carries more decimals than the print (compiler worked from an unrounded sheet) |
| `truncation` | decimals dropped rather than rounded |
| `averaging_component_omitted` | a per-individual value missing from the mean |
| `wrong_citation` | value reproduces a paper other than the one cited (same lab, wrong year; swapped a/b/c) |
| `format_artefact` | control characters, text-stored numbers, "<x stated as x" rules |
| `unexplained` | disagrees with every indexed candidate |

The `COUNT` block (rows with `row_id = "COUNT"`) gives the total per mechanism
so the .md can cite them.

## 3. averaging_tests.csv

Columns: `row_id, species, comp_column, comp_value, comp_n, candidate_sources,
candidate_values, candidate_ns, mean_unweighted, mean_n_weighted,
matches_unweighted, matches_n_weighted, matches_single_candidate, verdict`.
A test is run for every compilation cell where (a) the compilation's N
differs from the cited source's N, or (b) ≥ 2 indexed candidates exist for the
cell and the compilation value equals none of them exactly. Equality is
judged at the compilation's printed decimals. `verdict` ∈
`pooled_unweighted`, `pooled_n_weighted`, `single_source_relabelled_n`,
`not_reproduced`, `not_tested_insufficient_candidates`.

## 4. source_priority.csv

Columns: `source_a, source_b, cells_both_offer, chosen_a, chosen_b,
chosen_neither, a_newer, a_larger_n, a_is_cited_more, dominant_rule`. For each
compilation cell where both A and B publish a value, which one the
compilation equals. `dominant_rule` is descriptive only: `newer`, `older`,
`larger_n`, `cited_reference`, `mixed`, `n/a`. Also a per-cell long form,
`source_priority_cells.csv`, so every pair count can be traced.

## 5. discoveries.csv

Columns: `kind, subject, finding, evidence, made_by, where_recorded`. `kind` ∈
`species_identity` (synonym, reidentification, genus-level label),
`specimen_identity` (a cell traced to a named specimen), `anatomical_correspondence`
(structure-key crosswalk, hierarchy), `recalculation` (unit conversion,
criterion conversion, derived measure), `exclusion_rule` (a pattern from
coverage_inverse strong enough to state as a rule). `made_by` ∈ `compiler`,
`audit` — a discovery the audit made about the compiler's key is still worth
recording, but must not be attributed to the compiler.

## What stage 11 must not do

- Change or "correct" any value; it writes findings only.
- Assert intent. Patterns are reported as patterns; only
  `isolated_probable_accident` carries a probabilistic label, and its evidence
  column must show the row the compiler *did* take.
- Count a cell twice across coverage patterns; each index row gets one pattern.
