# Hodel_etal_2015_InlineSupplementaryTable4

**Item name** `Hodel_etal_2015_InlineSupplementaryTable4` · **Item encoded (expected after registration)** `10.1016%2Fj.neuroimage.2014.10.020_InlineSupplementaryTable4`

**Registration pending.** The item is not yet in `__ReadMe.xlsx`; the build writes the analysis CSV and
prints `not yet registered - TSV skipped`. Paste `Hodel_etal_2015_InlineSupplementaryTable4_registry_row.xlsx` (see its HOW_TO_PASTE sheet),
run `_tools/file_list.R`, then re-run the build to write the public TSV
`__Public/comparative-data/<Item encoded>.tsv`.

Hodel, A. S., Hunt, R. H., Cowell, R. A., Van Den Heuvel, S. E., Gunnar, M. R., & Thomas, K. M. (2015). Duration of early adversity and structural brain development in post-institutionalized adolescents. *NeuroImage*, 105, 112–119. <https://doi.org/10.1016/j.neuroimage.2014.10.020>

**Item full original title:** Inline Supplementary Table 4. *Comparison of age and sex adjusted cortical lobar volumes (mm^3) in non-adopted, PI-EA, and PI-LA children (corrected for total intracranial volume).*

## What the data are — contrasts, not means

**8 printed rows** cover frontal, occipital, parietal and temporal lobe (left, right). Each row gives the GLM group effect (F, p, partial η²) and
the **parameter estimates B (SE), in mm³, for PI-EA vs non-adopted controls and for PI-LA vs non-adopted
controls**, plus the p for EA vs LA. The models adjust for age, sex **and total intracranial volume (ICV)**. Its uncorrected counterpart, which also carries hippocampus and amygdala, is `Hodel_etal_2015_InlineSupplementaryTable3`. Table 4 is **not** a hippocampus/amygdala table. The main text (which has no tables) reports the ICV- and adjSTV-corrected hippocampus/amygdala results in prose and figures only.

**No control-group or PI-group mean volume is printed anywhere in the paper or its 8 supplementary
files.** These rows are absolute adjusted differences from the control group. A percent difference
needs a control mean from elsewhere, which would be a substituted reference.

**Analysis CSV: 12 rows** = 8 printed + 4 derived `left+right
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
**`Hodel_etal_2015_InlineSupplementaryTable4_snapshot.docx`** is `ScienceDirect_files_09Nov2026_23-01-31.887/1-s2.0-S1053811914008441-mmc4.docx`
**copy-renamed with bytes untouched** (md5 verified identical). It came from the article's ScienceDirect
page (downloaded 2026-11-09), and the original folder is left as is. The build reads the Word table XML
(`word/document.xml`) with `xml2`: superscript runs become `^x`, and nothing is retyped. This is a
digital-native source, so there is no PDF-to-snapshot visual check (`Not applicable: tabulated and
digital already`). An earlier session's independent XML read agrees on every B/SE pair.

**Audit-tool note.** `audit_dataset_item()` recognises only `_snapshot.(csv|xlsx|xls|tsv)`, so it reports
the `.docx` frozen source as `snapshot MISSING`. Converting the file would break the born-digital rule.

```
1-s2.0-S1053811914008441-mmc4.docx  (ScienceDirect supplement)
  -> Hodel_etal_2015_InlineSupplementaryTable4_snapshot.docx      FROZEN (byte copy)
  -> Hodel_etal_2015_InlineSupplementaryTable4.R                  XML read + parse + table checks + L+R sums
  -> Hodel_etal_2015_InlineSupplementaryTable4.csv                ("use this")
  -> __Public/comparative-data/<Item encoded>.tsv   (only once registered)
  -> reference_tables/Hodel_etal_2015_InlineSupplementaryTable4_definitions.csv
```

## Table checks

Actual R run, 2026-11-11: **29 pass, 3 mismatch, 0 not evaluable** (16 significance-mark checks, 8 F→p, 8 F→η²). The three mismatches are publication inconsistencies, kept as printed and recorded as errata: `sigmark_p_Occipital_Lobe_right` (p printed `.027*`, above the p < .02 threshold; E002), and `F_to_p_Temporal_Lobe_left` (F 6.368 → p .0022 vs printed .006) with `F_to_eta_Temporal_Lobe_left` (→ η² .071 vs printed .061) (E003).

* **Significance marks.** The footnote defines `*` as p < .02. Where a p is printed (F p and EA-vs-LA p),
  the mark must appear iff p < .02. B (se) marks rest on t tests with unprinted df and are not checked.
* **F → p and F → η²,** with df = (2, df2): p = P(F > F_printed) is compared at the printed 3 decimals
  (±.001), and η²ₚ = 2F/(2F + df2) within ±.0015. df2 = 166, as printed in the main text for the ICV-adjusted models (e.g. "F(2, 166) = 3.439").


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
| Hodel_etal_2015-E002 | p_sig_mark | Inline Supplementary Table 4 (mmc4.docx), row 'Occipital Lobe' / 'right', column p | .027* |  | publication_error |  | proposed | The table footnote defines '*' as 'significant at the p<.02 level', but this p prints .027 with a star. The F distribution confirms the printed p: F(2, 166) = 3.709 gives p = .0266 (df 166 as printed in the main text for the ICV-adjusted models). Flagged by the build's table_checks (sigmark_p_Occipital_Lobe_right). | CSV keeps p_printed '.027*' and p_sig_mark '*'. The effect is not significant at the paper's own threshold. |
| Hodel_etal_2015-E003 | F | Inline Supplementary Table 4 (mmc4.docx), row 'Temporal Lobe' / 'left', columns F, p, ηpartial2 | 6.368 \| .006* \| .061 |  | publication_ambiguity |  | proposed | With df (2, 166) the printed F = 6.368 implies p = .0022 and partial eta^2 = 2F/(2F + 166) = .071, but the row prints p = .006 and eta^2 = .061. The printed p and eta^2 agree with each other (both imply F ~ 5.4) and are identical to the Occipital Lobe left row (F 5.359, p .006, eta .061). The other 19 rows of Tables 3-4 reproduce their printed p and eta^2 within rounding. Either F or the p/eta^2 pair is misprinted. The B estimates are unaffected. Flagged by the build's table_checks (F_to_p_Temporal_Lobe_left, F_to_eta_Temporal_Lobe_left). | CSV keeps the printed F, p and eta^2. |

2 recorded, 2 open (proposed), 0 confirmed, 0 withdrawn.
<!-- errata:end -->
