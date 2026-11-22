#!/usr/bin/env python3
"""DosSantos_etal_2020_Figure5_primate_cortex_points.py

Reads the eight primate cerebral-cortex points off Figure 5D and 5H of Dos Santos et al.
(2020), J Neurosci 40(24): 4622-4643, p. 4638 -- an input to the internal check
(DosSantos_etal_2020_Table1_internal_check.R, family E). Published figure only; no
other source is read.

What the panels plot (caption, p. 4638-4639): for every species and structure,
  D  microglial percentage of ALL cells            against neuronal density (N/mg)
  H  microglial percentage of NON-NEURONAL cells   against neuronal density (N/mg)
both on log-log axes (x 100 to 1,000,000; y 0.1 to 30). Primates are red; primates have
only a cerebral-cortex (Cx) row in Table 1, so the eight red markers are the eight
primate Cx rows.

Method
  1. extract the embedded raster of Figure 5 from the paper's PDF (page 17 of the file);
  2. find each panel's axis frame (the grey rectangle) -- its corners are the axis limits;
  3. find the red markers (colour threshold, compact blobs; the red legend text is
     rejected by shape) and take their centroids;
  4. convert pixel -> data on the log axes;
  5. name the markers by RANK of neuronal density: the i-th marker from the left is the
     primate with the i-th smallest Cx N/mg in the Table 1 snapshot. Where two adjacent
     markers are near-tied in x (within 3%; one pair, ranks 6-7) rank cannot separate
     them, and the pair is assigned by the nearer Table 1 y value instead. The x read
     here runs about 0.76-0.87 of Table 1's N/mg throughout (the figure plots the density
     "in the sample", Table 1 the previously published density), so x is used for ORDER
     only, never as a value.
The y calibration is then tested, not assumed: for the species whose Table 1 row is
self-consistent, the y read here must equal 100 I/C (D) or 100 I/(C-N) (H) from Table 1.
The R check does that comparison and reports it.

Run:  python DosSantos_etal_2020_Figure5_primate_cortex_points.py
Needs: pymupdf, numpy, scipy, pillow, pandas.
Writes (next to this script):
  DosSantos_etal_2020_Figure5_primate_cortex_points.csv
  DosSantos_etal_2020_Figure5_primate_cortex_points_overlay.png   (markers found, for the eye)
"""
import io
import sys
from pathlib import Path

import numpy as np
import pandas as pd
import pymupdf
from PIL import Image, ImageDraw
from scipy import ndimage as ndi

HERE = Path(__file__).resolve().parent
PAPER = HERE.parent
ITEM = "DosSantos_etal_2020_Figure5_primate_cortex_points"
PDF = PAPER / "Dos Santos-2020-Similar Microglial Cell Densit.pdf"
SNAPSHOT = PAPER / "DosSantos_etal_2020_Table1_snapshot.csv"
CLADES = HERE / "DosSantos_etal_2020_Table1_clades.csv"
PDF_PAGE_INDEX = 16                    # p. 4638
X_LIMITS = (100.0, 1_000_000.0)        # printed axis limits, both panels
Y_LIMITS = (0.1, 30.0)
# search windows (pixels of the 1750 x 2495 embedded raster) that contain one panel each
PANELS = {"D": (30, 880, 1830, 2460), "H": (930, 1750, 1830, 2460)}
MEASURE = {"D": "I_pct_all_cells", "H": "I_pct_other_cells"}


def fail(msg):
    sys.exit(f"{ITEM}: {msg}")


def figure_raster():
    doc = pymupdf.open(PDF)
    images = doc[PDF_PAGE_INDEX].get_images(full=True)
    if len(images) != 1:
        fail(f"expected one embedded image on PDF page {PDF_PAGE_INDEX + 1}, found {len(images)}")
    im = Image.open(io.BytesIO(doc.extract_image(images[0][0])["image"])).convert("RGB")
    if im.size != (1750, 2495):
        fail(f"embedded Figure 5 raster is {im.size}, expected (1750, 2495); re-check the panel windows")
    return im


def axis_frame(a, window):
    """Pixel position of the grey axis rectangle inside a search window: left, right, top, bottom."""
    x0, x1, y0, y1 = window
    s = a[y0:y1, x0:x1]
    grey = ((abs(s[:, :, 0] - s[:, :, 1]) < 12) & (abs(s[:, :, 1] - s[:, :, 2]) < 12)
            & (s[:, :, 0] > 140) & (s[:, :, 0] < 215))
    cols, rows = grey.sum(0), grey.sum(1)
    xs = np.where(cols > 0.6 * cols.max())[0]
    ys = np.where(rows > 0.6 * rows.max())[0]
    return x0 + xs.min(), x0 + xs.max(), y0 + ys.min(), y0 + ys.max()


def red_markers(a, frame):
    """Centroids of compact red blobs inside the frame (data markers, not legend letters)."""
    left, right, top, bottom = frame
    s = a[top + 3:bottom - 3, left + 3:right - 3]
    red = (s[:, :, 0] > 170) & (s[:, :, 1] < 90) & (s[:, :, 2] < 110) & (s[:, :, 0] - s[:, :, 2] > 90)
    lab, n = ndi.label(red)
    out = []
    for k in range(1, n + 1):
        ys, xs = np.where(lab == k)
        w, h = np.ptp(xs) + 1, np.ptp(ys) + 1
        if 50 <= len(ys) <= 100 and abs(w - h) <= 2 and len(ys) / (w * h) > 0.6:
            out.append((left + 3 + xs.mean(), top + 3 + ys.mean(), len(ys)))
    return sorted(out)


def to_data(frame, px, py):
    left, right, top, bottom = frame
    lx0, lx1 = np.log10(X_LIMITS)
    ly0, ly1 = np.log10(Y_LIMITS)
    x = 10 ** (lx0 + (px - left) / (right - left) * (lx1 - lx0))
    y = 10 ** (ly1 - (py - top) / (bottom - top) * (ly1 - ly0))
    return x, y


def main():
    snap = pd.read_csv(SNAPSHOT, dtype=str)
    clades = pd.read_csv(CLADES)
    primates = set(clades.loc[clades.clade_table5 == "Primata", "species_table1"])
    cx = snap[snap["Species name"].isin(primates) & (snap["Structure"].str.replace("*", "", regex=False) == "Cx")].copy()
    cx["N_per_mg"] = pd.to_numeric(cx["N/mg"].str.replace(" ", "", regex=False))
    num = lambda col: pd.to_numeric(cx[col].str.replace(" ", "", regex=False))
    cx["I_pct_all_cells"] = 100 * num("I") / num("C")
    cx["I_pct_other_cells"] = 100 * num("I") / (num("C") - num("N"))
    cx = cx.sort_values("N_per_mg").reset_index(drop=True)
    if len(cx) != 8:
        fail(f"expected 8 primate Cx rows in the Table 1 snapshot, found {len(cx)}")

    im = figure_raster()
    a = np.asarray(im).astype(int)
    overlay = im.copy()
    draw = ImageDraw.Draw(overlay)
    rows = []
    for panel, window in PANELS.items():
        frame = axis_frame(a, window)
        pts = red_markers(a, frame)
        if len(pts) != 8:
            fail(f"panel {panel}: expected 8 red markers, found {len(pts)}; re-check the thresholds")
        draw.rectangle([frame[0], frame[2], frame[1], frame[3]], outline=(0, 160, 0))
        order = list(range(8))                 # order[k] = Table 1 density rank of marker k
        basis = ["density rank"] * 8
        for k in range(7):
            (xa, ya), (xb, yb) = to_data(frame, *pts[k][:2]), to_data(frame, *pts[k + 1][:2])
            if xb / xa < 1.03:                 # near-tie in x: decide the pair by y
                ta, tb = cx[MEASURE[panel]][order[k]], cx[MEASURE[panel]][order[k + 1]]
                keep = abs(np.log(ya / ta)) + abs(np.log(yb / tb))
                swap = abs(np.log(ya / tb)) + abs(np.log(yb / ta))
                if swap < keep:
                    order[k], order[k + 1] = order[k + 1], order[k]
                basis[k] = basis[k + 1] = "near-tie in x, assigned by nearer Table 1 y"
        for k, (px, py, size) in enumerate(pts):
            x, y = to_data(frame, px, py)
            rank = order[k]
            sp = cx["Species name"][rank]
            draw.ellipse([px - 9, py - 9, px + 9, py + 9], outline=(0, 0, 0), width=2)
            draw.text((px + 11, py - 6), f"{rank + 1}", fill=(0, 0, 0))
            rows.append(dict(panel=panel, measure=MEASURE[panel], density_rank=rank + 1,
                             species_table1=sp, table1_N_per_mg=cx["N_per_mg"][rank],
                             x_pixel=round(px, 1), y_pixel=round(py, 1), marker_pixels=size,
                             x_read_N_per_mg=round(x), y_read_pct=round(y, 3),
                             assigned_by=basis[k],
                             locator="Figure 5%s, p. 4638" % panel))
    out = pd.DataFrame(rows)
    out.to_csv(HERE / f"{ITEM}.csv", index=False)
    crop = overlay.crop((0, 1800, 1750, 2495))
    crop.save(HERE / f"{ITEM}_overlay.png")
    print(out[["panel", "species_table1", "table1_N_per_mg", "x_read_N_per_mg", "y_read_pct", "assigned_by"]].to_string(index=False))


if __name__ == "__main__":
    main()
