# Salvesen_etal_2015_Table4

**Item name** `Salvesen_etal_2015_Table4` · **Item number** `Table 4` · **Item encoded** *not yet registered* — paste
`Salvesen_etal_2015_Table4_registry_row.xlsx` into `__ReadMe.xlsx` Sheet1, run `_tools/file_list.R`, then re-run the build to
write the public TSV (the build prints `not yet registered - TSV skipped` until then).

Salvesen, L., Ullerup, B. H., Sunay, F. B., Brudek, T., Løkkegaard, A., Agander, T. K., Winge, K., & Pakkenberg, B. (2015). Changes in total cell numbers of the basal ganglia in patients with multiple system atrophy — a stereological study. *Neurobiology of Disease*, 74, 104–113. <https://doi.org/10.1016/j.nbd.2014.11.008>

**Item full original title:** Numerical estimations of the different cell types in the basal ganglia and red nucleus of patients with MSA and control subjects. (journal p. 108)

## What the data are

Group means (with CV, p-value and percent change) of **total cell numbers** and **numerical densities**
(cells/mm³) of neurons, oligodendrocytes, astrocytes and microglia in six human nuclei: substantia nigra
(SN; pigmented neurons only, no glia), putamen (PU), caudate nucleus (CN), globus pallidus (GP), subthalamic
nucleus (STN), red nucleus (RN). There are 42 printed rows (21 per section) × 2 groups, giving **84 analysis rows**.
`n_subjects` comes from Table 1 (11 per group for PU/CN/GP; 10 for SN/STN/RN). Regional **volumes** are not in
this table: see sibling item `Salvesen_etal_2015_text`.

Precision caveat (authors, p. 108): CE exceeded CV/2 for **microglia in general** and for **MSA red-nucleus
astrocytes**. These rows are flagged in `note`.

## Pipeline

```
Salvesen-2015-Changes in total cell numbers of.pdf  (born-digital; text layer clean)
  -> Salvesen_etal_2015_Table4_snapshot.R       writes the frozen snapshots (no values typed)
  -> Salvesen_etal_2015_Table4_snapshot.xlsx     FROZEN: 50 rows x 8 cols, sheet "Table4", printed layout
  -> Salvesen_etal_2015_Table4.R                 clean + parse + table checks (also reads the Table 1 snapshot for n)
  -> Salvesen_etal_2015_Table4.csv               84 rows ("use this")
  -> __Public/comparative-data/<Item encoded>.tsv   (written once registered)
  -> reference_tables/Salvesen_etal_2015_Table4_definitions.csv
```

Units: totals in **cells** (printed ×10⁶) and densities in **cells per mm³** (printed ×10³);
`value = value_mantissa × value_multiplier`. The printed strings are kept in `value_as_printed`.

## Groups (disease paper)

`Group` is kept exactly as printed. **`Controls` is the healthy control group**: neurologically healthy
subjects (10 died of acute myocardial infarction, 1 of an aortic aneurysm), `is_healthy_control = 1`.
`MSA` = multiple system atrophy (8 parkinsonian, 3 cerebellar subtype). The paper states that several control
brains were also used in Karlsen et al. 2014 and Karlsen & Pakkenberg 2011, so these are **not independent**
of those items' controls.

## Shrinkage and hemispheres

* **Volumes: NOT shrinkage-corrected.** The Cavalieri reference volume is "uncorrected for shrinkage"
  (Methods p. 105). The Results give the volumes as paraffin-embedded tissue. Contrast Karlsen & Pakkenberg 2011,
  whose published *volumes* are shrinkage-corrected (mean 46.7%) while its densities use the paraffin volume.
* **Densities (Nv)** are per mm³ of paraffin-embedded (shrunken) tissue. **Totals (N)** = Nv × uncorrected V,
  which makes them shrinkage-independent.
* **Bilateral:** one hemisphere counted, multiplied by 2 (Methods p. 105; Results "estimated bilateral quantities").

## Glial classification vs Karlsen & Pakkenberg 2011

**Matches.** Same lab and protocol as Karlsen & Pakkenberg 2011 (`Karlsen_Pakkenberg_2011/`): Giemsa-stained
40-µm paraffin sections, optical disector Nv × Cavalieri reference volume (uncorrected for shrinkage) × 2, and
cell types by morphology **citing the same source, Pelvig et al. (2008)**, with the same descriptors:

| class | Karlsen & Pakkenberg 2011 (Methods) | Salvesen et al. 2015 (Methods p. 105–106) |
|---|---|---|
| neurons | larger nuclei, darkly stained nucleoli, visible cytoplasm | large nuclei with a single dark nucleolus, visible cytoplasm |
| oligodendrocytes | small, round, dense heterochromatin, no visible cytoplasm | small, round, dark nuclei; often grouped near neurons/vessels |
| astrocytes | paler, heterochromatin in granules, sharp nuclear membrane | round pale nuclei, granulated heterochromatin, visible nuclear membrane |
| microglia | elongated/comma-shaped nuclei, dense peripheral chromatin | comma-shaped nuclei, visibly smaller than other types |

Salvesen adds GFAP and NeuN immunolabelling of striatal samples from control and MSA brains, reported to
corroborate the morphological identification (p. 106). Total glia is not printed; summing the three subtypes reproduces a K11-comparable total.
Differences in **regions** (subcortical nuclei here vs neocortex/basal ganglia in K11), not in criteria.

## Table checks

Percent change = 100 × (MSA − Controls)/Controls was re-computed for each of the 24 rows that print one.
The tolerance is the full interval the two rounded means can produce (± half a unit in each mean's last
decimal), plus half a unit of the whole-number percentage. **R run 2026-11-11: 22 pass, 2 mismatch.**

| check | printed | from the printed means | admissible |
|---|---|---|---|
| Total cell numbers, Microglia, GP | 145%↑ | +83.3% | 75.7–91.4% |
| Density/mm³, Astrocytes, GP | 46%↑ | +31.1% | 30.5–31.7% (the row's MSA CV prints 0.46) |

Both cells were re-read on the page render, so these are publication slips. **The printed values are kept**;
see errata E001 and E002. Also (not a printed relation): Table 4 control N/Nv implies 4868, 3323, 1941, 112.5
and 175.9 mm³ for PU, CN, GP, STN and RN, against 4900, 3300, 1900, 114.4 and 193.2 mm³ in the text item. That
agreement supports reading the text volumes as bilateral.

## Who read the values, when, and how it was checked

Born-digital Elsevier PDF with a clean text layer. **Extracted by `Salvesen_etal_2015_Table4_snapshot.R`**
(AI assistant, Claude, 2026-11-11) with `pdftools::pdf_text`: anchored structural literals, regex captures of
every value, and **no value typed in any script**. Text-layer glyph repairs, each confirmed on the page image:
flattened exponents (`× 106` → `× 10⁶`, `× 103` → `× 10³`), `b0.001` → `<0.001`, `mm3` → `mm³` in the section
heading, and ligatures expanded. Superscript footnote letters are written `^a`. The extract script refuses to
overwrite a frozen snapshot that differs and writes `*_NEW` instead.

Every cell of the frozen snapshot was then **read against 300-dpi renders of the page** (PDF p. 2 Table 1;
p. 5 Table 4, in two zoomed halves; p. 7 Results text), reading **across rows**, with the first and last rows
of each block and the rows beside the blank gap checked in particular. No disagreement was found.
Cross-check: the earlier staged extraction (`s1a_stereology_extracted_values.csv`, controls only) agrees with
this item for every comparable value and CV. 47 Salvesen values were compared and 0 differ; staged rows marked
DERIVED or "not reported" were not compared.

Note: OneDrive rewrites `.xlsx` files on sync (adds `customXml/` and `[trash]/` parts). Cell content is
unchanged; the extract script's guard compares cell content via `readxl` and still reports the frozen copy
as unchanged.

The **human visual check** of the snapshot is still pending (registry column AL).

## Species

Single-species human study. The tables print no species name, so `species_as_published = "human"` (from
Methods) and `Species = "Homo sapiens"`. No species key was edited. A proposed row is in
`reference_tables/Salvesen_etal_2015_species_key_proposed.csv`, for `_keys/General/species_key.csv`.

## Data role

**Proposed: `primary`.** These are the authors' own stereological measurements (registry row file).

## Not built

Table 2 (MSA clinical characteristics; no control or region data) and Table 3 (qRT-PCR primers). The online
Supplementary material (per-region sampling scheme and CE values) is not in the PDF and was not available here.


<!-- errata:begin -->
## Errata

Generated from `reference_tables/Salvesen_etal_2015_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| Salvesen_etal_2015-E001 | percent_change_MSA_vs_Controls | Table 4, p. 108, Total cell numbers, Microglia, row GP (snapshot row 23), column Percent change | 145%↑ |  | publication_error | 83 | proposed | Same printed row: Controls 1.8 x 10^6, MSA 3.3 x 10^6; 100 x (3.3 - 1.8)/1.8 = 83.3%. Rounding of the two printed means admits only 75.7-91.4%, so 145% cannot come from these means. All three cells re-read on the 300-dpi page render (PDF p. 5). The other 22 of 24 printed percent changes reproduce. | CSV keeps the printed 145. Detected by table_checks (percent_change_row23_Microglia_GP_N). Possibly a slip from another row/statistic; cannot be adjudicated from the paper. |
| Salvesen_etal_2015-E002 | percent_change_MSA_vs_Controls | Table 4, p. 108, Density/mm3, Astrocytes, row GP (snapshot row 41), column Percent change | 46%↑ |  | publication_error | 31 | proposed | Same printed row: Controls 19.3 x 10^3, MSA 25.3 x 10^3; 100 x (25.3 - 19.3)/19.3 = 31.1% (admissible from rounding: 30.5-31.7%). The printed 46 equals the MSA CV printed in the same row (0.46), suggesting a copy slip. Cells re-read on the 300-dpi render (PDF p. 5). | CSV keeps the printed 46. Detected by table_checks (percent_change_row41_Astrocytes_GP_Nv). |

2 recorded, 2 open (proposed), 0 confirmed, 0 withdrawn.
<!-- errata:end -->
