# Heffner_etal_1994_b_Figure3

## Source
Heffner, H. E., Heffner, R. S., Contos, C., & Ott, T. (1994). Audiogram of
the hooded Norway rat. *Hearing Research*, 73, 244-247.
doi:10.1016/0378-5955(94)90240-2

Registry Item **Figure 3**, printed p. 247. Public copy:
`Heffner_etal_1994_b/Heffner_etal_1994_b.pdf`.

## Why this item exists
This short paper's own new measurement is the audiogram of four hooded
(pigmented) Norway rats, compared against the previously-published albino
rat audiogram (Kelly and Masterton, 1977) to test for an effect of albinism
on hearing. Fig. 3 extends this comparison to two additional, more distantly
related muroid rodents (cotton rat and wood rat) shown only for qualitative
context. SensoryData_compiled's best-sensitivity/best-frequency values for
*Rattus norvegicus* trace to this paper.

## Pipeline
Per house rules, quantified values were taken from the Results-and-discussion
text (p. 246), not digitized from the plotted curves:
- "a point of best hearing at 8 kHz; ... a second point of best hearing at
  32-38 kHz" (both hooded and albino rats show this same general structure).
- "At a level of 60 dB SPL, the low-frequency limits are 530 Hz for the
  hooded rats and 400 Hz for the albinos... the high-frequency limits are
  68 kHz for the hooded rats with an estimated 76 kHz for the albino rats."

The cotton rat (*Sigmodon hispidus*) and wood rat (*Neotoma floridana*)
curves that also appear in Fig. 3 are not accompanied by any numeric
threshold values in the text -- they are shown purely for a qualitative
"family resemblance" comparison ("the hooded and albino rat audiograms
resemble each other more closely than they resemble either of the other two
species"). Those two rows are included in the snapshot for completeness of
what Fig. 3 actually depicts, with quantified fields left blank rather than
invented or digitized from the curve.

| file | role |
|---|---|
| `Heffner_etal_1994_b_Figure3_snapshot.csv` | frozen source, values as printed in the Results-and-discussion text |
| `Heffner_etal_1994_b_Figure3.R` | reads the snapshot, writes CSV + public TSV |
| `Heffner_etal_1994_b_Figure3.csv` | tidy analysis rows |
| `reference_tables/Heffner_etal_1994_b_Figure3_definitions.csv` | data dictionary |

## Data role
Row 1 (hooded rat) is primary (this paper's own new measurement, averaged
across 4 individuals A-D). Rows 2-4 (albino, cotton rat, wood rat) are
secondary/cited comparison data from other papers, reproduced in this
paper's Fig. 3.

## Observation level
Group means (hooded rat: n=4, this study; albino rat: mean audiogram from
Kelly and Masterton 1977). Cotton rat and wood rat rows have no numeric
observation (qualitative only).

## Units
Sensitivity/threshold in dB SPL; frequency in Hz/kHz as printed.

## Flags / anomalies (do not silently resolve)
1. **a/b/c naming swap.** SensoryData_compiled.csv attributes its *Rattus
   norvegicus* best-sensitivity (-1.25 dB) / best-frequency (32 kHz) values
   to "Heffner et al 1994c", while SensoryData_compiled_references.csv and
   this registry's DOI both identify the hooded-rat audiogram paper as
   "Heffner_etal_1994_b". The a/b/c disambiguation letters appear to be
   swapped between the two SensoryData files for this cluster of 1994 short
   communications. This is documented, not resolved, per the task
   instructions for this batch.
2. **Registry description mismatch, corrected.** The pre-existing draft
   registry row's title (column M) read "Average audiograms of the hooded
   rat (this study), albino rat and wild Norway rat" -- but the actual PDF's
   Fig. 3 legend (verified against the PDF page image, p. 247) lists hooded
   rat, albino rat, **cotton rat**, and **wood rat**; there is no "wild
   Norway rat" curve in this paper at all (a citation to a *different*
   Heffner and Heffner paper on wild-Norway-rat sound localization, 1985b,
   appears only in the reference list). The registry title was corrected to
   match the actual figure content; this discrepancy is flagged here rather
   than silently perpetuated.
3. The -1.25 dB / 32 kHz single-point value used elsewhere in
   SensoryData_compiled is not restated anywhere in this paper's text (only
   the two "points of best hearing" frequencies, 8 kHz and 32-38 kHz, are
   given, without accompanying dB values) -- it would require digitizing
   Fig. 2's curve to confirm, which was not attempted here per the house
   preference for text-stated values.
