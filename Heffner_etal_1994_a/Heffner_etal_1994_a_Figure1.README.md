# Heffner_etal_1994_a_Figure1

## Source
Heffner, R. S., Heffner, H. E., Contos, C., & Kearns, D. (1994). Hearing in
prairie dogs: transition between surface and subterranean rodents. *Hearing
Research*, 73, 185-189. doi:10.1016/0378-5955(94)90233-x

Registry Item **Figure 1**, printed p. 187 (audiograms for four black-tailed
prairie dogs, A-D). Public copy:
`Heffner_etal_1994_a/Heffner_etal_1994_a.pdf`.

## Why this item exists
Companion item to `Heffner_etal_1994_a_Figure2` (priority 1 for this folder,
the white-tailed prairie dog). This item covers the paper's other tested
species, four black-tailed prairie dogs (*Cynomys ludovicianus*). It was
built alongside the priority-1 item because its summary values are stated in
the same Results paragraph on the same page, making it a trivial addition
rather than a separate digitization effort.

## Pipeline
As with the companion item, the registry item is nominally "Figure 1" but the
values used here were taken from the Results text (p. 187), not digitized
from the four individual audiogram curves: "thresholds between 500 Hz and 8
kHz varying by less than 10 dB. The lowest average threshold was 20.3 dB SPL
at 4 kHz. The range of frequencies audible at 60 dB SPL extended from 29 Hz
to 26 kHz for the black-tailed prairie dogs." Individual-level thresholds by
frequency for animals A-D are only available in the plotted figure and were
not digitized (not needed for any currently-used SensoryData_compiled value).

| file | role |
|---|---|
| `Heffner_etal_1994_a_Figure1_snapshot.csv` | frozen source, values as printed in the Results text |
| `Heffner_etal_1994_a_Figure1.R` | reads the snapshot, writes CSV + public TSV |
| `Heffner_etal_1994_a_Figure1.csv` | tidy analysis row |
| `reference_tables/Heffner_etal_1994_a_Figure1_definitions.csv` | data dictionary |

## Data role
Single row, primary (this paper's own new measurement, averaged across the
four individually-tested animals).

## Observation level
Group summary (mean across 4 individually-labeled animals, A-D); not
per-individual. Animals A and B (non-hibernating) were tested down to the
species' overall low-frequency extreme (4 Hz); two additional individuals
were tested only in the midrange (owing to hibernation before testing could
be extended).

## Units
Sensitivity/threshold in dB SPL (re 20 uN/m^2 as printed); frequency in Hz/kHz
as printed for each field.

## Verification and anomaly note
Source PDF has an imperfect OCR text layer (scanned reprint). The
extracted text layer misread the frequency of the lowest average threshold
as "3 kHz"; a 250-dpi render of PDF page 3 (printed p. 187) was checked and
the printed page unambiguously reads "**4 kHz**", which is the value used
here. This is a correction of an OCR extraction error made during this
build, not an alteration of anything the source itself states -- the
printed page was never in conflict with itself. All other values (20.3 dB,
500 Hz, 8 kHz, 10 dB, 4 Hz, 29 Hz, 26 kHz) were also cross-checked against
the same page image and match exactly.
