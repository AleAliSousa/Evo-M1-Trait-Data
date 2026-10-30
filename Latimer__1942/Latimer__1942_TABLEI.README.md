# Latimer__1942 — Table I (brain, spinal cord, and body — one printed table)

## Correction from an earlier pass
An earlier build in this session split this paper into two separate items ("spinal cord" and
"brain") under two different registry rows, on the assumption that the spinal-cord half had
already been built as a standalone item. **That was wrong: Table I is printed as a single table**
("MEASUREMENTS AND COEFFICIENTS OF VARIATION OF THE BRAIN AND OF ITS DIVISIONS, AND OF THE SPINAL
CORD IN THE DOG", p. 43) reporting brain divisions, spinal cord, and body weight/length together
for the same 162 male / 159 female adult dogs. This build replaces both prior items with the one
unified item matching the single registry row (`Item name = Latimer__1942_TABLEI`, `Item number =
TABLE I`).

## What is captured (Panel A, "Weights and linear measurements")
One row per (sex x structure): Brain (whole), Olfactory bulbs, Hemispheres and diencephalon,
Prosencephalon (= hemispheres + diencephalon + olfactory bulbs), Mesencephalon, Cerebellum,
Medulla, Rhombencephalon (= cerebellum + medulla), Cord weight, Cord length, Body weight, Body
length — mean +/- SE and coefficient of variation +/- SE, transcribed exactly as printed
(`Latimer__1942_TABLEI_snapshot.csv`), then converted to project units (mg for mass, cm kept as
printed for length; see the `Method:unit_conversion` definitions row).

## Out of scope
Panel B ("Percentages of body weight") and Panel C ("Percentages of brain weight") are derived
percentages, not independently measured quantities — per house rule
(`__HOWTO_build_a_dataset_file.md` §7), they are left untranscribed. The "Diff./PE diff." column
(a male-vs-female significance statistic) is likewise not carried into the analysis CSV.

## QA note
A fresh high-resolution re-read of the printed male cord-length cell reads 51.09 +/- 0.37 cm.

## Source
`latimer_1942_scan.pdf`, Table I, p. 43.
