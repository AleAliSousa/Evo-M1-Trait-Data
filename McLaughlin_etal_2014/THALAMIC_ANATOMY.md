# Thalamic anatomy — McLaughlin et al. 2014 / BEIP

Table 4 reports **aggregate MRI thalamus volume**, not a named thalamic nucleus.

## Primary evidence

- `McLaughlin-2014-Widespread reductions in corti.pdf`, printed p. 630 / PDF p. 2, Image Processing: cortical reconstruction and volumetric segmentation use FreeSurfer 5.0.
- Printed p. 634 / PDF p. 6, Table 4: a single Thalamus row, with EIG mean 14465.7 and NIG mean 15046.2. The paper does not report thalamic subnuclei.
- Table 4 does not print volume units or hemisphere basis. The existing item README appropriately preserves this uncertainty. Bilateral mm3 is consistent with the magnitude but remains an inference, not an explicit printed definition.

## Consequence for matching

Treat the anatomy as the aggregate FreeSurfer thalamic label; do not equate it to Heiss's medial VOI. Within-table percent group differences do not require assuming an absolute volume unit, provided both groups share the published measurement definition. They are descriptive raw-mean contrasts, not the paper's covariate-adjusted effect estimates. This BEIP sample overlaps the later Sheridan follow-up and is independent of ERA, not an additional independent BEIP cohort.

Reviewed 2026-11-12 by Codex against the sources listed above. This is an anatomical provenance note, not a change to source values or a human snapshot sign-off.
