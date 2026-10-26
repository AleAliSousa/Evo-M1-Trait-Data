"""Apply visually checked primary ages from all printed-page ledgers."""
import csv
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
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
               "page098_visual_ages.json", "page100-102_visual_ages.json",
               "page104-110_visual_ages.json", "page111-116_visual_ages.json",
               "page121-122_visual_ages.json", "page124-136_visual_ages.json",
               "page137-140_visual_ages.json", "page141-150_visual_ages.json",
               "page151-157_visual_ages.json", "page159-160_visual_ages.json",
               "page161-165_visual_ages.json", "page166-170_visual_ages.json",
               "page171-175_visual_ages.json", "page176-180_visual_ages.json",
               "page181-185_visual_ages.json", "page186-190_visual_ages.json",
               "page191-195_visual_ages.json", "page196-199_visual_ages.json",
               "page156-158_visual_ages.json", "page123_visual_ages.json",
               "page057-059_visual_ages.json", "page061_visual_ages.json",
               "page063_visual_ages.json", "page065_visual_ages.json",
               "page069-075_visual_ages.json", "page077_visual_ages.json",
               "page079-085_visual_ages.json", "page067_visual_ages.json",
               "page095_visual_ages.json", "page089_visual_ages.json",
               "page091_visual_ages.json", "page093_visual_ages.json",
               "page087_visual_ages.json", "page099_visual_ages.json",
               "page103_visual_ages.json", "page117-120_visual_ages.json"):
    checks.update(json.loads((ROOT / "review" / ledger).read_text()))
for path in (ROOT / "review/Weigl_2005_records_OCR_draft.csv", ROOT / "Weigl__2005_Records_snapshot.csv"):
    with path.open(encoding="utf-8", newline="") as f:
        reader = csv.DictReader(f)
        fields = list(reader.fieldnames)
        if "age_printed_verified" not in fields:
            fields.append("age_printed_verified")
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
                row["age_days_verified"] = str(age["days"]) if "days" in age else ""
                row["age_qualifier_verified"] = ""
                row["age_printed_verified"] = (f'{age["days"]} {"day" if age["days"] == 1 else "days"}' if "days" in age else age["raw"])
            else:
                row["age_years_verified"] = str(age[0])
                row["age_months_verified"] = str(age[1])
                row["age_qualifier_verified"] = age[2] if len(age) == 3 else ""
                row["age_days_verified"] = ""
                row["age_printed_verified"] = f'{age[2] if len(age) == 3 else ""}{age[0]} years {age[1]} months'
            row["age_visual_check"] = "primary printed age checked from page image"
            row["review_status"] = "primary age visually checked; taxon, prose, and alternatives pending"
    for row in rows:
        if (row["age_visual_check"] or row.get("row_start_visual_check")) and not row.get("age_printed_verified"):
            if row["age_days_verified"]:
                days = row["age_days_verified"]
                row["age_printed_verified"] = f'{days} {"day" if days == "1" else "days"}'
            elif row["age_years_verified"] or row["age_months_verified"]:
                row["age_printed_verified"] = (
                    f'{row["age_qualifier_verified"]}{row["age_years_verified"]} years '
                    f'{row["age_months_verified"]} months'
                )
        if row.get("age_printed_verified") and not row["age_visual_check"]:
            row["age_visual_check"] = "primary printed age checked from page image"
    with path.open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fields)
        writer.writeheader()
        writer.writerows(rows)
    print(f"Applied {sum(len(x) for p,x in checks.items() if p != 'scope')} primary ages to {path.name}")
