# Koay_etal_2003_ResultsText

## Source
Koay, G., Heffner, R. S., Bitter, K. S., & Heffner, H. E. (2003). Hearing in
American leaf-nosed bats. II: *Carollia perspicillata*. *Hearing Research*,
178(1-2), 27-34. doi:10.1016/S0378-5955(03)00025-X

Registry Item **Results text**, printed p. 30. Public copy:
`Koay_etal_2003/Koay-2003-Hearing in American leaf-nosed bats.pdf`.

## Why this item exists
This is the second paper in the Heffner-lab series on American leaf-nosed
bats (Phyllostomidae); the first (Koay et al., 2002) covered the greater
spear-nosed bat, *Phyllostomus hastatus* (already registered separately).
This paper reports the audiogram of the short-tailed fruit bat, *Carollia
perspicillata* -- a distinct, frugivorous phyllostomid species -- from two
subjects (Bat A, Bat B), using a conditioned suppression/avoidance
procedure. The Results text explicitly states it is reporting the same
per-bat mean values that are "listed in Table 1," but no such table is
present anywhere in the delivered PDF (checked the full text layer and
220-dpi page renders of the Results page and surrounding pages) -- the paper
as delivered contains only the Results-text sentences and the Fig. 1
audiogram plot. The eight specific frequency/threshold values named
explicitly in the Results text are captured here; additional per-frequency
points that are visible only in Fig. 1 (e.g., the individual Bat A/Bat B
curves) were not digitized, to avoid fabricating numbers beyond what the
text itself states.

## Pipeline
Printed Results-text sentences -> snapshot -> analysis csv -> public TSV.

| file | role |
|---|---|
| `Koay_etal_2003_ResultsText_snapshot.csv` | frozen source, one row per reported quantitative statement, as printed |
| `Koay_etal_2003_ResultsText.R` | reads the snapshot, writes CSV + public TSV |
| `Koay_etal_2003_ResultsText.csv` | tidy analysis rows |
| `reference_tables/Koay_etal_2003_ResultsText_definitions.csv` | data dictionary |

## Data role
All eight rows are `primary` -- this paper's own new measurements (mean of
Bat A and Bat B, as the text does not break these particular sentences out
by individual).

## Observation level
Population mean (2 bats) at seven distinct frequencies plus the derived
60-dB SPL hearing range (5.2-150 kHz, 4.85 octaves).

## Units
Frequency in kHz; threshold in dB SPL. The two `hearing_range_60dB_*` rows
record the 60-dB SPL criterion (threshold_db_spl = 60), not a separately
measured threshold at those two frequencies.
