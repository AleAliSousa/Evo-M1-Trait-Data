"""Carlo_Stevens_2013_Figure2_extract_snapshot.py -- digitize Fig. 2 (A-C) -> constructed snapshot.

Source: Carlo & Stevens (2013) PNAS 110:1488-1493, Fig. 2 (PDF p. 2, page 1489), embedded
1-bit raster image (xref 83, 2043 x 4275 px, ~600 dpi). No values are typed in this script:
every coordinate is measured from the image at run time.

Method (AI assistant, 2026-10-28):
1. Axis calibration per panel from detected tick marks: y ticks 0/50/100/150/200 (thousands of
   cells under 1 mm2), x ticks 0/1/2/3 (cortical thickness, mm); linear least-squares fit.
2. Markers located by normalised cross-correlation with templates cut from each panel-A legend
   marker (circle = mouse, square = rat, triangle = cat, diamond = monkey); local maxima,
   threshold 0.45; legend areas and regression-line end artefacts excluded; duplicates < 0.02 mm
   & < 2 units merged.
3. Panels linked by abscissa: each point has the same cortical thickness in A, B and C
   (tolerance 0.012 mm, same species marker preferred).
4. Occlusions resolved, and flagged in `occluded_in`:
   - x ~ 1.12 mm: a mouse circle and a monkey diamond are concentric in all panels (visible as a
     diamond inside a circle); the hidden marker takes the coordinates of the visible one.
   - panel B, monkey at x ~ 1.75 and ~ 1.78 mm overlap the two regression lines: found by a
     local monkey-template search (threshold 0.35) in the window 1.6-1.9 mm, 80-115 thousand.
5. Check written to the snapshot: A - (B + C) per point (A = neurons + glia).
Run:  python Carlo_Stevens_2013_Figure2_extract_snapshot.py   (needs pymupdf, numpy, scipy)
Refuses to overwrite an existing, differing snapshot unless --force.
"""
import sys, os, csv, io, numpy as np, pymupdf
from scipy import ndimage as ndi
from scipy.signal import fftconvolve
HERE = os.path.dirname(os.path.abspath(__file__))
PDF = os.path.join(HERE, "Carlo-2013-Structural uniformit.pdf")
OUT = os.path.join(HERE, "Carlo_Stevens_2013_Figure2_snapshot.csv")
doc = pymupdf.open(PDF)
pix = pymupdf.Pixmap(doc, 83)
im = np.frombuffer(pix.samples, dtype=np.uint8).reshape(pix.height, pix.width, pix.n)[:, :, 0]
ink = (im > 128).astype(np.uint8)          # image is stored inverted (ink = 255)

def runs(idx):
    out = []
    for i in idx:
        if out and i == out[-1][1] + 1: out[-1][1] = i
        else: out.append([i, i])
    return [(a + b) / 2 for a, b in out]
def calib(y0, xax, yax):
    yt = runs(list(np.where(ink[y0:xax + 15, yax - 28:yax - 6].sum(1) >= 15)[0] + y0))
    xt = runs([x for x in np.where(ink[xax + 8:xax + 30, :].sum(0) >= 15)[0] if x >= yax - 10])
    assert len(yt) == 5 and len(xt) == 4, (yt, xt)
    return np.polyfit(xt, [0, 1, 2, 3], 1), np.polyfit(yt, [200, 150, 100, 50, 0], 1)
# axis rows/cols: longest ink row near each panel's x axis; y-axis column = densest column
def axis_row(lo, hi):
    rs = ink[lo:hi, 600:1900].sum(1); return lo + int(np.argmax(rs))
def axis_col(lo, hi):
    cs = ink[lo:hi, 400:650].sum(0); return 400 + int(np.argmax(cs))
P = {"A": (0, 1300, axis_row(1000, 1300), axis_col(100, 1100)),
     "B": (1300, 2800, axis_row(2550, 2700), axis_col(1600, 2600)),
     "C": (2800, 4275, axis_row(3950, 4100), axis_col(3000, 4000))}
CAL = {k: calib(v[0], v[2], v[3]) for k, v in P.items()}
def to_data(p, x, y):
    ax, ay = CAL[p]; return float(np.polyval(ax, x)), float(np.polyval(ay, y))
def to_px(p, X, Y):
    ax, ay = CAL[p]; return (X - ax[1]) / ax[0], (Y - ay[1]) / ay[0]
# templates from the panel-A legend (found as the 4 stacked ~44 px components right of x=1560)
lab, _ = ndi.label(ink[550:1000, 1560:1700])
legend = sorted([(sl[0].start + 550, sl[1].start + 1560) for sl in ndi.find_objects(lab)
                 if 38 < sl[0].stop - sl[0].start < 50 and 38 < sl[1].stop - sl[1].start < 50])
assert len(legend) == 4, legend
T = {sp: ink[y - 4:y + 49, x - 4:x + 49].astype(float) for sp, (y, x) in zip(["mouse", "rat", "cat", "monkey"], legend)}
def ncc(img, t):
    t = t - t.mean(); tn = np.sqrt((t ** 2).sum()); ones = np.ones_like(t)
    num = fftconvolve(img, t[::-1, ::-1], mode="same")
    s = fftconvolve(img, ones, mode="same"); s2 = fftconvolve(img ** 2, ones, mode="same")
    var = np.maximum(s2 - s ** 2 / t.size, 1e-6); return num / (tn * np.sqrt(var))
def detect(p, y0, y1, x0, x1, thr, drop, only=None):
    img = ink[y0:y1, x0:x1].astype(float)
    S = {k: ncc(img, t) for k, t in T.items() if only is None or k == only}
    st = np.stack(list(S.values())); best = st.max(0); arg = st.argmax(0)
    pk = np.argwhere((best == ndi.maximum_filter(best, size=25 if only is None else 9)) & (best > thr))
    out = []
    for yy, xx in pk:
        X, Y = to_data(p, xx + x0, yy + y0)
        if drop(X, Y): continue
        out.append(dict(sp=list(S)[arg[yy, xx]], X=X, Y=Y, score=float(best[yy, xx])))
    out.sort(key=lambda d: (d["X"], d["Y"])); ded = []
    for o in out:
        if ded and abs(o["X"] - ded[-1]["X"]) < 0.02 and abs(o["Y"] - ded[-1]["Y"]) < 2:
            if o["score"] > ded[-1]["score"]: ded[-1] = o
            continue
        ded.append(o)
    return ded
outside = lambda X, Y: X < 0.5 or X > 2.9
dA = detect("A", 100, P["A"][2] - 8, 540, 2043, 0.45, lambda X, Y: outside(X, Y) or (X > 2.1 and 30 < Y < 120))
dB = detect("B", 1560, P["B"][2] - 4, 530, 2043, 0.45, lambda X, Y: outside(X, Y) or (X < 1.1 and Y > 125))
dC = detect("C", 2980, P["C"][2] - 6, 550, 2043, 0.45, lambda X, Y: outside(X, Y) or (X < 1.2 and Y > 120))
# step 4b: local search for the two panel-B monkey markers hidden on the regression lines
x0, y0 = map(int, to_px("B", 1.6, 115)); x1, y1 = map(int, to_px("B", 1.9, 80))
extraB = detect("B", y0, y1, x0, x1, 0.35, lambda X, Y: False, only="monkey")
for e in extraB:
    if not any(abs(e["X"] - b["X"]) < 0.012 for b in dB): dB.append(dict(e, hidden_search=True))
def nearest(D, X, sp, tol=0.012):
    c = [d for d in D if abs(d["X"] - X) < tol and d["sp"] == sp] or [d for d in D if abs(d["X"] - X) < tol]
    return min(c, key=lambda d: abs(d["X"] - X)) if c else None
rows = []
anchors = list(dA)
# step 4a: concentric mouse+monkey at x~1.12: add the hidden partner of the visible marker
for d in dA:
    if d["sp"] == "monkey" and abs(d["X"] - 1.12) < 0.02:
        anchors.append(dict(d, sp="mouse", occluded=True))
for a in anchors:
    b = nearest(dB, a["X"], a["sp"]); c = nearest(dC, a["X"], a["sp"])
    occ = []
    if a.get("occluded"): occ.append("A")
    if b is None or b["sp"] != a["sp"]: occ.append("B")
    if c is None or c["sp"] != a["sp"]: occ.append("C")
    rows.append(dict(legend_marker=a["sp"], X=np.mean([v["X"] for v in (a, b, c) if v]),
                     A=a["Y"], B=b["Y"] if b else None, C=c["Y"] if c else None,
                     sA=a["score"], sB=b["score"] if b else None, sC=c["score"] if c else None,
                     occ=";".join(occ), hidden=bool(b and b.get("hidden_search"))))
rows.sort(key=lambda r: (r["X"], r["legend_marker"]))
assert len(rows) == 24, len(rows)
assert all(r["B"] is not None and r["C"] is not None for r in rows)
hdr = ["point_id", "legend_marker", "cortical thickness (mm)",
       "A: Number of cells under 1 mm2 (thousands of cells)",
       "B: Number of neurons under 1 mm2 (thousands of cells)",
       "C: Number of glia under 1 mm2 (thousands of cells)",
       "check A-(B+C) (thousands)", "ncc_A", "ncc_B", "ncc_C", "occluded_in", "note"]
buf = io.StringIO(); w = csv.writer(buf, lineterminator="\n"); w.writerow(hdr)
for i, r in enumerate(rows, 1):
    note = []
    if r["occ"]: note.append("marker occluded in panel(s) " + r["occ"] + ": coordinates of the concentric visible marker used")
    if r["hidden"]: note.append("panel B marker found by local monkey-template search (overlaps regression lines)")
    w.writerow([i, r["legend_marker"], f'{r["X"]:.3f}', f'{r["A"]:.1f}', f'{r["B"]:.1f}', f'{r["C"]:.1f}',
                f'{r["A"] - r["B"] - r["C"]:.1f}', f'{r["sA"]:.2f}', f'{r["sB"]:.2f}', f'{r["sC"]:.2f}',
                r["occ"], "; ".join(note)])
new = buf.getvalue()
if os.path.exists(OUT) and open(OUT, encoding="utf-8").read() != new and "--force" not in sys.argv:
    sys.exit("Existing snapshot differs from a fresh digitization; inspect, then rerun with --force.")
open(OUT, "w", encoding="utf-8").write(new)
print(f"wrote {OUT}: {len(rows)} points")
