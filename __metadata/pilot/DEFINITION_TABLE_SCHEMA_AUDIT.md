# Definition-table schema audit and migration proposal

The ten pilot folders contain **25** files classified as `field_definitions`:
all 25 under their paper folders' `reference_tables/` directories. All 25 have the same ten
columns (`Code`, `Definition`, `Structure`, `Measure`, `Stat`, `role`,
`taxon`, `Reference`, `Note`, `Source Note`) and together contain **501**
rows. Thus their headers already conform; the difficulty is that their rows
represent several kinds of metadata at different scopes.

| Existing pattern | Count or example | Why it needs a separate type or scope |
| --- | --- | --- |
| `Code` matching an item column | Ordinary field dictionary row | Can be keyed by `(item_id, column_code)` and reviewed once for that field. |
| `Method:*` pseudo-code | 49 rows; four more rows have `Code=Method` or `method` | Describes an acquisition, transformation, or extraction procedure, sometimes for several columns. It is not an item column. |
| Printed regional substructure in `Code` | Seven Kennedy Table rows such as `Thalamus: dorsomedial nucleus` | Applies to a row/region and needs a printed-region key, not a column key. |
| `Code=note`, `references`, or similar | Several files | May be a field definition, a free-text processing note, or a citation instruction; the current code does not say which. |
| `role` used for value origin and metadata type | After CSV repairs: 260 `info`, 114 `primary`, 63 `secondary`, 53 `method`; also six blanks, two `both`, two `taxonomy`, one `note` | `primary`/`secondary` applies to a value's origin; `method`, `taxonomy`, and `info` are content types. A mixed item can vary by row or cell. |

Strict CSV parsing exposed seven malformed definition records: four
ManyPrimates STM rows had a missing empty column, Boddy Table S1's `EQ` and
`Reference` definitions contained unquoted commas, and Boddy raw database's
`Sex` definition contained unquoted commas. These source CSV rows have been
repaired without changing their intended text. All 25 files now parse as
exactly ten columns and 501 records with zero `readr` parse problems.

## Machine-proposed row-type inventory

Run `Rscript __metadata/pilot/build_definition_row_types.R` to regenerate
`definition_row_types.csv`. It records each source file ID and path, the
logical CSV record number (header is row 1), original `Code` and `role`,
linked item IDs, proposed record type and scope, and the rule behind the
proposal. The script never edits the 25 definition files or the metadata
gate. Its `classification_status=machine_proposed` is deliberately separate
from a human review decision.

The current 501 rows classify as **395** exact item-column definitions,
**51** explicit method rows, **52** exact printed-region annotations, and
**3** unresolved rows. The unresolved entries are Buchsbaum Table I's
`Lateral cortex Mean`, `Subcortical gray Mean`, and `Medial cortex Mean`;
none matches an item column or exact printed-region value. No row is
classified as a citation or note record because every such label in these
files matches an actual item column first. Method scope remains unresolved
until the applicable item, columns, or values are reviewed.

The errors are not merely cosmetic. Kennedy Text has original, cited, and
repeated values in one registered item; a generic definition role cannot
classify every row. Mink's registered REFERENCES item is bibliography
metadata, so its registry or definition source role cannot make each entry
a secondary measurement. Fobbs S1a body lengths need a measure review even
though its catalog definitions use the shared header.

## Proposed typed tables

Keep a single file registry for **every** definition, lookup, and method
resource. Registration of a support file means that its path, creator or
producer, inputs, and current review status are known; it does not turn the
file into a registered public measurement matrix.

| Table | Key and essential fields | Grain |
| --- | --- | --- |
| `field_definition` | `(item_id, column_code)`; definition text, value type, measure, unit, statistic, anatomy/behavior target, evidence file ID and locator, review status | One actual matrix column. |
| `method_assertion` | `method_id`; item ID, method kind (`acquisition`, `transformation`, `extraction`), applicable columns or row key, method text, evidence file ID and locator, review status | Item, column, row, or cell, explicitly declared. |
| `citation_scope` | `(item_id, value_column, citation_column, scope)` plus printed-key mapping and evidence | A cell or row-to-citation rule. Existing Heffner/Bahney declarations are prototypes. |
| `anatomy_annotation` | `(item_id, printed_region)` or stable source-row key; accepted target, evidence, review status | Printed region or source row. |
| `value_source_role` | `(item_id, row_key, value_column)` when needed; primary/secondary/mixed/unresolved, reporting work, cited work, evidence, review status | Value, row, or an explicitly uniform column. |

Shared paper-level descriptions can have an item-set relation rather than
fifteen copies. For example, Kaufman's one definitions file can serve all
fifteen registered appendix items while each row states its applicable
column or item set. A cited-work key and its resolved bibliographic work
remain distinct from proof that two papers report the same observation.

## Safe migration order

1. Register the current 25 files as active supporting metadata resources,
   including their publication/supplement evidence and manual-curation or R
   producer. Keep them unchanged while the current gate uses them.
2. Generate a typed conversion inventory from each file: classify each row
   as a real column definition, method, regional annotation, citation
   instruction, or note. Mark ambiguous rows for review rather than
   inferring a type from `role` alone.
3. Create the five typed tables above for one difficult mixed item first
   (Kennedy Text or Bahney Table 3), and retain an adapter that reproduces
   the legacy ten-column view. Then convert Fobbs and the other pilot items.
4. Change item builders and the metadata gate to read typed records. Check
   that the same 5,285 pilot points, 699 qualification decisions, and known
   source-choice links are reproduced; inspect any changed classification.
5. Retire the legacy definition files only after the typed tables carry
   source locators and review decisions for all used rows. Keep their
   identities and versions in the file registry for provenance.

The current [folder manifests](FOLDER_METADATA_CONTRACT.md) and
[assertion audit](README.md#point-assertion-audit) provide the file and
point IDs needed to do this without changing the live `__ReadMe.xlsx`
registry first.
