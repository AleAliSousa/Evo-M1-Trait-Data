# `__merging_trees` — the project phylogeny

Source: Upham, Esselstyn & Jetz 2019 (PLoS Biol 17:e3000494), frozen in `Upham_etal_2019/`.
This folder turns that source into the trees the Shiny app and offline analyses use for PGLS.

## The rule

**The tree is one more source, and its names go through the species key like every other
source.** Each Upham species name is passed to the project resolver,

```r
resolve_species(<Upham name>, source_publication = "Upham_etal_2019")
```

and the tip carries the `accepted_name` the key returns. A species the key does not know keeps
the name Upham et al. printed. Then `_keys/species_display_aliases.csv` is applied, because the
app applies it to the data. That is all of the name handling (`tree_tip_names()` in `tree_names.R`).
There is no crosswalk, no synonym table and no matching rule in this folder.

If a species is on the tree under a name the data do not use, the fix is **a row in the species
key** — `_keys/Upham/species_key.csv` for a tree spelling, or the hub/spoke row concerned — so
that every merge gets the same answer. Never a rule here. See `_keys/SPECIES_NAMING.md`.

Two guards, both in `tree_tip_names()`:

- A key row written for another paper is borrowed only when it says two *names* are one species
  (synonym, spelling, verbatim). A row recording what that paper's animals were (lump,
  subspecies assignment, re-identification) does not rename a tree species.
- No two tips may share a name. If the key sends two Upham species to one `accepted_name`, the
  tip Upham prints under that name keeps it and the other keeps Upham's name.

Both cases are written to the `note` column of `tree_tip_names.csv` (5 tips today).

**The trees are not pruned to the data.** They hold every Upham species, so a growing merge
cannot make them stale; the app prunes to the species in each analysis. Rebuild only when the
species key, the display aliases or the source trees change. `verify_trees.R` fails when the
saved names no longer match what the key returns.

## The three trees

| | file (in `_keys/`) | tips | what it is |
|---|---|---|---|
| **A** | `mammal_tree.nwk` | 4,099 | Upham's DNA-only MCC tree, outgroup removed. Every tip has sequence data. **The app's tree.** |
| **B** | `mammal_trees_sample100.nwk` | 5,911 × 100 | Upham's "completed" trees: the 1,812 species without DNA are placed by *their* taxonomy-constrained imputation, differently in each tree. |
| **C** | `mammal_tree_augmented.nwk`, `mammal_trees_augmented100.nwk` | 5,885 (× 100) | Tree A plus 1,786 species without DNA added *here*, by genus (1,648) or family (138). One deterministic tree and 100 randomised ones. 26 species have no sequenced relative and are left out. |

A differs from the published file in tip names only; B likewise; C with the added tips dropped
is A exactly. `verify_trees.R` checks all three statements on every tree.

Use **A** by default. Use **B** when coverage matters and the result should carry placement
uncertainty: fit on all 100 trees and report the range. **C** is a sensitivity check on B, not a
published phylogeny; the added tips are placed by rule (`tree_augmentation_log.csv` gives the
clade, the method and the seed for each) and `__ShinyApp/PHYLO_SETUP.md` rules them out for the app.

### Does the choice matter? One worked example

log10 brain mass ~ log10 body mass, Pagel's lambda, one value per species from the merges
(`compare_pgls_across_trees.R` → `pgls_method_comparison.csv`):

| tree | species | not sequenced | slope (range over trees) | lambda |
|---|---|---|---|---|
| A | 1,674 | 0 | 0.543 | 0.953 |
| B, all tips | 1,826 | 152 | 0.538 (0.532–0.546) | 0.947 |
| B, sequenced tips only | 1,674 | 0 | 0.545 (0.541–0.549) | 0.957 |
| C, deterministic | 1,825 | 151 | 0.535 | 0.944 |
| C, randomised | 1,825 | 151 | 0.535 (0.531–0.538) | 0.941 |
| B, species also in C | 1,825 | 151 | 0.537 (0.531–0.543) | 0.947 |
| OLS, no tree | 1,674 | 0 | 0.748 | |

For this model the way the unsequenced species are added changes the slope in the third
decimal. That is one model on one pair of traits, not a general result; rerun the script on the
variables of a real analysis before relying on it (change the two `pick()` calls).

## Files

| file | role |
|---|---|
| `tree_names.R` | the rule above; paths; the coverage report. Sourced by everything else. |
| `build_mammal_tree.R` | A. Also writes `tree_tip_names.csv`. |
| `build_mammal_trees_sample.R` | B. Also writes `tree_sample_ids.csv` (Upham's id for each of the 100 trees). |
| `build_mammal_tree_augmented.R` | C. Also writes `tree_augmentation_log.csv`. |
| `verify_trees.R` | structural checks; exits 1 on failure. |
| `compare_pgls_across_trees.R` | the worked example. Needs `phylolm`. |
| `tree_tip_names.csv` | one row per Upham species (5,911): Upham's name, the tip name, whether and how the key resolved it, whether it is sequenced. **The published name of any tip is the `upham_name` column.** |
| `tree_coverage_report.csv` | one row per species label in the tables the app loads: is it on A, B, C. Informational; nothing is pruned to it. |
| `species_key_gaps_seen_from_tree.csv` | hub names that are off the tree although the tree has the species under another name (see below). For the key's curator. |
| `vertlife_phylosubsets_paste_list.txt` | kept from the 2026-09 VertLife download; not read by any script. |

```bash
# from the repo root; needs R with ape, dplyr, readr (the resolver's own requirements)
Rscript __merging_trees/build_mammal_tree.R
Rscript __merging_trees/build_mammal_trees_sample.R
Rscript __merging_trees/build_mammal_tree_augmented.R
Rscript __merging_trees/verify_trees.R
```

`EVOM1_OUT=<dir>` writes everything to a scratch folder instead of the repo, and
`EVOM1_KEYS=<dir>` reads a trial copy of the key; use both to see what a key change does to the
tree before saving it.

## State at the last build (2026-11-21)

- Upham species: 5,911 (4,099 sequenced). The key resolves 1,487 of them
  (1,407 sequenced); 111 tips carry a name different from Upham's
  (3 of them through a display alias).
- Species labels in the app's tables: 10,815. On A: 3,931. On B: 5,633. On C: 5,614.
- Hub species among those labels: 1,492. On A: 1,283. On B: 1,326.
- `_keys/Upham/species_key.csv`: 23 rows, each a tree spelling whose current name is already
  a hub row (22 from the NCBI names in `_keys/ncbi_taxonomy_snapshot.csv`, 1 from the hub's own
  `mdd_accepted_name`). All 23 tree spellings also occur as raw labels in merged tables, so
  **these rows will also change merge outputs** the next time the merges run.

Most of the labels that are off the tree are not tree problems. 9,323 of the 10,815 labels
are not hub names. They come chiefly from `body_ecology` and `supplementary`, whose database
names the resolver leaves unresolved, so one species can appear there under an older name beside
its hub name. Those are resolved in the key, not here.

## Open items

1. **Key gaps the tree exposes** (`species_key_gaps_seen_from_tree.csv`, 16 rows, written by
   `build_mammal_tree.R`). The hub holds two species or subspecies rows with one `ncbi_taxid`
   (e.g. *Neogale vison* / *Mustela vison*, *Osphranter rufus* / *Macropus rufus*); the tree can
   carry only one of the names, so data under the other are off the tree. Not in the table,
   because the hub row has no taxid: *Dasykaluta rosamundae* (hub) vs *rosamondae* (tree).
   Which name is the anchor is the curator's decision.
2. **`tip_binom()` in `__ShinyApp/app.R`** keeps only the first two words of a tip, which breaks
   `Capra_aegagrus_hircus`, the one three-word tip. Until that is fixed, domestic goat is off the
   app's tree.
3. **PGLS is slower** on the full tree: `nlme::gls` + `corPagel` takes roughly half a minute at
   ~1,600 species.
4. **Upham's own taxonomy table.** The paper describes a master taxonomy of its 5,911 species
   reconciled with NCBI and IUCN names (their S1 Data, on Dryad). It is not in the repo and has
   not been inspected for this build; if it holds what the paper says, it is the natural
   authority for further rows in `_keys/Upham/species_key.csv`.
5. **Family-level placement in C** reads `_keys/species_taxonomy.csv`, which predates the latest
   merges.
6. `Upham_etal_2019/Upham_etal_2019.README.md` (rebuild commands, "published tip labels") and
   `__metadata/README.md` (line on `tree_tip_crosswalk.csv`) still describe the previous system.

## History

- 2026-08: first tree, pruned to a hand-kept 214-species crosswalk (199 tips).
- 2026-11-19: rebuilt with a rule-based matcher against the Mammal Diversity Database and pruned
  to the species in the data (3,825 tips); trees B and C added.
- 2026-11-21: matcher, crosswalk and pruning removed. Tip names come from the species key; the
  trees are unpruned. Reason: a second naming system beside the key gave the same species
  different names in the tree and the data, and a pruned tree went stale at every merge.
