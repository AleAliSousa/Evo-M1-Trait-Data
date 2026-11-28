# Wegiel_etal_2014_Table1

**Item name** `Wegiel_etal_2014_Table1` · **Item number** `Table 1` · **Item encoded** not yet registered (paste
`Wegiel_etal_2014_Table1_registry_row.xlsx` into `__ReadMe.xlsx` Sheet1, then run `_tools/file_list.R`)

Wegiel, J., Flory, M., Kuchna, I., Nowicki, K., Ma, S. Y., Imaki, H., Wegiel, J., Cohen, I. L., London, E.,
Wisniewski, T., & Brown, W. T. (2014). Stereological study of the neuronal number and volume of 38 brain
subdivisions of subjects diagnosed with autism reveals significant alterations restricted to the striatum,
amygdala and cerebellum. *Acta Neuropathologica Communications* 2, 141.
<https://doi.org/10.1186/s40478-014-0141-7> (open access; PMC4177256; PMID 25231243)

**Item full original title:** Table 1 Parameters and procedures applied to estimate the volume of brain subdivisions and number of neurons

## This Table 1 is NOT a subject table

The paper's **Table 1 is the stereology-parameters table**. For each structure it gives the sections examined,
the objective lenses, the fractionator grid, the counting frame and disector height, the counting spaces and
neurons counted per case, and the CE. **The paper prints no subject or demographic table**; it refers to its
ref. [35] (Wegiel et al. 2014, *Acta Neuropathol Comm* 2:28) for demographics. The cohort facts printed in the
text are captured instead in `reference_tables/Wegiel_etal_2014_cohort_data_from_text.csv` (34 facts, with page,
section and a verbatim phrase).

## What the data are

**22 rows**, one per printed structure row. The printed group row `Entorhinal c.` is not an analysis row: it
becomes `structure_group_as_published` for the four layer rows under it (LII, LIII, LV, LVI). The parameters are
**per case and common to both groups** (`applies_to_groups = "Autism and Control"`). This item is methods
metadata for `Wegiel_etal_2014_Table2` and `Wegiel_etal_2014_Table3`. It holds no trait values.

Printed cells are split as follows:

* `1000 × 1000` becomes grid x and y (µm), and `80 × 80 × 10` becomes counting-frame x, y and height (µm);
  the printed cells are kept verbatim alongside.
* The `x` is dropped from objective magnifications.
* `1,418` becomes 1418.
* **Blank CE cells stay blank.** The printed CE seems to be given once per block (EC layers, CA sectors,
  striatum). The Methods text attests the blank LV and Globus pallidus cells (errata E003 and E004); the other
  blanks are left as printed.

## Cohort, groups and the healthy control

* **Groups as printed:** `Autism` (14 subjects diagnosed with autism, ADI-R confirmed postmortem) and
  `Control` (14 age-matched control subjects). **The healthy control group is `Control`**
  (`is_healthy_control = 1`). `Autism` is the disease group; it is kept in the CSV because the table prints it,
  but it is not a healthy reference and should not enter healthy-human merges.
* **Age range:** autism 4–60 years (Abstract; Results p. 10); controls 4–64 years (Discussion pp. 12, 14).
  The three oldest subjects in each group are 52–60 (autism) and 51–64 (control) years old (p. 10). Sex is not
  reported in this paper. Demographics per subject are only in the authors' ref. [35] (Wegiel et al. 2014,
  *Acta Neuropathol Comm* 2:28). **The paper prints no subject table.**
* Cohort facts printed only in the text (n assigned/excluded, PMI ranges, mean brain weight, fixation and
  dehydration days, shrinkage, clinical features, cerebellar exclusions) are in
  `reference_tables/Wegiel_etal_2014_cohort_data_from_text.csv`, one row per fact with page, section and a
  verbatim phrase that the extraction asserted present in the PDF text layer.
* **Cerebellar rows, autism group:** two autism brains were excluded from all cerebellar volume and neuron
  estimates, and a further 60-year-old case with cerebellar hypoplasia was excluded from the statistical
  analysis (Results p. 8); p. 10 refers to "12 examined subjects in the affected group". The n behind those
  means is not printed; the CSV `note` column flags these rows.

## Unilateral sampling

All values are for **one brain hemisphere**. Table 2's caption says "in one brain hemisphere", and Table 3's says
"in examined brain hemisphere". The Methods describe fixing and embedding "the brain hemisphere". **The paper does
not say which side.** Values are **not doubled** here, so any whole-brain use has to make that choice explicitly.
The Discussion (p. 12) doubles the Purkinje-cell number itself ("24.2 million calculated for entire cerebellum"
in autism, against 32.0 million in controls), but that figure is not part of the tables.

## Source → Snapshot → Data readable  (printed PDF → snapshot required)

```
Wegiel-2014-Stereological study of the neurona.pdf  (Table 1, p. 6)
  -> Wegiel_etal_2014_Table1_snapshot.R   writes the frozen snapshot
  -> Wegiel_etal_2014_Table1_snapshot.xlsx        FROZEN: 29 rows x 9 cols, sheet "Table1"
                                                  (caption; header row; 23 printed body rows incl. the
                                                   'Entorhinal c.' group row and blank CE cells; 4 footnotes)
  -> Wegiel_etal_2014_Table1.R                    parse
  -> Wegiel_etal_2014_Table1.csv                  22 rows x 21 cols ("use this")
  -> __Public/comparative-data/<Item encoded>.tsv  written only once the item is registered
  -> reference_tables/Wegiel_etal_2014_Table1_definitions.csv
```

## Who read the values, when, and how they were checked

The values were extracted by an **AI assistant (Claude) on 2026-11-11** from the PDF's **text layer**. The
journal PDF is born-digital BMC typesetting, and its layout-preserving text layer is clean for these tables.
The publisher offers **no machine-readable table or supplementary file**: the PMC JATS XML has no
`supplementary-material`, so the printed PDF is the source, and a snapshot is required.
`Wegiel_etal_2014_Table1_snapshot.R` reads the page with `pdftools::pdf_text`. It anchors only the printed header
literals, which it also checks against the page text, and splits each printed row into its printed cells. It
then freezes `Wegiel_etal_2014_Table1_snapshot.xlsx`, and **refuses to overwrite a frozen copy that differs**. Re-running it
reports "unchanged". The build script reads that frozen file and contains no table values.

Checks applied:

1. **Visual, row by row:** each snapshot row was read across against a 300-dpi render of the printed page
   (p. 6), including rows from the middle of the table and the rows on either side of every subdivision block.
   No shift, swap or misread was found.
2. **Row-count identity with the caption:** 23 printed body rows (22 structures + 1 group row). The two-line label "Magnocellular basal complex (Ch1-Ch4)" is one printed row. The extract script asserts the count.
3. **Cross-check against an earlier, independent staged extraction** (the control-group values of Tables 2
   and 3, `vbf0353d5_s1a_stereology_extracted_values.csv`): not applicable (the staged extraction did not cover Table 1).
4. **The table's own arithmetic** (see *Table checks*).

A human RA still needs to do the side-by-side check and record `DDMMYYYY_initials` in the
`Human visual check of snapshot` column of `__ReadMe.xlsx`.

## Table checks

The table prints no totals or other arithmetic relation, so nothing is checked. The counting spaces stated in
the Methods text (62 for EC LV, 1953 for Globus pallidus) agree with the printed cells.

## Data role

**Proposed: `primary`** (methods metadata, i.e. the authors' own sampling design). Not for any merge.

## Species

This is a single-species (human) study. The tables never print a species name, so `Species` and
`species_as_published` are both `Homo sapiens`, taken from the title and Methods (postmortem human brains).
A proposed key row is in `reference_tables/Wegiel_etal_2014_species_key_proposed.csv`, using the
`_keys/General/species_key.csv` schema. **No `_keys/` file was edited.**

<!-- errata:begin -->
## Errata

Generated from `reference_tables/Wegiel_etal_2014_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| Wegiel_etal_2014-E003 | CE | Table 1 p. 6, row 'LV' (under 'Entorhinal c.'), column 'CE*' | (blank) |  | publication_ambiguity | 0.003 | proposed | The CE cell of row LV is blank on the printed page. The Methods text on the same page states 'The number of virtual counting spaces ranged from 62 per subdivision per case in a very small subdivision such as the fifth layer in the entorhinal cortex (coefficient of error; CE, 0.003)'; Table 1 row LV prints 62 counting spaces. The printed CE 0.003 sits on row LII, the first row of the entorhinal block, suggesting blank CE cells share the value printed at the top of their block. | CSV keeps CE blank (NA) as printed. The same block reading would give LIII and LVI 0.003, CA2-CA4 0.003 (CA1 prints 0.003) and Putamen / Nucleus accumbens 0.04 (Caudate nucleus prints 0.04), but only LV and Globus pallidus are attested by the text, so only those two are raised. |
| Wegiel_etal_2014-E004 | CE | Table 1 p. 6, row 'Globus pallidus', column 'CE*' | (blank) |  | publication_ambiguity | 0.04 | proposed | The CE cell of row Globus pallidus is blank on the printed page. The Methods text on the same page states the counting spaces ranged '... to 1953 in the globus pallidus with a low neuronal numerical density (CE, 0.04)'; Table 1 row Globus pallidus prints 1953 counting spaces. The printed 0.04 sits on row Caudate nucleus, the first row of the striatal block. | CSV keeps CE blank (NA) as printed. See E003 for the block reading. |

2 recorded, 2 open (proposed), 0 confirmed, 0 withdrawn.
<!-- errata:end -->

## Workbook package repair (2026-11-27)

The frozen snapshot retained all printed worksheet cells, but its OOXML dimension
reported only `A1` and its relationship file referenced absent drawing parts.
The dimension was set to the extant cell range and those dangling drawing
relationships were removed. All cell XML, merged ranges, styles and values stayed
unchanged. `Rscript --vanilla Wegiel_etal_2014_Table1.R` rebuilt the same
22-row analysis CSV cell for cell. This is an assistant integrity check, not
human visual signoff.
