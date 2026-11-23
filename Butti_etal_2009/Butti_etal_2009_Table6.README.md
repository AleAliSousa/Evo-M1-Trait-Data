# Butti et al. 2009 — Table 6 (VEN, pyramidal and fusiform soma volumes)
Butti C, Sherwood CC, Hakeem AY, Allman JM, Hof PR (2009). *Total number and volume of Von Economo neurons in the cerebral cortex of cetaceans.* J Comp Neurol 515(2):243-259. doi:10.1002/cne.22055. PMID 19412956.
Full title (`__ReadMe.xlsx`): **"Table 6. Volume of Layer V VENs and Pyramidal Cell and Fusiform Cells of Layer VI"**

## Source->Snapshot
`..._Table6_snapshot.csv`: 4 rows as printed, each cell verbatim as `mean ± SD` with the thousands commas. Hand transcription, as for Tables 1 and 5.

## Data readable
`..._Table6.R` -> `..._Table6.csv`/`.tsv` (use this): 4 rows, one per species. Each printed cell is split into `_mean` and `_sd`, in the printed column order — VENs, pyramidal, fusiform.

## The VEN index checks the transcription
The caption defines it: *"The VEN index is the ratio between the average volume of VEN and the average volume of pyramidal neurons."* Recomputing it from the two printed means reproduces all four printed values to two decimal places — 1.3389→1.34, 1.0900→1.09, 1.2568→1.26, 1.7395→1.74. Carried both as printed and recomputed, and the build stops if they disagree. The index is a ratio, so it has `role = note` and is not merged.

## Units
Kept in μm³ as published. The project's mm³ standard is for structure volumes; these are somata. Same call as `Nimchinsky_etal_1999_Table2`, so the two items are directly comparable.

## Region — inferred, needs confirming
The caption does not name a cortical region. It is recorded as ACC in the definitions because Table 6 covers all four species and ACC is the only ROI with data for all four in the paper's Table 2. That is an inference and is flagged as one. **Confirm against the Results before these volumes are pooled with any other ACC measurement.**

## Layer
The printed title — *"Volume of Layer V VENs and Pyramidal Cell and Fusiform Cells of Layer VI"* — can be parsed either way. Read here as layer V for VENs and pyramidal cells, layer VI for fusiform, matching Nimchinsky et al. 1999 Table 2. Flagged in the definitions.

## Method
Optical rotator, isotropic slabs; parameters from the paper's Table 4. VENs: 2 μm focal plane separation, 9 μm grid line separation, 7 μm slab, 4 grid lines. Pyramidal: 3 / 6 / 7 / 4. Fusiform: 2 / 6 / 4 / 4.

## Comparisons
None. Founder item.

Pipeline: Source->Snapshot OK->Data readable OK->Species harmonized->Online database
