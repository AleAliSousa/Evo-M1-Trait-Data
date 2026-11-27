#!/usr/bin/env python3
"""Build Gabi_etal_2016_TableS1_snapshot.xlsx from the PNAS SI Appendix.

Printed source -> a snapshot is required (__HOWTO_build_a_dataset_file.md sec 0a invariant 1).
Table S1 is on p. 2 of pnas.201610178si.pdf.

Extraction uses the layout-preserving text layer on p. 2. The printed header is one row;
subscripts are part of the same header cells.

The snapshot keeps the printed caption, one-row header, printed row order and
the full footnote, with the species names exactly as printed (abbreviated genus, no spaces).
"""

import os
import re
import subprocess

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
HEADER = ["Species", "% V_GM", "% V_WM", "% O_WM", "% neurons"]


def restore_printed_species_spacing(name):
    name = re.sub(r"^([A-Z])\.(\S)", r"\1. \2", name)
    return "Homo sapiens" if name == "Homosapiens" else name


def main():
    page = subprocess.check_output(
        ["pdftotext", "-f", "2", "-l", "2", "-layout", PDF, "-"], text=True
    )
    band = page.split("Table S1.", 1)[1].split("Table S2.", 1)[0]
    pat = re.compile(r"^\s*((?:[A-Z]\.\s*\w+|Homo\s*sapiens))\s+"
                     r"(\d+(?:\.\d+)?)\s+(\d+(?:\.\d+)?)\s+"
                     r"(\d+(?:\.\d+)?)\s+(\d+(?:\.\d+)?)\s*$")
    rows = []
    for line in band.splitlines():
        match = pat.match(line)
        if match:
            row = list(match.groups())
            row[0] = restore_printed_species_spacing(row[0])
            rows.append(row)

    assert len(rows) == 8, "expected 8 species rows, got %d" % len(rows)
    for r in rows:
        assert all(c for c in r), "blank cell in %r - Table S1 prints no blanks" % r

    wb = Workbook()
    ws = wb.active
    ws.title = "TableS1"
    ws.append([CAPTION] + [None] * 4)
    ws.append(HEADER)
    for r in rows:
        ws.append(r)
    ws.append([FOOTNOTE] + [None] * 4)
    wb.save(OUT)
    print("%s: %d species rows" % (os.path.basename(OUT), len(rows)))
    for r in rows:
        print("   " + " | ".join("%-14s" % c for c in r))


if __name__ == "__main__":
    main()
