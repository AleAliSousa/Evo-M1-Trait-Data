# Preuss, Qi & Kaas 1999: Fig 2 -- cytochrome oxidase staining of area V1 in Saimiri, Ateles, Macaca, Pongo, Pan and Homo (panels A-F)

Source: Preuss, T. M., Qi, H., & Kaas, J. H. (1999). Distinctive compartmental organization of human primary visual cortex. Proceedings of the National Academy of Sciences of the United States of America, 96(20), 11601-11606. https://doi.org/10.1073/pnas.96.20.11601

Item: Fig. 2 legend (p. 11603): cytochrome oxidase staining of area V1 in Saimiri, Ateles, Macaca, Pongo, Pan and Homo (panels A-F).
Registry: Item number `Fig 2`; Item name `Preuss_etal_1999_Fig2`; Item encoded `10.1073%2Fpnas.96.20.11601_Fig2` (public TSV `10.1073%2Fpnas.96.20.11601_Fig2.tsv`).

## Frozen source (constructed snapshot)

`Preuss_etal_1999_Fig2_snapshot.csv` (6 rows, UTF-8 with BOM; sha256 `e83a6ab5bbdb613a...`). There is no printed table: the values live in figure legends, diagrams and running text, so the snapshot is a table we constructed (snapshot HOWTO, 'When there is no table').

- **Who and how:** transcribed on 5 Nov 2026 by the AI assistant (Copilot) from the PDF (`preuss_etal_1999.pdf`, in this folder): text rows from the PDF text layer (poppler `pdftotext`); diagram labels, arrows and letter codes from page images rendered at 200-220 dpi.
- **What is verbatim:** `printed_wording` is a short phrase (13 words or fewer) copied from the locus; `locus`, `page` (journal page) and `panel` say where. Everything else in a row (`taxon_*`, `feature`, `state_as_read`, `applies_to`, `note`) is our reading, and that reading is what the human check confirms.
- **Group statements** ('apes and humans', 'monkeys', 'none of the other species') are expanded to one row per taxon the Methods list for that stain; the printed group phrase stays in `taxon_as_printed` and the Methods name in `taxon_in_methods`.
- **Human check:** pending (registry column AJ). Check each row against the PDF page named in `page`.

Snapshot columns: row, row_type (statement, terminal_label, clade_label, annotation, letter_key, photo_mark), locus, page, panel, taxon_as_printed, taxon_in_methods, marker, layer, feature, state_as_read, value_low, value_high, unit, n_as_printed, applies_to (tree annotations: the genera under the arrow, or `root`), printed_wording, evidence (legend, Results, Discussion, figure image), note.

## What the data are

`Preuss_etal_1999_Fig2.csv`: 6 rows x 24 columns (6 statement). One row = one taxon (or group, or tree node) x one trait at one locus. States are qualitative except the size rows (`value_low`-`value_high`, µm as printed).

- Accepted taxa: Ateles geoffroyi; Homo sapiens; Macaca sp.; Pan troglodytes; Pongo pygmaeus; Saimiri sciureus.
- Traits: `L4A_CO_dense_band` (definitions in `reference_tables/Preuss_etal_1999_Fig2_definitions.csv`).
- Data role: **primary**.
- Area: V1 (striate cortex); layers in the Brodmann-Lund scheme the authors use (4A, 4B, 4Cα, 4Cβ).

## Species

Printed names are kept (`taxon_as_printed`, `taxon_in_methods`); accepted names come from `_keys/General/species_key.csv` rows with source_publication `Preuss_etal_1999` (added 5 Nov 2026). Methods binomials map verbatim; `Macaca` (several species pooled in Methods) -> Macaca sp. (basis lump); `Cercopithecus aethiops` -> Chlorocebus aethiops (synonym); genus labels on trees -> `<Genus> sp.` anchors (Homo -> Homo sapiens).

## Build

`Preuss_etal_1999_Fig2.R` reads the snapshot, checks its columns, row count (6) and coding vocabulary, resolves names through the species key, codes each feature to a trait, and writes the analysis CSV and the public TSV `__Public/comparative-data/10.1073%2Fpnas.96.20.11601_Fig2.tsv` (Item encoded looked up from `__ReadMe.xlsx` by Item name), then runs `validate_dataset_item()`.

**R NOT RUN.** There is no R in this workspace: the CSV and TSV were written by a Python mirror of the R logic (same rows, columns, quoting and blanks as `write.csv` / `write.table`). Rerun the R script to confirm; it stops if the analysis row count is not 6.

## Checks

Python mirror, 5 Nov 2026 -- pass: 6.

- Every text-layer quote (`printed_wording` on legend / Results / Discussion rows) was found on the page given in `page` (letters and digits compared, so line breaks, hyphenation and dashes do not matter). The R script repeats this check with `pdftools` when the PDF is in the folder.

## Differences from the earlier export workbook (`Evo_M1_Trait_Data_Preuss_etal_1999.xlsx`)

- Same six taxa and states as the export. Added sample sizes (Methods) and the fixation notes the legend prints (panel C immersion-fixed macaque; panel E perfusion-fixed chimpanzee).

The export workbook is left untouched in this folder.

## In the app (5 Nov 2026)

Mapped in `__merging_supplementary/supplementary_sources.csv` (dataset **Supplementary sources**, domain cellular composition, class `v1_layer4_architecture`, text states with Units `category`):
- `V1_L4A_CO_dense_band_Preuss1999 (category)`

Rows were written by a Python mirror of `supplementary_compiled.R` (R NOT RUN); definitions are in `__merging_supplementary/supplementary_label_definitions.csv`. The deployed app reads GitHub, so the change shows after the R steps and a push.
