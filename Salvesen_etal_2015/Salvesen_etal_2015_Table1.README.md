# Salvesen_etal_2015_Table1

**Item name** `Salvesen_etal_2015_Table1` · **Item number** `Table 1` · **Item encoded** *not yet registered* — paste
`Salvesen_etal_2015_Table1_registry_row.xlsx` into `__ReadMe.xlsx` Sheet1, run `_tools/file_list.R`, then re-run the build to
write the public TSV (the build prints `not yet registered - TSV skipped` until then).

Salvesen, L., Ullerup, B. H., Sunay, F. B., Brudek, T., Løkkegaard, A., Agander, T. K., Winge, K., & Pakkenberg, B. (2015). Changes in total cell numbers of the basal ganglia in patients with multiple system atrophy — a stereological study. *Neurobiology of Disease*, 74, 104–113. <https://doi.org/10.1016/j.nbd.2014.11.008>

**Item full original title:** Demographic and autopsy-related data.^a (journal p. 105)

## What the data are

One analysis row per printed column (**6 rows**): the two stereology sets (PU/CN/GP: Controls n = 11, MSA n = 11;
SN/STN/RN: Controls n = 10, MSA n = 10) and the separate qRT-PCR tissue set (Controls n = 14, MSA n = 10).
For each: age mean [range], male/female, post-mortem interval mean [range], left/right hemisphere and fixed
hemisphere weight mean [range] (g). Footnote a: some samples were omitted from some assessments for
technical artifacts or lack of tissue. This table is the source of the `n_subjects` used by
`Salvesen_etal_2015_Table4` and `Salvesen_etal_2015_text`.

## Pipeline

```
PDF p. 2 -> Salvesen_etal_2015_Table1_snapshot.R -> Salvesen_etal_2015_Table1_snapshot.xlsx
         (FROZEN: 13 rows x 7 cols, sheet "Table1"; spanner cells hold the three printed lines joined by newlines)
  -> Salvesen_etal_2015_Table1.R -> Salvesen_etal_2015_Table1.csv (6 rows)
  -> reference_tables/Salvesen_etal_2015_Table1_definitions.csv
```

## Groups (disease paper)

`Group` is kept exactly as printed. **`Controls` is the healthy control group**: neurologically healthy
subjects (10 died of acute myocardial infarction, 1 of an aortic aneurysm), `is_healthy_control = 1`.
`MSA` = multiple system atrophy (8 parkinsonian, 3 cerebellar subtype). The paper states that several control
brains were also used in Karlsen et al. 2014 and Karlsen & Pakkenberg 2011, so these are **not independent**
of those items' controls.

## Table checks

n = male + female and n = left + right were checked for every column. **R run 2026-11-11: 10 pass,
0 mismatch, 2 not evaluable** (the qRT-PCR hemisphere cells print NA).

## Who read the values, when, and how it was checked

Born-digital Elsevier PDF with a clean text layer. **Extracted by `Salvesen_etal_2015_Table1_snapshot.R`**
(AI assistant, Claude, 2026-11-11) with `pdftools::pdf_text`: anchored structural literals, regex captures of
every value, and **no value typed in any script**. Text-layer glyph repairs, each confirmed on the page image:
flattened exponents (`× 106` → `× 10⁶`, `× 103` → `× 10³`), `b0.001` → `<0.001`, `mm3` → `mm³` in the section
heading, and ligatures expanded. Superscript footnote letters are written `^a`. The extract script refuses to
overwrite a frozen snapshot that differs and writes `*_NEW` instead.

Every cell of the frozen snapshot was then **read against 300-dpi renders of the page** (PDF p. 2 Table 1;
p. 5 Table 4, in two zoomed halves; p. 7 Results text), reading **across rows**. No disagreement was found.
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


<!-- errata:begin -->
<!-- errata:end -->
