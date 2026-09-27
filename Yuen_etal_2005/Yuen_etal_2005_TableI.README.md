# Yuen_etal_2005 — Table I (behavioral audiograms of a false killer whale)

## Source
Yuen, M. M. L., Nachtigall, P. E., Breese, M., & Supin, A. Ya. (2005).
Behavioral and auditory evoked potential audiograms of a false killer whale
(*Pseudorca crassidens*). *Journal of the Acoustical Society of America*,
118(4), 2688-2695. doi:10.1121/1.2010350

Registry Item **Table I**, "Auditory threshold values from two behavioral
audiograms of a false killer whale", printed p. 2691. Public copy:
`Yuen_etal_2005/Yuen-2005-Behavioral and auditory evoked poten.pdf`.

## Relationship to Thomas_etal_1988
This paper studies the same species (and very likely the same long-lived
captive subject, a female false killer whale at the Hawaii Institute of
Marine Biology/Sea Life Park facility) as `Thomas_etal_1988`, but reports an
independent, later pair of behavioral audiograms (2001 and 2004) plus a
parallel auditory-evoked-potential (AEP) audiogram series, comparing
psychophysical and electrophysiological methods on the same animal. It is
built here as its own registry item rather than merged with Thomas et al.
(1988), since the two papers present distinct, separately-citable
measurement campaigns years apart.

## Why this item exists
The paper's primary methodological contribution is comparing behavioral vs.
AEP hearing thresholds; Table I holds the two **behavioral** audiograms
(a partial 2001 study at 5 frequencies, and a complete 2004 study at 16
frequencies spanning >4 octaves), which is the more directly comparable
"classical" audiogram measure (cf. Thomas et al. 1988) and is prioritized
here as the paper's core reported result. The paper's AEP audiograms (Table
II, not built as a separate item here) are referenced in this README for
context only.

## Source quality and verification
The source PDF is a born-digital, high-quality JASA reprint with a clean
text layer — Table I extracted cleanly with all values legible and
internally consistent with the paper's own Results-text summary statements
(e.g. "lowest threshold of 69 dB at 20 kHz" matches the printed 69.5 dB 2004
value at 20 kHz; the printed per-row "Difference"/"Average" columns for the
five double-tested frequencies were independently recomputed in Python and
match the printed values). No image re-render was necessary.

## Pipeline
Printed table -> snapshot -> analysis csv -> public TSV.

| file | role |
|---|---|
| `Yuen_etal_2005_TableI_snapshot.csv` | frozen source, printed wide layout (2001/2004/Difference/Average columns, blank cells where a frequency was untested in a given year) |
| `Yuen_etal_2005_TableI.R` | reshapes wide -> long (drops untested year x frequency combinations), writes CSV + public TSV |
| `Yuen_etal_2005_TableI.csv` | tidy analysis rows, one per year x frequency actually measured (21 rows) |
| `reference_tables/Yuen_etal_2005_TableI_definitions.csv` | data dictionary |

## Data role
All 21 rows are this paper's own new measurements ("primary"), from a
single subject tested in two field seasons.

## Observation level
One row per behavioral-audiogram year (2001 or 2004) per tested frequency.
The 2001 audiogram was a preliminary/partial study (5 frequencies: 16, 22.5,
32, 38, 45 kHz); the 2004 audiogram was the complete study (16 frequencies,
4–45 kHz). Five frequencies (16, 22.5, 32, 38, 45 kHz) were tested in both
years and are kept as separate rows (not averaged), matching the source
table's own presentation.

## Units
Thresholds are in dB re 1 µPa, as printed. Lowest threshold overall: 69.5 dB
at 20 kHz (2004 behavioral audiogram); region of best sensitivity 16–24 kHz
per the text. The printed "Difference" and "Average" columns (kept in the
snapshot for fidelity, not carried into the tidy analysis CSV) quantify
year-to-year repeatability at the five doubly-tested frequencies, ranging
from 2.6 dB (32 kHz) to 12.1 dB (38 kHz).
