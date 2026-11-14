# Thalamic anatomy — Johansen et al. 2024

The tabulated thalamus is a **FreeSurfer-defined subcortical ROI**, not an isolated medial, mediodorsal, or geniculate nucleus.

## Primary evidence

- `Johansen-2024-An In Vivo High-Resolution Human.pdf`, PDF p. 2, Image processing: FreeSurfer 7.2 / PETSurfer and recon-all; subcortical time-activity curves were extracted from nonsmoothed data. Thalamus is explicitly listed among the FreeSurfer subcortical regions.
- PDF p. 5, Table 2: Thalamus SV2A total 352 ± 55 pmol/mL; left 353 ± 55, right 351 ± 57. This is a regional SV2A-density estimate, not thalamic volume or a nucleus-specific estimate.

## Interpretation and limits

Treat this as the aggregate atlas-defined thalamic label. The paper does not supply nucleus-level inclusion/exclusion rules or identify a mediodorsal-only measurement. A whole FreeSurfer label need not coincide exactly with a histological whole-thalamus boundary or the AAL/Hammers definitions in other PET studies. The image-processing Methods, not the short table label alone, establish the ROI scope.

Heiss 2004's medial-thalamic VOI and its derived three-territory mean are not exact matches. A future nucleus-specific atlas extraction would be a new analysis and needs the actual spatial maps and a justified parcellation.

## Additional mapping correction discovered during this check

The same Methods explicitly names **cerebellum cortex**. Therefore the Table 2 Cerebellum row should be mapped to cerebellar cortex, rather than described as a whole-cerebellum proxy. This correction concerns the source anatomy; it does not change the numeric value.

Reviewed 2026-11-12 by Codex against the sources listed above. This is an anatomical provenance note, not a change to source values or a human snapshot sign-off.
