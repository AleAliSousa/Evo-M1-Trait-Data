"""Heffner_Heffner_2018_Figure3_extract.py -- frozen-source builder for Figure 3.

Heffner, H. E., & Heffner, R. S. (2018). The evolution of mammalian hearing.
AIP Conf. Proc. 1965, 130001. doi:10.1063/1.5038516

Figure 3 (PDF p. 5, journal p. 130001-4) is a RASTER image (embedded 1144 x 812
px, 8-bit grey) -- no vector paths -- so values are pixel-digitised from the
embedded bitmap at its native resolution (no re-rendering):

 1. axis lines = the fully dark column / row runs; tick marks = 2-px dark runs
    just outside the axes; tick values are the printed labels
    (y: 40 30 20 10 6 3 1; x: 1 3 10 30 100 180 200).
 2. calibration: log10(value) vs pixel, PIECEWISE-linear between adjacent
    printed ticks (primary), plus a single least-squares log fit (reported as
    the *_globalfit columns). The printed ticks are not exactly log-spaced
    (global-fit residuals up to ~5%, worst at the crowded 180/200 x ticks), so
    the two calibrations bracket the digitisation uncertainty.
 3. markers = open circles (outer diameter ~22 px): ring-template
    cross-correlation, local maxima above a score threshold, then an
    algebraic circle fit to the ring pixels for the centre.
 4. writes Heffner_Heffner_2018_Figure3_snapshot.csv -- and refuses to
    overwrite a differing frozen copy.

Run (conda env "python": pymupdf, numpy, scipy, pandas, pillow):
    python Heffner_Heffner_2018_Figure3_extract.py
Label -> marker assignment is NOT done here (it is a visual reading of the
printed labels and leader lines): reference_tables/
Heffner_Heffner_2018_Figure3_label_assignment.csv.
"""
import io, os, sys
import numpy as np, pandas as pd, pymupdf
from PIL import Image
from scipy.signal import fftconvolve
from scipy import ndimage as ndi

HERE = os.path.dirname(os.path.abspath(__file__))
PDF = os.path.join(HERE, "Heffner-2018-The evolution of mammalian hearin.pdf")
SNAP = os.path.join(HERE, "Heffner_Heffner_2018_Figure3_snapshot.csv")
Y_TICKS = [40, 30, 20, 10, 6, 3, 1]          # printed, top -> bottom
X_TICKS = [1, 3, 10, 30, 100, 180, 200]      # printed, left -> right

def load_bitmap():
    doc = pymupdf.open(PDF)
    page = doc[4]                              # PDF page 5
    imgs = [im for im in page.get_images(full=True)]
    # Figure 3 is the lower of the two images on the page
    im = max(imgs, key=lambda im: page.get_image_bbox(im).y0)
    pix = pymupdf.Pixmap(doc, im[0])
    if pix.colorspace is None or pix.colorspace.n != 1 or pix.alpha:
        pix = pymupdf.Pixmap(pymupdf.csGRAY, pix)
    a = np.array(Image.open(io.BytesIO(pix.tobytes("png"))).convert("L"))
    assert a.shape == (812, 1144), a.shape
    return a

def runs(mask):
    idx = np.where(mask)[0]; out = []
    if len(idx) == 0: return out
    s = p = idx[0]
    for i in idx[1:]:
        if i != p + 1: out.append((s, p)); s = i
        p = i
    out.append((s, p)); return out

def main():
    a = load_bitmap(); dark = a < 128
    cs, rs = dark.sum(0), dark.sum(1)                  # axis lines are 4 px thick
    ycol = int(np.where(cs >= 0.98 * cs.max())[0].min())   # left edge of y-axis line
    xrow = int(np.where(rs >= 0.98 * rs.max())[0].max())   # bottom edge of x-axis line
    yt = [(s + e) / 2 for s, e in runs(dark[:, ycol - 9:ycol - 1].all(1))]
    xt = [(s + e) / 2 for s, e in runs(dark[xrow + 2:xrow + 10, :].all(0))]
    assert len(yt) == 7 and len(xt) == 7, (yt, xt)
    ypx, xpx = np.array(yt), np.array(xt)
    yv, xv = np.log10(Y_TICKS), np.log10(X_TICKS)
    gy, gx = np.polyfit(ypx, yv, 1), np.polyfit(xpx, xv, 1)
    def piece(p, px, lv):
        o = np.argsort(px); px, lv = px[o], lv[o]
        if p < px[0]:  k = np.polyfit(px[:2], lv[:2], 1);  return 10 ** np.polyval(k, p)
        if p > px[-1]: k = np.polyfit(px[-2:], lv[-2:], 1); return 10 ** np.polyval(k, p)
        return 10 ** np.interp(p, px, lv)
    # ring template
    R = 15; yy, xx = np.mgrid[-R:R + 1, -R:R + 1]; rr = np.hypot(yy, xx)
    t = np.where((rr >= 8.5) & (rr <= 11.0), 1.0, 0.0); t[rr < 7.5] = -1.0; t[(rr > 12) & (rr <= 14)] = -0.5
    t -= t.mean()
    score = fftconvolve(dark.astype(float), t[::-1, ::-1], mode="same")
    pk = np.argwhere((score == ndi.maximum_filter(score, size=15)) & (score > 0.75 * score.max()))
    rows = []
    for r0, c0 in pk:
        ys, xs = np.where(dark[r0 - 14:r0 + 15, c0 - 14:c0 + 15]); ys = ys + r0 - 14; xs = xs + c0 - 14
        d = np.hypot(ys - r0, xs - c0); m = (d > 6.5) & (d < 13); ys, xs = ys[m].astype(float), xs[m].astype(float)
        for _ in range(3):
            A = np.c_[2 * xs, 2 * ys, np.ones_like(xs)]
            cx, cy, k = np.linalg.lstsq(A, xs ** 2 + ys ** 2, rcond=None)[0]; rad = np.sqrt(k + cx ** 2 + cy ** 2)
            keep = np.abs(np.hypot(xs - cx, ys - cy) - rad) < 2.0; xs, ys = xs[keep], ys[keep]
        rows.append(dict(px_x=cx, px_y=cy, radius_px=rad, ring_pixels=len(xs), match_score=score[r0, c0]))
    M = pd.DataFrame(rows).sort_values("px_x").reset_index(drop=True)
    assert len(M) == 22, f"expected 22 markers (caption n = 22), found {len(M)}"
    M.insert(0, "marker_id", [f"m{i + 1:02d}" for i in range(len(M))])
    M["width_field_best_vision_deg"] = [piece(x, xpx, xv) for x in M.px_x]
    M["sound_localization_threshold_deg"] = [piece(y, ypx, yv) for y in M.px_y]
    M["width_field_best_vision_deg_globalfit"] = 10 ** np.polyval(gx, M.px_x)
    M["sound_localization_threshold_deg_globalfit"] = 10 ** np.polyval(gy, M.px_y)
    M = M.round({"px_x": 2, "px_y": 2, "radius_px": 2, "match_score": 1,
                 "width_field_best_vision_deg": 3, "sound_localization_threshold_deg": 3,
                 "width_field_best_vision_deg_globalfit": 3, "sound_localization_threshold_deg_globalfit": 3})
    out = M.to_csv(index=False, lineterminator="\n")
    if os.path.exists(SNAP):
        if open(SNAP, encoding="utf-8").read() != out:
            sys.exit("REFUSING to overwrite differing frozen snapshot " + SNAP)
        print("snapshot unchanged"); return
    open(SNAP, "w", encoding="utf-8").write(out)
    print("wrote", SNAP, len(M), "markers; y ticks px", ypx.tolist(), "x ticks px", xpx.tolist())

if __name__ == "__main__":
    main()
