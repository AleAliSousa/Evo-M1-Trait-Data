#!/usr/bin/env python
"""Dickscheid et al. (2021) BigBrain layer-wise cell-density series -- read the AVERAGED REPORT figures.

Each dataset's averaged report, <area_dir>/v1.0/stats.pdf, is a one-page, figure-only pdf with three bar charts and
no table: (1) "Average layer thickness (micron)" per layer I-VI, (2) "Avg. # detected cells / 0.1mm3" per layer
I-VI, (3) a histogram of segmented cell-body areas.  Because the pdf is vector graphics, the bar heights can be read
back exactly: each bar is a filled rectangle, the y axis is calibrated from the numeric tick labels (slope) and the
bottom edge of the axes frame (zero of a matplotlib bar chart), and the six bars are read left to right (x-axis
labels I..VI are asserted).  The reading precision is far below 0.01 cells / 0.1 mm3 and 0.1 micron.

Output (one row per item x panel x layer): reference_tables/Dickscheid_etal_2021_stats_pdf_bars.csv
  item_name, area_dir, stats_pdf, panel (layer_thickness_micron | cells_per_0.1mm3), layer, value_from_pdf,
  y_axis_ticks (the tick labels used), tick_fit_max_residual (calibration check, should be ~0)
The build script Dickscheid_etal_2021_build.R uses this table only for its table checks (computed means vs the
published figure); it is NOT a data source.

Run:  conda run -n neuro-atlas python Dickscheid_etal_2021_stats_pdf_bars.py    (needs pdfplumber, numpy, pandas)
"""
import csv, os, re, sys
import numpy as np, pandas as pd, pdfplumber

HERE   = os.path.dirname(os.path.abspath(__file__))
series = os.path.splitext(os.path.basename(__file__))[0].removesuffix("_stats_pdf_bars")
datasets = list(csv.DictReader(open(os.path.join(HERE, "reference_tables", series + "_datasets.csv"), encoding="utf-8")))
out_csv  = os.path.join(HERE, "reference_tables", series + "_stats_pdf_bars.csv")
PANELS   = ["layer_thickness_micron", "cells_per_0.1mm3"]          # left-to-right order of the two bar charts
LAYERS   = ["I", "II", "III", "IV", "V", "VI"]

rows = []
for ds in datasets:
    path = os.path.join(HERE, ds["stats_pdf"])
    with pdfplumber.open(path) as pdf:
        assert len(pdf.pages) == 1
        pg = pdf.pages[0]; words = pg.extract_words(); rects = pd.DataFrame(pg.rects)
    text = pg.extract_text() or ""
    assert "Avg. # detected cells / 0.1mm3" in text.replace("\n", " ") or "sllec" in text, "y-axis label not found"
    frames = rects[(rects.width > 100) & (rects.fill == True)].sort_values("x0")   # the three axes backgrounds
    assert len(frames) == 3, (path, len(frames))
    for panel, (_, frame) in zip(PANELS, list(frames.iterrows())[:2]):
        px0, px1 = frame.x0, frame.x1
        bars = rects[(rects.x0 > px0) & (rects.x1 < px1 + 1) & (rects.width < 30) & (rects.width > 5)
                     & (rects.bottom <= frame.bottom + 0.5) & (rects.top >= frame.top - 0.5)].sort_values("x0")
        assert len(bars) == 6, (path, panel, len(bars))
        xlab = [w["text"] for w in sorted([w for w in words if px0 < w["x0"] < px1 and frame.bottom < w["top"] < frame.bottom + 15],
                                          key=lambda w: w["x0"])]
        assert xlab == LAYERS, (path, panel, xlab)
        ticks = [w for w in words if px0 - 40 < w["x1"] < px0 and re.fullmatch(r"\d+", w["text"])
                 and frame.top - 5 < w["top"] and w["bottom"] < frame.bottom + 5]
        yv = np.array([float(w["text"]) for w in ticks]); yc = np.array([(w["top"] + w["bottom"]) / 2 for w in ticks])
        slope, icpt = np.polyfit(yc, yv, 1)
        resid = float(np.abs(yv - (slope * yc + icpt)).max())
        assert len(ticks) >= 4 and resid < 0.01 * max(yv), (path, panel, resid)
        vals = slope * (bars.top.values - frame.bottom)             # frame bottom = 0 of the bar chart
        for layer, v in zip(LAYERS, vals):
            rows.append(dict(item_name=ds["item_name"], area_dir=ds["area_dir"], stats_pdf=ds["stats_pdf"], panel=panel,
                             layer=layer, value_from_pdf=round(float(v), 4),
                             y_axis_ticks=" ".join(w["text"] for w in sorted(ticks, key=lambda w: w["top"])),
                             tick_fit_max_residual=round(resid, 6)))
    print(ds["item_name"], "ok")
pd.DataFrame(rows).to_csv(out_csv, index=False, lineterminator="\n")
print("wrote", os.path.relpath(out_csv, HERE), len(rows), "rows")
