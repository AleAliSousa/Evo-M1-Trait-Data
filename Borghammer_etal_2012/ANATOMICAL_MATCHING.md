# Anatomical matching and convergence — 12 November 2026

Source checked: `Borghammer-2012-Glucose metabolism in small su.pdf`, Table 1 p.304, Methods/Fig.2 p.305, normalization p.306, Table2 p.307. Rendered Methods and table inspected alongside extracted text.

Table 2 reports normalized CMRglc ratios, not absolute rates. GM means global mean, not grey matter. Controls: 11 adults (8 Aarhus, 3 Cologne); use separately from the 21 PD participants. Three normalizations use the same people. Reference-cluster selection uses the PD/control comparison; predefined WM normalization is a reasonable initial convergence check, with the others as sensitivities.

The histology-derived atlas distinguishes caudate, putamen, GPe, GPi, VA, VL, CM and STN. VA/VL/CM are specific thalamic nuclei, not medial thalamus or whole thalamus. GPe/GPi cannot simply be averaged into an anatomically weighted whole-pallidum rate. Pons is a selected normalization VOI described among WM structures. The Cerebellum row is central cerebellar WHITE MATTER (Methods and Fig.2D), not cortex or whole cerebellum.

Absolute values differed significantly between centers; the authors restricted subsequent analyses to normalized values. Table S1 supplies global/reference measurements by center, not regional absolute rates. Group mean ratios cannot safely be de-normalized by multiplying a mean reference value without individual data/covariance. Do not mix Table 2 ratios into Heiss absolute-rate fits or energy budgets.

For the analysis project's Siletti metadata, six candidate named-structure matches exist: Human Pu, CaB, GPe, GPi, VA and pure CM. The first four have three donors; VA and CM each have one. Exclude Human CM-Pf (mixed nuclei); Human VLN denotes a ventral nuclear group of uncertain equivalence to VL; Human STH includes nearby tissue and should be sensitivity-only pending boundary verification. Rebuild native ROI compositions: the Heiss parent summaries pool GPe/GPi and omit VA/CM. Thalamic Human CM must not be confused with amygdalar Human CMN.

For broad MRI/SV2A regional comparisons, matching coverage is very small: Johansen and s2 have caudate/putamen; Holmes additionally has STN. This is primarily a narrow composition convergence source, not a substitute for Heiss or a remedy for the whole-thalamus gap.

Equal means of the printed control L/R means provide 10 structures per normalization (eight paired structures plus pons/cerebellar-WM rows). The eight subcortical structures have identical rank ordering across the three normalizations. These are descriptive summaries, not additional subjects. Do not invent bilateral SD: printed dispersion type and covariance are unspecified. Some subjects were reused from Eggers2009; independence from Heiss2004 is unverified.

Project assessment: `metadata/anatomy/BORGHAMMER_TABLE2_FEASIBILITY.md`; standalone audit `checks/assess_borghammer_table2.R`. Source values and primary analyses unchanged. Human source-side visual sign-off remains pending.
