# Dataset Builder

Repository-level tooling for Evo-M1-Trait-Data.

## Purpose

- audit a dataset item against the 4-file convention before building
- run the item's build script in an isolated environment
- validate all 7 hard invariants after the build

## Entry point

Source the single loader from any working directory:

```r
source("_tools/dataset_builder/load_dataset_builder.R")
```

This resolves its own path regardless of `getwd()`, then sources
`validate_dataset_item.R`, `audit_dataset_item.R`, and `build_dataset_item.R`
in dependency order. It also exposes a convenience helper:

```r
root <- repo_root()   # walks up from getwd() to the __ReadMe.xlsx sentinel
```

## Workflow

```
source("_tools/dataset_builder/load_dataset_builder.R")

audit_dataset_item(item_dir)
    ↓
build_dataset_item(item_dir, item_name, dry_run = TRUE)
    ↓
build_dataset_item(item_dir, item_name, dry_run = FALSE)
    ↓
# validate_dataset_item() is called automatically inside build_dataset_item();
# it can also be called directly for spot-checks.
```

## Hard invariants checked (validate_dataset_item)

1. **csv** — analysis CSV exists inside the paper folder
2. **tsv** — public TSV exists in `__Public/comparative-data/`
3. **readme** — README.md (or *.README.md) exists inside the paper folder
4. **definitions** — `reference_tables/*_definitions.csv` exists
5. **frozen_source** — a `*_snapshot.(csv|xlsx|xls|tsv)` file exists inside the paper
   folder; born-digital downloads are copy-renamed with bytes untouched, never converted
6. **registry_row** — item is found in `__ReadMe.xlsx` by `Item name` (never row number)
7. **tsv_name_match** — TSV file name equals `paste0(Item encoded, ".tsv")`
   - includes **no_trailing_underscore** guard: an `Item encoded` ending with `_`
     indicates a blank source column in the registry (empty-col-D failure mode)

Optional invariants return `SKIP` when the corresponding argument is not supplied.

## Errata (invariant 8)

A paper folder may carry `reference_tables/<Paper>_errata.csv` — one row per
discrepancy between our transcription, the print, or two publications
(`ERRATA_CONVENTION.md`). `validate_dataset_item()` fails on a malformed file
(`errata_file_valid`; `SKIP` when absent). After editing the file run
`render_errata(paper_dir)` to regenerate the README `## Errata` block and the
definitions-file notes; never edit those renderings by hand. Repo
transcription errors are fixed in the build `.R`, not the CSV, and logged as an
errata row.

## Reference documents

Step-by-step procedures are in:

```
_skills/build-dataset-item/references/__HOWTO_build_a_dataset_file.md
_skills/build-dataset-item/references/__HOWTO_make_a_snapshot.md
```

## File roles

| File | Role |
|------|------|
| `load_dataset_builder.R` | Entry point — source this |
| `validate_dataset_item.R` | 7-invariant checker (called by build) |
| `audit_dataset_item.R` | Pre-build 4-file convention + orphan-TSV scan |
| `build_dataset_item.R` | Runs the item build script then calls validate |
| `render_errata.R` | Errata schema check + renderer: `<Paper>_errata.csv` -> README `## Errata` block + definitions notes (see `ERRATA_CONVENTION.md`) |
| `ERRATA_CONVENTION.md` | The one-source / three-renderings errata convention |
| `COMPILER_DECISIONS_CONTRACT.md` | Stage-11 contract for the `*_refs_check` pipelines: the five compiler-decision tables (coverage inverse, error taxonomy, averaging tests, source priority, discoveries) |
| `compiler_decisions_helpers.R` | Shared R functions for stage 11 (`cd_coverage_inverse`, `cd_learn_colmap`, `cd_error_taxonomy`, `cd_averaging_tests`, `cd_source_priority`, `cd_discovery`, `cd_md_table`); sourced by the pipelines via `EVOM1_ROOT` |
| `COMPILATION_LESSONS.md` | Cross-pipeline rules for the next compilation, each traced to a stage-11 finding and to the `__merging_*` rule that encodes it |

## Notes

- `__ReadMe.xlsx` is resolved by walking up from `item_dir` to the nearest
  ancestor containing that file (same logic as `run_all_scripts_v2.R`).
  `cwd` does not need to be the repo root.
- The build-script picker excludes both `*compare*` and `*_extract_snapshot.R`
  files; extract-snapshot scripts are frozen-source helpers, not item builders.
- Public TSVs live in `__Public/comparative-data/`, not inside paper folders.
  `audit_dataset_item()` flags any `.tsv` found inside a paper folder (other
  than a `*_snapshot.tsv` frozen source) as an orphan.
