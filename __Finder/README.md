# __Finder — data discovery app

Spec: `APP_PLAN.md` Part B. Built so far: **Tab 4, "Coverage & gaps"**. Tabs 1–3 are not built yet.

```r
source("_tools/build_coverage_index.R")   # or: Rscript _tools/build_coverage_index.R
shiny::runApp("__Finder")
```

## What the Coverage tab answers

What has been collected, what is harmonized, what still needs review, and where the gaps are — per
structure, species and measurement. Statuses: ✅ available & harmonized · 🟡 available, not harmonized ·
🔵 planned · ⚪ not found. Clicking a cell lists the records behind it: source, crosswalk link,
boundary basis, source role and the reason for the status.

- **Project core** — M1, V1, EC, MEC, LEC × the core four species (Human, Mouse, Macaque, Marmoset), or
  every species in that project.
- **Broader comparison** — every structure in the crosswalk, starting from the Heiss / Kaufman / Karbowski
  metabolic-rate regions, × every measurement domain. Pick one species (Human for the Heiss-only regions)
  or all species (cells then show species counts). The co-occurrence table lists which domains have direct
  data for the same species.

## How a status is assigned

| status | rule |
|---|---|
| ✅ | direct crosswalk link **and** primary source **and** active in its merge |
| 🟡 | proxy link (containing/overlapping region, section block, PET/autoradiography ROI), **or** secondary / compilation / derived source, **or** flagged in its merge, **or** species name unverified |
| 🔵 | named target in `_keys/coverage_targets.csv` with `target_status = planned` |
| ⚪ | nothing identified; core species only; `wanted` targets are noted on these cells |

Proxy links are hidden by default. Records with different `boundary_basis` values are listed side by side,
never pooled (`_keys/SOURCE_RELATIONSHIPS.md`: `redefines_structure`, `reprints`, `derives_from`).

## Where the inputs live

The build reads mappings; it does not define them. To change a status, edit the key, then rebuild.

| file | role |
|---|---|
| `_keys/anatomy_crosswalk.csv` | concept × domain × term, with `relation`, `link_class` (direct / proxy), `boundary_basis` |
| `_keys/structure_boundary_basis.csv` | per paper: dimension (2D/3D), boundary basis, source role — e.g. the four Smaers products |
| `_keys/coverage_targets.csv` | named acquisition targets (`planned`) and unsourced gaps (`wanted`) |
| `_tools/build_coverage_index.R` | the build (read-only over the repo) |
| `__Finder/data/coverage_*.csv` | derived; regenerate, do not edit |

All key rows start as `status = drafted` and await curator confirmation, as in `source_relationships.csv`.

## Known limits

- Metabolic-rate values from Kaufman 2004 and Karbowski 2007 are review compilations; their primaries
  are not traced individually, so those records are 🟡. Heiss 2004 (human FDG-PET) is primary.
- Young 2013 (M1 cell/neuron densities) and Herculano-Houzel 2013 (mouse areas) are built but not wired
  into `__merging_cellcounts`; they show as 🔵. HH 2013 "Motor" is M1 + M2, so it is a proxy for M1.
- MEC/LEC: no data and no agreed boundary definition yet (target W003).
- The app reads `data/` locally; GitHub fetch via `_tools/lib_gh.R` (APP_PLAN B.2) is not wired yet.
