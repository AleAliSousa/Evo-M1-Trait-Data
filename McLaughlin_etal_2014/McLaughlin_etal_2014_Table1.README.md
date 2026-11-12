# McLaughlin_etal_2014_Table1

**Item name** `McLaughlin_etal_2014_Table1` · **Item encoded (expected after registration)** `10.1016%2Fj.biopsych.2013.08.016_Table1`

**Registration pending.** The item is not yet in `__ReadMe.xlsx`; the build writes the analysis CSV and
prints `not yet registered - TSV skipped`. Paste `McLaughlin_etal_2014_Table1_registry_row.xlsx` (see its HOW_TO_PASTE sheet),
run `_tools/file_list.R`, then re-run the build to write the public TSV
`__Public/comparative-data/<Item encoded>.tsv`.

McLaughlin, K. A., Sheridan, M. A., Winter, W., Fox, N. A., Zeanah, C. H., & Nelson, C. A. (2014). Widespread reductions in cortical thickness following severe early-life deprivation: A neurodevelopmental pathway to attention-deficit/hyperactivity disorder. *Biological Psychiatry*, 76(8), 629–638. <https://doi.org/10.1016/j.biopsych.2013.08.016>

**Item full original title:** Table 1. *Sociodemographic and Developmental Characteristics Among Children
Reared in Institutions and Community Control Subjects in the Bucharest Early Intervention Project (n = 80)*
(p. 630).

## What the data are

The sample-description table. It has 10 printed variables × 2 groups (EIG n = 58, NIG n = 22) = **20
analysis rows**: female count (%), three ages in months, birth weight (g), head circumference at birth
(cm), Full-Scale IQ, and **three global volumes: Intracranial Volume, Cerebral Gray Matter and Cortical
Gray Matter** (`is_volume = TRUE`). Each row carries M and SD (in parentheses, as printed), the
group-difference statistic (F, or χ²₁ for sex) and its p. `^a` marks p < .05, two-sided. Unlike Table 4,
these p values are **not** FDR-corrected, and the table does not say these group differences are
covariate-adjusted.

## Pipeline

```
Source (born-digital journal PDF, p. 630 = PDF page 2)
  -> McLaughlin_etal_2014_Table1_snapshot.R   printed layout verbatim -> frozen snapshot
  -> McLaughlin_etal_2014_Table1_snapshot.xlsx         FROZEN: 16 rows x 7 cols, sheet "Table1"
  -> McLaughlin_etal_2014_Table1.R                     clean + parse + table checks
  -> McLaughlin_etal_2014_Table1.csv                   20 rows ("use this")
  -> __Public/comparative-data/<Item encoded>.tsv   (only once registered)
  -> reference_tables/McLaughlin_etal_2014_Table1_definitions.csv
```

## Who read the values, when, and how it was checked

Transcribed by an **AI assistant (Claude) on 2026-11-11** from 300- and 450-dpi renders of PDF page 2
(journal p. 630), read row by row across the printed table. The printed layout is written out verbatim
inside the `McLaughlin_etal_2014_Table1_snapshot.R`, which freezes it to the `.xlsx` and refuses to overwrite a frozen copy
that differs. Two independent checks were made:

1. **Text-layer token check (in the extract script).** Every numeric lexeme typed in the block was
   found in the PDF text layer of the same page.
2. **Independent re-extraction.** An earlier session's extraction
   (`s2_stress_volumes_extracted_values.csv`), read from the same page at 200 dpi, gives identical
   means and SDs for every volume cell.

Neither check can see a value placed one cell away. That is what the human row-by-row read below is for.

### Structure of the snapshot

One worksheet row per printed row: the caption, two header tiers, 11 printed body rows (including the
"Age (Months)" heading row, which has no values), and the two footnote lines. Printed indentation is kept
as two leading spaces. The spanning group headers sit over their M column, with blank padding under SD.
"n = 28 (48.3%)" sits in the M column, as printed across M/SD. The χ² label is written `chi^2_1 = .25`
and superscripts as `^a`.

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

The build re-checks two printed relations into `table_checks` (HOWTO §7a). Result of an actual R run
(2026-11-11): **3 pass, 0 mismatch, 0 not evaluable.**

| check | relation | result |
|---|---|---|
| `female_percent_EIG` | 100 × 28 / 58 = 48.28 vs printed 48.3 (tolerance 0.05) | pass |
| `female_percent_NIG` | 100 × 12 / 22 = 54.55 vs printed 54.5 | pass |
| `group_n_sum` | 58 + 22 = caption n = 80 | pass |

## Data role

**Proposed: `primary`.** These are the authors' own measurements of this cohort.

## Species names

The table prints no species. The caption names the subjects "Children", and `species_as_published =
"children"` is carried on every row. A proposed key row (`children` → *Homo sapiens*, 9606) is in
`reference_tables/McLaughlin_etal_2014_species_key_proposed.csv` (General collection schema). No
`_keys/` file was edited.

## Human visual check of snapshot

Not yet recorded. A human still needs to lay the snapshot beside the page and read a few rows **across**,
including some from the middle of the table, then record `DDMMYYYY_initials` in the
`Human visual check of snapshot` column of `__ReadMe.xlsx`.
