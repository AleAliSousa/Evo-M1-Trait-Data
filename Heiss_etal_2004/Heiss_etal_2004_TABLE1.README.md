# Heiss et al. 2004 - Table 1 (regional cerebral glucose metabolism, human)  [energetics]
Heiss W-D, et al. (2004). Regional cerebral metabolic rate of glucose (CMRgl) by brain region in
healthy humans (FDG-PET). `Heiss_etal_2004.pdf`.

## Energetics dataset (not a volume; not in the volume merge)
Table 1 = regional **CMRgl** (cerebral metabolic rate of glucose) for ~26 human brain regions:
both-hemisphere mean (+SD), the left-minus-right hemisphere difference (+SD, p), and a comparison
column from an earlier Heiss study. Single species (Homo sapiens). Units: umol glucose / 100 g / min
(per the paper; verify). This is a metabolic-rate dataset, kept separate from the phylogenetic
volume merge.

## Source -> Snapshot -> Data
`Heiss_etal_2004_TABLE1_snapshot.xlsx` (faithful) -> `Heiss_etal_2004_TABLE1.r` ->
`Heiss_etal_2004_TABLE1.csv` (+ a DOI-coded public TSV). The script reconstructs the two-row header,
restores the indented region hierarchy into a `category` column, and coerces numerics.

## Related energetics datasets in this repo
See `__energetics_comparison/` for a cross-paper comparison with Kaufman 2004 (multi-species regional
CMRgl/CMRO2/CBF) and Karbowski 2007 (rodent glucose/oxygen). A common merge schema is proposed there
for your confirmation before any energetics merge is built.
