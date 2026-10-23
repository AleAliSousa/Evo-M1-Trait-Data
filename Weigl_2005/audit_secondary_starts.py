"""Flag image-OCR record lines absent from the PDF-text row extraction.

This is a review queue, never an automatic addition to the source-record table.
Run after secondary_ocr.cjs has produced page TSV files.
"""

import csv
import os
import re
from collections import defaultdict
from pathlib import Path

import pdfplumber

ROOT = Path(__file__).resolve().parent
PDF = ROOT / "Weigl_2005_LongevityOfMammalsInCaptivity_pp21-210.pdf"
TABLE = ROOT / "Weigl_2005_records_OCR_draft.csv"
OCR_DIR = Path(os.environ.get("OCR_OUT_DIR", "/tmp/weigl-secondary-ocr"))
OUT = ROOT / "Weigl_2005_secondary_possible_missing_rows.csv"

with TABLE.open(encoding="utf-8") as f:
    rows = list(csv.DictReader(f))
known = defaultdict(list)
for row in rows:
    known[int(row["pdf_page"])].append(float(row["record_y_pdf"]))

findings = []
with pdfplumber.open(PDF) as doc:
    for pdf_page in range(2, 181):
        if pdf_page + 19 in {97, 101, 105, 107}:
            # These pages have complete image-checked row ledgers.
            continue
        page = doc.pages[pdf_page - 1]
        entries = []
        with (OCR_DIR / f"page-{pdf_page:03d}.tsv").open(encoding="utf-8") as f:
            for raw in f:
                parts = raw.rstrip("\n").split("\t", 11)
                if len(parts) == 12 and parts[0] == "5" and parts[11].strip():
                    entries.append(parts)
        # TSV word widths are not page widths; use the level-1 header instead.
        with (OCR_DIR / f"page-{pdf_page:03d}.tsv").open(encoding="utf-8") as f:
            header = f.readline().rstrip("\n").split("\t", 11)
            image_width, image_height = int(header[8]), int(header[9])
        groups = defaultdict(list)
        for word in entries:
            groups[tuple(word[2:5])].append(word)
        for words in groups.values():
            text = " ".join(w[11] for w in sorted(words, key=lambda w: int(w[6])))
            x = min(int(w[6]) for w in words) * page.width / image_width
            y = min(int(w[7]) for w in words) * page.height / image_height
            if not (25 <= x <= 65 and 55 <= y <= page.height - 30):
                continue
            if not re.search(r"\b(?:died|living|released|escaped|born)\b", text, re.I):
                continue
            if not re.search(r"\b\d{1,2}\s+[A-Z]{3}\s+\d{4}\b", text, re.I):
                continue
            distance = min((abs(y - start) for start in known[pdf_page]), default=999)
            # The two OCR engines place a line's top several PDF points apart.
            # Six points produced many matches masquerading as missing rows.
            if distance < 11:
                continue
            findings.append({
                "printed_page": pdf_page + 19,
                "pdf_page": pdf_page,
                "image_ocr_y_pdf": f"{y:.2f}",
                "image_ocr_x_pdf": f"{x:.2f}",
                "nearest_existing_start_distance_pdf": f"{distance:.2f}",
                "image_ocr_line": text,
                "review_status": "possible missing record; visual review required",
            })

with OUT.open("w", encoding="utf-8", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=findings[0].keys())
    writer.writeheader()
    writer.writerows(findings)
print(f"{len(findings)} secondary OCR possible missing starts")
