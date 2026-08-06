#!/usr/bin/env python3
"""Build the five frozen snapshots of Changizi & Shimojo (2005) from the PDF.

    Changizi, M.A. & Shimojo, S. (2005) Parcellation and area-area connectivity as a
    function of neocortex size. Brain Behav Evol 66(2):88-98. doi:10.1159/000085942

Why word coordinates and not extract_text()
-------------------------------------------
The article is a TWO-COLUMN journal page and tables 2-5 sit in one column while body
prose runs down the other.  pdfplumber's line-based `extract_text()` therefore emits
table rows *interleaved* with sentences of prose, and - worse - it collapses the blank
cells, so a row that prints values only in V1/A1/S1 comes out looking like a row of
three consecutive numbers.  In table 2 the blanks are the whole point (a shifted row
silently turns an A1 value into an M1 value), so every cell here is placed by its
x-position: each column is a fixed x-window read off the header, and a word lands in
the column whose window contains its horizontal centre.  A column with no word in a
given row stays empty, which is exactly what the page shows.

Output (one workbook per printed table, journal-faithful, nothing cleaned)
    Changizi_Shimojo_2005_Table1_snapshot.xlsx   sheet "Table1"   19 animals
    Changizi_Shimojo_2005_Table2_snapshot.xlsx   sheet "Table2"   16 animals
    Changizi_Shimojo_2005_Table3_snapshot.xlsx   sheet "Table3"   10 subnetworks
    Changizi_Shimojo_2005_Table4_snapshot.xlsx   sheet "Table4"   38 area rows
    Changizi_Shimojo_2005_Table5_snapshot.xlsx   sheet "Table5"   11 animals

Each workbook holds: row 1 = the printed caption, then the printed header stack (one
worksheet row per printed header line), then the data rows in printed order with blank
cells left blank, then the printed footnote.  No renaming, no unit conversion, no
species harmonisation - all of that happens in Changizi_Shimojo_2005_Table<N>.R.

Run:  python3 Changizi_Shimojo_2005_extract_snapshot.py
"""

import os
import re
import sys

import pdfplumber
from openpyxl import Workbook

HERE = os.path.dirname(os.path.abspath(__file__))
PDF = os.path.join(HERE, "changizi_shimojo_2005.pdf")

# --------------------------------------------------------------------------- #
# generic helpers
# --------------------------------------------------------------------------- #

# The PDF text layer breaks the fi/fl ligatures into a free-standing "fi"/"fl"
# followed by the rest of the word ("fl attened", "fi gure", "fi fth").  The page
# itself shows the ligature, so re-joining restores what is printed.  Applied to
# captions/footnotes only; no data cell contains a ligature.
_LIG = re.compile(r"\b(ffi|ff|fi|fl)\s+(?=[a-z])")


def deligature(s):
    return _LIG.sub(r"\1", s)


def lines_of(page, x_lo=None, x_hi=None, top_lo=None, top_hi=None, tol=3.0):
    """Words of `page` inside the box, clustered into printed lines by `top`."""
    ws = []
    for w in page.extract_words():
        if x_lo is not None and w["x0"] < x_lo:
            continue
        if x_hi is not None and w["x0"] > x_hi:
            continue
        if top_lo is not None and w["top"] < top_lo:
            continue
        if top_hi is not None and w["top"] > top_hi:
            continue
        ws.append(w)
    ws.sort(key=lambda w: (w["top"], w["x0"]))
    out = []
    for w in ws:
        if out and w["top"] - out[-1][0] < tol:
            out[-1][1].append(w)
        else:
            out.append([w["top"], [w]])
    for top, group in out:
        group.sort(key=lambda w: w["x0"])
    return out


def to_cells(group, cols):
    """Place each word in the column whose x-window holds the word's centre.

    `cols` = [(name, x_lo, x_hi), ...].  Returns a list of strings, one per column,
    "" where the printed table shows nothing.
    """
    cells = ["" for _ in cols]
    for w in group:
        mid = (w["x0"] + w["x1"]) / 2.0
        for i, (_, lo, hi) in enumerate(cols):
            if lo <= mid < hi:
                cells[i] = (cells[i] + " " + w["text"]).strip()
                break
        else:
            raise ValueError("word %r at x=%.1f fits no column" % (w["text"], mid))
    return cells


def paragraph(page, **box):
    """Captions/footnotes: join the printed lines back into one string.

    A line that ends in "-" followed by a lower-case continuation is a word broken by
    the typesetter ("of se-" / "lected areas", "Data are plot-" / "ted in figure 3a."),
    so the hyphen is dropped and the halves joined.  No caption here ends on a real
    compound hyphen, so the rule is safe for this paper.
    """
    txt = ""
    for _, g in lines_of(page, **box):
        line = " ".join(w["text"] for w in g)
        if txt.endswith("-") and line[:1].islower():
            txt = txt[:-1] + line
        else:
            txt = (txt + " " + line).strip()
    return deligature(txt)


def save(name, sheet, rows):
    wb = Workbook()
    ws = wb.active
    ws.title = sheet
    for r in rows:
        ws.append(list(r))
    path = os.path.join(HERE, name)
    wb.save(path)
    print("%-52s %2d worksheet rows" % (os.path.basename(path), len(rows)))


# --------------------------------------------------------------------------- #
# Table 1 - page 89 (PDF page 2), full page width
# --------------------------------------------------------------------------- #
T1_COLS = [
    ("Animal",        45, 110),
    ("Latin name",   110, 222),
    ("Areas shown",  222, 252),
    ("Average rel. size, %", 252, 300),
    ("SD, log rel. size",    300, 342),
    ("Brain mass, g",        342, 385),
    ("EQ",                   385, 440),
    ("Reference",            440, 580),
]


def table1(pdf):
    p = pdf.pages[1]
    caption = paragraph(p, top_lo=68, top_hi=78)
    hdr = [to_cells(g, T1_COLS) for _, g in lines_of(p, top_lo=90, top_hi=112)]
    data = [to_cells(g, T1_COLS) for _, g in lines_of(p, top_lo=118, top_hi=325)]
    foot = paragraph(p, top_lo=334, top_hi=365)
    rows = [[caption]] + hdr + data + [[foot]]
    assert len(data) == 19, len(data)
    return rows, data


# --------------------------------------------------------------------------- #
# Table 2 - page 89 (PDF page 2), right-hand column, interleaved with prose
# --------------------------------------------------------------------------- #
T2_COLS = [
    ("Animal", 305, 380),
    ("V1",     380, 418),
    ("V2",     418, 453),
    ("A1",     453, 490),
    ("S1",     490, 528),
    ("M1",     528, 575),
]


def table2(pdf):
    p = pdf.pages[1]
    caption = paragraph(p, x_lo=306, top_lo=408, top_hi=425)
    # "Relative size of area, %" is one header spanning V1..M1; keep it as one cell.
    spanner = ["", paragraph(p, x_lo=306, top_lo=440, top_hi=450), "", "", "", ""]
    heads = to_cells(next(g for _, g in lines_of(p, x_lo=306, top_lo=457, top_hi=466)), T2_COLS)
    data = [to_cells(g, T2_COLS) for _, g in lines_of(p, x_lo=306, top_lo=476, top_hi=648)]
    foot = paragraph(p, x_lo=306, top_lo=658, top_hi=670)
    rows = [[caption], spanner, heads] + data + [[foot]]
    assert len(data) == 16, len(data)
    return rows, data


# --------------------------------------------------------------------------- #
# Table 3 - page 90 (PDF page 3), right-hand column
# --------------------------------------------------------------------------- #
T3_COLS = [
    ("Subnetwork", 215, 345),
    ("Areas",      345, 385),
    ("Edges",      385, 440),
    ("Reference",  440, 580),
]


def table3(pdf):
    p = pdf.pages[2]
    caption = paragraph(p, x_hi=214, top_lo=68, top_hi=110)
    hdr = [to_cells(g, T3_COLS) for _, g in lines_of(p, x_lo=215, top_lo=75, top_hi=85)]
    data = [to_cells(g, T3_COLS) for _, g in lines_of(p, x_lo=215, top_lo=96, top_hi=200)]
    foot = paragraph(p, x_lo=215, top_lo=212, top_hi=232)
    rows = [[caption]] + hdr + data + [[foot]]
    assert len(data) == 10, len(data)
    return rows, data


# --------------------------------------------------------------------------- #
# Table 4 - page 91 (PDF page 4), right-hand column, runs the full page
# --------------------------------------------------------------------------- #
T4_COLS = [
    ("Animal",         215, 275),
    ("Kind of areas",  275, 370),
    ("Area",           370, 410),
    ("Area connections per area", 410, 452),
    ("Reference",      452, 580),
]


def table4(pdf):
    p = pdf.pages[3]
    caption = paragraph(p, x_hi=214, top_lo=68, top_hi=98)
    hdr = [to_cells(g, T4_COLS) for _, g in lines_of(p, x_lo=215, top_lo=75, top_hi=105)]

    # The printed table rules one horizontal line between animals.  Use them, because
    # "Squirrel monkey" wraps onto two printed lines and only the rules say that the
    # stray "monkey" belongs to the cell above rather than to the DM row it sits on.
    rules = sorted({round(e["top"], 1) for e in p.edges
                    if e["orientation"] == "h" and e["x0"] < 230 and e["x1"] > 555
                    and 110 < e["top"] < 620})

    raw = [to_cells(g, T4_COLS) for _, g in lines_of(p, x_lo=215, top_lo=117, top_hi=600)]
    tops = [t for t, _ in lines_of(p, x_lo=215, top_lo=117, top_hi=600)]

    data = []
    for cells, top in zip(raw, tops):
        # "not shown here" is one cell spanning Area + Area-connections; the connections
        # column only ever prints an integer, so anything else there belongs to Area.
        if cells[3] and not re.fullmatch(r"\d+", cells[3]):
            cells[2] = (cells[2] + " " + cells[3]).strip()
            cells[3] = ""
        # A line carrying nothing but a reference is the second printed line of the
        # reference cell above (Squirrel S1(3b) and SII).
        if cells[4] and not any(cells[:4]):
            data[-1][4] = (data[-1][4] + " " + cells[4]).strip()
            continue
        data.append(cells)
        data[-1].append(top)

    # collapse the wrapped Animal cell onto the first row of its ruled group
    for lo, hi in zip([110] + rules, rules + [620]):
        grp = [r for r in data if lo < r[-1] < hi]
        if len(grp) < 2:
            continue
        parts = [r[0] for r in grp if r[0]]
        if len(parts) > 1:
            grp[0][0] = " ".join(parts)
            for r in grp[1:]:
                r[0] = ""

    data = [r[:-1] for r in data]
    foot = paragraph(p, x_lo=215, top_lo=612, top_hi=632)
    rows = [[caption]] + hdr + data + [[foot]]
    assert len(data) == 38, len(data)
    return rows, data


# --------------------------------------------------------------------------- #
# Table 5 - page 92 (PDF page 5), right-hand column
# --------------------------------------------------------------------------- #
T5_COLS = [
    ("Animal",     215, 305),
    ("Latin name", 305, 420),
    ("Average area connections per area", 420, 465),
    ("SD log area connections per area",  465, 522),
    ("Brain mass g", 522, 580),
]


def table5(pdf):
    p = pdf.pages[4]
    caption = paragraph(p, x_hi=214, top_lo=68, top_hi=150)
    hdr = [to_cells(g, T5_COLS) for _, g in lines_of(p, x_lo=215, top_lo=75, top_hi=118)]
    data = [to_cells(g, T5_COLS) for _, g in lines_of(p, x_lo=215, top_lo=128, top_hi=245)]
    foot = paragraph(p, x_lo=215, top_lo=254, top_hi=266)
    rows = [[caption]] + hdr + data + [[foot]]
    assert len(data) == 11, len(data)
    return rows, data


# --------------------------------------------------------------------------- #

def main():
    if not os.path.exists(PDF):
        sys.exit("PDF not found: %s" % PDF)
    with pdfplumber.open(PDF) as pdf:
        for n, fn in enumerate((table1, table2, table3, table4, table5), start=1):
            rows, data = fn(pdf)
            save("Changizi_Shimojo_2005_Table%d_snapshot.xlsx" % n, "Table%d" % n, rows)
            print("    caption: %s" % rows[0][0][:88])
            print("    data rows: %d" % len(data))


if __name__ == "__main__":
    main()
