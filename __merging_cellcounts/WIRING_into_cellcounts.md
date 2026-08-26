# Wiring plan — regional (per-area) cell counts into the cell-count layer

**Written 2026-08-25.** This file was already referenced by a comment in `cellcounts_compiled.R`
(§ the HH 2013 Table1-a item) but did not exist. It records the design problem and the queue, so
the sources stay visible. **Nothing here is wired yet — this is a plan, not a build log.**

## The problem
`cellcounts_compiled.R` is organized as species × whole-structure variables (whole brain, cerebral
cortex, cerebellum, RoB …) with team-based within-team resolution (§8.2, most-recent-wins). The
built-but-unwired sources below are **per cortical AREA** (V1, V2, M1, S1 …) — a third axis. Wiring
them needs a decision: (a) reshape long→wide into per-area column families
(`V1_N.n`, `M1_N.p.mm2`, …), or (b) a separate `__merging_regional_cellcounts` product that stays
long. Option (b) avoids exploding the wide schema and mirrors how regional surfaces are kept as
separate `trait_class = regional` terms in `__merging_cortical_areas`. **Owner decision required
before any build.**

## Ready and waiting (all built, registered, public TSVs on disk)
| Source | What it holds | Team |
|---|---|---|
| `HerculanoHouzel_etal_2013_Table1-a` | mouse, 18 cortical areas (already commented in the item list) | HH |
| `Collins_etal_2010_DatasetS1` | 4 primates, per-PIECE counts/densities across the flattened cortex — would need piece→area assignment or cortex-level aggregation | Kaas |
| `Collins_etal_2016_Table1` | chimp: cortex, V1, V2, M1, S1-block, premotor-block, PFC counts + densities | Kaas |
| `Young_etal_2013_Table1` | 10 species, M1 cell/neuron densities (per g and per mm²) | Kaas |
| `Young_etal_2013_b_Table1` | baboon V1/S1/M1 + cortex counts — **excluded from merges** (epileptics + Collins-duplicate; only case 11-31 usable). Respect the folder README. | Kaas |

## Constraints to carry into the design
- **Specimen web:** the Kaas tables share specimens (chimp KAAS-PAN-11_38 in Collins 2016 = Young
  2013; baboon 09-27 in Collins 2010 = Young 2013b = Turner). Specimen-level dedupe must come from
  `_keys/specimen_crosswalk/`, not per-source hacks.
- **Teams:** these are Kaas-lab flow-fractionator data — a **new team** alongside HH and Kverkova
  in the §8 resolution logic (or in the separate regional product).
- **Doubling:** all counts are per one hemisphere. Record hemisphere basis; never silently ×2
  (laterality/doubling provenance policy).
- **Whole-cortex values:** Collins 2016 / Young 2013b whole-cortex counts LOOK like they fit the
  existing `CerebralCortex_N.n` columns, but they are single-hemisphere and largely
  specimen-duplicated — do not shortcut them in ahead of the design.
- Mota 2019's `N` (cortical neurons) stays out — it re-reports HH-team counts already merged.
