"""Apply the primary-age image checks for printed pages 21–25.

The source text, names, and parenthesized alternative ages remain OCR drafts.
"""

import csv
import json
from collections import defaultdict
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
TABLE = ROOT / "review/Weigl_2005_records_OCR_draft.csv"
CHECKS = ROOT / "review/visual_age_checks_21-25.json"
with TABLE.open(encoding="utf-8") as f:
    rows = list(csv.DictReader(f))
fields = list(rows[0])
extra = ["age_years_verified", "age_months_verified", "age_days_verified", "age_visual_check"]
fields = [name for name in fields if name not in extra] + extra
checks = json.loads(CHECKS.read_text(encoding="utf-8"))
by_page = defaultdict(list)
for row in rows:
    by_page[row["printed_page"]].append(row)

for page, ages in checks.items():
    if page == "scope":
        continue
    page_rows = sorted(by_page[page], key=lambda row: int(row["record_on_page"]))
    if len(page_rows) != len(ages):
        raise ValueError(f"Printed page {page}: {len(page_rows)} rows but {len(ages)} visual ages")
    for row, age in zip(page_rows, ages):
        row["age_years_verified"] = ""
        row["age_months_verified"] = ""
        row["age_days_verified"] = ""
        if isinstance(age, dict):
            row["age_days_verified"] = age["days"]
        else:
            row["age_years_verified"], row["age_months_verified"] = age
            if row["age_candidate_basis"] and (
                str(row["age_years_candidate"]) != str(age[0])
                or str(row["age_months_candidate"]) != str(age[1])
            ):
                flags = [f for f in row["qa_flags"].split("; ") if f]
                flags.append("ocr_age_conflicts_with_visual")
                row["qa_flags"] = "; ".join(flags)
        row["age_visual_check"] = "primary printed age checked from page image"
        row["review_status"] = "primary age visually checked; other fields require image review"

tmp = TABLE.with_suffix(".tmp")
with tmp.open("w", encoding="utf-8", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=fields)
    writer.writeheader()
    writer.writerows(rows)
tmp.replace(TABLE)
print(f"Applied {sum(len(v) for k,v in checks.items() if k != 'scope')} visual primary-age checks")
