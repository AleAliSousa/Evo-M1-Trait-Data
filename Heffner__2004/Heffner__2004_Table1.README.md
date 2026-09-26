# Heffner__2004_Table1

## Source
Heffner, R. S. (2004). Primate hearing from a mammalian perspective. *The
Anatomical Record Part A*, 281A(1), 1111–1122. doi:10.1002/ar.a.20117

Registry Item **Table 1**, printed p. 1113 ("Hearing limits for 19 species
of primates"). Public copy:
`Heffner__2004/Heffner-2004-Primate hearing from.pdf` (PDF page 3).

## Why this item exists
This review paper compiles behaviorally determined audiograms for 19
primate species (plus a tree shrew comparison elsewhere in the paper) into
one summary table, citing "Figures 2, 3, 6, and 7" — i.e., the paper's own
per-group audiogram figures — as the source for each row. It is registered
on the same basis as `Baron_etal_1996`, `Heffner__1998`, and
`Mooney_etal_2012` — a compiled review table that is itself the paper's
own printed, citable artifact.

## Who read the values, when, and how it was checked — image-verified
This table's PDF text layer suffers a systematic extraction fault: printed
superscript footnote markers (¹²³⁴) fuse into the adjacent numeric cells,
and several negative "best sensitivity" values silently lose their minus
sign on extraction (e.g. "−1" reads as "1"). A first-pass attempt to
reconstruct the table from the raw text layer alone left roughly half the
rows ambiguous — it was not possible to tell, from text alone, whether a
stray digit was a footnote marker or part of a value, or whether a bare
positive number was missing a minus sign.

**Every one of the 19 rows was therefore re-read directly from a 300-dpi
page-image render of PDF page 3** (rendered 2026-09-25) rather than
transcribed from the text layer. The rendered table is fully legible at
that resolution — species names, all five numeric columns, and every
footnote superscript are unambiguous by eye. This is the same
image-verification standard used for `Baron_etal_1996_Table5`.

## Pipeline
Printed table → image-verified snapshot → analysis csv → public TSV.

| file | role |
|---|---|
| `Heffner__2004_Table1_snapshot.csv` | frozen source, transcribed from the page-image render, footnote markers kept in their own columns exactly as printed |
| `reference_tables/Heffner__2004_Table1_footnotes.csv` | footnote-number → citation text, transcribed from the table's own footnote block |
| `Heffner__2004_Table1.R` | reads the snapshot, resolves footnotes, writes CSV + public TSV |
| `Heffner__2004_Table1.csv` | one row per species (19) |
| `reference_tables/Heffner__2004_Table1_definitions.csv` | data dictionary |

## Data role
All 19 rows are secondary: compiled by Heffner (2004) from prior published
audiogram studies (some personal communications), not new measurements of
this paper's own.

## Printed oddities carried as-is
- **Negative best-sensitivity values.** Eulemur fulvus (−1), Cercopithecus
  aethiops (−4), Callithrix jacchus (−9), Aotus trivirgatus (−8), and Homo
  sapiens (−10) all print negative dB values that the PDF's raw text layer
  silently drops the sign from. All five were confirmed against the
  page-image render.
- **Six species have no printed low-frequency limit or hearing range**
  (Callithrix jacchus, Aotus trivirgatus, Macaca fascicularis, Macaca
  mulatta, Macaca nemestrina, Pan troglodytes) — confirmed blank in the
  source, not a transcription gap.
- **Erythrocebus patas (patas monkey)**: every one of its five values
  carries footnote 3 ("tested using headphones") — matching the paper's
  own prose caveat that patas-monkey data may be an underestimate because
  headphones are difficult to calibrate at low frequencies and eliminate
  the pinna's sound-gathering contribution.
- **Cercopithecus mitis (blue monkey) and Papio cynocephalus (yellow
  baboon)** carry footnote 2 ("extrapolated value") on their low-frequency
  limit (and, for C. mitis, also the high-frequency limit); Lemur catta and
  Galago senegalensis carry it on the low-frequency limit only.
- **Callithrix jacchus** carries footnote 4: "Published under the name
  *Hapale jacchus*" (an older synonym).
- **Eulemur fulvus** carries footnote 1: its entire row is a personal
  communication (D. Sutherland and R. B. Masterton), not a published
  citation.

## Observation level
Species-mean summary value (as compiled by the review), not per-individual.

## Units
kHz (frequency columns), dB re 20 µPa (best sensitivity), octaves (hearing
range).
