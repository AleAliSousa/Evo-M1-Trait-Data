# Lewitus et al. 2012 - ESM Table S1A (V1 stereology: glia:neuron ratio, neuronal and glial density; 36 non-primate species)

Lewitus, Sherwood & Hof (2012). Brain Struct Funct 217(2):531-547. doi:10.1007/s00429-011-0338-5

## Source -> snapshot
`429_2011_338_MOESM1_ESM.doc` is a Word file containing two embedded OpenDocument spreadsheet objects (text conversion yields only 'EMBED' stubs). The objects were carved out of the .doc (zip signature) in the scratchpad and `content.xml` parsed; both objects are byte-identical (one table, 'Sheet17'). `..._TableS1A_snapshot.csv` is that sheet verbatim (title row, 'PRIMARY VISUAL CORTEX' banner, header, 36 species rows, footnotes; full-precision values; '--' and 'NA' as printed; the empty 5th column kept).

## Fidelity checks
- 36 species rows (matches the '36 species' in the Lewitus 2014 reference list); 32 have cell data, 4 are '--' (Megaptera novaeangliae, Rhinoceros unicornis, Phoca vitulina, Manis gigantea).
- Every number is exactly 10^(two-decimal number): the supplement stores back-transformed 2-dp log10 values, so real precision is ~+/-1%.
- Glia:neuron ratio vs glial/neuronal density: max difference 0.05 (separate back-transformations); not a transcription error.
- **Cynocephalus volans has identical ratio, neuronal and glial density to Dasyprocta leporina** (brain/body/gestation differ). Probable copy-down error in the source; kept as printed, flagged. Lewitus 2014 S1 lists Dasyprocta only.
- The ESM has NO primate rows and none of the Table 4 apes; primate densities (and the glial densities in main Table 4) are not available here.

## Relation to Lewitus et al. 2014 Table S1 (Glia_neuron_ratio, Neuronal_density, Glial_cell_density)
Compared species by species (S1 `Sus scrofa domesticus` = ESM `Sus scrofa`):
- S1 holds cell data for 36 species: 15 non-primates + 21 primates.
- **15 of 15 non-primate S1 rows match this ESM** within S1's rounding (ratio to 2 dp, densities to integers; max |diff| 0.005, 0.46, 0.43). 0 mismatches.
- 21 S1 primate rows have no counterpart here (ESM has no primates).
- 17 ESM species with cell data are absent from S1 (Lepus, Stenella, Mustela, Neovison, Mephitis, Taxidea, Procyon cancrivorus, Nasua, Bassaricyon, Potos, Ailurus, Callorhinus, Canis lupus familiaris, Panthera, Puma, Scalopus, Cynocephalus volans).
- S1's values are therefore a rounded copy of this ESM (secondary); prefer this item.

## Caveats
Stereology: Measure codes end .Stereology. Brain mass unsourced; body mass and gestation from Jones et al. 2009 (secondary). Species names as printed.

## Build
`Lewitus_etal_2012_TableS1A.R` -> `..._TableS1A.csv` (36 rows). RA side-by-side check pending.
