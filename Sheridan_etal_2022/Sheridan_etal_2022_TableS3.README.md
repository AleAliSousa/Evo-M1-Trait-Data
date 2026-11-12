# Sheridan_etal_2022_TableS3

**Item name** `Sheridan_etal_2022_TableS3` · **Item encoded (expected after registration)** `10.1126%2Fsciadv.abn4316_TableS3`

**Registration pending.** The item is not yet in `__ReadMe.xlsx`; the build writes the analysis CSV and
prints `not yet registered - TSV skipped`. Paste `Sheridan_etal_2022_TableS3_registry_row.xlsx` (see its HOW_TO_PASTE sheet),
run `_tools/file_list.R`, then re-run the build to write the public TSV
`__Public/comparative-data/<Item encoded>.tsv`.

Sheridan, M. A., Mukerji, C. E., Wade, M., Humphreys, K. L., Garrisi, K., Goel, S., Patel, K., Fox, N. A., Zeanah, C. H., Nelson, C. A., & McLaughlin, K. A. (2022). Early deprivation alters structural brain development from middle childhood to adolescence. *Science Advances*, 8(40), eabn4316. <https://doi.org/10.1126/sciadv.abn4316>

**Item full original title:** Table S3. *Volume of total cortical grey and white matter as well as volume
of six subcortical structures in cubic centimeters at the second (age 16 years) time point. Volume was
measured using FreeSurfer analysis suite. Only differences between the EIG and NIG were significant for
total grey and white matter volume.* (Supplementary Materials p. 10.)

## Source

The Supplementary Materials PDF `sciadv.abn4316_sm.pdf` was retrieved earlier from the Europe PMC
supplementaryFiles service, for PMC9544316. It is open access (CC BY-NC); the PMC direct link returned a
reCAPTCHA page. A byte copy is kept in this folder (md5 `118adc50708dbe7f3fc3cdbb65538780`). The main
article was read as PMC full text (PMC9544316), because no main-article PDF was retrievable in this
session, and the folder therefore holds no main-article PDF. The SM is a PDF of a word-processor
manuscript, i.e. a *picture* of the table, so a transcribed snapshot is the frozen source.

## What the data are

There are 14 printed rows × 3 groups = **42 printed cells**: total grey matter and total white matter
(whole brain), and amygdala, hippocampus, thalamus, caudate, putamen and globus pallidus, each for
**Right and Left separately**. Each cell is "mean (dispersion)" in **cm³**, at 1 decimal. The caption
does not name the parenthetical statistic (`dispersion_type = "not stated (parenthetical; presumably
SD)"`). The values are raw group means. The paper's subcortical group tests adjust for ICV (main text,
Subcortical volume, and SM "Impact of institutionalization on subcortical volume without controls for
ICV"). No nucleus accumbens or cerebellum is given.

**Analysis CSV: 60 rows = 42 printed + 18 derived.** Following HOWTO §6 (hemispheres), each structure ×
group also gets a `Left+Right (computed)` row, the sum of the two printed means (`value_status =
"derived_sum"`). It has no dispersion, because the L/R covariance is not reported. Units: printed cm³ are
kept in `mean.cm3`/`dispersion.cm3`, and the project unit is `mean.mm3 = mean.cm3 × 1000`.

**Precision caveat.** Means are printed to 0.1 cm³ (100 mm³). For amygdala (~1.5 cm³) and pallidum
(~1.7 cm³), half a unit of rounding is ~3% of the mean. That is the same order as most of the printed
group differences. The paper says the extracted neural metrics are on OSF (osf.io/476m8, view-only link);
this was not accessed.

## Cohort and the control group

BEIP, 16-year follow-up: Siemens Magnetom 1.5 T at Santador Hospital, MPRAGE 1 mm isotropic, TR 2530
ms; FreeSurfer 5.3 (5.0 at the 9-y time point). Groups are as printed: **CAUG (n = 40)** = care as usual,
prolonged institutional care; **FCG (n= 41)** = randomised to foster care; **NIG (n = 33)**. SM Table S1
gives mean ages of 200, 198 and 201 months and 54%, 49% and 42% female.

* **Healthy control group = `NIG (n = 33)`** (never-institutionalized, community-reared; `group_code =
  NIG`, `is_control = TRUE`). CAUG + FCG together form the EIG that the caption refers to.
* Rows are intraspecific group summaries. Use NIG for normative use and do not pool groups.
* **Not independent of `McLaughlin_etal_2014_Table1/Table4`**: these are the same BEIP children,
  rescanned. Comparisons across the two time points also cross FreeSurfer versions (5.0 → 5.3) and
  scanners.
* Main-text cross-check (not a table check, and not applied to the data): pooling CAUG + FCG gives an EIG
  GM of 469.9 cm³ (−2.5% vs NIG) and WM of 431.3 cm³ (−5.5%). This matches the text's "2.5 to 5.5%
  decrease". The text's "total intracranial volume (… see table S3)" is not actually in Table S3.

## Pipeline

```
Source: sciadv.abn4316_sm.pdf, SM page 10
  -> Sheridan_etal_2022_TableS3_snapshot.R   printed layout verbatim -> frozen snapshot
  -> Sheridan_etal_2022_TableS3_snapshot.csv          FROZEN: 17 rows x 5 cols
  -> Sheridan_etal_2022_TableS3.R                     clean + parse + cm3 -> mm3 + L+R sums
  -> Sheridan_etal_2022_TableS3.csv                   60 rows ("use this")
  -> __Public/comparative-data/<Item encoded>.tsv   (only once registered)
  -> reference_tables/Sheridan_etal_2022_TableS3_definitions.csv
```

## Who read the values, when, and how it was checked

Transcribed by an **AI assistant (Claude) on 2026-11-11** from 300- and 500-dpi renders of SM page 10,
read row by row. The values were checked three ways:

1. The extract script confirms that **all 42 printed cells occur verbatim** in the SM text layer.
2. An earlier session's independent extraction (`s2_stress_volumes_extracted_values.csv`) agrees on all
   42 mean/dispersion pairs.
3. The page image was re-read.

### Structure of the snapshot

* The snapshot has the "Table S3." heading, the column-header row and 14 data rows, followed by the
  caption, which the SM prints *below* the table.
* The structure label sits on the Right row only, with a blank on the Left row, as printed.
* The two-line label "Total grey matter volume (cubic centimeters)" is joined with one space.
* "469.3(48.6)", with no space, is kept as printed.
* **Omitted:** the manuscript line numbers "5", "10" and "15" in the right margin beside the NIG column.
  They are separate text objects in the PDF text layer, part of the manuscript's continuous line
  numbering, and not table content. One of them sits just under "482.1 (51.5)" and could be misread as
  part of that cell.

## Table checks

Table S3 prints no total or other self-checking relation, so no `table_checks` are produced.

## Data role

**Proposed: `primary`.**

## Species names

`species_as_published = "children"` (main text). The proposed key row is in
`reference_tables/Sheridan_etal_2022_species_key_proposed.csv`. No `_keys/` file was edited.

## Human visual check of snapshot

Not yet recorded. A human still needs to lay the snapshot beside the page and read a few rows **across**,
including some from the middle of the table, then record `DDMMYYYY_initials` in the
`Human visual check of snapshot` column of `__ReadMe.xlsx`.
