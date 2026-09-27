# Heffner_etal_2003_Resultstext

## Source
Heffner, R. S., Koay, G., & Heffner, H. E. (2003). Hearing in American
leaf-nosed bats. III: *Artibeus jamaicensis*. *Hearing Research*, 184,
113-122. doi:10.1016/s0378-5955(03)00233-8

Registry Item **Results text**, printed p. 116 (audiogram summary) and Fig. 4
p. 117 (functional interaural distance label). Public copy:
`Heffner_etal_2003/Heffner_etal_2003.pdf`.

## Why this item exists
This is the priority-1 item for the folder: it captures the three headline
values SensoryData_compiled uses for *A. jamaicensis* directly from the
paper's own printed Results, rather than digitizing the companion Fig. 4
audiogram (registered separately, lower priority, as
`Heffner_etal_2003_Figure4`, row 506).

## Pipeline
Values transcribed directly from the born-digital PDF's text layer (no OCR
issues -- checked with `pdftotext`, clean output):
- "Beginning with a threshold of 88 dB at 1 kHz, sensitivity increased
  rapidly ... with the lowest mean threshold of 8.5 dB at 16 kHz." (p. 116)
- "At a level of 60 dB SPL, the audiogram extends from 2.8 to 131 kHz, a
  range of 5.5 octaves." (p. 116) -- independently checked:
  log2(131/2.8) = 5.55, consistent with the printed 5.5 octaves.
- Functional interaural distance: read from the Fig. 4 label (p. 117),
  "*Artibeus jamaicensis* (96 us)" -- see flag below.

| file | role |
|---|---|
| `Heffner_etal_2003_Resultstext_snapshot.csv` | frozen source, values as printed |
| `Heffner_etal_2003_Resultstext.R` | reads the snapshot, writes CSV + public TSV |
| `Heffner_etal_2003_Resultstext.csv` | tidy analysis row |
| `reference_tables/Heffner_etal_2003_Resultstext_definitions.csv` | data dictionary |

## Data role
Single row, primary (this paper's own new measurement, n=3 bats, A/B/C).

## Observation level
Group summary (mean of 3 individually-tested *A. jamaicensis*); not
per-individual.

## Units
Sensitivity/threshold in dB SPL; frequency in kHz; hearing range in octaves;
functional interaural distance in microseconds (time for sound to travel
around the head between the two ears, as defined on p. 117).

## Flag / anomaly -- interaural distance discrepancy (not resolved)
The pre-existing registry draft and SensoryData_compiled's currently-used
value for *A. jamaicensis* functional interaural distance is **89 us**. This
build re-read the actual PDF (Fig. 4, p. 117, rendered at 220 dpi and
visually inspected) and the printed label unambiguously reads "*Artibeus
jamaicensis* (**96 us**)" -- not 89. No occurrence of "89" appears anywhere
in this PDF's extracted text or in the figure. Per house rules (never
fabricate; use the value the source actually states, flag rather than
silently reconcile), **96 us** is the value recorded in this item's CSV, and
the discrepancy with the previously-assumed 89 us is flagged here for
follow-up -- it was not resolved or back-corrected into SensoryData_compiled
as part of this build.
