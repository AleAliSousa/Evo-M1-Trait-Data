# Folder-owned item registry: provisional pilot

This is a small, reversible test of declaring logical items within their source
folder and generating a project-wide index from those declarations. It is not a
replacement for `__ReadMe.xlsx`, the public-item registry, or the ten-paper file
registry. Current scripts, workbook sheets, public TSV names, and release rules
are unchanged.

## Pilot files

- `Kaufman__2004/item_registry.pilot.csv` is an editable **provisional, unreviewed**
  candidate for one folder. It declares the 15 existing public appendix items and
  proposes one supporting, non-public `reference_list` item for Literature Cited.
  The proposed bibliography ID is local to this pilot; it is not a public registry
  ID. The source locators identify the appendix table or Literature Cited section.
- `Catania_etal_1999/item_registry.pilot.csv` demonstrates the same idea with a
  single item. It identifies Table 1, its PDF page, prepared data file, public
  TSV, and the existing `definitions_file`; it does not repeat the workbook's
  41 legacy fields. The optional definitions link is validated when supplied,
  then carried into the generated index. It registers the supporting file in
  this pilot without presenting it as a separate public measurement item or
  claiming every definition is quoted from the paper.
- `build_item_index_pilot.py` combines `*/item_registry.pilot.csv` files into
  `__metadata/item_registry_index.pilot.csv`. Its `index_scope` explicitly says
  `partial_pilot`: a missing item is not evidence that the item does not exist.
  Generated output is a view; edit the folder declaration, not the index. The
  index has the union of declared columns; fields not declared for an item are
  blank and do not assert that the corresponding information is absent.
- The folder's `pipeline_files.csv` and `file_dependencies.csv` describe physical
  files and their links. This item pilot does not replace or automatically modify
  those registries; the two models need a reviewed integration before adoption.

## What needs a human decision

An item record explicitly states what it represents, where the source can be
found (`source_file` and `source_locator`), the associated data file, its kind,
and whether it is public. File existence and machine-generated indexes cannot
establish whether the source is the right table, its values are correct, or its
references and methods apply to a given measurement. Those remain review and
curation decisions. The pilot locators and item kinds are proposals, not review
decisions or permission to publish. The distinction between an item, a physical
file, a cited work, and a data point must be preserved.

## Legacy import and comparison

The 15 public records were seeded from the workbook's evaluated `Sheet1` cells,
including all 41 named fields. The `legacy:` prefix marks them as imported
values, not independently checked source facts. In particular, the workbook's
cached public-file match field says `notfound` for some TSVs that do exist; the
pilot preserves that cached value for comparison and separately declares and
checks the physical `public_tsv_path`. An empty value may mean a blank workbook
cell; it is not a claim that the corresponding fact is absent. The local
bibliography record has no invented workbook values.

Rebuild and validate the partial index from the repository root:

```sh
python3 __metadata/build_item_index_pilot.py
```

For a read-only comparison of the 15 seeded records with the current
**cached evaluated values** in `__ReadMe.xlsx` (requires `openpyxl`):

```sh
python3 __metadata/build_item_index_pilot.py --check-workbook
```

The latter compares every imported field for Kaufman, and checks Catania's item
identity and public filename against the workbook; Catania has no imported fields
to compare. It does not evaluate Excel formulas or prove that their caches, titles,
references or locations are correct. It
reports an error if the workbook or local fields diverge; that is a review
signal, not an instruction to overwrite either side. The builder validates
unique item IDs and public filenames, declared source/item files, and folder
ownership before writing the partial index. It does not discover or validate
all project items, cross-paper resources, hidden/retired work, or workbook
`SOURCE_DISPOSITION` and public-file inventory sheets. Those, the schema and
the transition plan need explicit decisions before any central replacement.
