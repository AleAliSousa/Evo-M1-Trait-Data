#!/usr/bin/env python3
"""Extract printed Table I, PDF pp.5-11; checked OCR overlay is item-scoped.

Requires pdfplumber. The snapshot is a published-table view, including the
inherited order/family headings and the printed units. Never cleans taxonomy,
subtracts the later 0.59 g correction, or converts a weight estimate to volume.
"""
import csv
import io
from pathlib import Path
import pdfplumber

folder = Path(__file__).resolve().parent
item_name = Path(__file__).stem.replace("_extract_snapshot", "")
records = []
order, family = "Rodentia", ""
with pdfplumber.open(folder / "Mace-1981-Brain size and ecolo.pdf") as doc:
    for page_number in range(5, 12):
        words = doc.pages[page_number-1].extract_words(x_tolerance=1.5, y_tolerance=2)
        anchors = []
        for w in words:
            if 100 < w["x0"] < 230 and (150 if page_number == 5 else 130) < w["top"] < (540 if page_number == 5 else 620 if page_number == 11 else 670):
                a = next((a for a in anchors if abs(a["y"] - w["top"]) < 2.5), None)
                if a is None:
                    a = {"y": w["top"], "words": []}
                    anchors.append(a)
                a["words"].append(w)
        for a in sorted(anchors, key=lambda a: a["y"]):
            label = " ".join(w["text"] for w in sorted(a["words"], key=lambda w: w["x0"]))
            if label.replace(" ", "").upper().startswith("INSECTIVOR"):
                order = "Insectivora"
            elif label.replace(" ", "").upper() == "LAGOMORPHA":
                order = "Lagomorpha"
            if label.replace(" ", "").endswith("idae"):
                family = label.replace(" ", "")
            if len(label.split()) < 2:
                continue
            cells = [" ".join(w["text"] for w in words if lo <= w["x0"] < hi and abs(w["top"] - a["y"]) < 3)
                     for lo, hi in [(230,277), (277,318), (318,360), (360,401)]]
            if not any(any(c.isdigit() for c in s) for s in cells[-3:]):
                continue
            records.append(dict(source_row=str(len(records)+1), source_pdf_page=str(page_number),
                                order_as_printed=order, family_as_printed=family,
                                species_as_printed=label, ecology_as_printed=cells[0],
                                body_weight_g_as_printed=cells[1], body_length_mm_as_printed=cells[2],
                                brain_weight_g_as_printed=cells[3]))

# The overlay records only OCR-to-print corrections established visually from
# these exact PDF pages. It is not a biological or taxonomic correction.
with (folder / "reference_tables" / (item_name + "_extraction_corrections.csv")).open(encoding="utf-8-sig") as f:
    for change in csv.DictReader(f):
        row = records[int(change["source_row"])-1]
        assert row[change["column"]] == change["extracted"], change
        row[change["column"]] = change["printed"]
assert len(records) == 278
buf = io.StringIO()
w = csv.DictWriter(buf, fieldnames=list(records[0]), lineterminator="\n")
w.writeheader()
w.writerows(records)
target = folder / (item_name + "_snapshot.csv")
payload = buf.getvalue()
if target.exists() and target.read_text(encoding="utf-8-sig") != payload:
    raise RuntimeError("Refusing to overwrite a differing frozen snapshot; inspect the source/overlay first")
target.write_text(payload, encoding="utf-8-sig")
print(f"{item_name}: {len(records)} printed rows extracted")
