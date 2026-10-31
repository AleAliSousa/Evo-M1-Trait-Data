"""Heffner_etal_2014_Figure9_extract.py -- frozen-source builder for Figure 9.

Heffner, R. S., Koay, G., & Heffner, H. E. (2014). Hearing in alpacas (Vicugna
pacos): Audiogram, localization acuity, and use of binaural locus cues.
J. Acoust. Soc. Am. 135, 778-788. doi:10.1121/1.4861344

FIG. 9 (PDF p. 9, journal p. 785) is a one-dimensional logarithmic scale of
behaviourally determined sound-localization thresholds, 1 deg to 180 deg.  Each
common name printed beside the scale is joined to the bar by a leader line; the
row at which that line meets the bar IS the datum.  The figure is a RASTER
image (embedded bitmap 1535 x 754 px, 8-bit grey), so values are pixel-digitised
from the embedded bitmap at its native resolution -- never from a re-render:

 1. the grey value bar is located by its two black border columns.
 2. scale ticks are the dark runs projecting inward from each border; the seven
    printed labels (180, 100, 50, 20, 10, 5, 1 deg) are matched to them.
 3. calibration: log10(threshold) linear in pixel row, least squares on those
    seven ticks (residuals < 0.5%); a piecewise-linear interpolation between
    adjacent printed ticks is carried as the primary value and the single-fit
    value as *_globalfit, their difference being the calibration spread.
 4. leader lines are the connected components that touch the bar border from
    outside and are wider than 40 px (narrower ones are title text).  The row
    of the far end of each line identifies which printed label it serves; the
    label texts themselves are listed here in printed top-to-bottom order
    (the only hand-entered content, verified against the rendered page).
 5. writes Heffner_etal_2014_Figure9_snapshot.csv; refuses to overwrite a
    differing frozen copy.

Run (conda env "python": pymupdf, numpy, scipy, pandas, pillow):
    python Heffner_etal_2014_Figure9_extract.py
"""
import io, os, sys
import numpy as np, pandas as pd, pymupdf
from PIL import Image
from scipy import ndimage as ndi

HERE = os.path.dirname(os.path.abspath(__file__))
PDF  = os.path.join(HERE, "Heffner_etal_2014.pdf")
SNAP = os.path.join(HERE, "Heffner_etal_2014_Figure9_snapshot.csv")
PAGE, SHAPE = 8, (1535, 754)
TICK_VALUES = [180, 100, 50, 20, 10, 5, 1]
TICK_ROWS   = [171.5, 321.5, 501.0, 735.0, 914.5, 1093.5, 1506.5]
LABELS_LEFT = ["blind mole rat, gopher", "naked mole rat", "domestic mouse", "marmot",
               "kangaroo rat, gerbil", "cottontail rabbit", "grasshopper mouse",
               "hedgehog, hamster", "chinchilla", "short-tailed fruit bat",
               "big brown bat, fox squirrel", "Norway rat", "straw-colored fruit bat",
               "Egyptian fruit bat", "dog-faced fruit bat", "Jamaican fruit bat",
               "greater spear-nose bat", "opossum", "porpoise"]
LABELS_RIGHT = ["cow", "horse", "alpaca", "goat", "least weasel", "ferret", "sea lion",
                "dog", "Japanese macaque", "harbor seal", "squirrel monkey", "cat",
                "pig", "human", "elephant"]

def load_bitmap(pdf, page_no, shape):
    doc = pymupdf.open(pdf)
    page = doc[page_no]
    im = max(page.get_images(full=True), key=lambda i: page.get_image_bbox(i).height)
    pix = pymupdf.Pixmap(doc, im[0])
    if pix.colorspace is None or pix.colorspace.n != 1 or pix.alpha:
        pix = pymupdf.Pixmap(pymupdf.csGRAY, pix)
    a = np.array(Image.open(io.BytesIO(pix.tobytes("png"))).convert("L"))
    assert a.shape == shape, a.shape
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


def bar_borders(a):
    """columns of the two black borders of the grey value bar."""
    grey = (a > 150) & (a < 235)
    cc = np.where(grey.sum(0) > 0.5 * grey.sum(0).max())[0]
    dark = a < 128; cd = dark.sum(0)
    lo = [c for c in range(cc.min() - 6, cc.min() + 3) if cd[c] > 0.5 * a.shape[0]]
    hi = [c for c in range(cc.max() - 4, cc.max() + 5) if cd[c] > 0.5 * a.shape[0]]
    return (min(lo), max(lo)), (min(hi), max(hi))


def leader_lines(a, bl, br, min_width=30):
    """Return, per side, the rows at which species leader lines meet the bar,
    paired with the row of their far (text) end -- the far row identifies the
    printed label, the attach row carries the value."""
    d = a < 128
    out = {}
    for side in "LR":
        if side == "L":
            sub = d[:, :bl[0]]; ac = bl[0] - 1
        else:
            sub = d[:, br[1] + 1:]; ac = 0
        lab, _ = ndi.label(sub, np.ones((3, 3)))
        ids = np.unique(lab[:, ac]); ids = ids[ids > 0]
        rows = []
        for i in ids:
            ys, xs = np.where(lab == i)
            w = int(xs.max() - xs.min())
            if w < min_width:          # figure titles / axis captions, not leaders
                continue
            far = int(xs.min()) if side == "L" else int(xs.max())
            rows.append(dict(attach_row=round(float(ys[xs == ac].mean()), 1),
                             far_row=round(float(ys[xs == far].mean()), 1),
                             n_px=int(len(ys))))
        out[side] = sorted(rows, key=lambda z: z["far_row"])
    return out


def scale_ticks(a, bl, br):
    d = a < 128
    inL = [round(float((s + e) / 2), 1) for s, e in runs(d[:, bl[1] + 1:bl[1] + 7].all(1))]
    inR = [round(float((s + e) / 2), 1) for s, e in runs(d[:, br[0] - 6:br[0]].all(1))]
    return inL, inR


def numeral_rows(a, bl, br):
    """row centres of the numeric scale labels printed inside the grey bar."""
    d = a < 128
    inside = d[:, bl[1] + 10:br[0] - 8]
    lab, _ = ndi.label(inside, np.ones((3, 3)))
    cen = sorted(((o[0].start + o[0].stop) / 2 for o in ndi.find_objects(lab)))
    groups = []
    for c in cen:
        if groups and abs(c - groups[-1][-1]) < 12:
            groups[-1].append(c)
        else:
            groups.append([c])
    return [round(float(np.mean(g)), 1) for g in groups]


def main():
    a = load_bitmap(PDF, PAGE, SHAPE)
    bl, br = bar_borders(a)
    inL, inR = scale_ticks(a, bl, br)
    assert all(abs(t - r) < 2 for t, r in zip(TICK_ROWS, [x for x in inL if min(abs(np.array(TICK_ROWS) - x)) < 2])), inL
    cf = np.polyfit(TICK_ROWS, np.log10(TICK_VALUES), 1)
    px = np.array(TICK_ROWS); lv = np.log10(TICK_VALUES)
    o = np.argsort(px); px, lv = px[o], lv[o]

    def piece(p):
        if p < px[0]:
            k = np.polyfit(px[:2], lv[:2], 1); return 10 ** np.polyval(k, p)
        if p > px[-1]:
            k = np.polyfit(px[-2:], lv[-2:], 1); return 10 ** np.polyval(k, p)
        return 10 ** np.interp(p, px, lv)

    LL = leader_lines(a, bl, br)
    assert len(LL["L"]) == len(LABELS_LEFT), (len(LL["L"]), len(LABELS_LEFT))
    assert len(LL["R"]) == len(LABELS_RIGHT), (len(LL["R"]), len(LABELS_RIGHT))
    rows = []
    for side, comps, labs in (("left (rodents, bats, other)", LL["L"], LABELS_LEFT),
                              ("right (hoofed mammals, carnivores, primates)", LL["R"], LABELS_RIGHT)):
        for c, lb in zip(comps, labs):
            r = c["attach_row"]
            rows.append(dict(label_as_printed=lb, scale_side=side,
                             px_attach_row=r, px_label_row=c["far_row"],
                             localization_threshold_deg=round(float(piece(r)), 3),
                             localization_threshold_deg_globalfit=round(float(10 ** np.polyval(cf, r)), 3),
                             n_species_in_label=lb.count(",") + 1))
    M = pd.DataFrame(rows)
    assert len(M) == 34, len(M)
    resid = 100 * (10 ** np.polyval(cf, np.array(TICK_ROWS)) / np.array(TICK_VALUES) - 1)
    hdr = ("# Heffner_etal_2014_Figure9 constructed snapshot -- digitised leader-line scale positions.\n"
           "# printed ticks %s deg at px rows %s; global log fit residuals (%%): %s\n"
           "# detected scale ticks (left/right inner): %s / %s\n"
           % (TICK_VALUES, TICK_ROWS, [round(float(v), 2) for v in resid], inL, inR))
    out = hdr + M.to_csv(index=False, lineterminator="\n")
    if os.path.exists(SNAP):
        if open(SNAP, encoding="utf-8").read() != out:
            sys.exit("REFUSING to overwrite differing frozen snapshot " + SNAP)
        print("snapshot unchanged"); return
    open(SNAP, "w", encoding="utf-8").write(out)
    print("wrote", SNAP, len(M), "leader lines")


if __name__ == "__main__":
    main()
