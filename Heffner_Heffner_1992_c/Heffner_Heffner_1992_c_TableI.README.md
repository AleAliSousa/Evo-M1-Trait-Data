# Heffner_Heffner_1992_c_TableI

## Source
Heffner, R. S., & Heffner, H. E. (1992). Hearing and sound localization in
blind mole rats (*Spalax ehrenbergi*). *Hearing Research*, 62(2), 206–216.
doi:10.1016/0378-5955(92)90188-S

Registry Item **Table I**, printed p. 212 ("Auditory parameters for
rodents"). Public copy:
`Heffner_Heffner_1992_c/heffner_heffner_1992_scan.pdf` (scanned).
(The "_c" suffix distinguishes this from other Heffner & Heffner 1992 papers
in this registry — `_a` is "Visual factors in sound localization in
mammals," J Comp Neurol 317.)

## Why this item exists
This paper reports the first behaviorally determined audiogram for the
blind mole rat (*Spalax ehrenbergi*), a subterranean rodent with vestigial
eyes. Table I places this new measurement alongside 16 previously published
rodent audiograms (the same comparison set used in the paper's own Fig. 6
and its high/low-frequency-hearing discussion), grouped by low-frequency
hearing limit into low-frequency, subterranean and high-frequency rodents.

## Pipeline
Scanned PDF (OCR text layer) → snapshot → analysis csv → public TSV.

| file | role |
|---|---|
| `Heffner_Heffner_1992_c_TableI_snapshot.csv` | frozen source, printed layout, footnote markers kept as printed |
| `reference_tables/Heffner_Heffner_1992_c_TableI_footnotes.csv` | footnote-number → citation text, transcribed from the table's own footnote line |
| `Heffner_Heffner_1992_c_TableI.R` | reads the snapshot, resolves footnotes, writes CSV + public TSV |
| `Heffner_Heffner_1992_c_TableI.csv` | one row per species (17) |
| `reference_tables/Heffner_Heffner_1992_c_TableI_definitions.csv` | data dictionary |

## Who read the values, when, and how it was checked
The source is a scanned/OCR'd PDF. All 17 rows and their footnote markers
were cross-checked against the paper's own footnote key (printed directly
under Table I) and against the paper's prose discussion of the same values
(e.g., "the 60-dB upper limit ranges from 5.9 kHz for blind mole rats to
8.7 kHz for pocket gophers, and 11.5 kHz for naked mole rats" — matches
rows 8–10 exactly; "low-frequency hearing limits for these 14 species range
from 29 Hz to 2.3 kHz" — matches the non-subterranean rows). Extracted and
checked by an AI assistant, 2026-09-25.

## Data role — mixed, by row
Only the *Spalax ehrenbergi* (blind mole rat) row is this paper's own new
data. The other 16 rows are secondary — reproduced in the paper's own
Table I from a series of earlier Heffner-lab (and one Ryan 1976, one Conesa
et al. 1991) rodent audiogram studies, most unpublished conference
abstracts at the time of printing. `data_role` marks this per row.

## Printed oddities carried as-is
- Binomial names are filled in only where this paper's own text or
  reference list confirms them unambiguously (blind mole rat, naked mole
  rat, pocket gopher, Darwin's mouse, spiny mouse) or where the common name
  has only one plausible standard-lab-species referent (guinea pig,
  chinchilla, Norway rat, house mouse). Prairie dog, gerbil, chipmunk,
  kangaroo rat, woodrat, grasshopper mouse and cotton rat are left blank —
  several of these common names cover multiple congeners and this paper
  does not print the species epithet.
- "Cotton rat" best frequency is printed as a plain "8.0" with no footnote
  glyph in the OCR text; the source column for that row uses the same
  citation as kangaroo rat and house mouse (H. Heffner & Masterton 1980,
  footnote 4), matching the paper's own footnote-4 grouping.

## Observation level
Species mean audiogram parameter (not per-individual). The blind mole rat
row is the mean of 2 tested animals (per the paper's Fig. 2/discussion);
comparison rows are species means from their own source studies.

## Units
kHz (frequency limits and best frequency), dB SPL (lowest/best threshold,
re 20 µPa).
