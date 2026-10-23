"""Apply visually checked primary ages on printed pages 27–34."""
import csv
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent
checks = {}
for ledger in ("page027-030_visual_ages.json", "page031-034_visual_ages.json",
               "page035-038_visual_ages.json", "page039-042_visual_ages.json",
               "page043-046_visual_ages.json", "page047-050_visual_ages.json",
               "page051-054_visual_ages.json", "page055-058_visual_ages.json",
               "page060-062_visual_ages.json", "page064-066_visual_ages.json",
               "page068-070_visual_ages.json", "page072-074_visual_ages.json",
               "page076-078_visual_ages.json", "page080_visual_ages.json",
               "page082-084_visual_ages.json", "page086-088_visual_ages.json",
               "page090-092_visual_ages.json", "page094-096_visual_ages.json",
               "page098_visual_ages.json"):
    checks.update(json.loads((ROOT / ledger).read_text()))
for path in (ROOT / "Weigl_2005_records_OCR_draft.csv", ROOT / "Weigl__2005_Records_snapshot.csv"):
    with path.open(encoding="utf-8", newline="") as f:
        reader = csv.DictReader(f)
        fields = list(reader.fieldnames)
        rows = list(reader)
    for page, ages in checks.items():
        if page == "scope":
            continue
        page_rows = [r for r in rows if r["printed_page"] == page]
        assert len(page_rows) == len(ages), (page, len(page_rows), len(ages))
        for row, age in zip(page_rows, ages):
            if isinstance(age, dict):
                row["age_years_verified"] = ""
                row["age_months_verified"] = ""
                row["age_days_verified"] = str(age["days"])
                row["age_qualifier_verified"] = ""
            else:
                row["age_years_verified"] = str(age[0])
                row["age_months_verified"] = str(age[1])
                row["age_qualifier_verified"] = age[2] if len(age) == 3 else ""
                row["age_days_verified"] = ""
            row["age_visual_check"] = "primary printed age checked from page image"
            row["review_status"] = "primary age visually checked; taxon, prose, and alternatives pending"
    with path.open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fields)
        writer.writeheader()
        writer.writerows(rows)
    print(f"Applied {sum(len(x) for p,x in checks.items() if p != 'scope')} primary ages to {path.name}")
