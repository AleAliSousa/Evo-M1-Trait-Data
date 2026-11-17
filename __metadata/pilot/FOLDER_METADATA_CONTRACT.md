# Paper-folder file and metadata contract

Each of the ten pilot paper folders contains `pipeline_files.csv` and
`file_dependencies.csv`. The first registers one physical file per row; the
second records confirmed input/output relationships. Paths are relative to
the repository root. Existing source files stay where they are. The older
`metadata_sources.csv` is an ancillary comparison view and is no longer read
by the active folder validator.

## Common logical folder structure

```text
Paper_folder/
  pipeline_files.csv              one row per source, script, metadata file,
                                  registered CSV, and public TSV
  file_dependencies.csv           confirmed file-to-file relationships
  publication and supplements      printed evidence, in their original formats
  *_snapshot.*                    frozen extraction before item processing
  Item.R                          registered item builder, one per item
  Item.csv                        local registered matrix built by Item.R
  Item.README.md                  item-specific extraction and provenance notes
  reference_tables/              definitions, citation lookups, taxon annotations,
                                 errata, and other paper-scoped metadata tables
```

All ten pilot folders now place their supporting metadata CSVs under
`reference_tables/`. The shared [metadata-table convention](METADATA_TABLE_CONVENTION.md)
defines their scope token, type suffix, and type-specific schema checks.

The names and physical locations of legacy source files vary. The file register
gives all ten folders the same *logical* structure without moving published
files or breaking existing item builders. A source's folder location does not
decide whether it is a public item: the live `__ReadMe.xlsx` does. A frozen snapshot may
contain source data while remaining unregistered; a final candidate value
must flow through a registered item R builder and its CSV/TSV output.

The full column contract, creation modes, and migration checks are in
[PIPELINE_FILE_REGISTRY.md](PIPELINE_FILE_REGISTRY.md). `file_id` reuses a
catalog artifact ID where one exists, so a field route and a file registration
refer to the same file. A registered item has separate rows for its R builder,
local CSV, and public TSV. `producer_id` points from generated files to their
known builder; a blank producer is explicit through `creation_mode`.

Registration and metadata use are independent. Mink `REFERENCES` and the seven
Fobbs supplements are registered matrices even when they primarily provide
bibliographic or catalog metadata. A registered value TSV can also contain a
project-added field: Fobbs S2/S4/S5b `Species_binomial` comes from an
unregistered taxon lookup. Conversely, an unregistered definitions or citation
table can be required for qualification without becoming a registry item.
`content_role_vocabulary.csv` validates the detailed labels and maps them
to broader groups such as `measurement`, `citation`, `definition`, `taxon`,
`source_evidence`, and `review_audit`. The broad group makes the ten folders
comparable; field routes still express the multiple uses of one matrix.
`authority_status_vocabulary.csv` validates the artifact statuses. A
`project_lookup` or `project_definition` label does not mean every row has
been accepted; proposal and review decisions remain at assertion grain.

The file register identifies resources, not assertions. `field_routes.csv` gives
the field, locator, checkpoint, and item uses for each resource; report-level
metadata and review decisions belong in the qualification tables. A blank
`related_item_id` for a shared file, such as Kaufman's definitions and
bibliography lookup, must not be interpreted as unused. Source-role labels,
taxon identity, citation resolution, method, and units require their own
point- or field-level checks. `source_class` and `authority_status` never turn
a value into an approved primary observation.

## Coverage of the ten source patterns

| Paper folder | Registered matrices | Metadata pattern exercised |
| --- | ---: | --- |
| ManyPrimates 2022 | 2 | Predictor values have adjacent Source and Comments fields; definitions and source workbooks are separate resources. |
| Mink 1981 | 2 | `REFERENCES` is itself a registered bibliography; the Table 1 citation-key lookup is an unregistered derived matrix. |
| Boddy 2012 | 2 | Table S1 and the raw database carry distinct source and conversion context; row-basis review is a separate table. |
| Falcone 2019 | 2 | Categorical ILA presence and numeric morphometry need different definitions and taxon review. |
| Buchsbaum 1989 | 2 | Table I and Text are registered; printed region, arm, and method context comes from definitions and publication prose. |
| Kaufman 2004 | 15 | Appendix matrices share unregistered bibliography and definition tables; citation keys must be resolved per item and row. |
| Heffner & Heffner 2010b | 1 | Different superscript keys apply to hearing and basilar-membrane cells; citation scope is declared in an unregistered table. |
| Bahney & von Bartheld 2018 | 4 | Original and literature rows coexist; Tables 3–4 use paper-scoped reference lookups and row-level citation scope. |
| Fobbs 2011 | 7 | Registered museum catalogs rely on Word supplements and unregistered taxon annotations; S1a also contains body lengths. |
| Kennedy 1978 | 2 | Registered Table and Text items differ in value origin; numbered references and a review chapter need distinct citation roles. |

The individual `pipeline_files.csv` inventories give paths, creation mode,
producer, content role, record grain, and authority status for these cases.

The first checkpoint verifies every registered matrix against its live
registry row, R builder, analysis CSV, and public TSV. The next checkpoint
routes paper-local metadata from a registered matrix, an unregistered matrix,
or another form such as PDF prose and README notes, while retaining the source
locator and the scope of the claim. The three metadata carrier classes are
derived from file roles. Qualification then evaluates the specific value and
sends unresolved assertions to review. These registries cover all
39 registered matrices in the ten folders, including Buchsbaum Text and the
14 Kaufman tables outside the current 17-item measurement qualification scope.
The validator also checks that each item R script contains registry and
CSV/TSV writing operations. It does not rerun all 39 item builders; the
Kennedy Table/Text and Buchsbaum Table/Text builders were rerun for this
pilot, and their registered outputs were reproduced.

Run `Rscript __metadata/pilot/build_folder_metadata.R` after rebuilding the
catalog. It reads `pipeline_files.csv` directly and writes
`folder_metadata.sqlite` with `registered_item`,
`resource`, and `field_use` tables plus a `field_evidence` view. For example,
the view keeps Kennedy's registered Text row context separate from the
unregistered numbered-reference lookup:

```sql
SELECT metadata_field, source_class, evidence_path, locator
FROM field_evidence
WHERE item_id = 'Kennedy_etal_1978_Text'
  AND metadata_field IN ('reported_citation', 'upstream_reference');
```

`evidence_path` is the actual file named by the route; `resource_path` is
the manifest's representative path for that resource. For a registered
matrix, a route may point to its R builder or public TSV while the resource
record points to its local CSV. The validator checks those relationships
without treating the output's registration as proof of every field's origin.
`item_route_coverage.csv` distinguishes the 17 items with value-level
measurement-gate routes from 22 registered items currently inventoried at
the source/build/definition level. All 39 have definition routes; catalog
coverage alone is not measurement qualification.
