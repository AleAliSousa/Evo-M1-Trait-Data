"""Koay_etal_2002_Figure3_extract_snapshot.py -- digitise Fig. 3 -> frozen snapshot.

Source: Koay, Bitter, Heffner & Heffner (2002) Hearing Research 171:96-102, Fig. 3
(PDF page index 5, journal p. 101), embedded image xref 83 (1975 x 1318 px). Two series
on one pair of axes: the behavioural audiogram of Phyllostomus hastatus (this paper's own
data, drawn as a THICK LINE WITH NO MARKERS) and multi-unit inferior-colliculus thresholds
replotted from Grinnell (1970) (thin line with filled markers). No coordinate is typed in
this script: every value is measured at run time.

Method (AI assistant, 2026-10-31):
1. Axis frame = densest dark column / row; calibration from the printed ticks, x against
   log10(kHz) (1-110 kHz) and y against dB SPL (0-90) by least squares. Residuals 2.8 px
   on x (0.004 decade) and 2.6 px on y (0.22 dB).
2. Behavioural audiogram: the thick line carries no markers, so its data points cannot be
   read directly. The curve is traced by continuity - at each column the dark run at least
   6 px thick whose centre is nearest the previous centre - and the plotted points are
   recovered as the vertices of that polyline (Douglas-Peucker, tolerance 3.5 px), with
   vertices closer than 0.025 decade in frequency merged. These vertices are INFERRED
   test frequencies, not printed ones: the snapshot marks them point_type =
   polyline_vertex_inferred.
3. Inferior-colliculus series: filled markers found as distance-transform peaks of radius
   at least 10 px (the line itself and the axis give radii of 5-6 px and are excluded).
4. Anchors: the paper's Results text gives a 60 dB SPL range of 1.8-105 kHz and best
   sensitivity 1 dB at 20 kHz; this digitisation reads 0.9 dB at 19.9 kHz and crosses
   60 dB at about 1.9 and 103 kHz.
Run:  python Koay_etal_2002_Figure3_extract_snapshot.py   (needs pymupdf, numpy, scipy)
Refuses to overwrite an existing, differing snapshot unless --force.
"""
import sys, os, csv, io
import numpy as np, pymupdf
from scipy import ndimage

HERE = os.path.dirname(os.path.abspath(__file__))
PDF  = os.path.join(HERE, "Koay_etal_2002.pdf")
OUT  = os.path.join(HERE, "Koay_etal_2002_Figure3_snapshot.csv")
XREF = 83
XV = [1, 2, 4, 8, 16, 32, 50, 64, 110]
YV = [90, 80, 70, 60, 50, 40, 30, 20, 10, 0]   # top to bottom: yt comes out in ascending pixel order

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

cols = np.where((a[XAX + 5:XAX + 22, :] < 128).mean(0) > 0.6)[0]
xt = grp(cols[cols > YAX - 10])
rws = np.where((a[:, YAX - 22:YAX - 5] < 128).mean(1) > 0.6)[0]
yt = grp(rws[rws < XAX + 10])
assert len(xt) == len(XV) and len(yt) == len(YV), (xt, yt)
BX, AX_ = np.polyfit(np.log10(XV), xt, 1)
BY, AY_ = np.polyfit(YV, yt, 1)
assert np.abs(np.array(xt) - (AX_ + BX * np.log10(XV))).max() < 5
assert np.abs(np.array(yt) - (AY_ + BY * np.array(YV))).max() < 5
to_khz = lambda p: 10 ** ((p - AX_) / BX)
to_db  = lambda p: (p - AY_) / BY

## ---- 2. behavioural audiogram: trace, then vertices -----------------------
def runs_at(x):
    col = a[40:XAX - 2, x] < 128
    out, cur = [], None
    for i, v in enumerate(col):
        if v and cur is None: cur = i
        elif not v and cur is not None: out.append((cur + 40, i - 1 + 40)); cur = None
    if cur is not None: out.append((cur + 40, len(col) - 1 + 40))
    return [r for r in out if r[1] - r[0] + 1 >= 6]

X0 = int(round(AX_ + BX * np.log10(1.1)))          # just right of the 1 kHz tick
prev = min((r[0] + r[1]) / 2 for r in runs_at(X0))  # the curve is the topmost thick run there
curve = {X0: prev}
for x in range(X0 + 1, int(xt[-1]) + 2):
    rr = runs_at(x)
    if not rr: continue
    c = [(r[0] + r[1]) / 2 for r in rr]
    j = int(np.argmin([abs(v - prev) for v in c]))
    if abs(c[j] - prev) <= 25: prev = c[j]; curve[x] = prev
back = curve[X0]
for x in range(X0 - 1, YAX, -1):
    rr = runs_at(x)
    if not rr: continue
    c = [(r[0] + r[1]) / 2 for r in rr]
    j = int(np.argmin([abs(v - back) for v in c]))
    if abs(c[j] - back) <= 25: curve[x] = c[j]; back = c[j]
xs = np.array(sorted(curve)); ys = np.array([curve[x] for x in xs])

def dp(i0, i1, tol, keep):
    if i1 <= i0 + 1: return
    x0, y0, x1, y1 = xs[i0], ys[i0], xs[i1], ys[i1]
    den = np.hypot(y1 - y0, x1 - x0)
    dd = np.abs((y1 - y0) * (xs[i0:i1 + 1] - x0) - (x1 - x0) * (ys[i0:i1 + 1] - y0)) / den
    i = int(np.argmax(dd))
    if dd[i] > tol:
        keep.add(i0 + i); dp(i0, i0 + i, tol, keep); dp(i0 + i, i1, tol, keep)

keep = {0, len(xs) - 1}; dp(0, len(xs) - 1, 3.5, keep)
verts = []
for i in sorted(keep):
    k = to_khz(xs[i])
    if verts and abs(np.log10(k) - np.log10(verts[-1][0])) < 0.025: continue
    verts.append((k, to_db(ys[i]), float(xs[i]), float(ys[i])))

## ---- 3. inferior-colliculus markers ---------------------------------------
reg = a[40:XAX - 3, YAX + 4:int(xt[-1]) + 45] < 128
dt = ndimage.distance_transform_edt(reg)
mx = ndimage.maximum_filter(dt, size=9)
pk = np.argwhere((dt == mx) & (dt >= 10))
cl = []
for y, x in pk:
    for c in cl:
        if abs(c[0] - y) < 12 and abs(c[1] - x) < 12: c[2].append((y, x)); break
    else: cl.append([y, x, [(y, x)]])
ic = sorted((np.mean([q[1] for q in c[2]]) + YAX + 4, np.mean([q[0] for q in c[2]]) + 40) for c in cl)
ic = [(x, y) for x, y in ic if not (int(round(x)) in curve and abs(curve[int(round(x))] - y) < 12)]

hdr = ["series_as_printed", "point_type", "frequency_kHz_as_read", "threshold_dB_SPL_as_read",
       "x_px_native", "y_px_native", "note"]
buf = io.StringIO(); w = csv.writer(buf, lineterminator="\n"); w.writerow(hdr)
for k, db, px, py in verts:
    w.writerow(["Behavioral Audiogram", "polyline_vertex_inferred", "%.2f" % k, "%.1f" % db,
                "%.1f" % px, "%.1f" % py,
                "the behavioural curve is drawn as a thick line with no markers: this point is a vertex of the traced polyline, not a printed symbol"])
for x, y in ic:
    w.writerow(["Inferior Colliculus Thresholds", "marker", "%.2f" % to_khz(x), "%.1f" % to_db(y),
                "%.1f" % x, "%.1f" % y, ""])
new = buf.getvalue()
if os.path.exists(OUT) and open(OUT, encoding="utf-8").read() != new and "--force" not in sys.argv:
    sys.exit("Existing snapshot differs from a fresh digitisation; inspect, then rerun with --force.")
open(OUT, "w", encoding="utf-8").write(new)
print("wrote %s: %d behavioural vertices, %d inferior-colliculus markers" % (OUT, len(verts), len(ic)))
