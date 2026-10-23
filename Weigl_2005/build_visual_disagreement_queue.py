"""List ages that still require page-image review after conservative OCR agreement."""

import csv
from pathlib import Path

root = Path(__file__).resolve().parent
rows = list(csv.DictReader((root / "Weigl__2005_Records.csv").open(newline="", encoding="utf-8")))
fields = [
    "source_id", "printed_page", "pdf_page", "record_on_page", "record_y_pdf",
    "taxon_printed_ocr", "age_years_ocr", "age_months_ocr",
    "age_years_ocr2", "age_months_ocr2", "age_candidate_basis",
    "age_years_candidate", "age_months_candidate", "qa_flags",
]
out = root / "Weigl_2005_visual_disagreement_queue.csv"
with out.open("w", newline="", encoding="utf-8") as f:
    writer = csv.DictWriter(f, fieldnames=fields)
    writer.writeheader()
    writer.writerows({key: row[key] for key in fields} for row in rows if row["age_review_level"] == "OCR_draft")
print(f"Wrote {out}")
