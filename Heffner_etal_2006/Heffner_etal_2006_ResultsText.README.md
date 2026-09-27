# Heffner_etal_2006_ResultsText

## Source
Heffner, R. S., Koay, G., & Heffner, H. E. (2006). Hearing in large
(*Eidolon helvum*) and small (*Cynopterus brachyotis*) non-echolocating
fruit bats. *Hearing Research*, 221, 17-25. doi:10.1016/j.heares.2006.06.008

Registry Item **Results text**, printed pp. 20-21 (Sections 3.1 and the
*C. brachyotis* results paragraph). Public copy:
`Heffner_etal_2006/Heffner-2006-Hearing in large (Eidolon helvum).pdf`.

## Why this item exists
This paper reports the first full behavioral audiograms for two
non-echolocating Old World fruit bats (Pteropodidae): the large,
straw-colored fruit bat (*Eidolon helvum*, 230-350 g) and the small,
dog-faced fruit bat (*Cynopterus brachyotis*, 30-45 g). The paper's main
comparative point -- used throughout its Discussion -- is the difference in
high-frequency hearing between these two body sizes among non-echolocators,
and how that compares with echolocating bats. No printed table of these
summary values exists in the paper (Figs. 2-4 show the audiogram curves
only); the core numbers are stated directly in the Results text and are
transcribed here.

## Pipeline
Results-text values -> snapshot -> analysis csv -> public TSV.

| file | role |
|---|---|
| `Heffner_etal_2006_ResultsText_snapshot.csv` | frozen source, values as printed in Results text |
| `Heffner_etal_2006_ResultsText.R` | reads the snapshot, writes CSV + public TSV |
| `Heffner_etal_2006_ResultsText.csv` | one row per species (2) |
| `reference_tables/Heffner_etal_2006_ResultsText_definitions.csv` | data dictionary |

## Data role
Both rows are this paper's own new measurements (primary); no comparison
species are reported in this particular item (the paper's Fig. 4 compares
the two species' averaged audiograms directly to each other, but that
comparison is between the paper's own two primary measurements, not a
secondary/cited value).

## Observation level
Species mean (average of the tested individuals): 2 male *E. helvum* (one
9.5-year-old, one younger; "Bat A"/"Bat B") and 2 male *C. brachyotis*.
Individual per-bat thresholds at the lowest tested frequency are given for
*E. helvum* only (84.5 dB and 77 dB at 800 Hz for Bat A/Bat B respectively);
elsewhere the paper reports averaged thresholds.

## Units
Frequency in kHz; threshold/sensitivity in dB SPL (re 20 uN/m^2, conditioned
suppression/avoidance procedure, corrected-performance = 0.50 criterion).
The 60-dB-SPL hearing range and its octave span are the paper's own
operational definition of "hearing range" used throughout the Heffner lab's
comparative audiogram series.

## N.B. / flagged anomaly
For *Eidolon helvum*, the paper's printed 60-dB octave span is 4.82 octaves,
computed from the printed (rounded) boundary values of 1.38 and 41 kHz.
Recomputing log2(41/1.38) from those same rounded values gives ~4.89
octaves, not 4.82 -- a small (~0.07-octave) rounding discrepancy, most
likely because the paper's internal calculation used unrounded raw
threshold-crossing frequencies rather than the rounded values printed in
the text. This was **not** corrected; the printed 4.82 value is kept as-is
in the snapshot/analysis CSV, per house rule against silently fixing
printed numbers. (For *C. brachyotis*, the printed 4.73 octaves reproduces
almost exactly from 2.63-70 kHz, so no similar flag applies to that row.)
