# Gatome etal 2010 — Table2

Gatome, C. W., Slomianka, L., Lipp, H. P., & Amrein, I. (2010). Number estimates of neuronal phenotypes in layer II of the medial entorhinal cortex of rat and mouse. *Neuroscience*, 170, 156–165. [DOI](https://doi.org/10.1016/j.neuroscience.2010.06.048).

## Source and scope

The exact source PDF is held as `Gatome-2010-Number estimates of neuronal pheno.pdf` in this folder. This item is Table 2 on PDF page 5 (printed page 160). The frozen CSV snapshot was made by manual transcription from the printed table with text-layer cross-check, in source row and column order, and checked against a rendered page by Codex on 2026-11-24. Sixteen phenotype/field rows across CE and ME, each with rat and mouse mean number (SD), coefficient of error where printed, mean proportion (SD) and P-values where printed. Blank CE/P cells reflect small sample sizes as noted in the caption. The eight printed proportions sum to about 100% for each species/field, within 0.1 percentage point from rounding. These are unilateral counts, not independent animals; group n is five rats and six mice.

## Build and validation

From repository root run `Rscript --vanilla Gatome_etal_2010/Gatome_etal_2010_Table2.R`. The reader uses only this item’s frozen snapshot and writes its analysis CSV and the public TSV named by the `__ReadMeAddON.xlsx` registry row. 32 long rows (16 printed rows × 2 species), with SD and P-values preserved. Numeric cells remain as printed; no figures were extracted in this item, so no figure replot applies. The source PDF and snapshot still need human visual signoff before downstream merge.
