# Handoff — PGLS full-coverage plan

*Saved 19 Nov 2026 for handoff, alongside HANDOFF_next_step.md (the tree-layer
build notes). Status: plan only — no code or data changed yet. Phase 1 is the
agreed first step if this is picked up.*

# Plan — Getting the missing species into the phylogeny, and PGLS in the app

*Written 19 Nov 2026. Repo: AleAliSousa/Evo-M1-Trait-Data. All counts below were
measured on main today, not estimated.*

## The short version

The app **already has a PGLS option** (Plot tab → "Adjustments & phylogeny":
PGLS with Pagel's λ or Brownian motion, fitted with `nlme::gls` +
`ape::corPagel`). What starves it is the tree: `_keys/mammal_tree.nwk` has
**~200 tips**, because it was pruned to the old project species list
(`_keys/species_reference.csv`, 215 rows) back in August. The app's data has
since grown to thousands of species, so most species in a typical analysis are
silently dropped from the PGLS fit.

The full source tree is already in the repo — the Upham et al. 2019 DNA-only
MCC tree (`Upham_etal_2019/MamPhy_fullPosterior_BDvr_DNAonly_4098sp_topoFree_NDexp_MCC_v2_target.tre`,
**4,100 tips**). Worked example, measured today: the new brain-size merge
(`__merging_brain_size/brain_size_long.csv`) holds 3,328 species; **1,749 of
them (53%) match the full Upham tree by plain binomial** — against ~200 the
app can use today. Most of the "missing species" problem is therefore not
missing species at all: it is a stale pruning list.

## Why species are missing — four buckets

1. **In the source tree, but pruned away (the big one).** The tree build
   (`__merging_trees/build_mammal_tree.R`) resolves only the species in
   `_keys/species_reference.csv` through `tree_tip_crosswalk.csv` and prunes
   everything else. Any species added to the merges since August is absent no
   matter how good its data is.
2. **Name mismatches.** Data names vs tree tip names: synonyms, taxonomic
   splits, subspecies, spelling/encoding variants. Of the brain-size species
   not matching Upham directly, **575 have their genus in the tree** — a mix
   of genuine mammals under another name (e.g. the *Alouatta arctoidea /
   discolor / juara* split complex) and a few non-mammals. The crosswalk
   currently covers only the 214 project species (199 matched: 176 direct,
   20 by synonym, 3 by subspecies-parent).
3. **Mammals genuinely absent from Upham DNA-only.** Species with no DNA in
   the 2019 supermatrix (7 of the original 214, e.g. *Crocidura jacksoni*,
   *Fukomys anselli*), plus species described or split after 2019.
4. **Non-mammals.** The merges now include birds and reptiles (~1,000 of the
   brain-size species). No mammal tree can hold them; they are out of scope
   for this tree, permanently (see "Decisions" below).

Two small app-side losses also exist: `tip_binom()` in app.R truncates tips
to two tokens, so 3 trinomial subspecies (*Canis lupus familiaris*,
*Damaliscus pygargus phillipsi*, *Sus scrofa domesticus*) never match; and
`species_reference.csv` has known data faults (the duplicated mojibake
*Scutisorex* rows, one all-NA row, 3 rows with the defunct order
"Soricomorpha").

## The plan

### Phase 1 — Rebuild the tree at full coverage (the main fix; no new science)

1. Define the species universe as the **union of species across the
   app-facing merges** (brain size, brain volumes, body & ecology, paired
   extracts — whatever `build_data.R` bundles), not the 215-row project list.
   Keep `species_reference.csv` as the curated core, but stop using it as the
   ceiling.
2. Extend the crosswalk seed (`make_tip_crosswalk_seed.py`) to that universe.
   Auto-match exact binomials; queue everything else as review candidates,
   following the existing discipline (auto-matches only enter the build when
   promoted in `tree_tip_crosswalk.csv` / `TREE_TIP_BRIDGES`).
3. Re-run `build_mammal_tree.R` against the full Upham MCC tree; write the
   new `_keys/mammal_tree.nwk`; regenerate `tree_coverage_report.csv` so the
   new coverage (and the new missing list) is on record.
4. Fix `tip_binom()` in app.R to try the full tip label first, then fall back
   to the binomial (recovers the 3 subspecies; one line, needs a deploy).
   Clean the *Scutisorex* duplicate and the NA row at source.
5. Add "rebuild tree + coverage report" to the data-refresh checklist, so
   coverage stops drifting away from the data every time a merge grows.

*Expected result:* PGLS coverage for mammal trait sets rises from ~200
species to ~1,750+ on the brain-size example (before any name work). Because
the app fetches `_keys/mammal_tree.nwk` from GitHub at runtime, the tree
commit alone changes the live app — no redeploy needed for this phase
except the one-line `tip_binom` fix.

### Phase 2 — The name layer (recovers most of bucket 2)

1. Complete the **MDD reconciliation** the tree handoff already flagged:
   only 90 of 215 `species_reference` rows carry `mdd_accepted_name`. Extend
   that mapping to the whole species universe — Upham's tips follow MDD
   taxonomy, so mapping data name → MDD accepted name → tip is the cheapest
   systematic lift.
2. Work the review-candidate queue in the crosswalk (genus-present misses
   first). Each promotion is a human-checked bridge, as now.
3. Rebuild the tree and coverage report; the missing list should shrink to
   buckets 3 and 4 only.

*Expected result:* a good share of the ~575 genus-present misses that are
true synonyms/splits come in. This phase is the long tail — mostly review
time, not code.

### Phase 3 — Species still absent from Upham DNA-only (bucket 3): a decision

The project's standing principle (`__ShinyApp/PHYLO_SETUP.md`) is: **published
source trees only; the app does not graft or impute placements.** Within that
principle, the options are:

- **(a) Accept and expose.** Leave them out of PGLS, but make the app show
  *which* species were dropped (Phase 4), so the exclusion is visible rather
  than silent.
- **(b) Add a second published tree.** Álvarez-Carretero et al. 2022
  (*Nature*, 4,705 species) covers taxa Upham's DNA-only tree lacks; offer it
  as an alternative tree in the app, or join whole published clades at cited
  divergence ages with the existing `_keys/combine_trees.R` (the same route
  PHYLO_SETUP already sanctions for adding marsupials/monotremes to the
  Zoonomia tree).
- **(c) Only if you and Alexandra choose to change the principle:** use the
  Upham "completed" trees (5,911 species, includes taxonomically imputed
  tips), or graft individual species (e.g. TACT, or `bind.tip` at the
  genus/family MRCA). Either invents placements the data don't support;
  if ever adopted, grafted/imputed species must be flagged in the app and
  every PGLS result needs a sensitivity run with them excluded. Not
  recommended as the default.

### Phase 4 — App surfacing (the PGLS option itself)

The option exists; make it trustworthy:

1. In the PGLS note above the plot, show **n matched / n in analysis** and a
  collapsible, downloadable list of the dropped species (today only the
  count is reported).
2. After Phase 1, coverage will usually be high for mammal-only analyses —
  consider making the phylogeny panel show the tree's name, source and tip
  count so users know what they're fitting on.
3. Optional, later: rebuild `mammal_trees_sample100.nwk` at full coverage
  (it is also pruned to ~200 tips today) and offer "PGLS across 100 trees"
  with pooled estimates, so phylogenetic uncertainty is visible. The fitting
  code already isolates λ per fit; pooling across trees is an incremental
  change, but it is 100 fits per click — cache or restrict to the final
  model.
4. Deployment notes: the tree loads from GitHub at runtime (data-only
  updates, no redeploy); `ape`/`nlme` must be present on shinyapps.io —
  they already are required by the current code, but verify after the next
  deploy, since PGLS disables quietly if the fetch or packages fail.

## Validation

- Reproduce one published PGLS result end-to-end (e.g. a brain–body
  allometry with a known λ) on the rebuilt tree and compare slope/λ.
- Check the OLS path is untouched (same numbers as before for λ = 0 / OLS).
- Commit the regenerated `tree_coverage_report.csv` with the tree, and diff
  the crosswalk before committing (hand promotions outside
  `TREE_TIP_BRIDGES` do not survive a re-seed).
- Sanity: root age and ultrametricity of the pruned tree unchanged
  (162.2 Ma for the current build); tip count and matched-n reported in the
  app note agree with the coverage report.

## Decisions for Michael / Alexandra

1. Bucket 3 route: (a) accept + expose, (b) second published tree, or
   (c) change the no-imputation principle. — *Recommendation: (a) now,
   (b) if a specific analysis needs the extra taxa.*
2. Non-mammals: confirm they stay out of scope for the mammal tree. A bird
   PGLS would be a separate tree (e.g. Jetz et al.) and a separate decision.
3. Whether the Zoonomia tree (Foley et al. 2023, placental-only, the better
   match for the M1 gene-expression work) should be offered alongside Upham
   in the app — the handoff already raises this; Phase 4 is the natural
   place to add a tree switcher if so.

## Effort sketch

Phase 1: days — the scripts exist; the work is the species-universe seed and
a rebuild + verification cycle. Phase 2: the long tail, spread over review
sessions. Phase 3: (a) is free with Phase 4; (b) is days (tree wrangling +
a switcher); (c) is a methods decision, not an effort question. Phase 4:
1–2 days of app work plus a deploy.
