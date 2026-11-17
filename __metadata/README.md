# Metadata architecture and stopping points

This directory holds project-level metadata decisions that must be available
**before** a species merge. The working implementation is the
[ten-paper pilot catalog](pilot/README.md), with 39 public items and a
file-level registry for the paper and shared pipeline files. Its
[provenance map](../__measurements/pilot_metadata/PROVENANCE_MAP.md)
shows the paper/supplement, snapshot, item, inventory, qualification, and
source-choice paths.
The [single-pipeline pilot](../__measurements/pilot_single_pipeline/README.md)
generates species choices from
qualified reports without using merge outputs as inputs.

## Name the entity before choosing its folder

| Entity | Meaning | Where it lives in this repository |
| --- | --- | --- |
| Registered item | A public TSV with one `__ReadMe.xlsx` row. Its `item_kind` can be observation table **or reference list**. | Item builder and supporting files in the paper folder; public TSV in `__Public/comparative-data/`; row in the registry. |
| Pipeline file | A physical source, script, snapshot, definition, lookup, output, or note with its own file ID, creator/producer mode, stage, and authority status. Public-item registration is separate. | Paper-local `pipeline_files.csv` and `file_dependencies.csv`; shared file register in `pilot/`. `reference_tables/` is the conventional home for item definitions and citation lookups. |
| Project authority | A reviewed cross-item rule, source-row decision, or prepool veto. | `__metadata/curation/` for audited decisions and vetoes; active taxon crosswalks currently remain in `_keys/`; processing adapters remain in `__measurements/config/`. |
| Derived index | A reproducible view of other metadata. It helps find or classify fields but is not a new original source. | `_keys/variable_catalog.csv` and generated `_keys/brain_size_basis.csv`, each with a builder. |
| Downstream product | A merged or selected species value used to audit source choice. | `__merging_*`; it cannot certify its own premerge inputs. |
| Reference work | The cited paper/book/database named in a row. It may or may not have its own registered item. | A bibliography item or item-scoped lookup, and then a resolved reference relation for the point. |

Location, public-item registration, content type, granularity, creation mode,
and authority status remain separate in the
[file-level contract](pilot/PIPELINE_FILE_REGISTRY.md). `__ReadMe.xlsx` is an
**item catalog**, while the file register includes supporting metadata and
pipeline outputs.
"Key" names one lookup or crosswalk form; definitions, citations, methods,
row annotations, and reviewed decisions are metadata too, even when no
lookup key exists.
`reference_tables` is a storage convention, not a distinct authority level.
For example, Falcone definitions are currently at the paper-folder top
level, and the pilot routes to that actual path.

## File registration, routes, and point-level decisions

1. Each paper folder's `pipeline_files.csv` registers one physical file per
   row; `file_dependencies.csv` records confirmed build and source links.
   Shared scripts, keys, and outputs have the same contract in
   `pilot/shared_pipeline_files.csv`. `pilot/build_file_registry.R` combines
   these into a checked relational SQLite file.
2. `pilot/items.csv` retains the 39 public-item kinds. The older
   `pilot/artifacts.csv` supplies route annotations and is checked against
   the active file IDs; it is no longer the complete file register.
3. `pilot/field_routes.csv` says **which file and locator supplies a
   metadata field for an item at a named checkpoint**. One field can have
   several evidence routes, such as a row's numbered citation plus a lookup.
4. `pilot/assertion_audit.sqlite` records point-field assertions and evidence
   precision. `__measurements/pilot_single_pipeline/pilot_single_pipeline.sqlite`
   records qualified reports, references, blockers, lineage, and source
   choices. A route is a search instruction; an assertion still needs a
   specific source location and review decision.

The R builder validates all catalog paths, IDs, live registry links, public
TSV stems, and foreign keys. It also blocks routes from `__merging_*`
products into any checkpoint before source choice.

## Standard checkpoint contract

| Checkpoint | Required record for each candidate point | If unresolved |
| --- | --- | --- |
| Snapshot and item extraction | Item ID, source file/row/column, raw value, measure, unit, statistic, anatomy/behavior target, and trait definition. | Retain the row and hold the point for definition or unit review. |
| Source trace | Reporting work and its item ID; for a secondary or mixed value, the specific cited upstream work and row citation/lookup; a primary/secondary/mixed role. | Keep cited strings without upgrading them to original observations; hold missing lineage. |
| Method | Original acquisition/observation method, distinct from conversion, estimation, model prediction, or species-mean calculation. | Hold if the original method needed for comparability is unknown. |
| Taxon | Printed name, snapshot/TSV name, accepted name, and exact active crosswalk evidence. | Hold name conflicts and congeneric or group substitutions. |
| Qualification | All required fields above, valid lineage for mixed inputs, and basis/pool eligibility. | Store blocker codes and evidence routes in the review queue. |
| Source choice | Compare qualified reports of the same measure and basis; trace shared animals/studies; usually prefer the original primary report over its relay. | Retain the secondary report as corroboration or fallback and leave selection pending. |

`primary`, `secondary`, and `mixed` describe **where a reported value came
from**. `review` describes an unresolved decision or a missing required
field; it is not a synonym for secondary. A primary observation may need
review, and a well-documented secondary report may qualify. Qualification
is separate from final source choice.

## Onboarding another paper or table

1. Preserve the paper/supplement and a frozen extraction in its paper
   folder. Build the item CSV and public TSV reproducibly; register the
   public TSV in `__ReadMe.xlsx`. Register a bibliography as its own item
   only when it has its own public TSV, as Mink REFERENCES does.
2. Place item definitions and numbered-reference lookups in the paper's
   `reference_tables/` when making new files. Keep source citations,
   comments, and printed names beside the values when supplied per row.
3. Add the item and every active file to the paper's file register, including
   definitions, lookups, scripts, generated checks, and outputs. State whether
   each was supplied, transcribed, curated, copied, or generated; link a known
   producer and confirmed source inputs. Add field routes to the catalog. Record exact
   source columns or printed locations; mark unparsed supporting notes as
   such. Add audited decisions that apply across items to
   `__metadata/curation/` and active taxon names to the project taxon keys.
4. Run the catalog validation, regenerate any affected derived indexes,
   rebuild the measurement inventory, and run the point-level metadata
   gate. Only qualified candidates proceed to source choice.

Run the current ten-paper pilot from the repository root after the
measurement inventory exists:

```sh
Rscript __measurements/pilot_single_pipeline/run_pilot.R
```

The file registry covers the ten pilot folders and their shared pilot inputs
and outputs. The full measurement inventory still has legacy direct readers
for definitions and keys; the pilot gate uses the catalog for its routed
sources. Wider adoption would extend this same file contract to other papers.
R plus DBI/RSQLite is sufficient; writing SQL by hand is optional for
queries and schema changes.

## Other merge-folder metadata found in the audit

The brain-mass row-basis and value-veto decisions have been moved into
`__metadata/curation/`, and both brain-mass builders now read them there.
The wider repository still has premerge inputs under merge folders. Their
current location should be recorded as a legacy exception rather than
mistaken for a generated merge output:

| Current location | Content role | Conventional destination when that stream is migrated |
| --- | --- | --- |
| `__merging_volumes/volumes_select_value_flags.csv`, `__merging_body_ecology/body_ecology_value_flags.csv`, `__merging_cell_counts_histology/value_flags.csv` | Hand-reviewed value flags used by merge code. | `__metadata/curation/`, with readers updated and exact-match checks retained. |
| `__merging_volumes/laterality_known.csv`, `volumes_primary_DeCasien_curation.csv`, `volumes_primary_DeCasien_sources.csv` | Laterality and primary-source curation inputs. | Curated project authority, with source evidence and producer recorded. |
| `__merging_cell_counts_histology/` and `__merging_cell_morphology/` vocabulary and crosswalk CSVs; `__merging_trees/tree_tip_crosswalk.csv` | Shared definitions, name mappings, and reviewed tree-tip matches. | A typed crosswalk/vocabulary area under `__metadata/`, with owner, scope, and checkpoint recorded. |
| `__merging_volumes/volumes_flags.csv`, `__merging_brain_mass/brain_mass_vetoed_rows.csv`, cell-count `qa_*.csv` | Generated audit outputs. | Remain downstream products; do not edit as upstream authority. |

The cerebral-metabolic-rate `primary_item_ingestion_manifest.csv` is a
generated file that a merge consumes. Its producer and version should be
declared when that stream joins the catalog. The cortical-area source-quality
flags are hand maintained, but no active merge reader was found in this
audit. These distinctions show why a folder name alone cannot tell us
whether a CSV is evidence, an active decision, an index, or a product.

This model follows the distinction between source entities and derived
entities in [W3C PROV-O](https://www.w3.org/TR/prov-o/), uses measurement
field concepts from [Darwin Core MeasurementOrFact](https://dwc.tdwg.org/terms/),
and uses explicit resource keys and links like
[Frictionless Table Schema](https://specs.frictionlessdata.io/table-schema/).
It is a local relational implementation, not a claim of full compliance
with those standards.
