# Ravizza_Masterton_1972_ResultsText

## Source
Ravizza, R. J., & Masterton, B. (1972). Contribution of neocortex to
sound localization in opossum (*Didelphis virginiana*). *Journal of
Neurophysiology*, 35(3), 344-356. https://doi.org/10.1152/jn.1972.35.3.344

Registry Item **Results text**, printed p. 349 (Results, Test II) and
Fig. 9 (p. 350). Public copy:
`Ravizza_Masterton_1972/Ravizza-1972-Contribution of neocortex to soun.pdf`.

## N.B. -- this is a lesion/ablation study, not a simple audiogram paper
This paper is a bilateral-neocortical-ablation behavioral study, not a
species-audiogram paper like the others built alongside it in this batch.
Twelve wild-born opossums were used: six underwent complete bilateral
neocortical ablation ("decorticate"), six were tested unoperated
("normal"). Six behavioral tests were run (pure-tone thresholds, azimuth
localization, elevation localization, and three control/scanning tests).
Read carefully, the ONE genuinely useful comparative-hearing datum this
paper reports as an explicit printed number is the **minimum audible angle
(MAA)** for horizontal (azimuth) sound-source localization -- both for
normal opossums (a real species baseline, comparable to MAA values for
other species elsewhere in this project) and for decorticate opossums (the
experimental manipulation, showing a ~5-fold loss of localization acuity
with neocortex removed, despite the animals still being able to detect
large directional shifts and to localize elevation changes normally). The
pure-tone-threshold test (Test I) is reported only qualitatively in the
text ("little effect" of decortication; no numbers given beyond a
Figure), so it is not part of this item.

## Why this item exists
The 4.6-degree normal-opossum MAA (at the paper's primary 0.5 performance
criterion) is directly comparable to other pinniped/primate/mammal MAA
values already or separately catalogued in this registry, and the paired
decorticate value (24.1 deg) documents how much of that acuity depends on
neocortex -- a foundational early result in the neurobehavioral study of
auditory cortex (Heffner, 2004, cites this paper explicitly as one of the
key demonstrations that auditory-cortex ablation impairs sound
localization but not absolute sensitivity, extending Neff's cat findings
to a marsupial).

## Pipeline
Results text + Fig. 9 axis values -> snapshot -> analysis csv -> public TSV.

| file | role |
|---|---|
| `Ravizza_Masterton_1972_ResultsText_snapshot.csv` | frozen source, one row per group x criterion |
| `Ravizza_Masterton_1972_ResultsText.R` | reads the snapshot, writes CSV + public TSV |
| `Ravizza_Masterton_1972_ResultsText.csv` | tidy analysis rows |
| `reference_tables/Ravizza_Masterton_1972_ResultsText_definitions.csv` | data dictionary |

## Data role
All four rows are this paper's own new behavioral measurements; there is
no secondary/cited data in this item. `group` distinguishes the
experimental manipulation (normal vs. bilateral neocortex ablation), which
functions here like a "primary vs. control" data-role split rather than
"primary vs. secondary-citation" as in other items in this cluster.

## Observation level
Group-mean MAA threshold (not per-individual), for four decorticate and
two normal opossums (per the Fig. 8/9 legends), computed at two different
psychophysical performance criteria (a stricter 0.5 and a more lenient 0.2
detection criterion) to show that the acuity loss from decortication does
not depend on the arbitrary choice of threshold definition.

## Units
- `maa_threshold_deg`: minimum audible angle in degrees of azimuth
  (angular separation between two sound sources at threshold detection).
- `performance_criterion`: the psychophysical detection criterion (a
  proportion, 0-1) used to define "threshold" from the underlying
  suppression-ratio psychophysical function; 0.5 is the paper's headline
  criterion, 0.2 a supplementary check.
