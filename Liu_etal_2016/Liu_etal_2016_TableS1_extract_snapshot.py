#!/usr/bin/env python3
"""Build Liu_etal_2016_TableS1_snapshot.xlsx from the SI PDF (printed source -> snapshot).

The SI (rspb20161923_si_001.pdf) is a PDF of the tables, not a data file, so a hand-verifiable
snapshot is required (__HOWTO_build_a_dataset_file.md sec 0a invariant 1). Table S1 runs from
page 7 to page 10.

How the species blocks are recovered
------------------------------------
The Species cell is a MERGED cell: the binomial is printed once, vertically centred in its block
of specimen rows. Centring is not reliable enough to segment on, so this script uses the table's
own drawn cell borders instead: the thin (<1 pt) rules that span the Species column
(x approx 36-119) are exactly the block boundaries. Rows between two consecutive rules are one
species; a block that runs past the foot of a page continues in the first segment of the next.

The snapshot expands the merged cell, i.e. writes the species on EVERY row of its block. That is
the cell's actual value; the README records that the PDF prints it once.

Nothing else is changed: values, the museum Key, column order and row order are all verbatim.
No R in this environment, hence Python (same pattern as Jacobs_etal_2018_extract_snapshot.py).
"""

import bisect
import collections
import os
import re

import pdfplumber
from openpyxl import Workbook

HERE = os.path.dirname(os.path.abspath(__file__))
PDF = os.path.join(HERE, "rspb20161923_si_001.pdf")
OUT = os.path.join(HERE, "Liu_etal_2016_TableS1_snapshot.xlsx")
PAGES = (6, 7, 8, 9)                      # 0-based: printed pages 7-10
SPRE = re.compile(r"^(Homo|Pan|Gorilla|Pongo|Hylobates|Macaca|Papio|Presbytis|Sapajus|Cebus|"
                  r"Alouatta)\b")
CONT = ("fascicularis",)                  # second line of a wrapped binomial

CAPTION = (
    "Table S1. Hand proportions of the anthropoid samples and their predicted results of "
    "manipulative potentials. The length of each hand segment in the samples is the proportion "
    "relative to the overall length of thumb and forefinger of associated hand skeletons. The raw "
    "morphometrics of these samples are taken from the literature [1]. The museum keys are as "
    "follows: AMNH, American Museum of Natural History New York; HMNH, Harvard Museum of Natural "
    "History; YPM, Yale Peabody Museum; UM-APC, University of Massachusetts Amherst; ZMB, Museum "
    "für Naturkunde Berlin; NMW, Naturhistorisches Museum Wien; UV, University of Vienna; "
    "UNI-Fl, University of Florence; MRAC, Musée royal de L'Afrique central; NME, National "
    "Museum of Ethiopia; WITS, University of this Witwatersrand. Abbreviation: MC1, metacarpal of "
    "thumb; PP1, proximal phalanx of thumb; DP1, distal phalanx of thumb; MC2, metacarpal of "
    "forefinger; PP2, proximal phalanx of forefinger; IP2, intermediate phalanx of forefinger; "
    "DP2, distal phalanx of forefinger; WS, workspace; GMI, global manipulation index."
)
HEADER = ["Species", "Key", "MC1", "PP1", "DP1", "MC2", "PP2", "IP2", "DP2", "WS", "GMI"]


def extract():
    items, rules = [], {}
    with pdfplumber.open(PDF) as pdf:
        for pi in PAGES:
            page = pdf.pages[pi]
            rules[pi] = sorted(r["top"] for r in page.rects
                               if r["height"] < 1.0 and r["x0"] < 40 and r["x1"] > 110)
            by_line = collections.defaultdict(list)
            for w in page.extract_words():
                by_line[round(w["top"], 1)].append(w)
            for top in sorted(by_line):
                ws = sorted(by_line[top], key=lambda w: w["x0"])
                nums = [w for w in ws if w["x0"] > 200 and re.fullmatch(r"0\.\d+", w["text"])]
                left = " ".join(w["text"] for w in ws if w["x0"] < 120).strip()
                if len(nums) == 9:
                    key = " ".join(w["text"] for w in ws if 120 <= w["x0"] < 200)
                    items.append((pi, top, "row", (key, [w["text"] for w in nums])))
                if left and (SPRE.match(left) or left in CONT):
                    items.append((pi, top, "lab", left))

    # group into (page, segment) buckets delimited by the Species-column rules
    buckets = collections.OrderedDict()
    for pi, top, kind, payload in items:
        seg = (pi, bisect.bisect_left(rules[pi], top))
        buckets.setdefault(seg, []).append((kind, payload))

    blocks, current = [], None
    for seg, entries in buckets.items():
        labels = [p for k, p in entries if k == "lab"]
        rows = [p for k, p in entries if k == "row"]
        if labels:                                   # a new species block starts here
            current = {"species": " ".join(labels), "rows": []}
            blocks.append(current)
        elif current is None:
            raise RuntimeError("rows found before any species label at segment %s" % (seg,))
        current["rows"].extend(rows)                 # unlabelled segment = block continued
    return blocks


def main():
    blocks = extract()
    wb = Workbook()
    ws = wb.active
    ws.title = "TableS1"
    ws.append([CAPTION] + [None] * (len(HEADER) - 1))
    ws.append(HEADER)
    n = 0
    for b in blocks:
        for key, vals in b["rows"]:
            ws.append([b["species"], key] + vals)
            n += 1
    wb.save(OUT)
    print("%s: %d species, %d specimen rows" % (os.path.basename(OUT), len(blocks), n))
    for b in blocks:
        print("   %-24s n=%d" % (b["species"], len(b["rows"])))


if __name__ == "__main__":
    main()
