# What to do after changing a source TSV

A runbook for keeping the volume merge (and the DeCasien comparison) consistent whenever a
per-paper source table in `__Public/comparative-data/*.tsv` changes. Distilled from the deSousa
2010 incident, where the TSV was rebuilt (columns renamed, cm³→mm³, V1/LGN left-only → both-sides)
but the downstream references still pointed at the old schema, so the pipeline errored with
`paper_long('deSousa_etal_2010_Table1'): no measured columns matched the term map`.

The golden rule: **a source TSV never stands alone.** Several files describe how to read, convert,
and reconcile it. If any of those descriptions no longer matches the TSV, the run either errors
loudly or (worse) silently drops or mis-scales data.

---

## The dependency chain — everything that reads a source TSV

When `__Public/comparative-data/<encoded>.tsv` changes, these are the downstream consumers, in the
order the pipeline touches them:

1. **`__ReadMe.xlsx`** (sheet `Sheet1`, columns `Item name` → `Item encoded`) — maps a paper's item
   name to its TSV filename (`<Item encoded>.tsv`). This is how the compile scripts find the file.
2. **`standardized_term_volumes.csv`** (the term map: `Original_Term, Reference, Standardized_Term`)
   — maps each TSV **column name** to a canonical term. Matching is case- and separator-insensitive
   (`neocortex_MM3` ≈ `Neocortex_mm3`), but the *stem* must match.
3. **The paper-specific reshape** inside `paper_long()` in **both** `volumes_compiled.R` **and**
   `volumes_compiled_DeCasien.R` — the `if (it == "<item>")` block that does unit conversion
   (cm³/cc→mm³, mg→g), per-specimen → species-mean aggregation, L+R bilateral joins, or
   structure-rows → columns pivots.
4. **`laterality_known.csv`** (`Reference, Original_Term, side, required_suffix, note`) — registers
   columns measured from one hemisphere, so they carry a `_left`/`_right`/`_unilateral` suffix and
   are never averaged against a both-sides value.
5. **`_keys/volumes_species_overrides.csv`** (`Reference, variant_name, accepted_name, note`) and
   **`_keys/Stephan/species_key.csv`** — curated species-name reconciliation, keyed by
   (Reference, raw name). Curated names win over the NCBI backbone.
6. **The DeCasien comparison** (moved 2026-09-05 to
   `Evo-M1-Trait-Data-restricted/restricted_checks/DeCasien_Higham_2019/comparison/
   DeCasien_Higham_2019_SupplementaryData1-BrainRegion.R` — all checks live in the restricted repo
   now), which has its **own** dependencies on the raw TSVs:
   - the anatomy **crosswalk** (`xwalk`: DeCasien region → our `*_Vol.mm3` term);
   - the **per-specimen supplement** (`unf_spec`) that reads several raw TSVs directly with
     hard-coded column names and conversions (Bauernfeind Table 1+2, MacLeod Table 1+2,
     Barger 2007, Barger 2014, Sherwood 2004, Bush & Allman);
   - `bilateral_terms` and `stephan_sources`.

A change you make to the canonical merge for files 1–5 may also need to be reflected in the
DeCasien comparison's own copies of the same logic (it reads this repo's live tables, but the
crosswalk/per-specimen-supplement logic above lives in its own script).

---

## Decide what actually changed, then follow the matching checklist

### A. A column was renamed (or added / removed)
This is what broke deSousa.

- [ ] Update the affected rows in `standardized_term_volumes.csv` so `Original_Term` = the new TSV
      column name, mapped to the correct `Standardized_Term`.
- [ ] If the paper uses a **structure-in-rows** layout (its term map lists structure *values*, not
      column headers — e.g. Zilles & Rehkämper 1988, Stimpson Table S2), the names to edit are the
      structure labels, and the relevant `if (it == …)` reshape reads a `structure` column. Update
      there, not by treating the raw headers as measures.
- [ ] If a column was **added** and you want it, add a term-map row; otherwise it is silently
      ignored (that's fine).
- [ ] If a column was **removed**, delete its term-map row (and any `laterality_known.csv` row).

### B. Units changed (cm³↔mm³, cc↔mm³, mg↔g, kg↔g)
The merge stores **mm³** for volumes, **Brain_Mass.mg**, **Body_Mass.g**.

- [ ] Find the paper's `if (it == "<item>")` block in `volumes_compiled.R` **and**
      `volumes_compiled_DeCasien.R`. Adjust or remove the `* 1000` / `/ 1000` factor so the output
      is in the target unit.
- [ ] If the TSV is now *already* in the target unit, neutralise the old conversion (as with
      deSousa, whose `across(ends_with("_cm3"), *1000)` is now a harmless no-op because no `_cm3`
      columns remain).
- [ ] Mirror the change in the DeCasien **`unf_spec`** block if that paper is one it reads directly.

### C. Laterality changed (one-side ↔ both-sides)
- [ ] If a column became **both-sides**: remove its `laterality_known.csv` row and drop the
      `_left`/`_right`/`_unilateral` suffix from its `Standardized_Term`.
- [ ] If a column became **one-side**: add a `laterality_known.csv` row and add the suffix to its
      term; step 7 will build the both-sides estimate.
- [ ] Sanity-check the value against a known both-sides source (deSousa's rebuilt area-striata =
      1918 matched Frahm's both-hemisphere figure, confirming it is genuinely both-sides).

### D. Granularity changed (per-specimen ↔ species-level)
- [ ] Update the reshape block's aggregation (`group_by(Species) %>% summarise(...)`) and any
      specimen-join keys (e.g. Bauernfeind joins Table 1 ↔ Table 2 on specimen id with the trailing
      hemisphere letter stripped).
- [ ] In the DeCasien comparison, the `unf_spec` supplement expects **per-specimen** rows for the
      papers it reads; if a TSV switched to species means, its per-specimen matches will collapse to
      one row (that's fine, but the individual DeCasien cells will only match via
      `species_mean_match`).

### E. Species labels changed
- [ ] If a raw name changed, check `_keys/volumes_species_overrides.csv` (keyed by Reference + raw
      name) — a stale `variant_name` silently stops mapping and the species falls back to NCBI or
      raw (watch for the "Species resolution … kept raw" warning).
- [ ] For DeCasien taxonomy variants, check `_keys/Stephan/species_key.csv` (rows with
      `source_publication == DeCasien`).

### F. The DOI / filename / encoding changed
- [ ] Update the `Item encoded` cell in `__ReadMe.xlsx` so `<Item encoded>.tsv` is the real file.
- [ ] If you cannot edit the registry immediately, add an `enc_override` entry in the compile
      script(s) (there is a block near the top for exactly this).

### G. Only the values changed (same schema)
- [ ] No structural edits needed. Just re-run and **verify** (below) — expect the flags/deviation
      counts and DeCasien match rates to move.

---

## Re-run

From the repo root (the scripts find the root by walking up to `__ReadMe.xlsx`):

```
Rscript __merging_volumes/volumes_compiled.R                                       # canonical merge
Rscript restricted_checks/DeCasien_Higham_2019/comparison/DeCasien_Higham_2019_SupplementaryData1-BrainRegion.R
                                                          # (in Evo-M1-Trait-Data-restricted) DeCasien comparison
```

The DeCasien-subset build (`volumes_compiled_DeCasien.R`, a reverted, non-recommended experiment)
was retired 2026-09-05 along with its outputs; the comparison above always compares against the
canonical core merge now. `run_all_scripts_v2.R` runs the canonical set (public repo only).

---

## Verify (do not skip)

The pipeline is designed to fail loudly; read the console.

- [ ] **Hard errors** mean a broken link in the chain:
  - `no measured columns matched the term map` → term map vs TSV column mismatch (checklist A).
  - `TSV not found -> …` or `no encoding (not in __ReadMe.xlsx …)` → registry/encoding mismatch (F).
- [ ] **Laterality guard** prints either `Laterality guard OK: N one-side column(s) correctly
      suffixed.` or a warning naming the offending columns — resolve before trusting the output.
- [ ] **Species resolution** warns if any (source, name) pair fell back to raw — fix via the
      overrides key (E).
- [ ] **Row counts / spot values**: open `volumes_unfiltered_DeCasien.csv` and confirm the changed
      paper's rows are present, in the right unit, under the expected species; spot-check one known
      value against the paper.
- [ ] **Deviation flags**: skim `volumes_flags*.csv` for new `deviation` or
      `estimated_bilateral_from_unilateral` entries.
- [ ] **DeCasien comparison**: check the message line and `DeCasien_Higham_2019_FINDINGS_DeCasien.md`
      — `match`, `species_mean_match`, `value_match_other_structure`, and `decasien_only` counts.
      A sudden jump in `decasien_only` or `value_match_other_structure` for the paper you touched
      signals a units or crosswalk regression.

---

## Quick reference

| Symptom in the run | Most likely cause | Fix |
|---|---|---|
| `no measured columns matched the term map` | TSV column renamed | Update `standardized_term_volumes.csv` (A) |
| `TSV not found` / `no encoding` | filename/DOI changed | Update `__ReadMe.xlsx` or add `enc_override` (F) |
| Values ~1000× off | unit change not mirrored | Fix the `if (it==…)` conversion in both compile scripts (B) |
| Laterality guard warning | one-side/both-sides change | Update `laterality_known.csv` + term suffix (C) |
| "kept raw" species warning | raw species label changed | Update `_keys/volumes_species_overrides.csv` (E) |
| DeCasien `decasien_only` spikes for one paper | comparison crosswalk / `unf_spec` stale | Update `xwalk` / `unf_spec` in the comparison script (6) |

> Reminder: files 1–5 are shared by `volumes_compiled.R` and `volumes_compiled_DeCasien.R`. When you
> fix one, re-run **both**, and remember the DeCasien comparison reads some raw TSVs a second time in
> its `unf_spec` supplement.
