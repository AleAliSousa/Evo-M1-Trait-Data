# Latimer__1956 — Table 2 (brain stem, prosencephalon, cerebellum weights across 10 taxa)

## What this item is
Latimer (1956) reports the weights of the brain stem, prosencephalon (forebrain), and cerebellum,
plus the ratio of each suprasegmental part to the brain stem, across 10 taxa spanning frog to
human. Transcribed exactly as printed (`Latimer__1956_Table2_snapshot.csv`), converted to mg.

## Species and data provenance
Frog and Turtle are printed without a species-level binomial (`Species` left blank; only common
name in `species_as_published`). Per the paper's text (footnote, same page as Table 1), the Rat,
Baboon, and Man rows are **not this lab's own dissections** — they are the paper's own cited
secondary values (Rat: Donaldson 1924; Baboon: Riese & Riese 1952; Man: Donaldson 1909),
`data_role = secondary` with the citation recorded in `secondary_source`. The remaining 7 taxa
(Frog, Chicken, Turtle, Rabbit, Guinea pig, Cat, Dog) are Latimer's own measurements,
`data_role = primary`.

## Frog cerebellum
The frog's cerebellum was not weighed separately (per the paper's text) — `weight_cerebellum_mg`
and `ratio_cerebellum_to_brainstem` are blank for Frog.

## Source
`Latimer-1956-The Weights of the Parts of the B.pdf`, Table 2.

## Snapshot layout correction (2026-11-27)

Restored the printed six-column matrix with its caption and two header tiers. Removed the added `data_role` and `secondary_source` columns from the snapshot; the R reader derives them from the paper’s cited Rat, Baboon and Man rows. Run `Rscript --vanilla Latimer__1956/Latimer__1956_Table2.R` from repository root. Independent human source comparison remains separate.
