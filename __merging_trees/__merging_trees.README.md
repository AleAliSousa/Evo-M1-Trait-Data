# `__merging_trees` — the project phylogeny

Turns **published source trees** into the trees the project fits PGLS against, with an
auditable record of which species reached a tip and how. Same shape as the other
`__merging_*` layers: source folders hold the frozen published data, this folder holds the
merge logic and the QA reports, `_keys/` holds the outputs the rest of the repo reads.

**Rebuilt 2026-11-19.** Until then the tree was pruned to the 214 species the curated list
held in August, so `_keys/mammal_tree.nwk` had 199 tips while the app's data had grown to
thousands of species. The pruning list is now the *species universe* — every label the app
loads — and there are three tree products instead of one.

## The three trees

| | file in `_keys/` | what it is | tips | who placed the non-sequenced species |
|---|---|---|---|---|
| **A** | `mammal_tree.nwk` | Upham et al. 2019 DNA-only MCC tree, pruned. **The app reads this one.** | 3,825 | nobody: there are none |
| **B** | `mammal_trees_sample100.nwk` | 100 of Upham et al.'s *completed* trees, pruned | 5,446 (3,825 sequenced + 1,621 imputed) | Upham et al., differently in each tree |
| **C** | `mammal_tree_augmented.nwk`, `mammal_trees_augmented100.nwk` | tree A plus branches added here; one deterministic tree and 100 randomised | 5,646 (3,825 sequenced + 1,821 added) | this repo, by genus (or family) |

Tips are project names with spaces as `_`. Every tree is ultrametric to the rounding of the
published file (tip depths differ by < 0.0002 Myr). The root of A is 179.2 Ma, the mammal
crown, because monotremes are now on the tree; the therian root is 162.2 Ma as before.

**All three reduce to the same thing when the non-sequenced tips are dropped:** C minus its
added tips is tree A exactly, and B's sequenced tips are A's species. So A is always
available as the conservative baseline for any result obtained on B or C.

### Which to use

- **A** when the claim must rest on sequence data alone. It is the app's tree and the
  default.
- **B** when the species that matter lack DNA. The placements are published, and running
  the analysis over the 100 trees carries both the placement uncertainty and the
  uncertainty of the backbone into the result.
- **C** for species B cannot give you — the 208 current species described or split
  since 2019 — and as a check on B. Its 100 trees vary only where the added tips sit; the
  backbone is fixed, so C understates uncertainty relative to B.

Whatever is used, **report the result with the non-sequenced tips dropped as well.** The
provenance tables (`tree_tip_provenance_completed100.csv`, `tree_tip_provenance_augmented.csv`)
say which tips those are. An imputed or added tip sits where taxonomy puts it, with no
information from the trait being analysed; a result that moves when those tips are removed
rests on the placements.

### Does the choice matter? One worked example

`compare_pgls_across_trees.R` fits log10 brain mass on log10 body mass with Pagel's λ on every
product (`pgls_method_comparison.csv`; run 2026-11-19):

| tree | trees | species | not sequenced | slope, median (range over trees) | SE | λ |
|---|---|---|---|---|---|---|
| **A** DNA-only | 1 | 1,589 | 0 | 0.539 | 0.0075 | 0.957 |
| **B** Upham completed, all tips | 100 | 1,721 | 132 | 0.535 (0.528–0.544) | 0.0073 | 0.949 |
| **B** sequenced tips only | 100 | 1,589 | 0 | 0.541 (0.538–0.546) | 0.0075 | 0.960 |
| **C** added branches, deterministic | 1 | 1,755 | 166 | 0.531 | 0.0073 | 0.947 |
| **C** added branches, randomised | 100 | 1,755 | 166 | 0.532 (0.527–0.536) | 0.0073 | 0.943 |
| **B** on the species B and C share | 100 | 1,720 | 131 | 0.533 (0.526–0.540) | 0.0073 | 0.949 |
| **C** randomised, same species | 100 | 1,720 | 131 | 0.531 (0.528–0.534) | 0.0074 | 0.943 |
| OLS, no phylogeny |  | 1,589 | 0 | 0.748 | 0.0041 | — |

For this allometry the choice does not matter: every phylogenetic slope lies between 0.531
and 0.541, about one standard error apart. Upham's imputation and our added branches, on the
same 1,720 species, differ by 0.002. Adding the non-sequenced species lowers the slope by
0.004–0.009 and λ slightly. Coverage mattered far more than method: on the old 199-tip tree
the same model had 190 species and a slope of 0.675.

This is one trait pair with strong signal and under 10% non-sequenced species. A comparison
with few species, or a high share of imputed tips, can behave differently — rerun the script
on the variables in question (change the two `pick()` calls) before relying on B or C.

## The rule, restated

The app does not graft or impute: tree A contains sequenced species only, as
`__ShinyApp/PHYLO_SETUP.md` requires. Widening coverage beyond that happens only in the two
separately named products, each with its own log:

- **B** uses the source authors' own imputation. Nothing is placed locally.
- **C** is the "clearly named downstream augmentation step with its own log table" the
  earlier version of this README allowed for. `tree_augmentation_log.csv` has one row per
  candidate species: constraint taxon and rank, number of sequenced relatives, whether the
  genus is monophyletic on the backbone, crown age, method, authority, decided_by.

`_keys/extend_phylo.R` stays deprecated. Nothing in this folder changes a tip of tree A.

## Pipeline

```
__ShinyApp/app.R (GH list)   _keys/species_reference.csv   _keys/species_display_aliases.csv
        └───────────────┬───────────────┘
              build_species_universe.py ──► species_universe.csv      every name, with a scope
                        │
reference_tables/mdd_names_extract.csv  +  _keys/ species key, aliases
                        │
            make_tip_crosswalk_seed.py ──► tree_tip_crosswalk.csv     name -> candidate spellings,
                        │                                             gated by auto_match
                        │        resolve_tips.R / resolve_tips.py     shared name -> tip rules
        ┌───────────────┼────────────────────────────┐
build_mammal_tree.R     build_mammal_trees_sample.R   build_mammal_tree_augmented.R
  (.py mirror)            (.py mirror)                  (R only)
  A: _keys/mammal_tree.nwk
     mammal_tree_sourcelabels.nwk        B: _keys/mammal_trees_sample100.nwk          C: _keys/mammal_tree_augmented.nwk
     tree_coverage_report.csv               mammal_trees_sample100_sourcelabels.nwk      _keys/mammal_trees_augmented100.nwk
                                            tree_sample_ids.csv                          tree_augmentation_log.csv
                                            tree_coverage_report_completed100.csv        tree_tip_provenance_augmented.csv
                                            tree_tip_provenance_completed100.csv         tree_coverage_report_augmented.csv
                        │
        compare_pgls_across_trees.R ──► pgls_method_comparison.csv, …_per_tree.csv
```

Sources (frozen, untouched): `Upham_etal_2019/*.tre` (DNA-only MCC, 4,098 species) and
`Upham_etal_2019/Completed100_topoCons_NDexp/output.nex` (100 completed trees, 5,911 species).

## Running it

```bash
python3 __merging_trees/build_species_universe.py      # when a merge or _keys/ species file changes
python3 __merging_trees/make_tip_crosswalk_seed.py
Rscript __merging_trees/build_mammal_tree.R            # A  (python3 …/build_mammal_tree.py mirrors it)
Rscript __merging_trees/build_mammal_trees_sample.R    # B  (python3 …/build_mammal_trees_sample.py)
Rscript __merging_trees/build_mammal_tree_augmented.R  # C  needs B's reports; R only
Rscript __merging_trees/compare_pgls_across_trees.R    # needs phylolm; ~3 min
```

Run in that order from the repo root. Each script reads from `$EVOM1_REPO` and writes under
`$EVOM1_OUT`; both default to this repo, so the commands above behave as before. Setting
`EVOM1_OUT` elsewhere builds everything into a scratch folder without touching the repo.

The R builds and their Python mirrors produce byte-identical trees (checked for A and B on
2026-11-19). The mirrors write the coverage CSVs with minimal quoting, R with full quoting;
the contents are the same.

**Rebuild whenever a merge grows.** The universe is read from the tables `app.R` loads, so a
rebuild picks up new species by itself — but only if it is run. Coverage drifted from 199 of
214 to 199 of several thousand because it was not.

## The species universe and scope

`species_universe.csv` lists 10,266 names: every `Species` label in the tables `app.R`
loads (its `GH` list is parsed, so a new table is picked up automatically), after the app's
display aliases, plus the names in `_keys/species_reference.csv`.

| scope | names | meaning |
|---|---|---|
| `in_scope_mammal` | 7,038 | a mammal species or subspecies name; goes to the crosswalk |
| `out_of_scope_non_mammal` | 2,404 | bird, reptile, fish, invertebrate. No mammal tree can hold it |
| `out_of_scope_not_a_species_name` | 612 | common name, abbreviation, placeholder, hybrid, misspelt genus, note text |
| `out_of_scope_no_order` | 196 | no order on record and genus not in the mammal checklist |
| `out_of_scope_fossil` | 16 | flagged fossil in `species_reference.csv` |

Out-of-scope names are listed in every coverage report with status `out_of_scope`. They are
not counted as missing from the tree.

## The crosswalk and `auto_match`

`app.R` matches tree tips to species by name, which loses every species whose published tip
spelling differs from the name the data use. `make_tip_crosswalk_seed.py` lists candidate
spellings for each in-scope name; the builds try them in rank order. It reads no tree.

- **`auto_match = TRUE`** — the same taxon: the name itself; MDD's current, Checklist-of-
  Mammals (2020) or MSW3 (2005) name for it, when that older name belongs to one species only;
  the same epithet under a genus MDD records for the species; a synonym MDD lists under exactly
  one species; a spelling or gender-agreement variant; a display alias; a subspecies falling
  back to its parent species; a hand-verified bridge.
- **`auto_match = FALSE`** — a different or ambiguous concept, **never matched**: a pre-split
  name that now covers several species, an epithet found under another genus of the family,
  a species-key link between distinct species. These are leads for a person to decide.

`candidate_source` records which rule produced each candidate; the seeder's docstring defines
every value. 9,224 auto candidates and 305 review-only candidates are in the file.

**`TREE_TIP_BRIDGES`** (in the seeder) holds the eleven hand-verified equivalences that no
rule recovers; re-seeding cannot lose them. **`NEVER_BRIDGE`** (also in the seeder) holds pairs
that must stay unmatched whatever a rule or database says: `Marmosa mitis → Marmosa robinsoni`
(curator decision, although MDD lists *mitis* in that synonymy), `Rattus norvegicus → Rattus
rattus`, `Avahi occidentalis → Avahi laniger`.

To promote a review lead, add it to `TREE_TIP_BRIDGES` with its basis, re-seed and rebuild.
Editing `auto_match` in the CSV by hand still works but **is overwritten by the next re-seed**.

They are deliberately **not** put in `_keys/species_display_aliases.csv` by this layer: that
file is a global rename applied by `app.R`. Renaming a species is a taxonomic decision;
matching a tree tip is not.

### The Mammal Diversity Database extract

`reference_tables/mdd_names_extract.csv` is a 13-column extract of the MDD species table (see
the README beside it for source, date and how to refresh). It supplies the name history that
links a data label to the spelling Upham et al. used in 2019, and the list of current living
species that tree C may add.

## How a name gets a tip (`resolve_tips.R`)

Only `auto_match = TRUE` candidates are tried. Two rules are new:

1. **A name the source taxonomy recognises is matched only as itself.** Upham et al. list
   5,911 species; one they recognise but did not sequence is absent from tree A, and is never
   moved onto another tip by a later synonymy. (*Petaurista magnificus* is a separate,
   unsequenced species in Upham; MDD has since sunk it into *P. albiventer*. It is absent
   from A, imputed in B, added in C.)
2. **One tip carries one name.** When several names resolve to the same tip it goes to, in
   order: a species-level match before a subspecies fallback; a name in `species_reference.csv`
   before a label found only in a merge; the current MDD name before an older one; the name
   that is the tip spelling; the name in more app tables; byte order.

## Reading the coverage reports

One row per universe name in each of `tree_coverage_report.csv` (A),
`tree_coverage_report_completed100.csv` (B) and `tree_coverage_report_augmented.csv` (C).

| status | A | B | C | meaning |
|---|---|---|---|---|
| `matched_direct` | 3,627 | 5,201 | 3,627 | the name is a tip |
| `matched_synonym` | 198 | 245 | 198 | reached via an `auto_match` candidate; `matched_via` names it |
| `grafted_local` | – | – | 1,821 | added by `build_mammal_tree_augmented.R` |
| `synonym_of_matched_name` | 585 | 675 | 585 | another label for the same taxon holds the tip (see below) |
| `subspecies_of_matched_species` | 130 | 132 | 130 | the parent species holds the tip |
| `absent_but_review_lead` | 202 | 201 | 202 | off the tree, but a review-only candidate exists; the note says whether it is on the tree |
| `absent_from_tree` | 2,296 | 584 | 475 | no candidate is a tip |
| `unresolvable_placeholder` | 51 | 51 | 51 | `Gorilla sp.` and the like in the curated list |
| `out_of_scope` | 3,177 | 3,177 | 3,177 | not a mammal species name |
| `conflict_tip_already_used` | 0 | 0 | 0 | two names that are the same tip spelling — a real error; fix the source |

`matched_subspecies_parent` no longer occurs: every parent species is now in the data and
holds its own tip.

### Two labels for one species (675 of them)

`synonym_of_matched_name` rows are data labels that are a second name for a species already
on the tree — *Mustela vison* beside *Neogale vison*, *Lagothrix lagotricha* beside
*L. lagothricha*. The app treats the two labels as two species, so the data under the losing
label cannot enter PGLS, and the two appear as separate points in every plot.
`tree_alias_candidates.csv` lists each pair with the tables each label occurs in and, where
one of them is the current MDD name, a suggested canonical. Adding a pair to
`_keys/species_display_aliases.csv` is the fix, and is a curator's decision.

### The review queue (217 names)

`tree_review_queue.csv` lists every off-tree name that has a review-only lead, most-used
names first, with empty `decision` / `decided_by` / `decided_date` columns. 141 of them have a
lead that is a tip of tree A; most are old generic placements (*Cercopithecus sabaeus* →
*Chlorocebus sabaeus*, *Tatera brantsii* → *Gerbilliscus brantsii*).

## How tree C places a species

Only names with positive evidence of being a valid living species are added: species in
Upham's taxonomy without DNA (1,613) and current, non-extinct MDD species absent from Upham
altogether (208). Fossils, placeholders, names of unknown status, second labels and
subspecies are never added.

| sequenced relatives | deterministic tree | randomised trees |
|---|---|---|
| genus has two or more | at the genus crown node (a polytomy) | uniformly along the branches below that node |
| genus has one | midpoint of that species' terminal branch | uniformly along it |
| genus has none | the same two rules on the family | the same |
| family has none | not placed | not placed |

1,648 were placed by genus and 173 by family; 244 had a single sequenced relative.
8 were not placed (Nesophontes edithae, Nesophontes hypomicrus, Nesophontes major, Nesophontes micrus, Nesophontes paramicrus, Nesophontes zamicrus, Prolagus sardus, Thylacinus cynocephalus).
An added species is never put inside another genus that is monophyletic on the backbone. The
build checks this, and that every added tip is inside its constraint clade, on the unpruned
tree, and stops if either fails.

**Limits to keep in view.** 586 of the genus-level additions are in genera that are *not*
monophyletic on the backbone; their constraint clade is the smallest clade holding all
sequenced congeners, which then includes other genera (`constraint_monophyletic`,
`constraint_clade_tips` in the log). Family-level placements are loose: *Abditomys latidens*, whose
genus is unsequenced, is attached at the crown of Muridae (412 sequenced species, 51.5 Ma),
or anywhere below it in the randomised trees. The deterministic tree has 390 polytomies, the
largest with 81 branches. Extinct species that Upham et al. include are added as present-day tips, as
they are in B. Placement uses taxonomy only.

## Using the trees in an analysis

```r
trees <- ape::read.tree("_keys/mammal_trees_sample100.nwk")        # multiPhylo, 100 trees
prov  <- read.csv("__merging_trees/tree_tip_provenance_completed100.csv")
have  <- intersect(gsub(" ", "_", my_data$Species), trees[[1]]$tip.label)
seqd  <- intersect(have, prov$tip_label[prov$provenance == "sequenced"])
fits_all <- lapply(trees, function(tr) <PGLS on ape::keep.tip(tr, have)>)
fits_seq <- lapply(trees, function(tr) <PGLS on ape::keep.tip(tr, seqd)>)   # report both
```

Summarise across the 100 fits (median and range), never one chosen tree. Cite the posterior
trees by `tree_sample_ids.csv`. `nlme::gls` with `ape::corPagel` needs about 30 s per fit at
1,600 species; `phylolm::phylolm(model = "lambda")` gives the same estimates in under a second.

## What changes for the app

`app.R` fetches `_keys/mammal_tree.nwk` from GitHub at run time, so **committing the new tree
changes the live app without a deploy.** Before or with that commit:

1. **Replace `tip_binom()` in `__ShinyApp/app.R`** (and deploy). It keeps the first two
   words of a tip label, so the tip `Capra_aegagrus_hircus` is read as *Capra aegagrus*: the
   wild goat's data would be fitted on the domestic goat's tip, and the domestic goat's own
   data would not match. The replacement drops only a published `FAMILY_ORDER` suffix:

   ```r
   # tree tip -> species name, as the data spell it. A published label
   # ("Genus_species_FAMILY_ORDER") is recognised by its last word, the ORDER in
   # capitals, on a label of four or more words; a project label is kept whole.
   tip_binom <- function(tips) {
     vapply(strsplit(trimws(gsub("_", " ", tips)), " +"), function(z) {
       if (length(z) >= 4 && grepl("^[A-Z]+$", z[length(z)])) z <- z[1:2]
       paste(z, collapse = " ")
     }, character(1))
   }
   ```

   It was tested on the function alone (project labels, raw Upham labels, every tip of A
   and C), not in the running app.
2. **Expect slower PGLS.** A mammal-wide fit now has up to ~1,600 species where it had at
   most 199. The app's `nlme::gls` + `corPagel` took 27 s for brain mass on body mass on a
   10-core laptop; shinyapps.io will be slower.

## Open items

Carried over from the two handoff notes of 2026-08/09 and 2026-11-19 (now removed), plus what
this rebuild found.

**App (handoff "Phase 4")**
- Show *n matched / n in analysis* and a downloadable list of the species dropped from a PGLS
  fit. Today only a count is shown.
- Show the tree's name, source and tip count in the phylogeny panel.
- Offer B (and C) in the app, with estimates pooled across trees; consider `phylolm` for speed.
- Verify `ape` / `nlme` on shinyapps.io after the next deploy; PGLS disables quietly without them.

**Names**
- Decide the 675 label pairs in `tree_alias_candidates.csv`.
- Work `tree_review_queue.csv` (217 names).
- Confirm the *Marmosa mitis* decision: the curated rule keeps it off the *M. robinsoni* tip;
  MDD treats *mitis* as a synonym of *M. robinsoni*.
- 612 labels in the merges are not species names. Among them: free-text notes in the
  `Species` column of `body_ecology_long.csv`, common names ("Honey possum"), and misspelt
  genera ("Nasau nasau", "Isoodono besulus"). `species_universe.csv` lists them with the genus
  `species_taxonomy.csv` files them under. They need fixing in the merges.
- `Order_resolved = Soricomorpha` on 2 rows of `species_reference.csv` (*Microsorex hoyi*,
  *Scutisorex somereni*); `Order_MDD` already says Eulipotyphla.
- `mdd_accepted_name` is filled on 90 of 1,545 rows of `species_reference.csv`. No longer
  needed for tip matching, which reads MDD directly.

**Trees**
- A second published tree. Álvarez-Carretero et al. 2022 (4,705 species) for taxa Upham's
  DNA-only tree lacks; Zoonomia (Foley et al. 2023) for consistency with the M1 expression
  work, placental-only, so marsupials would need `_keys/combine_trees.R`. Each as its own
  source folder and its own output name.
- Non-mammals (2,404 names) need their own trees (e.g. Jetz et al. for birds). A separate decision.

**Validation not yet done**
- Reproduce a published PGLS result end to end on tree A.
- Confirm in the running app that OLS results are unchanged and that the matched-n the app
  reports agrees with the coverage report.

**Housekeeping**
- Add "rebuild universe, crosswalk, trees and coverage reports" to the data-refresh checklist.

## History

- **2026-08-14** Tree layer built: Upham DNA-only MCC, 199 of 214 project species.
- **2026-08-24** Completed100 sample added: 204 of 214.
- **2026-11-19** Rebuilt at full coverage on the species universe; MDD name layer; tree C and
  the comparison script added; shared resolver; `$EVOM1_REPO` / `$EVOM1_OUT`. The new tree A
  pruned to the old 199 tips is identical to the old tree. Seven old names no longer label a
  tip: the dog, pig and blesbok (their parent species now hold the tips) and *Mustela vison*,
  *Myoxus glis*, *Spalax ehrenbergi*, *Tayassu tajacu* (the current names *Neogale vison*,
  *Glis glis*, *Nannospalax ehrenbergi*, *Pecari tajacu* are separate labels in the data and
  hold them). Four alias variants now carry the app's canonical spelling.
