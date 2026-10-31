"""Heffner_etal_2014_Figures10-11_extract.py -- frozen-source builder for Figures 10 and 11.

Heffner, R. S., Koay, G., & Heffner, H. E. (2014). Hearing in alpacas (Vicugna
pacos): Audiogram, localization acuity, and use of binaural locus cues.
J. Acoust. Soc. Am. 135, 778-788. doi:10.1121/1.4861344

The registry treats Figures 10 and 11 as ONE item ("Sound-localization acuity
and functional interaural distance among species using one vs both binaural
locus cues"): the two figures carry the same species roster and the same
left/right cue-use grouping, Fig. 10 on a LINEAR sound-localization-threshold
scale (0-35 deg) and Fig. 11 on a LOGARITHMIC functional-interaural-distance
scale (40-4000 us).

FIG. 10 is PDF p. 10 (journal p. 786), bitmap 1273 x 754 px;
FIG. 11 is PDF p. 11 (journal p. 787), bitmap 1280 x 754 px -- both raster,
so values are pixel-digitised from the embedded bitmaps at native resolution.

Method (identical for both panels):
 1. the grey value bar is located by its two black border columns;
 2. the numeric scale labels printed inside the bar give the calibration rows;
    Fig. 10 is calibrated linearly (residuals < 0.04 deg), Fig. 11 as
    log10(us) linear in row (residuals < 0.35%);
 3. a species leader line is a connected component touching a bar border from
    outside and wider than 30 px (narrower components are caption text);
    the row where it meets the bar is the datum, the row of its far end
    identifies which printed label it serves;
 4. where two labels share one tick the leader lines merge into a single
    component ending at one row -- those species are given the SAME value and
    flagged shares_tick_with.

The printed label texts (top-to-bottom order, verified against the rendered
page) are the only hand-entered content.

Run (conda env "python": pymupdf, numpy, scipy, pandas, pillow):
    python "Heffner_etal_2014_Figures10-11_extract.py"
"""
import io, os, sys
import numpy as np, pandas as pd, pymupdf
from PIL import Image
from scipy import ndimage as ndi

HERE = os.path.dirname(os.path.abspath(__file__))
PDF  = os.path.join(HERE, "Heffner_etal_2014.pdf")
SNAP = os.path.join(HERE, "Heffner_etal_2014_Figures10-11_snapshot.csv")

F10 = dict(page=9, shape=(1273, 754), tick_values=[35, 30, 25, 20, 15, 10, 5, 0],
           left=[["prairie dog"], ["kangaroo rat, gerbil"], ["chinchilla"], ["least weasel"],
                 ["Egyptian fruit bat"], ["Jamaican fruit bat"], ["Japanese macaque"],
                 ["cat"], ["human"]],
           right=[["domestic mouse"], ["cattle"], ["horse"], ["alpaca"], ["hedgehog"],
                  ["spiny mouse"], ["*goat"], ["short-tailed fruit bat"], ["big brown bat"],
                  ["Norway rat"], ["straw-colored fruit bat"], ["dog-faced fruit bat"],
                  ["greater spear-nosed bat"], ["pig"], ["*elephant"]])
F11 = dict(page=10, shape=(1280, 754), tick_values=[4000, 2000, 1000, 800, 400, 200, 100, 80, 40],
           left=[["human"], ["Japanese macaque"], ["cat"], ["chinchilla"],
                 ["Egyptian fruit bat", "prairie dog"], ["kangaroo rat", "Jamaican fruit bat"],
                 ["gerbil"], ["least weasel"]],
           right=[["*elephant"], ["cattle"], ["*goat, horse"], ["alpaca"], ["pig"],
                  ["hedgehog"], ["Norway rat"], ["straw-colored fruit bat"],
                  ["greater spear-nosed bat"], ["dog-faced fruit bat"], ["spiny mouse"],
                  ["domestic mouse"], ["big brown bat"], ["short-tailed fruit bat"]])

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


def leader_lines(a, bl, br, min_width=40):
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


def digitise(spec, figure, quantity, log_scale):
    a = load_bitmap(PDF, spec["page"], spec["shape"])
    bl, br = bar_borders(a)
    nrows = numeral_rows(a, bl, br)
    tv = spec["tick_values"]
    # the numeric labels inside the bar, top to bottom, are the printed scale values;
    # trailing groups below the bar are the figure's axis caption -- drop them.
    cal_rows = nrows[:len(tv)] if len(nrows) >= len(tv) else nrows
    if len(nrows) > len(tv):
        # the first group may be an unlabelled top tick: pick the run of len(tv)
        best, bestres = None, None
        for i in range(0, len(nrows) - len(tv) + 1):
            cand = nrows[i:i + len(tv)]
            y = np.log10(tv) if log_scale else np.array(tv, float)
            res = np.abs(np.polyval(np.polyfit(cand, y, 1), cand) - y).max()
            if bestres is None or res < bestres:
                best, bestres = cand, res
        cal_rows = best
    y = np.log10(tv) if log_scale else np.array(tv, float)
    cf = np.polyfit(cal_rows, y, 1)
    resid = np.polyval(cf, cal_rows) - y
    px = np.array(cal_rows); o = np.argsort(px); pxs, ys = px[o], y[o]

    def piece(p):
        if p < pxs[0]:
            k = np.polyfit(pxs[:2], ys[:2], 1); v = np.polyval(k, p)
        elif p > pxs[-1]:
            k = np.polyfit(pxs[-2:], ys[-2:], 1); v = np.polyval(k, p)
        else:
            v = np.interp(p, pxs, ys)
        return 10 ** v if log_scale else v

    LL = leader_lines(a, bl, br)
    rows = []
    for side, key, grp in (("both cues (left of scale)", "L", spec["left"]),
                           ("only one cue (right of scale)", "R", spec["right"])):
        comps = LL[key]
        assert len(comps) == len(grp), (figure, side, len(comps), len(grp))
        for c, labs in zip(comps, grp):
            r = c["attach_row"]
            for lb in labs:
                rows.append(dict(
                    figure=figure, label_as_printed=lb, cue_group=side,
                    px_attach_row=r, px_label_row=c["far_row"],
                    value=round(float(piece(r)), 3),
                    value_globalfit=round(float((10 ** np.polyval(cf, r)) if log_scale
                                                else np.polyval(cf, r)), 3),
                    quantity=quantity,
                    shares_tick_with="; ".join(x for x in labs if x != lb)))
    return rows, cal_rows, resid


def main():
    r10, c10, e10 = digitise(F10, "Figure 10", "sound_localization_threshold_deg", False)
    r11, c11, e11 = digitise(F11, "Figure 11", "functional_interaural_distance_us", True)
    M = pd.DataFrame(r10 + r11)
    assert len(r10) == 24 and len(r11) == 24, (len(r10), len(r11))
    hdr = ("# Heffner_etal_2014_Figures10-11 constructed snapshot -- digitised leader-line scale positions.\n"
           "# Fig.10 linear scale %s deg at px rows %s; fit residuals (deg): %s\n"
           "# Fig.11 log scale %s us at px rows %s; fit residuals (%%): %s\n"
           % (F10["tick_values"], [round(float(v), 1) for v in c10], [round(float(v), 3) for v in e10],
              F11["tick_values"], [round(float(v), 1) for v in c11],
              [round(float(v), 2) for v in 100 * (10 ** e11 - 1)]))
    out = hdr + M.to_csv(index=False, lineterminator="\n")
    if os.path.exists(SNAP):
        if open(SNAP, encoding="utf-8").read() != out:
            sys.exit("REFUSING to overwrite differing frozen snapshot " + SNAP)
        print("snapshot unchanged"); return
    open(SNAP, "w", encoding="utf-8").write(out)
    print("wrote", SNAP, len(M), "rows")


if __name__ == "__main__":
    main()
