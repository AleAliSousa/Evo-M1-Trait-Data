# Thalamic anatomy — Holmes et al. 2024

The thalamus is the **AAL atlas-defined thalamic ROI**, not a named thalamic subnucleus.

## Primary evidence

- `Holmes-2024-Synaptic loss and its association.pdf`, PDF pp. 7–8, Quantitative analysis: thalamus is a secondary ROI; ROIs come from Anatomical Automatic Labeling for SPM2 (AAL), with explicit exceptions for substantia nigra, locus coeruleus and raphe. Thalamus is not one of these exceptions.
- PDF p. 8: Müller-Gärtner partial-volume correction applies to cortical regions, the named striatal regions, and cerebellum. Thalamus is absent from that list; it is not among the PVC-corrected ROIs.
- `41531_2024_655_MOESM1_ESM.pdf`, p. 2, Supplementary Table 2: HC thalamus BPND 2.31 ± 0.39 (n=30), PD 2.12 ± 0.42. Healthy replication uses HC only.
- Existing `reference_tables/Holmes_etal_2024_SupplementaryTable2_region_methods.csv` already records the AAL origin and PVC status; this note expands the cross-study anatomical interpretation.

## Consequence for matching

This is an aggregate atlas-label value, not mediodorsal-only or geniculate-only. The article does not enumerate the nuclei included by its thalamus mask; AAL and FreeSurfer labels should not be assumed voxel-identical. Heiss's selected nuclear VOIs, especially their arbitrary unweighted average, are anatomical proxies for this ROI. Keep BPND separate from Johansen's calibrated Bmax scale, and retain the regional PVC difference when interpreting the replication.

Reviewed 2026-11-12 by Codex against the sources listed above. This is an anatomical provenance note, not a change to source values or a human snapshot sign-off.
