# HerculanoHouzel_etal_2016

Build target: Table 2 spinal-cord neuron counts and their observed/predicted status, with N_CX, N_M1, and the published N_M1/N_SC ratio retained because they define the paper's derivation. This is a synthetic secondary/derived compilation, not a new primary spinal-cord experiment. Observed N_SC values are attributed to Burish et al. (2010); predicted N_SC values use MacLarnon (1996) spinal-cord masses and the published scaling equation. Missing table cells remain missing.

## Table 2 snapshot layout recheck (2026-11-27)
Compared the snapshot with the local PDF, printed p. 451. The snapshot now
keeps the five printed columns, including the source reference or prediction
mark in each measurement cell, and the caption and footnote below the grid.
The R reader extracts numeric values and observed/predicted status and adds
analysis provenance fields. Run from the repository root:
`Rscript HerculanoHouzel_etal_2016/HerculanoHouzel_etal_2016_Table2.R`.
The rebuilt 14-row analysis CSV matches the prior version cell for cell.
This layout check is separate from independent human source signoff.
