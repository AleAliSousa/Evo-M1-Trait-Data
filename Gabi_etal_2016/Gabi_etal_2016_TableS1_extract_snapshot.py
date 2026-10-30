#!/usr/bin/env python3
"""Build Gabi_etal_2016_TableS1_snapshot.xlsx from the PNAS SI Appendix.

Printed source -> a snapshot is required (__HOWTO_build_a_dataset_file.md sec 0a invariant 1).
Table S1 is on p. 2 of pnas.201610178si.pdf.

Extraction is by word coordinates, not line text: the Frontiers/PNAS text layer has dropped the
space glyphs ("Homosapiens", "Percentvolumeandnumber..."), and the header is two-tier - "%V" sits
on one baseline with "GM"/"WM" on the next. Both are handled by reading fixed x-windows taken from
the printed header positions.

The snapshot keeps the printed caption, the two-tier header as printed, the printed row order and
the full footnote, with the species names exactly as printed (abbreviated genus, no spaces).
"""

import collections
import os

import pdfplumber
from openpyxl import Workbook

HERE = os.path.dirname(os.path.abspath(__file__))
PDF = os.path.join(HERE, "pnas.201610178si.pdf")
OUT = os.path.join(HERE, "Gabi_etal_2016_TableS1_snapshot.xlsx")

CAPTION = "Table S1. Percent volume and number of cortical neurons in prefrontal region"
FOOTNOTE = ("% V_GM, percentage of gray matter volume contained in prefrontal region; "
            "% V_WM, percentage of white matter volume contained in prefrontal region; "
            "% O_WM, percentage of all other (nonneuronal) cells in the white matter contained "
            "in prefrontal region; and % neurons, percentage of all cortical neurons contained "
            "in prefrontal region.")
# x-window start for each column, read off the printed header
XCUT = [(160, 240), (240, 285), (285, 330), (330, 375), (375, 430)]
HEADER_TOP = ["Species", "%V", "%V", "%O", "%neurons"]   # printed row 1 of the header
HEADER_BOT = ["", "GM", "WM", "WM", ""]                  # printed row 2 of the header


def main():
    with pdfplumber.open(PDF) as pdf:
        page = pdf.pages[1]
        by_line = collections.defaultdict(list)
        for w in page.extract_words():
            if w["top"] < 230:                      # Table S1 occupies the top of p. 2
                by_line[round(w["top"], 1)].append(w)

        rows = []
        for top in sorted(by_line):
            if not (85 < top < 170):                # data band, between header and footnote
                continue
            cells = []
            for lo, hi in XCUT:
                txt = " ".join(w["text"] for w in sorted(by_line[top], key=lambda w: w["x0"])
                               if lo <= w["x0"] < hi)
                cells.append(txt)
            if cells[0] and any(cells[1:]):
                rows.append(cells)

    assert len(rows) == 8, "expected 8 species rows, got %d" % len(rows)
    for r in rows:
        assert all(c for c in r), "blank cell in %r - Table S1 prints no blanks" % r

    wb = Workbook()
    ws = wb.active
    ws.title = "TableS1"
    ws.append([CAPTION] + [None] * 4)
    ws.append(HEADER_TOP)
    ws.append(HEADER_BOT)
    for r in rows:
        ws.append(r)
    ws.append([FOOTNOTE] + [None] * 4)
    wb.save(OUT)
    print("%s: %d species rows" % (os.path.basename(OUT), len(rows)))
    for r in rows:
        print("   " + " | ".join("%-14s" % c for c in r))


if __name__ == "__main__":
    main()
