# Specimen tracking — identity, source, and access schema

Two record types, two files, one join. This exists because two *different*
data-integrity problems were being conflated:

1. **One individual, many labels** (e.g. gibbon *Disco* / GPZ-5542): resolvable
   at the specimen level — there is exactly one animal under all the names, so it
   can be given one identity and, as taxonomy changes, reassigned to one taxon.
2. **One label, many individuals** (e.g. a pre-2001 *"Pongo pygmaeus"* mean):
   NOT resolvable that way. Before Groves (2001) split the genus, *Pongo
   pygmaeus* was *sensu lato* and a published mean can pool Bornean + Sumatran
   (+ hybrid) animals. You **cannot un-average it**, so the old label is not a
   synonym you rewrite to one modern species — it is a **taxon concept** whose
   composition is often unrecoverable.

Layer 1 handles case (1); layer 2 handles case (2).

---

## Layer 1 — specimen crosswalks (`record_type = "specimen")

One row per **(individual × source label)**. A physical animal that appears in
three papers under two names is one `canonical_specimen` with three rows. This
generalises `fossil_specimen_crosswalk.csv` (which is the same idea for fossils)
to living-collection specimens.

The public file is `_keys/specimen_crosswalk/specimen_crosswalk.csv`. Private
rows with the same schema live in the restricted companion repository as
`specimen_registry/derived/specimen_crosswalk_restricted.csv`. They may be
combined only in an explicitly restricted build.

| column | meaning |
|---|---|
| `canonical_specimen` | stable minted id for one physical individual (the join anchor). One per animal, reused across its source rows. |
| `record_type` | always `specimen` in this file. |
| `specimen_kind` | controlled description of what the record represents: `historical_biological_specimen`, `fossil_specimen`, `in_vivo_subject`, or `unknown`. |
| `access_class` | `public` or `restricted`, determined by the evidence supporting this identity row rather than by the printed-label source alone. |
| `evidence_source_ids` | `;`-joined foreign keys to `specimen_source_registry.source_id`; includes every source needed to support the identity assertion. |
| `specimen_name` | house / nick name (`Disco`, `HARRY`, `BRIGGS`) or `NA`. |
| `primary_identifier` | best single ID (`GPZ-5542`, `YN85-38`, catalog `Art. Nr.`). |
| `alternate_identifiers` | `;`-joined other IDs seen for this animal. |
| `collection` | holding collection: `Stephan`, `Zilles`, `Yerkes`, `GWU`, `Mount Sinai`, … |
| `source_publication` | paper/dataset this row's label comes from. |
| `item_reference` | the specific table item (e.g. `MacLeod_2000_APPENDIXI`). |
| `printed_name` | taxon **exactly as printed** in that source (kept verbatim). |
| `published_taxon` | normalised binomial the source intends. |
| `resolved_taxon` | current best identity for **this individual** (may be `NA` if unresolved). Reassignable as evidence improves. |
| `taxon_concept` | FK → `taxon_concept_registry.taxon_concept`. Which concept the *printed* label belongs to (e.g. an old row printed `Pongo pygmaeus` links to `Pongo pygmaeus (s.l.)`). |
| `taxon_conflict` | `TRUE` if sources disagree on this individual's taxon. |
| `match` | `matched` / `probable` / `<source>-only` / `unmatched`. Use `probable` when public evidence strongly supports one animal but no accession or explicit identity statement closes the link. |
| `sex` | `M`/`F`/`NA`. |
| `note` | free text: evidence, links, caveats. |

### `specimen_kind` rule

`fossil_specimen` means fossil or archaeological remains, or an endocast or
reconstruction tied to those remains. It does not imply a known living animal
record. Fossil rows remain individuals for cross-publication deduplication, but
consumers must be able to exclude them with a direct field filter and must not
infer fossil status from taxon names. See `SPECIMEN_INFORMATION_BOUNDARY.md`.

### Source and access rule

`source_publication` records where the row's printed label appears.
`evidence_source_ids` records what establishes the identity link. These are not
always the same. For example, a public Bush table can supply a species row while
an unpublished author workbook supplies the accession mapping; that crosswalk
row is `restricted`.

All IDs in `evidence_source_ids` must occur in
`specimen_source_registry.csv`. A public row must not cite a restricted source.

## Layer 2 — `taxon_concept_registry.csv`

One row per **taxonomic concept** used as a label anywhere in the corpus,
especially older *sensu lato* concepts that predate a modern split.

| column | meaning |
|---|---|
| `taxon_concept` | primary key, e.g. `Pongo pygmaeus (s.l.)`. |
| `sensu` | `s.l.` (sensu lato / broad) · `s.s.` (sensu stricto / narrow) · `NA`. |
| `rank` | `species` / `subspecies` / `genus` / … |
| `valid_period` | when this concept was in use, e.g. `pre-2001`, `2001-present`. |
| `decomposable` | `TRUE` only if a pooled mean under this concept can be split into modern species with the evidence in hand. Usually `FALSE`. |
| `believed_composition` | what a sample under this concept may contain (the honest statement of the uncertainty). |
| `split_authority` | taxonomic authority for the split (e.g. `Groves 2001`). |
| `superseded_by` | `;`-joined modern concept(s) that replace it. |
| `modern_equivalent` | single modern binomial **iff** the mapping is 1:1; else `NA`. |
| `note` | free text. |

---

## The join

`specimen_crosswalk.taxon_concept`  →  `taxon_concept_registry.taxon_concept`

A specimen row's `taxon_concept` records **which concept its printed label
belonged to**. The specimen's *own* best identity lives in `resolved_taxon` and
can differ from the concept (that is the whole point of YN85-38: printed under
the *P. pygmaeus s.l.* concept, resolved as *P. abelii*).

External museum, catalog, studbook, or biodiversity identifiers use the
separate one-to-many table `specimen_external_links.csv`; they are not added as
repeating columns here.

The public file contains links supported entirely by public evidence. Links
whose identity bridge depends on a private memo, catalog, correspondence, or
other restricted source use the identical schema in the companion repository:
`specimen_registry/derived/specimen_external_links_restricted.csv`. As with the
crosswalk, restricted and public links are combined only in an explicitly
restricted build. `match_status` uses `matched`, `probable`, or `unmatched`;
studbook links remain `probable` until an accession statement or equivalent
record explicitly connects the biological specimen to the studbook animal.

## The hard rule for the merge (consumer contract)

- A value that is a **specimen measurement** may be reassigned to a modern
  species via `resolved_taxon` (with `taxon_conflict` surfaced, never silently).
- A value that is a **pooled mean under an s.l. concept** with
  `decomposable = FALSE` is **never auto-rewritten** to a modern species. It
  stays under its concept label; at most it is annotated with
  `believed_composition`. Splitting it would fabricate composition the source
  never resolved.
- This is distinct from the DeCasien cross-genus *duplicate* case (Disco): a
  duplicate is one specimen double-entered under two genera (resolve by
  dedup); an s.l. pooled mean is many specimens under one genus (do not split).
- Fossil versus historical/in-vivo filtering is controlled by `specimen_kind`,
  independently of this specimen-versus-taxon-concept rule.
- Public builds use only `access_class = public`. Restricted overlays must be
  requested explicitly; their presence on disk must not silently change a
  build.
