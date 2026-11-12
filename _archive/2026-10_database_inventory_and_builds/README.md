# Database inventory and build pass — 30–31 October 2026

Point-in-time inventory of the registry against the filesystem, and the two
build passes that followed it.

| File | Role |
|---|---|
| `inventory_database.py` | read-only registry + filesystem inventory; wrote the two `database_inventory_*` files |
| `database_inventory_2026-10-30.md` / `.json` | the inventory (counts, progress labels, file presence) |
| `build_completion_2026-10-30.md` | 13 prepared items rebuilt from saved scripts and frozen snapshots |
| `database_items_build_20261031.md` | build and TSV-export pass for the large born-digital database items |

Status: finished; superseded by later registry audits (see `../registry_audits/`).
For a current inventory, re-run `inventory_database.py`. It writes to `_checks/`
(its repo-root depth was raised to `parents[2]` on the move), so a new report
lands there.
Moved here from `_checks/` on 2026-11-11.
