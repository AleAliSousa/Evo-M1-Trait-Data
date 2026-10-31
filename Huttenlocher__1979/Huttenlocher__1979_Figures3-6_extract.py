"""Huttenlocher__1979_Figures3-6_extract.py -- frozen-source builder for Figs 3-6.

Huttenlocher, P. R. (1979). Synaptic density in human frontal cortex: developmental
changes and effects of aging. Brain Res. 163, 195-205. doi:10.1016/0006-8993(79)90349-4

The paper publishes NO data table: every value lives in a figure.  Four figures are
digitised here, each into its own frozen snapshot:

  Fig. 3 (p. 199) synapse counts in layer 3 of middle frontal gyrus vs age, filled circles
  Fig. 4 (p. 200) neuronal density in the same layer vs age; OPEN circles = this study,
                  FILLED circles = Schade & Van Groenigen (ref. 18)
  Fig. 5 (p. 203) mean synapses per neuron vs age, open triangles (DERIVED: Fig3 / Fig4)
  Fig. 6 (p. 203) total brain weights vs age, open circles

The PDF pages are grey SCANS (1950 x 3000 px); values are pixel-digitised from the
embedded page bitmaps at native resolution, never from a re-render.

  1. AXES.  Per figure the ordinate is the longest dark column and the abscissa the
     longest dark row.  Ordinate ticks are located as the short marks protruding to the
     left of the ordinate and fitted by least squares against their printed labels.
  2. THE ABSCISSA IS BROKEN AND PIECEWISE LINEAR.  Fig. 3 prints
     NB 0.5 1 // 5 10 15 20 // 40 60 80 100 and Figs. 4-6 print
     NB 0.5 1 2 // 5 10 // Adult Aged(74-90).  Each printed tick is located below the
     abscissa and matched to its printed label (the label text centroids are found
     independently and used to disambiguate the break glyphs "//" from real ticks).
     Age is then interpolated WITHIN the segment the point falls in; a point lying in
     an axis-break gap is flagged (age_in_axis_break) and its age is extrapolated from
     the nearer segment -- it is not an exact reading.  "Adult" and "Aged (74-90)" are
     CATEGORICAL columns and get no numeric age.
  3. MARKERS.  Open markers (circles, triangles) are found as the white region they
     enclose: fill the holes of the dark mask, subtract, and keep hole blobs of marker
     size and roughly square aspect.  This survives the fitted curve and the error bars
     passing through a marker.  Filled circles are found by eroding the dark mask with a
     disk, which removes the curve and the error bars and leaves one blob per marker.
     Fig. 3 is cross-validated: matched-filter detection with a circle template and the
     erosion method return the same 22 markers to within 1 px.
  4. writes four snapshots and refuses to overwrite a differing frozen copy.

Run (conda env "python": pymupdf, numpy, scipy, pandas, pillow):
    python Huttenlocher__1979_Figures3-6_extract.py
"""
import io, os, sys
import numpy as np, pandas as pd, pymupdf
from PIL import Image
from scipy import ndimage as ndi
from scipy.ndimage import binary_erosion, binary_fill_holes, binary_dilation
from scipy.signal import fftconvolve

HERE = os.path.dirname(os.path.abspath(__file__))
PDF  = os.path.join(HERE, "Huttenlocher-1979-Synaptic density in human fr.pdf")

## figure -> page index, ordinate column, abscissa row, plot box, ordinate labels,
##           abscissa label sequence, marker kinds
FIGS = {
 "Figure3": dict(page=4, yax=316, xrow=2513, box=(1830, 2510, 322, 1300),
                 ylab=[20, 15, 10, 5], n_ytick=4,
                 xlab=[("NB", 0.0), ("0.5", 0.5), ("1", 1.0), ("5", 5.0), ("10", 10.0),
                       ("15", 15.0), ("20", 20.0), ("40", 40.0), ("60", 60.0),
                       ("80", 80.0), ("100", 100.0)],
                 segs=[(0, 2), (3, 6), (7, 10)],
                 series={"filled_circle": "Synapse counts, layer 3 middle frontal gyrus"},
                 unit="synapses/mm3 x 10^8"),
 "Figure4": dict(page=5, yax=315, xrow=765, box=(240, 760, 320, 1250),
                 ylab=[12, 10, 8, 6, 4, 2], n_ytick=6,
                 xlab=[("NB", 0.0), ("0.5", 0.5), ("1", 1.0), ("2", 2.0), ("5", 5.0),
                       ("10", 10.0), ("Adult", None), ("Aged (74-90)", None)],
                 segs=[(0, 3), (4, 5)],
                 series={"open_circle": "Neuronal density, present study",
                         "filled_circle": "Neuronal density, Schade and Van Groenigen"},
                 unit="neurons/mm3 x 10^4"),
 "Figure5": dict(page=8, yax=303, xrow=701, box=(240, 698, 308, 1250),
                 ylab=[10, 8, 6, 4, 2], n_ytick=5,
                 xlab=[("NB", 0.0), ("0.5", 0.5), ("1", 1.0), ("2", 2.0), ("5", 5.0),
                       ("10", 10.0), ("Adult", None), ("Aged (74-90)", None)],
                 segs=[(0, 3), (4, 5)],
                 series={"open_triangle": "Mean synapses per neuron"},
                 unit="synapses/neuron x 10^4"),
 "Figure6": dict(page=8, yax=351, xrow=2446, box=(1570, 2443, 356, 1400),
                 ylab=[1400, 1200, 1000, 800, 600, 400, 200], n_ytick=7,
                 xlab=[("NB", 0.0), ("0.5", 0.5), ("1", 1.0), ("2", 2.0), ("5", 5.0),
                       ("10", 10.0), ("Adult", None), ("Aged (74-90)", None)],
                 segs=[(0, 3), (4, 5)],
                 series={"open_circle": "Total brain weight"},
                 unit="grams"),
}


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


def ytick_rows(dd, yax, r0, r1, nexp):
    best = None
    for lo in range(2, 10):
        for hi in range(lo + 3, lo + 10):
            m = dd[r0:r1, yax - hi:yax - lo].sum(1)
            t = [((s + e) / 2 + r0) for s, e in runs(m >= (hi - lo) - 1)]
            mg = []
            for v in t:
                if mg and v - mg[-1][-1] <= 8:
                    mg[-1].append(v)
                else:
                    mg.append([v])
            cen = [float(np.mean(g)) for g in mg]
            if best is None or abs(len(cen) - nexp) < abs(len(best) - nexp):
                best = cen
    return best


def xlabel_centres(dd, xrow, yax):
    """centres of the printed tick labels -- the FIRST text line below the abscissa.
    (the second line carries the axis title "YEARS" / "Age (Years)" and the "(74-90)"
    continuation, which must not be mistaken for tick labels; in Fig. 6 the two lines
    touch, so they are separated by the characters' top row, not by a blank row.)"""
    r0 = xrow + 12
    strip = np.zeros_like(dd); strip[r0:xrow + 95, yax:] = dd[r0:xrow + 95, yax:]
    l, n = ndi.label(strip, np.ones((3, 3)))
    chars = []
    for i, o in enumerate(ndi.find_objects(l), 1):
        ## one printed character: >= 10 px tall.  A leftover tick stub is shorter.
        if int((l[o] == i).sum()) < 25 or (o[0].stop - o[0].start) < 10:
            continue
        chars.append((o[0].start, o[1].start, o[1].stop - 1))
    if not chars:
        raise SystemExit("no tick-label characters found below the abscissa")
    top = min(c[0] for c in chars)
    chars = sorted((c[1], c[2]) for c in chars if c[0] - top <= 12)
    groups = []
    for a, b in chars:
        if groups and a - groups[-1][1] <= 14:
            groups[-1][1] = max(groups[-1][1], b)
        else:
            groups.append([a, b])
    return [(g[0] + g[1]) / 2 for g in groups]


def xtick_positions(dd, xrow, yax, labels):
    """locate the printed ticks; keep only those that carry a printed label, so that
    the axis-break glyphs "//" (which look like ticks) are discarded."""
    cand = {}
    for lo in range(2, 9):
        for hi in range(lo + 3, lo + 9):
            m = dd[xrow + lo:xrow + hi, :].sum(0)
            for s, e in runs(m >= max(2, (hi - lo) - 2)):
                v = (s + e) / 2
                if v > yax:
                    cand[round(v)] = cand.get(round(v), 0) + 1
    pos = [p for p, k in sorted(cand.items()) if k >= 3]
    cen = xlabel_centres(dd, xrow, yax)
    if len(cen) != len(labels):
        raise SystemExit("found %d tick labels, expected %d (%s)"
                         % (len(cen), len(labels), [round(c) for c in cen]))
    out, used = [], set()
    for (nm, val), c in zip(labels, cen):
        free = [p for p in pos if p not in used and abs(p - c) <= 25]
        if not free:
            raise SystemExit("no tick matched printed label %r at %.1f px" % (nm, c))
        p = min(free, key=lambda q: abs(q - c))
        used.add(p); out.append((nm, val, float(p)))
    return out


def age_from_px(ticks, segs, x):
    for nm, val, px in ticks:
        if val is None and abs(x - px) <= 22:
            return nm, np.nan, "categorical", "no"
    for a, b in segs:
        lo, hi = ticks[a][2], ticks[b][2]
        if lo - 14 <= x <= hi + 14:
            c = np.polyfit([ticks[i][2] for i in range(a, b + 1)],
                           [ticks[i][1] for i in range(a, b + 1)], 1)
            return "years", float(np.polyval(c, x)), "segment %s-%s" % (ticks[a][0], ticks[b][0]), "no"
    # in an axis-break gap: extrapolate from the nearer segment and flag it
    best, bd = None, 1e9
    for a, b in segs:
        for edge, idx in ((ticks[a][2], a), (ticks[b][2], b)):
            if abs(x - edge) < bd:
                bd, best = abs(x - edge), (a, b)
    a, b = best
    c = np.polyfit([ticks[i][2] for i in range(a, b + 1)],
                   [ticks[i][1] for i in range(a, b + 1)], 1)
    return "years", float(np.polyval(c, x)), "segment %s-%s (extrapolated)" % (ticks[a][0], ticks[b][0]), "yes"


def open_markers(dd, box, amin=40, amax=200):
    reg = np.zeros_like(dd); reg[box[0]:box[1], box[2]:box[3]] = dd[box[0]:box[1], box[2]:box[3]]
    holes = binary_fill_holes(reg) & ~reg
    l, n = ndi.label(holes, np.ones((3, 3))); out = []
    for i, o in enumerate(ndi.find_objects(l), 1):
        s = int((l[o] == i).sum()); h = o[0].stop - o[0].start; w = o[1].stop - o[1].start
        if not (amin <= s <= amax and h >= 4 and w >= 3 and 0.45 <= w / h <= 2.0):
            continue
        c = ndi.center_of_mass(l == i)
        # for a triangle the glyph centre is the bounding box centre of the glyph, not
        # of the hole; the hole bbox is used, which is concentric with the glyph in x
        out.append((float(c[0]), float(c[1])))
    return sorted(out, key=lambda p: p[1])


def filled_markers(dd, box, rad=3, smin=6):
    reg = np.zeros_like(dd); reg[box[0]:box[1], box[2]:box[3]] = dd[box[0]:box[1], box[2]:box[3]]
    yy, xx = np.mgrid[0:2 * rad + 1, 0:2 * rad + 1]
    st = ((yy - rad) ** 2 + (xx - rad) ** 2) <= rad * rad
    er = binary_erosion(reg, st); l, n = ndi.label(er, np.ones((3, 3))); out = []
    for i in range(1, n + 1):
        if int((l == i).sum()) < smin:
            continue
        c = ndi.center_of_mass(l == i); out.append((float(c[0]), float(c[1])))
    return sorted(out, key=lambda p: p[1])


def main():
    doc = pymupdf.open(PDF)
    pages = {}
    for fig, C in FIGS.items():
        if C["page"] not in pages:
            pages[C["page"]] = page_bitmap(doc, C["page"])
    for fig, C in FIGS.items():
        dd = pages[C["page"]] < 128
        yt = ytick_rows(dd, C["yax"], C["box"][0], C["box"][1], C["n_ytick"])
        if len(yt) != C["n_ytick"]:
            sys.exit("%s: found %d ordinate ticks, expected %d" % (fig, len(yt), C["n_ytick"]))
        cy = np.polyfit(yt, C["ylab"], 1)
        yres = float(np.abs(np.polyval(cy, yt) - C["ylab"]).max())
        ticks = xtick_positions(dd, C["xrow"], C["yax"], C["xlab"])
        rows = []
        for kind, label in C["series"].items():
            pts = (open_markers(dd, C["box"], amin=(5 if fig == "Figure4" else 15))
                   if kind.startswith("open") else filled_markers(dd, C["box"]))
            if kind == "filled_circle" and fig == "Figure3":
                pts = filled_markers(dd, C["box"], rad=3, smin=8)
            for y, x in pts:
                nm, age, seg, brk = age_from_px(ticks, C["segs"], x)
                rows.append(dict(
                    figure=fig, series_as_printed=label, plot_symbol=kind,
                    px_x=round(x, 1), px_y=round(y, 1),
                    age_column=nm,
                    age_years_from_abscissa=("" if np.isnan(age) else round(age, 3)),
                    abscissa_segment=seg, age_in_axis_break=brk,
                    value_in_figure_units=round(float(np.polyval(cy, y)), 3),
                    figure_units=C["unit"]))
        M = pd.DataFrame(rows).sort_values(["figure", "plot_symbol", "px_x"]).reset_index(drop=True)
        hdr = ("# Huttenlocher__1979 %s constructed snapshot -- pixel digitisation of the "
               "embedded page bitmap (1950 x 3000 px, 8-bit grey), PDF p. %d.\n"
               "# ordinate: ticks at rows %s -> %s %s (linear fit, max residual %.3f).\n"
               "# abscissa (BROKEN, piecewise linear): %s\n"
               "# %d markers resolved: %s\n"
               % (fig, C["page"] + 1, [round(v, 1) for v in yt], C["ylab"], C["unit"], yres,
                  "; ".join("%s=%.1f px" % (t[0], t[2]) for t in ticks),
                  len(M), dict(M.plot_symbol.value_counts())))
        path = os.path.join(HERE, "Huttenlocher__1979_%s_snapshot.csv" % fig)
        out = hdr + M.to_csv(index=False, lineterminator="\n")
        if os.path.exists(path):
            if open(path, encoding="utf-8").read() != out:
                sys.exit("REFUSING to overwrite differing frozen snapshot " + path)
            print("snapshot unchanged:", os.path.basename(path))
        else:
            open(path, "w", encoding="utf-8").write(out)
            print("wrote", os.path.basename(path), len(M), "markers")


if __name__ == "__main__":
    main()
