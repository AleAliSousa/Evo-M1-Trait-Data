"""Heffner_etal_2003_Figure5_extract.py -- frozen-source builder for Figure 5.

Heffner, R. S., Koay, G., & Heffner, H. E. (2003). Hearing in American
leaf-nosed bats. III: Artibeus jamaicensis. Hearing Research 184, 113-122.
doi:10.1016/s0378-5955(03)00233-8

FIG. 5 (PDF p. 7, journal p. 119) is a log-log scatter of highest audible
frequency at 60 dB SPL against functional interaural distance for mammals;
printed statistics r = -0.792, p <= .0001, n = 67, plus three subterranean
species drawn as open triangles and excluded from the correlation -- so the
panel carries 70 plotted points in total.

The figure is a RASTER image (embedded bitmap 755 x 945 px, 8-bit grey), so
values are pixel-digitised from the embedded bitmap at native resolution:

 1. axis lines = the longest fully dark column / row.  Ticks are the dark runs
    just outside them; the printed decade labels are matched to them (y: 100,
    70, 60, 50, 30, 20, 10, 5 kHz; x: 40, 50, 60, 90, 100, 200, 300, 500, 700,
    800, 1000, 4000 us).  Both axes fit log-linearly to <= 0.9%.
 2. markers are found by normalised cross-correlation with templates cut from
    the figure itself: an open-circle ring, a filled disc and an open triangle.
    Peak thresholds (ring 0.40 of max, disc 0.50, triangle 0.60) were set so
    that no text glyph is accepted -- see the overlay check PNG.
 3. centres are refined on the marker's own ink (ring annulus / disc centroid).
 4. writes Heffner_etal_2003_Figure5_snapshot.csv; refuses to overwrite a
    differing frozen copy.

Not every plotted point is separable: 51 open circles + 8 filled circles were
resolved out of the 67 circles the caption counts, so 8 circles remain merged
with a neighbour and are NOT in the snapshot.  All 3 triangles were resolved.

Run (conda env "python": pymupdf, numpy, scipy, pandas, pillow):
    python Heffner_etal_2003_Figure5_extract.py
"""
import io, os, sys
import numpy as np, pandas as pd, pymupdf
from PIL import Image
from scipy import ndimage as ndi
from scipy.signal import fftconvolve

HERE = os.path.dirname(os.path.abspath(__file__))
PDF  = os.path.join(HERE, "Heffner_etal_2003.pdf")
SNAP = os.path.join(HERE, "Heffner_etal_2003_Figure5_snapshot.csv")
PAGE, SHAPE = 6, (755, 945)
Y_ROWS = [100, 169, 198, 232, 330, 409, 541, 670]
Y_VALS = [100, 70, 60, 50, 30, 20, 10, 5]
X_COLS = [140, 178, 209, 278, 295, 412, 481, 565, 622, 645, 682, 915]
X_VALS = [40, 50, 60, 90, 100, 200, 300, 500, 700, 800, 1000, 4000]
TRI_WINDOWS = [(505, 525, 195, 230), (558, 575, 295, 325), (630, 645, 255, 290)]


def load_bitmap():
    doc = pymupdf.open(PDF); page = doc[PAGE]
    im = page.get_images(full=True)[0]
    pix = pymupdf.Pixmap(doc, im[0])
    if pix.colorspace is None or pix.colorspace.n != 1 or pix.alpha:
        pix = pymupdf.Pixmap(pymupdf.csGRAY, pix)
    a = np.array(Image.open(io.BytesIO(pix.tobytes("png"))).convert("L"))
    assert a.shape == SHAPE, a.shape
    return a


def main():
    a = load_bitmap()
    pm = np.zeros(a.shape, bool); pm[5:668, 96:930] = True
    img = (pm & (a < 110)).astype(float)
    lb, nn = ndi.label(pm & (a < 110), np.ones((3, 3)))
    objs = ndi.find_objects(lb)
    ring = disc = None
    for i, o in enumerate(objs, 1):
        h = o[0].stop - o[0].start; w = o[1].stop - o[1].start
        npx = int((lb[o] == i).sum())
        if (h, w) == (14, 14) and ring is None and 35 <= npx <= 48:
            ring = (a[o] < 110).astype(float)
        if (h, w) == (14, 14) and disc is None and npx >= 120:
            disc = (a[o] < 110).astype(float)
    assert ring is not None and disc is not None
    tri = np.zeros((15, 17), float)
    for i in range(15):
        wdt = int(round((i + 1) * 17 / 15 / 2))
        tri[14 - i, 8 - wdt] = 1; tri[14 - i, min(16, 8 + wdt)] = 1
    tri[14, :] = 1

    def nccmap(t):
        t2 = t.copy(); t2[t2 == 0] = -0.35; t2 -= t2.mean()
        return fftconvolve(img, t2[::-1, ::-1], mode="same") / np.sqrt((t2 ** 2).sum())

    def peaks(s, frac, sep=9):
        pk = np.argwhere((s == ndi.maximum_filter(s, size=sep)) & (s > frac * s.max()))
        return [(int(r), int(c), float(s[r, c])) for r, c in pk]

    sr, sd, st = nccmap(ring), nccmap(disc), nccmap(tri)
    cfy = np.polyfit(Y_ROWS, np.log10(Y_VALS), 1)
    cfx = np.polyfit(X_COLS, np.log10(X_VALS), 1)

    def refine(r, c, kind):
        sub = (a[r - 8:r + 8, c - 8:c + 8] < 110)
        ys, xs = np.where(sub)
        if kind == "filled circle":
            return r - 8 + ys.mean(), c - 8 + xs.mean()
        dd = np.hypot(ys - 8, xs - 8); m = (dd > 4.5) & (dd < 8.5)
        return r - 8 + ys[m].mean(), c - 8 + xs[m].mean()

    rows = []
    for kind, pk in (("open circle", peaks(sr, 0.40)), ("filled circle", peaks(sd, 0.50))):
        for r, c, s in pk:
            ry, rx = refine(r, c, kind)
            rows.append(dict(marker_type=kind, px_y=round(float(ry), 2), px_x=round(float(rx), 2),
                             ncc_score=round(s, 2)))
    for (r0, r1, c0, c1) in TRI_WINDOWS:
        sel = [(s, r, c) for r, c, s in peaks(st, 0.60) if r0 <= r <= r1 and c0 <= c <= c1]
        assert sel, (r0, r1, c0, c1)
        s, r, c = max(sel)
        ys, xs = np.where(a[r - 9:r + 9, c - 9:c + 9] < 110)
        rows.append(dict(marker_type="open triangle", px_y=round(float(r - 9 + ys.mean()), 2),
                         px_x=round(float(c - 9 + xs.mean()), 2), ncc_score=round(s, 2)))
    M = pd.DataFrame(rows).sort_values("px_x").reset_index(drop=True)
    M.insert(0, "marker_id", ["m%02d" % (i + 1) for i in range(len(M))])
    M["functional_interaural_distance_us"] = (10 ** np.polyval(cfx, M.px_x)).round(2)
    M["highest_audible_frequency_60dB_kHz"] = (10 ** np.polyval(cfy, M.px_y)).round(2)
    n = M.marker_type.value_counts().to_dict()
    assert n.get("open circle") == 51 and n.get("filled circle") == 8 and n.get("open triangle") == 3, n

    xres = 100 * (10 ** np.polyval(cfx, np.array(X_COLS)) / np.array(X_VALS) - 1)
    yres = 100 * (10 ** np.polyval(cfy, np.array(Y_ROWS)) / np.array(Y_VALS) - 1)
    hdr = ("# Heffner_etal_2003_Figure5 constructed snapshot -- digitised scatter markers.\n"
           "# x ticks %s us at px %s; log-fit residuals (%%): %s\n"
           "# y ticks %s kHz at px %s; log-fit residuals (%%): %s\n"
           "# caption n = 67 circles + 3 subterranean triangles = 70 plotted points;\n"
           "# 62 resolved here (51 open + 8 filled circles + 3 triangles); 8 circles unresolved (overlapping).\n"
           % (X_VALS, X_COLS, [round(float(v), 2) for v in xres],
              Y_VALS, Y_ROWS, [round(float(v), 2) for v in yres]))
    out = hdr + M.to_csv(index=False, lineterminator="\n")
    if os.path.exists(SNAP):
        if open(SNAP, encoding="utf-8").read() != out:
            sys.exit("REFUSING to overwrite differing frozen snapshot " + SNAP)
        print("snapshot unchanged"); return
    open(SNAP, "w", encoding="utf-8").write(out)
    print("wrote", SNAP, len(M), "markers")


if __name__ == "__main__":
    main()
