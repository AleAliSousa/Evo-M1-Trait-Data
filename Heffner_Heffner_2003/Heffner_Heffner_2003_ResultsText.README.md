# Heffner_Heffner_2003_ResultsText

## ⚠ Citation/year mismatch — read this first
The folder name (`Heffner_Heffner_2003`) and the source PDF's filename
(`Heffner-2003-Audition.pdf`) both imply this should be:

> Heffner, H. E., & Heffner, R. S. (2003). Audition. In S. F. Davis (Ed.),
> *Handbook of Research Methods in Experimental Psychology* (pp. 413-440).
> Malden, MA: Blackwell.

**That is not what is actually inside this PDF.** The document's own title
page identifies it as:

> Heffner, H. E., & Heffner, R. S. (2008). High-frequency hearing. In
> P. Dallos, D. Oertel, & R. Hoy (Eds.), *Handbook of the Senses: Audition*
> (pp. 55-60). New York: Elsevier. doi:10.1016/B978-012370880-9.00004-9

The book title *Handbook of the Senses: **Audition*** almost certainly
explains the mix-up: whoever named/filed this PDF likely matched on the
word "Audition" in the book title and mistook it for the differently-titled
2003 chapter (which is also, confusingly, literally titled "Audition," but
is a different chapter in a different book). The genuine 2003 "Audition"
chapter is cited by number in this PDF's own reference list ("Heffner, H.
E. and Heffner, R. S. 2003. Audition. In: Handbook of Research Methods in
Experimental Psychology...") as a **separate, self-cited** work — i.e., the
chapter we actually have references its own 2003 sibling chapter but is not
identical to it.

Per house rules, this item is built from **what is actually in the PDF**
(the 2008 High-Frequency Hearing chapter). Column H (Publication name) is
set to the folder name `Heffner_Heffner_2003` as required, but column A
(citation) and the DOI reflect the real, 2008 source. This discrepancy is
flagged here and in the registry's N.B. column; it was **not** silently
resolved by renaming the folder or fabricating a 2003 citation.

## Source (as actually read)
Heffner, H. E., & Heffner, R. S. (2008). High-frequency hearing. In P.
Dallos, D. Oertel, & R. Hoy (Eds.), *Handbook of the Senses: Audition* (pp.
55-60). New York: Elsevier. doi:10.1016/B978-012370880-9.00004-9

(Preprint version, as posted; page numbers above refer to the published
chapter as cited on the preprint's own title page.) Public copy:
`Heffner_Heffner_2003/Heffner-2003-Audition.pdf`.

## Why this item exists — and why it is a review, not primary data
This is a review/synthesis book chapter, not a paper reporting new
experimental data. Its purpose is to explain the evolutionary logic behind
mammalian high-frequency hearing (localizing sound via binaural
spectral-difference and pinna cues) using previously published findings
from the Heffner lab's own decades of comparative audiogram work. **No
printed data table exists anywhere in the chapter.** The chapter's only
explicitly quantitative, citable comparative finding is a single
correlation statistic given in prose next to Figure 1 (a scatterplot,
not digitized here): the relationship between functional head size and the
60-dB-SPL high-frequency hearing limit holds at **r = -0.79, p < 0.0001**
"for over 60 species ranging in size from mice and bats to humans and
elephants." This statistic is captured as the item's sole row.

Per house rules ("prefer a printed Table if present, else the Results-text
values, over digitizing a Figure"), Figure 1's ~60 individual data points
were **not** digitized: the figure has no axis-tick data labels precise
enough to transcribe reliably, and the chapter itself directs readers
elsewhere for the underlying values ("For tables of the absolute
thresholds of mammals, go to the website at
http://psychology.utoledo.edu/lch" — a dead/unverifiable external link, not
transcribed).

## Pipeline
Results-text statistic -> snapshot -> analysis csv -> public TSV.

| file | role |
|---|---|
| `Heffner_Heffner_2003_ResultsText_snapshot.csv` | frozen source, the one correlation statistic as printed |
| `Heffner_Heffner_2003_ResultsText.R` | reads the snapshot, writes CSV + public TSV |
| `Heffner_Heffner_2003_ResultsText.csv` | one row (the correlation statistic) |
| `reference_tables/Heffner_Heffner_2003_ResultsText_definitions.csv` | data dictionary |

## Data role
This is a review chapter's own synthesis statistic, not new primary data
collected in this chapter -- but it is not a value borrowed from a single
other cited paper either; it summarizes the authors' own body of prior work
across many papers. Marked `primary(review synthesis)` to distinguish it
from both a normal primary measurement and a normal secondary citation.

## Observation level
Comparative synthesis statistic across mammal species (n > 60, exact n not
given), not a per-species or per-individual observation.

## Units
Pearson correlation coefficient (dimensionless, range -1 to 1); p-value
threshold as printed.
