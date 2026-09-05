# Latimer__1942 — brain-weight table (Table I, Panel A, brain rows)

Build target: published sex-specific adult-dog **brain and brain-division weights** from Table I,
Panel A (p. 43), the companion half of the same table whose spinal-cord rows were built separately
as `Latimer__1942_Table1_spinal_cord.csv`. The paper reports 162 male and 159 female adult dogs.
Values are transcribed as printed (grams, mean ± SE and CV% ± SE) and converted to the project unit
(mg) in the reformat script; individual-level measurements are not published and are not
reconstructed.

## Rows captured (Panel A, "Weights and linear measurements")
Brain (whole), Olfactory bulbs, Hemispheres and diencephalon, Prosencephalon (= hemispheres +
diencephalon + olfactory bulbs), Mesencephalon, Cerebellum, Medulla, Rhombencephalon (= cerebellum +
medulla) — for each sex. Body weight/length and cord weight/length are already covered by the
existing spinal-cord item and are not repeated here.

## Out of scope
Panel B ("Percentages of body weight") and Panel C ("Percentages of brain weight") are derived
percentages, not independently measured quantities — per house rule (`__HOWTO_build_a_dataset_file.md`
§7, "size indices/percentages are NOT transcribed"), they are left untranscribed; they can be
recomputed downstream from the Panel A weights if ever needed. The "Diff./PE diff." column (a
male-vs-female significance statistic) is likewise not carried into the analysis CSV.

## QA note
The existing `Latimer__1942_Table1_spinal_cord.csv` records male cord length as 51.00 ± 0.37 cm; a
fresh high-resolution re-read of the same printed cell for this build reads 51.09 ± 0.37 cm. Left
as-is in both items (not corrected here) — flagging for the item owner to check against the scan.

## Source
`latimer_1942_scan.pdf`, Table I, p. 43. Snapshot: `Latimer__1942_Table1_brain_snapshot.csv`.
