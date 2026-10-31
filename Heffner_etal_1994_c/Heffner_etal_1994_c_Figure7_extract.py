"""Heffner_etal_1994_c_Figure7_extract.py -- frozen-source builder for Figure 7.

Heffner, R. S., Heffner, H. E., Kearns, D., Vogel, J., & Koay, G. (1994).
Sound localization in chinchillas. I: Left/right discriminations.
Hearing Research 80, 247-257. doi:10.1016/0378-5955(94)90116-3

FIG. 7 (PDF p. 8, journal p. 254) has two panels.  The LEFT panel -- the only
one that carries trait values -- plots sound-localization threshold (deg, log)
against interaural distance (us, log) for 29 mammals.  The RIGHT panel plots
the same relation after partialling out the width of the field of best vision,
i.e. residuals, which are derived quantities and are NOT digitised here.

The page is a 200-ppi bilevel SCAN (1700 x 2200 px for the whole page), and in
this figure the two-letter species CODES ARE THE PLOTTED SYMBOLS: a separate
round dot is drawn only where the code had to be displaced to avoid a
collision, and is then joined to its code by a leader line.  Consequently:

 * 13 of the 29 species sit on 8 printed dots (five dots are shared by two
   species each: Gr/K, C/Op, Mk/P, SI/D -- and the Gr/K dot carries leader
   lines to both codes).  Those positions are measured from the dot ink.
 * the other 16 species are located by the ink centroid of their printed code
   inside a hand-read bounding box.  A displaced code can sit up to about one
   character height from its datum: the Sp (spiny mouse) code reads 11.0 deg
   here against the 19.0 deg this paper's own Table 1 prints, so code-anchored
   rows must be treated as approximate positions, not measurements.

Calibration: the left panel's printed ticks are NOT evenly log-spaced on this
scan -- a single log fit to the five abscissa ticks leaves residuals of -10.9%
to +10.5% (the ordinate fits to +-2%).  Primary values therefore use piecewise
log interpolation between adjacent printed ticks and the single-fit values are
carried as *_globalfit; their difference is the calibration spread.

Run (conda env "python": pymupdf, numpy, scipy, pandas, pillow):
    python Heffner_etal_1994_c_Figure7_extract.py
"""
import io, os, sys
import numpy as np, pandas as pd, pymupdf
from PIL import Image
from scipy import ndimage as ndi

HERE = os.path.dirname(os.path.abspath(__file__))
PDF  = os.path.join(HERE, "Heffner_etal_1994_c.pdf")
SNAP = os.path.join(HERE, "Heffner_etal_1994_c_Figure7_snapshot.csv")
PAGE, SHAPE = 7, (2200, 1700)
CROP = (1230, 1720, 200, 1460)        # left-panel working crop (row0,row1,col0,col1)
Y_ROWS = [186.0, 245.5, 316.0, 344.5, 385.5, 414.0]
Y_VALS = [200, 50, 10, 5, 2, 1]
X_COLS = [390.5, 449.8, 514.5, 612.5, 692.5]
X_VALS = [50, 100, 300, 1000, 3000]

# code -> approximate (row, col) of the printed dot, matched to the detected ink
DOTS = {"Mb": (190, 440), "Go": (191, 458), "Gr": (272, 440), "K": (272, 440),
        "Gm": (288, 417), "Rw": (306, 468), "Rd": (311, 479), "C": (341, 516),
        "Op": (341, 516), "Mk": (352, 563), "P": (352, 563), "SI": (324, 551),
        "D": (324, 551)}
# code -> hand-read bounding box (row0, row1, col0, col1) of the printed code
BOXES = {"N": (230, 249, 406, 431), "B": (298, 314, 381, 393), "Sp": (303, 322, 397, 420),
         "W": (302, 317, 422, 440), "Wr": (283, 298, 441, 468), "Hh": (282, 298, 470, 499),
         "Ch": (282, 300, 499, 520), "F": (318, 333, 487, 498), "Gh": (266, 282, 513, 538),
         "S": (360, 375, 538, 550), "Cw": (262, 277, 618, 646), "M": (400, 415, 597, 612),
         "E": (403, 418, 692, 703), "Do": (405, 420, 424, 447),
         "H": (270, 286, 577, 593), "G": (286, 303, 577, 593)}
SHARED = {"Gr": "K", "K": "Gr", "C": "Op", "Op": "C", "Mk": "P", "P": "Mk",
          "SI": "D", "D": "SI"}


def load_bitmap():
    doc = pymupdf.open(PDF); page = doc[PAGE]
    im = page.get_images(full=True)[0]
    pix = pymupdf.Pixmap(doc, im[0])
    if pix.colorspace is None or pix.colorspace.n != 1 or pix.alpha:
        pix = pymupdf.Pixmap(pymupdf.csGRAY, pix)
    a = np.array(Image.open(io.BytesIO(pix.tobytes("png"))).convert("L"))
    assert a.shape == SHAPE, a.shape
    return a[CROP[0]:CROP[1], CROP[2]:CROP[3]]


def main():
    P = load_bitmap(); d = P < 128
    # panel frame: the left panel's ordinate and abscissa
    assert d[:, 372].sum() > 200 and d[434].sum() > 250, "left-panel axes not where expected"

    # dot markers: erosion removes the 2-3 px letter strokes and the leader lines
    full = np.zeros_like(d); full[178:435, 373:714] = d[178:435, 373:714]
    er = ndi.binary_erosion(full, np.ones((3, 3)))
    lab, _ = ndi.label(er, np.ones((3, 3)))
    ids = range(1, lab.max() + 1)
    blobs = [(c, int(s)) for c, s in zip(ndi.center_of_mass(er, lab, ids), ndi.sum(er, lab, ids))
             if s >= 8]

    pxs = np.array(X_COLS); lxs = np.log10(X_VALS)
    pys = np.array(Y_ROWS); lys = np.log10(Y_VALS)
    cfx = np.polyfit(pxs, lxs, 1); cfy = np.polyfit(pys, lys, 1)

    def piece(p, px, lv):
        o = np.argsort(px); px, lv = px[o], lv[o]
        if p < px[0]:
            return 10 ** np.polyval(np.polyfit(px[:2], lv[:2], 1), p)
        if p > px[-1]:
            return 10 ** np.polyval(np.polyfit(px[-2:], lv[-2:], 1), p)
        return 10 ** np.interp(p, px, lv)

    rows = []
    for code, (r0, c0) in DOTS.items():
        cand = [(np.hypot(c[0] - r0, c[1] - c0), c, s) for c, s in blobs]
        dist, (ry, rx), s = min(cand)
        assert dist < 6, (code, dist)
        rows.append((code, "printed dot", round(float(ry), 1), round(float(rx), 1), int(s)))
    for code, (r0, r1, c0, c1) in BOXES.items():
        sub = d[r0:r1, c0:c1]
        ys, xs = np.where(sub)
        assert len(ys) > 20, code
        rows.append((code, "printed code (ink centroid in hand-read box)",
                     round(float(r0 + ys.mean()), 1), round(float(c0 + xs.mean()), 1), int(len(ys))))
    M = pd.DataFrame(rows, columns=["species_code_as_printed", "position_basis",
                                    "px_row", "px_col", "ink_px"])
    assert len(M) == 29, len(M)
    M["interaural_distance_us"] = [round(float(piece(c, pxs, lxs)), 1) for c in M.px_col]
    M["localization_threshold_deg"] = [round(float(piece(r, pys, lys)), 2) for r in M.px_row]
    M["interaural_distance_us_globalfit"] = [round(float(10 ** np.polyval(cfx, c)), 1) for c in M.px_col]
    M["localization_threshold_deg_globalfit"] = [round(float(10 ** np.polyval(cfy, r)), 2) for r in M.px_row]
    M["shares_marker_with"] = [SHARED.get(c, "") for c in M.species_code_as_printed]
    M = M.sort_values("species_code_as_printed").reset_index(drop=True)

    xres = 100 * (10 ** np.polyval(cfx, pxs) / np.array(X_VALS) - 1)
    yres = 100 * (10 ** np.polyval(cfy, pys) / np.array(Y_VALS) - 1)
    hdr = ("# Heffner_etal_1994_c_Figure7 constructed snapshot -- left panel (first-order correlation).\n"
           "# crop of the 200-ppi page scan: rows %d-%d, cols %d-%d.\n"
           "# x ticks %s us at px cols %s; single-log-fit residuals (%%): %s\n"
           "# y ticks %s deg at px rows %s; single-log-fit residuals (%%): %s\n"
           "# 29 species plotted; 13 located on 8 printed dots, 16 by their printed code.\n"
           "# the right panel (residuals after removing field of best vision) is NOT digitised.\n"
           % (CROP[0], CROP[1], CROP[2], CROP[3],
              X_VALS, X_COLS, [round(float(v), 1) for v in xres],
              Y_VALS, Y_ROWS, [round(float(v), 1) for v in yres]))
    out = hdr + M.to_csv(index=False, lineterminator="\n")
    if os.path.exists(SNAP):
        if open(SNAP, encoding="utf-8").read() != out:
            sys.exit("REFUSING to overwrite differing frozen snapshot " + SNAP)
        print("snapshot unchanged"); return
    open(SNAP, "w", encoding="utf-8").write(out)
    print("wrote", SNAP, len(M), "species")


if __name__ == "__main__":
    main()
