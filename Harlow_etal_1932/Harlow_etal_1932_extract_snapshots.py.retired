#!/usr/bin/env python3
"""Harlow_etal_1932_extract_snapshots.py

Builds the six frozen snapshots for Harlow, Uehling & Maslow (1932),
J. Comp. Psychol. 13(3), 313-343, doi:10.1037/h0073864, from the scanned
PDF in this folder ("Harlow-1932-Comparative behavior.pdf").

The PDF is a 1932 scan.  Its embedded OCR text layer is unusable for tables
(columns are emitted out of reading order and digits are corrupted), so the
values below were read off page renders at 200-400 dpi, cell by cell, and
typed here verbatim as printed -- snapshot HOWTO method 5 ("manual entry"),
with the printed-layout block living inside the extract script
(Jacobs_etal_2018_extract_snapshot.R pattern).

Transcribed by: AI assistant (Claude), 2026-10-31.
Checked by: the same session, by re-rendering each table at 400 dpi with the
column rules visible and reading every row left-to-right against the block
below.  A human side-by-side check is still outstanding -- see each item
README and the `Human visual check of snapshot` column of __ReadMe.xlsx.

Rules obeyed (see _skills/build-dataset-item/references/__HOWTO_make_a_snapshot.md):
  * one snapshot row per printed row, in printed order, blanks and section
    rows included;
  * column order as published, with blank padding under spanning headers;
  * values exactly as printed (fractions as "11 1/2", footnote marks kept,
    blank cells left blank);
  * nothing sorted, deduplicated or unpivoted.

Printed page numbers: TABLE 1 p.316, TABLE 2 p.323, TABLE 3 p.331,
TABLE 4 p.334, TABLE 5 p.334, TABLE 6 p.337 (PDF pages 4, 11, 19, 22, 22, 25).

Re-running is safe: the script refuses to overwrite a frozen file whose
content differs, unless --force is given.
"""

import csv
import os
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
FORCE = "--force" in sys.argv

# --------------------------------------------------------------------------
# TABLE 1 (p.316) -- Classification of the animals.  Flat layout -> CSV.
# --------------------------------------------------------------------------
TABLE1 = [
    ["TABLE 1", "", "", "", "", ""],
    ["Classification of the animals", "", "", "", "", ""],
    ["FAMILY", "GENUS", "SPECIES", "FAMILIAR NAME", "ESTIMATED AGE", "SEX"],
    ["Suborder Anthropoidea", "", "", "", "", ""],
    ["", "", "", "", "years", ""],
    ["Pongiidae (orang-outan)", "Pongo", "Pygmaeus", "Jiggs", "11 1/2", "Male"],
    ["Hylobatidae (white-handed gibbon)", "Hylobates", "Lar", "Charlotte", "15", "Male"],
    ["Lasiopygidae (Macacus rhesus)", "Pithecus", "Rhesus", "No. I", "7", "Male"],
    ["Lasiopygidae (Macacus rhesus)", "Pithecus", "Rhesus", "No. II", "5", "Female"],
    ["Lasiopygidae (Macacus rhesus)", "Pithecus", "Rhesus", "No. III", "5", "Female"],
    ["Lasiopygidae (Macacus rhesus)", "Pithecus", "Rhesus", "No. IV", "5", "Female"],
    ["Lasiopygidae (Macacus rhesus)", "Pithecus", "Rhesus", "No. V", "4", "Female"],
    ["Lasiopygidae (Java monkey)", "Pithecus", "Mordax", "Sourface", "5", "Male"],
    ["Lasiopygidae (Java monkey)", "Pithecus", "Mordax", "Kewpie", "5", "Male"],
    ["Lasiopygidae (Barbary ape)", "Simia*", "Sylvanus", "Blackie", "5", "Male"],
    ["Lasiopygidae (sooty mangaby)", "Cercocebus", "Aethiops", "Sooty", "3", "Male"],
    ["Lasiopygidae (Mona guenon)", "Lasiopyga", "Mona", "Mona", "3", "Female"],
    ["Lasiopygidae (green guenon)", "Lasiopyga", "Callitrichus", "Thunder", "9", "Male"],
    ["Lasiopygidae (green guenon)", "Lasiopyga", "Callitrichus", "Lightning", "9", "Male"],
    ["Lasiopygidae (mustached guenon)", "Lasiopyga", "Cephus", "Skeezix", "1 1/2", "Male"],
    ["Lasiopygidae (yellow baboon)", "Papio", "Cynocephalus", "Tommy", "7", "Male"],
    ["Lasiopygidae (guinea baboon)", "Papio", "Papio", "Andy", "7", "Male"],
    ["Lasiopygidae (guinea baboon)", "Papio", "Papio", "Min", "7", "Female"],
    ["Lasiopygidae (mandrill)", "Papio", "Sphinx", "Pat", "20", "Male"],
    ["Lasiopygidae (mandrill)", "Papio", "Sphinx", "Socrates", "1 1/2", "Male"],
    ["Lasiopygidae (mandrill)", "Papio", "Sphinx", "Xanthippe", "1 1/2", "Female"],
    ["Cebidae (Capuchin monkey)", "Cebus", "Capucinus", "Scarface Al", "4", "Male"],
    ["Cebidae (Capuchin monkey)", "Cebus", "Capucinus", "Bugs", "4", "Male"],
    ["Suborder Lemuroidea", "", "", "", "", ""],
    ["Nycticibidae", "Lemur", "Variegatus", "Racket", "13", "Male"],
    ["* The Barbary ape is classified by Elliot as a separate genus, Simia; by "
     "Sonntag (25) it is classified as belonging to the genus Macacus "
     "(Elliot's genus Pithecus). We include it with the macaques in the "
     "discussion of results.", "", "", "", "", ""],
]

# --------------------------------------------------------------------------
# TABLE 2 (p.323) -- Summary of correct responses.
# Three-tier header (PERIOD OF DELAY spanning 8 delay blocks x NT/PC/LFC)
# -> XLSX, with blank padding under every spanning header.
# --------------------------------------------------------------------------
DELAYS2 = ["0 second", "5 seconds", "15 seconds", "30 seconds",
           "60 seconds", "120 seconds", "180 seconds", "Over 180 seconds"]

T2_HEADER = [
    ["TABLE 2"],
    ["Summary of correct responses"],
    ["ANIMAL", "FAMILIAR NAME", "PERIOD OF DELAY"] + [""] * 23,
    ["", ""] + [v for d in DELAYS2 for v in (d, "", "")],
    ["", ""] + ["NT", "PC", "LFC"] * 8,
    ["", ""] + ["", "per cent", "per cent"] * 8,
]

# animal, familiar name, then 8 x (NT, PC, LFC) exactly as printed
T2_ROWS = [
    ["Orang-outan", "Jiggs",
     "60", "100", "", "60", "98", "", "60", "100", "", "40", "95", "",
     "", "", "", "20", "90", "", "", "", "", "16", "88", "*"],
    ["Gibbon", "Charlotte",
     "200", "89", "98", "200", "90", "96", "200", "86", "92", "200", "80", "90",
     "65", "71", "", "35", "66", "", "", "", "", "", "", ""],
    ["Macaque", "No. I",
     "200", "94", "98", "200", "94", "96", "200", "90", "94", "200", "92", "94",
     "100", "82", "90", "60", "75", "", "", "", "", "", "", ""],
    ["Macaque", "No. II",
     "200", "86", "94", "100", "93", "92", "100", "92", "94", "100", "89", "90",
     "60", "63", "", "40", "65", "", "", "", "", "", "", ""],
    ["Macaque", "No. III",
     "200", "72", "88", "200", "77", "84", "200", "71", "74", "200", "62", "70",
     "100", "51", "53", "60", "47", "", "", "", "", "", "", ""],
    ["Macaque", "No. IV",
     "100", "78", "92", "100", "81", "86", "100", "77", "82", "60", "65", "",
     "60", "55", "", "", "", "", "", "", "", "", "", ""],
    ["Macaque", "No. V",
     "200", "89", "96", "200", "91", "94", "200", "87", "94", "200", "78", "86",
     "100", "70", "78", "100", "65", "74", "", "", "", "", "", ""],
    ["Macaque", "Sourface",
     "200", "90", "100", "200", "96", "98", "200", "86", "96", "200", "85", "98",
     "100", "89", "96", "80", "80", "86", "", "", "", "", "", ""],
    ["Macaque", "Kewpie",
     "200", "92", "98", "200", "94", "100", "200", "95", "94", "200", "93", "96",
     "100", "94", "96", "100", "86", "90", "20", "70", "", "", "", ""],
    ["Barbary ape", "Blackie",
     "200", "92", "98", "200", "98", "100", "200", "90", "94", "200", "89", "92",
     "100", "70", "80", "60", "73", "", "", "", "", "", "", ""],
    ["Guenon", "Thunder",
     "200", "82", "88", "100", "86", "90", "80", "78", "", "60", "68", "",
     "20", "70", "", "", "", "", "", "", "", "", "", ""],
    ["Guenon", "Lightning",
     "100", "84", "94", "100", "88", "90", "100", "84", "84", "60", "72", "",
     "30", "73", "", "", "", "", "", "", "", "", "", ""],
    ["Guenon", "Mona",
     "200", "80", "90", "200", "77", "92", "200", "81", "88", "200", "76", "92",
     "100", "74", "84", "80", "64", "", "", "", "", "", "", ""],
    ["Guenon", "Skeezix",
     "(Failed to grasp problem)", "", "", "", "", "", "", "", "", "", "", "",
     "", "", "", "", "", "", "", "", "", "", "", ""],
    ["Mangabey", "Sooty",
     "200", "91", "94", "140", "84", "88", "80", "78", "", "60", "63", "",
     "40", "55", "", "", "", "", "", "", "", "", "", ""],
    ["Baboon", "Tommy",
     "200", "99", "100", "200", "100", "100", "200", "99", "100", "200", "93", "98",
     "100", "90", "92", "100", "84", "88", "", "", "", "", "", ""],
    ["Baboon", "Andy",
     "200", "96", "98", "200", "95", "98", "200", "90", "96", "200", "91", "94",
     "100", "84", "88", "100", "78", "80", "", "", "", "", "", ""],
    ["Baboon", "Min",
     "200", "96", "100", "200", "98", "98", "200", "96", "100", "200", "96", "98",
     "100", "90", "94", "100", "81", "84", "", "", "", "", "", ""],
    ["Mandrill", "Pat",
     "200", "96", "100", "200", "99", "100", "200", "96", "98", "200", "90", "94",
     "100", "92", "94", "100", "84", "86", "60", "80", "", "20", "85", "\u2020"],
    ["Mandrill", "Socrates",
     "60", "73", "", "40", "68", "", "", "", "", "", "", "",
     "", "", "", "", "", "", "", "", "", "", "", ""],
    ["Mandrill", "Xanthippe",
     "200", "80", "96", "100", "82", "92", "100", "74", "84", "70", "59", "",
     "", "", "", "", "", "", "", "", "", "", "", ""],
    ["Cebus monkey", "Scarface Al",
     "140", "74", "78", "110", "77", "", "30", "73", "", "", "", "",
     "", "", "", "", "", "", "", "", "", "", "", ""],
    ["Cebus monkey", "Bugs",
     "90", "77", "", "80", "76", "", "20", "65", "", "", "", "",
     "", "", "", "", "", "", "", "", "", "", "", ""],
    ["Lemur", "Racket",
     "80", "89", "", "40", "80", "", "40", "78", "", "14", "57", "",
     "", "", "", "", "", "", "", "", "", "", "", ""],
]

T2_FOOT = [
    ["NT, number of trials.  PC, per cent total trials correct.  "
     "LFC, per cent last 50 trials correct."],
    ["* Three hundred seconds."],
    ["\u2020 Six hundred seconds."],
]

# --------------------------------------------------------------------------
# TABLE 3 (p.331).  Eleven printed label lines for ten value rows: lines 2 and
# 3 ("II. Pat" and "II. Baboon Min") are joined by a printed brace to a single
# set of values, and the numeral "II." is printed twice.  Both facts are kept
# as printed; the brace sits in its own column at the position it occupies on
# the page (between the ANIMAL column and the first value column).  The shared
# values are placed on the FIRST braced line and the brace column says so.
# See Harlow_etal_1932_errata.csv (E001).
# --------------------------------------------------------------------------
T3 = [
    ["TABLE 3", "", "", "", ""],
    ["Responses of 10 primates to neutral orientation, favorable orientation, "
     "and unfavorable orientation of correct container following 50-second "
     "delay periods", "", "", "", ""],
    ["Percentages of responses correct in 50 trials", "", "", "", ""],
    ["ANIMAL", "[printed brace]", "NEUTRAL ORIENTATION",
     "UNFAVORABLE ORIENTATION", "FAVORABLE ORIENTATION"],
    ["I. Mandrill", "", "100", "100", "100"],
    ["II. Pat", "} joined to next line", "98", "100", "100"],
    ["II. Baboon Min", "} joined to previous line", "", "", ""],
    ["III. Baboon Andy", "", "96", "94", "98"],
    ["IV. Baboon Tommy", "", "100", "98", "100"],
    ["V. Gibbon Charlotte", "", "90", "82", "94"],
    ["VI. Guenon Mona", "", "88", "64", "100"],
    ["VII. Macaque No. III", "", "74", "32", "100"],
    ["VIII. Guenon Thunder", "", "62", "24", "96"],
    ["IX. Mandrill Socrates", "", "54", "12", "98"],
    ["X. Macaque No. IV", "", "56", "4", "100"],
]

# --------------------------------------------------------------------------
# TABLE 4 (p.334) -- Effect of previous responses.  Two-tier header -> XLSX.
# --------------------------------------------------------------------------
T4 = [
    ["TABLE 4", "", "", "", "", "", ""],
    ["Effect of previous responses", "", "", "", "", "", ""],
    ["Per cent of 10 trials correct", "", "", "", "", "", ""],
    ["ANIMAL", "15-SECOND DELAY", "", "30-SECOND DELAY", "",
     "60-SECOND DELAY", ""],
    ["", "NS", "ES", "NS", "ES", "NS", "ES"],
    ["I. Mandrill (Pat)", "100", "100", "100", "80", "100", "60"],
    ["II. Baboon (Min)", "100", "100", "100", "100", "100", "70"],
    ["III. Macaque (No. I)", "100", "80", "90", "70", "90", "40"],
    ["IV. Guenon (Mona)", "100", "90", "100", "40", "90", "30"],
    ["V. Macaque (No. IV)", "70", "20", "70", "0", "NR", "NR"],
    ["VI. Mandrill (Xanthippe)", "90", "40", "80", "20", "NR", "NR"],
    ["NS, normal or control series; random order of right and left choices. "
     "ES, experimental series, food is presented on one side four times in "
     "succession before being shifted to the other for the fifth (critical) "
     "trial. Results on only critical trials are recorded. NR, no response.",
     "", "", "", "", "", ""],
]

# --------------------------------------------------------------------------
# TABLE 5 (p.334) -- Tests of retention.  Single header row -> CSV.
# --------------------------------------------------------------------------
T5 = [
    ["TABLE 5", "", "", "", ""],
    ["Tests of retention of delayed reaction method in primates", "", "", "", ""],
    ["ANIMAL", "ORIGINAL TEST SCORE", "RETEST SCORE 10-14 DAYS LATER",
     "SCORE AFTER 4-6 WEEKS OF NO PRACTICE",
     "SCORE AFTER 9-12 WEEKS OF NO PRACTICE"],
    ["Mandrill (Pat)", "58", "59", "58", "56"],
    ["Baboon (Min)", "60", "57", "58", "55"],
    ["Baboon (Tommy)", "57", "57", "42", "49"],
    ["Macacus (Kewpie)", "49", "56", "51", "46"],
    ["Baboon (Andy)", "53", "53", "47", "49"],
    ["Macacus (Sourface)", "51", "54", "38", "51"],
    ["Gibbon (Charlotte)", "50", "52", "51", "49"],
    ["Barbary ape (Blackie)", "50", "49", "46", "47"],
    ["Macacus (No. I)", "42", "44", "44", "37"],
    ["Guenon (Mona)", "42", "44", "36", "33"],
    ["Macacus (No. II)", "40", "38", "40", "32"],
    ["Mangabey (Sooty)", "34", "28", "", ""],
    ["Macacus (No. III)", "36", "31", "33", ""],
    ["Rhesus (No. IV)", "29", "32", "28", ""],
    ["Guenon (Lightning)", "33", "30", "24", "28"],
    ["Guenon (Thunder)", "32", "24", "", ""],
    ["Mandrill (Xanthippe)", "29", "26", "", ""],
    ["Mandrill (Socrates)", "18", "18", "", ""],
    ["Cebus (Scarface Al)", "24", "22", "14", "9"],
    ["Cebus (Bugs)", "18", "21", "14", "16"],
    ["Lemur (Racket)", "21", "14", "16", "11"],
]

# --------------------------------------------------------------------------
# TABLE 6 (p.337) -- direct vs indirect method.  Two-tier header -> XLSX.
# --------------------------------------------------------------------------
T6 = [
    ["TABLE 6", "", "", "", "", "", ""],
    ["Comparison of direct and indirect methods", "", "", "", "", "", ""],
    ["Per cent of correct responses made in 20 trials by 10 primates at delay "
     "intervals of fifteen, thirty, and sixty seconds using both methods",
     "", "", "", "", "", ""],
    ["ANIMAL", "15-SECOND DELAY", "", "30-SECOND DELAY", "",
     "60-SECOND DELAY", ""],
    ["", "DM", "IM", "DM", "IM", "DM", "IM"],
    ["I. Mandrill (Pat)", "100", "100", "100", "100", "100", "100"],
    ["II. Baboon (Min)", "100", "100", "100", "90", "95", "85"],
    ["III. Macaque (Kewpie)", "100", "90", "100", "65", "90", "NR"],
    ["IV. Baboon (Tommy)", "100", "100", "100", "100", "90", "95"],
    ["V. Macaque (No. I)", "100", "90", "100", "75", "90", "70"],
    ["VI. Macaque (Blackie)", "90", "60", "95", "65", "75", "45"],
    ["VII. Gibbon (Charlotte)", "95", "90", "85", "90", "80", "80"],
    ["VIII. Guenon (Thunder)", "80", "NR", "70", "NR", "NR", "NR"],
    ["IX. Guenon (Mona)", "100", "NR", "90", "NR", "75", "NR"],
    ["X. Cebus (Bugs)", "65", "NR", "NR", "NR", "NR", "NR"],
    ["DM, direct method. IM, indirect method. NR, animal would not respond.",
     "", "", "", "", "", ""],
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
    write_csv("Harlow_etal_1932_TABLE1_snapshot.csv", TABLE1)
    write_xlsx("Harlow_etal_1932_TABLE2_snapshot.xlsx",
               T2_HEADER + T2_ROWS + T2_FOOT, "TABLE2")
    write_xlsx("Harlow_etal_1932_TABLE3_snapshot.xlsx", T3, "TABLE3")
    write_xlsx("Harlow_etal_1932_TABLE4_snapshot.xlsx", T4, "TABLE4")
    write_csv("Harlow_etal_1932_TABLE5_snapshot.csv", T5)
    write_xlsx("Harlow_etal_1932_TABLE6_snapshot.xlsx", T6, "TABLE6")


if __name__ == "__main__":
    main()
