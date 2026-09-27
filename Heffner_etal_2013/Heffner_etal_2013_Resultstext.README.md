# Heffner_etal_2013_Resultstext

## Source
Heffner, R. S., Koay, G., & Heffner, H. E. (2013). Hearing in American
leaf-nosed bats. IV: the Common vampire bat, *Desmodus rotundus*. *Hearing
Research*, 296, 42-50. doi:10.1016/j.heares.2012.09.011

Registry Item **Results text**, printed p. 45 (audiogram summary) and
Discussion section 4.3.1, p. 47 (functional interaural distance). Public
copy: `Heffner_etal_2013/Heffner_etal_2013.pdf`.

## Why this item exists
This is the priority-1 item for the folder: it captures the four headline
*D. rotundus* values SensoryData_compiled uses, directly from the paper's
own printed Results/Discussion text, rather than digitizing the companion
Fig. 2 pure-tone audiogram (registered separately, lower priority, as
`Heffner_etal_2013_Figure2`, row 511).

## Pipeline
Row 1 (*Desmodus rotundus*) values transcribed directly from the born-
digital PDF's text layer:
- "At an intensity of 60 dB SPL, the hearing of D. rotundus ranges from 716
  Hz to 113 kHz, a span of 7.3 octaves." (p. 45; independently verified:
  log2(113/0.716) = 7.30, matching the printed 7.3 octaves)
- "the average best hearing of three Common vampire bats of 5 dB at 20 kHz"
  (p. 45)
- "The Common vampire bat, with an interaural distance of only 61 us" (p.
  47; verified against a 200-dpi page render because the plain-text
  extraction rendered the printed mu sign as "m", i.e. "61 ms" -- the actual
  printed page reads "61 us")

Row 2 (*Phyllostomus hastatus*) is a **derived secondary value**, included
because SensoryData_compiled attributes a "hearing_range: Phyllostomus
hastatus = 5.9 octaves" fact to this paper, per the task brief for this
build. No single sentence in this PDF states that octave span directly. It
was reconstructed here from two numbers this paper DOES state for that
species:
- low-frequency limit "hears only down to about 1.77 kHz at 60 dB SPL"
  (Discussion, p. 46)
- high-frequency limit 105.0 kHz, this paper's own Table 1 ("Observed
  high-frequency hearing limit", *Phyllostomus hastatus* row, sourced there
  to Koay et al., 2002)
- octaves = log2(105.0 / 1.77) = 5.89, rounds to **5.9**, matching
  SensoryData_compiled's figure and confirming that this is indeed how that
  number was originally derived.
- The 108 us functional interaural distance for *P. hastatus* IS directly
  text-stated in this paper's Fig. 4 label (p. 46) -- and independently
  cross-confirmed against the same species' interaural distance printed in
  the companion `Heffner_etal_2003` paper's Fig. 4 (also 108 us there, for
  comparison -- see that item's README for the *A. jamaicensis* 96 us
  cross-check).

| file | role |
|---|---|
| `Heffner_etal_2013_Resultstext_snapshot.csv` | frozen source, values as printed / derived-and-labeled |
| `Heffner_etal_2013_Resultstext.R` | reads the snapshot, writes CSV + public TSV (includes an arithmetic sanity check) |
| `Heffner_etal_2013_Resultstext.csv` | tidy analysis rows |
| `reference_tables/Heffner_etal_2013_Resultstext_definitions.csv` | data dictionary |

## Data role
Row 1 (*D. rotundus*) is primary (this paper's own new measurement, n=3
bats A/B/C). Row 2 (*P. hastatus*) is secondary and explicitly derived (see
above), not a directly-quoted single value.

## Observation level
Row 1: group summary (mean of 3 individually-tested *D. rotundus*). Row 2:
species-level summary compiled from two different reported statistics in
this same paper (no new individual-level data).

## Units
Sensitivity/threshold in dB SPL; frequency in kHz; hearing range in octaves;
functional interaural distance in microseconds.

## Flags / anomalies (kept as printed, not silently corrected)
1. **Internal 716 Hz vs. 710 Hz inconsistency.** The Abstract and Results
   (p. 45) both state the *D. rotundus* 60-dB low-frequency limit as **716
   Hz**, but the Discussion (p. 45, comparing to Inferior Colliculus
   recordings) separately states "the behavioral hearing limit of **710
   Hz** at 60 dB" for the same species/study. This is an internal
   inconsistency within the source paper itself. 716 Hz (the paper's
   primary Abstract/Results summary statement) is used as the recorded
   value here; the 710 Hz mention is flagged, not silently reconciled or
   corrected.
2. **Row 2 is a derived value, not a direct quotation** -- see Pipeline
   section above for the full calculation and its two source statements.
