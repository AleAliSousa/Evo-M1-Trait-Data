# Heffner_etal_1994_c_Table1

## Source
Heffner, R. S., Heffner, H. E., Kearns, D., Vogel, J., & Koay, G. (1994).
Sound localization in chinchillas. I: Left/right discriminations. *Hearing
Research*, 80, 247-257. doi:10.1016/0378-5955(94)90116-3

Registry Item **Table 1**, printed p. 253 ("Sound-localization thresholds of
eleven species of rodents"). Public copy:
`Heffner_etal_1994_c/Heffner_etal_1994_c.pdf`.

## Why this item exists
This is the paper's own compact, printed comparison table of minimum-audible-
angle (left/right sound-localization) thresholds across 11 rodent species,
including the two subterranean specialists (naked mole rat, *Heterocephalus
glaber*, 63 deg; blind mole rat, *Spalax ehrenbergi*, 180 deg) that
SensoryData_compiled cites this paper for, plus the chinchilla's own new
value (15.6 deg, "present report" -- the paper's primary contribution).

## Pipeline
Printed table -> snapshot -> analysis csv -> public TSV. Source is a scanned
reprint whose OCR text layer mangled several digits and species names (e.g.
"Sound-localization" -> ":ound-localization", "12.8" -> "[2_8,"); the table
was transcribed from a 400-dpi render of PDF page 7 (printed p. 253) and
every value below was confirmed against that image.

| file | role |
|---|---|
| `Heffner_etal_1994_c_Table1_snapshot.csv` | frozen source, printed table layout |
| `Heffner_etal_1994_c_Table1.R` | reads the snapshot, writes CSV + public TSV |
| `Heffner_etal_1994_c_Table1.csv` | tidy analysis rows |
| `reference_tables/Heffner_etal_1994_c_Table1_definitions.csv` | data dictionary |

## Data role
Chinchilla (row 3) is primary ("Present report" -- this paper's own new
measurement). All other 10 rows are secondary/cited values compiled by this
paper from prior studies (citations as printed in the table's Source
column).

## Observation level
One threshold value per species (species-level summary as printed; no
per-individual data given in the table). Footnote a: thresholds were defined
as 75% correct for two-choice procedures and 50% detection for conditioned-
avoidance procedures; based on brief broadband-noise bursts except the
kangaroo rat (2/s clicks). Footnote b: the two subterranean mole-rat
thresholds used a longer 400-ms noise burst because these species cannot
reliably localize the standard 100-ms burst even at 180 deg separation;
pocket gopher's threshold could not be obtained even with the 400-ms signal
(printed as a dash, transcribed here as a blank/NA, not zero).

## Units
Threshold in degrees of minimum audible angle, as printed.

## Flags / anomalies (kept as printed, not silently corrected)
1. **Duplicate citation.** The table prints the identical citation "Heffner
   and Heffner, 1988a" for both the wood rat (19.0 deg) and grasshopper mouse
   (19.3 deg) rows. That 1988a reference's own title in this paper's
   reference list ("Sound localization in a predatory rodent, the northern
   grasshopper mouse, *Onychomys leucogaster*") is specific to the
   grasshopper mouse, not the wood rat -- so the wood rat row's citation may
   be a printed error in the source (its correct citation is more likely the
   Heffner and Heffner 1985a wood-rat/grasshopper-mouse hearing paper, or an
   unlisted localization study). Kept exactly as printed per house rules;
   flagged rather than corrected.
2. **Species not fully specified.** The "Kangaroo rat" row's cited source
   (Heffner and Masterton, 1980, "Hearing in Glires: domestic rabbit, cotton
   rat, feral house mouse, and kangaroo rat") does not give a genus/species
   in this paper's text or reference list, and that 1980 title reads as an
   audiogram (hearing) paper rather than a localization paper -- so the
   citation itself may also be a printed anomaly, but is kept as printed.
   The `binomial` field for this row is left blank rather than guessing a
   *Dipodomys* species.
3. **Pocket gopher** has no numeric threshold (printed as an em dash); left
   blank/NA rather than fabricated.
