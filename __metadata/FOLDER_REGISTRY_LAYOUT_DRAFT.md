# Paper-folder registry and layout: working draft

This draft brings the folder-owned item-index experiment together with Option A
in `repo-restructure-plan.md`. It is a proposal for small tests, not an adopted
schema, a migration instruction, or a replacement for `__ReadMe.xlsx`.

## The idea

Keep each paper's evidence and its item descriptions together. A local item
record identifies what was extracted and points to the files needed to understand
it. Generate a searchable project-wide index from those local records. A
publication, a logical item, a physical file, a cited work, and an individual
measurement are distinct: one paper can contain several items; one item can use
several files; a shared file can support several items.

The existing public item IDs and encoded TSV names must remain stable through a
transition. A folder name or DOI alone need not be a permanent identity: a
folder may contain several related works, supplements, or item-specific DOIs.
Shared project taxon keys, scripts, curation, and merges continue to have a
project-wide home.

## A trial layout

The following is **one proposed arrangement**, not a requirement to create all
directories for every paper. Source and snapshot filenames, physical layout,
and metadata schema remain open to the test.

```text
Paper_folder/
  item_registry...       local item declarations (one logical item per row)
  sources/               publisher files and other supplied material
  snapshots/             source-table transcriptions, when needed
  scripts/               snapshot-makers and item-processing code
  reference_tables/      definitions, reference lists, and related metadata
  Item.csv               prepared data; possible location, still to decide
  Item.README.md         explanation and provenance
```

- **Sources** are retained as supplied and not silently edited.
- **Snapshots** capture the source before data cleaning. Scripts do not silently
  overwrite them. A transcription error can be corrected explicitly against the
  source, with the earlier capture or change evidence and its locator retained.
- **Curated metadata** can include definitions, citation resolutions, evidence
  notes and errata. It must not be called disposable or automatically regenerable
  merely because it is stored near outputs.
- **Generated files** include prepared data and reproducible indexes or reports;
  record their inputs and producer. Not every paper needs every file type.

The existing pilot manifests `pipeline_files.csv`, `file_dependencies.csv`, and
older `metadata_sources.csv` have different current consumers. The trial should
identify what information is needed and where it belongs before choosing a
single durable representation; it must not create a parallel set of per-item
metadata files simply to conform to a diagram.

## Links and definitions

For each item, declare its stable ID, kind and review/public status; identify
its source and a precise locator; and link the snapshot, builder, prepared
data, public output and supporting metadata where they exist. Absence, unknown
provenance and not-yet-checked are different states. A path is a pointer, not
proof that a value or scientific claim is correct.

Store each definitions file once. It may describe one item, a declared group of
items, or paper-wide context. A link means *consult this file*, not that every
row applies to every linked item. If rows differ in applicability, record the
item or item group at the definition level; do not infer the scope solely from a
filename or common column name. A conflicting item-specific and shared meaning
needs a documented exception or review. Retain the distinction between wording
from the publication and project-created fields, labels, or interpretations.

Examples already in the provisional item-index pilot:

- **Catania Table 1:** one item points to the PDF table, its prepared CSV and
  its existing Table 1 definitions file.
- **Falcone Tables 1 and 2:** two items point to the same PDF, each to its own
  table, data file and currently separate definitions file.
- **Shared definitions:** a single file may be linked to several items without
  copying its contents. Kaufman's file is a harder example: its A1–A14 rows
  and A15 rows have different scopes. The pilot links the same file to the 15
  tables and records the existing exact `Reference` value for each group in
  `definitions_scope`. It checks that the declared group exists, not that the
  declaration or the definition text is scientifically correct. This is a narrow
  experiment, not yet a general model for arbitrary mixed or conflicting scopes.

## Authority and transition

During this trial, existing tools still use `__ReadMe.xlsx`; local pilot records
are provisional. Imported workbook fields are legacy information to compare,
not independently verified facts. For each item in any future transition, name
which record is authoritative; do not maintain the same field independently in
two places. A generated index can be rebuilt for search and compatibility. It
must report its coverage and distinguish missing items from unconverted ones.

Replacing the workbook requires preserving its item-level fields and handling
its other sheets, formula results, source dispositions and public-file list.
File existence, public release, review status and primary/secondary provenance
are separate facts. Identifying a cited work does not establish that a copied
measurement, unit or experimental condition has been verified in that work.

## Next tests

1. Review the Catania and Falcone records for clarity and the right level of
   detail, including source, item, definitions and generated-index links. Then
   test an explicitly shared-definitions case.
2. Capture current item IDs, source paths, public filenames and outputs. Reconcile
   stale/generated workbook status separately from maintained item facts.
3. In a scratch copy, trial the proposed layout on Beatty, including its PDF,
   XML, supplements, snapshot-maker and item builder. Adapt path handling for
   both layouts; do not overwrite the original source or snapshot.
4. Check source/snapshot bytes and stable identifiers, compare prepared and
   public data, and inspect relevant consumers and provenance links. Generated
   output should be byte-identical when deterministic, otherwise compared by
   documented content and semantics.
5. Only after these examples are satisfactory, expand a folder at a time and
   compare the global index with existing workbook records and consumers. Keep
   workbook compatibility until coverage and parity are established.

Still to decide: directory names; the prepared CSV and documentation locations;
how best to express multiple-file and shared-definition links without excessive
files; how a local record is reviewed; and the durable location/versioning of
original OCR evidence where snapshot corrections have been made.

## Initial baseline (2026-11-18)

- The declared Catania and Falcone PDF pages, item CSVs, definitions files and
  public TSVs exist. Each item CSV and TSV has the same parsed rows and columns;
  this is not a scientific validation of the transcriptions. Falcone's existing
  inventory flags a Table 2 snapshot genus discrepancy for separate review.
- The workbook's generated public-file status says `notfound` for Kaufman A1
  and A10 even though their declared TSVs exist. The pilot now reports that
  cached-status difference separately while still checking item IDs, encoded
  filenames and imported maintained fields.
- Kaufman's 15 item records now point to its one shared definitions file with
  separate explicit A1–A14 and A15 groups. Automated checks confirm that both
  groups exist and remain separate. The pilot does not yet adjudicate whether
  any particular item-to-group declaration is scientifically correct.
- A normal cerebral metabolic-rate rebuild currently expects original OCR
  captures in `Kaufman__2004/old/`, which is absent. How to preserve or recover
  that extraction evidence remains a separate decision; the layout trial does
  not recreate or remove it.

## Beatty layout trial (2026-11-18)

An isolated copy of Beatty placed its PDF, XML and supplements in `sources/`,
its existing snapshot in `snapshots/`, and its two scripts in `scripts/`. The
original repository files were not moved. The unmodified scripts failed because
they expected their inputs beside the scripts. Three path adjustments were made
in the copy only. The PDF, XML, supplements and snapshot remained byte-identical;
the adapted item builder reproduced both the 36-row CSV and public TSV byte for
byte. The snapshot-maker accepted an identical copy and refused a deliberately
changed copy without overwriting it.

A scratch-local item declaration and partial index pointed to the moved files and
retained the workbook's item ID and encoded public filename. This checks paths,
not all dependencies or scientific assertions. The item builder still used a copy
of `__ReadMe.xlsx`. This experiment is not a repo-wide path migration.

The trial exposed an existing generic-checker defect: it could run a snapshot
maker or another item's script and then pass based on already-existing outputs.
The helper now selects the requested item's exact builder and files and stops on
ambiguous inputs; its focused scratch-only regression test is
`_tools/dataset_builder/test_build_dataset_item.R`. Multiple declared snapshot
sources remain an explicit review case, not an automatically resolved pattern.
Independent end-to-end tests of the real Catania and Falcone items still failed
inside the generic wrapper: its isolated evaluation environment does not expose
the unqualified `read.csv` and `read_csv` used by those builders. In scratch-only
experiments, merely changing the evaluation environment then made both builders
resolve the outer wrapper's script path rather than their own. These pre-existing execution issues
need a separate design and real-item regression before the helper can serve as a
general migration gate. The successful Beatty result does not establish that
other item builders can be run through it.
The exact-name check is deliberately fail-closed: a preliminary read-only scan
found 97 workbook rows without an exact-named item script, including legitimate
shared or legacy builders. Those cases need explicit reviewed mappings; the
checker must not guess that the first nearby script is correct.
