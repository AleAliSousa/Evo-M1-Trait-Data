# Pilot metadata source catalog

This catalog answers a question before any point is qualified: **which
resource supplies each kind of metadata, and how does that resource relate
to a registered dataset item?** It catalogs all 39 registered items from ten pilot
papers, including the Mink bibliography, Boddy raw database, Heffner Table 1,
Bahney Tables 1–4, seven Fobbs museum catalogs, and two Kennedy items. Supporting
files remain distinct from public items in `__ReadMe.xlsx`.

The [file-level registry](PIPELINE_FILE_REGISTRY.md) now gives every active
pilot source, builder, supporting table, and output its own file row. The
paper-local `pipeline_files.csv` and `file_dependencies.csv` files are the
editable registration source; the older `metadata_sources.csv` files are
ancillary comparison views. The shared register covers the pilot's central
R scripts, configuration, keys, and generated reports.

The [reference-table audit](REFERENCE_TABLES_AUDIT.md) lists which
definitions and citation lookups the qualification gate reads, which it only
catalogues, and how to build source metadata alongside values.
The [metadata-table convention](METADATA_TABLE_CONVENTION.md) gives all 47
paper-local supporting CSVs one location and typed naming rule.
The [definition schema audit](DEFINITION_TABLE_SCHEMA_AUDIT.md) classifies
all 501 rows of the 25 current definition files for a typed migration. Seven
malformed CSV rows were repaired; three Buchsbaum aggregate labels and the
scope of many method rows remain for review.

Run from the repository root:

    Rscript __metadata/pilot/build_catalog.R
    Rscript __metadata/pilot/build_folder_metadata.R
    Rscript __metadata/pilot/build_file_registry.R
    python3 __metadata/pilot/validate_metadata_tables.py

The folder contract and registration decisions are in
[FOLDER_METADATA_CONTRACT.md](FOLDER_METADATA_CONTRACT.md) and
[REGISTRATION_POLICY.md](REGISTRATION_POLICY.md).

The R builder reads items.csv, artifacts.csv, field_routes.csv, and the
live __ReadMe.xlsx. It validates paths and links, then writes catalog.sqlite
with item, artifact, and field_route tables. `build_folder_metadata.R` reads
the same `pipeline_files.csv` contract in each of the ten paper folders,
validates every registered item against its R builder, CSV, and public TSV,
and writes `folder_metadata.sqlite`. `build_file_registry.R` combines all
paper and shared file rows into `file_registry.sqlite`, checks dependency
keys and reference-table coverage, and verifies the file IDs and paths still
match the active catalog artifacts. The existing registry, paper source
files, keys, and measurement inventory are read-only inputs.

## Three distinct entities

| Entity | Meaning | Example |
| --- | --- | --- |
| Item | A public TSV with one __ReadMe.xlsx registry row. `item_kind` describes its predominant content or grain; it does not decide whether every field is data or metadata. | Mink REFERENCES is a registered reference-list item; Kennedy Table is an observation item; Fobbs Table S4 is a specimen catalog. |
| File | A physical file with its own file ID, creation mode, producer, and authority status. `artifacts.csv` still carries legacy route annotations and is checked against these file IDs. | Mink TABLE1_references.csv is a pipeline-registered supporting lookup derived from a registered item builder. |
| Field route | A documented way to obtain one metadata field for one item, with an exact locator, granularity, checkpoint, and assertion kind. | The Source column beside a ManyPrimates predictor gives its per-row cited work. |

A bibliographic work mentioned in a Source cell is a fourth concept. It
is not automatically a registered item or an available original
measurement. The pilot's point_reference table can record its role after
the cited work is identified.

## Where the metadata currently lives

| Location | Catalog role | Example |
| --- | --- | --- |
| __ReadMe.xlsx | Registry of item identity and encoded public output. | Mink REFERENCES and Mink TABLE1 have separate item rows. |
| __Public/comparative-data | Registered item output, including some metadata items. | Mink REFERENCES public TSV is a registered bibliography item. |
| Paper folder | Published evidence, frozen source snapshot, or item-specific processing file. | ManyPrimates source data and its snapshot builder. |
| Paper-folder reference_tables | Typed definitions, citation lookups, taxon annotations, review tables, and generated source checks; all 47 pilot files have file-level registration, while only independent public matrices enter `__ReadMe.xlsx`. | Mink TABLE1_references.csv. |
| _keys active crosswalks | Shared curated taxon names and source-specific variants. | _keys/species_reference.csv and _keys/Stephan/species_key.csv. |
| _keys specimen crosswalk | Curated specimen identity and taxonomic history, distinct from a paper-local name annotation. | _keys/specimen_crosswalk/specimen_crosswalk.csv for Fobbs records. |
| _keys generated indexes | Reproducible summaries of definitions or curated basis rules. | _keys/variable_catalog.csv and _keys/brain_size_basis.csv. |
| __measurements/config | Explicit extraction and report-link decisions. | column_rules.csv and report_links.csv. |
| __metadata/curation | Reviewed row-level decisions used before a merge. | brain_mass_row_basis.csv and brain_mass_value_flags.csv. |
| __merging_* | Derived merge results and source-choice audits. | brain_mass_unfiltered.csv. |

The storage_zone column records **where** a file is; authority_stage
records **when its content may be used**. This keeps an unregistered
reference lookup, a curated key, and a downstream audit distinct even
when all three are CSV files.
The file registries cover 397 active, ancillary, and retired physical files
and 548 declared dependencies. The older route catalog covers 39 public items, 291
artifacts, and 526 field routes; three historical `__merging_*` artifacts
remain in that catalog but are excluded from the active file register.
The combined `file_registry.sqlite` also joins 523 file-backed field routes.
Its `file_registration_issues.csv` lists 20 snapshots with unknown creation
mode and 45 manually curated paper-metadata tables without a confirmed
source-file locator. These are review tasks, not unregistered files.
The folder validator reports 17 items with value-level measurement routes
and 22 catalog-only items in `item_route_coverage.csv`; every item still has
a definition route and a linked R→CSV→TSV path.
Its `folder_metadata.sqlite` joins 192 paper-local resources to 431
catalogued field uses: 39 registered matrices, 94 unregistered matrices,
and 59 other unregistered sources. The `field_evidence` view retains the
actual evidence path and locator for each join.

Heffner Table 1 is routed from its printed-layout snapshot through its CSV
and public TSV. The source snapshot has separate citation letters for hearing
frequency and basilar-membrane length. The footnote table preserves the printed
letters, while an item-scoped references table resolves them to full citations
where the paper supplies them. Its reviewed citation-scope declaration links
each key column to the appropriate measure. Generated source-match, summary,
and issues tables record the resulting key-to-value links. Functional interaural distance has
no per-row citation letter. Its definitions now use the same ten-column
schema as the other pilot items. All item rows are secondary, including the
*Tursiops* row that an earlier README classified as primary because of
downstream use. The public item retains both the PDF's printed
`Tursiops truncates` and normalized `Tursiops truncatus` in separate fields.

Bahney Tables 1–4 each have a frozen snapshot, item builder, registered TSV,
and ten-column definitions file. Tables 3 and 4 additionally have item-scoped
reference lookups. Their reviewed `reference_columns.csv` declarations assign
each citation to `row_overall`, preserving the reported association without
attributing it to every separate measure in that row. The two own-study spinal-cord rows
in each compiled table must be classified at row level. All four items route
to the accepted-species reference and the active General species crosswalk.

For the added source comparison, Buchsbaum 1989 Table I is routed from the
publication PDF through its frozen snapshot and long public TSV. Its
definitions specify the regional measure, unit, source role, and arm
context. Kaufman 2004 Table A3 is routed from the dissertation PDF and
snapshot through its checked correction overlay and public TSV. Its
`Reference` field points to an exact citation lookup in
`Kaufman__2004/reference_tables`, which resolves the Buchsbaum citation
to the original paper. The catalog also routes the candidate original
Buchsbaum row so the source-choice check can compare the reported values.
The shared accepted-species table remains the taxon authority; the
paper-local Buchsbaum species key is explicitly a proposal.

Fobbs Tables S1a, S1b, S2, S3, S4, S5a, and S5b are registered
`specimen_catalog` items. Each route starts at the published Word supplement,
passes through a frozen workbook and item builder, and reaches a public TSV.
Definitions under `reference_tables/` are item-processing metadata, not
tables supplied as such by the publication. S2, S4, and S5b use additional
paper-local taxon lookup files to annotate printed names; those annotations
are separate from the curated specimen crosswalk and accepted-species
reference. S4 is a box inventory, and the other catalogs mix specimen and
preparation fields. S1a's two body-length columns are routed as reported
specimen values, with their `Measure=count` definition error flagged for
review. The S2 and S5a section-thickness definitions have the same type
error. Catalog section counts, thickness, and slide counts do not become
species brain trait measurements merely because they are numeric. The
paper's role as compiler of legacy collections is routed separately from
the unproven original observer of each S1a length. The
`source_row` fields are assigned after layout filtering, so the catalog does
not claim that they are Word-document row numbers.

Kennedy 1978 has separate registered Table and Text items. The Table holds
39 primary regional glucose-use group means. The Text item mixes original
estimates and single-animal values with cited and repeated values; its
per-row `data_role` and `value_status` govern source-role review, rather
than the generic primary role in its definitions file. The item-scoped
references lookup resolves numbered citations 20 and 22: ref 20 identifies
Schmidt 1945, while the original measurement behind the human value cited
via ref 22 remains unresolved. Kennedy's proposed species key is not an
approved crosswalk. In particular, `monkey` in the rows citing Schmidt 1945
cannot inherit Kennedy's rhesus identity because Schmidt's reported mean
pooled animals from more than one genus. The Text erratum and cross-item
check retain the printed 29 despite a recomputed value near 30.04.
The Kennedy README files and catalog now agree with their live registry rows
and public TSVs.

Kaufman Table A3 has a live registry row and a public TSV whose filename
matches its registered `Item encoded` field. The registry's cached
`Public TSV match` field currently says `notfound`; this catalog verifies
the physical output and encoded filename independently of that cache.

## Controlled distinctions

artifacts.csv uses registration_status = registered_item_output only for
an item's public TSV. All other artifacts use supporting, even
when they support a registered item. The builder checks that exactly one
registered output artifact matches each item's live Item encoded TSV stem.
Thus "supporting" does not mean missing or low quality.

authority_stage has four values:

| Stage | What it means | Typical source |
| --- | --- | --- |
| source_evidence | Published or supplied evidence, preserved before cleaning. | Paper, supplement, frozen snapshot, original row citation. |
| item_processing | Item-scoped interpretation or output. | Analysis TSV, definitions, reference lookup. |
| curated_authority | Project-level decision with evidence, made before a merge. | Active taxon key or audited measurement basis. |
| downstream_product | Species merge or audit produced after item ingestion. | A __merging_* output. |

The builder permits a downstream_product route only at the source_choice
audit checkpoint. This prevents a merge output from supplying its own
snapshot, definition, source_trace, method_review, taxon_review, or
qualification metadata.
If a merge audit contains a decision needed before the merge, promote
that decision into a curated upstream resource with its source evidence;
the merge output can then consume it. Physical file location alone does
not determine whether content is authoritative, but a downstream
product cannot silently certify its own input.

## What the catalog does and does not decide

field_routes.csv is a **routing plan**, not a table of resolved claims.
A route says to read the cited source column, definition row, key row, or
paper method at a specified point in the workflow. It does not conclude
that a citation is primary, that a method is known, or that two values are
independent. Those are separate per-point assertions and review decisions
in the metadata gate. Source role and qualification remain separate, and
selection of a final species value happens after qualification.

The route catalog's three inputs remain diffable during migration:

- items.csv records item_id, item_kind, and public_tsv_path.
- artifacts.csv records artifact_id, path, storage_zone, artifact_kind,
  registration_status, owner_item, authority_stage, granularity, producer,
  and note.
- field_routes.csv records item_id, metadata_field, artifact_id, locator,
  assertion_kind, granularity, and checkpoint.

Paper-local artifact IDs and paths are checked against `pipeline_files.csv`.
The [artifact derivation preview](ARTIFACT_DERIVATION_PREVIEW.md) identifies
legacy columns that need explicit translation before `artifacts.csv` can be
generated instead of maintained separately. File registration and source
review remain separate from this route index.

Paths are relative to the repository root. Paths for operational source,
item-processing, and curated-authority artifacts must exist. Historical
`downstream_product` paths may be absent; they remain catalogued for the
legacy audit, but the no-merge pilot route does not read them. IDs must be
unique, route foreign keys must resolve, every item must match exactly
one live registry row by Item name, and its TSV filename stem must equal
the registry's Item encoded value. catalog.sqlite enforces item and
artifact foreign keys and exposes metadata_routes, checkpoint_coverage,
artifact_registration, and stage_location_flags views. The last view lists
upstream-curated artifacts that still physically live under a __merging_*
directory, so their relocation can be planned without concealing the
current path.

For example, query one item's evidence routes from R:

    con <- DBI::dbConnect(RSQLite::SQLite(),
                          "__metadata/pilot/catalog.sqlite")
    DBI::dbGetQuery(con,
      "SELECT metadata_field, checkpoint, path, locator, authority_stage
       FROM metadata_routes
       WHERE item_id = 'Mink_etal_1981_TABLE1'
       ORDER BY checkpoint, metadata_field")
    DBI::dbDisconnect(con)

This is a lightweight relational catalog. Its design borrows the
source-entity and derivation distinction from [W3C PROV-O](https://www.w3.org/TR/prov-o/),
measurement field names from [Darwin Core MeasurementOrFact](https://dwc.tdwg.org/terms/),
and explicit keys and resource links from [Frictionless Table Schema](https://specs.frictionlessdata.io/table-schema/).
It does not require RDF or another database language: R builds and queries
SQLite through DBI.

## Point assertion audit

The seven-step `pilot_single_pipeline/run_pilot.R` entrypoint runs this after
qualification. To rebuild the audit alone, run:

    Rscript __metadata/pilot/build_assertion_audit.R

This writes `point_assertions.csv` (one row per point and metadata field),
`assertion_evidence.csv` (zero or more source links per assertion), and a
queryable `assertion_audit.sqlite` mirror with point, artifact, assertion,
and evidence foreign keys. The
current export covers all 5,285 pilot points, including 699 qualified
points. `point_id` joins the assertion table to `pilot_points.csv`;
`assertion_id` joins its evidence links; a nonblank `artifact_id` joins the
catalog. Blank artifact IDs identify an explicit path to a pilot file that
is not yet catalogued, or an unresolved evidence link.

`pilot_status` copies the existing qualification field status when one
exists; `present` means only that a value was recorded. It is independent
of `link_status`. `exact_located` identifies a verified TSV cell or keyed
row, `item_route_only` identifies a paper, snapshot, or table lead without
a point-specific original-source locator, and `rule_pointer_only` points
to the pilot code that made a decision. A short cited-work label located
in a Boddy curation row is not proof that the underlying specimens match
another paper's reports. Primary reports have an explicit
`upstream_reference` status of `not_applicable` in this audit.

The builder checks every pilot `source_locator` against the registered
public TSV row and column and requires `raw_value` to match the cell. It
also checks the qualified definition code, accepted-name key, reporting
registry row, and Boddy row-basis key where applicable. This audit does
not change qualification, select reports, or certify that an item-level
paper route is an exact original publication locator.
