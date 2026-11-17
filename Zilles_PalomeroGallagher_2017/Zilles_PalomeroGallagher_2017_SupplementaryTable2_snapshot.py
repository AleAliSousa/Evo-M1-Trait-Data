#!/usr/bin/env python
"""Zilles & Palomero-Gallagher (2017) Front Neuroanat 11:78 — Supplementary Table 2.
Snapshot script: PDF text layer -> <Item>_snapshot.csv.  Writes ONLY the snapshot.

Source: supplementary_downloads/Table_2.pdf (Frontiers supplementary file, 24 pages, text layer;
download recorded in supplementary_downloads/download_manifest.csv).  The table is 15 receptor
blocks (one per receptor, in printed order) x 44 cortical areas; per area and stratum
(supragranular, granular, infragranular, all layers) the page prints  mean (SD) CV.

Why Python/pdfplumber and not R/pdftools: the caption carries meaning through highlighting
("Primary sensory areas are highlighted in yellow, the primary motor cortex in grey").  pdfplumber
exposes the fill rectangles behind each row, so the highlight colour can be frozen into the
snapshot as printed (column `highlight`); pdftools exposes only text.  Values are taken from the
text layer with anchored regular expressions — no table value is typed in this script.

House rules: the snapshot keeps the printed layout (one row per printed area row, receptor label as
printed, `(SD)` kept in parentheses, `--` kept as printed, row/column order unchanged).  The
companion <Item>.R reads this file and never writes it.  The script refuses to overwrite a
differing frozen copy unless run with --force (then explain the change in the README).

Run:  conda run -n neuro-atlas python <this file>   (needs pdfplumber)
"""
import csv, os, re, sys, io

HERE      = os.path.dirname(os.path.abspath(__file__))
item_name = os.path.splitext(os.path.basename(__file__))[0].removesuffix("_snapshot")
pdf_path  = os.path.join(HERE, "supplementary_downloads", "Table_2.pdf")
out_csv   = os.path.join(HERE, item_name + "_snapshot.csv")

import pdfplumber

# one printed data row: Region, then 4 x [mean (SD) CV]; '--' where the stratum is absent
TOKEN = r"(\d+|--)\s+(\(\d+\)|--)\s+(\d\.\d+|--)"
ROW   = re.compile(r"^(\S+)\s+" + r"\s+".join([TOKEN] * 4) + r"\s*$")
HEADER = "Region supragranular (SD) CV granular (SD) CV infragranular (SD) CV all layers (SD) CV"

def fill_colour(c):
    """pdfplumber non_stroking_color -> 'yellow' | 'grey' | None (white/black/none)."""
    if c is None:
        return None
    c = tuple(round(float(x), 2) for x in (c if isinstance(c, (list, tuple)) else (c,)))
    if c in ((1.0, 1.0, 0.0),):
        return "yellow"
    if len(c) == 1 and 0.0 < c[0] < 1.0:
        return "grey"
    if len(c) == 3 and len(set(c)) == 1 and 0.0 < c[0] < 1.0:
        return "grey"
    return None

rows = []
block = 0
receptor_printed = None
caption = []
with pdfplumber.open(pdf_path) as pdf:
    for pno, page in enumerate(pdf.pages, start=1):
        rects = [(r, fill_colour(r.get("non_stroking_color"))) for r in page.rects
                 if r["width"] > 20 and r["height"] > 5]
        rects = [(r, col) for r, col in rects if col]
        lines = page.extract_text_lines()
        texts = [ln["text"].strip() for ln in lines]
        for i, (ln, text) in enumerate(zip(lines, texts)):
            m = ROW.match(text)
            if m:
                cols = {col for r, col in rects
                        if r["top"] <= ln["top"] + 2 and r["bottom"] >= ln["bottom"] - 2}
                hl = "|".join(sorted(cols))
                rows.append([pno, block, receptor_printed, *m.groups(), hl])
            elif text == HEADER:
                continue
            elif i + 1 < len(texts) and texts[i + 1] == HEADER:
                # the line printed directly above a column-header line is the receptor label
                block += 1
                receptor_printed = text
            elif pno == 1 and block == 0:
                caption.append(text)
            else:
                # a receptor label whose header line fell on the next page (GABA-B, p.8/9)
                block += 1
                receptor_printed = text

# sanity: 15 blocks x 44 areas, every area appears once per block
assert block == 15, f"expected 15 receptor blocks, found {block}"
assert len(rows) == 15 * 44, f"expected 660 data rows, found {len(rows)}"
areas_per_block = {}
for r in rows:
    areas_per_block.setdefault(r[1], []).append(r[3])
first = areas_per_block[1]
assert len(first) == 44 and all(v == first for v in areas_per_block.values()), "area order differs between blocks"

header = ["page", "receptor_block", "receptor (as printed)", "Region",
          "supragranular", "(SD)", "CV",
          "granular", "(SD)", "CV",
          "infragranular", "(SD)", "CV",
          "all layers", "(SD)", "CV",
          "highlight"]
buf = io.StringIO()
w = csv.writer(buf, lineterminator="\n")
w.writerow(header)
w.writerows(rows)
new = buf.getvalue()

if os.path.exists(out_csv) and "--force" not in sys.argv:
    old = open(out_csv, encoding="utf-8").read()
    if old != new:
        sys.exit(f"Frozen snapshot differs from the fresh extraction: {out_csv}\n"
                 "Not overwritten. Re-run with --force only after checking the PDF and noting the change in the README.")
    print("Snapshot unchanged:", os.path.basename(out_csv))
else:
    with open(out_csv, "w", encoding="utf-8", newline="") as fh:
        fh.write(new)
    print("Wrote", len(rows), "rows ->", os.path.basename(out_csv))
print("Caption as printed:", " ".join(caption))
