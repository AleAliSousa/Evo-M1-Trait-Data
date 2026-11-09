# Young et al. 2013 — whole-cortex surfaces in Results text

Young, N. A., Collins, C. E., & Kaas, J. H. (2013). Cell and neuron densities in the primary motor cortex of primates. *Frontiers in Neural Circuits, 7*, 30. https://doi.org/10.3389/fncir.2013.00030

The paper reports eight **whole flattened hemisphere** surface areas in the Results species sections, outside Table 1: three galagos, one owl monkey, one squirrel monkey, one macaque, and two baboons. The Kaskan workbook identified where to look; its arithmetic means are not observations in this item.

I independently transcribed all eight values from the source PDF Results text. `Young_etal_2013_ResultsTextSurface_pdf_transcription.csv` records the printed values and PDF pages; the R script rebuilds the data CSV from it. This item is registered separately from `Young_etal_2013_Table1`, whose M1 regional areas must never be interpreted as whole-cortex areas.

Some specimens overlap Collins et al. 2010 and Turner et al. 2016. This item is **provenance-only pending case-level deduplication** and is not wired into `__merging_cortical_areas`. The galago labels are printed as numbered animals; no independent specimen ID is asserted for the owl or squirrel monkey here.

## Update 2026-11-09

The R script now finds its own folder (so the repo-wide run_all sweep can run it from the repo root) and writes the public TSV `10.3389%2Ffncir.2013.00030_ResultsTextSurface.tsv` (Item encoded looked up in `__ReadMe.xlsx` by Item name), which had been missing. The transcription, the checks and the CSV are unchanged. The TSV now in `__Public/comparative-data/` was written from the CSV by a Python mirror of `write.table(sep = "\t", na = "")` (R NOT RUN); rerun the R to confirm.
