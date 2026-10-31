"""Chugani_etal_1987_Figure2_extract.py -- frozen-source builder for FIG 2 (panels A-D).

Chugani, H. T., Phelps, M. E., & Mazziotta, J. C. (1987). Positron emission tomography
study of human brain functional development. Ann. Neurol. 22, 487-497.
doi:10.1002/ana.410220408

FIG 2 (panels A-C on PDF p. 6 = journal p. 492; panel D on PDF p. 7 = journal p. 493)
plots absolute lCMRGlc against age for 13 brain regions.  Caption: "In the infants and
children, points represent individual values of lCMRGlc; in adults, points are mean
values from 7 subjects, in which the size of the symbols equals the standard error of
the mean (also see Table 2)."  So each panel carries, per plotted series, 29 individual
points (the 29 patients of Table 1) plus one adult mean = 30 points.

The PDF pages are 2400 x 3449 px 8-bit grey SCANS (no vector art, no usable text layer
for the figure), so values are pixel-digitised from the embedded bitmap at its native
resolution -- never from a re-render.

  1. per panel, the y-axis is the longest dark column and the x-axis the longest dark
     row inside the panel band.  The ordinate is calibrated two-point: the x-axis row
     is 0 and the top of the y-axis line is 72 umol/min/100 g (the printed ladder runs
     0..72 in steps of 6 with a minor tick every 3).  The abscissa is calibrated by a
     least-squares fit of the regular 1-year ticks (16 of them); age 0 falls on the
     y-axis column.
  2. the four plotting glyphs (filled square, filled circle, open circle, filled
     triangle) are matched by normalised cross-correlation using templates cut from
     clean, isolated data markers of panel A (15x15, 15x15, 15x15 and 13x14 px),
     padded with 3 px of background and with background weighted -1.0 so that extra
     ink next to a glyph is penalised.
  3. detection is SLOT-CONSTRAINED: the abscissa of every point is known in advance,
     because Table 1 prints the age of all 29 patients.  Each (patient age, glyph)
     pair is one slot and may receive at most one detection; the adult means share a
     wide slot to the right of the 16-year tick.  Candidates are taken greedily by
     NCC score with spatial suppression (8 px same glyph, 6 px different glyph).
  4. writes the two frozen snapshots and refuses to overwrite a differing copy:
       Chugani_etal_1987_Figure2A_snapshot.csv     (panel A)
       Chugani_etal_1987_Figure2B-D_snapshot.csv   (panels B, C and D)

NOT every plotted point can be resolved.  Points from the first year of life are
printed on top of one another (7 patients spanning 0.014-0.63 y = 41 px, with 15 px
glyphs), and six patients fall between 6.7 and 7.5 y.  The counts actually resolved are
written into the snapshot header; nothing is interpolated or invented -- an unresolved
point is simply absent, and the item's README and definitions say so.

Run (conda env "python": pymupdf, numpy, scipy, pandas, pillow):
    python Chugani_etal_1987_Figure2_extract.py
"""
import io, os, sys
import numpy as np, pandas as pd, pymupdf
from PIL import Image
from scipy import ndimage as ndi
from scipy.signal import fftconvolve

HERE = os.path.dirname(os.path.abspath(__file__))
PDF  = os.path.join(HERE, "Chugani-1987-Positron emission to.pdf")
SNAP_A  = os.path.join(HERE, "Chugani_etal_1987_Figure2A_snapshot.csv")
SNAP_BD = os.path.join(HERE, "Chugani_etal_1987_Figure2B-D_snapshot.csv")

## the 29 patient ages, in printed order, from Table 1 (days/weeks/months/years as
## printed, converted to years here only to locate the abscissa).
AGES_PRINTED = ["5 days", "5 weeks", "8 weeks", "13.5 weeks", "4 months", "6.25 months",
                "7.6 months", "1 year", "1.5 years", "1.5 years", "1.6 years",
                "3.5 years", "3.7 years", "5.7 years", "6.7 years", "6.8 years",
                "7 years", "7.1 years", "7.2 years", "7.5 years", "8.4 years",
                "8.5 years", "8.6 years", "9.3 years", "9.5 years", "9.8 years",
                "12 years", "13.5 years", "15.1 years"]
def _years(s):
    n, u = s.split(" ")
    n = float(n)
    return {"days": n / 365.25, "weeks": n * 7 / 365.25, "months": n / 12.0,
            "year": n, "years": n}[u]
AGES = [_years(s) for s in AGES_PRINTED]

## panel -> (pdf page index, band of rows to search for the axes).  The bands sit
## strictly inside the full-width horizontal rules that separate the panels, so that
## the longest dark row inside a band is that panel's own abscissa.
PANEL_PAGE = {"A": (5, 320, 1200), "B": (5, 1255, 2150), "C": (5, 2180, 3070),
              "D": (6, 320, 1230)}
## panel -> glyph -> the series label exactly as printed in that panel's key
SERIES = {
    "A": {"square": "Frontal cortex", "circle": "Parietal cortex",
          "open_circle": "Temporal cortex", "triangle": "Occipital cortex"},
    "B": {"square": "Calcarine cortex", "circle": "Sensorimotor cortex",
          "open_circle": "Anterior cingulate cortex",
          "triangle": "Transverse temporal cortex"},
    "C": {"square": "Caudate (head)", "circle": "Lenticular nuclei",
          "triangle": "Thalamus"},
    "D": {"square": "Cerebellar cortex", "circle": "Brainstem"},
}
## template source: panel A, (row, col, height, width) of a clean isolated marker
TEMPLATE_SRC = {"square": (490, 992, 15, 15), "circle": (509, 1172, 15, 15),
                "open_circle": (553, 1085, 15, 15), "triangle": (622, 1513, 13, 14)}
BG, THR, R_SAME, R_DIFF, SLOT_HALF = -1.0, 0.32, 8, 6, 10


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


def panel_cal(d, r0, r1):
    """two-point ordinate calibration + least-squares abscissa fit on the 1-year ticks"""
    band = d[r0:r1]
    yax = int(np.argmax(band.sum(0)))
    y0 = int(np.argmax(band.sum(1))) + r0
    col = d[:, yax - 2:yax + 4].sum(1) >= 2
    segs = [(s, e) for s, e in runs(col) if r0 - 80 <= s and e <= y0 + 8 and e - s > 25]
    ytop = min(s for s, e in segs)
    best = []
    for off in range(2, 10):
        for th in (2, 3):
            m = d[y0 + off:y0 + off + 5, :].sum(0)
            t = [(s + e) / 2 for s, e in runs(m >= th)
                 if yax + 30 < (s + e) / 2 < yax + 16 * 68 + 40]
            if len(t) > len(best):
                best = t
    keep = [(round((v - yax) / 67.0), v) for v in best]
    keep = [(i, v) for i, v in keep if 1 <= i <= 16 and abs((v - yax) / 67.0 - i) < 0.25]
    A = np.polyfit([v for i, v in keep], [i for i, v in keep], 1)
    return dict(yax=yax, y0row=y0, ytop=ytop, ppy=1 / A[0], x0=-A[1] / A[0],
                n_xticks=len(keep))


def build_templates(d):
    T = {}
    for k, (r, c, h, w) in TEMPLATE_SRC.items():
        t = d[r:r + h, c:c + w].astype(float)
        out = np.zeros((h + 6, w + 6)); out[3:3 + h, 3:3 + w] = t
        T[k] = out
    return T


def slot_detect(region, templ, slots):
    maps = {}
    for k, t in templ.items():
        t0 = t.copy(); t0[t0 == 0] = BG; t0 -= t0.mean()
        maps[k] = fftconvolve(region.astype(float), t0[::-1, ::-1], mode="same") / float((t * t0).sum())
    cands = []
    for k, S in maps.items():
        mx = ndi.maximum_filter(S, size=5)
        ys, xs = np.where((S == mx) & (S >= THR))
        for y, x, v in zip(ys, xs, S[ys, xs]):
            for lbl, xc, hw in slots:
                if abs(x - xc) <= hw:
                    cands.append((float(v), k, int(y), int(x), lbl))
    cands.sort(reverse=True)
    taken, pts = set(), []
    for v, k, y, x, lbl in cands:
        if (lbl, k) in taken:
            continue
        if any(np.hypot(y - yy, x - xx) < (R_SAME if kk == k else R_DIFF)
               for _, kk, yy, xx, _ in pts):
            continue
        taken.add((lbl, k)); pts.append((v, k, y, x, lbl))
    return pts


def run_panel(doc, nm, templ, pages):
    pg, r0, r1 = PANEL_PAGE[nm]
    d = pages[pg] < 128
    c = panel_cal(d, r0, r1)
    reg = np.zeros_like(d)
    reg[c["ytop"] + 2:c["y0row"] - 2, c["yax"] + 5:c["yax"] + 1500] = \
        d[c["ytop"] + 2:c["y0row"] - 2, c["yax"] + 5:c["yax"] + 1500]
    reg[c["ytop"] - 12:c["ytop"] + 155, c["yax"] + 850:] = False      # the panel key
    T = {k: templ[k] for k in SERIES[nm]}
    slots = [("P%02d" % (i + 1), c["x0"] + a * c["ppy"], SLOT_HALF) for i, a in enumerate(AGES)]
    slots += [("Adult", c["x0"] + 17.5 * c["ppy"], 55)]
    rows = []
    for v, k, y, x, lbl in slot_detect(reg, T, slots):
        rows.append(dict(
            panel=nm, series_as_printed=SERIES[nm][k], plot_symbol=k,
            subject_slot=lbl,
            age_as_printed_Table1=("adult group" if lbl == "Adult"
                                   else AGES_PRINTED[int(lbl[1:]) - 1]),
            px_x=x, px_y=y,
            age_years_from_abscissa=round((x - c["x0"]) / c["ppy"], 3),
            lCMRGlc_umol_min_100g=round(72.0 * (c["y0row"] - y) / (c["y0row"] - c["ytop"]), 2),
            ncc=round(v, 3)))
    M = pd.DataFrame(rows).sort_values(["panel", "px_x", "px_y"]).reset_index(drop=True)
    return M, c


def write_frozen(path, frame, header):
    out = header + frame.to_csv(index=False, lineterminator="\n")
    if os.path.exists(path):
        if open(path, encoding="utf-8").read() != out:
            sys.exit("REFUSING to overwrite differing frozen snapshot " + path)
        print("snapshot unchanged:", os.path.basename(path)); return
    open(path, "w", encoding="utf-8").write(out)
    print("wrote", os.path.basename(path), len(frame), "points")


def main():
    doc = pymupdf.open(PDF)
    pages = {i: page_bitmap(doc, i) for i in (5, 6)}
    templ = build_templates(pages[5] < 128)
    frames, cals = {}, {}
    for nm in ("A", "B", "C", "D"):
        frames[nm], cals[nm] = run_panel(doc, nm, templ, pages)

    def hdr(names):
        n_exp = sum(len(SERIES[n]) * 30 for n in names)
        n_got = sum(len(frames[n]) for n in names)
        L = ["# Chugani_etal_1987 FIG 2 constructed snapshot -- pixel digitisation of the "
             "embedded page bitmaps (2400 x 3449 px, 8-bit grey), panel(s) %s.\n" % ", ".join(names),
             "# Each series carries 29 individual patients (Table 1) + 1 adult mean = 30 "
             "plotted points; %d points are plotted in total and %d were individually "
             "resolved.\n" % (n_exp, n_got),
             "# Unresolved points are ABSENT (never interpolated): they lie in the "
             "birth-to-1-year cluster and the 6.7-7.5 y cluster, where glyphs overprint.\n"]
        for n in names:
            c = cals[n]
            L.append("# panel %s calibration: y-axis col %d = age 0; x-axis row %d = 0 "
                     "umol/min/100 g; y-axis top row %d = 72; %.3f px/year (fit on %d "
                     "1-year ticks); points resolved %d of %d.\n"
                     % (n, c["yax"], c["y0row"], c["ytop"], c["ppy"], c["n_xticks"],
                        len(frames[n]), len(SERIES[n]) * 30))
        return "".join(L)

    write_frozen(SNAP_A, frames["A"], hdr(["A"]))
    BD = pd.concat([frames[n] for n in ("B", "C", "D")], ignore_index=True)
    write_frozen(SNAP_BD, BD, hdr(["B", "C", "D"]))


if __name__ == "__main__":
    main()
