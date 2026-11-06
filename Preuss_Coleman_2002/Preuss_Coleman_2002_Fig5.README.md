# Preuss & Coleman 2002: Fig 5 -- Cat-301 immunoreactivity in area V1 of six primate taxa (Homo, Pan, Pongo, Macaca, Ateles, Saimiri)

Source: Preuss, T. M., & Coleman, G. Q. (2002). Human-specific organization of primary visual cortex: Alternating compartments of dense Cat-301 and calbindin immunoreactivity in layer 4A. Cerebral Cortex, 12(7), 671-691. https://doi.org/10.1093/cercor/12.7.671

Item: Fig. 5 legend (p. 677): Cat-301 immunoreactivity in area V1 of six primate taxa (Homo, Pan, Pongo, Macaca, Ateles, Saimiri).
Registry: Item number `Fig 5`; Item name `Preuss_Coleman_2002_Fig5`; Item encoded `10.1093%2Fcercor%2F12.7.671_Fig5` (public TSV `10.1093%2Fcercor%2F12.7.671_Fig5.tsv`).

## Frozen source (constructed snapshot)

`Preuss_Coleman_2002_Fig5_snapshot.csv` (6 rows, UTF-8 with BOM; sha256 `986c32eb310a8980...`). There is no printed table: the values live in figure legends, diagrams and running text, so the snapshot is a table we constructed (snapshot HOWTO, 'When there is no table').

- **Who and how:** transcribed on 5 Nov 2026 by the AI assistant (Copilot) from the PDF (`preuss_coleman_2002.pdf`, in this folder): text rows from the PDF text layer (poppler `pdftotext`); diagram labels, arrows and letter codes from page images rendered at 200-220 dpi.
- **What is verbatim:** `printed_wording` is a short phrase (13 words or fewer) copied from the locus; `locus`, `page` (journal page) and `panel` say where. Everything else in a row (`taxon_*`, `feature`, `state_as_read`, `applies_to`, `note`) is our reading, and that reading is what the human check confirms.
- **Group statements** ('apes and humans', 'monkeys', 'none of the other species') are expanded to one row per taxon the Methods list for that stain; the printed group phrase stays in `taxon_as_printed` and the Methods name in `taxon_in_methods`.
- **Human check:** pending (registry column AJ). Check each row against the PDF page named in `page`.

Snapshot columns: row, row_type (statement, terminal_label, clade_label, annotation, letter_key, photo_mark), locus, page, panel, taxon_as_printed, taxon_in_methods, marker, layer, feature, state_as_read, value_low, value_high, unit, n_as_printed, applies_to (tree annotations: the genera under the arrow, or `root`), printed_wording, evidence (legend, Results, Discussion, figure image), note.

## What the data are

`Preuss_Coleman_2002_Fig5.csv`: 6 rows x 24 columns (6 statement). One row = one taxon (or group, or tree node) x one trait at one locus. States are qualitative except the size rows (`value_low`-`value_high`, µm as printed).

- Accepted taxa: Ateles geoffroyi; Homo sapiens; Macaca sp.; Pan troglodytes; Pongo pygmaeus; Saimiri sciureus.
- Traits: `L4A_Cat301_mesh` (definitions in `reference_tables/Preuss_Coleman_2002_Fig5_definitions.csv`).
- Data role: **primary**. The legend lists the taxa only; states come from the Results text that cites Fig. 5.
- Area: V1 (striate cortex); layers in the Brodmann-Lund scheme the authors use (4A, 4B, 4Cα, 4Cβ).

## Species

Printed names are kept (`taxon_as_printed`, `taxon_in_methods`); accepted names come from `_keys/General/species_key.csv` rows with source_publication `Preuss_Coleman_2002` (added 5 Nov 2026). Methods binomials map verbatim; `Macaca` (several species pooled in Methods) -> Macaca sp. (basis lump); genus labels on trees -> `<Genus> sp.` anchors (Homo -> Homo sapiens).

## Build

`Preuss_Coleman_2002_Fig5.R` reads the snapshot, checks its columns, row count (6) and coding vocabulary, resolves names through the species key, codes each feature to a trait, and writes the analysis CSV and the public TSV `__Public/comparative-data/10.1093%2Fcercor%2F12.7.671_Fig5.tsv` (Item encoded looked up from `__ReadMe.xlsx` by Item name), then runs `validate_dataset_item()`.

**R NOT RUN.** There is no R in this workspace: the CSV and TSV were written by a Python mirror of the R logic (same rows, columns, quoting and blanks as `write.csv` / `write.table`). Rerun the R script to confirm; it stops if the analysis row count is not 6.

## Checks

Python mirror, 5 Nov 2026 -- pass: 6.

- Every text-layer quote (`printed_wording` on legend / Results / Discussion rows) was found on the page given in `page` (letters and digits compared, so line breaks, hyphenation and dashes do not matter). The R script repeats this check with `pdftools` when the PDF is in the folder.

## Differences from the earlier export workbook (`Evo_M1_Trait_Data_Preuss_Coleman_2002.xlsx`)

- Same six taxa and states as the export ('Absent (light stratum)' is coded as absent, with the light stratum in the note). The legend lists taxa only; states come from the Results.

The export workbook is left untouched in this folder.

## In the app (5 Nov 2026)

Listed in the app's source-table browser (`__ShinyApp/data/source_manifest.csv`). Its states are not separate app labels: the Preuss & Coleman 2002 labels come from the Main Text (observations) and Fig. 11 (reconstruction) items; the figure items repeat Main Text states for the same taxa.
