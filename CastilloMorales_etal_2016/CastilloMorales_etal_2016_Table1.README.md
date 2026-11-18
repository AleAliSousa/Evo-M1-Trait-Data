# Castillo-Morales et al. 2016 — Table 1 (neocortex ratio traits, 28 species)

Castillo-Morales A, Monzón-Sandoval J, de Sousa AA, Urrutia AO, Gutierrez H
(2016). *Neocortex expansion is linked to size variations in gene families
with chemotaxis, cell–cell signalling and immune response functions in
mammals.* Open Biology 6: 160132. doi:10.1098/rsob.160132

Table **1** — phenotypic traits for the **28 mammalian species** analysed:
brain volume (cm³), neocortex volume (cm³), the literature source of the
volumes (refs 84–99), neocortex ratio **Nr** (after Dunbar: neocortex /
(brain − neocortex)), encephalization index **Ei** (= ln(brain mass /
body mass^0.64), slope from the 493-species data of González-Lagos et al.
2010, ref 83), and maximum lifespan (AnAge, ref 100).

## Source → Snapshot → Data readable → Online database

<<<<<<< HEAD
- **Frozen source:** the publisher PDF in this folder (Table 1, p. 3),
  plus the paper's figshare supplementary file `rsob160132_si_001.csv`
  (gene-family results only — no trait data).
- **Reformat:** `CastilloMorales_etal_2016_Table1.R` transcribes Table 1
  verbatim (volumes in cm³ as printed; species names as printed) and
  writes:
  - `CastilloMorales_etal_2016_Table1.csv` (analysis-ready, 28 rows)
  - `../__Public/comparative-data/10.1098%2Frsob.160132_Table1.tsv` (public, DOI-encoded —
    name is the expected Item encoded; see Registry)
- **Definitions:** `reference_tables/CastilloMorales_etal_2016_Table1_definitions.csv`.
- **Reader:** the CSV/TSV were produced by Muse (Buddy), Michael Proulx's
  AI assistant, with a Python equivalent of the .R build and
  cross-checked programmatically: recomputing Nr from the two volume
  columns reproduces all 28 printed Nr values to 2 dp. The R script was
  run in an isolated copy on 2026-11-18; its CSV and TSV matched the
  committed files by cell.
=======
- **Source:** the publisher PDF of the paper, held in this folder
  (`Castillo-Morales-2016-Neocortex_expansion.pdf`); Table 1 is a printed
  table on p. 3. The paper's figshare supplementary file
  (`rsob160132_si_001.csv`, gene-family results only) carries no trait
  data and is not this item's source.
- **Snapshot:** `CastilloMorales_etal_2016_Table1_snapshot.csv` — Table 1
  transcribed exactly as printed (printed headers, row order, values and
  the bracketed ref. numbers kept), frozen **before** any cleaning.
  Transcribed by Buddy (AI assistant) on 2026-11-18 from the publisher
  PDF and verified against it: every row cross-checked against the PDF
  text layer, and the Ei signs read from the printed page (the text layer
  renders a minus sign as a leading "2"; only *Homo sapiens* has a
  positive Ei, as the paper's formula requires).
- **Data readable:** `CastilloMorales_etal_2016_Table1.R` reads **only**
  the snapshot, cleans (numeric types, ref. brackets stripped, per-row
  source folder keys joined from the references file below) and writes
  `CastilloMorales_etal_2016_Table1.csv` (28 rows) and the public TSV.
  The script runs clean under Rscript and reproduces the committed
  CSV/TSV exactly.
- **References:** `reference_tables/CastilloMorales_etal_2016_Table1_references.csv`
  itemises every source the item cites (ref_keys [83]–[99] exactly as
  printed in the table's ref. column, with the verbatim bibliography
  entries); `Source` in the analysis CSV is the Evo-M1 folder key
  recorded in that file's notes.
- **Definitions:** `reference_tables/CastilloMorales_etal_2016_Table1_definitions.csv`.
- **Online database:** public TSV `10.1098%2Frsob.160132_Table1.tsv` in
  `__Public/comparative-data/`; registry row in `__ReadMe.xlsx`
  (Item name `CastilloMorales_etal_2016_Table1`).

## Table checks

The reader recomputes Nr from the printed volumes for all 28 species
(build HOWTO §7a): the recomputed value must fall inside the rounding
envelope of the printed volumes, widened by half a unit of Nr's last
printed decimal. **Result (R run, 2026-11-18): 28 of 28 pass.** The
mouse row is the widest case (printed volumes 0.48/0.12 cm³ carry only
two significant figures; recomputed Nr 0.333 against printed 0.32,
inside the envelope). Nothing was adjusted to make a check pass.
>>>>>>> 92a9b69404ddaff1cfd1c8f6e9607368c2dbeb5b

## Data role and caveats

- **Secondary compilation.** Every value was compiled by the authors
  from earlier literature; nothing here is a primary measurement. The
  volume source is named per row in `Source`; the Ei column rests on
  González-Lagos et al. (2010), whose brain/body dataset is not an
  Evo-M1 item (see the `GonzalezLagos_etal_2010` folder).
- **Neocortex definition:** grey + white matter of the cerebral cortex,
  excluding palaeocortical grey matter (entorhinal cortex, schizocortex,
  hippocampus, amygdala) — paper Methods 2.2.
- **Erratum (proposed):** the dog row's two volumes look ×10 too large
  for a poodle (Nr is unaffected, being a ratio) — recorded as
  `CastilloMorales_etal_2016-E001` in
  `reference_tables/CastilloMorales_etal_2016_errata.csv`; values are
  kept as printed.
- **Names as printed:** *Canis familiaris* (now usually *Canis lupus
  familiaris*), *Macropus eugenii* (now *Notamacropus eugenii*) and the
  trinomen *Mustela putorius furo* are kept verbatim; harmonisation is a
  merge-side step via the species keys.

<!-- errata:begin -->
## Errata

<<<<<<< HEAD
The public TSV name above is the expected Item encoded
(10.1098%2Frsob.160132_Table1). The registry row was added on 2026-11-18; descriptive metadata remain incomplete. Merge ingestion is pending.
=======
Generated from `reference_tables/CastilloMorales_etal_2016_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| CastilloMorales_etal_2016-E001 | Brain_volume_cm3 | Table 1, row "Canis familiaris" | 458.273 | 458.273 | publication_error |  | proposed | Nr (0.63) is unchanged if both volume columns are scaled by the same factor, so the printed ratio cannot detect the slip; the Evo-M1 volumes merge carries the dog's total brain volume as 46.6 cm3 (Ashwell 2020, as Canis lupus familiaris), one tenth of the printed value, and no dog breed approaches a 458 cm3 brain. Suspected decimal slip affecting both volume columns of this row. | The Neocortex_volume_cm3 cell of the same row (177.753) is covered by this erratum. Values kept as printed in the snapshot and the analysis CSV; merges should see this flag before using the row's volumes. |

1 recorded, 1 open (proposed), 0 confirmed, 0 withdrawn.
<!-- errata:end -->
>>>>>>> 92a9b69404ddaff1cfd1c8f6e9607368c2dbeb5b
