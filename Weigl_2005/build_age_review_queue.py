"""Summarize unfinished page-image review from the registered Weigl table."""

import csv
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parent
SOURCE = ROOT / "Weigl__2005_Records.csv"
OUTPUT = ROOT / "Weigl_2005_age_review_queue.csv"
with SOURCE.open(encoding="utf-8", newline="") as f:
    rows = list(csv.DictReader(f))
by_page = defaultdict(list)
for row in rows:
    by_page[int(row["printed_page"])].append(row)
with OUTPUT.open("w", encoding="utf-8", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=[
        "printed_page", "pdf_page", "candidate_rows", "age_checked_rows",
        "age_pending_rows", "two_ocr_readings_agree_pending",
        "two_ocr_agreement_accepted", "visual_disagreement_or_alignment_pending",
        "row_alignment_status",
    ])
    writer.writeheader()
    for page in sorted(by_page):
        page_rows = by_page[page]
        pending = [r for r in page_rows if r["age_review_level"] != "image_checked"]
        if not pending:
            continue
        agreement = sum(
            bool(r["age_years_ocr"])
            and r["age_years_ocr"] == r["age_years_ocr2"]
            and r["age_months_ocr"] == r["age_months_ocr2"]
            for r in pending
        )
        writer.writerow({
            "printed_page": page,
            "pdf_page": page - 19,
            "candidate_rows": len(page_rows),
            "age_checked_rows": len(page_rows) - len(pending),
            "age_pending_rows": len(pending),
            "two_ocr_readings_agree_pending": agreement,
            "two_ocr_agreement_accepted": sum(r["age_review_level"] == "two_OCR_agree" for r in pending),
            "visual_disagreement_or_alignment_pending": sum(r["age_review_level"] == "OCR_draft" for r in pending),
            "row_alignment_status": "requires visual row-start reconciliation" if (page < 93 or page in (93, 95)) else "not yet checked",
        })
print(f"Wrote {OUTPUT}")
