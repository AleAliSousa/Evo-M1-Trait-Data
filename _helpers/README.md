# `_helpers/` — sourced libraries

**The rule: nothing in here is run. Everything in here is `source()`d.**

These files define functions and stop. Running one standalone does nothing
useful, which is why `run_all_scripts_v2.R` skips the whole folder — before the
split they sat in `_tools/` and the sweep dutifully executed each one to no
effect, which also made them look like tools you could invoke.

Third category alongside [`_checks/`](../_checks/README.md) (reads and reports)
and [`_tools/`](../_tools/README.md) (changes something on demand). A helper does
neither on its own; it is machinery the other two and the paper builds borrow.

## What is here

| Helper | Provides | Sourced by |
|---|---|---|
| `openxlsx_compat.R` | `openxlsx_compatible_copy()` — makes `__ReadMe.xlsx` readable by openxlsx. OneDrive rewrites the workbook in two ways openxlsx 4.2.8 cannot parse (a prefixed `x:workbook` namespace, and a legacy cell note expanded into AlternateContent), and there is a dangling drawing relationship that defeats openpyxl too. Never edits the source; returns either the original path or a normalised temp copy. | `_tools/file_list.R`, `_tools/restore_registry_rows.R`, and the two dated registration tools |
| `cortical_layers_source_common.R` | shared build steps for the cortical-layer sources | `Jacobs_etal_2015`, `Jacobs_etal_2016`, `Johnson_etal_2016`, `Peruffo_etal_2019` table builds |
| `restricted_data.R` | `evom1_restricted()` / `evom1_restricted_file()` — the **only sanctioned read across the public/private boundary**. Resolves the private repo from `EVOM1_RESTRICTED` or the default layout and stops with an explanatory message if it is not mounted. See `REPO_BOUNDARY.md`. | `DosSantos_etal_2020_unpublished.R` |

## Naming

`_helpers` rather than `R/` deliberately. `R/` is the R **package** convention,
where it holds every function definition and `library()` loads it; outside a
package it has come to mean "all the project's R code", which would be wrong here
— the ~220 paper build scripts live in their own folders and are not in here. The
other conventions in circulation are `lib/`, `utils/`, `_functions/` and
`_shared/`; `_helpers` was chosen because it matches the register of its siblings
(`_keys`, `_checks`, `_tools`, `_archive`: single underscore, lowercase,
plain-English plural naming a role).

## Adding one

A file belongs here if, and only if, another script `source()`s it. Anchor the
path from the repo root rather than relative to the caller, so a paper folder and
a tool can both reach it:

```r
source(file.path(root_dir, "_helpers", "openxlsx_compat.R"))
```

If it is useful to run on its own, it is a tool or a check, not a helper.
