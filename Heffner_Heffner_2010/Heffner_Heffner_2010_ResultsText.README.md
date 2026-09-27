# Heffner_Heffner_2010_ResultsText

## Source
Heffner, Jr., H., & Heffner, H. E. (2010). The behavioral audiogram of
whitetail deer (*Odocoileus virginianus*). *Journal of the Acoustical
Society of America*, 127(3), EL111-EL114. doi:10.1121/1.3284546

Registry Item **Results text**, printed p. EL111 (Abstract/Results).
Public copy: `Heffner_Heffner_2010/Heffner-2010-The behavioral audiogram of
white.pdf`.

**Folder-identity note (important):** the task that generated this batch
flagged a known risk of mixing up this folder with `Heffner_etal_2010`.
Both folders were freshly listed via `GetDriveChildren` immediately before
opening either PDF:
- `Heffner_Heffner_2010/` (2-author, matching this folder's name) ->
  `Heffner-2010-The behavioral audiogram of white....pdf`, which is this
  **whitetail deer** audiogram paper -- the truncated filename "white..."
  is the start of "white**tail deer**," not "white rhinoceros" as an
  initial guess suggested.
- `Heffner_etal_2010/` (3-author) -> a *different* paper, "Use of binaural
  cues for sound localization..." (built separately as
  `Heffner_etal_2010_TableI`).
- `Heffner_Heffner_2010_b/` contains a small, separate, already-registered
  candidate-row PDF handled by a different agent; it was not opened or
  touched by this build.

These are three confirmed-distinct items with three distinct DOIs
(10.1121/1.3284546 here; 10.1121/1.3372717 for `Heffner_etal_2010`; a
third, unexamined DOI for `Heffner_Heffner_2010_b`). No cross-contamination
occurred.

## Why this item exists
This JASA Express Letter reports the first full behavioral audiogram of
white-tailed deer, the wild North American ungulate with the largest
economic/human-safety impact of any wild mammal (deer-vehicle collisions,
Lyme disease, hunting economics). Only auditory brainstem response (ABR)
data existed previously for this species; ABR does not give an accurate
measure of absolute sensitivity, so this behavioral audiogram is the first
reliable comparative hearing-sensitivity data point for the species. The
core reported numbers (best frequency/threshold, 60-dB-SPL hearing range,
and the wider range measured at higher stimulus intensities) are stated
directly in the Abstract and Results text; there is no printed data table
in this short-format letter (Fig. 1 shows the audiogram curve only).

## Pipeline
Results-text values -> snapshot -> analysis csv -> public TSV.

| file | role |
|---|---|
| `Heffner_Heffner_2010_ResultsText_snapshot.csv` | frozen source, values as printed in Abstract/Results |
| `Heffner_Heffner_2010_ResultsText.R` | reads the snapshot, writes CSV + public TSV |
| `Heffner_Heffner_2010_ResultsText.csv` | one row (this species) |
| `reference_tables/Heffner_Heffner_2010_ResultsText_definitions.csv` | data dictionary |

## Data role
Primary -- this paper's own new measurement (this study), the only row in
this item.

## Observation level
Species mean threshold, averaged across 2 female whitetail does
(1-2 years old, domestically raised); the paper's Fig. 1 shows the average
of the two deer as its solid line.

## Units
Frequency in kHz (Hz for values under 1 kHz, matching the paper's own
convention); threshold/sensitivity in dB SPL (re 20 uN/m^2), conditioned
suppression/avoidance procedure, 50%-detection (corrected for false
positives) threshold criterion. Two hearing-range figures are given: the
standard 60-dB-SPL range (115 Hz-54 kHz) used for cross-species comparison
throughout this registry cluster, and the paper's own wider "absolute
range" figures at higher stimulus intensities (32 Hz at 96.5 dB to 64 kHz
at 93 dB) which bound the species' true absolute limits of hearing.
