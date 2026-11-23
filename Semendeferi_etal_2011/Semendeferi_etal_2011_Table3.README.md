# Semendeferi_etal_2011_Table3

Table 3 | GLR in all ROIs, averaged by species, including SD. Source: `Semendeferi-2011-Spatial organization of.pdf`, PDF page 5 (journal page 1489), DOI in `__ReadMe.xlsx`.

## Build

Table 3 gives, for the six groups of Table 1, the mean gray level ratio (GLR, dimensionless — the fraction of the image area occupied by stained cell bodies) in layer III of BA 10, BA 4, BA 3 and BA 17. The table's note reads: "Regions include BA 10 (frontal pole), BA 4 (primary motor cortex), BA 3 (primary somatosensory cortex), and BA 17 (primary visual cortex)." Each cell is printed "mean (SD)" over the images of the individual specimens. The build splits each cell into a mean column and an SD column and resolves the group names to binomials as in the Table 1 build.

From the paper folder, run:

```sh
Rscript Semendeferi_etal_2011_Table3_snapshot.R
Rscript Semendeferi_etal_2011_Table3.R
```

The snapshot script captures the table programmatically from the frozen publisher PDF (snapshot HOWTO method 3: poppler `pdftotext -bbox` geometry, with the capture window ending at x = 560 so the rotated publisher download line at x = 570 cannot leak into the BA 17 column) and refuses to overwrite a differing frozen snapshot. It was run once for this build. On subsequent runs, run only `Rscript Semendeferi_etal_2011_Table3.R`. The R script reads only its item snapshot and writes `Semendeferi_etal_2011_Table3.csv` and the DOI-coded public TSV. The item definitions are in `reference_tables/`.

## Interpretation and checks

- **Species means only**, as in Table 2: per-specimen GLR values appear only in the paper's figures.
- **Capture checks.** The build asserts the values the Results text quotes: human BA 10 GLR 0.18 (the lowest value in the table), human BA 17 0.29, and the ape BA 3 range 0.28 (gorilla) to 0.33 (bonobo).
- **One text slip, in the paper, not the table.** The Results text describes the ape BA 17 range as running "from 0.31 in the chimpanzee specimens to 0.39 for the gibbons"; in this table 0.31 is the **bonobo** mean and the chimpanzee mean is 0.35 (the range endpoints 0.31–0.39 are right, the attribution is wrong). The build asserts the table's own values, and the slip is recorded here and in the registry row so the table is not "corrected" against the text later.
- The snapshot was captured programmatically and checked by the assistant against the rendered PDF page and the paper's text; human visual signoff remains pending in the registry. No merge is performed by this build.
