# Dunbar & Bever 1998 - Table 3 (neocortex size and group size of insectivores, GENUS level)

Dunbar RIM, Bever J (1998). *Neocortex size predicts group size in carnivores and some insectivores.* Ethology 104(8):695-708. doi:10.1111/j.1439-0310.1998.tb00103.x

## Source -> snapshot -> CSV
`Dunbar_Bever_1998.pdf` (EndNote 2154), Table 3 on PDF p.5. Text layer is scrambled, so `..._Table3_snapshot.csv` is a **constructed snapshot** read by eye from a 2.2x render: 25 rows, order and numeric formatting as printed, footnote digits kept on names/headers. `..._Table3.R` -> `..._Table3.csv` (volumes mm3 as printed). TSV skipped until the registry row is pasted into `__ReadMe.xlsx`.

## Fidelity checks
- Row count 25 genera. CR re-computed from the printed means: matches within 0.006 for 24 of 25 (*Suncus*: 0.151 vs 0.160); CR is stated to be averaged over species so small deviations are expected.
- Rows are GENERA (column 'Genus'), mean over 'No. of spp. sampled' species; `species` is therefore absent from the CSV and the table cannot enter a species-level merge without a genus-to-species ruling.

## Group size
Column N = mean group size **as defined by the paper's sources** (Gittleman 1989a,b for carnivores; the general insectivore literature for Table 3). Not verified to equal the repo's Social_group_size definition; do not pool without a ruling. Lewitus 2014 (ref 72) copies group size and neocortex ratio from this paper: comparable columns are CR (neocortex ratio) and N. Lewitus's copy is secondary; prefer this table.

## Overlaps in repo
No Dunbar_Bever rows exist in the merges. Brain/neocortex volumes derive from Frahm et al. (1982) and Stephan et al. (1981, 1984); the repo holds Stephan_etal_1981 (Neocortex volume per species) - the volumes here are genus means of that lineage, secondary, do not double-count.

## RA check still to do
Side-by-side read of the render against the snapshot.
