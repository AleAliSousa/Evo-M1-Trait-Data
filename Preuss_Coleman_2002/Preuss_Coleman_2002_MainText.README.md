# Preuss & Coleman 2002: Main Text -- Cat-301, calbindin and NPNF in area V1 layer 4A of humans, chimpanzees, an orangutan, macaques, squirrel and spider monkeys

Source: Preuss, T. M., & Coleman, G. Q. (2002). Human-specific organization of primary visual cortex: Alternating compartments of dense Cat-301 and calbindin immunoreactivity in layer 4A. Cerebral Cortex, 12(7), 671-691. https://doi.org/10.1093/cercor/12.7.671

Item: comparative statements in Methods and Results (pp. 672-679): Cat-301, calbindin and NPNF in area V1 layer 4A of humans, chimpanzees, an orangutan, macaques, squirrel and spider monkeys.
Registry: Item number `Main Text`; Item name `Preuss_Coleman_2002_MainText`; Item encoded `10.1093%2Fcercor%2F12.7.671_MainText` (public TSV `10.1093%2Fcercor%2F12.7.671_MainText.tsv`).

## Frozen source (constructed snapshot)

`Preuss_Coleman_2002_MainText_snapshot.csv` (35 rows, UTF-8 with BOM; sha256 `d4927025fcdad57e...`). There is no printed table: the values live in figure legends, diagrams and running text, so the snapshot is a table we constructed (snapshot HOWTO, 'When there is no table').

- **Who and how:** transcribed on 5 Nov 2026 by the AI assistant (Copilot) from the PDF (`preuss_coleman_2002.pdf`, in this folder): text rows from the PDF text layer (poppler `pdftotext`); diagram labels, arrows and letter codes from page images rendered at 200-220 dpi.
- **What is verbatim:** `printed_wording` is a short phrase (13 words or fewer) copied from the locus; `locus`, `page` (journal page) and `panel` say where. Everything else in a row (`taxon_*`, `feature`, `state_as_read`, `applies_to`, `note`) is our reading, and that reading is what the human check confirms.
- **Group statements** ('apes and humans', 'monkeys', 'none of the other species') are expanded to one row per taxon the Methods list for that stain; the printed group phrase stays in `taxon_as_printed` and the Methods name in `taxon_in_methods`.
- **Human check:** pending (registry column AJ). Check each row against the PDF page named in `page`.

Snapshot columns: row, row_type (statement, terminal_label, clade_label, annotation, letter_key, photo_mark), locus, page, panel, taxon_as_printed, taxon_in_methods, marker, layer, feature, state_as_read, value_low, value_high, unit, n_as_printed, applies_to (tree annotations: the genera under the arrow, or `root`), printed_wording, evidence (legend, Results, Discussion, figure image), note.

## What the data are

`Preuss_Coleman_2002_MainText.csv`: 35 rows x 24 columns (35 statement). One row = one taxon (or group, or tree node) x one trait at one locus. States are qualitative except the size rows (`value_low`-`value_high`, µm as printed).

- Accepted taxa: Ateles geoffroyi; Homo sapiens; Macaca sp.; Pan troglodytes; Pongo pygmaeus; Saimiri sciureus.
- Traits: `L4A_CB_Cat301_complementary`, `L4A_CB_NPNF_complementary`, `L4A_CB_double_labelled`, `L4A_CB_pattern`, `L4A_CB_soma_diameter`, `L4A_Cat301_NPNF_double_labelled`, `L4A_Cat301_NPNF_same_compartments`, `L4A_Cat301_capsule_diameter`, `L4A_Cat301_large_soma_diameter`, `L4A_Cat301_mesh`, `L4A_Cat301_soma_diameter`, `V1_CB_staining_strength`, `V1_Cat301_densest_layer`, `V1_Cat301_staining_strength` (definitions in `reference_tables/Preuss_Coleman_2002_MainText_definitions.csv`).
- Data role: **primary**. Sample sizes per stain are from Methods (pp. 672-673).
- Area: V1 (striate cortex); layers in the Brodmann-Lund scheme the authors use (4A, 4B, 4Cα, 4Cβ).
- Caveat: Staining-strength rows describe antibody sensitivity under the protocol (dilution and incubation needed), not an anatomical measure.

## Species

Printed names are kept (`taxon_as_printed`, `taxon_in_methods`); accepted names come from `_keys/General/species_key.csv` rows with source_publication `Preuss_Coleman_2002` (added 5 Nov 2026). Methods binomials map verbatim; `Macaca` (several species pooled in Methods) -> Macaca sp. (basis lump); genus labels on trees -> `<Genus> sp.` anchors (Homo -> Homo sapiens).

## Build

`Preuss_Coleman_2002_MainText.R` reads the snapshot, checks its columns, row count (35) and coding vocabulary, resolves names through the species key, codes each feature to a trait, and writes the analysis CSV and the public TSV `__Public/comparative-data/10.1093%2Fcercor%2F12.7.671_MainText.tsv` (Item encoded looked up from `__ReadMe.xlsx` by Item name), then runs `validate_dataset_item()`.

**R NOT RUN.** There is no R in this workspace: the CSV and TSV were written by a Python mirror of the R logic (same rows, columns, quoting and blanks as `write.csv` / `write.table`). Rerun the R script to confirm; it stops if the analysis row count is not 35.

## Checks

Python mirror, 5 Nov 2026 -- pass: 35.

- Every text-layer quote (`printed_wording` on legend / Results / Discussion rows) was found on the page given in `page` (letters and digits compared, so line breaks, hyphenation and dashes do not matter). The R script repeats this check with `pdftools` when the PDF is in the folder.

## Differences from the earlier export workbook (`Evo_M1_Trait_Data_Preuss_Coleman_2002.xlsx`)

- The export had four human rows only. Added the nonhuman results (no Cat-301 mesh in Pan, Pongo, Macaca, Saimiri or Ateles), the densest Cat-301 layer (4B in humans and chimpanzees; 6 in macaques and the orangutan), Cat-301 and calbindin staining strength, soma and capsule sizes, calbindin patterns for apes and monkeys, and the macaque double-staining result.
- Export Text_3 'Cat-301/NPNF colocalization in 4A mesh bands: Present' is coded as 'same compartments: present' plus 'double-labelled neuronal elements in 4A: absent' (Results p. 676), so 'colocalization' is not read as co-expression in the same neurons.

The export workbook is left untouched in this folder.

## In the app (5 Nov 2026)

Mapped in `__merging_supplementary/supplementary_sources.csv` (dataset **Supplementary sources**, domain cellular composition, class `v1_layer4_architecture`, text states with Units `category`):
- `V1_L4A_Cat301_mesh_Preuss2002 (category)`
- `V1_L4A_CB_pattern_Preuss2002 (category)`
- `V1_Cat301_densest_layer_Preuss2002 (category)`
- `V1_L4A_CB_Cat301_complementary_Preuss2002 (category)`

Rows were written by a Python mirror of `supplementary_compiled.R` (R NOT RUN); definitions are in `__merging_supplementary/supplementary_label_definitions.csv`. The deployed app reads GitHub, so the change shows after the R steps and a push.
