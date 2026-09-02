# Dataset Builder

Repository-level tooling for Evo-M1-Trait-Data.

Purpose:

- audit dataset items
- run build scripts
- validate outputs
- check repository invariants

The builder follows:

- __HOWTO_build_a_dataset_file.md
- __HOWTO_make_a_snapshot.md

Workflow:

audit_dataset_item()
    ↓

build_dataset_item(dry_run = TRUE)
    ↓

build_dataset_item(dry_run = FALSE)
    ↓

validate_dataset_item()

Hard invariants checked:

- frozen source exists
- analysis CSV exists
- public TSV exists
- README exists
- definitions file exists
- item exists in __ReadMe.xlsx
- TSV name matches Item encoded