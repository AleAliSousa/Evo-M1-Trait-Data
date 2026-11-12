# Karlsen_etal_2014_Table1

**Item name** `Karlsen_etal_2014_Table1` · **Item number** `Table 1` · **Item encoded** *not yet registered* — paste
`Karlsen_etal_2014_Table1_registry_row.xlsx` into `__ReadMe.xlsx` Sheet1, run `_tools/file_list.R`, then re-run the build to
write the public TSV (the build prints `not yet registered - TSV skipped` until then).

Karlsen, A. S., Korbo, S., Uylings, H. B. M., & Pakkenberg, B. (2014). A stereological study of the mediodorsal thalamic nucleus in Down syndrome. *Neuroscience*, 279, 253–259. <https://doi.org/10.1016/j.neuroscience.2014.08.046>

**Item full original title:** Table 1. Clinical details of the individual subjects (journal p. 254)

## What the data are

Individual subjects: 6 female controls and 4 females with DS. Columns: age, height, fixed hemisphere weight,
country, cause of death, post-mortem delay, and Braak score (DS only), plus the two printed **Mean** rows. That
gives **12 analysis rows**; use `row_type == "individual"` for subject-level work. Per-subject cell counts are not
published (Fig. 3 plots them; not digitised).

## Pipeline

```
PDF p. 2 -> Karlsen_etal_2014_Table1_snapshot.R -> Karlsen_etal_2014_Table1_snapshot.xlsx
         (FROZEN: 18 rows x 8 cols, sheet "Table1"; the "Braak score" sub-header row kept)
  -> Karlsen_etal_2014_Table1.R -> Karlsen_etal_2014_Table1.csv (12 rows)
  -> reference_tables/Karlsen_etal_2014_Table1_definitions.csv
```

## Groups (disease paper)

`Group` is kept exactly as printed. **`Controls` is the healthy control group**: six female controls
(5 acute myocardial infarction, 1 congestive heart failure; no neurodegenerative signs), `is_healthy_control = 1`.
`DS` = four females with Down syndrome (The Netherlands Brain Bank). **Overlap:** comparing the printed
individual rows with Karlsen & Pakkenberg 2011 Table 1, 3 controls match exactly (74/160/469/AMI/48:00,
60/161/377/AMI/48:00, 70/169/482/AMI/04:00). A fourth (64/154/AMI/24:00) matches except that K11 leaves the
weight blank. One shares only the hemisphere weight (389 g), and one (75/159/575) is new. Salvesen et al. 2015
also reuses some of these controls. The DS brains are the K11 DS brains, except that K11's 70-year-old US case is
replaced by an 80-year-old NED case.

## Table checks

Each printed Mean was re-computed from the printed individuals. Dashes were left out, never counted as zero.
**R run 2026-11-11: 4 pass, 2 mismatch.**

| check | printed | from individuals |
|---|---|---|
| DS mean height | 159.7 | 155.0 (148, 162; two dashes) |
| DS mean hemisphere | 252.5 | 278.75 (244, 395, 231, 245) |

Both DS means are **copied from the DS Mean row of Karlsen & Pakkenberg 2011 Table 1**, which had a different
DS set (errata E001, E002). In addition, the 2014 DS PMD column reproduces the 2011 PMD column position by
position, while the subjects changed. For two DS brains present in both papers, the PMD therefore disagrees
(errata E003–E005). All printed values are kept.

## Who read the values, when, and how it was checked

Born-digital Elsevier PDF with a clean text layer. **Extracted by `Karlsen_etal_2014_Table1_snapshot.R`**
(AI assistant, Claude, 2026-11-11) with `pdftools::pdf_text`: anchored structural literals, regex captures of
every value, and **no value typed in any script**. Text-layer glyph repairs, each confirmed on the page image:
flattened unit superscripts (`(mm3)` → `(mm³)`, `(106)` → `(10⁶)`) and ligatures expanded. Superscript
footnote asterisks are written `^*`, `^**`, `^***`. The Table 2 footnote formula is garbled in the text layer, so
its words are anchored and the formula itself is typed as printed (a structural literal, not a value). The extract script refuses to
overwrite a frozen snapshot that differs and writes `*_NEW` instead.

Every cell of the frozen snapshot was then **read against 300-dpi renders of the page** (PDF p. 2 Table 1,
p. 4 Table 2; Karlsen & Pakkenberg 2011 Table 1 at p. 2520 for the cross-source errata), reading **across rows**. No disagreement was found.
Cross-check: the earlier staged extraction (`s1a_stereology_extracted_values.csv`, controls only) agrees with
this item for every comparable value and CV. 7 Karlsen values (control volume and six cell numbers, with CVs) were compared and 0 differ; staged rows marked
DERIVED or "not reported" were not compared.

Note: OneDrive rewrites `.xlsx` files on sync (adds `customXml/` and `[trash]/` parts). Cell content is
unchanged; the extract script's guard compares cell content via `readxl` and still reports the frozen copy
as unchanged.

The **human visual check** of the snapshot is still pending (registry column AL).

## Species

Single-species human study. The tables print no species name, so `species_as_published = "human"` (from
Methods) and `Species = "Homo sapiens"`. No species key was edited. A proposed row is in
`reference_tables/Karlsen_etal_2014_species_key_proposed.csv`, for `_keys/General/species_key.csv`.

## Data role

**Proposed: `primary`.** These are the authors' own stereological measurements (registry row file).


<!-- errata:begin -->
## Errata

Generated from `reference_tables/Karlsen_etal_2014_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| Karlsen_etal_2014-E001 | height.cm | Table 1, p. 254, DS Mean row, column Height (cm) | 159.7 |  | publication_error | 155.0 | proposed | The DS rows print heights -, -, 148, 162; mean of the two printed values = 155.0. 159.7 is also printed as the DS Mean height in Karlsen & Pakkenberg 2011 Table 1 (p. 2520), where it is equally inconsistent with that paper's DS heights (148, 162) and equals that paper's CONTROL mean height ((162+160+154+161+152+169)/6 = 159.67). Both tables re-read on page renders. | CSV keeps 159.7 on the printed_mean row. Detected by table_checks (mean_DS_height). Use the individual rows. |
| Karlsen_etal_2014-E002 | hemisphere_weight.g | Table 1, p. 254, DS Mean row, column Hemisphere (g) | 252.5 |  | publication_error | 278.75 | proposed | The DS rows print 244, 395, 231, 245; mean = 278.75. 252.5 is the DS Mean of Karlsen & Pakkenberg 2011 Table 1, whose DS set was 244, 231, 245, 290 (mean 252.5) and included a US case (70 y, 290 g) that is replaced here by an 80-year-old NED case (395 g). The 2014 DS Mean age (68.8) WAS recomputed for the new set; height and hemisphere were not. | CSV keeps 252.5 on the printed_mean row. Detected by table_checks (mean_DS_hemisphere). |
| Karlsen_etal_2014-E003 | PMD.h | Table 1, p. 254, DS row 3 (64 y, 148 cm, 231 g, NED, Pneumonia), column PMD (h) | 09:00 |  | cross_source_disagreement |  | proposed | Karlsen & Pakkenberg 2011 Table 1 (p. 2520) prints the same DS brain (64 y, 148 cm, 231 g, NED, Pneumonia) with PMD 04:00. The 2014 DS PMD column (05:30, 04:00, 09:00, 06:00) is the 2011 DS PMD column in the same order, while the 2011 70-y US case was replaced by an 80-y NED case in row 2; PMDs appear to have stayed in place while rows changed. | Which value is right cannot be decided from the papers. CSV keeps the printed 09:00. |
| Karlsen_etal_2014-E004 | PMD.h | Table 1, p. 254, DS row 4 (70 y, 162 cm, 245 g, NED, Ileus), column PMD (h) | 06:00 |  | cross_source_disagreement |  | proposed | Karlsen & Pakkenberg 2011 Table 1 (p. 2520) prints the same DS brain (70 y, 162 cm, 245 g, NED, Ileus) with PMD 09:00. See E003 for the shifted-column pattern. | CSV keeps the printed 06:00. |
| Karlsen_etal_2014-E005 | PMD.h | Table 1, p. 254, DS row 2 (80 y, -, 395 g, NED, AMI / pneumonia), column PMD (h) | 04:00 |  | publication_ambiguity |  | proposed | This case is not in Karlsen & Pakkenberg 2011; its printed PMD 04:00 equals the PMD the 2011 table gives to the DS row in the same position (64 y, 231 g). Given E003/E004 the value may not belong to this subject. | CSV keeps the printed 04:00. |

5 recorded, 5 open (proposed), 0 confirmed, 0 withdrawn.
<!-- errata:end -->
