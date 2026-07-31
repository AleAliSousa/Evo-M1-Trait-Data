# Wiring HH, Watson & Paxinos 2013 (mouse 18 cortical areas) into `__merging_cellcounts`

The data is **already built** — `HerculanoHouzel_etal_2013_Table1-a.csv` (18 functional
areas) / `-b.csv` (7 groups), snapshots, definitions, README, and public TSVs
(`10.3389%2Ffnana.2013.00035_Table1-a.tsv` / `-b.tsv`) all exist. It is **not consumed by
any merge**: it appears in no `item_name` list (`cellcounts_compiled.R`,
`cortical_areas_compiled.R`), so its mouse per-area neuron/other-cell counts never reach the
compiled dataset. Wiring it in is the lowest-effort item in the HH coverage-gap audit — but
it is **not just a term file**, because of the table's shape.

## The shape problem (why a standardized-terms file alone isn't enough)

The cell-count merge reads each source as **one wide row per species** (`Species` +
measure columns) and pivots to long. `Table1-a` is **long in `Area`** — 18 rows, all
`Mus musculus`. Fed as-is, every row shares `Species = Mus musculus` and the same column
names, so the pivot/dedup would collapse the 18 areas into one. The `Area` value must
become part of the **variable name** before it can enter the long merge.

## Required step: reshape long-by-area → wide area-prefixed

Add a small reshape (either a new `Herculano-Houzel_etal_2013_Table1-a_cellcounts.R` that
writes a wide TSV, or a pre-step in the merge) producing one `Mus musculus` row with
area-prefixed columns, e.g.:

```
Species        Infralimbic_N.n  Infralimbic_O.n  Infralimbic_N.p.mm2  ...  Motor_N.n  ...
Mus musculus   114397           178738           44851                ...  <M1/M2>    ...
```

Column → term rule (per area A):
- `Neurons`      → `Cortex_<A>_N.n`
- `OtherCells`   → `Cortex_<A>_O.n`
- `N_per_mm2`    → `Cortex_<A>_N.p.mm2`
- `N_per_mm3`    → `Cortex_<A>_N.p.mm3`
- `Thickness_mm` → `Cortex_<A>_Thickness.mm`

These are **regional** cortical terms — kept **separate**, never pooled into whole-cortex
`CerebralCortex_N.n` (mouse already has that from HH 2015). Same rule the
`__merging_cortical_areas` merge uses for `M1_Surface_Area.mm2`. See the shared design note
in `__merging_cellcounts/HH_coverage_gaps_scaffold.md`.

`is_M1 = 1` marks the Motor area (M1+M2) — the headline row for the M1 focus of this repo.

## Alternative

If per-area cortical cell counts feel out of place next to whole-structure counts, this
table is a better fit for the **`__merging_cortical_areas`** merge (which already handles
regional cortical traits) or a dedicated `__merging_cortical_cellcounts`. Pick one home for
all regional cortical cell counts (this table + Gabi 2016 + Ribeiro 2013) together.

## Needs (blockers)

- [ ] Shared regional-term design decision (scaffold manifest).
- [ ] Reshape `Table1-a` long→wide (area-prefixed columns) + write a wide TSV.
- [ ] `standardized_term_by_reference/HerculanoHouzel_etal_2013_Table1-a_standardized_terms.csv`
      mapping the reshaped columns (stub created alongside this note).
- [ ] Add the reshaped item to the chosen merge's `item_name`; re-run.

Status: **SCAFFOLD** — wiring documented; reshape + term file to complete. Data already built.
