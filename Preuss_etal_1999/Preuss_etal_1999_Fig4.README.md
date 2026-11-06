# Preuss, Qi & Kaas 1999: Fig 4 -- NPNF immunostaining in layer 4A with differential-interference contrast optics in Macaca, Pongo and Homo

Source: Preuss, T. M., Qi, H., & Kaas, J. H. (1999). Distinctive compartmental organization of human primary visual cortex. Proceedings of the National Academy of Sciences of the United States of America, 96(20), 11601-11606. https://doi.org/10.1073/pnas.96.20.11601

Item: Fig. 4 legend (p. 11604): NPNF immunostaining in layer 4A with differential-interference contrast optics in Macaca, Pongo and Homo.
Registry: Item number `Fig 4`; Item name `Preuss_etal_1999_Fig4`; Item encoded `10.1073%2Fpnas.96.20.11601_Fig4` (public TSV `10.1073%2Fpnas.96.20.11601_Fig4.tsv`).

## Frozen source (constructed snapshot)

`Preuss_etal_1999_Fig4_snapshot.csv` (5 rows, UTF-8 with BOM; sha256 `0861434b2366418d...`). There is no printed table: the values live in figure legends, diagrams and running text, so the snapshot is a table we constructed (snapshot HOWTO, 'When there is no table').

- **Who and how:** transcribed on 5 Nov 2026 by the AI assistant (Copilot) from the PDF (`preuss_etal_1999.pdf`, in this folder): text rows from the PDF text layer (poppler `pdftotext`); diagram labels, arrows and letter codes from page images rendered at 200-220 dpi.
- **What is verbatim:** `printed_wording` is a short phrase (13 words or fewer) copied from the locus; `locus`, `page` (journal page) and `panel` say where. Everything else in a row (`taxon_*`, `feature`, `state_as_read`, `applies_to`, `note`) is our reading, and that reading is what the human check confirms.
- **Group statements** ('apes and humans', 'monkeys', 'none of the other species') are expanded to one row per taxon the Methods list for that stain; the printed group phrase stays in `taxon_as_printed` and the Methods name in `taxon_in_methods`.
- **Human check:** pending (registry column AJ). Check each row against the PDF page named in `page`.

Snapshot columns: row, row_type (statement, terminal_label, clade_label, annotation, letter_key, photo_mark), locus, page, panel, taxon_as_printed, taxon_in_methods, marker, layer, feature, state_as_read, value_low, value_high, unit, n_as_printed, applies_to (tree annotations: the genera under the arrow, or `root`), printed_wording, evidence (legend, Results, Discussion, figure image), note.

## What the data are

`Preuss_etal_1999_Fig4.csv`: 5 rows x 24 columns (5 statement). One row = one taxon (or group, or tree node) x one trait at one locus. States are qualitative except the size rows (`value_low`-`value_high`, µm as printed).

- Accepted taxa: Homo sapiens; Macaca sp.; Pongo pygmaeus.
- Traits: `L4A_NPNF_encapsulating_bands`, `L4A_NPNF_vertical_elements` (definitions in `reference_tables/Preuss_etal_1999_Fig4_definitions.csv`).
- Data role: **primary**.
- Area: V1 (striate cortex); layers in the Brodmann-Lund scheme the authors use (4A, 4B, 4Cα, 4Cβ).

## Species

Printed names are kept (`taxon_as_printed`, `taxon_in_methods`); accepted names come from `_keys/General/species_key.csv` rows with source_publication `Preuss_etal_1999` (added 5 Nov 2026). Methods binomials map verbatim; `Macaca` (several species pooled in Methods) -> Macaca sp. (basis lump); `Cercopithecus aethiops` -> Chlorocebus aethiops (synonym); genus labels on trees -> `<Genus> sp.` anchors (Homo -> Homo sapiens).

## Build

`Preuss_etal_1999_Fig4.R` reads the snapshot, checks its columns, row count (5) and coding vocabulary, resolves names through the species key, codes each feature to a trait, and writes the analysis CSV and the public TSV `__Public/comparative-data/10.1073%2Fpnas.96.20.11601_Fig4.tsv` (Item encoded looked up from `__ReadMe.xlsx` by Item name), then runs `validate_dataset_item()`.

**R NOT RUN.** There is no R in this workspace: the CSV and TSV were written by a Python mirror of the R logic (same rows, columns, quoting and blanks as `write.csv` / `write.table`). Rerun the R script to confirm; it stops if the analysis row count is not 5.

## Checks

Python mirror, 5 Nov 2026 -- pass: 5.

- Every text-layer quote (`printed_wording` on legend / Results / Discussion rows) was found on the page given in `page` (letters and digits compared, so line breaks, hyphenation and dashes do not matter). The R script repeats this check with `pdftools` when the PDF is in the folder.

## Differences from the earlier export workbook (`Evo_M1_Trait_Data_Preuss_etal_1999.xlsx`)

- Three export rows match. Added the two contrasting rows the legend implies (Macaca and Pongo: no encapsulating bands; layer 4A generally lightly stained).

The export workbook is left untouched in this folder.

## In the app (5 Nov 2026)

Listed in the app's source-table browser (`__ShinyApp/data/source_manifest.csv`). Its states are not separate app labels: the Preuss 1999 labels come from the Main Text and Fig. 2 items, which carry the same observations; Fig. 1 is a literature model and Fig. 6 a tree interpretation.
