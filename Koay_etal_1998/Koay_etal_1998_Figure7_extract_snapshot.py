"""Koay_etal_1998_Figure7_extract_snapshot.py -- digitise Figure 7 -> frozen snapshot.

Source: Koay, Heffner & Heffner (1998) J Comp Psychol 112:371-382, Figure 7 (PDF page
index 10, journal p. 380). Scatter of low-frequency hearing limit (kHz, log y) against
high-frequency hearing limit (kHz, log x) for the 58 species keyed in the Figure 6
caption. No coordinate is typed in this script: every value is measured from a 300 dpi
render of the page at run time.

Method (AI assistant, 2026-10-31):
1. Axis frame located as the longest dark column / row (y axis x=499, x axis y=1370 px).
2. Calibration from the printed tick marks only: tick rows/columns detected by their ink
   runs beside each axis, labelled with the printed decade and minor-tick values, then a
   least-squares fit of pixel against log10(value). Residuals are asserted < 5 px
   (<= 0.005 decade on x, <= 0.016 decade on y).
3. Each printed point label is seeded with the pixel of the marker it labels (SEEDS below:
   the label->marker assignment is the human reading of the figure; the coordinate itself
   is re-measured here). Measurement per marker type:
     disc_centroid        - filled circle/triangle: peak of the distance transform of the
                            ink, then centroid of the ink within radius 9 px.
     ring_template        - open circle (the five bats): the position in a 25 px window
                            maximising (mean brightness of the 7x7 core) - (mean brightness
                            on a radius-7.5 ring); requires a bright core and a dark ring.
     triangle_bbox_centre - open triangle (marine species): bounding-box centre of the
                            connected component.
     shared_merged_blob   - the marker is merged with a neighbour's and cannot be separated
                            at this resolution; both labels take the merged blob's centre
                            and are flagged in the snapshot.
4. Marker types were read from the page image, not inherited from Figure 6: point 51
   (sea lion in air) prints as a FILLED CIRCLE in Figure 6 but as an OPEN TRIANGLE in
   Figure 7, where the caption groups it with the marine mammals excluded from the
   regressions.
Run:  python Koay_etal_1998_Figure7_extract_snapshot.py   (needs pymupdf, numpy, scipy)
Refuses to overwrite an existing, differing snapshot unless --force.
"""
import sys, os, csv, io
import numpy as np, pymupdf
from scipy import ndimage

HERE = os.path.dirname(os.path.abspath(__file__))
PDF  = os.path.join(HERE, "koay_etal_1998.pdf")
OUT  = os.path.join(HERE, "Koay_etal_1998_Figure7_snapshot.csv")
PAGE, DPI = 10, 300

## printed label, seed pixel (x, y), printed marker, measurement method
SEEDS = [
    ("Ef", 1977, 543, "open_circle_bat", "ring_template"), ("Ml", 2022, 401, "open_circle_bat", "ring_template"),
    ("Nl", 2003, 445, "open_circle_bat", "ring_template"), ("Ra", 1738, 612, "open_circle_bat", "ring_template"),
    ("Rf", 1970, 521, "open_circle_bat", "ring_template"), ("1", 1767, 719, "filled_circle", "disc_centroid"),
    ("2", 1833, 547, "filled_circle", "disc_centroid"), ("3", 1822, 565, "filled_circle", "disc_centroid"),
    ("4", 1701, 814, "filled_circle", "disc_centroid"), ("5", 1716, 987, "filled_circle", "disc_centroid"),
    ("6", 1549, 1091, "filled_circle", "disc_centroid"), ("7", 1560, 1072, "filled_circle", "disc_centroid"),
    ("8", 1538, 1014, "filled_circle", "shared_merged_blob"), ("9", 1747, 1058, "filled_circle", "disc_centroid"),
    ("11", 1548, 1046, "filled_circle", "disc_centroid"), ("14", 1522, 1160, "filled_circle", "disc_centroid"),
    ("15", 1447, 1228, "filled_circle", "disc_centroid"), ("17", 1604, 1154, "filled_circle", "disc_centroid"),
    ("19", 1522, 1160, "filled_circle", "shared_merged_blob"), ("21", 1126, 1210, "filled_circle", "disc_centroid"),
    ("22", 1611, 1050, "filled_circle", "disc_centroid"), ("23", 1675, 891, "filled_circle", "disc_centroid"),
    ("24", 1641, 1176, "filled_circle", "disc_centroid"), ("25", 1338, 1172, "filled_circle", "disc_centroid"),
    ("26", 1312, 1221, "filled_circle", "disc_centroid"), ("27", 1312, 1162, "filled_circle", "disc_centroid"),
    ("28", 1610, 1028, "filled_circle", "disc_centroid"), ("29", 789, 908, "filled_triangle_subterranean", "disc_centroid"),
    ("30", 923, 1107, "filled_triangle_subterranean", "disc_centroid"), ("31", 604, 1134, "filled_triangle_subterranean", "disc_centroid"),
    ("32", 1641, 1169, "filled_circle", "disc_centroid"), ("33", 1767, 638, "filled_circle", "disc_centroid"),
    ("34", 1796, 726, "filled_circle", "disc_centroid"), ("35", 1675, 733, "filled_circle", "disc_centroid"),
    ("36", 1804, 664, "filled_circle", "disc_centroid"), ("37", 1696, 1188, "filled_circle", "disc_centroid"),
    ("38", 1789, 608, "filled_circle", "disc_centroid"), ("39", 1796, 814, "filled_circle", "disc_centroid"),
    ("40", 1775, 810, "filled_circle", "disc_centroid"), ("41", 1914, 609, "filled_circle", "disc_centroid"),
    ("42", 1841, 741, "filled_circle", "disc_centroid"), ("43", 1589, 1050, "filled_circle", "disc_centroid"),
    ("44", 1608, 1152, "filled_circle", "disc_centroid"), ("45", 1425, 1143, "filled_circle", "disc_centroid"),
    ("46", 1560, 1102, "filled_circle", "disc_centroid"), ("47", 1842, 1128, "filled_circle", "disc_centroid"),
    ("48", 1710, 1143, "filled_circle", "disc_centroid"), ("49", 1538, 1188, "filled_circle", "disc_centroid"),
    ("51", 1416, 807, "open_triangle_marine", "bbox_centre"), ("52", 878, 1296, "filled_circle", "disc_centroid"),
    ("53", 1432, 1127, "filled_circle", "disc_centroid"), ("54", 1522, 1160, "filled_circle", "shared_merged_blob"),
    ("55", 1450, 1250, "filled_circle", "disc_centroid"), ("56", 1480, 1080, "filled_circle", "disc_centroid"),
    ("57", 1538, 1014, "filled_circle", "disc_centroid"), ("59", 2126, 998, "open_triangle_marine", "bbox_centre"),
    ("60", 1437, 760, "open_triangle_marine", "bbox_centre"), ("61", 2060, 1008, "open_triangle_marine", "bbox_centre"),
]

im = pymupdf.open(PDF)[PAGE].get_pixmap(dpi=DPI)
a  = np.frombuffer(im.samples, dtype=np.uint8).reshape(im.height, im.width, im.n)[:, :, 0]

## ---- 1. axis frame -------------------------------------------------------
dark = a[300:1900, 200:2300] < 128
YAX = 200 + int(np.argmax(dark.sum(0)))
XAX = 300 + int(np.argmax(dark.sum(1)))

## ---- 2. calibration from printed ticks -----------------------------------
def groups(idx, gap=5):
    out, cur = [], [idx[0]]
    for v in idx[1:]:
        if v - cur[-1] <= gap: cur.append(v)
        else: out.append(float(np.mean(cur))); cur = [v]
    out.append(float(np.mean(cur)))
    return out

xticks = groups(np.where((a[XAX + 4:XAX + 22, :] < 128).sum(0) >= 12)[0])
yrows  = np.where((a[:, YAX - 20:YAX - 3] < 128).sum(1) >= 12)[0]
yticks = groups(yrows[(yrows > 300) & (yrows < XAX)])
XV = [5, 6, 7, 8, 9, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 120, 150]
YV = ([10] + [9, 8, 7, 6, 5, 4, 3, 2] + [1] + [.9, .8, .7, .6, .5, .4, .3, .2]
      + [.1] + [.09, .08, .07, .06, .05, .04, .03, .02] + [.01])
assert len(xticks) == len(XV), (len(xticks), xticks)
yticks = [t for t in yticks if t >= 400]
assert len(yticks) == len(YV), (len(yticks), yticks)
BX, AX_ = np.polyfit(np.log10(XV), xticks, 1)
BY, AY_ = np.polyfit(np.log10(YV), yticks, 1)
assert np.abs(np.array(xticks) - (AX_ + BX * np.log10(XV))).max() < 5
assert np.abs(np.array(yticks) - (AY_ + BY * np.log10(YV))).max() < 5
to_x = lambda p: 10 ** ((p - AX_) / BX)
to_y = lambda p: 10 ** ((p - AY_) / BY)

## ---- 3. measure each marker ----------------------------------------------
def disc(sx, sy, r=9):
    win = a[sy - 14:sy + 15, sx - 14:sx + 15] < 120
    dt  = ndimage.distance_transform_edt(win)
    py, pxl = np.unravel_index(np.argmax(dt), dt.shape)
    cy, cx = py + sy - 14, pxl + sx - 14
    yy, xx = np.mgrid[cy - r:cy + r + 1, cx - r:cx + r + 1]
    m = (a[cy - r:cy + r + 1, cx - r:cx + r + 1] < 120) & ((yy - cy) ** 2 + (xx - cx) ** 2 <= r * r)
    return float(xx[m].mean()), float(yy[m].mean())

def ring(sx, sy, rad=12, r=7.5):
    ang = np.linspace(0, 2 * np.pi, 24, endpoint=False)
    best = None
    for cy in range(sy - rad, sy + rad + 1):
        for cx in range(sx - rad, sx + rad + 1):
            core = a[cy - 3:cy + 4, cx - 3:cx + 4].mean()
            if core < 200: continue
            rg = np.array([a[int(round(cy + r * np.sin(t))), int(round(cx + r * np.cos(t)))] for t in ang])
            if rg.max() > 140: continue
            sc = core - rg.mean()
            if best is None or sc > best[0]: best = (sc, float(cx), float(cy))
    assert best is not None, ("no ring near", sx, sy)
    return best[1], best[2]

def bbox(sx, sy, rad=20):
    lab, n = ndimage.label(a[sy - rad:sy + rad, sx - rad:sx + rad] < 130)
    best = None
    for i in range(1, n + 1):
        ys, xs = np.where(lab == i)
        h, w = np.ptp(ys) + 1, np.ptp(xs) + 1
        if not (14 <= h <= 30 and 14 <= w <= 30): continue
        bx = (xs.min() + xs.max()) / 2 + sx - rad
        by = (ys.min() + ys.max()) / 2 + sy - rad
        d = (bx - sx) ** 2 + (by - sy) ** 2
        if best is None or d < best[0]: best = (d, float(bx), float(by))
    assert best is not None, ("no open-triangle component near", sx, sy)
    return best[1], best[2]

rows = []
for fid, sx, sy, marker, method in SEEDS:
    if method == "ring_template":        x, y = ring(sx, sy)
    elif method == "bbox_centre":         x, y = bbox(sx, sy)
    else:                                 x, y = disc(sx, sy)
    rows.append(dict(figure_id=fid, marker=marker, method=method, x=x, y=y))

## shared merged blobs: both labels take the same measured centre
merged = {}
for r in rows: merged.setdefault((round(r["x"]), round(r["y"])), []).append(r["figure_id"])
for r in rows:
    partners = [f for f in merged[(round(r["x"]), round(r["y"]))] if f != r["figure_id"]]
    r["shared_with"] = ";".join(partners)

assert len(rows) == 58, len(rows)
hdr = ["figure_id", "marker_as_printed", "high_frequency_hearing_limit_kHz_as_read",
       "low_frequency_hearing_limit_kHz_as_read", "x_px_300dpi", "y_px_300dpi",
       "read_method", "shared_marker_with", "note"]
buf = io.StringIO(); w = csv.writer(buf, lineterminator="\n"); w.writerow(hdr)
for r in rows:
    note = ""
    if r["shared_with"]:
        note = ("marker merged with the marker(s) of point(s) " + r["shared_with"] +
                " at this resolution; the shared blob centre is reported for both")
    w.writerow([r["figure_id"], r["marker"], f'{to_x(r["x"]):.2f}', f'{to_y(r["y"]):.4f}',
                f'{r["x"]:.1f}', f'{r["y"]:.1f}', r["method"], r["shared_with"], note])
new = buf.getvalue()
if os.path.exists(OUT) and open(OUT, encoding="utf-8").read() != new and "--force" not in sys.argv:
    sys.exit("Existing snapshot differs from a fresh digitisation; inspect, then rerun with --force.")
open(OUT, "w", encoding="utf-8").write(new)
print(f"wrote {OUT}: {len(rows)} points; x residual <5px, y residual <5px")
