# Heffner_etal_2001_a_ResultsText - README

**Source.** Heffner, R. S., Koay, G., & Heffner, H. E. (2001). Sound localization in a new-world frugivorous bat, *Artibeus jamaicensis*: Acuity, use of binaural cues, and relationship to vision. *Journal of the Acoustical Society of America, 109*(1), 412-421. https://doi.org/10.1121/1.1329620

**Item.** `Results Text` - the quantities this paper states in prose; the article has no numbered
tables. Registry `Item name` will be `Heffner_etal_2001_a_ResultsText` once the row is pasted
(**`sequence` = "a"** is required, see *Registry* below).

## Why this paper is here

It is the primary source cited by **Heffner & Heffner (2016) Figure 5** ("Modified from Heffner
et al., 2001") and its own **FIG. 6** is the primary version of that relationship - the reason the
2016 item recommended registering it. Built alongside this item: `Heffner_etal_2001_a_Figure6`
(the 24-species roster).

## What the data are

| role | rows | content |
|---|---|---|
| `primary` | 10 | the study's own measurements on *Artibeus jamaicensis* |
| `secondary` | 4 | values the paper **quotes** for two other bats |

**Primary (Jamaican fruit bat).** Sound-localization threshold (minimum audible angle, 100-ms noise
burst): bats A, B, C = 9.5 deg, 9 deg, 11.5 deg, mean **10 deg**; the same 10 deg for bat A with a
burst of five 2-ms pulses mimicking the echolocation call. Width of the **field of best vision =
34 deg** (the >=75% ganglion-cell isodensity region). Peak ganglion-cell density 9325 cells/mm2,
giving a calculated acuity of 1.1 cycles/deg. Flattened retina approximately 4.4 mm across.
Binaural phase cue usable up to 6.3 kHz.

**Secondary (quoted, never to be merged as primary).** Big brown bat: field of best vision 139 deg,
localization threshold 14 deg. Egyptian fruit bat: field of best vision 27 deg, localization
threshold 11.6 deg. The paper attributes these to R. Heffner, Koay & Heffner (1999) and
Koay et al. (1998b).

### What this closes

`__merging_sensory` carries `Field_of_best_vision.deg` for only 12 species, all from
`Heffner_Heffner_1992_a_TABLE1`. This item supplies that quantity for **three further species** -
*Artibeus jamaicensis* (34 deg, primary here) and, as quoted values, *Eptesicus fuscus* (139 deg)
and *Rousettus aegyptiacus* (27 deg).

## Files

| file | what it is |
|---|---|
| `Heffner-2001-Sound localization in a new-world.pdf` | the publication |
| `Heffner_etal_2001_a_ResultsText_snapshot.csv` | the frozen **constructed** snapshot: one row per measurement with the quoted sentence verbatim and its printed location |
| `Heffner_etal_2001_a_ResultsText.R` | build: snapshot -> analysis CSV (+ public TSV once registered) |
| `Heffner_etal_2001_a_ResultsText.csv` | analysis CSV, 14 rows x 13 columns |
| `reference_tables/Heffner_etal_2001_a_ResultsText_definitions.csv` | data dictionary (25 rows) |

## Source -> snapshot (constructed)

Values stated only in prose go in a clearly named constructed source (snapshot HOWTO). Each row
carries the sentence it came from, verbatim, plus the printed page and section. The quotes were
read from the PDF text layer and **verified character-by-character against 200-dpi renders of
printed pp. 412, 416 and 418**, because this PDF's text layer mis-maps punctuation: `~` for `(`,
`!` for `)`, `5` for `=` and `,` for `<` (so the raw layer renders "r = 0.916" as "r 50.916").
The build asserts that every `value_as_printed` actually occurs in its quoted sentence.

**Reader.** AI assistant (Claude), 2026-10-29. Pending human RA sign-off.

## Table checks

The prose prints both the three per-animal thresholds and their mean, so the mean is checkable:
mean(9.5, 9, 11.5) = 10.0 against the printed 10 deg - **passes exactly** (tolerance 0.5/3 deg from
the printed 0.5 deg rounding).

## Registry

**No registry row existed for this paper when the item was built** - `Heffner_etal_2001` is the
rodent-audiogram paper (Hear Res 157:138-152). The row must set **`sequence` = "a"**, which is what
makes the Item-name formula yield `Heffner_etal_2001_a_*` and match this folder; see the
consolidated paste workbook. Until then the build writes the CSV and warns that the public TSV is
pending - progress stage **PREPARED**, the repo's existing term for exactly this state. Re-running
the script after the paste writes the TSV with no other change.
