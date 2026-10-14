# Zilles_etal_1986_Table2

## Status — documentation completed, NOT FINISHED

Frozen source, R reader and analysis CSV already exist in this folder; this README and `reference_tables/Zilles_etal_1986_Table2_definitions.csv` were added on 2026-10-13 to complete the 4-file convention. They document the existing files only — no data, script, snapshot, registry row or public TSV was changed. No registry invariant is claimed passed here.

## Source → snapshot

Zilles, K., Armstrong, E., Schlaug, G., & Schleicher, A. (1986). Quantitative cytoarchitectonics of the posterior cingulate cortex in primates. Journal of Comparative Neurology, 253(4), 514–524. https://doi.org/10.1002/cne.902530408

Locus: **TABLE 2. Grey Level Indices (GLI) of the Different Areas and Layers in the Posterior Cingulate Gyrus of 17 Primate Species**, printed p.521 (PDF page 8; `page_8.png` in this folder is a page render). Source PDF `zilles_etal_1986.pdf` is held in this folder unchanged.

Source format is a scanned journal page with an OCR text layer (Adobe Paper Capture); the printed table is legible, but the OCR layer contains character errors in species names (e.g. `A/,ouatta`, `Popio`, `Pan trog/,odytes`), so the text layer is not a numerical authority. Legibility is source-format metadata, not a measurement-confidence score. The folder also holds `zilles_etal_1986.xlsx`, a large workbook export of the PDF (provenance).

`Zilles_etal_1986_Table2_snapshot.xlsx` (sheet `Table2`) keeps the caption, the area grouping row, the printed layer headers, 17 species rows in printed order and the abbreviation footnote; 10 value columns: O/I for areas 29 and 30 and O/G/I for areas 23 and 31 (no molecular-layer column is printed; the text notes the molecular layer's very low GLI gives standardized values a high relative error). [TO CHECK: the reader who transcribed the snapshot and the date are not recorded in the folder.] The draft registry row in `__ReadMe_rows_to_add_Zilles_etal_1986.csv` states "Verified cell-by-cell against the PDF (p.521), exact match" but does not name who performed that check or how; human visual curation is therefore recorded here as pending.

## Snapshot → data readable

Run `Zilles_etal_1986_Table2.R` in a clean R session. It reads the snapshot (skip 2 rows), asserts the 11 literal headers (duplicate O/G/I labels read with `.name_repair = "minimal"`), renames them to `area<NN>_<layer>_GLI`, drops the blank and footnote rows, parses numbers, and stops unless there are exactly 17 unique species with no missing values. It writes `Zilles_etal_1986_Table2.csv` and looks up `Item encoded` by exact `Item name` in `__ReadMe.xlsx` Sheet1, writing `<Item encoded>.tsv` to `__Public/comparative-data/` (it stops if no registry code exists). The draft registry row proposes `10.1002%2Fcne.902530408_Table2` (NOT registry authority).

Method (methods p.514–515): 17 primate species; brains serially sectioned at 20 µm and stained with cresyl violet; areas 29, 30, 23 and 31 (Brodmann) analysed on at least two sections immediately rostral to the splenium of the corpus callosum; laminae delineated from GLI computer plots superimposed on the sections with a drawing tube, then outlined and measured with a computer-controlled scanning stage and TV image analyzer (Micro-videomat 2, Zeiss). Laminae: molecular (layer I), outer main lamina, granular (areas 23 and 31 only), inner main lamina (layers V–VI).

Units: standardized GLI in percent (methods eq. 2: layer GLI × 100 / mean GLI of the reference field; the paper states that 'GLI value' means standardized GLI). The GLI is the proportion of a 20 × 20 µm measuring field occupied by cresyl-violet-stained profiles (neuronal cell bodies, glial and endothelial nuclei). [TO CHECK: the OCR text names the reference as the mean GLI of 'the whole area 29'; confirm on the page image whether each area is standardized to its own mean.]

Observation level: **one row per species** (17 rows). Most species are represented by one brain; Perodicticus potto, Callithrix jacchus, Macaca mulatta and Papio sp. by n=2 and Cercopithecus mitis by n=3 (methods p.514). See `Method:observation_level` in `reference_tables/Zilles_etal_1986_Table2_definitions.csv`. [TO CHECK: the table does not state that values for n>1 species are means.] Printed species names are retained in `Species`; collection-scoped species mapping is still required.

Data role: **primary** (the authors' own measurements; the draft registry row also gives `primary`). The folder's draft registry row records that these values are merged into `__merging_GLI/GLI_long.csv` (O → supragranular, G → granular, I → infragranular).

## Known limitations

- Values are printed as integers or one decimal; small samples (1–3 brains per species) and only two or more sections per brain near the splenium, so values describe that sampling plane, not the whole area.
- The authors describe the boundary between areas 23 and 31 as more difficult to recognize than the 29/30 and 30/23 boundaries (p.516).

## QA and online database

No public comparison folder exists, and no independent 0-mismatch audit is claimed in this README. [TO CHECK: whether the committed CSV was produced by an R run; no execution log is held in the folder.] Expected analysis rows: **17**. Definitions have the fixed 10-column schema.

Pending: owner paste of the draft registry row (if not already done) and file-list recalculation; clean R audit → dry run → build → validate; human visual curation of the snapshot against the page; collection-scoped species mapping.
