#!/usr/bin/env python3
"""Builds the frozen snapshot of Heffner, Koay & Heffner (2020) Figure 3
by reading the PDF's VECTOR content -- not by pixel digitisation.

Heffner, R. S., Koay, G., & Heffner, H. E. (2020). Hearing and sound
localization in Cottontail rabbits, Sylvilagus floridanus. J Comp Physiol A
206:543-552. doi:10.1007/s00359-020-01424-8

Figure 3 (journal p. 548) plots high-frequency hearing limit at 60 dB SPL (kHz,
log axis) against functional interaural distance (us, log axis) for n = 74
species. The paper prints no comparative table and no numeric point list.

Because the PDF is born-digital, each plot marker is a vector path with exact
page coordinates, and each axis tick is a vector line. This script therefore:
  1. reads the x/y axis tick lines and least-squares fits log10(value) against
     page coordinate (the fit residuals are reported; both axes are exact log
     scales, so a good fit is a check that the calibration is right);
  2. reads every marker path, takes its centre, and converts to data units;
  3. records each marker's raw drawn geometry (fill/stroke, grey vs black fill,
     path point count, size) as audit columns. NOTE: these do NOT reliably
     recover the caption's symbol classes -- a circle and a square drawn as
     Bezier paths give the same anchor-point count -- so no symbol class is
     asserted here. Where a point carries a printed label, the caption's scheme
     (squares = bats, stars = rabbits, diamonds = subterranean, triangles =
     aquatic, grey fill = rodent, black fill = echolocating) is read off the
     species instead.
This is reproducible and far more precise than eyeball digitisation, but the
values remain FIGURE-DERIVED: value_origin = digitised_from_figure everywhere.

Species identity is NOT determined here -- only ~41 of the 74 points carry a
printed label. Label-to-marker assignment is the interpretive step and lives in
reference_tables/Heffner_etal_2020_Figure3_label_assignment.csv.
"""
import pdfplumber, csv, os, statistics

HERE = os.path.dirname(os.path.abspath(__file__))
PDF = os.path.join(HERE, "Heffner-2020-Hearing and sound localization in.pdf")
SNAP = os.path.join(HERE, "Heffner_etal_2020_Figure3_snapshot.csv")
PAGE = 5  # 0-based; journal p. 548

X_TICKS = [40, 50, 60, 70, 80, 90, 100, 200, 300, 400, 500, 600, 700, 800, 900,
           1000, 2000, 3000, 4000]
Y_TICKS = [200, 150, 120, 100, 90, 80, 70, 60, 50, 40, 30, 20, 10, 9, 8, 7, 6, 5]

import math

def fit(coords, values):
    """least-squares log10(value) = a*coord + b ; returns a, b, max abs residual"""
    logs = [math.log10(v) for v in values]
    n = len(coords)
    mx, my = sum(coords) / n, sum(logs) / n
    sxy = sum((c - mx) * (l - my) for c, l in zip(coords, logs))
    sxx = sum((c - mx) ** 2 for c in coords)
    a = sxy / sxx
    b = my - a * mx
    resid = [abs(10 ** (a * c + b) - v) / v for c, v in zip(coords, values)]
    return a, b, max(resid)

def geometry(c):
    """raw drawn geometry of one marker path (audit columns only)"""
    w = c["x1"] - c["x0"]; h = c["bottom"] - c["top"]
    filled, stroked = bool(c.get("fill")), bool(c.get("stroke"))
    npts = len(c.get("pts", []))
    # colour of the fill: black echolocators vs grey rodents
    col = c.get("non_stroking_color")
    grey = False
    if isinstance(col, (list, tuple)) and col:
        vals = [v for v in col if isinstance(v, (int, float))]
        if vals and 0.2 < sum(vals) / len(vals) < 0.95:
            grey = True
    return filled, stroked, grey, npts, round(w, 2), round(h, 2)

def main():
    with pdfplumber.open(PDF) as pdf:
        p = pdf.pages[PAGE]
        xt = sorted(l["x0"] for l in p.lines
                    if abs(l["x1"] - l["x0"]) < 0.5 and (l["bottom"] - l["top"]) < 8)
        yt = sorted({round(l["top"], 2) for l in p.lines
                     if abs(l["bottom"] - l["top"]) < 0.5 and (l["x1"] - l["x0"]) < 8
                     and 230 < l["x0"] < 240})
        assert len(xt) == len(X_TICKS), (len(xt), len(X_TICKS))
        assert len(yt) == len(Y_TICKS), (len(yt), len(Y_TICKS))
        ax, bx, rx = fit(xt, X_TICKS)
        ay, by, ry = fit(yt, Y_TICKS)
        print("axis calibration: max relative residual  x=%.4f%%  y=%.4f%%" % (rx * 100, ry * 100))

        plot_x = (min(xt) - 5, max(xt) + 5)
        plot_y = (min(yt) - 5, max(yt) + 5)
        rows = []
        for c in p.curves:
            w, h = c["x1"] - c["x0"], c["bottom"] - c["top"]
            # plot markers are 3.4-8 pt and near-square; smaller/elongated paths are
            # leader-line arrowheads, and larger ones the regression band / axis frame
            if not (3.3 < w < 9 and 3.3 < h < 9 and 0.8 < w / h < 1.25):
                continue
            cx, cy = (c["x0"] + c["x1"]) / 2, (c["top"] + c["bottom"]) / 2
            if not (plot_x[0] <= cx <= plot_x[1] and plot_y[0] <= cy <= plot_y[1]):
                continue
            filled, stroked, grey, npts, ww, hh = geometry(c)
            dup = next((r for r in rows if abs(r["_cx"] - cx) < 1.2 and abs(r["_cy"] - cy) < 1.2), None)
            if dup is not None:
                # each marker is drawn twice (fill path + outline path): merge them
                dup["filled"] = "TRUE" if (dup["filled"] == "TRUE" or filled) else "FALSE"
                dup["stroked"] = "TRUE" if (dup["stroked"] == "TRUE" or stroked) else "FALSE"
                if grey: dup["grey_fill"] = "TRUE"
                continue
            rows.append({
                "_cx": cx, "_cy": cy,
                "marker_id": "", "page_x": round(cx, 3), "page_y": round(cy, 3),
                "functional_interaural_distance_us": "%.6g" % (10 ** (ax * cx + bx)),
                "high_freq_hearing_limit_60dB_kHz": "%.6g" % (10 ** (ay * cy + by)),
                "filled": str(filled).upper(), "stroked": str(stroked).upper(),
                "grey_fill": str(grey).upper(), "n_path_points": npts,
                "width_pt": ww, "height_pt": hh,
            })
    rows.sort(key=lambda r: (float(r["functional_interaural_distance_us"]),
                             float(r["high_freq_hearing_limit_60dB_kHz"])))
    for i, r in enumerate(rows, 1):
        r["marker_id"] = "m%03d" % i
    for r in rows: r.pop("_cx", None); r.pop("_cy", None)
    with open(SNAP, "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=list(rows[0].keys()))
        w.writeheader(); w.writerows(rows)
    from collections import Counter
    print("markers extracted:", len(rows))
    print(Counter((r["filled"], r["stroked"], r["grey_fill"]) for r in rows))

if __name__ == "__main__":
    main()
