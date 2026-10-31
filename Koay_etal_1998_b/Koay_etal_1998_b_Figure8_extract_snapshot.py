"""Koay_etal_1998_b_Figure8_extract_snapshot.py -- digitise Fig. 8 -> frozen snapshot.

Source: Koay, Kearns, Heffner & Heffner (1998) Hearing Research 119:37-48, Fig. 8
(PDF page index 8, journal p. 45), embedded image xref 32 (5156 x 1600 px). The figure is
a single logarithmic scale bar from 1 deg to 180 deg carrying 30 species labels; each label
is joined to the bar by a tick or a leader. No coordinate is typed in this script: every
value is measured from the embedded image at run time.

Method (AI assistant, 2026-10-31):
1. The grey scale bar is located as the block of rows in which ink covers essentially the
   whole width (the bar is a dither pattern), giving its top and bottom edges.
2. Calibration: the printed scale labels 1, 2, 5, 10, 20, 50, 100 and 180 deg are the only
   fiducials the figure carries - it prints no axis ticks. Their glyphs are recovered by
   eroding the dither away inside the bar, grouped into labels, and the group centres are
   fitted by least squares against log10(value). The fit is loose by the standards of a
   plotted axis (rms about 20 px, max about 45 px = 0.022 decade), so values carry roughly
   +/- 5 per cent.
3. Each label is seeded with the x of the tick or leader it is joined to (SEEDS below: the
   label-to-leader assignment is the human reading of the figure). The coordinate is
   re-measured here as the x of the ink in a thin band against the bar - the business end,
   so a bent leader is read at its tick and not at its elbow. The Big Brown Bat arrow is
   measured at its tip, tracked into the bar by 5x5 erosion of the dither.
4. Three species (spiny mouse, wood rat, grasshopper mouse) share one tick joined by a
   printed brace, and two labels name two species each ("pig, opossum"; "kangaroo rat,
   gerbil"); both cases are flagged, not split, in the snapshot.
Run:  python Koay_etal_1998_b_Figure8_extract_snapshot.py   (needs pymupdf, numpy, scipy)
Refuses to overwrite an existing, differing snapshot unless --force.
"""
import sys, os, csv, io
import numpy as np, pymupdf
from scipy import ndimage

HERE = os.path.dirname(os.path.abspath(__file__))
PDF  = os.path.join(HERE, "Koay_etal_1998_b.pdf")
OUT  = os.path.join(HERE, "Koay_etal_1998_b_Figure8_snapshot.csv")
XREF = 32

## label as printed, seed x, side of the bar, leader type
SEEDS = [
    ("bottlenose dolphin", 441, "above", "bent"), ("elephant", 527, "above", "straight"),
    ("human", 587, "above", "straight"), ("(pallid bat)", 999, "above", "dashed"),
    ("seal", 1357, "above", "straight"), ("pig, opossum", 1642, "above", "straight"),
    ("macaque", 1793, "above", "straight"), ("cat", 1876, "above", "straight"),
    ("dog", 2167, "above", "bent"), ("ferret", 2201, "above", "straight"),
    ("sea lion", 2227, "above", "bent"), ("least weasel", 2538, "above", "bent"),
    ("Big Brown Bat", 2625, "above", "arrow"), ("goat", 2875, "above", "straight"),
    ("hedgehog", 2965, "above", "straight"), ("horse", 3181, "above", "straight"),
    ("cattle", 3296, "above", "straight"), ("albino rat", 2477, "below", "bent"),
    ("wild Norway rat", 2567, "below", "straight"), ("chinchilla", 2779, "below", "bent"),
    ("spiny mouse", 2957, "below", "brace"), ("wood rat", 2957, "below", "brace"),
    ("grasshopper mouse", 2957, "below", "brace"), ("kangaroo rat, gerbil", 3238, "below", "straight"),
    ("groundhog", 3261, "below", "bent"), ("(naked mole rat)", 3888, "below", "straight"),
    ("(blind mole rat)", 4904, "below", "bent"), ("(gopher)", 4935, "below", "dashed"),
]
SCALE = [1, 2, 5, 10, 20, 50, 100, 180]

doc = pymupdf.open(PDF)
pm  = pymupdf.Pixmap(doc, XREF)
a   = np.frombuffer(pm.samples, dtype=np.uint8).reshape(pm.height, pm.width, pm.n)[:, :, 0]
W   = a.shape[1]

## ---- 1. the grey scale bar ------------------------------------------------
cov = [(((a[i] < 200)[:W // 50 * 50]).reshape(-1, 50).any(1)).mean() for i in range(a.shape[0])]
rows = [i for i, c in enumerate(cov) if c > 0.97]
B0, B1 = rows[0], rows[-1]

## ---- 2. calibration from the printed scale labels -------------------------
solid = ndimage.binary_erosion(a[B0 + 5:B1 - 5, :] < 100, np.ones((3, 3)))
lab, n = ndimage.label(solid)
boxes = []
for i, sl in enumerate(ndimage.find_objects(lab), 1):
    ar = int((lab[sl] == i).sum())
    if ar < 150: continue
    boxes.append((sl[1].start, sl[1].stop, ar))
boxes.sort()
groups, cur = [], [boxes[0]]
for b in boxes[1:]:
    if b[0] - cur[-1][1] <= 45: cur.append(b)
    else: groups.append(cur); cur = [b]
groups.append(cur)
groups = [g for g in groups if sum(x[2] for x in g) > 1500]
cent = [(min(x[0] for x in g) + max(x[1] for x in g)) / 2 for g in groups]
assert len(cent) == len(SCALE), (len(cent), cent)
BX, AX_ = np.polyfit(np.log10(SCALE), cent, 1)
resid = np.array(cent) - (AX_ + BX * np.log10(SCALE))
assert np.abs(resid).max() < 60
to_deg = lambda x: 10 ** ((x - AX_) / BX)

## ---- 3. measure each leader where it meets the bar ------------------------
def leader_x(seed, side, kind):
    if kind == "arrow":                       # tip, tracked into the dithered bar
        reg = ndimage.binary_erosion(a[B0 - 60:B1 + 5, seed - 90:seed + 90] < 100, np.ones((5, 5)))
        cand = []
        for r in range(reg.shape[0]):
            xs = np.where(reg[r])[0]
            if len(xs) and (xs.max() - xs.min()) < 60: cand.append(r)
        tip = max(cand)
        return float(np.where(reg[tip])[0].mean() + seed - 90)
    band = (a[B0 - 26:B0 - 6, seed - 45:seed + 45] if side == "above"
            else a[B1 + 6:B1 + 26, seed - 45:seed + 45]) < 128
    cols = np.where(band.mean(0) >= (0.45 if kind == "dashed" else 0.85))[0]
    assert len(cols), ("no leader near", seed)
    runs, cur = [], [cols[0]]
    for c in cols[1:]:
        if c - cur[-1] <= 4: cur.append(c)
        else: runs.append(cur); cur = [c]
    runs.append(cur)
    best = min(runs, key=lambda r: abs(np.mean(r) - 45))
    return float(np.mean(best) + seed - 45)

rows_out = []
for name, seed, side, kind in SEEDS:
    x = leader_x(seed, side, kind)
    rows_out.append(dict(label=name, side=side, kind=kind, x=x, deg=to_deg(x)))

shared = {}
for r in rows_out: shared.setdefault(round(r["x"]), []).append(r["label"])
assert len(rows_out) == 28, len(rows_out)
hdr = ["label_as_printed", "position", "leader_type", "sound_localization_threshold_deg_as_read",
       "x_px_native", "shares_tick_with", "note"]
buf = io.StringIO(); w = csv.writer(buf, lineterminator="\n"); w.writerow(hdr)
for r in rows_out:
    partners = [l for l in shared[round(r["x"])] if l != r["label"]]
    note = []
    if partners: note.append("joined to the same tick by the printed brace as: " + "; ".join(partners))
    if "," in r["label"]: note.append("one tick, two species named in the label")
    if r["label"].startswith("("): note.append("parentheses as printed: threshold obtained with a stimulus longer than 100 ms")
    w.writerow([r["label"], r["side"], r["kind"], "%.2f" % r["deg"], "%.1f" % r["x"],
                "; ".join(partners), ". ".join(note)])
new = buf.getvalue()
if os.path.exists(OUT) and open(OUT, encoding="utf-8").read() != new and "--force" not in sys.argv:
    sys.exit("Existing snapshot differs from a fresh digitisation; inspect, then rerun with --force.")
open(OUT, "w", encoding="utf-8").write(new)
print("wrote %s: %d labels; calibration rms %.0f px, max %.0f px" % (OUT, len(rows_out), np.sqrt((resid**2).mean()), np.abs(resid).max()))
