# Mohl__1968_Table2

## Source
Møhl, B. (1968). Auditory sensitivity of the common seal in air and water.
*The Journal of Auditory Research*, 8, 27-38. (This pre-1970s journal was
never retroactively assigned a DOI; a placeholder DOI is used in the
registry per house convention -- see N.B.)

Registry Item **Table II**, printed p. 32. Public copy:
`Mohl__1968/Mohl-1968-Auditory sensitivity of the common s.pdf`.

## Why this item exists
This is the first published audiogram of a pinniped (the common/harbour
seal, *Phoca vitulina vitulina*) measured in both air and water in the same
individual, using a conditioned lever-press go/no-go procedure. Table II
gives the full frequency-by-frequency threshold data (1-180 kc/s in water,
1-22.5 kc/s in air) underlying the paper's headline finding: the seal's ear
is "water-adapted" (best sensitivity -37 dB re 1 µBar at 32 kc/s in water,
vs. best sensitivity 16 dB re 2x10^-4 µBar at 11.25 kc/s in air, with the
air audiogram running roughly 15 dB less sensitive than the water audiogram
across 1-12 kc/s). This dataset is foundational for cross-species
comparisons of amphibious-mammal hearing (e.g., against Schusterman's 1974
airborne sea-lion audiogram and Schusterman's 1981 review tables, also
built in this project).

## Pipeline
Printed table -> snapshot -> analysis csv -> public TSV.

| file | role |
|---|---|
| `Mohl__1968_Table2_snapshot.csv` | frozen source, printed layout (separate Water/Air blocks) |
| `Mohl__1968_Table2.R` | reads the snapshot, writes CSV + public TSV |
| `Mohl__1968_Table2.csv` | tidy analysis rows |
| `reference_tables/Mohl__1968_Table2_definitions.csv` | data dictionary |

## Data role
All 20 rows (11 water + 9 air) are this paper's own new behavioral
measurements on a single male common seal -- there is no secondary/cited
data in this table, so `data_role` is `primary` throughout.

## Observation level
One row per tested frequency per medium (water or air), for a single
subject (one male common seal, ~40 kg). Each threshold is the mean of a
constant-stimuli psychophysical run (approx. 10+ judgments per 6-dB step
near threshold); `sd_dB` is the standard deviation of that psychophysical
estimate, and `n_catch_trials`/`pct_correct_catch_trials` describe the
session-level catch-trial (false-alarm) control data printed alongside
each threshold in the original table.

## Units
- `frequency_kHz`: kc/s as printed (numerically identical to kHz).
- `threshold_dB`: water thresholds are dB re 1 µBar; air thresholds are dB
  re 2x10^-4 µBar (the standard SPL reference, 0.0002 dyne/cm^2). These are
  **not** on a common scale -- see `reference_level` per row. The source
  paper itself only makes them directly comparable after converting both
  to dB re 1 µW/cm^2 for its Figure 2, which is a derived/plotted quantity
  not printed as a table and was therefore not transcribed here (only
  printed table values were used, per house rule to prefer tables over
  figures).
- Values printed in parentheses in the original table, e.g. `(-16)`,
  `(33)`, `(58)`, and one `(4)` SD value, are flagged
  `threshold_flag`/`sd_flag` = `parenthetical_in_source`; the paper does
  not fully explain this notation but context (e.g. the 180 kc/s row,
  described in text as "only indicatory, the uncertainty being unknown")
  indicates these are values the author himself considered less certain
  (edge-of-range extrapolations). Values are transcribed as printed, not
  corrected or omitted.
