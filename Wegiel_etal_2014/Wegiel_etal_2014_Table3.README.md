# Wegiel_etal_2014_Table3

**Item name** `Wegiel_etal_2014_Table3` · **Item number** `Table 3` · **Item encoded** not yet registered (paste
`Wegiel_etal_2014_Table3_registry_row.xlsx` into `__ReadMe.xlsx` Sheet1, then run `_tools/file_list.R`)

Wegiel, J., Flory, M., Kuchna, I., Nowicki, K., Ma, S. Y., Imaki, H., Wegiel, J., Cohen, I. L., London, E.,
Wisniewski, T., & Brown, W. T. (2014). Stereological study of the neuronal number and volume of 38 brain
subdivisions of subjects diagnosed with autism reveals significant alterations restricted to the striatum,
amygdala and cerebellum. *Acta Neuropathologica Communications* 2, 141.
<https://doi.org/10.1186/s40478-014-0141-7> (open access; PMC4177256; PMID 25231243)

**Item full original title:** Table 3 Total number of neurons per region and neuronal numerical density in 15 structures and 16 cytoarchitectonic subdivisions in examined brain hemisphere of individuals with autism and control subjects*

## What the data are

**62 rows** = 31 printed regions (15 structures + 16 cytoarchitectonic subdivisions, as the caption says) × 2
printed groups. For each row the CSV gives:

* the mean **total number of neurons per region** (one hemisphere, optical fractionator);
* the mean **neuronal numerical density** (N/mm³ of processed tissue);
* the printed p of each between-group comparison (ANCOVA with log age, brain weight, PMI, days of fixation and
  % brain-weight loss as covariates; `ns` = not significant).

The row `Cerebellum (Purkinje cells)` counts **Purkinje cells only** (`cell_type`). The `- EC Islands` p cell
prints `ns† (0.013)`: the † footnote says the 20% deficit (p < 0.013) disappears once covariates are entered.
The mark goes in `footnote_mark_p_neuron_number`, and the footnote text goes in `note`. Printed labels are kept
verbatim, including the misspelling `- Accesory basal nucleus` (Table 2 prints "Accessory"). Units: counts and
N/mm³, as printed; no conversion is applied.

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
Wegiel-2014-Stereological study of the neurona.pdf  (Table 3, p. 10)
  -> Wegiel_etal_2014_Table3_snapshot.R   writes the frozen snapshot
  -> Wegiel_etal_2014_Table3_snapshot.xlsx        FROZEN: 36 rows x 7 cols, sheet "Table3"
                                                  (caption; spanning headers with blank padding; sub-header;
                                                   31 body rows in printed order; * and † footnotes)
  -> Wegiel_etal_2014_Table3.R                    parse + reshape + table checks
  -> Wegiel_etal_2014_Table3.csv                  62 rows x 22 cols ("use this")
  -> __Public/comparative-data/<Item encoded>.tsv  written only once the item is registered
  -> reference_tables/Wegiel_etal_2014_Table3_definitions.csv
```

Counting method: design-based stereology, an optical fractionator with systematic random sampling (Stereo
Investigator, MicroBrightField). Sampling parameters for each structure are in item `Wegiel_etal_2014_Table1`.
A proposed row for `_keys/cell_count_methods/source_methods.csv` is in
`reference_tables/Wegiel_etal_2014_cell_count_methods_proposed.csv`: Control rows `include_flagged` and
Autism rows `exclude`, both pending owner review.

## Who read the values, when, and how they were checked

The values were extracted by an **AI assistant (Claude) on 2026-11-11** from the PDF's **text layer**. The
journal PDF is born-digital BMC typesetting, and its layout-preserving text layer is clean for these tables.
The publisher offers **no machine-readable table or supplementary file**: the PMC JATS XML has no
`supplementary-material`, so the printed PDF is the source, and a snapshot is required.
`Wegiel_etal_2014_Table3_snapshot.R` reads the page with `pdftools::pdf_text`. It anchors only the printed header
literals, which it also checks against the page text, and splits each printed row into its printed cells. It
then freezes `Wegiel_etal_2014_Table3_snapshot.xlsx`, and **refuses to overwrite a frozen copy that differs**. Re-running it
reports "unchanged". The build script reads that frozen file and contains no table values.

Checks applied:

1. **Visual, row by row:** each snapshot row was read across against a 300-dpi render of the printed page
   (p. 10), including rows from the middle of the table and the rows on either side of every subdivision block.
   No shift, swap or misread was found.
2. **Row-count identity with the caption:** 31 body rows: 15 without and 16 with the "- " marker, exactly the "15 structures and 16 cytoarchitectonic subdivisions" of the caption. The extract script asserts this.
3. **Cross-check against an earlier, independent staged extraction** (the control-group values of Tables 2
   and 3, `vbf0353d5_s1a_stereology_extracted_values.csv`): 62 control values (31 neuron numbers and 31 densities), **0 mismatches**.
4. **The table's own arithmetic** (see *Table checks*).

A human RA still needs to do the side-by-side check and record `DDMMYYYY_initials` in the
`Human visual check of snapshot` column of `__ReadMe.xlsx`.

## Table checks

Structure total neurons = sum of its printed subdivisions, for both groups, for CA (CA1–CA4), Claustrum
(insular + prepiriform), Entorhinal cortex (Islands + III + V + VI), Amygdala (four nuclei) and Globus pallidus
(external + internal). Tolerance: half a unit per printed cell. Densities are not additive and are not summed.

**Result of an actual R run (2026-11-11): 10 pass, 0 mismatch, of 10 checks.** Every sum is exact.

## Data role

**Proposed: `primary`.** These are the authors' own optical-fractionator counts. Only the `Control` rows are
candidates for the `__merging_cell_counts_histology` merge, flagged for one-hemisphere values and for densities
per mm³ of processed tissue.

## Species

This is a single-species (human) study. The tables never print a species name, so `Species` and
`species_as_published` are both `Homo sapiens`, taken from the title and Methods (postmortem human brains).
A proposed key row is in `reference_tables/Wegiel_etal_2014_species_key_proposed.csv`, using the
`_keys/General/species_key.csv` schema. **No `_keys/` file was edited.**

No errata recorded for this item (all 10 table checks pass; every printed value was confirmed on the page render). Paper-level errata for Tables 1 and 2: `reference_tables/Wegiel_etal_2014_errata.csv`.

<!-- errata:begin -->
<!-- errata:end -->

## Workbook package repair (2026-11-27)

The frozen snapshot retained all printed worksheet cells, but its OOXML dimension
reported only `A1` and its relationship file referenced absent drawing parts.
The dimension was set to the extant cell range and those dangling drawing
relationships were removed. All cell XML, merged ranges, styles and values stayed
unchanged. `Rscript --vanilla Wegiel_etal_2014_Table3.R` rebuilt the same
62-row analysis CSV cell for cell. This is an assistant integrity check, not
human visual signoff.
