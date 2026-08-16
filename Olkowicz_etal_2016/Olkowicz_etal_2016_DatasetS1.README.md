# Olkowicz et al. 2016 — Dataset S1

## Source

Olkowicz, S., Kocourek, M., Lučan, R. K., Porteš, M., Fitch, W. T.,
Herculano-Houzel, S., and Němec, P. (2016). *Birds have primate-like numbers
of neurons in the forebrain.* **PNAS 113**: 7255–7260. DOI
**10.1073/pnas.1517131113**. Registry item
`Olkowicz_etal_2016_DatasetS1`.

The frozen publisher supplement is retained byte-for-byte inside
`pnas.1517131113.sd01.source.zip` (archive MD5
`4ea82db38d2f673ed7f3588b0f2caa50`; contained XLSX MD5
`0b0454f3d3da43e405fb5d444f9a0e4f`). The outer ZIP prevents cloud-office
software from rewriting the downloaded XLSX package metadata. Dataset S1
contains species means for 73 birds representing 28 species.

## Pipeline and representation

`Olkowicz_etal_2016_DatasetS1.R` reads the machine-readable supplement,
assigns stable names to all 79 source fields, adds `source_row` and the explicit
class gate `Class = Aves`, and writes the local CSV, variable definitions, and
`10.1073%2Fpnas.1517131113_DatasetS1.tsv`.

The wide output preserves mass, total-cell, neuron, non-neuronal-cell,
NeuN-percentage, density, and whole-brain-share fields for whole brain,
telencephalon, pallium, subpallium, tectum, diencephalon, cerebellum,
brainstem, and the source's separately reported “rest of brain” grouping.
Pallium and subpallium remain subdivisions of telencephalon and must not be
added to it as independent structures.

## Verification and scope gate

- all 28 source species and all 75 numeric source measurements are retained;
- for every structure, total cells reproduce neurons plus non-neuronal cells;
- whole-brain mass and cell totals reproduce telencephalon + tectum +
  diencephalon + cerebellum + brainstem;
- telencephalon totals reproduce pallium + subpallium;
- source spelling and capitalization are preserved, including
  `Taenipygia guttata` and `Corvus mondeula`; no silent taxonomic correction is
  made before a bird-capable resolver exists;
- the dataset is built and publicly shelf-stocked, but it is intentionally not
  added to the mammal-only compiled cell-count merge. A future Aves-aware merge
  must retain `Class` and the avian region scheme.
