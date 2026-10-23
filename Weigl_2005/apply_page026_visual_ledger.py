"""Apply the printed-page-26 image ledger to the draft and frozen snapshot.

The ledger verifies row starts, taxon labels, sex/count, and primary ages only.
OCR prose and parenthesized alternative ages retain their draft status.
"""

import csv
from pathlib import Path

ROOT = Path(__file__).resolve().parent
LEDGER = ROOT / "page026_visual_ledger.csv"
with LEDGER.open(encoding="utf-8", newline="") as f:
    checks = list(csv.DictReader(f))
assert len(checks) == 20
assert [int(x["row_on_page"]) for x in checks] == list(range(1, 21))

for path in (ROOT / "Weigl_2005_records_OCR_draft.csv",
             ROOT / "Weigl__2005_Records_snapshot.csv"):
    with path.open(encoding="utf-8", newline="") as f:
        reader = csv.DictReader(f)
        fields = list(reader.fieldnames)
        rows = list(reader)
    page = [x for x in rows if x["printed_page"] == "26"]
    assert len(page) == 20
    for row, checked in zip(page, checks):
        assert int(row["record_on_page"]) == int(checked["row_on_page"])
        assert row["source_id"] == f"Weigl_2005_p026_r{int(checked['row_on_page']):03d}"
        for field in ("taxon_printed_verified", "sex_count_verified",
                      "age_years_verified", "age_months_verified", "age_qualifier_verified"):
            row[field] = checked[field]
        row["age_days_verified"] = ""
        row["age_visual_check"] = "primary printed age checked from page image"
        row["row_start_visual_check"] = "2026-10-22; printed page image"
        row["review_status"] = "row start, taxon, sex/count, and primary age visually checked; prose and alternatives pending"
        flags = [x for x in row["qa_flags"].split("; ") if x]
        flags.append("visual_primary_age_supersedes_ocr_candidate")
        row["qa_flags"] = "; ".join(dict.fromkeys(flags))
    with path.open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fields)
        writer.writeheader()
        writer.writerows(rows)
    print(f"Applied 20 page-26 checks to {path.name}")
