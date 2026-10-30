# Dunbar & Bever 1998 - Table 2 (estimated neocortex size and group size, carnivores)

Dunbar RIM, Bever J (1998). *Neocortex size predicts group size in carnivores and some insectivores.* Ethology 104(8):695-708. doi:10.1111/j.1439-0310.1998.tb00103.x

## Source -> snapshot -> CSV
`Dunbar_Bever_1998.pdf` (EndNote 2154), Table 2 on PDF p.4. Text layer is scrambled, so `..._Table2_snapshot.csv` is a **constructed snapshot** read by eye from a 2.2x render: 43 rows, order and numeric formatting as printed, footnote digits kept on names/headers. `..._Table2.R` -> `..._Table2.csv` (volumes mm3 as printed). TSV skipped until the registry row is pasted into `__ReadMe.xlsx`.

## Fidelity checks
- Row count 43. CR re-computed as N/(B-N): matches printed (within 1%) for 40 of 43 rows. Mismatches: *Urocyon cineroargenteus* (1.22 vs 1.31 computed), *Vulpes rüppelli* (1.27 vs 1.22), *Vulpes velox* (1.31 vs 1.27).
- *Alopex lagopus* and *Vulpes velox* print IDENTICAL brain (31742) and neocortex (17769) volumes; the *V. rüppelli* CR (1.27) equals the Alopex value. Looks like a printing/row-shift error in the original; kept as printed and flagged.

## Group size
Column N = mean group size **as defined by the paper's sources** (Gittleman 1989a,b for carnivores; the general insectivore literature for Table 3). Not verified to equal the repo's Social_group_size definition; do not pool without a ruling. Lewitus 2014 (ref 72) copies group size and neocortex ratio from this paper: comparable columns are CR (neocortex ratio) and N. Lewitus's copy is secondary; prefer this table.

## Overlaps in repo
No Dunbar_Bever rows exist in the merges. Neocortex volume here is ESTIMATED from brain volume (eq. 1), so it is not an independent measurement; the 15 species of Table 1 are recomputed here with slightly different values (e.g. Meles meles 56779 vs 56771 mm3 brain).

## RA check still to do
Side-by-side read of the render against the snapshot.
