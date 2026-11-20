# Itoh et al 2001 Figure 2

Itoh Y, Esaki T, Kaneshige M, Suzuki H, Cook M, Sokoloff L, Cheng SY, Nunez J (2001). Brain glucose utilization in mice with a targeted mutation in the thyroid hormone alpha or beta receptor gene. PNAS 98:9913-9918. DOI: 10.1073/pnas.171319498.

## Source and observation level

Figure 2, printed p.9916, PDF page 4 of Itoh-2001-Brain glucose utilization in mice wi.pdf. The item name and public TSV stem come from the owner-provided __ReadMeAddON.xlsx, matched by Item name. The main registry is preferred once the owner registers the prepared row. Neither workbook was edited.

All 19 regions and all three groups are retained: young wild-type (n=3), young TRbetaPV/PV (n=3), young TRalphaPV/+ (n=4), giving 57 regional group means. They are not independent animal observations or pooled species means. WT age is 32 +/-1 days (SEM, Table 1); beta-mutant age is 32 +/-1 and alpha-mutant age 29 +/-1. Sex and strain are not specified for these metabolic cohorts. The mice were measured without ongoing anesthesia after at least three hours of recovery from surgical halothane, with locomotion prevented by a plaster cast. Food and water were available ad libitum. Experimental context is stored separately from the figure snapshot.

## Source to snapshot

Codex AI assistant read the figure on 2026-11-20. pdfimages extracted the native one-bit 2030 x 1558 bitmap (PDF object 27, nominal 300 dpi), preserved unchanged in reference_tables. The independent mean-edge and upper-error-end coordinates, plotted-region order, axis ticks, baseline drift points and printed percentages are retained there. The physical bar order is WT, alpha mutant, beta mutant; the legend and constructed snapshot column order is WT, beta mutant, alpha mutant. This distinction was checked visually.

The axis is linear. The rate-per-pixel scale is fitted to the seven printed y ticks, with zero fixed at the observed baseline; a line fitted to eight baseline points accounts for the small raster tilt. No percentage is used to determine a mean or to adjust a bar height. The reading halfwidth is +/-3 native pixels (about +/-0.36 umol/100g/min). The snapshot builder refuses to overwrite a differing frozen snapshot. The digitization review overlays mean edges in blue (WT), green (beta), orange (alpha), upper-error endpoints as crosses, and axis ticks in magenta. Human RA visual signoff remains pending; AI review is not a human signature.

Figure 2 does not specify whether error bars are SEM or SD. Their upper endpoints and lengths are preserved with the type explicitly unspecified. The SEM statement accompanying Table 1 is not transferred to Figure 2. These bars are not used as biological sampling distributions in the downstream digitization-only sensitivity analysis.

## Snapshot to analysis data

The separate item R reader reads only its own constructed snapshot for scientific values. It reshapes the 19-region wide snapshot to 57 rows and converts original umol/g/min to umol/100g/min by multiplying by 100. Printed labels, percentages and double-asterisk marks are retained. Rates are approximate figure estimates, not exact source tables. Definitions use the project ten-column schema. A proposed General species-key row preserves the printed wording mice; no global key or species merge has been edited.

## Table checks

Actual R run: 19 pass, 0 mismatch for the internal relation 100 x (alpha-mutant mean / WT mean - 1), compared with the 19 printed percentages. The allowance is whole-percent rounding (+/-0.5 percentage points) plus propagated independent +/-3-pixel reading bounds on the two means. Full residuals remain visible in table_checks when the reader runs and in the nonhuman analysis output printed_percentage_checks.csv. No value was changed to make a check pass.

Maximum absolute percentage residual: 1.149 percentage points. 13 of 19 are within +/-0.5 percentage points without a digitization allowance. The remaining differences are within the independently specified reading bounds.

No independent numeric table exists for a zero-mismatch external comparison; no public comparison directory is created. The source checks validate extraction, not physiological generalization or anatomical matching.

## Build and registry

Run Itoh_etal_2001_Figure2_snapshot.R only to reproduce the frozen capture; run Itoh_etal_2001_Figure2.R to regenerate the local CSV and DOI-coded public TSV. Item encoded is looked up by Item name in __ReadMe.xlsx, falling back to __ReadMeAddON.xlsx while registration is pending. The prepared registry-row workbook preserves the owner-provided citation, item number and original title, and leaves formula-owned E-L blank for owner paste. Human visual signoff and main-registry paste are pending.

The CSV is a primary experimental item. Young and mutant arms must not be silently added to an adult baseline mean. The present request builds the item and uses WT for an age-matched anatomical comparison; it does not rerun the global adult metabolic-rate merge.
