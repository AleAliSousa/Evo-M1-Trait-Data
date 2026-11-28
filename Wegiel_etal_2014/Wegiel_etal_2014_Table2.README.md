# Wegiel_etal_2014_Table2

**Item name** `Wegiel_etal_2014_Table2` · **Item number** `Table 2` · **Item encoded** not yet registered (paste
`Wegiel_etal_2014_Table2_registry_row.xlsx` into `__ReadMe.xlsx` Sheet1, then run `_tools/file_list.R`)

Wegiel, J., Flory, M., Kuchna, I., Nowicki, K., Ma, S. Y., Imaki, H., Wegiel, J., Cohen, I. L., London, E.,
Wisniewski, T., & Brown, W. T. (2014). Stereological study of the neuronal number and volume of 38 brain
subdivisions of subjects diagnosed with autism reveals significant alterations restricted to the striatum,
amygdala and cerebellum. *Acta Neuropathologica Communications* 2, 141.
<https://doi.org/10.1186/s40478-014-0141-7> (open access; PMC4177256; PMID 25231243)

**Item full original title:** Table 2 Mean volume (±SE) of 14 brain structures and 24 cytoarchitectonic subdivisions in one brain hemisphere of autistic and control subjects*

## What the data are

**76 rows** = 38 printed regions (14 structures + 24 cytoarchitectonic subdivisions, as the caption says) × 2
printed groups. For each row the CSV gives:

* the mean **absolute volume** and its **SE** (mm³, one hemisphere, processed tissue);
* the **shrinkage-corrected** mean volume (mm³);
* the printed between-group **p** (ANCOVA with brain weight and % brain-weight loss during dehydration as
  covariates; `ns` = not significant).

The printed label is kept verbatim in `structure_as_published`; a printed "- " prefix marks a subdivision of
the structure row above it. `structure` drops that prefix, and `parent_structure_as_published` names the
structure row. The row `- Cerebellar cortex (calculated)` has no printed SE, because the authors calculated it
(it equals molecular + granule cell layer). Units: mm³ as printed, which is already the project unit, so no
conversion is applied.

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

## Shrinkage handling

The tissue was formalin-fixed (mean 408 days for controls, 905 for autism), dehydrated in ethanol (36 / 38 days),
embedded in 8% celloidin and cut into serial 200-µm sections stained with cresyl violet (Methods p. 3).
Dehydration reduced hemisphere weight by **45% (control)** and **47% (autism)** on average.

* Table 2 prints two volumes. The first is the **absolute volume** of processed tissue, calculated from mounted
  section thickness and not corrected. The second is a **shrinkage-corrected volume**, computed by the authors
  as absolute / (1 − shrinkage) with the group-mean factors 0.55 (control) and 0.53 (autism), as the Table 2
  footnote states. The table checks reproduce this relation in 74 of 76 cells.
* Table 3 **densities are per mm³ of processed tissue**, not corrected. In 58 of 60 region × group cells,
  neuron number / Table 2 absolute volume reproduces the printed density to within rounding. The two exceptions
  are the entorhinal cortex rows: Table 2's EC volume includes layers I and IV, where no neurons were counted.
  To express a density per fresh-tissue mm³, multiply by (1 − shrinkage). That is a downstream decision and is
  not done here.
* The analysis CSVs keep the printed values. The shrinkage factor of each row is in `shrinkage_pct_applied`
  (Table 2).

## Source → Snapshot → Data readable  (printed PDF → snapshot required)

```
Wegiel-2014-Stereological study of the neurona.pdf  (Table 2, p. 9)
  -> Wegiel_etal_2014_Table2_snapshot.R   writes the frozen snapshot
  -> Wegiel_etal_2014_Table2_snapshot.xlsx        FROZEN: 43 rows x 6 cols, sheet "Table2"
                                                  (caption; spanning headers with blank padding; sub-header;
                                                   38 body rows in printed order; 2 footnote lines)
  -> Wegiel_etal_2014_Table2.R                    parse + reshape + table checks
  -> Wegiel_etal_2014_Table2.csv                  76 rows x 20 cols ("use this")
  -> __Public/comparative-data/<Item encoded>.tsv  written only once the item is registered
  -> reference_tables/Wegiel_etal_2014_Table2_definitions.csv
```

## Who read the values, when, and how they were checked

The values were extracted by an **AI assistant (Claude) on 2026-11-11** from the PDF's **text layer**. The
journal PDF is born-digital BMC typesetting, and its layout-preserving text layer is clean for these tables.
The publisher offers **no machine-readable table or supplementary file**: the PMC JATS XML has no
`supplementary-material`, so the printed PDF is the source, and a snapshot is required.
`Wegiel_etal_2014_Table2_snapshot.R` reads the page with `pdftools::pdf_text`. It anchors only the printed header
literals, which it also checks against the page text, and splits each printed row into its printed cells. It
then freezes `Wegiel_etal_2014_Table2_snapshot.xlsx`, and **refuses to overwrite a frozen copy that differs**. Re-running it
reports "unchanged". The build script reads that frozen file and contains no table values.

Checks applied:

1. **Visual, row by row:** each snapshot row was read across against a 300-dpi render of the printed page
   (p. 9), including rows from the middle of the table and the rows on either side of every subdivision block.
   No shift, swap or misread was found.
2. **Row-count identity with the caption:** 38 body rows: 14 without and 24 with the "- " marker, exactly the "14 brain structures and 24 cytoarchitectonic subdivisions" of the caption. The extract script asserts this.
3. **Cross-check against an earlier, independent staged extraction** (the control-group values of Tables 2
   and 3, `vbf0353d5_s1a_stereology_extracted_values.csv`): 76 control values (38 absolute volumes with their SE, and 38 corrected volumes), **0 mismatches**.
4. **The table's own arithmetic** (see *Table checks*).

A human RA still needs to do the side-by-side check and record `DDMMYYYY_initials` in the
`Human visual check of snapshot` column of `__ReadMe.xlsx`.

## Table checks

The table carries two relations, and the reader re-runs both into `table_checks`:

1. **Footnote relation**, corrected = absolute / (1 − s), with s = 0.47 (autism) and 0.45 (control) read from
   the printed footnote. Applied to all 76 cells. Tolerance: half a unit of the printed absolute, propagated
   (0.5 / (1 − s)), plus half a unit of the printed corrected value.
2. **Structure total = sum of its printed subdivisions**, in all four value columns, for CA, EC I–VI, Globus
   pallidus, Claustrum, Amygdala, Cerebellum (= cerebellar cortex + white matter + cerebellar nuclei), and
   Cerebellar cortex (calculated) (= molecular + granule cell layer). `- Dentate nucleus` is a part of
   `- Cerebellar nuclei` and is not added. Tolerance: half a unit per printed cell, including the total. In the
   corrected columns each cell also carries the propagated half unit of the rounded absolute it was computed
   from.

**Result of an actual R run (2026-11-11): 102 pass, 2 mismatch, of 104 checks.**

| check | row | observed | printed | difference | tolerance |
|---|---|---|---|---|---|
| `shrinkage_38_Autism` | – Dentate nucleus, Autism | 460.38 | 511 | −50.62 | 1.44 |
| `shrinkage_4_Control` | Cornu Ammonis (CA), Control | 1094.55 | 1096 | −1.45 | 1.41 |

Both cells were re-read on the page render and are printed as shown. **The printed values are kept** in the
snapshot and the CSV, and both are filed as errata (E001, E002).

## Data role

**Proposed: `primary`.** These are the authors' own stereological measurements on their own postmortem series.
Only the `Control` rows are candidates for healthy-human merges, after a decision on the one-hemisphere basis
and the shrinkage basis. Other volumetric work in the same tissue bank and lab may share brains, and the authors
compare their values with Kreczmanski, Bogerts, Lauer and Pakkenberg (Discussion p. 12).

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
| Wegiel_etal_2014-E001 | volume_shrinkage_corrected.mm3 | Table 2 p. 9, row 38 '- Dentate nucleus', column 'Volume (mm³) corrected for shrinkage' Autism | 511 |  | publication_error | 460 | proposed | The Table 2 footnote states the corrected volume uses 47% shrinkage for autism, i.e. corrected = absolute/(1 - 0.47). The same row prints absolute 244 ± 14, giving 244/0.53 = 460.4; the printed 511 differs by 50.6 against a 1.4 rounding allowance. The absolute 244 mm3 is confirmed by the Results text (p. 7: 'the largest dentate nucleus (244 mm3 and 232 mm3, respectively)'). Every other one of the 76 corrected cells follows the footnote within rounding, including the Control dentate (232/0.55 = 421.8 -> 422 as printed). 511 would require an absolute of ~271. Page render re-read at 300 dpi: '511' is unambiguous. | Detected by the item's table_checks (shrinkage_38_Autism). CSV keeps the printed 511. 460 also happens to be the printed corrected value of the Nucleus accumbens Autism row (absolute also 244), which may be the source of the slip in reverse; not adjudicable from the paper. |
| Wegiel_etal_2014-E002 | volume_shrinkage_corrected.mm3 | Table 2 p. 9, row 4 'Cornu Ammonis (CA)', column 'Volume (mm³) corrected for shrinkage' Control | 1,096 |  | publication_error | 1095 | proposed | Footnote: control corrected = absolute/(1 - 0.45). The row prints absolute 602 ± 30, giving 602/0.55 = 1094.5; printed 1,096 differs by 1.45 against a 1.41 rounding allowance (an absolute in [601.5, 602.5] gives 1094-1095). Independently, the row's printed corrected subdivisions sum to 785 + 65 + 82 + 162 = 1,094. Marginal, last-digit only. | Detected by the item's table_checks (shrinkage_4_Control). CSV keeps the printed 1,096. Proposed 1095 = round(602/0.55); 1094 (subdivision sum) is equally defensible. |

2 recorded, 2 open (proposed), 0 confirmed, 0 withdrawn.
<!-- errata:end -->

## Workbook package repair (2026-11-27)

The frozen snapshot retained all printed worksheet cells, but its OOXML dimension
reported only `A1` and its relationship file referenced absent drawing parts.
The dimension was set to the extant cell range and those dangling drawing
relationships were removed. All cell XML, merged ranges, styles and values stayed
unchanged. `Rscript --vanilla Wegiel_etal_2014_Table2.R` rebuilt the same
76-row analysis CSV cell for cell. This is an assistant integrity check, not
human visual signoff.
