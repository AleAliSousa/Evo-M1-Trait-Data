# Thalamic anatomy — Mackes et al. 2020 / ERA

The outcome is **volume of the aggregate FreeSurfer thalamus segmentation**, not a single thalamic nucleus or a tissue-composition measurement.

## Primary evidence

- `Mackes_etal_2020.pdf`, PDF p. 7, MRI Data Acquisition and Processing: subcortical volumes were quantified with FreeSurfer 6.0.0.
- PDF pp. 7–8, Subcortical volumes: thalamus is listed alongside amygdala, hippocampus, accumbens, caudate, putamen and pallidum. No thalamic-nuclei subdivision procedure is reported.
- `Mackes_etal_2020_subcortical.csv` preserves the source volume summaries used by the analysis. Scaling a bilateral summary to per-hemisphere units does not change its anatomical concept into a nuclear measurement.

## Consequence for matching

Interpret the source as whole/aggregate thalamus under the standard FreeSurfer segmentation definition. The article does not enumerate the nuclei included in the mask, so exact boundary identity with other software versions or atlas labels remains unverified.

Study s2 asks about regional volume differences and should retain this valid volume outcome. Its comparability with Walhovd is a volumetric segmentation question. Pairing it with metabolism is a separate question: Heiss 2004 provides selected thalamic nuclear VOIs, not a whole-thalamus mean. Excluding an unmatched point from a metabolic regression must not delete the thalamus volume from the descriptive data, and must not be justified merely by its absence from composition studies.

Reviewed 2026-11-12 by Codex against the sources listed above. This is an anatomical provenance note, not a change to source values or a human snapshot sign-off.
