# Preuss, Qi & Kaas 1999: Fig 6 -- interpretation of V1 changes during hominoid evolution, mapped on a primate tree; plus the Discussion statements it summarises

Source: Preuss, T. M., Qi, H., & Kaas, J. H. (1999). Distinctive compartmental organization of human primary visual cortex. Proceedings of the National Academy of Sciences of the United States of America, 96(20), 11601-11606. https://doi.org/10.1073/pnas.96.20.11601

Item: Fig. 6 (p. 11605): interpretation of V1 changes during hominoid evolution, mapped on a primate tree; plus the Discussion statements it summarises.
Registry: Item number `Fig 6`; Item name `Preuss_etal_1999_Fig6`; Item encoded `10.1073%2Fpnas.96.20.11601_Fig6` (public TSV `10.1073%2Fpnas.96.20.11601_Fig6.tsv`).

## Frozen source (constructed snapshot)

`Preuss_etal_1999_Fig6_snapshot.csv` (16 rows, UTF-8 with BOM; sha256 `387b7a98bc366f2a...`). There is no printed table: the values live in figure legends, diagrams and running text, so the snapshot is a table we constructed (snapshot HOWTO, 'When there is no table').

- **Who and how:** transcribed on 5 Nov 2026 by the AI assistant (Copilot) from the PDF (`preuss_etal_1999.pdf`, in this folder): text rows from the PDF text layer (poppler `pdftotext`); diagram labels, arrows and letter codes from page images rendered at 200-220 dpi.
- **What is verbatim:** `printed_wording` is a short phrase (13 words or fewer) copied from the locus; `locus`, `page` (journal page) and `panel` say where. Everything else in a row (`taxon_*`, `feature`, `state_as_read`, `applies_to`, `note`) is our reading, and that reading is what the human check confirms.
- **Group statements** ('apes and humans', 'monkeys', 'none of the other species') are expanded to one row per taxon the Methods list for that stain; the printed group phrase stays in `taxon_as_printed` and the Methods name in `taxon_in_methods`.
- **Human check:** pending (registry column AJ). Check each row against the PDF page named in `page`.

Snapshot columns: row, row_type (statement, terminal_label, clade_label, annotation, letter_key, photo_mark), locus, page, panel, taxon_as_printed, taxon_in_methods, marker, layer, feature, state_as_read, value_low, value_high, unit, n_as_printed, applies_to (tree annotations: the genera under the arrow, or `root`), printed_wording, evidence (legend, Results, Discussion, figure image), note.

## What the data are

`Preuss_etal_1999_Fig6.csv`: 16 rows x 24 columns (1 annotation, 11 derived, 4 statement). One row = one taxon (or group, or tree node) x one trait at one locus. States are qualitative except the size rows (`value_low`-`value_high`, µm as printed).

- Accepted taxa: Gorilla sp.; Homo sapiens; Hylobates sp.; Pan sp.; Pongo sp.
- Traits: `L4A_CO_dense_band`, `L4A_honeycomb`, `L4A_mesh`, `L4B_CO_band` (definitions in `reference_tables/Preuss_etal_1999_Fig6_definitions.csv`).
- Data role: **both**. Diagram rows give terminal states inferred from the branch annotations (state_basis says so).
- Area: V1 (striate cortex); layers in the Brodmann-Lund scheme the authors use (4A, 4B, 4Cα, 4Cβ).
- Caveat: Derived rows are the authors' interpretation drawn on a tree, not observations of those genera; Pongo and Pan are keyed to genus anchors because the tree prints genera.

## Species

Printed names are kept (`taxon_as_printed`, `taxon_in_methods`); accepted names come from `_keys/General/species_key.csv` rows with source_publication `Preuss_etal_1999` (added 5 Nov 2026). Methods binomials map verbatim; `Macaca` (several species pooled in Methods) -> Macaca sp. (basis lump); `Cercopithecus aethiops` -> Chlorocebus aethiops (synonym); genus labels on trees -> `<Genus> sp.` anchors (Homo -> Homo sapiens).

## Build

`Preuss_etal_1999_Fig6.R` reads the snapshot, checks its columns, row count (16) and coding vocabulary, resolves names through the species key, codes each feature to a trait, and writes the analysis CSV and the public TSV `__Public/comparative-data/10.1073%2Fpnas.96.20.11601_Fig6.tsv` (Item encoded looked up from `__ReadMe.xlsx` by Item name), then runs `validate_dataset_item()`.
For tree annotations it derives terminal states: a change annotation applies to the genera listed in `applies_to` (`?` under a label gives `uncertain`); a `root` annotation becomes an ancestral-node row.

**R NOT RUN.** There is no R in this workspace: the CSV and TSV were written by a Python mirror of the R logic (same rows, columns, quoting and blanks as `write.csv` / `write.table`). Rerun the R script to confirm; it stops if the analysis row count is not 16.

## Checks

Python mirror, 5 Nov 2026 -- not evaluable (diagram text is not in the PDF text layer): 12, pass: 4.

- Every text-layer quote (`printed_wording` on legend / Results / Discussion rows) was found on the page given in `page` (letters and digits compared, so line breaks, hyphenation and dashes do not matter). The R script repeats this check with `pdftools` when the PDF is in the folder.
- Diagram labels, arrows and letter codes are drawn as graphics (not in the text layer): checked by eye only.

## Differences from the earlier export workbook (`Evo_M1_Trait_Data_Preuss_etal_1999.xlsx`)

- Export row 'Hominoids: CO-dense 4A band: Loss' is refined: the loss is drawn on the great-ape + human stem, with a second arrow to the stem below Hylobates, and both Hylobates and Gorilla carry '?' (no data). Derived rows: Pongo, Pan, Homo absent; Hylobates and Gorilla uncertain.
- The same annotation also says 'increased CO activity in 4B', which the export left out (added as L4B_CO_band present).
- 'Ancestral Anthropoid: Honeycomb: Present' kept as the ancestral-node row; 'Homo: mesh-like architecture: Derived presence' coded as present (row_type derived).
- Added the Discussion statement the tree summarises: dense CO in 4A and light 4B in most New World and Old World monkeys.

The export workbook is left untouched in this folder.

## In the app (5 Nov 2026)

Listed in the app's source-table browser (`__ShinyApp/data/source_manifest.csv`). Its states are not separate app labels: the Preuss 1999 labels come from the Main Text and Fig. 2 items, which carry the same observations; Fig. 1 is a literature model and Fig. 6 a tree interpretation.
