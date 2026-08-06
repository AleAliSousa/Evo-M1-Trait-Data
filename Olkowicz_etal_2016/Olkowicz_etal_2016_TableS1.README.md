# Olkowicz, Kocourek, Lučan, Porteš, Fitch, Herculano-Houzel & Němec 2016 — bird brain cell counts

Olkowicz S, Kocourek M, Lučan RK, Porteš M, Fitch WT, Herculano-Houzel S, Němec P (2016).
*Birds have primate-like numbers of neurons in the forebrain.* PNAS 113(26):7255–7260.
doi:**10.1073/pnas.1517131113**

## Why it's here (coverage gap — new SPECIES, new class)

Isotropic-fractionator neuron / non-neuronal counts for **~28 bird species** (songbirds,
parrots, and others), with a bird-specific region scheme (telencephalon/pallium, cerebellum,
"rest of brain," optic tectum). S. Herculano-Houzel is a co-author (Němec lab lead). This is
the single biggest raw species gain in the audit and the first non-mammal.

## ⚠️ BLOCKED — do not ingest into the mammal merge yet

The dataset's taxonomy backbone is **mammal-only**: `_keys` resolves against the Mammal
Diversity Database (MDD) and `species_reference.csv` has no `Class` column, so any bird is
**silently dropped** at taxonomy resolution. This is documented in
`SCOUTING_AND_SCOPING.md` (Part 2) (the four real gaps → #1; do-first checklist →
step 4: "De-MDD the resolver — add a `Class`-gated non-mammal path — **before** ingesting
any non-mammal").

Prerequisites, in order:

1. Add `Class` to `_keys/species_reference.csv`; backfill existing rows to `Mammalia`.
2. Give the resolver a `Class`-gated non-mammal path (GBIF backbone is the usual choice).
3. Decide whether avian forebrain/tectum counts share the cell-count merge (with a
   `trait_scope`/`Class` tag so mammal-only views can exclude them) or live in a parallel
   non-mammal merge.

Only then build Table S1 → snapshot → CSV → public TSV → register → add to `item_name`.

## Needs (blockers)

- [ ] Resolver + `Class` work above (SCOPING do-first steps 1, 4) — **hard prerequisite**.
- [ ] PDF + Table S1 (supplementary dataset) into `Olkowicz_etal_2016/`.
- [ ] Bird region-scheme terms (telencephalon/pallium, cerebellum, RoB, optic tectum).
- [ ] Register + extract + standardized-terms + `item_name` (mammal merge only if step 3
      says so; otherwise the new non-mammal merge).

Status: **SCAFFOLD — BLOCKED**. Folder + README + stub `.R` + definitions stub only.
Placeholder until the taxonomy resolver supports non-mammals.
