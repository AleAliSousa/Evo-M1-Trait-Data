"""Koay_etal_1998_b_Figure9_extract_snapshot.py -- digitise Fig. 9 -> frozen snapshot.

Source: Koay, Kearns, Heffner & Heffner (1998) Hearing Research 119:37-48, Fig. 9
(PDF page index 9, journal p. 46), embedded image xref 36 (2949 x 2425 px). Scatter of
sound-localization threshold (deg, log y) against width of the field of best vision
(deg, log x) for the 23 species keyed in the caption, plus the paper's own big brown bat.
No coordinate is typed in this script: every value is measured at run time.

Method (AI assistant, 2026-10-31):
1. Axis frame = densest dark column / row. Calibration from the printed tick marks beside
   each axis, fitted by least squares against log10(value): x ticks 1-200 deg, y ticks
   1-50 deg (the 100 and 180 ticks sit above the detection window and are not needed).
2. MOST POINTS ARE NOT MARKERS. The figure plots 18 of the 24 points as the caption's key
   NUMBER set at the data position; only 6 carry a filled disc with a leader to the number.
   Discs are measured as the centroid of the ink at a distance-transform peak; numeral
   points are measured as the bounding-box centre of the one or two digit glyphs that make
   up the label. A numeral centre is a weaker estimate of a data position than a marker
   centre, and crowded numerals are nudged by the typesetter - see the snapshot's note
   column for the two affected labels.
3. Each label is seeded with the pixel of its own glyph or disc (SEEDS below: the
   label-to-position assignment is the human reading of the figure).
Run:  python Koay_etal_1998_b_Figure9_extract_snapshot.py   (needs pymupdf, numpy, scipy)
Refuses to overwrite an existing, differing snapshot unless --force.
"""
import sys, os, csv, io
import numpy as np, pymupdf
from scipy import ndimage

HERE = os.path.dirname(os.path.abspath(__file__))
PDF  = os.path.join(HERE, "Koay_etal_1998_b.pdf")
OUT  = os.path.join(HERE, "Koay_etal_1998_b_Figure9_snapshot.csv")
XREF = 36

## caption key label, seed x, seed y, how the point is drawn
SEEDS = [
    ("1", 1759, 1543, "numeral"), ("2", 1202, 1508, "numeral"),
    ("3", 410, 2028, "numeral"), ("4", 2656, 928, "numeral"),
    ("5", 2748, 780, "numeral"), ("6", 2521, 845, "numeral"),
    ("7", 2630, 774, "disc"), ("8*", 2786, 116, "numeral"),
    ("9", 2750, 990, "disc"), ("10", 2395, 983, "disc"),
    ("11", 2545, 995, "numeral"), ("12", 2860, 858, "numeral"),
    ("13", 2273, 1142, "numeral"), ("14", 2460, 987, "numeral"),
    ("15", 2608, 775, "disc"), ("16", 2719, 1023, "disc"),
    ("17*", 2679, 525, "numeral"), ("18", 1272, 1323, "numeral"),
    ("19", 1918, 1160, "numeral"), ("20", 1845, 1175, "numeral"),
    ("21", 1259, 1456, "numeral"), ("22", 1627, 1540, "numeral"),
    ("23", 2678, 814, "numeral"), ("Big Brown Bat", 2708, 1110, "disc"),
]
XV = [1, 3, 5, 10, 30, 50, 100, 200]
YV = [50, 30, 10, 5, 3, 1]

pm = pymupdf.Pixmap(pymupdf.open(PDF), XREF)
a  = np.frombuffer(pm.samples, dtype=np.uint8).reshape(pm.height, pm.width, pm.n)[:, :, 0]
d  = a < 128
YAX, XAX = int(np.argmax(d.sum(0))), int(np.argmax(d.sum(1)))

def grp(idx, gap=8):
    g, cur = [], [idx[0]]
    for v in idx[1:]:
        if v - cur[-1] <= gap: cur.append(v)
        else: g.append(float(np.mean(cur))); cur = [v]
    g.append(float(np.mean(cur))); return g

cols = np.where((a[XAX + 6:XAX + 26, :] < 128).mean(0) > 0.55)[0]
xt = grp(cols[cols > YAX - 20])
rws = np.where((a[:, YAX - 26:YAX - 6] < 128).mean(1) > 0.55)[0]
yt = grp(rws[rws < XAX + 20])
assert len(xt) == len(XV) and len(yt) == len(YV), (xt, yt)
BX, AX_ = np.polyfit(np.log10(XV), xt, 1)
BY, AY_ = np.polyfit(np.log10(YV), yt, 1)
assert np.abs(np.array(xt) - (AX_ + BX * np.log10(XV))).max() < 25
assert np.abs(np.array(yt) - (AY_ + BY * np.log10(YV))).max() < 25
to_x = lambda p: 10 ** ((p - AX_) / BX)
to_y = lambda p: 10 ** ((p - AY_) / BY)

def disc(sx, sy, r=22):
    """centroid of the ink at the distance-transform peak NEAREST the seed (touching
    discs share one blob, so the global peak would collapse both onto one centre)."""
    win = a[sy - 45:sy + 45, sx - 45:sx + 45] < 128
    dt = ndimage.distance_transform_edt(win)
    mx = ndimage.maximum_filter(dt, size=11)
    pk = np.argwhere((dt == mx) & (dt >= 14))
    assert len(pk), ("no disc near", sx, sy)
    py, px = min(pk, key=lambda q: (q[0] - 45) ** 2 + (q[1] - 45) ** 2)
    cy, cx = py + sy - 45, px + sx - 45
    yy, xx = np.mgrid[cy - r:cy + r + 1, cx - r:cx + r + 1]
    m = (a[cy - r:cy + r + 1, cx - r:cx + r + 1] < 128) & ((yy - cy) ** 2 + (xx - cx) ** 2 <= r * r)
    return float(xx[m].mean()), float(yy[m].mean())

def numeral(sx, sy, rad=55):
    """bounding-box centre of the one or two digit glyphs of the label. A glyph merged
    with neighbouring ink (label 23's '2' touches a disc) is accepted for the x span but
    excluded from the y centre, where its box is inflated."""
    lab, n = ndimage.label(a[sy - rad:sy + rad, sx - rad:sx + rad] < 128)
    glyphs = []
    for i, sl in enumerate(ndimage.find_objects(lab), 1):
        h, w = sl[0].stop - sl[0].start, sl[1].stop - sl[1].start
        if not (45 <= h <= 100 and 15 <= w <= 55): continue
        if int((lab[sl] == i).sum()) < 400: continue
        gx0, gx1 = sl[1].start + sx - rad, sl[1].stop + sx - rad
        gy0, gy1 = sl[0].start + sy - rad, sl[0].stop + sy - rad
        if abs((gx0 + gx1) / 2 - sx) > 45 or abs((gy0 + gy1) / 2 - sy) > 45: continue
        glyphs.append((h, gx0, gx1, gy0, gy1))
    assert glyphs, ("no digit glyph near", sx, sy)
    tidy = [g for g in glyphs if g[0] <= 75] or glyphs
    return (min(g[1] for g in glyphs) + max(g[2] for g in glyphs)) / 2, \
           (min(g[3] for g in tidy) + max(g[4] for g in tidy)) / 2

rows = []
for label, sx, sy, kind in SEEDS:
    x, y = disc(sx, sy) if kind == "disc" else numeral(sx, sy)
    rows.append(dict(label=label, kind=kind, x=x, y=y))
assert len(rows) == 24, len(rows)

NOTE = {
 "20": "the numerals 20 and 19 are printed abutting as \"2019\"; the typesetter has nudged them apart, so label 20's position is displaced. Its threshold (about 11.6 deg) disagrees with Fig. 8 of this same paper (7.9 deg) and with Heffner and Heffner (1992a) Table 1 (8.5 deg): treat label 20 as unresolved",
 "19": "the numerals 20 and 19 are printed abutting as \"2019\"; positions are approximate",
 "15": "two discs touch at this point (labels 15 and 7); each was measured separately but they are not independently resolved",
 "7":  "two discs touch at this point (labels 15 and 7); each was measured separately but they are not independently resolved",
 "9":  "two discs touch at this point (labels 9 and 16); each was measured separately but they are not independently resolved",
 "16": "two discs touch at this point (labels 9 and 16); each was measured separately but they are not independently resolved",
 "23": "the numeral 23 abuts the numeral 5; positions are approximate",
 "5":  "the numeral 5 abuts the numeral 23; positions are approximate",
 "14": "the numerals 14 and 11 are printed abutting as \"1411\"; positions are approximate",
 "11": "the numerals 14 and 11 are printed abutting as \"1411\"; positions are approximate",
}
hdr = ["caption_key_label", "point_drawn_as", "width_of_field_of_best_vision_deg_as_read",
       "sound_localization_threshold_deg_as_read", "x_px_native", "y_px_native", "note"]
buf = io.StringIO(); w = csv.writer(buf, lineterminator="\n"); w.writerow(hdr)
for r in rows:
    w.writerow([r["label"], r["kind"], "%.2f" % to_x(r["x"]), "%.2f" % to_y(r["y"]),
                "%.1f" % r["x"], "%.1f" % r["y"], NOTE.get(r["label"].rstrip("*"), "")])
new = buf.getvalue()
if os.path.exists(OUT) and open(OUT, encoding="utf-8").read() != new and "--force" not in sys.argv:
    sys.exit("Existing snapshot differs from a fresh digitisation; inspect, then rerun with --force.")
open(OUT, "w", encoding="utf-8").write(new)
print("wrote %s: %d points (%d discs, %d numerals)" % (OUT, len(rows),
      sum(r["kind"] == "disc" for r in rows), sum(r["kind"] != "disc" for r in rows)))
