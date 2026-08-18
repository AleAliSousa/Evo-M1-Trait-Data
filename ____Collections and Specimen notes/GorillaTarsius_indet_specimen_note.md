# *Gorilla* sp. and *Tarsius* sp. — two indeterminate labels, two different answers

## Purpose

`volumes_wide_select.csv` prints two genus-level indeterminate labels, `Gorilla
sp.` and `Tarsius sp.`, where `Stephan_primates.csv` and `species.nwk` both
carry resolved binomials. Downstream (`analyses_metabol_rate_structure`) the
mismatch caused both rows to fail the tree-tip filter and vanish silently, so
the volumes_wide PGLS fits ran on 53 species against Stephan's 59.

This note records what the two labels actually cover. They look like the same
problem and are not.

## The core problem

A `Genus sp.` label is not a synonym. It is a refusal to resolve. Rewriting it
to a binomial is an inference, and whether that inference is safe depends
entirely on what sits underneath — which is a specimen question, not a
nomenclatural one.

## Evidence chain

1. **Catalog, *Tarsius*** — `collection_specimens_parsed.csv` CAT-167 and
   CAT-168 (Stephan, Düsseldorf, both female, both Art. Nr. 3282, Tier Nr. 1033
   and 1333). Both rows record `species = Tarsius syrichta` **and**
   `other sp. = Tarsius sp.`, flagged `alt-species-listed`. The indeterminate
   label is an alternate listing for these same two animals; it covers no
   additional material.

2. **Numeric, *Tarsius*** — all 14 compared cells in `volumes_wide_select.csv`
   are identical to `Stephan_primates.csv` `Tarsius_syrichta`
   (`checks/qc_stephan/compare_all_cells.csv`, mode `raw`). Same measurements,
   two labels.

3. **Catalog, *Gorilla*** — five rows. CAT-070 (*Jinji*, Zilles/Yerkes, F, 20),
   CAT-072 (*Moshe*, Zilles), CAT-177 (Mount Sinai, "Willy B?") are
   unremarkable *G. gorilla*. **CAT-071** is Stephan, source `Congo (Uti)`.
   **CAT-069** is Stephan (Art. Nr. 3551, MacLeod H1, juvenile male) recorded
   `species = Gorilla gorilla` but `subspecies = ?East lowland`, source
   `Belgian Congo (bilota)` — flagged `subspecies-mismatch`.

4. **Why CAT-069 matters** — eastern lowland gorilla is *Gorilla beringei
   graueri* under Groves (2001). If CAT-069 contributed to the Düsseldorf
   gorilla volumetric mean, that mean pools two modern *species*, and the
   `Gorilla gorilla` label in `Stephan_primates.csv` is itself *sensu lato*.
   The merge's vaguer `Gorilla sp.` would then be the more honest label.

5. **Numeric, *Gorilla*** — 7 of 12 compared cells identical, 2 within
   rounding. The three that differ (brain volume 470,359 vs 401,785; Area
   striata grey 9,129 vs 12,062; LGN 308.5 vs 300.1) are source-precedence
   overrides in the merge, not evidence of a different sample.

## Recommended treatment

| | *Tarsius* sp. | *Gorilla* sp. |
|---|---|---|
| layer | specimen (one label, two named animals) | concept (composition uncertain) |
| `decomposable` | `TRUE` | `FALSE` |
| `modern_equivalent` | `Tarsius syrichta` | `Gorilla gorilla` — **provisional** |
| relabel in analysis | yes, unconditionally | yes, but inherited not asserted |

*Tarsius* resolves cleanly. *Gorilla* is relabelled in
`s3_..._VOLUMES_WIDE_SELECT.R` **only because `Stephan_primates.csv` and
`species.nwk` have already committed to `Gorilla_gorilla`** — the join inherits
an existing commitment rather than adding a new one. It is not an independent
finding that the material is western lowland gorilla.

## The hard rule

`modern_equivalent` is the switch the merge consumes. Where it is set, a 1:1
rewrite is permitted; where it is `NA` — as for `Pongo pygmaeus (s.l.)` — the
value is a pooled mean and must never be rewritten to a modern species. The
`Gorilla sp. (indet.)` entry carries `modern_equivalent = Gorilla gorilla`
together with `decomposable = FALSE`, which is deliberately uncomfortable: it
permits the join the analysis currently needs while recording that composition
is unconfirmed.

## What remains unresolved

- **Did CAT-069 enter the volumetric mean?** This is the question that decides
  whether `Gorilla sp. (indet.).modern_equivalent` should be reset to `NA`.
  Needs the Frahm/Stephan unpublished specimen-to-species-mean mapping.
- **CAT-069's own identity.** `resolved_taxon` is `NA`, `taxon_conflict` is
  `TRUE`. Placing it needs provenance beyond "Belgian Congo".
- **CAT-071** (`Congo (Uti)`) carries no subspecies conflict in the catalog but
  shares the Congo provenance; not currently flagged.
- *Carlito syrichta* (Groves & Shekelle 2010) is the accepted combination for
  the Philippine tarsier. `species.nwk` retains `Tarsius_syrichta` and this
  repo follows the tree.

## Sources

- `_keys/specimen_crosswalk/collection_specimens_parsed.csv` — CAT-069/070/071/072/177, CAT-167/168
- `specimens info 151211.xls`, sheet `catalog`
- Groves, C.P. (2001) *Primate Taxonomy*
- Groves, C.P. & Shekelle, M. (2010) The genera and species of Tarsiidae
- `analyses_metabol_rate_structure/checks/qc_stephan/compare_all_cells.csv`
