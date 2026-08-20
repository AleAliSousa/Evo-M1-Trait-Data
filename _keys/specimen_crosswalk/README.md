# Specimen crosswalk and taxon-concept registry

Cross-paper harmonisation keys at the specimen and taxon-concept levels. The
identity model, source provenance, and public/restricted boundary are defined
in `SCHEMA.md` and `SPECIMEN_INFORMATION_BOUNDARY.md`.

## Two identity problems

| problem | example | file | mechanism |
|---|---|---|---|
| one individual, many labels | gibbon Disco / GPZ-5542, published under conflicting taxa | specimen crosswalk | one `canonical_specimen`; resolve only with evidence |
| one label, many individuals | pre-2001 `Pongo pygmaeus` mean pooling Bornean and Sumatran animals | taxon-concept registry | pin to the broad concept; never un-average |

A specimen can be reassigned as taxonomy changes. A pooled *sensu lato* mean
cannot be split into modern species without fabricating its composition.

## Files in this public repository

| file | contents |
|---|---|
| `SCHEMA.md` | authoritative column contracts and merge consumer rules |
| `SPECIMEN_INFORMATION_BOUNDARY.md` | source/access decision, fossil distinction, split architecture, and external-link plan |
| `specimen_source_registry.csv` | evidence-source inventory with publication status, access class, specimen kind, location, and split action |
| `specimen_crosswalk.csv` | public identity rows, one per individual × source label, with explicit `specimen_kind` |
| `taxon_concept_registry.csv` | broad, narrow, fossil-grade, extant, and indeterminate taxon concepts |
| `specimen_external_links.csv` | initially empty table for later museum, catalog, studbook, and biodiversity-database links |
| `split_manifest_2026-08-19.csv` | artifact-level record of the initial move/sanitize decisions and row conservation checks |
| `pongo_provenance_audit.csv` | public-source Pongo entries classified as specimen or taxon concept |
| `fossil_specimen_crosswalk.csv` | published Kochiyama/Weaver fossil aliases, explicitly typed as fossils |
| `fossil_specimen_cerebellum_comparison.csv` | published fossil method-offset comparison |

Restricted companions live under
`Evo-M1-Traits-Data-restricted/specimen_registry/`:

- `source_material/specimens_info_151211.xls` — unpublished master catalog.
- `derived/collection_specimens_parsed.csv` — parsed private catalog.
- `derived/specimen_crosswalk_restricted.csv` — private identity overlay with
  the same columns as the public crosswalk.
- `cases/` — full evidence notes and audits that depend on private sources,
  including Bush-Allman, the catalog-dependent Pongo material, and the
  Gorilla/Tarsius catalog case.

## Source and access rule

Every crosswalk row cites `evidence_source_ids` from
`specimen_source_registry.csv`. `source_publication` says where the printed
label occurs; it does not by itself establish the identity link. A row whose
printed label is public remains restricted when the link to a physical animal
depends on a private catalog, workbook, or correspondence.

The public crosswalk must work by itself. A restricted overlay can be added
only in an explicitly restricted build. Merely mounting the companion
repository must not silently change output.

## Fossils

Fossils remain specimen records because the same named fossil can be measured
in several studies. They carry `specimen_kind = fossil_specimen`, which means
fossil or archaeological remains or an endocast/reconstruction tied to them;
it does not imply a known living research animal.

Consumers must filter fossils by `specimen_kind`, not by taxon strings. In
particular, early fossil *Homo sapiens* must never be pooled automatically with
the extant-human mean merely because the binomial is identical.

## Joins

```text
specimen_crosswalk.taxon_concept
    -> taxon_concept_registry.taxon_concept

specimen_crosswalk.evidence_source_ids
    -> specimen_source_registry.source_id   (one or more IDs)

specimen_external_links.canonical_specimen
    -> specimen_crosswalk.canonical_specimen
```

The specimen's best current taxon lives in `resolved_taxon`; the concept of the
printed label lives in `taxon_concept`. A specimen measurement may be
reassigned through `resolved_taxon`, with conflicts surfaced. A pooled mean
under a non-decomposable broad concept is never rewritten to a modern species.

## Public Pongo example

MacLeod 2000 prints YN85-38 with both `PONGO PYGMAEUS` and `ABELII`, supporting
resolution to *Pongo abelii*. Smaers 2011 prints the same `yn85 38` identifier,
so that link can be supported entirely by public sources; Smaers 2017 carries
the measurement forward through a public value match.

By contrast, a Zilles/Rehkämper value printed only as `Pongo sp.` remains
attached to `Pongo pygmaeus (s.l.)`. DeCasien's promotion of that value to
modern `Pongo pygmaeus` must not be accepted silently. Catalog-only matches
and metadata stay in the restricted overlay and full evidence note.

## Adding a case

1. Register every evidence source in `specimen_source_registry.csv` and decide
   its access class before adding an identity row.
2. Set `specimen_kind` from evidence. Never infer fossil status from the taxon
   string.
3. Add the identity row to the public or restricted crosswalk as appropriate;
   set `resolved_taxon` only with evidence and surface `taxon_conflict`.
4. For an old broad pooled label, add or reference a non-decomposable row in
   `taxon_concept_registry.csv` rather than pretending it is one modern species.
5. Write a source-appropriate note and audit where the value enters the merge.
