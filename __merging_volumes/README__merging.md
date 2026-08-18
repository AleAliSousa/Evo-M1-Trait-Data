# Merging histologically-derived brain-structure volumes

Pipeline for compiling the comparative brain **volume** dataset — the counterpart of
`../__merging_cellcounts/`, built by copying that folder's structure. **One data type
only**: volumes from sectioned, stained, shrinkage-corrected brains. (Cell-count /
optical-fractionator data live in `../__merging_cellcounts/`.)

## Teams and the two-tier resolution rule

By analogy to the cell-count merge (Herculano-Houzel updating her own collection →
take most recent; Kverkova a different lab → average): a duplicate
(species × structure × measure) is resolved by **which team measured which specimens**.

**Tier 1 — the Stephan / Düsseldorf collection** (one evolving dataset by a coauthor
group on the same C&O Vogt specimens). Duplicates resolved by **most recent
publication date** (the later paper supersedes the earlier), *unless flagged*:

> Stephan 1970 / 1981 / 1982 / 1984 / 1987, Frahm 1982 / 1984 / 1994 / 1997 / 1998,
> Baron 1983 / 1987 / 1988 / 1990, Matano 1985a / 1985b / 1986 / 1992, and
> Zilles & Rehkämper 1988.

Worked example: the amygdala is taken from **Stephan 1987** (its re-measurement)
over Stephan 1981 — e.g. *Alouatta seniculus* 426 (1987) not 413 (1981).

**Tier 2 — independent series** (different specimens / labs / segmentation, same data
type). Each is its **own team**; across teams the values are **averaged** with the
Tier-1 result:

> de Sousa 2010 + 2013, MacLeod 2003, Bauernfeind 2013, Bush & Allman 2003/2004,
> Smaers 2011 Tables 1–2, Semendeferi 1998/2001, Sherwood 2005, **Barger 2007**
> (amygdala; team `Zilles` = the Semendeferi/Zilles collection), Ashwell 2020,
> **Reep 2007**, and **Kverkova 2018**.

## Hemispheres: the merge unit is the COMBINED (left + right) volume

Brain-structure volumes are merged as **whole-structure, both-hemisphere** values:
- where a paper measured **one hemisphere and doubled it** (assuming symmetry) or already reports a
  both-sides total (Stephan/Frahm/Baron/Zilles/Matano; MacLeod `hemisphere` = both lateral hemispheres
  summed; Barger `amygdaloid_complex_total` = L + R), the reported both-sides volume is used directly;
- where a paper reports **left and right separately** (Smaers 2011 `frontal_*_total` = left + right),
  the merge uses **left + right added**.

### Who did the doubling: `doubling` in `laterality_known.csv`

A both-hemisphere number can be a both-hemisphere **measurement** or a **2× estimate from one side**,
and if it is an estimate the ×2 was applied either by the paper's authors or by this merge. That is
recorded per source column in `laterality_known.csv`:

| `doubling` | what the printed number is | suffix on its standardized term | how the merge records it |
|---|---|---|---|
| `none` | one side, **as measured** | **required** (`_left` / `_right` / `_unilateral`) | if a both-sides partner is wanted, step 7 builds it → `estimated_bilateral_from_unilateral` |
| `by_source` | **already 2× one side**, doubled by the authors | **forbidden** — the value legitimately stands for both sides | used exactly as published, never doubled again → `published_bilateral_estimate` |

> **Neither of these is a veto.** `estimated_bilateral_from_unilateral` and
> `published_bilateral_estimate` are *provenance*: they say how a both-sides number came to exist and
> they never remove a value. A value is only ever dropped by an `action = skip` row in
> `volumes_select_value_flags.csv`. Both live in the generated `volumes_flags.csv`, not in the
> hand-edited veto registry, precisely so the two cannot be confused.

**`by_source` columns — de Sousa.** de Sousa et al. (2010) measured the left hemisphere only and
state in Methods: *"In all statistical analyses, left V1 and left LGN volumes were doubled to estimate
the total (left plus right hemisphere) volumes of V1 and LGN for each specimen because the volumes of
V1 (Amunts et al., 2007a) and LGN (H. Frahm, unpublished observation) apparently do not exhibit major
asymmetries."* This is a deliberate, argued estimator, not an error — hence provenance, not a veto.

- **de Sousa 2010 Table 1** prints the *undoubled* left values → `doubling = none`, `_left` suffix.
- **de Sousa 2010 Supp. Table 2** prints the doubled figures → `doubling = by_source`. Verified: its
  hominoid V1 = 2 × mean(Table 1 left V1) exactly (Homo 15.2 = 2×7.63; *Pan paniscus* 11.6 = 2×5.8;
  *Gorilla* 9.1 = 2×4.55; *Hylobates lar* 4.1 = 2×2.05). Not currently in any merge, but its term map
  already points V1 at the unsuffixed `Area_striata_grey_matter_Vol.mm3`, so it is a trap if ingested.
- **de Sousa 2013 Table 1** (LGN) → `doubling = by_source`, and it is the one doubled column that is
  **live in the merge**: it enters as the unsuffixed `Corpus_geniculatum_laterale_Vol.mm3` and is
  Tier-2 averaged with the Stephan-collection LGN. The 2013 paper never restates the doubling — its
  Methods say only *"A minimum of one left hemisphere was investigated per species, although both
  right and left hemispheres were investigated for most specimens."* The evidence that it inherits
  the 2010 convention is that its LGN values reproduce 2010 Supp. Table 2 exactly for the species
  they share (*Homo sapiens* 0.335; *Pongo pygmaeus* 0.259; *Hylobates lar* 0.166).

Because the ×2 is already in those published numbers, `bilateral_stems_exclude` stops step 7 doubling
`Area_striata_grey_matter` and `Corpus_geniculatum_laterale` a second time.

**Reep 2007 is also `by_source`.** Its Table 1 values were calculated from one measured side,
shrinkage-corrected, and multiplied by two by the authors (right side for 28 specimens; left for
*Eumetopias jubatus*). All 11 regional columns therefore remain unsuffixed, are used exactly as
published, and receive `published_bilateral_estimate` provenance. Reep's diencephalon excludes
globus pallidus while its striatum includes it, so those two columns use definition-specific terms
rather than colliding with Stephan-style diencephalon and striatum.

**Bauernfeind is the other case, not the same one.** Bauernfeind 2013 did *not* double anything:
Table 1 is the measured left insula and Table 2 the measured right, so both are `doubling = none`.
Where a species has only a left value, the ×2 is **this project's**, and it is recorded as
`estimated_bilateral_from_unilateral`. Same arithmetic, different author — which is exactly what the
`doubling` column exists to keep apart.

### One-side-only structures (suffix-only laterality convention)

Some sources report a structure from **one side only**. Such a value must never be silently compared,
superseded, or averaged against a both-sides volume — that is exactly what produced the Baron 1988 vs
Stephan 1981 vestibular ≈ 2× mismatch. We mark these in the **standardized term itself** with a laterality
suffix — `_unilateral` (side unspecified), `_left`, or `_right` — so a one-side value becomes a *distinct
variable* that cannot collide with a both-sides column. Current one-side columns are registered in
`laterality_known.csv` and enforced by the **laterality guard** in `volumes_compiled.R` (it warns if the
registry and the term map disagree):

| Source | Columns | Side measured | `doubling` | Suffix |
|---|---|---|---|---|
| Stephan 1981 Tables XII/XIII | Complexus vestibularis + 4 vestibular nuclei (codes 35–39) | one side (per Baron 1988) | `none` | `_unilateral` |
| Bauernfeind 2013 | insula: granular, dysgranular, agranular, FI, total | **left** = Table 1; **right** = Table 2 | `none` | `_left` / `_right` |
| Semendeferi 1998 Table 2 | area 13 (orbitofrontal), n = 1/species | right | `none` | `_right` |
| Semendeferi 2001 Table 2 | area 10 (frontal pole), n = 1/species | right | `none` | `_right` |
| Sherwood 2005 Table 1 | cranial motor nuclei VII, Vmo, XII | left | `none` | `_left` |
| de Sousa 2010 Table 1 | V1 (area striata grey), LGN — printed **undoubled** | left | `none` | `_left` |
| de Sousa 2010 Supp. Table 2 | V1, LGN — printed **already ×2** | left | **`by_source`** | *(none — value stands for both sides)* |
| de Sousa 2013 Table 1 | LGN — printed **already ×2** | left | **`by_source`** | *(none — value stands for both sides)* |
| Reep 2007 Table 1 | 11 major brain components — printed **already ×2** | right (28 spp.); left (*Eumetopias jubatus*) | **`by_source`** | *(none — value stands for both sides)* |

Left (Table 1) and right (Table 2) are combined into whole-insula both-hemisphere volumes in
`volumes_compiled.R` (step 7): both sides → left + right; left-only species → 2× left, flagged.

For `doubling = none` columns the numeric values are **not** doubled in place; a both-sides estimate, if
needed, is derived downstream as `2 ×` and flagged `estimated_bilateral_from_unilateral`, never overwriting
the original. For `doubling = by_source` columns the ×2 is already in the published figure, so the merge
does nothing to the number and only records `published_bilateral_estimate`. Individual-hemisphere
volumes from both-sides papers (e.g. Smaers `frontal_white_left_cm3`/`_right_cm3`, Barger `amygdaloid_complex_L`/`amygdaloid_complex_R`) are
preserved in each paper's source CSV/TSV but not carried into the merged table.

**Adding a one-side column:** register it in `laterality_known.csv` with the side it was measured from
and who did any doubling. If `doubling = none`, give its standardized term the matching suffix; if
`doubling = by_source`, give it the plain both-sides term and leave `required_suffix` empty. The guard
warns at compile time in either direction — a missing suffix on a measured one-side column, or a
laterality suffix on a value that already represents both sides.

Worked examples: *Microcebus* neocortical grey = mean(Frahm 1982, Bush 2003);
*Pan troglodytes* LGN = mean(Stephan-collection 356, deSousa-team mean 297) = 327.

**Exception — body & brain weight** (specimen attributes, often re-used, not refined):
the **Stephan 1981 reference** is kept (newer values only fill gaps); these are **not**
cross-team averaged.

**Flags** (`volumes_flags.csv`): where a superseding value deviates > 50 % from the
value it replaces, it is flagged for review (the most-recent value is still taken).
This auto-surfaces things like Baron 1988's "both sides" vestibular volumes (≈ 2× the
Stephan 1981 one-side figures) and is where your manual exceptions live (e.g. you kept
Frahm 1984 over de Sousa for *Avahi laniger* area striata).

*Status of the amygdala-complex flags (Stephan 1987 vs 1981).* These are **not** a one-side/both-side
issue: 1987 `amygdala_total` is defined to equal the 1981 amygdala and Barger AC, and 74/76 species agree
within ±25 % (only Homo and Crocidura deviate). They resolve as:
- **Callithrix jacchus NTO** (0 vs 0.195): the 1987 `0` is a "not determinable with certainty" sentinel
  (per the 1987 data dictionary), now mapped to `NA` in `volumes_compiled.R`, so the real 1981 value 0.195
  is kept and the flag clears.
- **Homo sapiens amygdala** (1981 3015 < Barger 3805 < 1987 5286.6): a genuine remeasurement disagreement,
  resolved by **cross-team averaging** once Barger (team `Zilles`) is added → 4545.8, matching the curated
  `../Stephan_etal_1987/comparison/Stephan1987_AMY_vs_Barger2007_AC.csv` merged mean. The Tier-1 flag still
  fires (informational); the final merged value is the average.
- **Crocidura flavescens** (≈ 1.8–2.0×): a **taxonomy lump** — the 1981 row is "Crocidura *occidentalis*",
  keyed to accepted "Crocidura *flavescens*" to meet the 1987 row. **Verify these are the same
  specimens/species** before trusting the gap; this is the only amygdala flag still genuinely open.

## Steps

1. `standardized_term.R` → `standardized_term_volumes.csv` (stacks the per-reference
   `standardized_term_by_reference/<Reference>_standardized_terms.csv` maps:
   `Species`, `Body_Mass.g`, `Brain_Mass.mg`, one `<CanonicalStructure>_Vol.mm3` each).
2. `volumes_compiled.R` → reads each paper's DOI/PMID-coded TSV, applies the terms, resolves
   species (step 4, below), runs the two-tier resolution above. Paper-specific reshapes (step 3):
   Zilles 1988 (structure-rows → one *Pongo* row), Bauernfeind 2013 & MacLeod 2003 & **Barger 2007**
   (per-individual → species means; Bush & MacLeod & Barger cm³ → mm³; Bauernfeind brain mg → g);
   **Stephan 1987** NTO `0` → `NA` (not-determinable sentinel).
   Outputs: `volumes_long.csv`, `volumes_wide.csv`, `volumes_flags.csv`; audit
   `volumes_unfiltered.csv`; species review table `volumes_source_species_ids.csv`; source
   inventory `volumes_species_sources.csv`. Needs `tidyverse`, `readxl`, **`taxizedb`**.

### Species resolution (step 4 — mirrors `../__merging_cellcounts` §4, with extras)

No per-paper "tokens" any more. The species **column** is found from the term map (the
`Original_Term` whose `Standardized_Term == "Species"`), and species **names** are resolved in a
single layered pass over the long table:

- **NCBI backbone** — `taxizedb::name2taxid`/`taxid2name` give the preferred scientific name for
  each raw name (source-independent), exactly as the cell-count merge does.
- **Curated overrides win** — the project's deliberate taxonomy decisions (genus-level lumping like
  `Gorilla sp.`/`Pongo sp.`, subspecies→binomial, synonyms like *Lophocebus albigena*) override
  NCBI. They live in `_keys/volumes_species_overrides.csv` (`Reference, variant_name,
  accepted_name, note`) and are applied **source-aware** — keyed by `Reference` (= item name) **and**
  the raw variant — so the same label can resolve differently in different papers. This file was
  generated from the per-team `_keys/*/species_key.csv` (non-identity rows only), re-keyed from the
  old cryptic `source_publication` tokens to item names; edit it directly to add/adjust a decision.
- **Order**: curated → else NCBI preferred → else the raw name (flagged `unresolved_raw`).
- **Review table** `volumes_source_species_ids.csv` records, per (Source, raw name): NCBI name,
  curated name, final name, and flags (`flag_curated_overrides_ncbi`, `flag_unresolved`) for sign-off.
- Variants that now collapse to one accepted name are **aggregated/averaged** by the two-tier rules
  in steps 5–6.
3. **Hemisphere reconciliation** (step 7 of `volumes_compiled.R`; see `volumes_wide.NOTE.md`).
   Add whole-structure both-hemisphere variables (no laterality suffix): sum left + right where
   both sides exist (Bauernfeind insula = Table 1 + Table 2); otherwise estimate as 2× the one
   measured side and flag it (`estimated_bilateral_from_unilateral`), preferring a genuine
   both-sides value over an estimate. One-side columns are kept for traceability.

## Current state

**57 citable source tables merged → 300 species × 135 variables** (2026-08-15).
Tier 1 comprises 39 printed tables from Stephan 1970/1981/1982/1984/1987,
Frahm 1982/1984/1994/1997/1998, Baron 1983/1987/1988/1990, Matano 1985a/1985b/1986/1992,
and Zilles & Rehkämper 1988. Tier 2 comprises 18 independent tables from de Sousa 2010/2013,
MacLeod 2003, Bauernfeind 2013 (insula sides retained explicitly), Bush & Allman 2003/2004,
Smaers 2011, Barger 2007, Ashwell 2020, Semendeferi 1998/2001, Sherwood 2005, Reep 2007,
and Kverkova 2018.

The 2026-08-15 intake added, in order:

- **Matano 1992** — 45 species × four bilateral inferior-olive volumes (180 contributions);
- **Kverkova 2018 Table S1** — 11 rodent species × 14 regional volumes plus body and brain mass
  (176 contributions; brain mass converted g→mg), adding all 11 species;
- **Smaers 2011 Supplementary Table 2** — 19 primates × left, right, and printed-total prefrontal
  grey/white volumes (114 contributions; per-individual cm³→species-mean mm³). The printed totals
  equal the retained left + right values after aggregation.

**Canonical contract: core means core-only, and the script now enforces it.**
`volumes_compiled.R` owns the unsuffixed canonical outputs and stops if a DeCasien/expanded-only
item enters its `papers` table. The 2026-06-24 expansion that folded the
DeCasien sources (Sherwood 2004 `_TABLEI`, Barks 2014, Rilling & Insel 1998/1999, Stimpson 2015,
and the `*_viaDeCasien` tables) *into* this merge was reverted: cross-team averaging shifted
great-ape values away from DeCasien's single-source figures (44 regressions; see
`_EXPANSION_FINDINGS.md`). Those papers are no longer compiled here. The merge-vs-DeCasien
comparison lives in its own scripts. Two ways to compare:
(1) **value-match** (recommended; needs only the canonical core):
`../DeCasien_Higham_2019/DeCasien_Higham_2019_SupplementaryData1-BrainRegion.R` value-matches
DeCasien's published MOESM3 numbers against this core merge's `volumes_unfiltered.csv` /
`volumes_long.csv`. It now takes an optional `merge_suffix` (default `""` = core).
(2) **DeCasien source-subset build** (`volumes_compiled_DeCasien.R`): a dedicated sibling containing
only the volume-source papers cited by DeCasien & Higham, writing `volumes_*_DeCasien.csv` and
`DeCasien_vs_merge_comparison_DeCasien.csv`. It is a reproduction/comparison subset, not an
expanded canonical merge. Historical documentation that called it `EXPANDED` described an obsolete
experiment; no `volumes_*_EXPANDED.csv` file is canonical or generated now.

Species harmonization: `MacLeod_etal_2003_` and `Smaers_etal_2011_*` now carry species_key tokens
`MacLeod2003` / `Smaers2011` (added to `_keys/Stephan/species_key.csv`), which lump great apes to the
dataset convention (`Gorilla sp.`, `Pongo sp.`) and fix Smaers synonyms — replacing the old NA
("species as-is") that had left `Gorilla gorilla` etc. unmerged. Bugfix 2026-06-28: the
generic wide→long step now excludes the species column from `keep`, so a paper whose species column
is literally named `Species` (Sherwood 2004) no longer has its names coerced to NA doubles — that
was the `bind_rows` "`..N$Species <double>`" crash.

**Note:** `Sherwood_etal_2004_I/` is a *different* paper (M1 GLI cytoarchitecture, not volumes)
— not the ref-64 source. The ref-64 great-ape volumes are `Sherwood_etal_2004_TABLEI`. Baron
1987 olfactory and Baron 1988 vestibular abbreviations are mapped (BOL→Bulbus_olfactorius,
VC→Complexus_vestibularis, VI→…descendens, etc.) — sanity-check those against the papers.

## Cross-publication comparisons (`crosspub_*`)

Some later papers **re-use earlier data under new labels** (different species names and/or anatomical
terms). To detect this — *if the values are identical, it is the same data* — `crosspub_value_match.R`
matches one publication's volumes against the merged dataset and the per-source TSVs **by value**
(species-agnostic, within tolerance), writing `crosspub_<paper>_value_match.csv`. First target:
**Smaers 2017** Table S1 (its cortical-area volumes vs the Stephan-collection / de Sousa / Smaers 2011
sources), using `../Smaers_etal_2017/primary_source_checks/species_name_changes_2011_to_2017.csv`
(which already records the 2011→2017 relabelings, e.g. *Cercocebus*→*Lophocebus albigena*, "values identical").

## Adding a paper
1. Create `standardized_term_by_reference/<Reference>_standardized_terms.csv`.
2. Ensure its TSV is in `__Public/comparative-data/`; add it to `item_name` with its
   `team` (default `Stephan_collection`) and `token` (species_key) in `volumes_compiled.R`.
3. Re-run `standardized_term.R`, then `volumes_compiled.R`.
