# Heffner_etal_2008_ResultsText

## Source
Heffner, R. S., Koay, G., & Heffner, H. E. (2008). Sound localization
acuity and its relation to vision in large and small fruit-eating bats:
II. Non-echolocating species, *Eidolon helvum* and *Cynopterus
brachyotis*. *Hearing Research*, 241, 80-86.
doi:10.1016/j.heares.2008.05.001

Registry Item **Results Text** - sections 3.1 and 3.2, printed pp. 83-84.
Local copy: `Heffner_etal_2008/Heffner-2008-Sound localization acuity and its.pdf`.

## Why this item exists
Table 1 of this paper (built separately in this folder) prints only one
number per species, the passive sound-localization threshold, and does so
for seven bats drawn mostly from earlier papers. Everything else the study
measured is in the Results prose and nowhere else: the sample sizes, the
retinal measurements on *E. helvum* (flattened retina diameter, the visual
angle it subtends, the binocular field, and the 45.5 deg horizontal width
of the field of best vision that Fig. 3 regresses localization acuity
against), and the paper's statement that no *C. brachyotis* retina could be
obtained. Those values are the reason this paper is in the project's
sensory-vision scope, and none of them is tabulated.

## Pipeline
Results prose -> **constructed** snapshot -> analysis csv -> public TSV.

| file | role |
|---|---|
| `Heffner_etal_2008_ResultsText_extract_snapshot.R` | builds the constructed snapshot from the PDF text layer |
| `Heffner_etal_2008_ResultsText_snapshot.csv` | frozen constructed source (11 rows) |
| `Heffner_etal_2008_ResultsText.R` | reads the frozen snapshot, writes CSV + public TSV |
| `Heffner_etal_2008_ResultsText.csv` | analysis rows (11 x 16) |
| `reference_tables/Heffner_etal_2008_ResultsText_definitions.csv` | data dictionary |
| `__Public/comparative-data/10.1016%2Fj.heares.2008.05.001_ResultsText.tsv` | public copy |

## The constructed snapshot
There is no printed table to freeze, so the snapshot is a table this
project constructs, per the "When there is no table" section of
`__HOWTO_make_a_snapshot.md`. It carries **one row per reported value**
with, for each: the Results subsection, the printed journal page, the PDF
page, the species as the prose abbreviates it, the quantity in the
paper's own wording, the value exactly as printed, its unit, any printed
hedge, and - the point of the whole thing - **the verbatim sentence the
number came from**. A reviewer can read the sentence, turn to the printed
page, and confirm the number without reconstructing anything.

**Extraction method (provenance).** `..._extract_snapshot.R` reads the
PDF text layer with `pdftools::pdf_data`, reconstructs the two-column
reading order by splitting word boxes on x and sorting by (y, x), rejoins
words hyphenated at line ends, and expands the two PDF ligature glyphs
(fi, fl) that Elsevier's font encoding emits. Each sentence is then located
between **two anchored printed literals**, each of which must occur exactly
once on that column, and the number is pulled out of the located sentence
with a capture group. No value is typed into either script, and the extract
refuses to overwrite a frozen copy that differs from what it extracted.
Run by an AI assistant (Claude, Anthropic) on 2026-10-31; **human visual
curation against the printed pages is still pending.**

## What is in the 11 rows
- **3.1**, p. 83: n = 2 individuals per species; the >= 90 deg separation at
  which every individual performed perfectly; the .50 performance
  thresholds (minimum audible angles) of 11.7 deg for *E. helvum* and
  10.5 deg for *C. brachyotis*.
- **3.2**, pp. 83-84: one *E. helvum* retina obtained; flattened retina
  14.25 mm in diameter, subtending approximately 190 deg; binocular field
  approximately 60 deg; horizontal width of the field of best vision
  45.5 deg (the >= 75%-of-maximum ganglion-cell-density criterion).
- **3.2**, p. 84: the reported **absence** - no *C. brachyotis* retinae,
  by agreement with the Lubee Bat Conservancy. That row is kept with
  `value_printed = n.a.` and `reported_as_absent = TRUE`, because a stated
  impossibility is evidence and an empty cell is not.

Two values are hedged in print ("approximately 190 deg", "approximately
60 deg") and one is a bound ("90 deg or greater"); `value_qualifier` and
`is_approximate` carry that, and none of the three should be used as a
point estimate.

**Deliberately not included:** the r = .889, p < .0001 correlation between
sound-localization acuity and the width of the field of best vision. It is
a Fig. 3 statistic reported in the Discussion (section 4.2.1), not in the
Results, and this item's locus is the Results text.

## Data role
`primary` on every row: all eleven are measurements (or a stated
non-measurement) from this study. Nothing here is compiled from another
paper, so there is **no references file** for this item - unlike Table 1 in
the same folder, five of whose seven rows are cited from earlier work.

## Units
Degrees for all angular quantities (minimum audible angle, retinal visual
angle, binocular field, field of best vision); mm for the flattened retina
diameter; counts for the two sample sizes. No conversion applies and none
was made.

## Table checks

The prose has no internal arithmetic, but it overlaps the paper's own
Table 1 at exactly two cells: the minimum audible angles. The reader
checks them against the sibling `Heffner_etal_2008_Table1.csv`, exact
(tolerance 0), since the two are the same measurement published twice in
one paper.

Result of the recorded run (`Rscript --vanilla`, 2026-10-31):
**2 pass, 0 mismatch, 0 not_evaluable** - 11.7 deg and 10.5 deg agree
exactly between the Results prose and Table 1.

## Pending
Human visual curation of the 11 sentences and values against printed
pp. 83-84; owner paste of
`Heffner_etal_2008_ResultsText_registry_row.xlsx` (Progress stage).
