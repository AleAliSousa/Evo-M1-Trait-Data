# Sherwood et al. 2009 - Table 1 (specimens: sex, age, brain mass, body mass, fixation; 7 specimens, 5 species)

Sherwood CC, Stimpson CD, Butti C, Bonar CJ, Newton AL, Allman JM, Hof PR (2009). Neocortical neuron types in Xenarthra and Afrotheria: implications for brain evolution in mammals. Brain Struct Funct 213(3):301-328. doi:10.1007/s00429-008-0198-9

## Source -> snapshot
`Sherwood_etal_2009.pdf` p.3 (journal p.303), Table 1 "Specimens used in the study". Text layer scrambled; `Sherwood_etal_2009_Table1_snapshot.csv` is a **transcribed snapshot** read from a 2.2x render: 7 rows, printed row order, headers as printed, footnote letter `a` kept on the giant anteater brain mass (76a). Built by `Sherwood_etal_2009_Table1.R` -> `.csv` (7 rows).

## What it is
Specimen-level (one row per brain). Two Choloepus didactylus and two Procavia capensis specimens appear as separate rows - keep them separate (individual-level, histological/immunohistochemical study; **not** isotropic-fractionator data).

## Fidelity checks
- 7 rows = 7 specimens used (Table 3 lists the same 7: TS1, TS2, LA, GA, RH1, RH2, GES; match is by row order, species and the text "one of the two-toed sloths was a juvenile").
- Text layer (partial) agreed with the render for all numeric cells.
- Body mass 3.2 kg for a 28 g sloth brain and 0.471 kg elephant shrew are as printed.

## Caveats
- Giant anteater brain mass 76 g is **not measured** (from Bush & Allman 2004 volumetric data x 1.036); flagged in `brain_mass_footnote_a`. Methods text: "we used a brain mass of 76 g for the giant anteater".
- Age is text with lower bounds; juveniles are the giant anteater and one two-toed sloth (Methods) - not marked in the table.
- Species names exactly as printed (Choloepus didactylus, Tamandua tetradactyla, Myrmecophaga tridactyla, Procavia capensis, Rhynchocyon petersi).

## Lewitus et al. 2014
Lewitus ref 29 cites this paper for neuron-type data of 2 species. Those neuron-type percentages are in **Table 3** (columns % CB/CR/PV/NPY-ir interneurons, % NPNFP-ir), not here. Table 1 supplies the brain/body mass of the same specimens.

## Tables not built
See `Sherwood_etal_2009_Table3.README.md` and the section "Tables not built" in `README.md`.
