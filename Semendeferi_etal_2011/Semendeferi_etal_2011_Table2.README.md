# Semendeferi_etal_2011_Table2

Table 2 | HSD in all ROIs, averaged by species, including SD (in microns). Source: `Semendeferi-2011-Spatial organization of.pdf`, PDF page 4 (journal page 1488), DOI in `__ReadMe.xlsx`.

## Build

Table 2 gives, for the six groups of Table 1, the mean horizontal spacing distance (HSD, microns) between neurons in layer III of BA 10 (frontal pole), BA 4 (primary motor cortex), BA 3 (primary somatosensory cortex) and BA 17 (primary visual cortex) — the table's note reads: "Regions include BA 10 (frontal pole), BA 4 (primary motor cortex), BA 3 (primary somatosensory cortex), and BA 17 (primary visual cortex). SD, standard deviation." Each cell is printed "mean (SD)", the SD across the multiple images of the individual specimens. The build splits each cell into a mean column and an SD column and resolves the group names to binomials as in the Table 1 build.

From the paper folder, run:

```sh
Rscript Semendeferi_etal_2011_Table2_snapshot.R
Rscript Semendeferi_etal_2011_Table2.R
```

The snapshot script captures the table programmatically from the frozen publisher PDF (snapshot HOWTO method 3: poppler `pdftotext -bbox` geometry; no value typed by hand) and refuses to overwrite a differing frozen snapshot. It was run once for this build. On subsequent runs, run only `Rscript Semendeferi_etal_2011_Table2.R`. The R script reads only its item snapshot and writes `Semendeferi_etal_2011_Table2.csv` and the DOI-coded public TSV. The item definitions are in `reference_tables/`.

## Interpretation and checks

- **Species means only.** Per-specimen HSD values are not printed anywhere in the paper (Figures 3 and 6 plot them graphically); this item is species-level by construction, and the SDs are across images/specimens pooled by species, not standard errors.
- **Capture checks.** Every mean the Results text quotes agrees with the table, and the build asserts them: human BA 10 59.52, BA 4 49.23, BA 3 45.32, BA 17 38.61 µm; gibbon BA 17 29.50 µm (the lowest ape value); the ape BA 4 range 44.26 (bonobo) to 52.66 (chimpanzee) µm.
- One coincidence to note so it is not mistaken for a capture slip: the BA 10 SD is 3.39 for both Orangutan and Gibbon, as printed in both the text layer and the rendered page.
- The snapshot was captured programmatically and checked by the assistant against the rendered PDF page and the paper's text; human visual signoff remains pending in the registry. No merge is performed by this build.
