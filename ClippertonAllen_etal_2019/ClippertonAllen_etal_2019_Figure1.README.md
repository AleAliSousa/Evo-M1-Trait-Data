# ClippertonAllen_etal_2019_Figure1

Source: `Clipperton-Alle-2019-Pten haploinsufficiency d.pdf`. PDF Figure 1 panels a-b; 300 dpi manual bar/cap digitization. Registry item: `ClippertonAllen_etal_2019_Figure1` in `__ReadMe.xlsx`.

## Build

Twelve plotted group means for total brain, total gray matter and total white matter at P7/P60, control Pten+/+ versus Pten+/-. The caption defines bars as mean ± SEM; n is 10 per genotype at P7 and 10 controls/9 mutants at P60. Pixel-axis calibration is retained in the snapshot. Values and SEM are approximate visual digitizations, rounded to two decimals; refer to Table S1 for exact regional means. Panels c-f are omitted because they are relative percentage or image maps rather than additional absolute group means.

R reader converts source page-4 bar-top and upper-SEM-cap pixel positions to mm3 using each panel axis; no smoothing or model fit.

From this paper folder, run:

```sh
Rscript ClippertonAllen_etal_2019_Figure1.R
```

The script reads only `ClippertonAllen_etal_2019_Figure1_snapshot.csv` for measurements and writes `ClippertonAllen_etal_2019_Figure1.csv` plus the DOI-coded public TSV under `__Public/comparative-data/`. The snapshot is frozen; do not overwrite it when rebuilding. Definitions are in `reference_tables/ClippertonAllen_etal_2019_Figure1_definitions.csv`.

## Source and verification

Replot command: Rscript ClippertonAllen_etal_2019_Figure1_replot.R. The PNG was generated and compared with the source shape by AI. It preserves source age, genotype, tissue, panel-specific axis scales and SEM. It uses separate subpanels rather than the source broken axes and dual axis; individual mouse points are omitted because they were not extracted. Human visual signoff pending.

No cross-paper merge is performed by this item build. Condition labels and source measurement scopes must be respected before any merge.
