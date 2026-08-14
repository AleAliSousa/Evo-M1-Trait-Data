# Tree layer — built and working. One manual step left.

**Status 2026-08-14: done and verified.** Upham et al. 2019 DNA-only MCC tree is in
`Upham_etal_2019/`, the merge ran, and `_keys/mammal_tree.nwk` exists — so the Shiny app's
PGLS control is live. `build_mammal_tree.R` (canonical, run in R) and `build_mammal_tree.py`
(offline mirror) were confirmed to produce **byte-identical** output.

## Coverage: 199 of 214 project species on the tree

Root age 162.2 Ma, ultrametric, every placement sequence-based. The 15 not on it:

| n | reason | what to do |
|---|---|---|
| 5 | `sp.` placeholders — `Ateles`, `Callicebus`, `Gorilla`, `Pongo`, `Tarsius` | nothing; no single tip can represent a genus |
| 3 | subspecies pooled onto a parent tip another row already holds (`Cryptomys hottentotus` ×2, `Mustela putorius furo`) | nothing; the tree cannot separate them |
| 6 | no DNA in Upham's supermatrix: *Crocidura jacksoni*, *Elephantulus fuscipes*, *Fukomys anselli*, *Micropotamogale ruwenzorii*, *Nesogale dobsoni*; plus *Marmosa mitis*, which must **not** be bridged to *M. robinsoni* | needs a different source tree, never a graft |
| 1 | `ScutisorexÊsomereni` — corrupted duplicate row | fix at source, see below |

Per-order coverage is in `tree_coverage_report.csv`. Marsupials are fully covered
(Diprotodontia 6/6, Didelphimorphia 4/5, Dasyuromorphia 1/1), which is why the DNA-only Upham
tree was chosen over placental-only Zoonomia.

## The one thing left: the `__ReadMe.xlsx` registry row

Not yet added (checked — no `Upham` / `3000494` / `DNAonlyMCC` in the workbook). Add one row to
`Sheet1`, descriptive columns only; `Item name` / `Item encoded` are formulas that fill
themselves. **Mind the col-D trap:** a blank *Item number* leaves the name ending in a bare `_`.

| column | value |
|---|---|
| Publication name | `Upham_etal_2019` |
| 1st Author | `Upham` |
| year | `2019` |
| DOI (or Alt) | `10.1371/journal.pbio.3000494` |
| Item number | `DNAonlyMCC` |
| Source type | `tree` |
| Team | `Upham` |
| Main Trait(s) | `phylogeny; divergence times` |
| Data role | `primary` |

The public TSV `__Public/comparative-data/10.1371%2Fjournal.pbio.3000494_DNAonlyMCC.tsv` is
already written and matches that encoding, so the row will line up.

## Optional next: publish to the app

```bash
Rscript __ShinyApp/build_data.R    # copies the tree into __ShinyApp/data/ as offline fallback
```

## Rebuilding later

```bash
Rscript __merging_trees/build_mammal_tree.R          # canonical
python3 __merging_trees/build_mammal_tree.py         # offline mirror, identical output
python3 __merging_trees/make_tip_crosswalk_seed.py   # only when _keys/ species files change
```

Re-seeding rebuilds the crosswalk from `_keys/` and from the `TREE_TIP_BRIDGES` table inside the
seeder. Bridges survive; any `auto_match` you promoted **by hand in the CSV** does not — diff
before committing, or move the promotion into `TREE_TIP_BRIDGES`.

---

## Open decisions, none blocking

1. **Three subspecies rows cannot enter PGLS.** `app.R`'s `tip_binom()` truncates every tip to
   its first two tokens, so a tip labelled `Canis_lupus_familiaris` reads as `Canis lupus` and
   never matches the trait row `Canis lupus familiaris`. Affects `Canis lupus familiaris`,
   `Damaliscus pygargus phillipsi`, `Sus scrofa domesticus` — which is why app-side matching
   finds 196 where the crosswalk found 199. Either make `tip_binom` try the full
   underscore-to-space label first and fall back to the binomial (one line), or accept the loss
   — pooling a domestic dog onto the wolf tip is arguably wrong anyway.

2. **Zoonomia as a second tree.** Foley et al. 2023 is the better match for the M1
   gene-expression work but placental-only, so the 12 marsupials would need
   `_keys/combine_trees.R` to join a published marsupial tree at a cited Theria age. Add as
   `Foley_etal_2023/`, not instead — the two are worth comparing.

3. **Finish the MDD reconciliation.** Only 90 of 215 rows in `_keys/species_reference.csv` carry
   `mdd_accepted_name` / `Order_MDD` / `Family_MDD`. Upham tips follow MDD, so this is the
   cheapest remaining way to lift matching.

## Data problems to fix at source

- **`Scutisorex somereni` is two rows** in `_keys/species_reference.csv`, both with a mojibake
  separator instead of a space: `scutisorexã\x8asomereni` (double-encoded) and
  `ScutisorexÊsomereni` (single-encoded) — a non-breaking space through a Latin-1/UTF-8 round
  trip, genus also lower-cased on the first. The first has an MDD name so the crosswalk rescues
  it and it **is** on the tree; the second has none and is dead. Collapse to one row named
  `Scutisorex somereni`.
- **`Order_resolved = Soricomorpha`** on 3 rows — defunct order, these are Eulipotyphla, which
  is what `Order_MDD` already says.
- **One all-`NA` row** at line 134 of `species_reference.csv`, carried as a species.
