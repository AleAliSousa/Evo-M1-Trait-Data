# Pilot supporting-metadata table convention

This convention applies to supporting metadata CSVs in the ten-paper pilot.
They are registered as **files** in each paper's `pipeline_files.csv`; that
registration does not make them public measurement items in `__ReadMe.xlsx`.
The convention covers the 44 files formerly under `reference_tables/` plus
the Falcone (two) and Kaufman (one) definitions formerly at paper-folder
top level.

## Location and name

```text
<Paper>/reference_tables/<scope_token>_<type_suffix>.csv
```

`scope_token` is the exact registered item ID for item-scoped metadata, the
exact paper-folder ID for paper-wide metadata, or an explicit item-set label
for shared metadata (for example, `Kaufman__2004_TablesA1-A14`). A file
covering several items must not be made to look item-specific merely to fit
the pattern. Keep the stable `file_id` when a path changes; update its
`pipeline_files.csv` path and all uses of that path.

The suffix vocabulary preserves the existing R tool contracts:

| Suffix | Registered `content_role` | One row represents |
| --- | --- | --- |
| `bibliography` | `bibliography` | One source bibliography entry; extraction and review status are recorded separately. |
| `definitions` | `field_definitions` | A legacy definition record; see row-type note below. |
| `references` | `citation_lookup` | A printed citation key or cited-work resolution. |
| `footnotes` | `citation_lookup` | A printed footnote letter and its meaning. |
| `reference_columns` | `citation_scope` | A rule connecting a citation column to values. |
| `errata` | `errata_ledger` | A proposed or reviewed discrepancy. |
| `ocr_audit` | `errata_ledger` | A source-text OCR correction with its original and checked transcription and PDF locator. |
| `species_key_proposed` | `proposed_taxon_mapping` | A proposed printed-name mapping, not an adopted `_keys` decision. |
| `taxa` | `taxon_annotation_lookup` | A printed taxon annotation in an item. |
| `source_match` | `generated_source_match` | A generated source-cell match. |
| `source_match_issues` | `generated_source_match_issues` | A generated unresolved match issue. |
| `source_match_summary` | `generated_source_match_summary` | A generated cited-key/variable summary. |

Keep `*_definitions.csv`, `<Item>_references.csv`,
`<Item>_reference_columns.csv`, and `<Item>_source_match*.csv`: the variable
catalog and source-match builder discover or write those names. `footnotes`
is a separate suffix because a letter legend is not a bibliography. A
shared paper or item-set reference lookup must be identified as shared in
the file registry; a filename alone does not prove that it belongs to one
item.

## Typed tables and review

The suffix identifies the **table type**, not a universal CSV schema. The
legacy definition tables share ten columns, but their records include actual
item-column definitions, method statements, and printed-region annotations.
The citation lookups also have several schemas. Do not concatenate all
`reference_tables` files as if they were one relational table. Use the file
registry's `content_role`, `record_grain`, `creation_mode`, and
`authority_status`, then join assertions at their declared item, row, column,
or cell scope.

The file registry is the first checkpoint: it confirms a file's identity,
type, scope, path, and producer. A separate evidence/review checkpoint must
record the publication or supplement file and exact locator for manually
curated claims. An active file is not proof that each row is correct. A
`project_lookup` is not necessarily a primary measurement; a proposed
species key is not an accepted taxon key; generated source matches are audit
outputs, not source evidence. Primary/secondary origin and method may vary
within an item and require point-level decisions.

Run the read-only validator after renaming or adding pilot metadata:

```sh
python3 __metadata/pilot/validate_metadata_tables.py
```

It checks placement, naming, registered type, scope, existence, registration
coverage, and stable headers. It reports outstanding source-locator issues
from `file_registration_issues.csv` by stable `file_id`, without filling them
by inference. Then rebuild and validate the combined file registry and run
the pilot gate to verify that path changes have not broken consumers.
