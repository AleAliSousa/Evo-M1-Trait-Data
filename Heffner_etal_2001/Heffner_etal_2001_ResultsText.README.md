# Heffner_etal_2001_ResultsText

## Source
Heffner, R. S., Koay, G., & Heffner, H. E. (2001). Audiograms of five
species of rodents: implications for the evolution of hearing and the
perception of pitch. *Hearing Research*, 157(1-2), 138-152.
https://doi.org/10.1016/S0378-5955(01)00298-2

Registry Item **Results text** (no single printed summary table; each
species' key values are stated once, in running text, in its own Results
subsection). Public copy: `Heffner_etal_2001/Heffner-2001-Audiograms of
five species of rod.pdf`.

## Why this item exists
Behavioral audiograms for five rodent species newly tested by this lab:
groundhog (*Marmota monax*), eastern chipmunk (*Tamias striatus*), Darwin's
leaf-eared mouse (*Phyllotis darwinii*), golden hamster (*Mesocricetus
auratus*), and Egyptian spiny mouse (*Acomys cahirinus*) -- chosen to
broaden the sample of mammals with known audiograms (bringing the rodent
total to 20 species) and to test a proposed evolutionary/perceptual
dichotomy between "extended" and "restricted" low-frequency hearing. For
each species the paper states, once in its own Results subsection, the
60-dB-SPL hearing range (low and high frequency limits, plus the span in
octaves) and the average best sensitivity (dB) and its frequency (kHz) --
exactly the "core reported result" convention used throughout this
registry cluster. There is no single combined table of these five values;
they are transcribed here from the five separate quoted sentences (frozen
in the snapshot).

## Pipeline
Verbatim per-species Results text -> snapshot -> analysis csv -> public TSV.

| file | role |
|---|---|
| `Heffner_etal_2001_ResultsText_snapshot.csv` | frozen verbatim quotes, one row per species |
| `Heffner_etal_2001_ResultsText.R` | re-keys the stated values, writes CSV + public TSV |
| `Heffner_etal_2001_ResultsText.csv` | tidy analysis rows |
| `reference_tables/Heffner_etal_2001_ResultsText_definitions.csv` | data dictionary |

## Data role
Primary for all five rows -- this paper's own new behavioral audiograms.

## Observation level
Species-level average (each species tested in multiple individual animals;
per-animal data underlying each species average is shown only in Fig. 2,
not in a printed table, and is not transcribed here).

## Units
`hearing_range_low_khz`/`hearing_range_high_khz` = the lowest/highest
frequency at which the species' threshold was <=60 dB SPL, as printed.
`hearing_range_octaves_printed` = the octave span the paper itself states
(log2(high/low)); `hearing_range_octaves_computed` is independently
recomputed here from the printed low/high limits as a verification check
(see below) -- both are kept, neither replaces the other.
`best_sensitivity_db_spl`/`best_frequency_khz` = the average lowest
threshold and its frequency, as printed. `range_criterion_db_spl` = 60 for
every row (the paper's own stated definition of "hearing range" throughout).

## Verification
For every species, `log2(hearing_range_high_khz / hearing_range_low_khz)`
was recomputed in Python/R and compared to the paper's own printed octave
count: all five agree to within 0.1 octave (chipmunk 10.38 vs. printed 10.4;
groundhog 9.43 vs. 9.4; hamster 8.92 vs. 8.9; leaf-eared mouse 5.57 vs. 5.5;
spiny mouse 4.95 vs. 4.9) -- differences are ordinary rounding, not
transcription errors. No printed number was altered; both the printed and
recomputed octave values are retained as separate columns.

## N.B. / anomalies
None found for this item -- all five species' printed range/sensitivity
values reconcile with each other (octave check above) and no other
discrepancies were identified in the source text.
