"""Feinberg_etal_1990_Figure1_extract.py -- frozen-source builder for FIG. 1(a) and 1(c).

Feinberg, I., Thode, H. C., Jr., Chugani, H. T., & March, J. D. (1990). Gamma distribution
model describes maturational curves for delta wave amplitude, cortical metabolic rate and
synaptic density. J. theor. Biol. 142, 149-161. doi:10.1016/S0022-5193(05)80218-8

FIG. 1 (p. 152) has four panels; two are built here:
  (a) raw SYNAPTIC DENSITY observations (open circles) with the fitted gamma model.
      These are NOT Feinberg's measurements: they are Huttenlocher (1979), N = 12
      (Table 2 of this paper).
  (c) raw CEREBRAL METABOLIC RATE observations (open circles) with the fitted gamma
      model.  These are Chugani et al. (1987) frontal cortex, N = 29 (Table 2).
Hence data_role = secondary for both items, and
reference_tables/Feinberg_etal_1990_Figure1(a|c)_references.csv carries the primary
citation for every plotted point.

The PDF is a grey SCAN (1890 x 2850 px) with an unreliable OCR text layer; values are
pixel-digitised from the embedded page bitmap at native resolution.

  1. AXES.  Both panels have SINGLE LINEAR axes 0-35 years, which makes them directly
     comparable with the sources (Huttenlocher's Fig. 3 abscissa, by contrast, is broken
     and piecewise linear).  The abscissa ticks are read below the panel's own abscissa
     row; the ordinate is calibrated on the centres of the printed tick LABELS, whose
     row centres coincide with the ticks (the ordinate line is slightly skewed on this
     scan, so a tick scan at a fixed column misses some).
  2. MARKERS.  Every point is an open circle.  Circles are found two ways and merged:
     (i) the white region each ring encloses (fill holes, subtract, keep blobs of ring
     size and roughly square aspect -- this rejects the sliver enclosed between a ring
     and the ordinate line), and (ii) normalised cross-correlation against a ring
     template cut from an isolated circle, which recovers rings the fitted curve has
     broken.  The panel-letter "(a)" / "(c)" box is excluded: those letters enclose
     holes too.
  3. writes the two frozen snapshots and refuses to overwrite a differing copy.

Run (conda env "python": pymupdf, numpy, scipy, pandas, pillow):
    python Feinberg_etal_1990_Figure1_extract.py
"""
import io, os, sys
import numpy as np, pandas as pd, pymupdf
from PIL import Image
from scipy import ndimage as ndi
from scipy.ndimage import binary_fill_holes, binary_dilation
from scipy.signal import fftconvolve

HERE = os.path.dirname(os.path.abspath(__file__))
PDF  = os.path.join(HERE, "SynapticDensityDevelopment.pdf")
PAGE = 3                       # PDF p. 4 = journal p. 152

PANELS = {
 "Figure1(a)": dict(
     box=(452, 1216, 308, 880), exclude=[(455, 560, 740, 880)],
     xtick_px=[322, 402, 482, 562, 642, 722, 802, 882], xtick_val=[0, 5, 10, 15, 20, 25, 30, 35],
     ylab_cols=(262, 318), ylab_rows=(450, 1230), ylab_val=[25, 20, 15, 10, 5],
     thr=0.45, unit="synapses mm^-3 x 10^8",
     series="Synaptic density (raw observations)",
     n_printed=12, source="Huttenlocher (1979)"),
 "Figure1(c)": dict(
     box=(1372, 2156, 292, 880), exclude=[(1376, 1480, 740, 880)],
     xtick_px=[308, 390, 473, 557, 640, 722, 803, 886], xtick_val=[0, 5, 10, 15, 20, 25, 30, 35],
     ylab_cols=(225, 300), ylab_rows=(1360, 2170), ylab_val=[100, 80, 60, 40, 20],
     thr=0.40, unit="umol min^-1 100 g^-1",
     series="Cerebral metabolic rate (raw observations)",
     n_printed=29, source="Chugani et al. (1987), frontal cortex"),
}
TEMPLATE = (888, 908, 791, 813)   # an isolated open circle in panel (a): the 30-year point
RMIN = 9


def page_bitmap(doc, i):
    page = doc[i]
    im = page.get_images(full=True)[0]
    pix = pymupdf.Pixmap(doc, im[0])
    if pix.colorspace is None or pix.colorspace.n != 1 or pix.alpha:
        pix = pymupdf.Pixmap(pymupdf.csGRAY, pix)
    return np.array(Image.open(io.BytesIO(pix.tobytes("png"))).convert("L"))


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


def ylabel_rows(dd, c0, c1, r0, r1, nexp):
    band = np.zeros_like(dd); band[r0:r1, c0:c1] = dd[r0:r1, c0:c1]
    band = binary_dilation(band, np.ones((9, 1)))
    l, n = ndi.label(band, np.ones((3, 3))); cen = []
    for i, o in enumerate(ndi.find_objects(l), 1):
        if int((l[o] == i).sum()) < 120:
            continue
        cen.append((o[0].start + o[0].stop - 1) / 2)
    mg = []
    for v in sorted(cen):
        if mg and v - mg[-1][-1] <= 12:
            mg[-1].append(v)
        else:
            mg.append([v])
    out = [float(np.mean(g)) for g in mg]
    if len(out) != nexp:
        sys.exit("found %d ordinate labels, expected %d: %s" % (len(out), nexp, [round(v) for v in out]))
    return out


def detect(reg, t, thr):
    t0 = t.copy(); t0[t0 == 0] = -0.35; t0 -= t0.mean()
    S = fftconvolve(reg.astype(float), t0[::-1, ::-1], mode="same") / float((t * t0).sum())
    mx = ndi.maximum_filter(S, size=5); ys, xs = np.where((S == mx) & (S >= thr))
    out = []
    for v, y, x in sorted(zip(S[ys, xs], ys, xs), reverse=True):
        if any(np.hypot(y - yy, x - xx) < RMIN for _, yy, xx in out):
            continue
        out.append((float(v), int(y), int(x)))
    return out


def circles(dd, box, excl, t, thr):
    reg = np.zeros_like(dd); reg[box[0]:box[1], box[2]:box[3]] = dd[box[0]:box[1], box[2]:box[3]]
    for e in excl:
        reg[e[0]:e[1], e[2]:e[3]] = False
    holes = binary_fill_holes(reg) & ~reg
    l, n = ndi.label(holes, np.ones((3, 3))); out = []
    for i, o in enumerate(ndi.find_objects(l), 1):
        s = int((l[o] == i).sum()); h = o[0].stop - o[0].start; w = o[1].stop - o[1].start
        if not (40 <= s <= 200 and h >= 6 and w >= 6 and 0.55 <= w / h <= 1.8):
            continue
        c = ndi.center_of_mass(l == i)
        out.append((float(c[0]), float(c[1]), "enclosed_hole"))
    for v, y, x in detect(reg, t, thr):
        if not any(np.hypot(y - yy, x - xx) < RMIN for yy, xx, _ in out):
            out.append((float(y), float(x), "template_match"))
    return sorted(out, key=lambda p: p[1])


def main():
    doc = pymupdf.open(PDF)
    a = page_bitmap(doc, PAGE)
    if a.shape != (2850, 1890):
        sys.exit("unexpected page bitmap %s" % (a.shape,))
    dd = a < 128
    t = dd[TEMPLATE[0]:TEMPLATE[1], TEMPLATE[2]:TEMPLATE[3]].astype(float)
    for name, C in PANELS.items():
        yr = ylabel_rows(dd, C["ylab_cols"][0], C["ylab_cols"][1],
                         C["ylab_rows"][0], C["ylab_rows"][1], len(C["ylab_val"]))
        cy = np.polyfit(yr, C["ylab_val"], 1)
        yres = float(np.abs(np.polyval(cy, yr) - C["ylab_val"]).max())
        cx = np.polyfit(C["xtick_px"], C["xtick_val"], 1)
        xres = float(np.abs(np.polyval(cx, C["xtick_px"]) - C["xtick_val"]).max())
        pts = circles(dd, C["box"], C["exclude"], t, C["thr"])
        rows = [dict(panel=name, series_as_printed=C["series"], plot_symbol="open_circle",
                     px_x=round(x, 1), px_y=round(y, 1), detection=m,
                     age_years=round(float(np.polyval(cx, x)), 3),
                     value_in_figure_units=round(float(np.polyval(cy, y)), 3),
                     figure_units=C["unit"]) for y, x, m in pts]
        M = pd.DataFrame(rows).sort_values("px_x").reset_index(drop=True)
        hdr = ("# Feinberg_etal_1990 FIG. 1%s constructed snapshot -- pixel digitisation of the "
               "embedded page bitmap (1890 x 2850 px, 8-bit grey), PDF p. %d.\n"
               "# SECONDARY DATA: the plotted observations are %s.\n"
               "# abscissa: ticks at px %s -> %s years (linear, max residual %.3f).\n"
               "# ordinate: label centres at rows %s -> %s %s (linear, max residual %.3f).\n"
               "# the panel plots %d points (Table 2, N); %d were individually resolved.\n"
               % (name[6:], PAGE + 1, C["source"], C["xtick_px"], C["xtick_val"], xres,
                  [round(v, 1) for v in yr], C["ylab_val"], C["unit"], yres,
                  C["n_printed"], len(M)))
        path = os.path.join(HERE, "Feinberg_etal_1990_%s_snapshot.csv" % name)
        out = hdr + M.to_csv(index=False, lineterminator="\n")
        if os.path.exists(path):
            if open(path, encoding="utf-8").read() != out:
                sys.exit("REFUSING to overwrite differing frozen snapshot " + path)
            print("snapshot unchanged:", os.path.basename(path))
        else:
            open(path, "w", encoding="utf-8").write(out)
            print("wrote", os.path.basename(path), len(M), "of", C["n_printed"], "points")


if __name__ == "__main__":
    main()
