# McLaughlin_etal_2014_Table4

**Item name** `McLaughlin_etal_2014_Table4` · **Item encoded (expected after registration)** `10.1016%2Fj.biopsych.2013.08.016_Table4`

**Registration pending.** The item is not yet in `__ReadMe.xlsx`; the build writes the analysis CSV and
prints `not yet registered - TSV skipped`. Paste `McLaughlin_etal_2014_Table4_registry_row.xlsx` (see its HOW_TO_PASTE sheet),
run `_tools/file_list.R`, then re-run the build to write the public TSV
`__Public/comparative-data/<Item encoded>.tsv`.

McLaughlin, K. A., Sheridan, M. A., Winter, W., Fox, N. A., Zeanah, C. H., & Nelson, C. A. (2014). Widespread reductions in cortical thickness following severe early-life deprivation: A neurodevelopmental pathway to attention-deficit/hyperactivity disorder. *Biological Psychiatry*, 76(8), 629–638. <https://doi.org/10.1016/j.biopsych.2013.08.016>

**Item full original title:** Table 4. *Group Differences in the Volume of Subcortical Structures and the
Cerebellum Among Children Reared in Institutions and Community Control Subjects in the Bucharest Early
Intervention Project (n = 80)*ᵃ (p. 634).

## What the data are

There are 8 structures × 2 groups = **16 analysis rows**. The structures are caudate, putamen, globus
pallidus and nucleus accumbens (printed indented under "Striatum"), plus amygdala, hippocampus,
thalamus and cerebellum, which are *not* indented. Each row has the group **M and SD of volume**, the
group-difference F and its **FDR-corrected** p. Footnote a: "Analyses control for age, gender, total brain
volume, and repetition time and p values corrected for the false discovery rate". The covariates apply
to the F test. The tabulated M/SD are not stated to be adjusted and appear to be raw group means. In
this table the SDs are printed without parentheses.

## Pipeline

```
Source (born-digital journal PDF, p. 634 = PDF page 6)
  -> McLaughlin_etal_2014_Table4_snapshot.R   printed layout verbatim -> frozen snapshot
  -> McLaughlin_etal_2014_Table4_snapshot.xlsx         FROZEN: 13 rows x 7 cols, sheet "Table4"
  -> McLaughlin_etal_2014_Table4.R                     clean + parse
  -> McLaughlin_etal_2014_Table4.csv                   16 rows ("use this")
  -> __Public/comparative-data/<Item encoded>.tsv   (only once registered)
  -> reference_tables/McLaughlin_etal_2014_Table4_definitions.csv
```

## Who read the values, when, and how it was checked

Transcribed by an **AI assistant (Claude) on 2026-11-11** from 300- and 450-dpi renders of PDF page 6
(journal p. 634), read row by row across the printed table. The printed layout is written out verbatim
inside the `McLaughlin_etal_2014_Table4_snapshot.R`, which freezes it to the `.xlsx` and refuses to overwrite a frozen copy
that differs. Two independent checks were made:

1. **Text-layer token check (in the extract script).** Every numeric lexeme typed in the block was
   found in the PDF text layer of the same page.
2. **Independent re-extraction.** An earlier session's extraction
   (`s2_stress_volumes_extracted_values.csv`), read from the same page at 200 dpi, gives identical
   means and SDs for every volume cell.

Neither check can see a value placed one cell away. That is what the human row-by-row read below is for.

### Structure of the snapshot

One worksheet row per printed row: the caption, two header tiers, the "Striatum" heading row, 8
structure rows and the footnote. Indentation is kept as two leading spaces. The nucleus accumbens F cell
is kept verbatim as `3.68S` (errata E001).

## Units — not printed

**Neither Table 1 nor Table 4 prints a unit for any volume.** There is none in the column headers, the
captions or the footnotes. The text gives only "Cortical reconstruction and volumetric segmentation were
performed with FreeSurfer (Version 5.0 …)" and never names a volume unit or says whether a subcortical
value is one hemisphere, an average, or left + right.

The values are therefore carried **exactly as printed**, with `unit_as_printed = "not printed"`, and
**not converted**. (Table 4 also has `hemisphere_as_published = "not printed"`.) The magnitudes are
consistent with FreeSurfer mm³ and with bilateral L+R sums. For example, caudate is ≈ 8.3–8.7 × 10³ and
cortical GM ≈ 5.8–6.1 × 10⁵. That is an *inference*, not a printed fact. A user who accepts it can read
the values as mm³ (bilateral) with no numeric change.

## Cohort and the control group

Bucharest Early Intervention Project (BEIP), MRI at 8–10 years (Siemens Magnetom Avanto 1.5 T, MPRAGE
1 × 1 × 1 mm, TR 1650–1910 ms; FreeSurfer 5.0). Of 86 children scanned, 80 were analysed: 31 CAUG
(care as usual, prolonged institutional care), 27 FCG (randomised to foster care) and 22 NIG. The text
(p. 630) says CAUG and FCG did not differ in thickness or subcortical volume, so they are **pooled as the
Ever Institutionalized Group (EIG, n = 58)**.

* **Healthy control group = `Never Institutionalized Group (n = 22)`** (`group_code = NIG`,
  `is_control = TRUE`): community-reared children recruited from Bucharest paediatric clinics.
* The CSV keeps both printed groups with their printed labels. Rows are intraspecific group summaries.
  Use the NIG rows for any normative (species-level) use and never pool EIG with NIG.
* **Not an independent sample.** These are the same children as in Sheridan et al. 2012 (PNAS, 9-y
  scans) and Sheridan et al. 2022 (`Sheridan_etal_2022_TableS3`, rescanned at 16 y).

## Table checks

Table 4 prints no total or other self-checking relation, so no `table_checks` are produced. Outside the
build, we checked the printed p values against the printed F values. Benjamini–Hochberg FDR applied to
F(1, ~74) p values across the 8 structures reproduces every printed p (to ±.001–.008, the last from the
rounding of F). This is the evidence for E001.

## Data role

**Proposed: `primary`.**

## Species names

`species_as_published = "children"` (from the caption). The proposed key row is in
`reference_tables/McLaughlin_etal_2014_species_key_proposed.csv`. No `_keys/` file was edited.

## Human visual check of snapshot

Not yet recorded. A human still needs to lay the snapshot beside the page and read a few rows **across**,
including some from the middle of the table, then record `DDMMYYYY_initials` in the
`Human visual check of snapshot` column of `__ReadMe.xlsx`.

<!-- errata:begin -->
## Errata

Generated from `reference_tables/McLaughlin_etal_2014_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| McLaughlin_etal_2014-E001 | F_printed | Table 4, p. 634, row 'Nucleus accumbens', column Group Difference F | 3.68S |  | publication_ambiguity | 3.68 | proposed | Page 6 render read at 450 dpi: the cell prints '3.68S' (a capital S after the digits; no footnote S exists). Taking F = 3.68 with df (1, ~74) gives uncorrected p = .059, and Benjamini-Hochberg FDR across the 8 printed structures then reproduces every printed p value of the table, including .472 for this row (p x 8/1) and the shared .512 for caudate, globus pallidus, amygdala and thalamus. So the numeric value is 3.68 and 'S' is a stray character. | CSV keeps F_printed = '3.68S' verbatim; F is parsed as 3.68 and F_trailing_text = 'S'. Inconsequential for the volume means. |

1 recorded, 1 open (proposed), 0 confirmed, 0 withdrawn.
<!-- errata:end -->
