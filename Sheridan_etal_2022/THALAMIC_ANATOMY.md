# Thalamic anatomy — Sheridan et al. 2022 / BEIP follow-up

The source provides **left and right aggregate thalamus volumes** at age 16, not volumes of individual thalamic nuclei.

## Primary evidence

- Local `sciadv.abn4316_sm.pdf`, p. 10, Table S3: separate Right and Left Thalamus rows, in cm3, for CAUG, FCG and NIG. NIG means are 7.2 right and 7.9 left. The compiled bilateral 15.1 cm3 is their sum, not another independent observation.
- Main article, Methods / Gray matter analysis: FreeSurfer 5.0 at the childhood time point and 5.3 for the adolescent and longitudinal analyses; standard segmentation of deep grey matter is described. No thalamic-nuclei subdivision pipeline is reported.
- The main article PDF is not present in this folder. Its primary full text was checked at https://pmc.ncbi.nlm.nih.gov/articles/PMC9544316/ on 2026-11-12.

## Consequence for matching

This is a whole/aggregate atlas-defined thalamic outcome. Exact constituent-nucleus boundaries are not listed. Do not combine Left, Right and derived Left+Right as separate regions, or compute a bilateral SD without L/R covariance. Do not pool this follow-up with McLaughlin as an independent cohort. A matched whole-thalamus metabolic rate is still needed for a direct s2 metabolic comparison; the three-territory Heiss average is only a proxy.

Reviewed 2026-11-12 by Codex against the sources listed above. This is an anatomical provenance note, not a change to source values or a human snapshot sign-off.
