# Mooney_etal_2012_Table4.1

## Source
Mooney, T. A., Yamato, M., & Branstetter, B. K. (2012). Hearing in
Cetaceans: From Natural History to Experimental Biology. *Advances in
Marine Biology*, 63, 197–246. doi:10.1016/B978-0-12-394282-1.00004-1

Registry Item **Table 4.1**, printed pp. 206–207 ("Odontocete audiograms
chronologically from initial tests on the species"). Public copy:
`Mooney_etal_2012/mooney_2012.pdf`.

## Why this item exists
This book-chapter review compiles every published odontocete (toothed
whale/dolphin/porpoise) audiogram as of 2012 into one table: 31 published
tests across 18 species, each row giving the hearing range and the
frequency range of best sensitivity. It is registered on the same basis as
`Baron_etal_1996` and `Heffner__1998` — a compiled review table that is
itself the paper's own printed, citable artifact, not a figure requiring
digitization.

## Pipeline
Printed table → snapshot → analysis csv → public TSV.

| file | role |
|---|---|
| `Mooney_etal_2012_Table4.1_snapshot.csv` | frozen source, printed layout |
| `Mooney_etal_2012_Table4.1.R` | reads the snapshot, writes CSV + public TSV |
| `Mooney_etal_2012_Table4.1.csv` | one row per published test (31, 18 species) |
| `reference_tables/Mooney_etal_2012_Table4.1_definitions.csv` | data dictionary |

## Data role
All 31 rows are secondary: this is the review paper's own compilation of
other researchers' published audiograms, not new data of Mooney et al.'s own.

## Printed oddities carried as-is
- **Column name vs. content mismatch.** The source's "Best sensitivity
  (kHz)" column reports a *frequency range* (the band of frequencies at
  which the animal is most sensitive), not a dB threshold value, despite
  the header. This is preserved as printed; see `definitions.csv`.
- **Two rows (Stenella coeruleoalba and Globicephala melas) print a
  "best sensitivity" range wider than the row's own hearing range** (e.g.
  striped dolphin: hearing range 32–120 kHz but best-sensitivity range
  0.5–160 kHz). This is almost certainly a genuine error or ambiguity in
  the original source table (the same paper's own text does not resolve
  it), not a transcription mistake — both numbers are transcribed exactly
  as printed with no attempt to reorder or correct them.
- **Species abbreviations expanded to full binomials** using the paper's
  own prose (which names every species in full on first mention) rather
  than left as printed initials, to make the table usable independent of
  row order. The printed genus-abbreviated form is preserved implicitly by
  row order/study grouping.
- Footnote markers (a, b, c) and the literal "Unclear" cell for
  *Steno bredanensis* are preserved as printed.

## Observation level
One row per published study/test (not one row per species) — 18 species
are represented by 31 published audiograms, since several species (notably
the bottlenose dolphin, beluga, killer whale, and false killer whale) have
been tested multiple times by different research groups and methods.

## Units
kHz (all frequency columns).
