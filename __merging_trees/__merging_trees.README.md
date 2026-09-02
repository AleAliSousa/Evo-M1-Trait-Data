# `__merging_trees` — the project phylogeny

Turns a **published source tree** into the tree the Shiny app fits PGLS against, with an
auditable record of which project species reached a tip and how. Same shape as the other
`__merging_*` layers: source folders hold the frozen published data, this folder holds the
merge logic and the QA report, `_keys/` holds the output the rest of the repo reads.

**Current state — two builds from two Upham Items:**

*Single tree* (Upham et al. 2019 DNA-only MCC, 4,100 tips → built 2026-08-14):
**199 of 214 project species on the tree**, root age 162.2 Ma, ultrametric. Every placement
is sequence-based. The 15 not on it break down as 5 `sp.` placeholders, 3 subspecies pooled
onto a parent tip already held by another row, 6 species with no DNA in Upham's supermatrix
(*Crocidura jacksoni*, *Elephantulus fuscipes*, *Fukomys anselli*, *Micropotamogale
ruwenzorii*, *Nesogale dobsoni*, plus *Marmosa mitis* which must not be bridged to
*M. robinsoni*), and 1 corrupted duplicate name (see Known data problems).

*Multi-tree sample* (Upham et al. 2019 **Completed100**: 100 complete trees, 5,911 sp,
`topoCons NDexp`, drawn from the 10k pseudoposterior → built 2026-08-24):
**204 of 214 project species on every tree** — the completed set recovers the 5 no-DNA
species via the *authors'* per-tree taxonomic imputation (placements differ across trees, so
that uncertainty propagates into any PGLS run over the sample). Still off: the 5 `sp.`
placeholders, the 3 pooled subspecies, *Marmosa mitis* (genuinely not an MDD tip), and the
corrupted *Scutisorex* duplicate. This sample is for PGLS-across-trees sensitivity analyses;
the app's canonical tree stays the DNA-only MCC.

```
Upham_etal_2019/*.tre                    frozen published MCC (source 1)
Upham_etal_2019/Completed100_topoCons_NDexp/output.nex
                                         frozen 100-tree credible-set sample (source 2)
        │
        ├── tree_tip_crosswalk.csv       accepted_name -> candidate spellings, gated
        │                                by auto_match (shared by both builds)
        ▼
   build_mammal_tree.R                   canonical single-tree build.  .py = offline mirror
        ├──► _keys/mammal_tree.nwk                     tips = accepted_name  ← app.R reads this
        ├──► mammal_tree_sourcelabels.nwk              tips = published labels, untouched
        └──► tree_coverage_report.csv                  one row per project species
   build_mammal_trees_sample.R           canonical multi-tree build.  .py = offline mirror
        ├──► _keys/mammal_trees_sample100.nwk          100 trees, tips = accepted_name
        ├──► mammal_trees_sample100_sourcelabels.nwk   100 trees, published labels
        ├──► tree_sample_ids.csv                       line -> Upham posterior tree ID
        └──► tree_coverage_report_completed100.csv     one row per project species
```

## The one rule

**No grafting, no imputation — locally.** A species that is not in the published source tree
is reported absent and left off the tree; it still plots and still joins the OLS fit in the
app, it just does not enter the PGLS fit. This is why `_keys/extend_phylo.R` was deprecated
rather than fixed, and it is the whole argument of `__ShinyApp/PHYLO_SETUP.md`. To widen
coverage, change the *source tree*, never the tips — which is exactly what the `Completed100`
sample does: its no-DNA placements are Upham et al.'s own published imputation, not ours.
If a future analysis needs taxa no published tree carries (fossils, `sp.` anomalies), that
happens in a clearly named downstream augmentation step with its own log table (species,
constraint/age, authority, method, decided_by) — never upstream, and never silently.

## Why a crosswalk instead of just matching names

`app.R` matches tree tips to species by binomial. That silently loses every species whose
published tip spelling differs from the project's accepted name — and in this dataset that is
not a rare edge case. Real examples, all of which the crosswalk recovers:

| project accepted name | tip spelling in an MDD-based tree |
|---|---|
| Fukomys damarensis | Cryptomys damarensis |
| Sapajus apella | Cebus apella |
| Symphalangus syndactylus | Hylobates syndactylus |
| Notamacropus parma | Macropus parma |
| Lophocebus albigena | Cercocebus albigena |
| Nesogale dobsoni | Microgale dobsoni |
| Callithrix pygmaea | Cebuella pygmaea |
| Tarsius syrichta | Carlito syrichta |

`make_tip_crosswalk_seed.py` builds these candidates by inverting
`_keys/Stephan/species_key.csv` and reading `_keys/species_display_aliases.csv` and the
`mdd_accepted_name` column of `_keys/species_reference.csv`. It invents nothing — every
candidate is a spelling already recorded somewhere in `_keys/`.

## `auto_match` — the gate that matters

The species key is **paper-scoped by design**, so inverting it drags in links that are *not*
alternative spellings of one taxon. Matching those to tips would put a species in the wrong
place on the tree and quietly bias every PGLS fit. So each candidate is classified:

- **`auto_match = TRUE`** — same taxon, different generic assignment (`Galago demidoff` =
  `Galagoides demidoff`) or minor orthographic variation (`Aotes`/`Aotus`,
  `lagotricha`/`lagothricha`); or a subspecies falling back to its parent species, since a
  species-level tree has no subspecies tips. Used automatically.
- **`auto_match = FALSE`** — a different taxon concept. **Never matched.** Reported as a lead
  so a human can adopt it, mirroring the `status` / `decided_by` / `decided_date` discipline in
  `_keys/reidentifications.csv`.

13 review-only leads remain, and none of them is currently on the tree, so promoting one would
change nothing today — they matter only if the source tree changes. The ones that must *stay*
unmatched whatever happens: `Rattus norvegicus` → `Rattus rattus` and `Avahi occidentalis` →
`Avahi laniger` are **distinct species**.

To promote one: set `auto_match` to `TRUE` on that row, put who decided and on what basis in
`note`, and re-run the build. Do not delete the row.

### `TREE_TIP_BRIDGES` — the hand-verified cases

Eleven same-taxon equivalences are not recoverable from `_keys/` at all: the generic
reassignment is more recent than the species key, or the epithet differs by more than the
orthographic test allows. They live in a table at the top of `make_tip_crosswalk_seed.py`, each
with its taxonomic authority, so re-seeding cannot lose them — and they bypass the plausibility
filter, since by definition their genus (`Neovison`, `Pecari`, `Limnogale`, `Chaerephon`…) is
one the project does not use.

| project accepted name | tree tip | why |
|---|---|---|
| Mustela vison | Neovison vison | Neovison split from Mustela |
| Mops pumilus | Chaerephon pumilus | generic reassignment |
| Macronycteris commersoni | Hipposideros commersoni | Macronycteris split from Hipposideros |
| Galictis vittatus | Galictis vittata | gender agreement |
| Equus burchelli | Equus quagga | senior synonym |
| Fukomys mechowii | Fukomys mechowi | orthographic |
| Osphranter rufus | Macropus rufus | Osphranter raised from Macropus |
| Tayassu tajacu | Pecari tajacu | moved to Pecari |
| Chinchilla laniger | Chinchilla lanigera | correct original spelling |
| Microgale mergulus | Limnogale mergulus | Limnogale sunk; Upham retains it |
| Galagoides demidoff | Galagoides demidovii | orthographic |

Five of these were already documented in `Wilman_etal_2014/…README.md`'s bridge table — the repo
knew them, but only in prose. Together they lift coverage from 188 to 199.

They are deliberately **not** in `_keys/species_display_aliases.csv`: `app.R` applies that file
as a *global rename*, so putting `Mustela vison → Neovison vison` there would rename the species
everywhere in the project. Renaming a species is a taxonomic decision; matching a tree tip is
not.

Dropped from the seed entirely, as they can never be tip labels: common names
("Owl monkey", "Beagle Dog"), abbreviated genera ("C. mitis"), truncations
("Daubentonia madagas."), and `sp.`/`spp.` lumps.

## Reading `tree_coverage_report.csv`

| status | meaning |
|---|---|
| `matched_direct` | accepted name is a tip. Nothing to do. |
| `matched_synonym` | reached via an `auto_match` synonym; `matched_via` names the spelling used. |
| `matched_subspecies_parent` | trinomial matched to its parent species tip. |
| `subspecies_of_matched_species` | the parent tip is already held by another project row, so this one is excluded rather than duplicating a tip. Expected for the `Cryptomys hottentotus` subspecies and `Mustela putorius furo`. |
| `absent_but_review_lead` | not on the tree under any `auto_match` name, but a review-only candidate exists — and the note says whether that candidate **is on the tree**. These are the rows worth your time. |
| `absent_from_tree` | genuinely not in the source tree. Needs a different source tree, not a graft. |
| `unresolvable_placeholder` | `Ateles sp.`, `Gorilla sp.`, `Callicebus sp.`, `Pongo sp.`, `Tarsius sp.` — genus-level names that no single tip can represent. |
| `conflict_tip_already_used` | two species claim one tip other than via subspecies fallback. **A real error** — fix the crosswalk. |

A species matching a tip in its own right always beats a subspecies falling back to the same
tip, so the outcome does not depend on row order in the CSV.

## Two output trees, on purpose

`_keys/mammal_tree.nwk` carries **project accepted names** as tips, because that is what
`app.R` can match against — a tree keeping `Cryptomys_damarensis` would lose that species in
the app even though the crosswalk found it. The published labels are not lost: they are in
`mammal_tree_sourcelabels.nwk`, in the `matched_tip` column of the coverage report, and of
course in the untouched `.tre` in the source folder. This is the repo's usual
printed-name-preserved-alongside-harmonised-name pattern
(`__HOWTO_build_a_dataset_file.md` §0a invariant 3), applied to tips.

## Running it

```bash
Rscript  __merging_trees/build_mammal_tree.R          # canonical single tree
Rscript  __merging_trees/build_mammal_trees_sample.R  # canonical 100-tree sample
python3  __merging_trees/build_mammal_tree.py         # offline mirrors, same outputs
python3  __merging_trees/build_mammal_trees_sample.py
python3  __merging_trees/make_tip_crosswalk_seed.py   # only when _keys/ species files change
```

### Using the sample in an analysis

`_keys/mammal_trees_sample100.nwk` is a plain multi-line Newick: `ape::read.tree()` returns a
`multiPhylo` of 100 trees whose tips are project accepted names (spaces as `_`). To take the
species subset an analysis actually has data for, prune per tree — never edit the file:

```r
trees <- ape::read.tree("_keys/mammal_trees_sample100.nwk")
have  <- gsub(" ", "_", my_data$accepted_name)
sub   <- lapply(trees, ape::keep.tip, tip = intersect(trees[[1]]$tip.label, have))
class(sub) <- "multiPhylo"
fits  <- lapply(sub, function(tr) <PGLS fit against tr>)   # then summarise across fits
```

Report which posterior trees the lines are via `tree_sample_ids.csv` when citing. Fit results
should be summarised across the 100 fits (median + spread), not cherry-picked.

Re-seeding the crosswalk **overwrites hand-promoted `auto_match` values** — the seeder rebuilds
the file from `_keys/`. Diff before committing, or re-apply promotions afterwards.

Then publish, exactly as `PHYLO_SETUP.md` describes:

```bash
Rscript __ShinyApp/build_data.R     # copies the tree into __ShinyApp/data/ as offline fallback
```

`build_data.R` already picks up `_keys/mammal_tree.*`; no app changes are needed.

## Known data problems this layer exposed

- **`Scutisorex somereni` occupies two rows in `_keys/species_reference.csv`**, both with a
  mojibake separator instead of a space: `scutisorexã\x8asomereni` (double-encoded) and
  `ScutisorexÊsomereni` (single-encoded) — a non-breaking space run through a Latin-1/UTF-8
  round trip, with the genus also lower-cased on the first. Neither can match a tree tip or
  join any other table. The first has `mdd_accepted_name = Scutisorex somereni` so the
  crosswalk rescues it; the second has no MDD name and is unrescuable. **Fix at source:**
  repair to one row named `Scutisorex somereni`.
- **`Order_resolved = Soricomorpha`** on 3 rows. Soricomorpha is defunct — these are
  Eulipotyphla, which is what `Order_MDD` says. Harmless to tip matching (order is not used
  to match) but it will misgroup those species anywhere the app colours by order.
- **One entirely `NA` row** in `species_reference.csv` (line 134), carried through as a species.
- Only **90 of 215** rows have `mdd_accepted_name` / `Order_MDD` / `Family_MDD` filled. Since
  Upham tips follow MDD, finishing that reconciliation is the single highest-yield way to lift
  tip-matching coverage.

## Adding another source tree later

The second source arrived 2026-08-24 as a second **Item in the same folder**
(`Upham_etal_2019/Completed100_topoCons_NDexp/` — same publication, so no new source folder),
with its own build script and distinct output names, so the two are compared rather than
silently swapped. The same pattern applies to the next one: Zoonomia (Foley et al. 2023) —
best consistency with the M1 gene-expression analyses, but placental-only, so the project's
12 marsupials would need `_keys/combine_trees.R` to join a published marsupial tree at a cited
Theria age. Add it as its own source folder (`Foley_etal_2023/`), point a build at it, and
write to a distinct output name.
