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

## What we built

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

## Data role and caveats

- **Secondary compilation.** Every value was compiled by the authors from
  earlier literature; nothing here is a primary measurement. The volume
  source is named per row in `Source`; the Ei column rests on
  González-Lagos et al. (2010), whose brain/body dataset is not (yet) an
  Evo-M1 item.
- **Neocortex definition:** grey + white matter of the cerebral cortex,
  excluding palaeocortical grey matter (entorhinal cortex, schizocortex,
  hippocampus, amygdala) — paper Methods 2.2.
- **Ei signs:** the PDF text layer renders minus signs as a leading "2";
  the CSV carries the true signed values (only Homo sapiens is positive).
- **Dog row:** brain/neocortex volumes as printed look 10× too large for
  a poodle (see folder ReadMe, Quality Note 2). Transcribed as printed.
- **Names as printed:** *Canis familiaris* (now usually *Canis lupus
  familiaris*), *Macropus eugenii* (now *Notamacropus eugenii*) and the
  trinomen *Mustela putorius furo* are kept verbatim; harmonisation is a
  merge-side step via the species keys.

## Registry

The public TSV name above is the expected Item encoded
(10.1098%2Frsob.160132_Table1). The registry row was added on 2026-11-18; descriptive metadata remain incomplete. Merge ingestion is pending.
