# Dunbar & Bever 1998 - Table 1 (carnivores with known neocortex volume)

Dunbar RIM, Bever J (1998). *Neocortex size predicts group size in carnivores and some insectivores.* Ethology 104(8):695-708. doi:10.1111/j.1439-0310.1998.tb00103.x

## Source -> snapshot -> CSV
`Dunbar_Bever_1998.pdf` (EndNote 2154), Table 1 on PDF p.3. Text layer is scrambled, so `..._Table1_snapshot.csv` is a **constructed snapshot** read by eye from a 2.2x render: 15 rows, order and numeric formatting as printed, footnote digits kept on names/headers. `..._Table1.R` -> `..._Table1.csv` (volumes mm3 as printed). TSV skipped until the registry row is pasted into `__ReadMe.xlsx`.

## Fidelity checks
- Row count 15 (the paper's eq. (1) quotes n = 18, i.e. 3 more species than printed here; not resolvable from the table).
- CR re-computed as N/(B-N): matches the printed value (within 0.006) for 11 of 15 rows. NOT matching: *Ailuropoda melanoleuca* (printed 2.355, computed 1.81), *Ursus americanus* (2.439 vs 1.70), *Procyon lotor* (1.407 vs 1.46), *Ailurus fulgens* (1.414 vs 1.43). Values kept as printed; image re-read, so either the paper's CR used different underlying volumes or contains errors.

## Group size
Column N = mean group size **as defined by the paper's sources** (Gittleman 1989a,b for carnivores; the general insectivore literature for Table 3). Not verified to equal the repo's Social_group_size definition; do not pool without a ruling. Lewitus 2014 (ref 72) copies group size and neocortex ratio from this paper: comparable columns are CR (neocortex ratio) and N. Lewitus's copy is secondary; prefer this table.

## Overlaps in repo
No Dunbar_Bever rows exist in the merges. Actual neocortex volumes (not estimated). Same species recur in Table 2 with ESTIMATED volumes (recalculated by eq. 1); do not treat as independent.

## RA check still to do
Side-by-side read of the render against the snapshot.
