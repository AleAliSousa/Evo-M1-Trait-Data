# Flydal_etal_2001_Table2

## Source
Flydal, K., Hermansen, A., Enger, P. S., & Reimers, E. (2001). Hearing in
reindeer (*Rangifer tarandus*). *Journal of Comparative Physiology A*, 187,
265-269. https://doi.org/10.1007/s003590100198

Registry Item **Table 2**, "Individual hearing thresholds with sound from
the front and sound from behind the animal," printed p. 267. Public copy:
`Flydal_etal_2001/Flydal-2001-Hearing in reindeer (Rangifer tara.pdf`.

## Why this item exists
The first published reindeer (*Rangifer tarandus tarandus*) audiogram, from
two 14-month-old semi-domestic males tested with a conditioned
suppression/avoidance method (drinking-bowl paradigm), at 11 frequencies
(63 Hz-38 kHz), with the sound source placed either in front of or behind
the animal. Table 2 is the paper's actual printed per-animal, per-direction
threshold data -- the more commonly quoted headline numbers (60-dB hearing
range ~70 Hz-38 kHz; best sensitivity 3 dB at 8 kHz, stated in the Abstract)
are the *averaged* front+behind audiogram shown only as a figure (Fig. 1);
Table 2 is the actual numeric data underlying that average and is
transcribed here in preference to digitizing the figure, per house rule.

## Pipeline
Printed table -> snapshot -> analysis csv -> public TSV.

| file | role |
|---|---|
| `Flydal_etal_2001_Table2_snapshot.csv` | frozen source, printed layout |
| `Flydal_etal_2001_Table2.R` | reads the snapshot, writes CSV + public TSV |
| `Flydal_etal_2001_Table2.csv` | tidy analysis rows |
| `reference_tables/Flydal_etal_2001_Table2_definitions.csv` | data dictionary |

## Data role
Primary for all rows -- this is the paper's own new behavioral audiogram
data for both reindeer.

## Observation level
Per-individual-animal x per-sound-direction x per-frequency (2 reindeer x 2
directions x 11 frequencies = 44 rows; one cell, Reindeer 1 / front / 38
kHz, was not tested/reported and is printed as "-" in the source, kept as
NA here).

## Units
Thresholds in dB re 20 uPa (the modern SPL reference; the paper's methods
state SPL was measured re. 20 uPa with a Bruel & Kjaer 2231 sound-level
meter). Frequency in Hz (also given in kHz). Negative values (e.g. -1 dB for
Reindeer 1, behind, at 8 kHz) indicate a threshold below the 20 uPa
reference, i.e. very high sensitivity.

## Verification
This PDF's extracted text layer is corrupted (font/glyph mapping produces
control characters instead of readable text throughout the document). Table
2 was therefore transcribed entirely from a 150-dpi page render and checked
digit-by-digit a second time against the same image before finalizing. The
abstract's summary values (60-dB range ~70 Hz-38 kHz, best sensitivity 3 dB
at 8 kHz) were confirmed legible directly from the rendered title page and
are quoted in this README for context, but are not themselves printed table
cells and are not included as rows in the analysis CSV (only the
individual-animal Table 2 values are).

## N.B. / anomalies
Reindeer 1's threshold at 38 kHz with sound from the front is printed as
"-" in the source table (not tested, or no reliable threshold obtained) --
kept as a missing value (NA), not fabricated or interpolated.
