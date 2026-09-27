# Terhune_Ronald_1972 — Table 1 (underwater audiogram of a harp seal)

## Source
Terhune, J. M., & Ronald, K. (1972). The harp seal, *Pagophilus
groenlandicus* (Erxleben, 1777). III. The underwater audiogram. *Canadian
Journal of Zoology*, 50(5), 565-569. doi:10.1139/z72-077

Registry Item **Table 1**, "Acoustic sensitivity of a harp seal underwater",
printed p. 566. Public copy: `Terhune_Ronald_1972/Terhune-1972-The harp
seal, Pagophilus groenla.pdf`.

## Why this item exists
This paper reports a free-field underwater audiogram (0.76–100 kHz, in
half-octave steps) for a single trained female harp seal, using a
psychophysical up/down tracking procedure. Table 1 is the paper's complete
set of raw threshold determinations, including two increased-sensitivity
regions (near 2 kHz and 22.9 kHz) and a steep high-frequency roll-off above
64 kHz. This is a foundational early phocid audiogram frequently cited in
comparative pinniped hearing literature.

## Source quality and verification
The source PDF is a scanned photocopy (NRC Research Press reprint); its text
layer is OCR output with clear character-substitution errors (e.g.
"d/pbar" for "db/µbar", "111." for "III."). The automatically extracted
table text was garbled and incomplete. **Table 1 (all 21 determinations) was
therefore transcribed by hand from a 200 dpi page render (PDF page 2,
printed p. 566) and cross-checked digit-by-digit against the image** before
finalizing the snapshot.

## Pipeline
Printed table -> snapshot -> analysis csv -> public TSV.

| file | role |
|---|---|
| `Terhune_Ronald_1972_Table1_snapshot.csv` | frozen source, printed layout (title line + 21 data rows + footnote) |
| `Terhune_Ronald_1972_Table1.R` | reads the snapshot, writes CSV + public TSV |
| `Terhune_Ronald_1972_Table1.csv` | tidy analysis rows |
| `reference_tables/Terhune_Ronald_1972_Table1_definitions.csv` | data dictionary |

## Data role
All 21 rows are this paper's own new measurements ("primary"), from a single
subject.

## Observation level
One row per individual threshold determination/testing session (21 sessions
total across 15 distinct half-octave frequencies from 0.76 to 100 kHz; a few
frequencies — 2.0, 22.9, 32.0, and 90.0 kHz — were determined twice on
different dates and both determinations are kept as separate rows, as
printed).

## Units
Threshold and ambient-noise-level columns are in dB re 1 µbar (add 100 to
convert to dB re 1 µPa, per the paper's own underwater SPL convention of the
era). Standard deviation is in dB. Two ambient-noise cells are printed with
a "less-than" sign (`<-77`, `<-78`, at 5.6 and 8.0 kHz) indicating the true
ambient level was below the instrument's measurable floor; these are kept as
upper-bound values with a flag column (`ambient_noise_is_upper_bound`)
rather than being treated as exact readings.

## N.B. — flagged discrepancy (not silently corrected)
The paper's abstract/Discussion text states the harp seal's "maximum
sensitivity... was -32.9 db/µbar at 15.0 kHz." **15.0 kHz was not one of the
half-octave frequencies actually tested** (the two nearest tested points,
11.3 and 16.0 kHz, have printed thresholds of -31 and -29 db/µbar
respectively), and -32.9 dB does not match any raw threshold printed in
Table 1. The lowest value actually printed in Table 1 is **-37 db/µbar at
22.9 kHz** (the 12-28-70 determination; a second 22.9 kHz determination on
1-18-71 gave -30 db/µbar). This strongly suggests the -32.9 dB/15.0 kHz
figure in the text was read off the fitted/interpolated audiogram curve in
Fig. 2 rather than being a raw Table 1 entry. Per house convention this is
flagged here and in the registry N.B., and the table is transcribed exactly
as printed rather than "corrected" to match the abstract.
