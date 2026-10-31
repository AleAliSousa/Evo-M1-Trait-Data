"""Wenstrup__1984_Figure8_extract_snapshot.py -- digitise Fig. 8 -> frozen snapshot.

Source: Wenstrup, J.J. (1984) J Comp Physiol A 155:91-101, Fig. 8 (PDF page index 9,
journal p. 99), embedded page scan xref 269 (2490 x 3270 px, 300 dpi). Three stacked
panels sharing one logarithmic frequency axis: behavioural audiograms of Rhinolophus
ferrumequinum, Eptesicus fuscus and Noctilio leporinus. No coordinate is typed in this
script: every value is measured from the scan at run time.

Method (AI assistant, 2026-10-31):
1. The page is a slightly skewed scan. The left panel frame is fitted as x = f(y) over the
   rows where the only ink near x = 338 is the frame itself, and the bottom frame as
   y = g(x); both are used so that ticks are looked for relative to the true frame.
2. Calibration. The frequency axis is shared: ticks protrude INWARD from the bottom frame
   and are fitted against log10(kHz) over 1-100 kHz (max residual 3.1 px = 0.011 decade,
   about 2.6%). Intensity: each panel carries its own five inward ticks at 0, 20, 40, 60
   and 80 dB SPL; the three panels give 2.84, 2.78 and 2.81 px/dB, and each panel is
   calibrated on its own 0 and 80 dB ticks (about 0.4 dB per pixel).
3. THE CURVES CARRY SMALL FILLED DOTS, but most are no thicker than the line that joins
   them. The plotted points are therefore recovered as the vertices of each traced
   polyline (trace by continuity, then Douglas-Peucker at 2.6 px, vertices within 0.02
   decade merged) and marked point_type = polyline_vertex_inferred. A distance-transform
   dot detector is run as a check and the snapshot records, per point, whether a distinct
   printed dot was found at the vertex (dot_confirmed).
4. The Eptesicus panel carries a SECOND, dashed series drawn with open circles. These are
   found with a ring template (bright core, dark ring, 80th-percentile ring test so that
   the gap where the dashed line enters does not reject the ring) at radii 5-7 px, and the
   species-label text block at the foot of the panel is excluded. The leftmost circle sits
   on the y-axis and is bisected by it; it is measured and flagged.
5. The horizontal bars at the top of each panel mark the echolocation band, not data, and
   are removed before tracing.
Run:  python Wenstrup__1984_Figure8_extract_snapshot.py   (needs pymupdf, numpy, scipy)
Refuses to overwrite an existing, differing snapshot unless --force.
"""
import sys, os, csv, io
import numpy as np, pymupdf
from scipy import ndimage

HERE = os.path.dirname(os.path.abspath(__file__))
PDF  = os.path.join(HERE, "Wenstrup__1984.pdf")
OUT  = os.path.join(HERE, "Wenstrup__1984_Figure8_snapshot.csv")
XREF = 269
FRAME_R = 1089
XVAL = [1, 2, 5, 10, 20, 30, 40, 60, 80, 100, 150]   # labelled 1-100; 30/80/150 are unlabelled minor ticks
PANELS = [("Rhinolophus ferrumequinum", 285, 612, 3.0, None),
          ("Eptesicus fuscus",          636, 925, 6.0, 2.2),
          ("Noctilio leporinus",        977, 1290, 2.0, 0.95)]

a = np.frombuffer(pymupdf.Pixmap(pymupdf.open(PDF), XREF).samples,
                  dtype=np.uint8).reshape(3270, 2490, 1)[:, :, 0]

## ---- 1. frames ------------------------------------------------------------
ys, xs_ = [], []
for y in range(285, 1290):
    seg = np.where(a[y, 330:355] < 128)[0]
    if len(seg) >= 2 and seg.max() - seg.min() <= 6: ys.append(y); xs_.append(seg.mean() + 330)
bL, aL = np.polyfit(ys, xs_, 1); fxl = lambda y: aL + bL * y
cx_, cy_ = [], []
for x in range(350, 1085, 5):
    seg = np.where(a[1285:1302, x] < 128)[0]
    if len(seg) >= 2 and seg.max() - seg.min() <= 6: cx_.append(x); cy_.append(seg.mean() + 1285)
bB, aB = np.polyfit(cx_, cy_, 1); fyb = lambda x: aB + bB * x

def group1(idx, gap=4):
    g, cur = [], [idx[0]]
    for v in idx[1:]:
        if v - cur[-1] <= gap: cur.append(v)
        else: g.append(float(np.mean(cur))); cur = [v]
    g.append(float(np.mean(cur))); return g

## ---- 2. calibration -------------------------------------------------------
xc = [x for x in range(345, 1090)
      if (a[int(round(fyb(x))) - 13:int(round(fyb(x))) - 2, x] < 145).mean() > 0.6]
XPIX = group1(xc)
assert len(XPIX) == len(XVAL), (len(XPIX), XPIX)
BX, AX_ = np.polyfit(np.log10(XVAL), XPIX, 1)
assert np.abs(np.array(XPIX) - (AX_ + BX * np.log10(XVAL))).max() < 5
to_khz = lambda p: 10 ** ((p - AX_) / BX)

yt = group1([y for y in range(285, 1290)
             if (a[y, int(round(fxl(y))) + 2:int(round(fxl(y))) + 12] < 145).mean() > 0.6])
PCAL = {}
for name, y0, y1, seed, xlo in PANELS:
    t = sorted(v for v in yt if y0 <= v <= y1)
    ## keep the regularly spaced chain of five (80, 60, 40, 20, 0 dB); a panel edge or a
    ## stray mark can add a sixth candidate, which breaks the 50-62 px spacing
    best = []
    for i in range(len(t)):
        chain = [t[i]]
        for j in range(i + 1, len(t)):
            if 50 <= t[j] - chain[-1] <= 62: chain.append(t[j])
        if len(chain) > len(best): best = chain
    assert len(best) == 5, (name, t, best)
    PCAL[name] = (best[0], best[-1])                   # 80 dB tick, 0 dB tick

## ---- 3. trace each panel's solid curve, take its vertices -----------------
def panel(name, y0, y1, seed, xlo):
    p80, p0 = PCAL[name]; scale = (p0 - p80) / 80.0
    to_db = lambda py: (p0 - py) / scale
    reg = (a[y0:y1, 342:FRAME_R - 6] < 128).copy()
    lab, n = ndimage.label(reg)
    for i, sl in enumerate(ndimage.find_objects(lab), 1):
        h, w = sl[0].stop - sl[0].start, sl[1].stop - sl[1].start
        if w > 25 and h <= 16 and w / h > 3 and to_db(sl[0].start + y0) > 86:
            reg[sl][lab[sl] == i] = False              # echolocation-band bar
    def runs(x):
        col = reg[:, x - 342]; out, cur = [], None
        for i, v in enumerate(col):
            if v and cur is None: cur = i
            elif not v and cur is not None: out.append((cur, i - 1)); cur = None
        if cur is not None: out.append((cur, len(col) - 1))
        return [r for r in out if r[1] - r[0] + 1 <= 40]
    x0 = int(round(AX_ + BX * np.log10(seed)))
    lo = int(round(AX_ + BX * np.log10(xlo))) if xlo else 349
    rr = runs(x0); assert rr, (name, "no ink at seed")
    tr = {x0: (rr[0][0] + rr[0][1]) / 2}
    for rng in (range(x0 + 1, FRAME_R - 7), range(x0 - 1, lo, -1)):
        prev = tr[x0]
        for x in rng:
            rr = runs(x)
            if not rr: continue
            c = [(r[0] + r[1]) / 2 for r in rr]
            j = int(np.argmin([abs(v - prev) for v in c]))
            if abs(c[j] - prev) <= 28: prev = c[j]; tr[x] = prev
    xs = np.array(sorted(tr)); ys = np.array([tr[x] for x in xs]) + y0
    keep = {0, len(xs) - 1}
    def dp(i0, i1):
        if i1 <= i0 + 1: return
        x0_, y0_, x1_, y1_ = xs[i0], ys[i0], xs[i1], ys[i1]
        den = np.hypot(y1_ - y0_, x1_ - x0_)
        dd = np.abs((y1_ - y0_) * (xs[i0:i1 + 1] - x0_) - (x1_ - x0_) * (ys[i0:i1 + 1] - y0_)) / den
        i = int(np.argmax(dd))
        if dd[i] > 2.6: keep.add(i0 + i); dp(i0, i0 + i); dp(i0 + i, i1)
    dp(0, len(xs) - 1)
    V = []
    for i in sorted(keep):
        k = to_khz(xs[i])
        if xs[i] >= FRAME_R - 12: continue
        if V and abs(np.log10(k) - np.log10(V[-1][0])) < 0.02: continue
        V.append((k, to_db(ys[i]), float(xs[i]), float(ys[i])))
    dt = ndimage.distance_transform_edt(reg)
    mx = ndimage.maximum_filter(dt, size=5)
    pk = np.argwhere((dt == mx) & (dt >= 3.4))
    cl = []
    for yy, xx in pk:
        for c in cl:
            if abs(c[0] - yy) < 6 and abs(c[1] - xx) < 6: c[2].append((yy, xx)); break
        else: cl.append([yy, xx, [(yy, xx)]])
    dots = [(np.mean([q[1] for q in c[2]]) + 342, np.mean([q[0] for q in c[2]]) + y0) for c in cl]
    conf = [any((x - dx) ** 2 + (y - dy) ** 2 <= 64 for dx, dy in dots) for k, db, x, y in V]
    return V, conf, to_db

## ---- 4. the Eptesicus open-circle series ---------------------------------
def open_circles(y0, y1, to_db):
    ang = np.linspace(0, 2 * np.pi, 24, endpoint=False)
    cands = []
    for r in (5, 5.5, 6, 6.5, 7):
        for cy in range(y0 + 5, y1 - 5):
            for cx in range(336, 660):
                core = a[cy - 2:cy + 3, cx - 2:cx + 3].mean()
                if core < 200: continue
                rg = np.array([a[int(round(cy + r * np.sin(t))), int(round(cx + r * np.cos(t)))]
                               for t in ang], dtype=float)
                if np.percentile(rg, 80) > 150 or rg.mean() > 90: continue
                cands.append((core - rg.mean(), cx, cy))
    cands.sort(reverse=True); K = []
    for s, cx, cy in cands:
        if all((cx - k[1]) ** 2 + (cy - k[2]) ** 2 > 169 for k in K): K.append((s, cx, cy))
    ## the species label sits at the foot of the panel below 12 dB; no data there
    K = [k for k in K if not (to_db(k[2]) < 12 and to_khz(k[1]) < 6)]
    K.sort(key=lambda k: k[1])
    return K

rows = []
for name, y0, y1, seed, xlo in PANELS:
    V, conf, to_db = panel(name, y0, y1, seed, xlo)
    for (k, db, x, y), c in zip(V, conf):
        rows.append([name, "solid line with filled dots", "polyline_vertex_inferred",
                     "%.2f" % k, "%.1f" % db, "%.1f" % x, "%.1f" % y, str(c).upper(),
                     "point recovered as a vertex of the traced polyline" +
                     ("; a distinct printed dot was found at it" if c else
                      "; no separately resolvable dot at this vertex (dot and line merge at this resolution)")])
    if name == "Eptesicus fuscus":
        for s, cx, cy in open_circles(y0, y1, to_db):
            onaxis = cx <= int(round(fxl(cy))) + 3
            rows.append([name, "dashed line with open circles", "marker",
                         "%.2f" % to_khz(cx), "%.1f" % to_db(cy), "%.1f" % cx, "%.1f" % cy, "TRUE",
                         "open circle of the second, dashed series" +
                         ("; bisected by the y axis, centre measured on the frame" if onaxis else "")])
assert len(rows) == 64, len(rows)
hdr = ["panel_label_as_printed", "series_as_printed", "point_type", "frequency_kHz_as_read",
       "intensity_dB_SPL_as_read", "x_px_native", "y_px_native", "dot_confirmed", "note"]
buf = io.StringIO(); w = csv.writer(buf, lineterminator="\n"); w.writerow(hdr)
for r in rows: w.writerow(r)
new = buf.getvalue()
if os.path.exists(OUT) and open(OUT, encoding="utf-8").read() != new and "--force" not in sys.argv:
    sys.exit("Existing snapshot differs from a fresh digitisation; inspect, then rerun with --force.")
open(OUT, "w", encoding="utf-8").write(new)
print("wrote %s: %d points" % (OUT, len(rows)))
