# Preuss & Coleman 2002: Fig 11 Matrix -- reconstruction of layer 4A evolution in anthropoid primates -- per-genus letter codes for the kinds of data published, annotation boxes, and photomicrograph marks

Source: Preuss, T. M., & Coleman, G. Q. (2002). Human-specific organization of primary visual cortex: Alternating compartments of dense Cat-301 and calbindin immunoreactivity in layer 4A. Cerebral Cortex, 12(7), 671-691. https://doi.org/10.1093/cercor/12.7.671

Item: Fig. 11 (legend p. 684, graphic p. 685): reconstruction of layer 4A evolution in anthropoid primates -- per-genus letter codes for the kinds of data published, annotation boxes, and photomicrograph marks.
Registry: Item number `Fig 11 Matrix`; Item name `Preuss_Coleman_2002_Fig11Matrix`; Item encoded `10.1093%2Fcercor%2F12.7.671_Fig11Matrix` (public TSV `10.1093%2Fcercor%2F12.7.671_Fig11Matrix.tsv`).

## Frozen source (constructed snapshot)

`Preuss_Coleman_2002_Fig11Matrix_snapshot.csv` (52 rows, UTF-8 with BOM; sha256 `8a4fe6766f0bfe7c...`). There is no printed table: the values live in figure legends, diagrams and running text, so the snapshot is a table we constructed (snapshot HOWTO, 'When there is no table').

- **Who and how:** transcribed on 5 Nov 2026 by the AI assistant (Copilot) from the PDF (`preuss_coleman_2002.pdf`, in this folder): text rows from the PDF text layer (poppler `pdftotext`); diagram labels, arrows and letter codes from page images rendered at 200-220 dpi.
- **What is verbatim:** `printed_wording` is a short phrase (13 words or fewer) copied from the locus; `locus`, `page` (journal page) and `panel` say where. Everything else in a row (`taxon_*`, `feature`, `state_as_read`, `applies_to`, `note`) is our reading, and that reading is what the human check confirms.
- **Group statements** ('apes and humans', 'monkeys', 'none of the other species') are expanded to one row per taxon the Methods list for that stain; the printed group phrase stays in `taxon_as_printed` and the Methods name in `taxon_in_methods`.
- **Human check:** pending (registry column AJ). Check each row against the PDF page named in `page`.

Snapshot columns: row, row_type (statement, terminal_label, clade_label, annotation, letter_key, photo_mark), locus, page, panel, taxon_as_printed, taxon_in_methods, marker, layer, feature, state_as_read, value_low, value_high, unit, n_as_printed, applies_to (tree annotations: the genera under the arrow, or `root`), printed_wording, evidence (legend, Results, Discussion, figure image), note.

## What the data are

`Preuss_Coleman_2002_Fig11Matrix.csv`: 73 rows x 24 columns (6 annotation, 66 derived, 1 statement). One row = one taxon (or group, or tree node) x one trait at one locus. States are qualitative except the size rows (`value_low`-`value_high`, µm as printed).

- Accepted taxa: Aotus sp.; Ateles sp.; Callithrix sp.; Cebus sp.; Cercopithecus sp.; Erythrocebus patas; Homo sapiens; Macaca sp.; Miopithecus talapoin; Pan sp.; Papio sp.; Pongo sp.; Saimiri sp.
- Traits: `L3_NPNF_dense`, `L4A_CB_level`, `L4A_CO_dense_band`, `L4A_Cat301_pattern`, `L4A_NPNF_pattern`, `L4A_direct_LGN_input`, `L4A_honeycomb`, `L4A_mesh` (definitions in `reference_tables/Preuss_Coleman_2002_Fig11Matrix_definitions.csv`).
- Data role: **both**. Per-genus states are inferred: only where the printed letter code includes the character, from the most specific annotation box (state_basis says so).
- Area: V1 (striate cortex); layers in the Brodmann-Lund scheme the authors use (4A, 4B, 4Cα, 4Cβ).
- Caveat: Derived states are inferences from the reconstruction, not observations; literature data behind letters a-b come from studies cited in the text (not built here).

## Species

Printed names are kept (`taxon_as_printed`, `taxon_in_methods`); accepted names come from `_keys/General/species_key.csv` rows with source_publication `Preuss_Coleman_2002` (added 5 Nov 2026). Methods binomials map verbatim; `Macaca` (several species pooled in Methods) -> Macaca sp. (basis lump); genus labels on trees -> `<Genus> sp.` anchors (Homo -> Homo sapiens); Fig. 11 `Saimiri` -> Saimiri sp. (not yet in the hub), `Erythrocebus` -> Erythrocebus patas and `Miopithecus` -> Miopithecus talapoin (legend vernacular names).

## Build

`Preuss_Coleman_2002_Fig11Matrix.R` reads the snapshot, checks its columns, row count (52) and coding vocabulary, resolves names through the species key, codes each feature to a trait, and writes the analysis CSV and the public TSV `__Public/comparative-data/10.1093%2Fcercor%2F12.7.671_Fig11Matrix.tsv` (Item encoded looked up from `__ReadMe.xlsx` by Item name), then runs `validate_dataset_item()`.
For tree annotations it derives terminal states: a change annotation applies to the genera listed in `applies_to` (`?` under a label gives `uncertain`); a `root` annotation becomes an ancestral-node row; letter-coded characters get a state only where the genus's printed code includes the letter, taken from the most specific annotation covering the genus (fewest genera under the arrow).

**R NOT RUN.** There is no R in this workspace: the CSV and TSV were written by a Python mirror of the R logic (same rows, columns, quoting and blanks as `write.csv` / `write.table`). Rerun the R script to confirm; it stops if the analysis row count is not 73.

## Checks

Python mirror, 5 Nov 2026 -- not evaluable (diagram text is not in the PDF text layer): 46, pass: 22.

- Every text-layer quote (`printed_wording` on legend / Results / Discussion rows) was found on the page given in `page` (letters and digits compared, so line breaks, hyphenation and dashes do not matter). The R script repeats this check with `pdftools` when the PDF is in the folder.
- Photomicrograph marks vs annotation boxes: filled arrows (Pan CO, CB) sit on hominoid changes, open arrows (Homo CB, NPNF, Cat-301) on human changes, the asterisk (Pan NPNF, layer 3) on the hominoid layer-3 increase printed in the legend: 16/16 agree.
- Agreement with the owner's export matrix: every lettered cell matches (see below).
- Diagram labels, arrows and letter codes are drawn as graphics (not in the text layer): checked by eye only.

## Differences from the earlier export workbook (`Evo_M1_Trait_Data_Preuss_Coleman_2002.xlsx`)

- The export is a 13-genus state matrix (Lgn 4A, Co Band, Honeycomb, Mesh, Npnf, Cat301, Calbindin). The figure does not print a state matrix: it prints, under each genus, letter codes for the kinds of data published (a-e) plus annotation boxes (ancestral organization; Aotus, hominoid and human specializations) from a MacClade parsimony reconstruction.
- The snapshot keeps exactly what is printed; the R script derives per-genus states only where the letter is printed. For every lettered cell the derived state agrees with the export (export 1/0 = present/absent; low = sparse; moderate = increased; high = dense in mesh bands or interstitial zones; '?' = no data published).
- Export Honeycomb and Mesh values per genus are not printed (only the ancestral honeycomb and the human meshwork are), so they are not reproduced, except Homo mesh = present (Human specializations box).
- Added the photomicrograph marks (filled arrows on Pan CO and CB, asterisk on Pan NPNF layer 3, open arrows on Homo CB, NPNF and Cat-301) as checks against the annotation boxes: all 16 agree.

The export workbook is left untouched in this folder.

## In the app (5 Nov 2026)

Mapped in `__merging_supplementary/supplementary_sources.csv` (dataset **Supplementary sources**, domain cellular composition, class `v1_layer4_architecture`, text states with Units `category`):
- `V1_L4A_direct_LGN_input_Preuss2002Fig11 (category)`
- `V1_L4A_CO_dense_band_Preuss2002Fig11 (category)`
- `V1_L4A_CB_level_Preuss2002Fig11 (category)`
- `V1_L4A_NPNF_pattern_Preuss2002Fig11 (category)`
- `V1_L4A_Cat301_pattern_Preuss2002Fig11 (category)`

Rows were written by a Python mirror of `supplementary_compiled.R` (R NOT RUN); definitions are in `__merging_supplementary/supplementary_label_definitions.csv`. The deployed app reads GitHub, so the change shows after the R steps and a push.
