# Sherwood et al. 2009 - Table 3 (data used in the principal components analysis; 7 specimens)

Sherwood CC, Stimpson CD, Butti C, Bonar CJ, Newton AL, Allman JM, Hof PR (2009). Neocortical neuron types in Xenarthra and Afrotheria: implications for brain evolution in mammals. Brain Struct Funct 213(3):301-328. doi:10.1007/s00429-008-0198-9

## Source -> snapshot
`Sherwood_etal_2009.pdf` p.20 (journal p.320), Table 3. The text layer lists the columns out of order (the NPY column appears after the NPNFP columns), so the snapshot was **transcribed from a 2.2x render**: 7 rows, headers as printed, row order as printed, no blanks. `Sherwood_etal_2009_Table3.R` -> `.csv` (7 rows).

## What it is
Per-specimen percentages of neurons with each immunohistochemical marker (CB, CR, PV, NPY interneuron classes; NPNFP in layer V). These are the species/specimen neuron-type quantities that Lewitus et al. 2014 (ref 29) cites for 2 species. **Comparable Lewitus quantities live in columns 2-5** (% CB-/CR-/PV-/NPY-ir interneurons); columns 6-7 are layer V NPNFP measures. Histological/immunohistochemical percentages, **not** isotropic-fractionator counts. Table 3 is individual-level; the species rock hyrax and two-toed sloth have two specimens each (do not average silently).

## Fidelity checks
- Render vs text layer: all 42 numeric cells agree; column assignment taken from the render header.
- 7 rows = the 7 specimens of Table 1 (TS1, TS2, LA, GA, RH1, RH2, GES). Species are **not printed** in Table 3; the build script adds `species_inferred` from the common names and Table 1.
- Percent ranges are plausible (interneuron classes 1.2-8.4 percent; NPNFP 12.5-44.7 percent).

## Caveats / owner ruling
- All columns are from **primary somatosensory cortex (S1)** (Results: PCA used the percentage of the total Nissl-stained neuron population of layers II-VI of S1 immunostained for CB/CR/PV/NPY; NPNFP is the percentage of Nissl neurons in layer V of S1). Do not pool with whole-cortex percentages. Measure codes `p.N.*` are proposed, not in the glossary. Species-mean versions are plotted in Fig. 5/other figures; Table 3 is per specimen.
- Species names are inferred from the common names; the snapshot keeps the printed specimen label.

## Tables not built
See `README.md` (Tables 2, 4, 5).
