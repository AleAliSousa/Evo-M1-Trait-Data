#!/usr/bin/env python3
"""Maslow_Harlow_1932_extract_snapshots.py

Builds the two frozen snapshots for Maslow & Harlow (1932), "Comparative
behavior of primates. II. Delayed reaction tests on primates at Bronx Park
zoo", J. Comp. Psychol. 14(1), 97-107, doi:10.1037/h0072093, from the scanned
PDF in this folder ("Maslow-1932-Comparative behavior.pdf").

The PDF is a 1932 scan whose embedded OCR text layer emits table columns out
of reading order and corrupts digits, so the values below were read off page
renders at 200 dpi, cell by cell, and typed here verbatim as printed --
snapshot HOWTO method 5 ("manual entry"), with the printed-layout block kept
inside the extract script.

Transcribed by: AI assistant (Claude), 2026-10-31.
Checked by: the same session, re-reading every row left-to-right against
magnified crops of the two halves of each table.  A human side-by-side check
is still outstanding (see the item READMEs and `Human visual check of
snapshot` in __ReadMe.xlsx).

Printed page numbers: TABLE 1 p.99, TABLE 2 p.106 (PDF pages 3 and 10).

One snapshot row per printed row, printed row and column order, blank
padding under spanning headers, values exactly as printed.
Re-running is safe: the script refuses to overwrite a differing frozen copy
unless --force is given.
"""

import csv
import os
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
FORCE = "--force" in sys.argv

# --------------------------------------------------------------------------
# TABLE 1 (p.99) -- Classification of the animals.  Single header row -> CSV.
# The printed FAMILY cells wrap over two lines; a wrapped cell is still one
# printed row, so each numbered animal is one snapshot row.
# --------------------------------------------------------------------------
TABLE1 = [
    ["TABLE 1", "", "", "", ""],
    ["Classification of the animals", "", "", "", ""],
    ["FAMILY", "GENUS", "SPECIES", "ESTIMATED AGE", "SEX"],
    ["Suborder Anthropoidea", "", "", "", ""],
    ["1. Pongiidae", "Pan", "Chimpanse", "4 1/2 years", "Female"],
    ["2. Pongiidae (gorilla)", "Gorilla", "Gorilla", "4 1/2 years", "Female"],
    ["3. Lasiopygidae (Chacma baboon)", "Papio", "Porcarius", "Adult", "Male"],
    ["4. Lasiopygidae (guinea baboon)", "Papio", "Papio", "Young adult", "Female"],
    ["5. Lasiopygidae (yellow baboon)", "Papio", "Cynocephalus", "Adult", "Male"],
    ["6. Lasiopygidae (drill)", "Papio", "Leucophaeus", "Adult", "Male"],
    ["7. Lasiopygidae (drill)", "Papio", "Leucophaeus", "Baby (2 years)", "Male"],
    ["8. Lasiopygidae (mandrill)", "Papio", "Sphinx", "Adult", "Male"],
    ["9. Lasiopygidae (pig tailed monkey)", "Pithecus", "Andamanensis", "Adult", "Male"],
    ["10. Lasiopygidae (common macaque)", "Pithecus", "Cinnemalogus", "Adult", "Male"],
    ["11. Cebidae (woolly monkey)", "Lagothrix", "Lagotricha", "Young adult", "Male"],
    ["12. Cebidae (spider monkey)", "Ateleus", "Ater", "Adult", "Male"],
    ["13. Cebidae (hooded Capuchin)", "Cebus", "Unicolor", "Adult", "Female"],
    ["14. Cebidae (Capuchin monkey)", "Cebus", "Capucinus", "Old adult", "Male"],
    ["15. Cebidae (Capuchin monkey)", "Cebus", "Capucinus", "Young adult", "Male"],
    ["Suborder Lemuroidea", "", "", "", ""],
    ["16. Nycticibidae (brown ruffed lemur)", "Lemur", "Variegatus ruber", "Adult", "Male"],
    ["17. Nycticibidae (brown mongoose lemur)", "Lemur", "Rufus", "Adult", "Female"],
    ["18. Nycticibidae (gray mongoose lemur)", "Lemur", "Mongoz", "Adult", "Male"],
]

# --------------------------------------------------------------------------
# TABLE 2 (p.106) -- Summary of correct responses.
# Three-tier header: PERIOD OF DELAY (SECONDS) spanning eight delay blocks,
# each N / %C.  -> XLSX with blank padding under the spanning headers.
# Three animals have a sentence printed across the data columns instead of
# values; that sentence is kept in the first data cell of its own row.
# --------------------------------------------------------------------------
DELAYS = ["0", "5", "10", "15", "30", "60", "120", "180"]

T2_HEADER = [
    ["TABLE 2"],
    ["Summary of correct responses"],
    ["ANIMAL", "PERIOD OF DELAY (SECONDS)"] + [""] * 15,
    [""] + [v for d in DELAYS for v in (d, "")],
    [""] + ["N", "%C"] * 8,
]

T2_ROWS = [
    ["Young chimpanzee", "30", "93", "30", "83", "", "", "50", "76",
     "48", "61", "28", "82", "25", "60", "", ""],
    ["Young gorilla", "20", "85", "40", "83", "", "", "39", "74",
     "36", "72", "31", "52", "1", "100", "", ""],
    ["Chacma baboon", "5", "100", "15", "93", "", "", "20", "85",
     "20", "85", "20", "85", "", "", "", ""],
    ["Hamadryas baboon", "5", "100", "5", "100", "", "", "5", "100",
     "5", "100", "10", "70", "10", "60", "", ""],
    ["Drill", "5", "100", "20", "95", "", "", "31", "84",
     "35", "90", "35", "77", "17", "60", "2", "0"],
    ["Mandrill", "5", "100", "10", "100", "", "", "15", "66",
     "20", "65", "7", "57", "", "", "", ""],
    ["Yellow baboon", "5", "100", "20", "95", "", "", "15", "87",
     "20", "80", "30", "83", "22", "68", "10", "70"],
    ["Baby mandrill", "44", "81", "40", "75", "", "", "37", "62",
     "40", "55", "20", "70", "7", "0", "", ""],
    ["Pig tailed monkey", "5", "100", "15", "93", "", "", "24", "75",
     "25", "76", "10", "60", "", "", "", ""],
    ["Common macaque", "Too ferocious to attend to experimental situation",
     "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""],
    ["Woolly monkey", "50", "88", "40", "85", "", "", "49", "82",
     "52", "45", "20", "55", "", "", "", ""],
    ["Spider monkey", "Too sick to respond. Died soon after",
     "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""],
    ["Hooded Capuchin", "15", "93", "13", "77", "10", "50", "", "",
     "", "", "", "", "", "", "", ""],
    ["White faced Capuchin", "28", "96", "15", "60", "19", "74", "25", "72",
     "20", "45", "", "", "", "", "", ""],
    ["White faced Capuchin (young)", "34", "85", "30", "77", "10", "70",
     "10", "20", "", "", "", "", "", "", "", ""],
    ["Brown ruffed lemur", "30", "80", "20", "75", "", "", "", "",
     "", "", "", "", "", "", "", ""],
    ["Gray mongoose lemur", "21", "67", "8", "75", "", "", "", "",
     "", "", "", "", "", "", "", ""],
    ["Brown mongoose lemur", "Too shy to respond",
     "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""],
]

T2_FOOT = [["N, number of trials.  %C, percentage of trials correct."]]


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
    write_csv("Maslow_Harlow_1932_TABLE1_snapshot.csv", TABLE1)
    write_xlsx("Maslow_Harlow_1932_TABLE2_snapshot.xlsx",
               T2_HEADER + T2_ROWS + T2_FOOT, "TABLE2")


if __name__ == "__main__":
    main()
