#!/usr/bin/env python3
"""Build the frozen snapshot of the Kazu et al. 2015 CORRIGENDUM Table 1.

Source: Kazu, R. S., Maldonado, J., Mota, B., Manger, P. R., & Herculano-Houzel, S. (2015).
Corrigendum: Cellular scaling rules for the brain of Artiodactyla include a highly folded cortex
with few neurons. Front. Neuroanat. 9:39. doi:10.3389/fnana.2015.00039.
TABLE 1 is reprinted in full on PDF page 2.

This is the CORRECTED reprint of Kazu et al. 2014 Table 1. The corrigendum states the reason:
the hippocampus had been counted into the rest of brain rather than the cerebral cortex in four
species, and omitted entirely for Damaliscus, plus "a few other minor mistakes". The 2014 build
lives in ../Kazu_etal_2014/ and is kept as the historical printing; the cell-by-cell diff between
the two is produced by comparison/Kazu_etal_2015_TABLE1_compare_to_Kazu_2014.R.

Why coordinate extraction (see __HOWTO_make_a_snapshot.md and the sibling 2014 script): the
Frontiers text layer stores no space glyphs ("TABLE1|CellularcompositionofArtiodactylabrains")
and the structure subscripts and power-of-ten exponents are drawn as separate small-font
characters on their own baselines. Read as lines of text, "2.22 x 10^9" and "292.96 x 10^6"
both collapse to indistinguishable strings ending "109" / "106". Everything here is therefore
assembled from character coordinates plus font size.

Font sizes on this page differ from the 2014 article and are set from the page itself:
  * 7.0 pt  full-size characters in plain-number rows
  * 6.8 pt  full-size characters in the exponent rows, and the "~" of "~100"
  * 6.0 pt  SUBSCRIPTS (structure labels) and EXPONENTS (values)
  * 6.5 pt  the legend under the table   * 9.5 pt  the body prose below it
so the full-size threshold is 6.5 pt.

Documented transcription deviations (the only two; everything else is verbatim):
  1. a printed subscript is written inline after "_"   -> M_BD, N_D+BG, O/N_CXT
  2. a printed superscript is written inline after "^" -> "2.22 x 10^9"
Both are reversible by eye against the page. Values, "n.a." cells, the "~100" approximate body
mass, thousands commas, the printed row order and the caption/legend are all kept as printed.
"""
import os
import re

import pdfplumber
import openpyxl
from openpyxl.styles import Font

HERE = os.path.dirname(os.path.abspath(__file__))
PDF = os.path.join(HERE, "Kazu-2015-Corrigendum_ Cellular scaling rules.pdf")
OUT = os.path.join(HERE, "Kazu_etal_2015_TABLE1_snapshot.xlsx")

PAGE = 1                      # 0-based; the corrigendum reprints TABLE 1 on page 2
CAPTION = (60.0, 80.0)        # (top, bottom) crop of the caption line
HEAD = (80.0, 100.0)          # the species header
BODY = (100.0, 560.0)      # the 39 data rows (the last, O/N_OB, sits at bottom 554.4)
FOOT = (560.0, 610.0)      # the legend under the table
BIG = 6.5                     # >= this font size is a full-size character
# x windows, read off the printed columns (label column then five species columns)
COLS = [(0, 110), (110, 200), (200, 300), (300, 400), (400, 490), (490, 600)]


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
    """Read a caption/legend block back into words (no space glyphs in this PDF)."""
    t = page.crop((30, box[0], 570, box[1])).extract_text(x_tolerance=xtol) or ""
    return " ".join(t.split())


def main():
    with pdfplumber.open(PDF) as pdf:
        page = pdf.pages[PAGE]
        caption = flow(page, CAPTION)
        footnote = flow(page, FOOT)

        # The species header cannot be split with COLS: each binomial is CENTRED over its
        # column, so "Sus scrofa domesticus" starts left of the first column boundary and the
        # x-window split cuts names in half ("Sus s" | "crofa domesticus Antid" ...). Split on
        # the gap size instead - between binomials the gap is 15.7-17.8 pt, within a binomial
        # it is 1.95 pt, so any gap over 5 pt is a column break.
        hchars = sorted((c for c in page.chars
                         if HEAD[0] < c["bottom"] < HEAD[1] and c["size"] >= BIG),
                        key=lambda c: c["x0"])
        groups, cur = [], [hchars[0]]
        for prev, c in zip(hchars, hchars[1:]):
            if c["x0"] - prev["x1"] > 5.0:
                groups.append(cur)
                cur = [c]
            else:
                cur.append(c)
        groups.append(cur)
        assert len(groups) == 5, "expected 5 species in the header, got %d" % len(groups)
        header = [""] + [_spaced(g) for g in groups]

        data = []
        for row in bands([c for c in page.chars if BODY[0] < c["bottom"] < BODY[1]]):
            parts = [[] for _ in COLS]
            for c in row["chars"]:
                parts[col_of(c)].append(c)
            cells = [render(p, "label" if i == 0 else "value") if p else ""
                     for i, p in enumerate(parts)]
            if any(cells):
                data.append(cells)

    assert len(data) == 39, "expected 39 printed data rows, got %d" % len(data)
    assert header[1].startswith("Sus scrofa"), header
    for r in data:
        assert r[0], "a data row lost its label: %r" % (r,)
        assert sum(bool(c) for c in r[1:]) == 5, "row %r does not have 5 species cells" % (r[0],)

    wb = openpyxl.Workbook()
    ws = wb.active
    ws.title = "TABLE1"
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
    print("caption :", caption[:100])
    print("header  :", header)
    print("rows    :", len(data))
    for r in data[:4]:
        print("          " + " | ".join("%-12s" % c for c in r))
    print("wrote   :", os.path.basename(OUT))


if __name__ == "__main__":
    main()
