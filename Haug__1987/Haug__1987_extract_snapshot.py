#!/usr/bin/env python3
"""Haug__1987_extract_snapshot.py -- build the frozen snapshot of Haug (1987) TABLE 2 from the
PDF's text layer (journal p. 128 = PDF p. 3).

The PDF is a scan with an OCR text layer, so the layer is NOT trusted blindly: every row is
assembled from word coordinates (row = y band; column = x band), and the handful of cells where the
layer disagrees with the printed page are listed in OCR_FIXES below. Each of those was checked
against a render of the page. No table VALUE is typed into this script: numbers, Latin names and
common names come from the text layer; OCR_FIXES only repairs characters the layer got wrong.

Run: python3 Haug__1987_extract_snapshot.py [--force]
Writes Haug__1987_TABLE2_snapshot.xlsx (sheet "TABLE2"): row 1 = printed caption, rows 2-3 = the
two header tiers, rows 4+ = the 42 printed rows in printed order, last row = the printed footnote.
Refuses to overwrite an existing snapshot whose cells differ (the frozen copy must not drift).
"""
import os, re, sys
import pymupdf, openpyxl

HERE = os.path.dirname(os.path.abspath(__file__))
PDF = os.path.join(HERE, "Haug-1987-Brain sizes, surface.pdf")
OUT = os.path.join(HERE, "Haug__1987_TABLE2_snapshot.xlsx")
PAGE = 2                                    # 0-based -> PDF page 3

# column x-bands in PDF points (from the text layer's word boxes)
X_NO, X_ABBR, X_LATIN, X_COMMON, X_BRVO, X_REG = (100, 130), (130, 160), (160, 290), (290, 405), (405, 450), (450, 490)
Y_TOP, Y_BOT = 150, 530

# (row no, field) -> value printed on the page where the OCR layer differs
OCR_FIXES = {
    (8, "abbr"): "US", (10, "abbr"): "CC", (11, "abbr"): "CC", (16, "abbr"): "OS", (20, "abbr"): "OC",
    (9, "latin"): "Panthera leo", (13, "latin"): "Procyon lotor",
    (41, "common"): "Mouse opossum",
    (33, "reg"): "221",                      # layer splits "221" into "22" + "1"
}

doc = pymupdf.open(PDF)
words = [w for w in doc[PAGE].get_text("words") if Y_TOP < w[1] < Y_BOT]
words.sort(key=lambda w: ((w[1] + w[3]) / 2, w[0]))
rows, cur = [], []
for w in words:
    yc = (w[1] + w[3]) / 2
    if cur and abs(yc - cur[-1][0]) > 3.5:
        rows.append(cur); cur = []
    cur.append((yc, w))
if cur: rows.append(cur)

def band(r, xr):
    return " ".join(w[4] for _, w in sorted(r, key=lambda t: t[1][0]) if xr[0] <= w[0] < xr[1])

data = []
for r in rows:
    no = band(r, X_NO)
    if not re.fullmatch(r"\d{1,2}", no): continue
    n = int(no)
    rec = dict(no=no, abbr=band(r, X_ABBR), latin=band(r, X_LATIN), common=band(r, X_COMMON),
               brvo=band(r, X_BRVO), reg=band(r, X_REG).replace(" ", ""))
    for k in ("abbr", "latin", "common", "reg"):
        if (n, k) in OCR_FIXES: rec[k] = OCR_FIXES[(n, k)]
    data.append(rec)
data.sort(key=lambda d: int(d["no"]))
assert [int(d["no"]) for d in data] == list(range(1, 43)), "expected rows 1..42"

CAPTION = ("TABLE 2. The various species of this investigation including the brain volume (Br-vo) in cm3 "
           "and our register number\u00b9")
FOOTNOTE = ("\u00b9In all primates including prosimians the lateral convexity of the frontal cortex was "
            "microscopically estimated. For further details see Table 3.")
cells = [[CAPTION, None, None, None, None, None],
         [None, "Abbr.", "Latin name", "Common name", "Br-vo", "Reg."],
         [None, None, None, None, None, "no."]]
cells += [[d["no"], d["abbr"], d["latin"], d["common"], d["brvo"], d["reg"]] for d in data]
cells += [[FOOTNOTE, None, None, None, None, None]]

if os.path.exists(OUT) and "--force" not in sys.argv:
    old = [[(c if c is not None else None) for c in row] for row in
           openpyxl.load_workbook(OUT)["TABLE2"].iter_rows(values_only=True)]
    new = [[(str(c) if c is not None else None) for c in row] for row in cells]
    old = [[(str(c) if c is not None else None) for c in row] for row in old]
    if old != new:
        sys.exit("REFUSING to overwrite %s: extracted cells differ from the frozen copy. "
                 "Inspect the difference; use --force only for a deliberate re-freeze." % OUT)
    print("snapshot unchanged:", OUT); sys.exit(0)

wb = openpyxl.Workbook(); ws = wb.active; ws.title = "TABLE2"
for row in cells: ws.append(row)
for r in range(1, ws.max_row + 1):                     # every cell stored as text, exactly as printed
    for c in range(1, 7):
        cell = ws.cell(r, c)
        if cell.value is not None: cell.value = str(cell.value); cell.number_format = "@"
wb.save(OUT)
print("wrote", OUT, "-", len(data), "rows")
