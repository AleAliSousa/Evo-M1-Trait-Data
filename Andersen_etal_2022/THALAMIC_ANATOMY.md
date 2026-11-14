# Thalamic anatomy — Andersen et al. 2022

Thal is an **aggregate bilateral Hammers-atlas thalamic VOI** used for both FDG and UCB-J measurements in the same participants, not a mediodorsal-only ROI.

## Primary evidence

- `Andersen-2022-Healthy brain aging assessed wit.pdf`, PDF p. 2, image-analysis Methods: standard Hammers N30R83 atlas VOIs; bilateral regions were combined into larger regions and verified by overlay on each participant's MRI. Thal is defined as thalamus in the list of analysis regions.
- VOI-based geometric-transfer-matrix partial-volume correction was applied. FDG is reported as SUVR with CSO and/or grey-matter reference normalization; UCB-J normalization is described separately.
- PDF p. 5, Fig. 3: FDG and UCB-J comparisons include Thal in the same healthy cohort (N=26).

## Consequence for matching

This offers a more coherent within-study, matched-VOI comparison of metabolic and synaptic markers than combining a whole thalamic SV2A ROI with three selected Heiss nuclei. However, FDG SUVR is not an absolute rCMRGlc value. Use this as a separate replication on its native scale, not as a single replacement absolute rate spliced into the Heiss vector. The article does not enumerate nucleus-level inclusion rules for the thalamic mask; exact equivalence to FreeSurfer or AAL remains unverified.

Reviewed 2026-11-12 by Codex against the sources listed above. This is an anatomical provenance note, not a change to source values or a human snapshot sign-off.
