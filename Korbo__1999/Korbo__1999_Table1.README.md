# Korbo__1999_Table1

**Item name** `Korbo__1999_Table1` · **Item number** `Table 1` · **Item encoded** pending registration
(expected `10.1111%2Fj.1530-0277.1999.tb04039.x_Table1`)

Korbo, L. (1999). Glial cell loss in the hippocampus of alcoholics. *Alcoholism: Clinical and Experimental Research*, 23(1), 164–168. <https://doi.org/10.1111/j.1530-0277.1999.tb04039.x>

**Item full original title:** Table 1. *Mean Total Number of Neurons (10⁶) in Five Subregions of
Hippocampus in Alcoholics and Controls* (p. 166, PDF page 3).

## Source

Scanned journal PDF (Wiley download; text layer is OCR and interleaves the two columns with the
tables). Values were read from the page images and checked against the text layer where legible.
The supplied file is named `Korbo-2006-Glial Cell Loss in the Hippocampus.pdf`, but the article is
the **1999** paper (masthead: *Alcohol Clin Exp Res* Vol. 23, No. 1, January 1999, pp. 164–168;
download watermark DOI 10.1111/j.1530-0277.1999.tb04039.x). **Single author (Lise Korbo)**, hence
the folder `Korbo__1999`. Copied into this folder with its original filename.

**Groups.** `Controls` / `control group` = **healthy control group**: 5 males, 34–56 y (mean 44), no
history of mental or neurological disease or alcohol abuse; causes of death acute myocardial
infarction, aneurysm of the aorta, one "had been killed", pulmonary embolism. `Alcoholics` = 5 male alcoholics,
36–53 y (mean 44), no Wernicke–Korsakoff syndrome, 4 with liver cirrhosis. **Left hippocampus only.**
Optical fractionator, 70 µm glycolmethacrylate sections, modified Giemsa; z-shrinkage 2–3% (negligible).

## Pipeline

```
Source (scanned PDF p. 166)
  -> Korbo__1999_Table1_snapshot.csv   FROZEN: hand transcription in the printed layout
  -> Korbo__1999_Table1.R              clean + reshape + table check
  -> Korbo__1999_Table1.csv            12 rows = 6 subregion rows x 2 printed groups ("use this")
  -> __Public/comparative-data/<Item encoded>.tsv   (written once registered)
  -> reference_tables/Korbo__1999_Table1_definitions.csv
```

The CSV keeps **both printed groups** (`group_as_printed` = `Controls` / `Alcoholics`, verbatim);
`is_healthy_control = 1` marks the **Controls** rows — use only those as healthy reference values.

## Who read the values, when, and how it was checked

Transcribed by an **AI assistant (Claude) on 2026-11-11** from a 500-dpi render of p. 166, typed
into the frozen CSV (no values in the build script); cross-read against the OCR text layer and the
staged extraction `s1a_stereology_extracted_values.csv` (all 6 staged control values present).

Snapshot structure: row 1 caption (`(10^6)`), row 2 header (blank stub, `Controls`, `Alcoholics`),
rows 3–8 the six printed rows, row 9 the legend.

## Table checks

Total hippocampus = sum of the five subregions, per group (tolerance: half-units of the summands +
half a unit of the total). **Actual R run 2026-11-11: 2 pass, 0 mismatch** — Controls 40.3 vs printed
40.2 (tolerance 0.3); Alcoholics 38.0 vs 38.0.

## Caveats

Neurons were counted in the principal cell layers only; glia (see `Korbo__1999_Text`) over a larger
territory that includes the molecular layers / strata. No volumes are reported, so no densities.

## Data role

**Proposed: `primary`**.

## Species names

The paper prints no binomial; the species is `human` (title/text), kept verbatim in
`species_as_published`. No `_keys/` file was edited. A proposed row (`human` → *Homo sapiens*,
NCBI 9606, collection General) is in `reference_tables/Korbo__1999_species_key_proposed.csv`; adopt it
into `_keys/General/species_key.csv` before this item enters a species-resolving merge. The
counting method should also be recorded in `_keys/cell_count_methods/source_methods.csv`
(proposed: `STEREO_DISECTOR` — optical fractionator, target `cell_counts_histology`) — not done here (no `_keys/` edits).

## Registration

Not yet in `__ReadMe.xlsx`. The proposed Sheet1 row is `Korbo__1999_Table1_registry_row.xlsx` in this folder
(see its HOW_TO_PASTE sheet). Until the owner pastes it and runs `_tools/file_list.R`, the build
writes the CSV only and prints `not yet registered - TSV skipped`; once `Item encoded` resolves,
the same script writes `__Public/comparative-data/<Item encoded>.tsv`.

## Human visual check of snapshot

Pending. An AI assistant transcribed and checked the snapshot against the page images. A human
still needs to read a few rows **across** beside the page (including mid-table rows) and record
`DDMMYYYY_initials` in the `Human visual check of snapshot` column.
