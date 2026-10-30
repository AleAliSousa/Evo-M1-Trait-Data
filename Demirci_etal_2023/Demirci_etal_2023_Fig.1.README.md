# Demirci et al. 2023 — Fig. 1 (12-primate MRI cortical surfaces + cerebral volumes)

Demirci N, Hoffman ME, Holland MA (2023). *Systematic cortical thickness and curvature patterns in
primates.* NeuroImage 278:120283. doi:10.1016/j.neuroimage.2023.120283.

Registry (`__ReadMe.xlsx`): Item **`Demirci_etal_2023_Fig.1`**, encoded
`10.1016%2Fj.neuroimage.2023.120283_Fig.1`. Progress stage / Snapshot cells still blank — set on
next registry sitting.

## What the data are
Total pial cortical **surface area (SA, cm²)** and **cerebral volume (V, cm³)** for 12 primate
species (galago → human), printed under each species' reconstructed cortical surface in Fig. 1.
MRI surface reconstructions (mixed postmortem 7T / in-vivo scans; Freesurfer and species-adapted
pipelines — Table 1). 12 rows.

**Both-hemispheres warning:** SA and V are whole-cerebrum totals — **halve SA for the merge's
per-hemisphere convention** (Kaskan review sheet / roadmap item 2). Cerebellum + brain stem removed.
For the multi-subject species (rhesus n=31 PRIME-DE, chimp n=54 NCBR, human n=501 ABIDE-I) Fig. 1
prints a single representative/average value; per-subject spreads are in the paper's Fig. 8, not here.

## Source → Snapshot → Data readable
SA/V read from the vector text of the publisher's full-resolution Fig. 1
(`1-s2.0-S1053811923004342-gr1_lrg.jpg`, in this folder) into sheet `Fig1` of
`Demirci_etal_2023_Fig.1_snapshot.xlsx`; subject context (N, sex, age, scan status, source archive)
transcribed from Table 1 onto sheet `Table1` ("Homo Sapiens" capitalization kept as printed there,
normalized to *Homo sapiens* in cleaning). `Demirci_etal_2023_Fig.1.R` →
`Demirci_etal_2023_Fig.1.csv` (**use this**). Columns in
`reference_tables/Demirci_etal_2023_Fig.1_definitions.csv`.
Built offline 2026-08-31 (Python mirror; no R in sandbox) — **re-run the .R in RStudio to confirm**
(expect byte-identical CSV/TSV).

## Merge note — NOT yet wired
Candidate for `__merging_cortical_areas` (whole-cortex surfaces; halve first). Aotus here is
*A. lemurinus* — check the merge's existing Aotus species usage before matching. *Gorilla gorilla*
and *Sapajus apella* printed as such. Thickness/curvature/GI values from later figures are not part
of this item.

Pipeline: Source ✅ → Snapshot ✅ → Data readable ✅ → Registry stage cells ⬜ → R rerun ⬜ → Merge ⬜
