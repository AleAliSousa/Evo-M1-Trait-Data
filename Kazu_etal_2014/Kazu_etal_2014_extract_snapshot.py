#!/usr/bin/env python3
"""Build the frozen snapshot of Kazu et al. 2014 Table 1 from the article PDF.

Source: Kazu, R. S., Maldonado, J., Mota, B., Manger, P. R., & Herculano-Houzel, S.
(2014). Cellular scaling rules for the brain of Artiodactyla include a highly folded
cortex with few neurons. Front. Neuroanat. 8:128. doi:10.3389/fnana.2014.00128
Table 1 "Cellular composition of Artiodactyla brains" is on PDF page 5 (article p. 5).

Why coordinate extraction (__HOWTO_make_a_snapshot.md): the Frontiers text layer carries
no space glyphs ("Table1|CellularcompositionofArtiodactylabrains") and the structure
subscripts / power-of-ten exponents are drawn as separate small-font characters on their
own baselines. Reading the page as lines of text silently glues "10" to its exponent, so
"2.22 x 10^9" and "292.96 x 10^6" become indistinguishable strings "...109" / "...106".
Everything here is therefore assembled from character coordinates + font size:

  * rows      = bands of full-size (>= 7.2 pt) characters, +-3 pt
  * columns   = fixed x windows read off the printed header
  * small     = size < 7.2 pt; in the label column these are STRUCTURE SUBSCRIPTS,
                in the value columns they are POWER-OF-TEN EXPONENTS

Documented transcription deviations (the only two; everything else is verbatim):
  1. a printed subscript is written inline after "_"   -> M_BD,  N_D+BG,  O/N_CXT
  2. a printed superscript is written inline after "^" -> "2.22 x 10^9"
Both are reversible and can be eyeballed against the page. Values, "n.a." cells, the
"~100" approximate body mass, the thousands commas, the printed row order and the
caption/footnote are all kept exactly as printed. NO correction is applied here - in
particular the values are the ORIGINAL 2014 printing, not the 2015 corrigendum
(doi:10.3389/fnana.2015.00039); see Kazu_etal_2014_Table1.README.md.
"""
import os
import re

import pdfplumber
import openpyxl
from openpyxl.styles import Font

HERE = os.path.dirname(os.path.abspath(__file__))
PDF = os.path.join(HERE, "Kazu-2014-Cellular scaling rules for the brain.pdf")
OUT = os.path.join(HERE, "Kazu_etal_2014_Table1_snapshot.xlsx")

PAGE = 4                      # 0-based; printed article page 5
BODY = (128.0, 675.0)         # bottom-coordinate window of the 39 data rows
HEAD = (100.0, 125.0)         # the two-line species header
CAPTION = (70.0, 95.0)        # (top, bottom) crop of the caption line
FOOT = (676.0, 745.0)         # (top, bottom) crop of the legend under the table
BIG = 7.2                     # >= this font size is a full-size character
# x windows, read off the printed header (label column then five species columns)
COLS = [(0, 120), (120, 205), (205, 293), (293, 393), (393, 480), (480, 600)]


def bands(chars, tol=3.0):
    """Group full-size chars into printed rows, then attach the small chars."""
    big = sorted((c for c in chars if c["size"] >= BIG), key=lambda c: c["bottom"])
    out = []
    for c in big:
        if out and c["bottom"] - out[-1]["b"] < tol:
            out[-1]["chars"].append(c)
        else:
            out.append({"b": c["bottom"], "chars": [c]})
    for row in out:
        row["b"] = min(x["bottom"] for x in row["chars"])
    for c in chars:
        if c["size"] >= BIG:
            continue
        near = min(out, key=lambda r: abs(c["bottom"] - r["b"]))
        if abs(c["bottom"] - near["b"]) < 7.0:     # subscripts/exponents sit within 7 pt
            near["chars"].append(c)
    return out


def col_of(c):
    x = (c["x0"] + c["x1"]) / 2.0
    for i, (lo, hi) in enumerate(COLS):
        if lo <= x < hi:
            return i
    return len(COLS) - 1


def _spaced(chars, gap=1.3):
    """Join full-size chars, restoring the word spaces the text layer does not store."""
    s = ""
    prev = None
    for c in sorted(chars, key=lambda c: c["x0"]):
        if prev is not None and c["x0"] - prev["x1"] > gap:
            s += " "
        s += c["text"]
        prev = c
    return s


def render(chars, mode):
    """mode: 'label' (subscripted row name) | 'text' (header) | 'value' (data cell)."""
    big = [c for c in chars if c["size"] >= BIG]
    small = [c for c in chars if c["size"] < BIG]
    if mode == "text":
        return _spaced(big)
    if mode == "value":
        s = "".join(c["text"] for c in sorted(big, key=lambda c: c["x0"]))
        if small:                                    # power-of-ten exponent
            s += "^" + "".join(c["text"] for c in sorted(small, key=lambda c: c["x0"]))
        s = s.replace("×", " × ")                    # "2.22x10^9" -> "2.22 x 10^9"
        return re.sub(r"\s+", " ", s).strip()
    # label: base symbol, subscript run, then the printed unit
    if not small:
        return _spaced(big)
    x_lo = min(c["x0"] for c in small)
    x_hi = max(c["x1"] for c in small)
    base = _spaced([c for c in big if c["x1"] <= x_lo + 0.5])
    rest = _spaced([c for c in big if c["x0"] >= x_hi - 0.5])
    sub = "".join(c["text"] for c in sorted(small, key=lambda c: c["x0"]))
    return (base + "_" + sub + rest).strip()


def flow(page, box, xtol=1.4):
    """Read a caption/footnote block back into words (no space glyphs in this PDF)."""
    t = page.crop((30, box[0], 570, box[1])).extract_text(x_tolerance=xtol) or ""
    return " ".join(t.split())


def main():
    with pdfplumber.open(PDF) as pdf:
        page = pdf.pages[PAGE]
        caption = flow(page, CAPTION)
        footnote = flow(page, FOOT)

        header = [[] for _ in COLS]
        for row in bands([c for c in page.chars if HEAD[0] < c["bottom"] < HEAD[1]]):
            parts = [[] for _ in COLS]
            for c in row["chars"]:
                parts[col_of(c)].append(c)
            for i, p in enumerate(parts):
                if p:
                    header[i].append(render(p, "label" if i == 0 else "text"))
        header = [" ".join(h) for h in header]

        data = []
        for row in bands([c for c in page.chars if BODY[0] < c["bottom"] < BODY[1]]):
            parts = [[] for _ in COLS]
            for c in row["chars"]:
                parts[col_of(c)].append(c)
            cells = [render(p, "label" if i == 0 else "value") if p else "" for i, p in enumerate(parts)]
            if any(cells):
                data.append(cells)

    assert len(data) == 39, "expected 39 printed data rows, got %d" % len(data)
    assert header[1].startswith("Sus scrofa"), header

    wb = openpyxl.Workbook()
    ws = wb.active
    ws.title = "Table1"
    ws.append([caption])
    ws.append(header)
    for r in data:
        ws.append(r)
    ws.append([])
    ws.append([footnote])
    for c in ws[2]:
        c.font = Font(bold=True)
    ws.column_dimensions["A"].width = 16
    for col in "BCDEF":
        ws.column_dimensions[col].width = 22
    wb.save(OUT)
    print("caption :", caption)
    print("header  :", header)
    print("rows    :", len(data))
    print("wrote   :", OUT)


if __name__ == "__main__":
    main()
