# Phylogenetic regression (PGLS) — adding a source tree

The app's **Plot (X vs Y)** tab has a **"Phylogenetic regression (PGLS)"** option
(Pagel's-λ / Brownian model selector). It stays dormant, with a hint, until a
phylogeny is present. Add one published tree file to switch it on.

**Principle: the tree must come from a published source.** Species that are not in
the source tree are **excluded from the PGLS fit** (they still appear on the plot
and in the OLS line). The app does **not** graft or impute positions for missing
species. If you need broader coverage, use a source tree that already contains
more of the taxa — don't fabricate tips.

## Choose a source tree

Pick a published, sequence-based tree that covers your taxa, and save it (Newick
preferred) as `_keys/mammal_tree.nwk` (`.tre` / `.newick` / `.nex` also work):

- **Team's Zoonomia tree** (Foley et al. 2023, *Science* 380:eabl8189) —
  `AllenInstitute/EvoGen : Projects/M1Evo/data/phylo/`. Best for consistency with
  the M1 gene-expression analyses. Placental mammals only. Copy it in:
  ```bash
  cp .../EvoGen/Projects/M1Evo/data/phylo/<treefile> _keys/mammal_tree.nwk
  ```
- **Upham et al. 2019 DNA-only tree** (PLoS Biol 17:e3000494; VertLife) — the
  *DNA-only* mammal tree (~4 100 species **with genetic data**, incl. marsupials
  & monotremes). Use this for broad mammal coverage from real sequence data
  (the "completed"/DR trees add taxonomically-imputed tips — do **not** use those).
  <https://vertlife.org/data/mammals/>
- **Álvarez-Carretero et al. 2022** (*Nature* 602:263) — a 4 705-species mammal
  timetree, another sequence-based option covering all major clades.

The private EvoGen repo can't be read by the public app, so whichever tree you
choose must be committed **into this repo** at `_keys/mammal_tree.nwk`.

> On marsupials/monotremes: Zoonomia is placental-only. To include them from a
> source (not by grafting), either use a single tree that already contains them
> (Upham 2019 DNA-only or Álvarez-Carretero 2022), or **combine two published
> trees** — see below.

## Optional: combine two published trees (source-to-source)

To keep the Zoonomia placental tree *and* add marsupials/monotremes from published
trees — without imputing individual species — join whole published clades at a
literature divergence age with `_keys/combine_trees.R`. This grafts published
subtrees at a dated node; it does **not** invent species placements.

Provide dated (ultrametric) source trees and run it:

```
_keys/phylo_placental.nwk    e.g. the team's Zoonomia tree
_keys/phylo_marsupial.nwk    a published marsupial time-tree, e.g. Upham 2019
                             DNA-only marsupial subtree, or Duchêne et al. 2018
                             (Mol Phylogenet Evol), or Mitchell et al. 2014
_keys/phylo_monotreme.nwk    optional (else monotremes are omitted)
```
```r
install.packages(c("ape", "phytools"))
```
```bash
Rscript _keys/combine_trees.R      # -> _keys/mammal_tree.nwk (+ coverage report)
```

Set the join ages at the top of the script from the source you cite
(`THERIA_AGE`, default 160 Ma for the marsupial–placental split; `MAMMALIA_AGE`,
default 180 Ma for monotremes). Both input trees must be time-calibrated in the
same unit. The script preserves each subtree's own branch lengths and reports how
many dataset species end up on the combined tree.

## Install + publish

```r
install.packages("ape")              # one time, for PGLS
```
```bash
git add _keys/mammal_tree.*
git commit -m "Add source phylogeny for PGLS" && git push
```

The app loads the tree from GitHub (`_keys/mammal_tree.*`). It is **not** copied
into `__ShinyApp/data/` — that folder holds only files which exist nowhere else
(see DEPLOY.md, "Why `data/` holds only two files"), and `build_data.R` will
abort if a copy is put there. The practical consequence: if GitHub is
unreachable, PGLS quietly disables rather than erroring, since the tree is
optional.

## How it works

- Tips are matched to species by binomial (`Genus_species…` → `Genus species`),
  case-insensitive. Species **not on the tree are dropped from the PGLS fit** —
  the note above the plot reports how many of the plotted species matched.
- For the current X vs Y (and the log₁₀ setting), the app prunes the tree to the
  matched species and fits `gls(y ~ x, correlation = corPagel|corBrownian)`.
- Plot shows **orange = OLS** (all points), **black = PGLS** (tree-matched
  species); the note reports slope, p, λ (Pagel only), and n. Needs ≥ 4 matched
  species.

If some species don't match the tree's tip spelling (synonyms), tell me and I'll
add a synonym pass via the species key — that recovers real matches without
inventing placements.
