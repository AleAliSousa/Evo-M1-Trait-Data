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
5. **frozen_source** — `*_snapshot.csv` (frozen source) exists inside the paper folder
6. **registry_row** — item is found in `__ReadMe.xlsx` by `Item name` (never row number)
7. **tsv_name_match** — TSV file name equals `paste0(Item encoded, ".tsv")`
   - includes **no_trailing_underscore** guard: an `Item encoded` ending with `_`
     indicates a blank source column in the registry (empty-col-D failure mode)

Optional invariants return `SKIP` when the corresponding argument is not supplied.

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

## Notes

- `__ReadMe.xlsx` is resolved by walking up from `item_dir` to the nearest
  ancestor containing that file (same logic as `run_all_scripts_v2.R`).
  `cwd` does not need to be the repo root.
- The build-script picker excludes both `*compare*` and `*_extract_snapshot.R`
  files; extract-snapshot scripts are frozen-source helpers, not item builders.
- Public TSVs live in `__Public/comparative-data/`, not inside paper folders.
  `audit_dataset_item()` flags any `.tsv` found inside a paper folder as an
  orphan.
