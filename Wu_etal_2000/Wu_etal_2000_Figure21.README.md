# Wu et al. 2000, Figure 21

Wu, C. W.-H., Bichot, N. P., & Kaas, J. H. (2000). Converging evidence from microstimulation, architecture, and connections for multiple motor areas in the frontal and cingulate cortex of prosimian primates. *The Journal of Comparative Neurology*, 423(1), 140–177. DOI: [10.1002/1096-9861(20000717)423:1<140::AID-CNE12>3.0.CO;2-3](https://doi.org/10.1002/1096-9861(20000717)423:1%3C140::AID-CNE12%3E3.0.CO;2-3).

## Source and extraction

Figure 21 is on printed page 173 / page 34 of the exact EndNote PDF at `/Users/crossmodal/Documents/References.Data/PDF/1504569911/Wu-2000-Converging evidence from microstimulat.pdf`. The source PDF remains in the personal EndNote library. `reference_tables/Wu_etal_2000_Figure21_source.png` is a 300-dpi crop of that page for audit. `reference_tables/Wu_etal_2000_Figure21_pixel_readings.csv` preserves the 20 bar and upper-whisker coordinates, physical left-to-right order, area, movement category and source x position. The two axis ticks used for calibration are in `reference_tables/Wu_etal_2000_Figure21_axis.csv`. The independent digitization reading uncertainty is about ±3 pixels, or ±2 µA; it is not an SEM.

`Wu_etal_2000_Figure21_snapshot.R` reads those frozen coordinate tables, converts the source's linear axis to approximate µA values, and writes `Wu_etal_2000_Figure21_snapshot.csv`; it refuses to replace a differing snapshot. The item reader only reads that snapshot for scientific values. The caption states that the plotted means and error bars are averages and SEM across cases, so the upper-whisker distance is reported as approximate SEM. The three tiny M1 whisker endpoints were not legible in the preserved image; those SEM fields are blank. No lower endpoint or individual-case threshold is invented. The paper prints *Galago garnetti*; the analysis file retains that label and maps it to *Otolemur garnettii* using NCBI taxid 30611 and [MDD's synonym record](https://www.mammaldiversity.org/taxon/1001050/).

## Build and replot

From the repository root, run:

```sh
Rscript --vanilla Wu_etal_2000/Wu_etal_2000_Figure21_snapshot.R
Rscript --vanilla Wu_etal_2000/Wu_etal_2000_Figure21.R
Rscript --vanilla Wu_etal_2000/Wu_etal_2000_Figure21_replot.R
```

The first command reproduced the frozen snapshot identically on 2026-11-23. The second wrote the 20-row local CSV and DOI-coded public TSV. The standalone base-R replot reads only the analysis CSV and writes `Wu_etal_2000_Figure21_replot.png` beside it. Codex inspected the replot against the preserved source crop on 2026-11-23: area order, five movement-category identities, relative bar heights, linear threshold scale and legible upper SEM endpoints match the source shape. The replot simplifies the source hatching and group spacing; it omits the three unreadable M1 SEM whiskers and the neighboring Figure 22. This is an AI visual check, not human signoff, which remains pending.
