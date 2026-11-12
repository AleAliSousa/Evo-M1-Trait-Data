# Hodel_etal_2015_InlineSupplementaryTable3

**Item name** `Hodel_etal_2015_InlineSupplementaryTable3` · **Item encoded (expected after registration)** `10.1016%2Fj.neuroimage.2014.10.020_InlineSupplementaryTable3`

**Registration pending.** The item is not yet in `__ReadMe.xlsx`; the build writes the analysis CSV and
prints `not yet registered - TSV skipped`. Paste `Hodel_etal_2015_InlineSupplementaryTable3_registry_row.xlsx` (see its HOW_TO_PASTE sheet),
run `_tools/file_list.R`, then re-run the build to write the public TSV
`__Public/comparative-data/<Item encoded>.tsv`.

Hodel, A. S., Hunt, R. H., Cowell, R. A., Van Den Heuvel, S. E., Gunnar, M. R., & Thomas, K. M. (2015). Duration of early adversity and structural brain development in post-institutionalized adolescents. *NeuroImage*, 105, 112–119. <https://doi.org/10.1016/j.neuroimage.2014.10.020>

**Item full original title:** Inline Supplementary Table 3. *Comparison of age and sex adjusted uncorrected cortical and subcortical volumes (mm^3) in non-adopted, PI-EA, and PI-LA children.*

## What the data are — contrasts, not means

**12 printed rows** cover frontal, occipital, parietal and temporal lobe (left, right), hippocampus (left, right) and amygdala (left, right). Each row gives the GLM group effect (F, p, partial η²) and
the **parameter estimates B (SE), in mm³, for PI-EA vs non-adopted controls and for PI-LA vs non-adopted
controls**, plus the p for EA vs LA. The models adjust for age and sex only — **not** corrected for head size ("uncorrected"). Its ICV-corrected counterpart is `Hodel_etal_2015_InlineSupplementaryTable4` (lobes only). The main text calls this table "raw volumes" ("Raw volumes are reported in Inline Supplementary Table S3"), but it prints model contrasts, not raw means.

**No control-group or PI-group mean volume is printed anywhere in the paper or its 8 supplementary
files.** These rows are absolute adjusted differences from the control group. A percent difference
needs a control mean from elsewhere, which would be a substituted reference.

**Analysis CSV: 18 rows** = 12 printed + 6 derived `left+right
(computed)` rows (HOWTO §6). The derived rows hold B_left + B_right. That sum is exact for the
bilateral-sum contrast under OLS with the same subjects and covariates. No SE is given for them,
because the L/R covariance is not reported. Units: mm³ as printed = project unit, so there is no
conversion.

## Cohort and the control group

Minnesota International Adoption Project, ages 12–14: **110 post-institutionalized (PI) adoptees**. They
were split at adoption ≤ 12 months (PI-EA, N = 56) vs > 12 months (PI-LA, N = 54). Scans: Siemens 3 T
Trio, MPRAGE 1 mm, FreeSurfer 5.1.0. Lobar volumes are FreeSurfer cortical parcel volumes combined per
hemisphere (Appendix A1.2).

* **Healthy control group = the 62 non-adopted controls** (US children reared by their biological
  families; `contrast_reference_group = "non-adopted controls"`). Every B is "PI group minus controls".
* Hippocampus/amygdala analyses exclude 15 further subjects (2 controls, 13 PI). For those rows
  `n_control = 60` and `n_PI_total = 97`, and the EA/LA split is not reported (NA).
* SM Table 1 prints the control age as "12.12 (.59) / 12.12–14.22": the mean equals the range minimum,
  which is internally implausible. This is recorded here only, because that table is not built.

## Source → frozen source (born-digital)

The journal supplies the supplementary tables as Word files. The frozen source
**`Hodel_etal_2015_InlineSupplementaryTable3_snapshot.docx`** is `ScienceDirect_files_09Nov2026_23-01-31.887/1-s2.0-S1053811914008441-mmc3.docx`
**copy-renamed with bytes untouched** (md5 verified identical). It came from the article's ScienceDirect
page (downloaded 2026-11-09), and the original folder is left as is. The build reads the Word table XML
(`word/document.xml`) with `xml2`: superscript runs become `^x`, and nothing is retyped. This is a
digital-native source, so there is no PDF-to-snapshot visual check (`Not applicable: tabulated and
digital already`). An earlier session's independent XML read agrees on every B/SE pair.

**Audit-tool note.** `audit_dataset_item()` recognises only `_snapshot.(csv|xlsx|xls|tsv)`, so it reports
the `.docx` frozen source as `snapshot MISSING`. Converting the file would break the born-digital rule.

```
1-s2.0-S1053811914008441-mmc3.docx  (ScienceDirect supplement)
  -> Hodel_etal_2015_InlineSupplementaryTable3_snapshot.docx      FROZEN (byte copy)
  -> Hodel_etal_2015_InlineSupplementaryTable3.R                  XML read + parse + table checks + L+R sums
  -> Hodel_etal_2015_InlineSupplementaryTable3.csv                ("use this")
  -> __Public/comparative-data/<Item encoded>.tsv   (only once registered)
  -> reference_tables/Hodel_etal_2015_InlineSupplementaryTable3_definitions.csv
```

## Table checks

Actual R run, 2026-11-11: **48 pass, 0 mismatch, 0 not evaluable** (24 significance-mark checks, 12 F→p, 12 F→η²).

* **Significance marks.** The footnote defines `*` as p < .02. Where a p is printed (F p and EA-vs-LA p),
  the mark must appear iff p < .02. B (se) marks rest on t tests with unprinted df and are not checked.
* **F → p and F → η²,** with df = (2, df2): p = P(F > F_printed) is compared at the printed 3 decimals
  (±.001), and η²ₚ = 2F/(2F + df2) within ±.0015. df2 = 167 (lobes: 172 − 5 parameters) and 152 (hippocampus/amygdala: 157 − 5). This is not printed: it is derived from the printed sample sizes and the model, it is consistent with the main text's F(2, 166) for the ICV-adjusted lobar models and F(2, 151) for the ICV-adjusted left hippocampus (one more covariate each), and it reproduces all 12 printed p and η² values.
* Also found outside the build: the right frontal row prints the same SE (1814.88) for both contrasts, although the design-fixed SE ratio is 1.0234 in every other lobar row (E001).

## Data role

**Proposed: `primary`** (the authors' own cohort). The values are between-group contrasts, not group
means (Measure `Vol.mm3.contrast`).

## Species names

`species_as_published = "children"` (title). The proposed key row is in
`reference_tables/Hodel_etal_2015_species_key_proposed.csv`. No `_keys/` file was edited.

## Human visual check of snapshot

`Not applicable: tabulated and digital already` (born-digital .docx).

<!-- errata:begin -->
## Errata

Generated from `reference_tables/Hodel_etal_2015_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| Hodel_etal_2015-E001 | PI_LA_SE.mm3 | Inline Supplementary Table 3 (mmc3.docx), row 'Frontal Lobe' / 'right', columns PI-EA B (se) and PI-LA B (se) | -10708.24 (1814.88)* \| -7871.34 (1814.88)* |  | publication_ambiguity |  | proposed | Both contrasts print the same SE, 1814.88. The ratio SE(PI-EA)/SE(PI-LA) is fixed by the design matrix (same subjects and covariates in every lobar model), and it is 1.0234 in all seven other lobar rows of this table (1.0242 in the four hippocampus/amygdala rows, which use 157 subjects; 1.0530 in all eight rows of Inline Supplementary Table 4). The right frontal row alone gives 1.0000, so one of its two SEs is probably a duplicated cell. If PI-EA's 1814.88 is right, PI-LA's would be ~1773.3; if PI-LA's is right, PI-EA's would be ~1857.4. Which cell is wrong cannot be decided from the paper. Both B estimates remain significant either way. | CSV keeps both printed SEs. Variable is recorded on PI_LA_SE.mm3 (a rightward copy is the more common slip), but PI_EA_SE.mm3 of the same row is equally suspect. |

1 recorded, 1 open (proposed), 0 confirmed, 0 withdrawn.
<!-- errata:end -->
