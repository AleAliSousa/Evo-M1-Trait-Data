# Specimen-information provenance and repository boundary

## Decision

Specimen information is separated by the source and disclosure status of the
identity claim, not merely by whether a row is at specimen level.

- Information printed in a paper, supplement, dissertation, or intentionally
  public institutional record may remain in this repository.
- Unpublished catalogs, author workbooks, correspondence, and any identity
  link that depends on them belong in the restricted companion repository.
- A row whose printed label is public can still be restricted when the link
  from that label to a physical animal was established using private evidence.
- Mixed notes are split into a public account and a restricted evidence note;
  private details must not be paraphrased back into the public account.

`specimen_source_registry.csv` is the source-level trace used to make these
decisions. Each crosswalk row carries `evidence_source_ids`, which point to one
or more rows in that registry, plus its own `access_class`.

## What a specimen row represents

`specimen_kind` makes the biological context explicit and filterable:

| value | meaning |
|---|---|
| `historical_biological_specimen` | A documented animal or human individual represented by a biological collection record or preserved biological material. This does not assert that the individual was alive when measured. |
| `fossil_specimen` | Fossil or archaeological remains, or an endocast/reconstruction tied to such remains. No record of a known living research animal is implied. |
| `in_vivo_subject` | An individually identified subject measured while alive. Reserved for future records supported by the source. |
| `unknown` | The available source does not establish which of the above applies. |

Fossils remain specimen-level records because individual fossils can recur
across studies, but they are not treated as historical animal subjects. They
must be filterable with `specimen_kind == "fossil_specimen"` and must never be
pooled automatically with extant individuals solely because the taxon name is
the same. The early-*Homo sapiens* fossil-grade rule remains in force.

## Public and restricted layers

The two repositories use the same crosswalk columns.

```text
public specimen_crosswalk.csv
        +
restricted specimen_crosswalk_restricted.csv
        -> validated authorized view
```

The public layer must be usable on its own. A future restricted build may add
the private overlay through `_tools/restricted_data.R`, but build mode must be
explicit; the result must not change silently just because the companion
repository happens to be mounted.

The restricted layer is authoritative for exact identities established from
private sources. A public row may use the same `canonical_specimen` only when
the identity can be supported entirely by public sources. Otherwise the public
record remains unresolved until a releasable bridge is available.

## Initial split

The first pass covers the highest-confidence cases:

1. Move the unpublished master catalog and its parsed derivative to the
   restricted repository.
2. Move Bush-Allman accession mappings, author-workbook-derived rows, audit,
   and evidence note to the restricted repository. Although the Bush papers
   are public, their exact contributor-to-accession links are not printed in
   those papers.
3. Retain MacLeod dissertation rows and other directly published specimen
   records in the public layer, after removing any private-catalog-only claims
   from their notes.
4. Keep fossil records public and mark them explicitly as `fossil_specimen`.
5. Classify mixed Pongo, Smaers, and de Sousa identity links row by row; do not
   assume that a public paper label makes a private catalog match public.

The source registry records which mixed cases are already split and which
still require review. This incremental approach prevents the provenance key
from becoming a hidden dependency while the volume merge does not yet consume
it.

## Future links to broader databases

External catalog, museum, studbook, and biodiversity identifiers belong in
`specimen_external_links.csv`, one row per specimen-database assertion. They
should not become new columns in the crosswalk because one specimen can have
many external identifiers and each match needs its own status and evidence.

The link table is intentionally empty at the start. A link is added only when
the cited evidence supports it, using `match_status` to distinguish confirmed,
candidate, and rejected matches. Restricted external links remain in the
restricted companion table rather than being copied into the public file.

## Consumer rules

1. Filter fossils by `specimen_kind`, not by taxon name or specimen-name
   heuristics.
2. Join provenance through `evidence_source_ids` and the source registry.
3. Never infer that two rows are the same animal merely because their
   collection or species agrees.
4. Continue to distinguish one-individual-many-labels from a pooled
   taxon-concept mean; the specimen/taxon-concept consumer contract in
   `SCHEMA.md` is unchanged.
5. Do not publish a restricted-derived output until its release status has
   been decided independently of whether identifiers were removed.

## Git-history limitation

Moving a tracked file does not remove earlier versions from Git history. This
split governs the working tree and future commits. Any decision to rewrite
published history is a separate, coordinated operation.
