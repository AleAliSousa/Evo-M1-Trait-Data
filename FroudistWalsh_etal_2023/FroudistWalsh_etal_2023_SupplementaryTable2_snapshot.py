#!/usr/bin/env python
"""Froudist-Walsh S, Xu T, Niu M, Rapan L, Zhao L, Margulies DS, Zilles K, Wang X-J, Palomero-Gallagher N (2023)
Gradients of neurotransmitter receptor expression in the macaque cortex. Nat Neurosci 26:1281-1294.
doi:10.1038/s41593-023-01351-2 -- Supplementary Information PDF, Supplementary Table 2 (Standard deviation of receptor density per neuron, fmol/neuron).

Snapshot script: PDF text layer -> <Item>_snapshot.csv.  Writes ONLY the snapshot.

Source: supplementary_downloads/41593_2023_1351_MOESM1_ESM.pdf (Springer ESM, 24 pages, text layer; URL, bytes
and sha256 in supplementary_downloads/download_manifest.csv).  The table is printed over 4 consecutive pages:
one row per cortical area (109 areas of the Julich Brain Macaque Maps), 14 receptor columns in printed order
AMPA kainate NMDA GABAA GABAB GABAA/BZ M1 M2 M3 alpha1 alpha2 5HT1A 5HT2A D1.  Values are fmol/neuron as printed
(Supplementary Table 2 prints 'N/A' for areas with data from one brain only; kept as printed).

Method: the table's pages are located by the printed caption ("Supplementary Table N." as the first text line of
the page; the table ends at the page before the next caption).  Every printed data row is pulled from the text
layer with an anchored regular expression (area label, then exactly 14 numeric-or-N/A tokens); the column header,
which the text layer renders with the subscripts broken onto their own lines, is re-joined from those lines and
asserted against the expected labels.  No table value is typed in this script.  The snapshot keeps the printed
layout: page, row order within the table, area as printed, 14 receptor columns as printed.  The companion
<Item>.R reads this file and never writes it.  The script refuses to overwrite a differing frozen copy unless run
with --force (then explain the change in the README).

Run:  conda run -n neuro-atlas python <this file>   (needs pdfplumber)
"""
import csv, io, os, re, sys

HERE      = os.path.dirname(os.path.abspath(__file__))
item_name = os.path.splitext(os.path.basename(__file__))[0].removesuffix("_snapshot")
table_no  = int(re.search(r"SupplementaryTable(\d+)$", item_name).group(1))
pdf_path  = os.path.join(HERE, "supplementary_downloads", "41593_2023_1351_MOESM1_ESM.pdf")
out_csv   = os.path.join(HERE, item_name + "_snapshot.csv")

import pdfplumber

NUM = r"(?:-?\d+(?:\.\d+)?|N/A)"
ROW = re.compile(r"^(\S+)((?:\s+" + NUM + r"){14})\s*$")        # area label (no spaces in this table) + 14 cells
CAPTION = re.compile(r"^Supplementary Table (\d+)\.\s*(.*)$")
EXPECTED_HEADER = ["AMPA", "kainate", "NMDA", "GABAA", "GABAB", "GABAA/BZ", "M1", "M2", "M3",
                   "α1", "α2", "5HT1A", "5HT2A", "D1"]

rows, caption, footnotes, header_printed = [], None, [], None
with pdfplumber.open(pdf_path) as pdf:
    pages = [(i + 1, (pg.extract_text() or "").split("\n")) for i, pg in enumerate(pdf.pages)]
# pages of this table: from its caption page to the page before the next caption
start = next(i for i, (pno, ls) in enumerate(pages)
             if ls and (m := CAPTION.match(ls[0])) and int(m.group(1)) == table_no)
end = next((i for i, (pno, ls) in enumerate(pages) if i > start and ls and CAPTION.match(ls[0])), len(pages))
for pno, ls in pages[start:end]:
    for i, line in enumerate(ls):
        m = ROW.match(line)
        if m:
            rows.append([pno, len(rows) + 1, m.group(1), *m.group(2).split()])
        elif (c := CAPTION.match(line)):
            caption = c.group(2)
            # header: the lines between the caption and the first data row, subscripts on their own lines
            j = i + 1
            hdr = []
            while j < len(ls) and not ROW.match(ls[j]):
                hdr.append(ls[j].strip()); j += 1
            header_printed = hdr
        elif re.fullmatch(r"\d+", line.strip()):
            continue                                              # printed page number
        elif rows and not ROW.match(line):
            footnotes.append(line.strip())

# re-join the header lines: 'AMPA kainate NMDA GABA' 'A' 'GABA' 'B' 'GABA' 'A/BZ' 'M' '1' ... -> 14 labels
toks = " ".join(header_printed).split()
labels, k = [], 0
while k < len(toks):
    t = toks[k]
    if t in ("GABA", "M", "α", "5HT", "D") and k + 1 < len(toks):
        labels.append(t + toks[k + 1]); k += 2
    else:
        labels.append(t); k += 1
assert labels == EXPECTED_HEADER, f"unexpected header: {labels}"
assert len(rows) == 109, f"expected 109 area rows, found {len(rows)}"
assert len({r[2] for r in rows}) == 109, "duplicate area label"

header = ["page", "printed_order", "area"] + EXPECTED_HEADER
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
print("Table pages:", pages[start][0], "-", pages[end - 1][0])
print("Caption as printed:", caption)
print("Footnotes as printed:", " ".join(footnotes) if footnotes else "(none)")
