# Holmes_etal_2024_SupplementaryTable2

**Item name** `Holmes_etal_2024_SupplementaryTable2` · **Item number** `Supplementary Table 2` ·
**Item encoded** (expected once registered) `10.1038%2Fs41531-024-00655-9_SupplementaryTable2`

Holmes, S. E., Honhar, P., Tinaz, S., Naganawa, M., Hilmer, A. T., Gallezot, J.-D., Dias, M., Yang, Y.,
Toyonaga, T., Esterlis, I., Mecca, A., Van Dyck, C., Henry, S., Ropchan, J., Nabulsi, N., Louis, E. D.,
Comley, R., Finnema, S. J., Carson, R. E., & Matuskey, D. (2024). Synaptic loss and its association with
symptom severity in Parkinson's disease. *npj Parkinson's Disease* 10, 42.
<https://doi.org/10.1038/s41531-024-00655-9>

**Item full original title:** Supplementary Table 2. *BP*ND values across HC and PD groups. Reported
values are Mean (SD).

## Healthy control group — read this first

This is a **disease paper**. Two groups are printed and both are kept, with the printed group labels:
**`HC group` = healthy controls (the control group; `is_healthy_control = 1`)**, n = 30, age 61.0 ± 8.8 y,
17 F : 13 M (main-text Table 1); and `PD group` = Parkinson's disease, n = 30. For healthy-brain use,
filter `is_healthy_control == 1`. Never pool HC with PD.

## What the data are

In vivo [11C]UCB-J PET (HRRT, Yale PET Center) as a surrogate of synaptic density (SV2A). Outcome **BPND**
(unitless) from SRTM2 with the **centrum semiovale (CSO)** as reference region and a fixed population k2′.
**26 regions × 2 groups = 52 BPND rows** in printed order, sectioned as printed into *Primary* (5 a priori
early-Braak ROIs) and *Secondary* (21 exploratory ROIs). Each row also carries the printed HC-vs-PD
p-value, % Difference, Cohen's d and the bold flag (bold = significant after Bonferroni correction; only
Caudate is bold).

**Plus 4 reference-region rows (CSO)** that the paper prints only in running text (Methods, "Quantitative
analysis of PET data", article p. 7, right column): the 1TCM volume of distribution **VT** (HC 4.1 ± 0.6,
PD 4.0 ± 0.6 mL/cm³, p = 0.30) and **K1** (HC 0.12 ± 0.017, PD 0.12 ± 0.016 mL min⁻¹ cm⁻³, p = 0.97), in
the arterial-sampling subset (26 HC, 18 PD). BPND of the CSO is 0 by definition; these VT/K1 rows give
the reference-region scale. Total **56 rows**.

Units are kept as printed (BPND unitless; VT mL/cm³; K1 mL/min/cm³). The project units (mm³, g, mg) do
not apply to these measures, and nothing is converted.

### Partial-volume correction differs by region

Müller-Gärtner PVC was applied to grey-matter-segmented **cortical regions, striatum (caudate, putamen,
ventral striatum) and cerebellum only** (Methods p. 8). Substantia nigra, brainstem, red nucleus,
thalamus, subthalamic, pallidum, amygdala, locus coeruleus and raphe are **not** PVC-corrected, so small
nuclei are biased low relative to the PVC'd regions. The per-region ROI source and PVC status are in
`reference_tables/Holmes_etal_2024_SupplementaryTable2_region_methods.csv` (join on
`region_as_published`). Parahippocampal and olfactory are marked "yes (inferred)" because they are AAL
cortical labels, but the paper does not list its cortical ROIs one by one.

Observation: main-text Fig. 1a bar heights (Caudate ≈ 2.6, Putamen ≈ 3.8) sit below the table's
4.18 / 5.73, while SN and red nucleus agree. This fits the figure showing uncorrected values for the
striatal ROIs that the table reports after PVC. It is not a table inconsistency and is not recorded as an
erratum.

## Pipeline

```
Source: 41531_2024_655_MOESM1_ESM.pdf (journal supplement, p. 2) + article PDF p. 7 (text)
  -> Holmes_etal_2024_SupplementaryTable2_snapshot.R   writes both frozen sources
  -> Holmes_etal_2024_SupplementaryTable2_snapshot.xlsx        FROZEN: 32 rows x 6 cols, sheet "SupplementaryTable2"
  -> Holmes_etal_2024_data_from_text_snapshot.csv               FROZEN: constructed snapshot of the Methods passage (4 rows)
  -> Holmes_etal_2024_SupplementaryTable2.R                     clean + reshape + table checks
  -> Holmes_etal_2024_SupplementaryTable2.csv                   56 rows x 20 cols ("use this")
  -> __Public/comparative-data/<Item encoded>.tsv               written only once the registry row exists
  -> reference_tables/Holmes_etal_2024_SupplementaryTable2_definitions.csv
  -> reference_tables/Holmes_etal_2024_SupplementaryTable2_region_methods.csv
  -> reference_tables/Holmes_etal_2024_species_key_proposed.csv
```

Build order: run the extract script once, which freezes the sources and refuses to overwrite a frozen
copy that differs, then the build script. Both run from a clean `Rscript` session (packages: pdftools,
openxlsx, readxl, readr).

## Who read the values, when, and how it was checked

The source is a **printed (PDF) table**, so the snapshot is a capture, not a copy-rename. The values were
read on **2026-11-11 by an AI assistant (Claude)** using `…_snapshot.R`. That script takes the
values from the supplement's text layer with `pdftools::pdf_data`, using word positions and font names.
Column boundaries are derived from the printed header words, and the anchors (caption, header and
footnote) are printed literals. **No table value is typed in any script.** The bold row is detected from
the font name (`TimesNewRomanPS-BoldMT`) and written as bold in the xlsx; the build reads it back from the
cell styles. The Methods passage is captured by regex from the article's p. 7 text layer, reading the
two columns in order with sub- and superscript glyphs removed. Its unit strings are anchored printed
literals.

Checks:

1. **Page image.** The supplement p. 2 was rendered at 200 dpi and read row by row against the snapshot:
   all 26 rows × 5 value columns, the italic section rows, and the bold Caudate row agree. The article
   p. 7 passage was rendered at 170 dpi and every VT/K1 value, n, p and unit agrees.
2. **Table checks** (see below): 52/52 pass.
3. **Independent cross-check.** An earlier-session staged extraction (`s1c_synaptic_density_extracted_values.csv`)
   holds the 26 HC BPND means and SDs plus the HC CSO VT and K1: **28/28 agree** with this build. That
   file was a cross-check only; the PDF was the authority.

Owner/RA visual check of the snapshot is still pending (registry column *Human visual check of snapshot*).

### Structure of the snapshot

Row 1 caption (the ND subscript is written inline as `BPND`); rows 2–3 the two-line column headers
(`HC group` / `(n=30)`, …, `%` / `Difference`, `Cohen’s d` / `magnitude`); row 4 *Primary*; rows 5–9;
row 10 *Secondary*; rows 11–31; row 32 the footnote. Cells keep the printed `mean (SD)` strings.

## Table checks

The table prints two quantities derived from its own means and SDs. The reader recomputes both and
checks them in `table_checks`, using interval arithmetic: every printed mean/SD is ±0.005, and the
printed result is ± half a unit of its own last decimal.

- `% Difference = 100 (PD − HC) / HC` — **26/26 pass**.
- `Cohen's d = |HC − PD| / sqrt((SD_HC² + SD_PD²)/2)` (equal n = 30) — **26/26 pass**.

Result from an actual R run (2026-11-11): pass = 52, mismatch = 0, not_evaluable = 0.

## Not built from this paper

- **Main-text Tables 1–2** hold demographics only (no regional values). Their healthy-control facts are
  quoted above.
- **Supplementary Table 3** (HC vs the 'longer illness' >6 y PD subgroup) repeats the same HC column.
  It was not built in this pass; it could be built as a sibling item for its PD-subgroup values.
- **Supplementary Tables 4–5** (R1, relative delivery ≈ relative perfusion) were not built in this pass.
  They are candidates for a perfusion track.

## Species

Single species, *Homo sapiens*. No species is printed in the table; `species_as_published` carries
`Homo sapiens` from the title/Methods. The proposed key row is in
`reference_tables/Holmes_etal_2024_species_key_proposed.csv` (collection *General*); it has not been added
to `_keys/General/species_key.csv`.

## Registration

The item is **not yet registered**. The build writes the CSV and prints `not yet registered - TSV skipped`
until the owner pastes `Holmes_etal_2024_SupplementaryTable2_registry_row.xlsx` into `__ReadMe.xlsx` and
runs `_tools/file_list.R`. After that, the next build writes the public TSV.

## Errata

None recorded. All table checks pass and no printed value was found inconsistent, so there is no
`reference_tables/Holmes_etal_2024_errata.csv`.

## Workbook repair (2026-11-27)

Repaired the worksheet dimension (A1:F32) and removed two dangling drawing links. The table cells, source order, and six printed columns are unchanged and match Supplementary Table 2 on page 2 of the local PDF. `openpyxl` normal and read-only modes now both open the workbook and report 32 × 6. The analysis CSV hash remains `197144af5b0589d92df2b97b2221a367bdd572a1ac6052d035215fa4684620d2`. This does not record human visual signoff.
