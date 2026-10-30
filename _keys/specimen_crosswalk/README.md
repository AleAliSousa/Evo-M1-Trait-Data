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
| `via_data_source_registry.csv` | mixed secondary/author-supplied datasets, independence class, and default merge treatment |
| `specimen_crosswalk.csv` | public identity rows, one per individual × source label, with explicit `specimen_kind` |
| `taxon_concept_registry.csv` | broad, narrow, fossil-grade, extant, and indeterminate taxon concepts |
| `specimen_external_links.csv` | initially empty table for later museum, catalog, studbook, and biodiversity-database links |
| `split_manifest_2026-08-19.csv` | artifact-level record of the initial move/sanitize decisions and row conservation checks |
| `pongo_provenance_audit.csv` | public-source Pongo entries classified as specimen or taxon concept |
| `kaas_young_collins_provenance_audit.csv` | Kaas-team Young/Collins/Turner specimen overlaps and merge treatment |
| `fossil_specimen_crosswalk.csv` | published Kochiyama/Weaver fossil aliases, explicitly typed as fossils |
| `fossil_specimen_cerebellum_comparison.csv` | published fossil method-offset comparison |
| `Disco_gibbon_specimen_note.md` | public account of the gibbon Disco / GPZ-5542 one-individual-many-labels case, with the MRI and Semendeferi addendum |
| `Disco_study_list_public.csv` | the studies that used Disco, public handles only |
| `Pongo_specimen_note.md` | public-source account of the pygmaeus→abelii split; the catalog-dependent evidence note is restricted |
| `EarlyHomoSapiens_fossil_vs_extant_specimen_note.md` | why named fossils stay specimens but remain filterable from extant reference samples |
| `Kaas_Young_Collins_specimen_overlap_note.md` | public evidence linking Young 2013 M1 rows to Collins/Young/Turner cases |

The four public specimen notes above were consolidated here from the former
`____Collections and Specimen notes/` folder, which no longer exists; each now
sits beside the provenance audit it explains.

Restricted companions live under
`Evo-M1-Trait-Data-restricted/specimen_registry/`:

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

The via-data registry handles a different provenance problem: a paper can be
mostly secondary while also being the first public route to values supplied by
an earlier measurement team. Such a publication is not automatically a new
independent team. Genuine gap-filling values retain both their measuring team
and their route of access.

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

## Public Kaas-team example

Young 2013 reports species-level M1 rows without case numbers. Numerical fingerprints and source
institutions link its owl monkey and normal baboons to Collins/Young/Turner cases, but those Young
rows remain `probable`; later rows that print case numbers are `matched`. Its three-galago mean is
explicitly `partial_overlap` and cannot be decomposed. The Young/Collins chimpanzee link is also
high-confidence `probable`, so consumers must not count it as an independent animal by default.
See `kaas_young_collins_provenance_audit.csv` and the corresponding public specimen note.

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

## File roles

Every file here is one of three things, and the distinction is load-bearing:
a **source** is hand-authored here and is the authority for its content; an
**output** is the public half of work done in
`Evo-M1-Trait-Data-restricted/specimen_registry/` and should be regenerated
there rather than edited here; a **contract** defines how consumers read the
rest. Machinery that combines the public and restricted layers does not live
here at all — it lives restricted-side, because only that side can see both.

| file | role |
|---|---|
| `specimen_crosswalk.csv` | source |
| `fossil_specimen_crosswalk.csv` | source |
| `taxon_concept_registry.csv` | source |
| `specimen_source_registry.csv` | source (also the boundary record) |
| `specimen_external_links.csv` | source |
| `via_data_source_registry.csv` | source — **no script reads it**; wire or retire |
| `SCHEMA.md` | contract |
| `SPECIMEN_INFORMATION_BOUNDARY.md` | contract |
| `IDENTIFIER_MATCHING_RULES.md` | contract |
| `README.md` | contract |
| `split_manifest_2026-08-19.csv` | historical record |
| `IDENTIFIER_JOIN_PASS_METHOD.md` | output (method half; results are restricted) |
| `audit/*.csv` | output (public rows of the restricted join pass) |
| `Disco_gibbon_specimen_note.md`, `Disco_study_list_public.csv` | output (public half; restricted half in `cases/hylobates/`) |
| `Pongo_specimen_note.md` | output (public half; restricted half in `cases/pongo/`) |
| `EarlyHomoSapiens_fossil_vs_extant_specimen_note.md` | output (no restricted half — fossils carry none) |
| `Kaas_Young_Collins_specimen_overlap_note.md` | output (no restricted half — published evidence) |
| `early_homo_sapiens_provenance_audit.csv`, `kaas_young_collins_provenance_audit.csv`, `pongo_provenance_audit.csv`, `fossil_specimen_cerebellum_comparison.csv` | output |

The crosswalk is a **source, not a generated view**, and should stay one: 99 of
its 134 rows concern specimens with no restricted counterpart, and for 13
specimens it holds a published `sex` value the restricted layer does not have.
Regenerating it from the restricted side would delete those.

`validate_specimen_layers.R` moved to
`Evo-M1-Trait-Data-restricted/specimen_registry/` on 2026-09-20: it validates
both layers together and its only caller is `build_combined_specimen_registry.R`.

## Collection vocabulary

`_keys/collection_registry.csv` is **active** as of 2026-09-20 — it is no longer
documentation. `specimen_registry/normalise_collections.R` reads it with both
specimen layers and writes `specimen_registry/derived/collection_group_map.csv`,
mapping all 29 attested collection strings to 15 groups with zero unmapped. It
**fails** rather than warns when a string is not covered.

The attested `collection` text is never rewritten — `collection_group` is a
companion for joining and `collection_qualifier` keeps the rest, because
"ex Yerkes" and "later NMHM/AFIP" are information a controlled vocabulary would
destroy. Two rows may be treated as the same collection only when their
`collection_group` sets intersect; `UNKNOWN` never matches `UNKNOWN`.
