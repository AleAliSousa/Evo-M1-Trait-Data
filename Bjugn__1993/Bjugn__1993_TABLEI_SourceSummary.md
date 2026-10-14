# Bjugn__1993_TABLEI: source reading and discrepancy summary

- Source: printed TABLE I, p.26 (PDF page 2); all values from the held paper, not its web abstract.
- Reader: Microsoft Copilot AI assistant, 2026-10-10 (America/Los_Angeles / Pacific). AI visual inspection is not human visual curation.
- Caption verified against rendered PDF. TABLE I has Roman I; OCR's TABLE 1 is not followed. Existing item token remains unchanged.
- Footer labels are **Mean, SD, CV**, in that order. Neither table has a Total footer; TABLE II's **Σ columns** are per-compartment total cell estimates, not footer records.
- TABLE II OCR commas in E (animals 2 and 3), gray N (animal 3), and gray N CV are printed decimal points in the rendered page. The frozen strings follow the print, not OCR punctuation.
- Printed cells and summary values retained without silently recomputing Mean/SD/CV. Independent PDF text parsing and frozen-to-preview Python checks are numerical checks, not an R build or an independent human review.
- Source legibility: rendered captions, units, nuclei class symbols, all 5 animal rows and 3 summary rows legible; OCR misreads Roman I, Σ and some decimal points. No missing-value tokens or footnote superscripts occur in these two tables.
- Author states no correction for volumetric changes during tissue processing (p.31). None invented here; ependymal cells are excluded from cell-number estimates.
- Primary data are the **same five adult male albino mice**, not five new animals per table or ten animals. Rat comparisons refer to an earlier paper and supply no rows here.
- Fresh owner source-label/DOI review is pending. Only one article DOI applies: 10.1016/0006-8993(93)90744-8. TABLE II's existing -9 code is wrong; the owner must repair existing-row citation/column C and refresh formula authority. No new registration, public TSV, pool or merge is authorized.
- R runtime absent: audit/dry-run/build/validate and source()/sys.source()/Rscript execution all **NOT RUN**. Future exact-item clean-session R validation and independent review remain required.

## Published summary rounding (not repairs)

All printed means equal the arithmetic means of the displayed animal rows. Printed SDs agree at their published precision with sample SDs from those rows. CVs are kept as printed; several agree more closely with **printed rounded SD / printed mean** than with unrounded sample SD / mean. For example, white-matter U in TABLE II prints SD 0.16, mean 0.60 and CV 0.267, while the unrounded sample SD/mean is approximately 0.263523. This difference is recorded, not overwritten. No exact equality to recomputed CV is claimed.
