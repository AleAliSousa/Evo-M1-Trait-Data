# Schusterman_Moore_1980 — Results text (aerial audiogram thresholds)

## Source
Schusterman, R. J., & Moore, P. W. B. (1980). Auditory sensitivity of
northern fur seals (*Callorhinus ursinus*) and a California sea lion
(*Zalophus californianus*) to airborne sound. *Journal of the Acoustical
Society of America*, 68(S1), S6. doi:10.1121/1.2004876

Registry Item **Results text**, printed p. 86 (100th Meeting of the
Acoustical Society of America, abstract Cll). Public copy:
`Schusterman_Moore_1980/Schusterman-1980-Auditory sensitivity of north.pdf`.
This 2-page PDF *is* the full source: a conference-proceedings abstract
reprint (J. Acoust. Soc. Am. Suppl. 1, Vol. 68, Fall 1980), not a full
journal article — there is no separate printed data table or figure, so the
values below are transcribed directly from the abstract's Results text.

## Why this item exists
This abstract reports the first aerial (airborne-sound) audiograms for two
otariid pinniped species tested in a purpose-built acoustic chamber: two
yearling female northern fur seals (*Callorhinus ursinus*) and one 2-year-old
female California sea lion (*Zalophus californianus*). Using a go/no-go
tracking procedure, average behavioral thresholds were obtained at seven
frequencies (1–32 kHz) for each species. The results show otariids hearing
airborne sound fairly well relative to phocid (true) seals, and the paper
also notes that an earlier *Zalophus* study (Schusterman 1974) had likely
been noise-limited below 24 kHz — this dataset supersedes it for that range.

## Pipeline
Abstract Results text -> snapshot -> analysis csv -> public TSV.

| file | role |
|---|---|
| `Schusterman_Moore_1980_ResultsText_snapshot.csv` | frozen source, values as printed in the running text |
| `Schusterman_Moore_1980_ResultsText.R` | reads the snapshot, writes CSV + public TSV |
| `Schusterman_Moore_1980_ResultsText.csv` | tidy analysis rows |
| `reference_tables/Schusterman_Moore_1980_ResultsText_definitions.csv` | data dictionary |

## Data role
All 14 rows (7 frequencies x 2 species) are this paper's own new behavioral
measurements ("primary").

## Observation level
Per-species, per-frequency mean threshold. For *Callorhinus ursinus* each
value is the mean of the two yearling female subjects (individual data not
broken out in the abstract); for *Zalophus californianus* each value is from
the single tested subject. No standard deviations or individual-animal
values are given in this abstract-length source.

## Units
Thresholds are in dB re 0.0002 dyn/cm² (the traditional airborne SPL
reference, equivalent to dB re 20 µPa), as printed. Best sensitivity: 7 dB at
16 kHz for *Callorhinus ursinus* (mean of 2); 16 dB at 8 kHz for *Zalophus
californianus* (n=1). The paper's discussion states these otariid pinnipeds
appear more sensitive to airborne sound than phocid pinnipeds studied to
date, though thresholds in air are inferior to *Callorhinus*'s underwater
sensitivity (per the same abstract).
