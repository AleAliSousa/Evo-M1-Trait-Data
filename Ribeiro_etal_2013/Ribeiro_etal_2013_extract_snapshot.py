#!/usr/bin/env python3
"""Build the frozen snapshot of Ribeiro et al. 2013 Table 1 from the article PDF.

Source: Ribeiro, P. F. M., Ventura-Antunes, L., Gabi, M., Mota, B., Grinberg, L. T.,
Farfel, J. M., Ferretti-Rebustini, R. E. L., Leite, R. E. P., Jacob Filho, W., &
Herculano-Houzel, S. (2013). The human cerebral cortex is neither one nor many: neuronal
distribution reveals two quantitatively different zones in the gray matter, three in the
white matter, and explains local variations in cortical folding. Front. Neuroanat. 7:28.
doi:10.3389/fnana.2013.00028
Table 1 "Mean neuronal density, other cell density and other cell/neuron ratio across
cortical regions" is on PDF page 7 (article p. 7).

Why coordinate extraction (__HOWTO_make_a_snapshot.md): the Frontiers text layer stores no
space glyphs ("Table1|Meanneuronaldensity,..."), and inside a cell the digits, the decimal
point, the thousands comma, the "+-" and the significance asterisks are all drawn on
DIFFERENT baselines - "17,742 +- 4,240" arrives as three interleaved text lines. Reading
the page line by line therefore scrambles the numbers. This script instead:

  * groups characters into printed rows by baseline (+-3 pt),
  * orders every character inside a row by x, so "2" "." "2" "9" "1" recomposes as 2.291
    and "4" "," "240" recomposes as 4,240,
  * keeps the trailing significance asterisks (*, **, ***) attached to the printed cell.

Nothing is cleaned here: the caption, the printed header ("Neuronal density +- SE" etc.),
the printed row order (Prefrontal .. V1), the asterisks and the full footnote are kept
exactly as printed. The units (neurons/mg, other cells/mg) are NOT in the printed header -
they are given in the Results text - and are documented in the .R and the README, not
invented into the snapshot.
"""
import os

import pdfplumber
import openpyxl
from openpyxl.styles import Font

HERE = os.path.dirname(os.path.abspath(__file__))
PDF = os.path.join(HERE, "Ribeiro-2013-The human cerebral c.pdf")
OUT = os.path.join(HERE, "Ribeiro_etal_2013_Table1_snapshot.xlsx")

PAGE = 6                     # 0-based; printed article page 7
CAPTION = (483.0, 496.0)     # (top, bottom) crop of the caption line
HEADER = (500.0, 512.0)
BODY = (515.0, 600.0)        # the seven printed data rows
FOOT = (605.0, 640.0)
COLS = [(0, 170), (170, 330), (330, 490), (490, 600)]   # x windows from the header


def bands(chars, tol=3.0):
    out = []
    for c in sorted(chars, key=lambda c: (c["bottom"], c["x0"])):
        if out and c["bottom"] - out[-1][0] < tol:
            out[-1][1].append(c)
        else:
            out.append([c["bottom"], [c]])
    return out


def col_of(c):
    x = (c["x0"] + c["x1"]) / 2.0
    for i, (lo, hi) in enumerate(COLS):
        if lo <= x < hi:
            return i
    return len(COLS) - 1


def render(chars, gap=1.3):
    """Concatenate a cell in x order, restoring the missing word spaces."""
    s, prev = "", None
    for c in sorted(chars, key=lambda c: c["x0"]):
        if prev is not None and c["x0"] - prev["x1"] > gap:
            s += " "
        s += c["text"]
        prev = c
    return s.strip()


def flow(page, box, xtol=1.4):
    t = page.crop((30, box[0], 570, box[1])).extract_text(x_tolerance=xtol) or ""
    return " ".join(t.split())


def main():
    with pdfplumber.open(PDF) as pdf:
        page = pdf.pages[PAGE]
        caption = flow(page, CAPTION)
        footnote = flow(page, FOOT)

        def grid(window):
            rows = []
            for _, cs in bands([c for c in page.chars
                                if window[0] < c["bottom"] < window[1]]):
                parts = [[] for _ in COLS]
                for c in cs:
                    parts[col_of(c)].append(c)
                rows.append([render(p) if p else "" for p in parts])
            return rows

        header = grid(HEADER)
        data = grid(BODY)

    assert len(header) == 1, header
    assert len(data) == 7, "expected 7 printed cortical-region rows, got %d" % len(data)
    assert [r[0] for r in data] == ["Prefrontal", "Frontal", "Temporal", "Insula",
                                    "Parietal", "Posterior", "V1"], [r[0] for r in data]

    wb = openpyxl.Workbook()
    ws = wb.active
    ws.title = "Table1"
    ws.append([caption])
    ws.append(header[0])
    for r in data:
        ws.append(r)
    ws.append([])
    ws.append([footnote])
    for c in ws[2]:
        c.font = Font(bold=True)
    ws.column_dimensions["A"].width = 20
    for col in "BCD":
        ws.column_dimensions[col].width = 26
    wb.save(OUT)
    print("caption :", caption)
    print("header  :", header[0])
    for r in data:
        print("   ", r)
    print("wrote   :", OUT)


if __name__ == "__main__":
    main()
