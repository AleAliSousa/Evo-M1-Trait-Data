# Thomas_etal_1988 — Table I (underwater audiogram of a false killer whale)

## Source
Thomas, J., Chun, N., Au, W., & Pugh, K. (1988). Underwater audiogram of a
false killer whale (*Pseudorca crassidens*). *Journal of the Acoustical
Society of America*, 84(3), 936-940. doi:10.1121/1.396662

Registry Item **Table I**, "Underwater auditory thresholds of Pseudorca
crassidens measured with two transducers", printed p. 939. Public copy:
`Thomas_etal_1988/Thomas-1988-Underwater audiogram of a false ki.pdf`.

## Why this item exists
An adult male false killer whale at Sea Life Park (Oahu, Hawaii) was trained
in a go/no-go, up/down staircase paradigm to measure underwater hearing
thresholds from 2–115 kHz over a 6-month period, using two different
transducers (J9 for lower frequencies, WAU for higher/overlap frequencies).
Table I is the paper's complete set of overall thresholds (with session-mean
ranges) at each tested frequency. This is one of a small number of
odontocete audiograms available at the time, and it is a companion/earlier
dataset to the same subject's behavioral audiogram reported later in Yuen et
al. (2005).

## Source quality and verification
The source PDF is a born-digital JASA reprint. The extracted text layer for
Table I was largely legible but contained a few visually ambiguous digit
substitutions (e.g. "8O"/"3O" rendered in place of "80"/"30"). **All 12
threshold values in Table I were cross-checked against a 200 dpi render of
PDF page 5 (printed p. 939)**; every value transcribed here matches the
rendered page image exactly, with no discrepancies found.

## Pipeline
Printed table -> snapshot -> analysis csv -> public TSV.

| file | role |
|---|---|
| `Thomas_etal_1988_TableI_snapshot.csv` | frozen source, printed layout (10 frequency rows, J9/WAU columns side by side) |
| `Thomas_etal_1988_TableI.R` | reshapes wide -> long (one row per transducer measurement), writes CSV + public TSV |
| `Thomas_etal_1988_TableI.csv` | tidy analysis rows (12 rows: 10 frequencies, with 64 and 85 kHz measured on both transducers) |
| `reference_tables/Thomas_etal_1988_TableI_definitions.csv` | data dictionary |

## Data role
All 12 rows are this paper's own new measurements ("primary"), from a
single subject.

## Observation level
One row per transducer measurement per tested frequency. Ten frequencies
(2, 4, 8, 16, 32, 64, 85, 105, 110, 115 kHz) were tested; 2–32 kHz used only
the J9 transducer, 105–115 kHz used only the WAU transducer, and 64 and 85
kHz were replicated with both transducers (12 rows total).

## Units
Threshold and session-range columns are in dB re 1 µPa, as printed. Best
sensitivity was 39 dB re 1 µPa at 64 kHz (J9 transducer); the paper defines
the "range of greatest sensitivity" (10 dB from maximum) as 16–64 kHz,
consistent with the printed 49 dB threshold at 16 kHz. Above 64 kHz,
sensitivity dropped sharply (~150 dB/octave per the text); below 8 kHz it
declined more gradually (~38 dB/octave).
