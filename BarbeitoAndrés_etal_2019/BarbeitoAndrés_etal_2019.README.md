# Barbeito-Andrés et al. 2019 (developmental / experimental mouse dataset)
Barbeito-Andrés J, et al. (2019). *Region-specific changes in Mus musculus brain size and cell
composition under chronic nutrient restriction.* Journal of Experimental Biology.

## Separate comparison set (NOT in the volume merge)
Single species (Mus musculus) under experimental nutrition groups. This is a developmental/
experimental dataset, kept as its own comparison set; it is **not** part of the phylogenetic
volume merge in `__merging_volumes/`.

## Source -> Snapshot
`data_figshare.xlsx` sheet **Hoja1** only (Hoja2 and Hoja3 are empty). Hoja1 stacks three
sub-tables, frozen in each of the three registered CSV/TSV snapshot pairs as
the same complete source worksheet grid. The item readers select the absolute
volume, cell-number, or cell-density block, respectively.
Snapshot scripts (one per item; each writes its own source-grid CSV+TSV from
`data_figshare.xlsx`): `..._volumes_snapshot.R`, `..._cellnumber_snapshot.R`,
`..._celldensity_snapshot.R`. Item scripts (`..._volumes.R`,
`..._cellnumber.R`, `..._celldensity.R`, `..._tidy.R`) read the snapshots;
the former single script `BarbeitoAndrés_etal_2019.R` was split into these.
Groups: **C** = control, **LP** = low protein, **LCP** = low calorie + protein (labels as published).

## Data readable
`BarbeitoAndrés_etal_2019_tidy.R` -> `BarbeitoAndrés_etal_2019_tidy.csv`: one tidy long table aligned to a
generic developmental schema `species, reference, group, specimen, region, cell_type, measure, value,
units`. `measure` in {absolute_volume (mm3), cell_number, cell_density}.

## Units & scaling - VERIFIED (internal consistency)
The figshare sheet states no units. Resolved by an internal-consistency check (`cell_density x
absolute_volume` vs `cell_number`, per group x region x cell_type, using group-mean regional volumes;
Rest = Total - the four named regions):
- The ratio `(cell_density x volume) / cell_number` is consistent **across cell types within each
  region** (e.g. Cerebellum/C: Neurons 1254, Non-neurons 1218, Total 1251) and centres on **~10^3**
  (median 868, mean 944, range 681-1540 across 45 cells). The region-level spread reflects a
  volume-subset / parcellation mismatch (the cell-count subset carries no specimen ids), not a unit
  ambiguity - the within-region cross-cell-type agreement confirms the data is internally consistent.
- Confirmed scaling (isotropic-fractionator convention; volume mm3 ~ mg tissue, rho ~ 1 mg/mm3):
  - **cell_density = published value x 10^3 cells/mg**
  - **cell_number  = published value x 10^6 cells**
  - absolute_volume = mm3 (Total ~ 365-380 mm3 for a mouse brain -> consistent).
- Applied to `..._tidy.csv` (`units` column is now `10^3 cells/mg` / `10^6 cells`) and to
  `..._definitions.csv`. (No source PDF text was needed; verification is by internal arithmetic.)

## Remaining caveat
- The cell tables label rows by group only (no specimen id; `specimen = NA`), so per-animal pairing to
  the volume table is not possible from the snapshot; group-level means were used for the check above.

Pipeline: Source -> Snapshot OK -> Data readable OK -> units/scaling VERIFIED (internal consistency) -> standalone comparison set.
## Snapshot layout recheck (2026-11-27)

The three registered snapshot pairs (`volumes`, `cellnumber`,
`celldensity`; CSV and TSV each) now copy the complete 69-row by 16-column
`Hoja1` worksheet grid from `data_figshare.xlsx`. Source labels, internal
blanks, and 23 `SUM` formulas remain in their original cells. Every source
cell was compared with each of the six snapshots: no mismatches.

The three item R readers select their corresponding source block and do the
reshaping for analysis. The volumes reader evaluates the source `SUM`
formulas. Rebuild from the repository root with
`Rscript BarbeitoAndrés_etal_2019/BarbeitoAndrés_etal_2019_volumes.R`,
`Rscript BarbeitoAndrés_etal_2019/BarbeitoAndrés_etal_2019_cellnumber.R`, and
`Rscript BarbeitoAndrés_etal_2019/BarbeitoAndrés_etal_2019_celldensity.R`.
The combined `Rscript BarbeitoAndrés_etal_2019/BarbeitoAndrés_etal_2019_tidy.R`
reader was also updated and rebuilt to 724 rows. Output row counts and
substantive values match prior analysis CSVs; 25 item-level
numeric cells differ only in floating-point serialization (maximum absolute
difference 1.14e-13). This is separate from independent human source signoff.
