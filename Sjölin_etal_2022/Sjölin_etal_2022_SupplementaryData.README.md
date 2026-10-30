# Sjölin_etal_2022_SupplementaryData — README

**Source.** Sjölin, K., Kultima, K., Larsson, A., Freyhult, E., Zjukovskaja, C., Alkass, K., &
Burman, J. (2022). Distribution of five clinically important neuroglial proteins in the human
brain. *Molecular Brain, 15*(1), 52. https://doi.org/10.1186/s13041-022-00935-6

**Item.** `Additional file 2` — the journal-supplied supplementary data workbook, one row per
tissue sample. Registry `Item name` = `Sjölin_etal_2022_SupplementaryData`,
`Item encoded` = `10.1186%2Fs13041-022-00935-6_SupplementaryData`.

## What the data are

ELISA concentrations of five neuroglial proteins — GFAP, MBP, NFL, tau (total) and UCHL1 — plus
total protein (BCA), measured in the supernatant of homogenised post-mortem tissue from **17 CNS
regions × 10 donors = 168 samples** (hippocampus is missing for two donors, so 168 rather than 170).
Donors were 24–50 years old, one of ten female, with no history of neurological disease; each row
also carries the donor's warm time, cold time, total post-mortem interval and cause of death.
This is a **within-human regional map**, not a comparative species dataset: one species, many
structures.

## Files

| file | what it is |
|---|---|
| `13041_2022_935_MOESM2_ESM.xlsx` | the download, as supplied by the journal |
| `Sjölin_etal_2022_SupplementaryData_snapshot.xlsx` | frozen source — a **byte-identical copy** of the download (sha256 `92ea0505…c44700`), not a transcription |
| `Sjölin_etal_2022_SupplementaryData.R` | build: frozen source → analysis CSV + public TSV |
| `Sjölin_etal_2022_SupplementaryData.csv` | analysis CSV, 168 rows × 26 columns |
| `reference_tables/Sjölin_etal_2022_SupplementaryData_definitions.csv` | data dictionary (48 rows) |
| `__Public/comparative-data/10.1186%2Fs13041-022-00935-6_SupplementaryData.tsv` | public TSV (repo-level, not in this folder) |
| `13041_2022_935_MOESM1_ESM.docx` | Additional file 1 — methods detail, regression tables, validation figures |

**Frozen source.** The source is digital-native (a journal `.xlsx`), so there is no transcription
step and no hand-made snapshot: the untouched download *is* the frozen copy, copy-renamed to the
`_snapshot.xlsx` suffix the builder tools expect. No cell value is typed into the build script.
`Human visual check of snapshot` = *Not applicable: tabulated and digital already*.

## What the build script does

1. Reads the frozen workbook as text and **asserts the 14 published column headers** — if the
   frozen file ever changes, the build stops rather than silently remapping columns.
2. Splits the printed `CNS region` cell into `region_code` (the sampling letter A–Q, which Fig. 1
   and Additional file 1 use) and `region_as_published`.
3. Adds `species_as_published` = `Homo sapiens` (the table prints no species; it comes from the
   title/methods) and harmonises it through `_keys/General/species_key.csv`.
4. Converts to tissue-referenced units (below), keeping every published column as printed.
5. Checks parse fidelity: the number of NAs per analyte column must equal the number of blank
   cells in the source (two — see *Missing values*), so no value can fail to parse unnoticed.
6. Writes the analysis CSV and the `Item encoded`-named public TSV.

Run it with a UTF-8 locale (`LC_ALL=en_US.UTF-8 Rscript …`); under a `C` locale R's `unzip` cannot
open a workbook whose path contains `ö`. The folder name is stored decomposed by macOS while the
registry spells it composed, so the script normalises both before matching (`nfc()`).

## Unit conversion

The published columns are concentrations **in the homogenate supernatant** (ng/mL; total protein
µg/mL). Additional file 1's extraction protocol adds lysing buffer *"at a ratio of 1 ml/100 mg
brain sample"* — 10 mL of homogenate per gram of wet tissue — so

    concentration per g wet tissue = supernatant concentration × 10 mL/g
    ng/mL × 10 / 1000 = µg/g        µg/mL × 10 / 1000 = mg/g

i.e. **× 0.01** in both cases. Both forms are in the CSV: `*_ng_per_ml` / `total_protein_ug_per_ml`
as published, `*_ug_per_g` / `total_protein_mg_per_g` derived. The derived columns are in the units
the paper itself reports (Table 2) and are the ones wired into the merge.

## Table checks

The frozen source prints no totals, percentages or other internal relation, so there is **no
self-check in the reader** (HOWTO §7a: don't invent one).

**External check against the paper's Table 2** (run once, offline, AI assistant, 2026-10-28; not
part of the build, because Table 2 is a separate published table whose values are not hardcoded
here). Per-region geometric means were recomputed from the public TSV's `*_ug_per_g` /
`total_protein_mg_per_g` columns and compared with all 102 printed cells of Table 2:

* **all 102 cells agree within 4.5%**, which is what rounding to the two significant figures
  Table 2 prints allows (a printed `100` covers 95–105, i.e. ±5%);
* for the quantities Table 2 reports unadjusted (GFAP, tau, UCHL1, total protein, and hippocampus
  MBP/NFL) the largest deviation is **+4.45%** (parietal white matter UCHL1, 104.4 vs 100 µg/g);
* for MBP and NFL, which Table 2 adjusts for donor warm time, the largest deviation is **2.9%** —
  the adjustment moves the regional means very little.

This confirms both the extraction and the 10 mL/g conversion: the values in this item reproduce the
published regional map.

## Missing values

Two analyte cells are blank in the source and stay empty here — donor 8 cervical spinal cord GFAP,
and donor 9 frontal lobe white matter total protein. Blank means not measured, never zero.

## Observation level

One row = **one donor × one CNS region**, unadjusted. Pool across donors (geometric mean, the
distributions are log-normal) before any species-level use. The paper's own summaries additionally
adjust MBP and NFL for warm time; this item does not.

## Species

`Homo sapiens`, harmonised through `_keys/General/species_key.csv`
(`source_publication = Sjölin_etal_2022`, NCBI taxid 9606, basis `verbatim`). The table prints no
species name — see HOWTO §5, single-species papers.

## Data role and merge

`primary` — the paper's own measurements. Wired into **`__merging_supplementary/`**
(`supplementary_sources.csv`, 102 mapping rows = 17 regions × 6 analytes), which the Shiny app /
Trait Explorer loads as the dataset **Supplementary sources**. Each region × analyte becomes one
app variable (`FrontalCortex_GFAP (µg/g)`, …) because the app's compiled database is keyed on
species × variable and cannot carry region as a second axis; the per-species value is the geometric
mean over donors. See `__merging_supplementary/README__merging.md` for the mapping decisions.

Because the dataset covers one species, these variables populate the app's compiled-database and
coverage views but cannot be used for a cross-species regression on their own.

## Provenance

Reader: AI assistant (Claude), 2026-10-28, from the journal-supplied `.xlsx` — no transcription
step, so the reader's work is the column mapping, the unit conversion and the checks above, all
reproducible by re-running the script. Registry descriptive columns prepared in
`Sjölin_etal_2022_SupplementaryData_registry_row.xlsx` for the owner to paste.
