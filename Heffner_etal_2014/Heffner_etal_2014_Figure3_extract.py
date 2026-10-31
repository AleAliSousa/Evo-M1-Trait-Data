"""Heffner_etal_2014_Figure3_extract.py -- frozen-source builder for Figure 3.

Heffner, R. S., Koay, G., & Heffner, H. E. (2014). Hearing in alpacas (Vicugna
pacos): Audiogram, localization acuity, and use of binaural locus cues.
J. Acoust. Soc. Am. 135, 778-788. doi:10.1121/1.4861344

FIG. 3 (PDF p. 5, journal p. 782) plots the auditory detection thresholds of
three alpacas.  The plotted symbols ARE the letters A, B and C (one per
individual); the solid grey line is the mean.  The figure is a RASTER image
(embedded bitmap 682 x 1015 px, 8-bit grey; no vector paths), so values are
pixel-digitised from the embedded bitmap at its native resolution -- never from
a re-render:

 1. axis lines  = the longest fully dark column / row.  Ticks = dark runs just
    outside them.  y ticks carry the printed labels 80..0 dB SPL (step 10);
    x ticks are the 14 printed test frequencies.
 2. calibration: y linear in dB (least squares on the nine detected ticks);
    x linear in log10(frequency).  NOTE the tick printed "20" sits at the
    log position of 22.5 kHz (residual 0.07% against 22.5 vs 10.4% against 20),
    and the Results text names 22.5 kHz as a test frequency -- the snapshot
    freezes BOTH the printed label and the position-implied value and the
    discrepancy is recorded as erratum Heffner_etal_2014-E001.
 3. letters: connected components of the dark mask inside the plot frame,
    excluding the title band; components taller than 24 px are two stacked
    letters and wider than 22 px are two side-by-side letters, split at the
    glyph height/width (17 / 15 px).  Each box is then identified as A, B or C
    by normalised cross-correlation against exemplars cut from the uncrowded
    1 kHz cluster.  Exactly 42 letters are required (14 frequencies x 3 bats).
 4. writes Heffner_etal_2014_Figure3_snapshot.csv and refuses to overwrite a
    differing frozen copy.

Run (conda env "python": pymupdf, numpy, scipy, pandas, pillow):
    python Heffner_etal_2014_Figure3_extract.py
"""
import io, os, sys
import numpy as np, pandas as pd, pymupdf
from PIL import Image
from scipy import ndimage as ndi
from scipy.signal import fftconvolve

HERE = os.path.dirname(os.path.abspath(__file__))
PDF  = os.path.join(HERE, "Heffner_etal_2014.pdf")
SNAP = os.path.join(HERE, "Heffner_etal_2014_Figure3_snapshot.csv")
PAGE = 5                       # PDF page 6, journal p. 782
FREQ_PRINTED = [.025, .032, .063, .125, .250, .500, 1, 2, 4, 8, 16, 20, 32, 40]
FREQ_POSITION = [.025, .032, .063, .125, .250, .500, 1, 2, 4, 8, 16, 22.5, 32, 40]
Y_TICKS = [80, 70, 60, 50, 40, 30, 20, 10, 0]


def load_bitmap():
    doc = pymupdf.open(PDF)
    page = doc[PAGE]
    im = min(page.get_images(full=True), key=lambda i: page.get_image_bbox(i).x0)
    pix = pymupdf.Pixmap(doc, im[0])
    if pix.colorspace is None or pix.colorspace.n != 1 or pix.alpha:
        pix = pymupdf.Pixmap(pymupdf.csGRAY, pix)
    a = np.array(Image.open(io.BytesIO(pix.tobytes("png"))).convert("L"))
    assert a.shape == (682, 1015), a.shape
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


def main():
    a = load_bitmap(); dark = a < 100
    yaxis = int(np.argmax(dark.sum(0)))          # 95
    xaxis = int(np.argmax(dark.sum(1)))          # 596
    yt = [(s + e) / 2 for s, e in runs(dark[:, yaxis - 10:yaxis - 2].all(1))]
    xt = [(s + e) / 2 for s, e in runs(dark[xaxis + 1:xaxis + 9, :].all(0))]
    assert len(yt) == 9 and len(xt) == 14, (len(yt), len(xt))
    cfy = np.polyfit(yt, Y_TICKS, 1)
    cfx_pos = np.polyfit(xt, np.log10(FREQ_POSITION), 1)
    cfx_lab = np.polyfit(xt, np.log10(FREQ_PRINTED), 1)

    # letter exemplars from the uncrowded 1 kHz cluster
    tA = dark[480:497, 531:547].astype(float)
    tB = dark[485:502, 547:561].astype(float)
    tC = dark[480:498, 560:575].astype(float)

    def ncc(img, t):
        t0 = t.copy(); t0[t0 == 0] = -0.35; t0 -= t0.mean()
        return fftconvolve(img, t0[::-1, ::-1], mode="same") / np.sqrt((t0 ** 2).sum())

    mask = np.zeros_like(dark); mask[12:594, 98:1014] = dark[12:594, 98:1014]
    mask[10:30, 380:690] = False                                   # figure title
    lab, _ = ndi.label(mask, np.ones((3, 3)))
    boxes = []
    for i, o in enumerate(ndi.find_objects(lab), 1):
        h = o[0].stop - o[0].start; w = o[1].stop - o[1].start
        if int((lab[o] == i).sum()) < 50 or not (13 <= h <= 40 and 8 <= w <= 45):
            continue
        nrow = 2 if h > 24 else 1; ncol = 2 if w > 22 else 1
        for ri in range(nrow):
            for ci in range(ncol):
                r0 = o[0].start + ri * (h - 17) if nrow == 2 else o[0].start
                r1 = r0 + 17 if nrow == 2 else o[0].stop
                c0 = o[1].start + ci * (w - 15) if ncol == 2 else o[1].start
                c1 = c0 + 15 if ncol == 2 else o[1].stop
                boxes.append((r0, r1, c0, c1, nrow * ncol > 1))
    rows = []
    xt_arr = np.array(xt)
    for r0, r1, c0, c1, merged in boxes:
        sub = dark[max(0, r0 - 4):r1 + 4, max(0, c0 - 4):c1 + 4].astype(float)
        sc = {k: float(ncc(sub, t).max()) for k, t in (("A", tA), ("B", tB), ("C", tC))}
        letter = max(sc, key=sc.get)
        xc, yc = (c0 + c1) / 2, (r0 + r1) / 2
        j = int(np.argmin(abs(xt_arr - xc)))
        rows.append(dict(
            frequency_index=j,
            frequency_kHz_printed_label=FREQ_PRINTED[j],
            animal_letter=letter,
            px_x=round(xc, 1), px_y=round(yc, 1),
            threshold_dB_SPL=round(float(np.polyval(cfy, yc)), 2),
            frequency_kHz_from_tick_position=round(float(10 ** np.polyval(cfx_pos, xt[j])), 3),
            frequency_kHz_from_printed_labels=round(float(10 ** np.polyval(cfx_lab, xt[j])), 3),
            glyph_was_merged="yes" if merged else "no",
            ncc_A=round(sc["A"], 2), ncc_B=round(sc["B"], 2), ncc_C=round(sc["C"], 2)))
    M = pd.DataFrame(rows).sort_values(["frequency_index", "animal_letter"]).reset_index(drop=True)
    assert len(M) == 42, f"expected 42 letters (14 frequencies x 3 animals), found {len(M)}"
    assert (M.groupby("frequency_index").size() == 3).all()
    # 60-dB arrows: the two long dark columns inside the plot frame
    cols = dark[:, 100:1010].sum(0)
    arrow_px = sorted(int(c + 100) for c in np.argsort(cols)[-2:])
    M.attrs = {}
    hdr = ("# Heffner_etal_2014_Figure3 constructed snapshot -- digitised letter markers.\n"
           "# y ticks (px): %s -> %s dB SPL; x ticks (px): %s\n"
           "# 60-dB arrows at px columns %s -> %s kHz (text: 0.040 and 32.8 kHz)\n"
           % ([round(float(v), 1) for v in yt], Y_TICKS, [round(float(v), 1) for v in xt],
              arrow_px, [round(float(10 ** np.polyval(cfx_pos, c)), 3) for c in arrow_px]))
    out = hdr + M.to_csv(index=False, lineterminator="\n")
    if os.path.exists(SNAP):
        if open(SNAP, encoding="utf-8").read() != out:
            sys.exit("REFUSING to overwrite differing frozen snapshot " + SNAP)
        print("snapshot unchanged"); return
    open(SNAP, "w", encoding="utf-8").write(out)
    print("wrote", SNAP, len(M), "letters")


if __name__ == "__main__":
    main()
