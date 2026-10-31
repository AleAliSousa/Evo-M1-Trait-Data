"""Heffner_etal_2003_Figure4_extract.py -- frozen-source builder for Figure 4.

Heffner, R. S., Koay, G., & Heffner, H. E. (2003). Hearing in American
leaf-nosed bats. III: Artibeus jamaicensis. Hearing Research 184, 113-122.
doi:10.1016/s0378-5955(03)00233-8

FIG. 4 (PDF p. 5, journal p. 117) plots the audiograms of three phyllostomid
bats as three line styles:
    thick grey  = Carollia perspicillata (47 us)   [arrow, top label]
    thin black  = Artibeus jamaicensis  (96 us)    [arrow, middle label]
    dotted      = Phyllostomus hastatus (108 us)   [arrow, bottom label]
(assignment read from the three printed arrows; see the README).

The figure is a RASTER image (embedded bitmap 617 x 945 px, 8-bit grey; no
vector paths), so the curves are pixel-digitised from the embedded bitmap at
native resolution -- never from a re-render:

 1. axis lines = the longest fully dark column / row.  The 14 printed x ticks
    (1 ... 160 kHz) are the dark runs below the abscissa; the 10 printed y
    ticks (90 ... 0 dB SPL) the dark runs left of the ordinate.  Both axes fit
    their printed values to <= 0.8% (x, log) and <= 0.2 dB (y, linear).
 2. curve separation by grey level and connectivity: the thick grey curve is
    the 130-175 grey band (components > 200 px); the thin black curve is the
    single largest < 110 component; the dotted curve is every other < 110
    component of <= 120 px, with the italic in-panel label block and the
    60-dB reference line removed by position.
 3. per-column trace = centre of the longest dark run in that column.
 4. polyline vertices by Douglas-Peucker simplification of the trace
    (tolerance 2.0 px for the thin black curve, 2.5 px for the thick grey one,
    3.0 px for the gapped dotted one), merging vertices closer than 4 px in x.
    The paper does not print the tested frequencies, so vertex frequencies are
    reported AS EXTRACTED and are not snapped to a nominal test series.
 5. writes Heffner_etal_2003_Figure4_snapshot.csv; refuses to overwrite a
    differing frozen copy.

Run (conda env "python": pymupdf, numpy, scipy, pandas, pillow):
    python Heffner_etal_2003_Figure4_extract.py
"""
import io, os, sys
import numpy as np, pandas as pd, pymupdf
from PIL import Image
from scipy import ndimage as ndi

HERE = os.path.dirname(os.path.abspath(__file__))
PDF  = os.path.join(HERE, "Heffner_etal_2003.pdf")
SNAP = os.path.join(HERE, "Heffner_etal_2003_Figure4_snapshot.csv")
PAGE, SHAPE = 4, (617, 945)
X_TICKS = [1, 2, 4, 8, 16, 20, 25, 32, 40, 56, 80, 100, 140, 160]
Y_TICKS = [90, 80, 70, 60, 50, 40, 30, 20, 10, 0]


def load_bitmap():
    doc = pymupdf.open(PDF); page = doc[PAGE]
    im = page.get_images(full=True)[0]
    pix = pymupdf.Pixmap(doc, im[0])
    if pix.colorspace is None or pix.colorspace.n != 1 or pix.alpha:
        pix = pymupdf.Pixmap(pymupdf.csGRAY, pix)
    a = np.array(Image.open(io.BytesIO(pix.tobytes("png"))).convert("L"))
    assert a.shape == SHAPE, a.shape
    return a


def runs(mask):
    idx = np.where(mask)[0]; out = []
    if len(idx) == 0:
        return out
    s = p = idx[0]
    for i in idx[1:]:
        if i != p + 1:
            out.append((s, p)); s = i
        p = i
    out.append((s, p)); return out


def trace_cols(m):
    out = []
    for x in range(m.shape[1]):
        r = runs(m[:, x])
        if not r:
            continue
        s, e = max(r, key=lambda t: t[1] - t[0])
        out.append((x, (s + e) / 2))
    return np.array(out, float)


def dp(pts, eps):
    def rec(i, j):
        if j <= i + 1:
            return [i]
        p0, p1 = pts[i], pts[j]
        v = p1 - p0; n = np.hypot(*v)
        d = np.abs(v[0] * (pts[i:j + 1, 1] - p0[1]) - v[1] * (pts[i:j + 1, 0] - p0[0])) / n
        if d.max() <= eps:
            return [i]
        k = int(np.argmax(d)) + i
        return rec(i, k) + rec(k, j)
    return rec(0, len(pts) - 1) + [len(pts) - 1]


def vertices(m, eps):
    P = trace_cols(m); V = P[dp(P, eps)]
    out = [V[0]]
    for v in V[1:]:
        if v[0] - out[-1][0] < 4:
            out[-1] = (out[-1] + v) / 2
        else:
            out.append(v)
    V = np.array(out)
    fx = np.interp(P[:, 0], V[:, 0], V[:, 1])
    return V, float(np.sqrt(np.mean((fx - P[:, 1]) ** 2))), len(P)


def main():
    a = load_bitmap()
    d = a < 100
    cd, rd = d.sum(0), d.sum(1)
    yaxis = int(np.where(cd >= 0.98 * cd.max())[0].max())
    xaxis = int(np.where(rd >= 0.98 * rd.max())[0].max())

    def find_band(axis, n, horizontal):
        """scan offsets outside the axis line for the band giving exactly n ticks."""
        for off in range(1, 12):
            for wid in (4, 5, 6, 7):
                if horizontal:          # ticks below the abscissa
                    t = [(s + e) / 2 for s, e in runs(d[axis + off:axis + off + wid, :].all(0))]
                else:                   # ticks left of the ordinate
                    t = [(s + e) / 2 for s, e in runs(d[:, axis - off - wid:axis - off].all(1))]
                if len(t) == n:
                    return t, off, wid
        raise AssertionError("tick band not found for n=%d" % n)

    yt, yoff, ywid = find_band(yaxis, len(Y_TICKS), False)
    xt, xoff, xwid = find_band(xaxis, len(X_TICKS), True)
    cfy = np.polyfit(yt, Y_TICKS, 1)
    cfx = np.polyfit(xt, np.log10(X_TICKS), 1)

    pm = np.zeros(a.shape, bool); pm[16:xaxis - 1, yaxis + 2:910] = True
    grey = pm & (a >= 130) & (a <= 175); grey[176:187, :] = False
    gl, gn = ndi.label(grey, np.ones((3, 3))); gs = ndi.sum(grey, gl, range(1, gn + 1))
    grey = np.isin(gl, [i + 1 for i, s in enumerate(gs) if s > 200])

    blk = pm & (a < 110)
    bl, bn = ndi.label(blk, np.ones((3, 3))); bs = ndi.sum(blk, bl, range(1, bn + 1))
    solid_id = int(np.argmax(bs)) + 1
    solid = (bl == solid_id)
    dot = np.zeros_like(blk)
    for i in range(1, bn + 1):
        if i != solid_id and bs[i - 1] <= 120:
            dot |= (bl == i)
    dot[:140, 300:] = False          # italic species labels + arrows inside the panel
                                     # (right of col 300 no curve lies above row 140)
    dot[176:187, :] = False          # 60-dB reference line
    dot[:, 840:] = False             # beyond the dotted curve's right end

    rows = []
    for species, note, m, eps in (
            ("Carollia perspicillata", "thick grey line; label '(47 us)'", grey, 2.5),
            ("Artibeus jamaicensis", "thin black line; label '(96 us)'", solid, 2.0),
            ("Phyllostomus hastatus", "dotted line; label '(108 us)'", dot, 3.0)):
        V, rms, ncol = vertices(m, eps)
        for k, (px, py) in enumerate(V, 1):
            rows.append(dict(species_as_printed=species, line_style=note, vertex_index=k,
                             px_x=round(float(px), 1), px_y=round(float(py), 1),
                             frequency_kHz=round(float(10 ** np.polyval(cfx, px)), 3),
                             threshold_dB_SPL=round(float(np.polyval(cfy, py)), 2),
                             trace_rms_px=round(rms, 2), trace_columns=ncol))
    M = pd.DataFrame(rows)
    xres = 100 * (10 ** np.polyval(cfx, np.array(xt)) / np.array(X_TICKS) - 1)
    yres = np.polyval(cfy, np.array(yt)) - np.array(Y_TICKS)
    hdr = ("# Heffner_etal_2003_Figure4 constructed snapshot -- digitised audiogram polylines.\n"
           "# x ticks %s kHz at px %s; log-fit residuals (%%): %s\n"
           "# y ticks %s dB SPL at px %s; linear-fit residuals (dB): %s\n"
           "# vertex frequencies are AS EXTRACTED, not snapped to nominal test frequencies.\n"
           % (X_TICKS, [round(float(v), 1) for v in xt], [round(float(v), 2) for v in xres],
              Y_TICKS, [round(float(v), 1) for v in yt], [round(float(v), 2) for v in yres]))
    out = hdr + M.to_csv(index=False, lineterminator="\n")
    if os.path.exists(SNAP):
        if open(SNAP, encoding="utf-8").read() != out:
            sys.exit("REFUSING to overwrite differing frozen snapshot " + SNAP)
        print("snapshot unchanged"); return
    open(SNAP, "w", encoding="utf-8").write(out)
    print("wrote", SNAP, len(M), "vertices")


if __name__ == "__main__":
    main()
