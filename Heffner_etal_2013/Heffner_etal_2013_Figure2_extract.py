"""Heffner_etal_2013_Figure2_extract.py -- vector extraction of Fig. 2 (p. 45, PDF page 4).

The figure is born-digital vector art. This script reads the PDF drawing commands with
PyMuPDF (no rasterising): the two polylines (pure-tone mean audiogram, black 0.97 pt; the
Groger & Wiegrebe 2006 noiseband thresholds, grey 1.16 pt) and the axis tick segments,
fits log10(kHz) and dB-SPL calibrations by least squares to the major ticks, and writes the
frozen constructed snapshot Heffner_etal_2013_Figure2_snapshot.csv (rows in legend order,
then x order) plus a check image. Run: python Heffner_etal_2013_Figure2_extract.py
Written 2026-10-30 by an AI assistant (Claude) for A. de Sousa.
"""
import csv, os, numpy as np, pymupdf
here = os.path.dirname(os.path.abspath(__file__))
doc = pymupdf.open(os.path.join(here, "Heffner_etal_2013.pdf")); pg = doc[3]
Y_TICKS = list(range(80, -10, -5))
def polyline(drawing):
    pts = [it[1] for it in drawing["items"]] + [drawing["items"][-1][-1]]
    return [(p.x, p.y) for p in pts]
lines = [d for d in pg.get_drawings() if d["type"] == "s" and len(d["items"]) >= 8
         and d["rect"].y0 > 520 and d["rect"].x1 < 300]
series = {}
for d in lines:
    grey = d["color"][0] > 0.5
    series["Noiseband Thresholds" if grey else "Pure Tone Thresholds"] = polyline(d)
assert set(series) == {"Pure Tone Thresholds", "Noiseband Thresholds"}
segs = [(it[1], it[2]) for d in pg.get_drawings() for it in d["items"] if it[0] == "l"]
yt = sorted({round(a.y, 2) for a, b in segs if abs(a.y - b.y) < .01 and 63 < a.x < 64 and 540 < a.y < 700})
xt = sorted({round(a.x, 2) for a, b in segs if abs(a.x - b.x) < .01 and 689 < a.y < 692})
assert len(yt) == 18, yt
# major x ticks = those under a printed tick label
labels = {w[4]: (w[0] + w[2]) / 2 for w in pg.get_text("words") if 692 < w[1] < 695}
lab = {".5": .5, "1": 1, "2": 2, "4": 4, "8": 8, "10": 10, "20": 20, "40": 40, "80": 80, "100": 100, "116": 116}
xmaj = {v: min(xt, key=lambda t: abs(t - labels[k])) for k, v in lab.items()}
A = np.polyfit(np.log10(list(xmaj)), list(xmaj.values()), 1)
B = np.polyfit(yt, sorted(Y_TICKS, reverse=True), 1)   # yt ascending pt = 80 ... -5 dB
xres = np.polyval(A, np.log10(list(xmaj))) - np.array(list(xmaj.values()))
yres = np.polyval(B, yt) - np.array(sorted(Y_TICKS, reverse=True))
print("x ticks (kHz: pt):", xmaj, "max resid pt", round(max(abs(xres)), 3))
print("y ticks pt:", yt, "max resid dB", round(max(abs(yres)), 3))
out = os.path.join(here, "Heffner_etal_2013_Figure2_snapshot.csv")
with open(out, "w", newline="", encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["Series (label as printed)", "Point", "x (pt, PDF page 4)", "y (pt, PDF page 4)",
                "Frequency (in kHz)", "Threshold (in dB SPL)", "Note"])
    for s in ["Pure Tone Thresholds", "Noiseband Thresholds"]:
        pts = sorted(series[s])
        for i, (x, y) in enumerate(pts, 1):
            fk = 10 ** ((x - A[1]) / A[0]); db = np.polyval(B, y)
            note = ""
            if s == "Noiseband Thresholds": note = "Groger and Wiegrebe, 2006 (caption)"
            w.writerow([s, f"{'PT' if s.startswith('Pure') else 'NB'}{i:02d}", round(x, 2), round(y, 2),
                        f"{fk:.3g}" if fk < 100 else f"{fk:.4g}", f"{db:.1f}", note])
print("wrote", out)
pix = pg.get_pixmap(dpi=300, clip=pymupdf.Rect(40, 540, 300, 712))
import PIL.Image as I, PIL.ImageDraw as D
im = I.frombytes("RGB", (pix.width, pix.height), pix.samples); dr = D.Draw(im); s = 300 / 72
for nm, pts in series.items():
    for x, y in pts:
        cx, cy = (x - 40) * s, (y - 540) * s
        dr.ellipse([cx - 9, cy - 9, cx + 9, cy + 9], outline=(220, 0, 0) if nm.startswith("Pure") else (0, 90, 220), width=3)
for t in xmaj.values(): dr.line([((t - 40) * s, (689 - 540) * s), ((t - 40) * s, (693 - 540) * s)], fill=(0, 160, 0), width=3)
im.save(os.path.join(here, "Heffner_etal_2013_Figure2_digitisation_check.png"))
