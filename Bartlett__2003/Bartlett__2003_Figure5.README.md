# Bartlett__2003_Figure5

Figure5, printed p.247; PDF p.9.

Digitized stacked bars: play is the upper segment height, not the total bar height. Monthly activity-budget percentages; approximate to 0.1 percentage point, conservative reading tolerance ±0.2. These are seasonal measurements, not 12 independent species or a new annual mean. Axis calibration and pixel positions in reference_tables/Figure5_digitization.json.

Frozen source: `Bartlett__2003_Figure5_snapshot.csv`. This constructed snapshot records the stated endpoint, not a transcription of every curve. Source inspected by assistant; human sign-off not claimed.

Rebuild: `Rscript Bartlett__2003/Bartlett__2003_Figure5.R`.

## Quick figure replot (pilot, 2026-11-20)

From the repository root:

```sh
Rscript --vanilla Bartlett__2003/Bartlett__2003_Figure5_replot.R
```

The standalone base-R script reads `Bartlett__2003_Figure5.csv` and saves
`Bartlett__2003_Figure5_replot.png` beside it. It orders the 12 rows by
`source_month_order`, then stacks `Groom_time.pct` below `Play_time.pct` on the
source's linear 0–20% activity axis. Play remains a segment height; it is not
treated as the total. February–January order and the two grey fills are retained.
Month labels are expanded for clarity and background gridlines are omitted.
No error bars are shown in the source, and the digitisation tolerance is not
plotted as biological uncertainty.

Codex ran the script in clean R sessions with `Rscript --vanilla` and `source()`
and visually compared the PNG with Figure 5 on printed p.247 / PDF p.9. All 12
stacks show the source's seasonal pattern, including the May maximum and
November minimum, with grooming at the bottom. No new discrepancy was identified
in this shape check. This is AI review, not human visual signoff.
