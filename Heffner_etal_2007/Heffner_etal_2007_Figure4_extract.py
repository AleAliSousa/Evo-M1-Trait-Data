"""Heffner_etal_2007_Figure4_extract.py -- frozen-source builder for Figure 4.

Heffner, R. S., Koay, G., & Heffner, H. E. (2007). Sound-localization acuity
and its relation to vision in large and small fruit-eating bats: I.
Echolocating species, Phyllostomus hastatus and Carollia perspicillata.
Hearing Research 234, 1-9. doi:10.1016/j.heares.2007.06.001

FIG. 4 (PDF p. 6, journal p. 6) shows retinal ganglion-cell isodensity contours
for P. hastatus (left panel) and C. perspicillata (right panel), shaded in
three steps (>=25% light grey, >=50% mid grey, >=75% black of maximum density)
with a 1 mm scale bar under each panel.  The figure has NO axes: it is
digitised by SCALE-BAR PLANIMETRY, which is the only quantitative content the
panel carries.

The figure is a RASTER image (embedded bitmap 444 x 906 px, 8-bit grey), so
areas are measured on the embedded bitmap at native resolution:

 1. the two scale bars are the only black components wider than 60 px and no
    more than 14 px tall; each is 1 mm, giving the panel's mm/px.
 2. the retina is the largest non-white connected component of the panel with
    its interior filled; its grey levels partition it into the >=25% (light),
    >=50% (mid) and >=75% (black) zones.
 3. the >=75% field of best vision is taken as the black components lying
    strictly inside the retina (erosion by 7 px removes the outline stroke)
    and larger than 300 px, which also excludes the black "25%"/"50%"/"OD"
    lettering.
 4. writes Heffner_etal_2007_Figure4_snapshot.csv; refuses to overwrite a
    differing frozen copy.

Run (conda env "python": pymupdf, numpy, scipy, pandas, pillow):
    python Heffner_etal_2007_Figure4_extract.py
"""
import io, os, sys
import numpy as np, pandas as pd, pymupdf
from PIL import Image
from scipy import ndimage as ndi

HERE = os.path.dirname(os.path.abspath(__file__))
PDF  = os.path.join(HERE, "Heffner_etal_2007.pdf")
SNAP = os.path.join(HERE, "Heffner_etal_2007_Figure4_snapshot.csv")
PAGE, SHAPE, SPLIT = 5, (444, 906), 460
PANELS = [("Phyllostomus hastatus", "Greater spear-nosed bat", 0, SPLIT),
          ("Carollia perspicillata", "Short-tail fruit bat", SPLIT, 906)]


def load_bitmap():
    doc = pymupdf.open(PDF); page = doc[PAGE]
    im = page.get_images(full=True)[0]
    pix = pymupdf.Pixmap(doc, im[0])
    if pix.colorspace is None or pix.colorspace.n != 1 or pix.alpha:
        pix = pymupdf.Pixmap(pymupdf.csGRAY, pix)
    a = np.array(Image.open(io.BytesIO(pix.tobytes("png"))).convert("L"))
    assert a.shape == SHAPE, a.shape
    return a


def scale_bars(a):
    blk = a < 60
    lab, _ = ndi.label(blk, np.ones((3, 3)))
    out = []
    for i, o in enumerate(ndi.find_objects(lab), 1):
        h = o[0].stop - o[0].start; w = o[1].stop - o[1].start
        if w > 60 and h <= 14:
            out.append((int(o[1].start), int(o[1].stop), w))
    assert len(out) == 2, out
    return sorted(out)


def main():
    a = load_bitmap()
    bars = scale_bars(a)
    rows = []
    for (species, common, c0, c1), bar in zip(PANELS, bars):
        A = a[90:436, c0:c1]
        nw = A < 248
        lab, _ = ndi.label(nw, np.ones((3, 3)))
        s = ndi.sum(nw, lab, range(1, lab.max() + 1))
        region = ndi.binary_fill_holes(lab == int(np.argmax(s)) + 1)
        inner = ndi.binary_erosion(region, np.ones((7, 7)))
        g25 = (A >= 220) & (A <= 245) & region
        g50 = (A >= 170) & (A <= 200) & region
        b = (A < 60) & inner
        lb, _ = ndi.label(b, np.ones((3, 3)))
        sz = ndi.sum(b, lb, range(1, lb.max() + 1))
        z75 = np.isin(lb, [i + 1 for i, v in enumerate(sz) if v > 300])
        mm = 1.0 / bar[2]
        tot, a25, a50, a75 = region.sum(), g25.sum(), g50.sum(), z75.sum()
        ys, xs = np.where(region); yz, xz = np.where(z75)
        rows.append(dict(
            species_as_printed=species, common_name_as_printed=common,
            scale_bar_px=bar[2], mm_per_px=round(mm, 6),
            retina_outline_area_mm2=round(tot * mm ** 2, 3),
            area_ge25pct_mm2=round((a25 + a50 + a75) * mm ** 2, 3),
            area_ge50pct_mm2=round((a50 + a75) * mm ** 2, 3),
            area_ge75pct_mm2=round(a75 * mm ** 2, 3),
            pct_retina_ge50=round(100 * (a50 + a75) / tot, 1),
            pct_retina_ge75=round(100 * a75 / tot, 1),
            nasotemporal_extent_mm=round((xs.max() - xs.min() + 1) * mm, 3),
            superoinferior_extent_mm=round((ys.max() - ys.min() + 1) * mm, 3),
            fbv75_nasotemporal_extent_mm=round((xz.max() - xz.min() + 1) * mm, 3),
            fbv75_superoinferior_extent_mm=round((yz.max() - yz.min() + 1) * mm, 3),
            px_retina=int(tot), px_ge25_only=int(a25), px_ge50_only=int(a50), px_ge75=int(a75),
            n_fbv75_components=int(len(np.unique(lb[z75])))))
    M = pd.DataFrame(rows)
    hdr = ("# Heffner_etal_2007_Figure4 constructed snapshot -- scale-bar planimetry of the\n"
           "# retinal ganglion-cell isodensity contours (no axes in the figure).\n"
           "# 1 mm scale bars measured at %d px (left panel) and %d px (right panel).\n"
           % (bars[0][2], bars[1][2]))
    out = hdr + M.to_csv(index=False, lineterminator="\n")
    if os.path.exists(SNAP):
        if open(SNAP, encoding="utf-8").read() != out:
            sys.exit("REFUSING to overwrite differing frozen snapshot " + SNAP)
        print("snapshot unchanged"); return
    open(SNAP, "w", encoding="utf-8").write(out)
    print("wrote", SNAP, len(M), "panels")


if __name__ == "__main__":
    main()
