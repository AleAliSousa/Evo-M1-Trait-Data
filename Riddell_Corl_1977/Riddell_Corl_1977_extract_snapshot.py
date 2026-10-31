#!/usr/bin/env python3
"""Riddell_Corl_1977_extract_snapshot.py

Builds the frozen snapshot of Table II of Riddell & Corl (1977), "Comparative
investigation of the relationship between cerebral indices and learning
abilities", Brain Behav. Evol. 14(6), 385-398, doi:10.1159/000125804, from the
scanned PDF in this folder.

Table II runs across two printed pages (p.391 and p.392 of the journal = PDF
pages 7 and 8; the second page repeats the caption as "Table II (continued)"
and the full header).  Both pages are kept, in printed order, in one snapshot.

The PDF's OCR text layer scrambles this rotated, brace-grouped table, so the
values were read off 300 dpi page renders, cell by cell, and typed here
verbatim as printed -- snapshot HOWTO method 5 ("manual entry") with the
printed-layout block inside the extract script.

Transcribed by: AI assistant (Claude), 2026-10-31.
Checked by: the same session, reading each row left-to-right against magnified
crops of the numeric block and of the rank/reference block.  Independently,
the build script re-derives the printed Nc / E / H rank columns from the
printed Nc / E / H values within each task block (see `table_checks` in
Riddell_Corl_1977_TableII.R).  A human side-by-side check is still outstanding.

Printed peculiarities kept verbatim (do not "fix" them here):
  * species epithets as printed -- "Cebus capuchin", "Erinaceus europacus",
    "Sciurus vulgaric", "Meriones unguiculates", "Silvilagus gabbi",
    "Saimiri sciurea", "Galago-senegalensis", "Paco paca", "Lagothrix" n/a;
  * Tupaia glis P is 145.5 in the delayed-alternation block and 145.4 in the
    extradimensional-shift block; Rattus rattus H is 15.55 in the learning-set
    block and 15.6 in the extradimensional-shift block;
  * in the extradimensional-shift block the printed Behavior rank is 6 for
    Tupaia glis (row 5) and 5 for Rattus rattus (row 6);
  * the Slope column is printed only for the learning-set block; elsewhere it
    is an en dash "-".

Re-running is safe: the script refuses to overwrite a differing frozen copy
unless --force is given.
"""

import csv
import os
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
FORCE = "--force" in sys.argv

HEAD = [
    ["Species", "[printed brace]", "Dependent variable", "P, g", "E, g",
     "Nc x 10^7", "H", "Slope", "Behavior rank", "Nc rank", "E rank",
     "H rank", "Behavior reference", "E and P reference"],
]

# row number as printed, species, brace, dependent variable, then the values.
# The "Dependent variable" cell is printed once per braced block, vertically
# centred; it is repeated here on the block's first row and left blank on the
# rest, exactly as it reads on the page.
TABLE2 = [
    ["Table II. Anatomical and performance data for several species on five tasks"],
    ["[page 391]"],
    HEAD[0],
    ["1 Cebus capuchin", "{", "successive discrimination reversal",
     "3,765.0", "73.8", "110.0", "5.72", "-", "1", "1", "1", "3", "8", "17"],
    ["2 Procyon lotor", "{", "",
     "4,290.0", "39.2", "60.4", "8.2", "-", "2", "2", "2", "5", "8", "4"],
    ["3 Mephitis mephitis", "{", "",
     "1,980.0", "10.2", "15.0", "12.5", "-", "3", "6", "6", "6", "8", "4"],
    ["4 Nasua nasua", "{", "",
     "399.0", "23.3", "54.1", "4.8", "-", "4", "3", "5", "1", "8", "4"],
    ["5 Saimiri sciurea", "{", "",
     "630.0", "24.8", "54.0", "5.44", "-", "5", "4", "4", "2", "8", "17"],
    ["6 Potos flavus", "{", "",
     "2,620.0", "31.1", "53.0", "7.8", "-", "6", "5", "3", "4", "8", "4"],
    ["1 Pan troglodytes", "{", "conditioned response reversal",
     "50,340.0", "382.5", "325.6", "6.0", "-", "1", "1", "1", "1.5", "41", "18"],
    ["2 Papio hamadryas", "{", "",
     "16,000.0", "179.0", "197.0", "6.0", "-", "2", "2", "2", "1.5", "41", "17"],
    ["3 Canis familiaris", "{", "",
     "13,520.0", "80.6", "96.2", "8.4", "-", "3", "3", "3", "3", "41", "4"],
    ["4 Silvilagus gabbi", "{", "",
     "539.0", "4.5", "10.2", "11.3", "-", "4", "4", "4", "4", "41", "4"],
    ["1 Galago-senegalensis", "{", "delayed alternation",
     "200.0", "5.0", "15.2", "8.3", "-", "1", "1", "1", "1", "21", "4"],
    ["2 Tupaia glis", "{", "",
     "145.5", "3.2", "10.1", "9.4", "-", "2", "2", "3", "2", "21", "27"],
    ["3 Erinaceus europacus", "{", "",
     "860.0", "3.35", "2.39", "16.4", "-", "3", "3", "2", "3", "21", "17"],
    ["1 Homo sapiens", "{", "learning sets",
     "64,807.4", "1,326.6", "855.6", "3.47", "2.5", "1", "1", "1", "1", "38", "4"],
    ["2 Pan troglodytes", "{", "",
     "28,022.9", "357.1", "329.8", "4.97", "0.20", "2", "2", "2", "3", "9", "18"],
    ["3 Macaca mulatta", "{", "",
     "8,719.0", "106.4", "136.0", "6.3", "0.11", "3", "4", "4", "6", "23", "17"],
    ["4 Ateles geoffroyi", "{", "",
     "7,787.0", "117.0", "150.0", "5.79", "0.06", "4", "3", "3", "5", "35", "17"],
    ["5 Cebus albifrons", "{", "",
     "1,640.0", "80.0", "128.0", "4.17", "0.04", "5", "5", "5", "2", "35", "17"],
    ["6 Saimiri sciurea", "{", "",
     "630.0", "24.8", "54.0", "5.44", "0.03", "6.5", "6", "7", "4", "24, 35", "17"],
    ["7 Callithrix jacchus", "{", "",
     "850.0", "22.0", "47.2", "6.38", "0.03", "6.5", "7", "8", "7", "24", "10"],
    ["8 Felis domesticus", "{", "",
     "3,275.6", "25.3", "40.7", "9.33", "0.02", "8", "8", "6", "8", "22", "2"],
    ["9 Meriones unguiculates", "{", "",
     "62.0", "1.0", "3.0", "12.70", "0.01", "10", "10", "11", "10", "1",
     "present study"],
    ["10 Rattus rattus", "{", "",
     "326.6", "1.9", "2.4", "15.55", "0.01", "10", "11", "10", "11", "42",
     "present study"],
    ["11 Sciurus vulgaric", "{", "",
     "389.0", "6.0", "15.5", "9.42", "0.01", "10", "9", "9", "9", "30", "40"],
    ["[page 392]"],
    ["Table II (continued)"],
    HEAD[0],
    ["1 Homo sapiens", "{", "extradimensional shift",
     "64,807.4", "1,326.6", "855.6", "3.47", "-", "1", "1", "1", "1", "29", "4"],
    ["2 Cebus albifrons", "{", "",
     "1,640.0", "80.0", "128.0", "4.17", "-", "2", "2", "2", "2", "29", "17"],
    ["3 Saimiri sciurea", "{", "",
     "630.0", "24.8", "54.0", "5.44", "-", "3", "3", "4", "3", "29", "17"],
    ["4 Paco paca", "{", "",
     "6,100.0", "28.7", "37.9", "10.83", "-", "4", "4", "3", "5", "29", "29"],
    ["5 Tupaia glis", "{", "",
     "145.4", "3.2", "10.1", "9.4", "-", "6", "5", "5", "4", "29", "27"],
    ["6 Rattus rattus", "{", "",
     "326.6", "1.9", "2.4", "15.6", "-", "5", "6", "6", "6", "29", "28"],
]


def _pad(rows):
    w = max(len(r) for r in rows)
    return [list(r) + [""] * (w - len(r)) for r in rows]


def write_csv(name, rows):
    rows = _pad(rows)
    path = os.path.join(HERE, name)
    fd, tmp = tempfile.mkstemp(dir=HERE, suffix=".csv")
    with os.fdopen(fd, "w", newline="", encoding="utf-8") as fh:
        csv.writer(fh).writerows(rows)
    _commit(tmp, path)


def write_xlsx(name, rows, sheet):
    from openpyxl import Workbook
    rows = _pad(rows)
    path = os.path.join(HERE, name)
    wb = Workbook()
    ws = wb.active
    ws.title = sheet
    for r in rows:
        ws.append(r)
    fd, tmp = tempfile.mkstemp(dir=HERE, suffix=".xlsx")
    os.close(fd)
    wb.save(tmp)
    _commit(tmp, path)


def _read_back(path):
    if path.endswith(".csv"):
        with open(path, newline="", encoding="utf-8") as fh:
            return [list(r) for r in csv.reader(fh)]
    from openpyxl import load_workbook
    ws = load_workbook(path).active
    return [["" if c is None else str(c) for c in row]
            for row in ws.iter_rows(values_only=True)]


def _commit(tmp, path):
    new = _read_back(tmp)
    if os.path.exists(path):
        if _read_back(path) == new:
            os.remove(tmp)
            print("unchanged: %s" % os.path.basename(path))
            return
        if not FORCE:
            os.remove(tmp)
            raise SystemExit(
                "REFUSING to overwrite a differing frozen copy: %s\n"
                "Re-run with --force only after deciding whether the "
                "difference is a transcription fix (record it) or an error."
                % os.path.basename(path))
    os.replace(tmp, path)
    print("wrote %s (%d rows)" % (os.path.basename(path), len(new)))


def main():
    write_xlsx("Riddell_Corl_1977_TableII_snapshot.xlsx", TABLE2, "TableII")


if __name__ == "__main__":
    main()
