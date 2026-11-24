# Bjugn Gundersen 1993 — Table2

Bjugn, R., & Gundersen, H. J. G. (1993). Estimate of the total number of neurons and glial and endothelial cells in the rat spinal cord by means of the optical disector. *Journal of Comparative Neurology*, 328, 406–414. [DOI](https://doi.org/10.1002/cne.903280307).

## Source and scope

The exact source PDF is held as `Bjugn-1993-Estimate of the total number of neu.pdf` in this folder. This item is Table 2 on PDF page 4 (printed page 409). The frozen CSV snapshot was made by manual transcription from the scanned printed table; OCR was used only to locate cells, in source row and column order, and checked against a rendered page by Codex on 2026-11-24. Five individual rats with white/gray-matter totals, glial, endothelial and neuronal estimates. The printed Mean, SD and CV rows remain source summaries. Cell numbers are in millions; CE is printed only for gray-matter neuron estimates. All individual Σ values equal G+E+N to printed precision. The printed mean gray-neuron estimate is 6.42 million. The source explicitly excludes ependymal cells.

## Build and validation

From repository root run `Rscript --vanilla Bjugn_Gundersen_1993/Bjugn_Gundersen_1993_Table2.R`. The reader uses only this item’s frozen snapshot and writes its analysis CSV and the public TSV named by the `__ReadMeAddON.xlsx` registry row. 64 long rows (8 printed rows × 2 matter classes × 4 cell classes). Individual and summary rows have distinct data roles. Numeric cells remain as printed; no figures were extracted in this item, so no figure replot applies. The source PDF and snapshot still need human visual signoff before downstream merge.
