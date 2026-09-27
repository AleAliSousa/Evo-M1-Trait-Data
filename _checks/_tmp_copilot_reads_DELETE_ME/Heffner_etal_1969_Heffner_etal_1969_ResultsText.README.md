# Heffner_etal_1969_ResultsText

## Source
Heffner, H. E., Ravizza, R. J., & Masterton, B. (1969). Hearing in
primitive mammals, III: Tree shrew (*Tupaia glis*). *Journal of Auditory
Research*, 9(1), 12-18.

No DOI exists for this citation -- see N.B. below for the Alt identifier
used in its place. Registry Item **Results text** (no printed data table;
the paper's two audiograms are shown only as figures, Figs. 1-2). Public
copy: `Heffner_etal_1969/Heffner-1969-Hearing in primitive mammals, III.pdf`.

## Why this item exists
Third in a series (following opossum and hedgehog, see
`Ravizza_etal_1969` and companion folders elsewhere in this registry)
testing primitive/basal mammals to reconstruct the evolution of human
hearing. Tree shrews were tested with two independent behavioral techniques
(conditioned suppression, n=2; shock-avoidance in a double-grill box, n=2).
The paper's core reported results -- overall best frequency, lowest
threshold, and the audible frequency range (both as tested and as
extrapolated to +80 dB SPL) -- are stated explicitly in the Results,
Discussion ("Overall sensitivity" / "Best frequency" subsections), and
Summary text; there is no printed numeric table.

## Pipeline
Verbatim Results/Discussion/Summary text -> snapshot -> analysis csv -> public TSV.

| file | role |
|---|---|
| `Heffner_etal_1969_ResultsText_snapshot.csv` | frozen verbatim quotes |
| `Heffner_etal_1969_ResultsText.R` | re-keys the stated values, writes CSV + public TSV |
| `Heffner_etal_1969_ResultsText.csv` | tidy analysis row |
| `reference_tables/Heffner_etal_1969_ResultsText_definitions.csv` | data dictionary |

## Data role
Primary -- the paper's own new audiogram for *Tupaia glis*, obtained by the
technique the authors state they trust most (conditioned suppression; the
shock-avoidance replication broadly agrees in shape but the authors
explicitly note it does not reproduce the sharp best-frequency tuning and is
considered less reliable for absolute SPL).

## Observation level
Species-level summary derived from n=2 individual tree shrews tested by the
conditioned-suppression technique (the technique the authors state gives
their most trustworthy absolute-threshold values, hence used here for
`best_sensitivity_db_spl` and `best_frequency_khz`).

## Units
`best_sensitivity_db_spl` and thresholds are in dB SPL re 2x10-4 microbar
(= 20 uPa, the same reference as the modern SPL standard, per the paper's
Fig. 1 caption) -- directly comparable to modern dB SPL values, no
conversion needed. Frequencies in kHz (paper's own unit, "kc/s").
`tested_range_*` = the range over which the animals were shown to
respond directly; `extrapolated_range_*` = the wider range the authors
conclude the animals can hear if the audiogram slopes are extrapolated out
to +80 dB SPL (their stated criterion), not directly tested at those
frequencies.

## Verification
This PDF is a scanned photocopy (Acrobat 5.0 "Scan Plug-in", no OCR/text
layer at all -- the semantic extraction returns only page-image markers for
all 7 pages). Every page was rendered at 150 dpi and read visually; each
quoted sentence in the snapshot was transcribed directly from, and
cross-checked twice against, the rendered page images (pp. 12-18 of the
printed journal).

## N.B. / anomalies
- **No DOI.** *Journal of Auditory Research* ceased publication decades ago
  and was never assigned Crossref DOIs; this article is also not indexed in
  PubMed/Medline (no PMID found). Following this registry's existing
  precedent for DOI-less sources (PMID/ISBN/OCLC-style Alt identifiers seen
  elsewhere in column I of `__ReadMe.xlsx`), this entry uses the Alt
  identifier `JAudRes:9:12-18` (percent-encoded as
  `JAudRes%3A9%3A12-18`) in place of a DOI.
- The paper reports a real best-frequency discrepancy between its two
  testing methods (16 kc/s sharply tuned by conditioned suppression; no
  comparable sharp tuning seen with shock-avoidance) and explicitly
  attributes this to likely SPL-measurement imprecision in the
  shock-avoidance apparatus, not to a data error -- kept as printed/stated,
  not resolved or averaged here.
