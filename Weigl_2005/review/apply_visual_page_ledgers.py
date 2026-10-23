"""Apply checked row starts and primary fields for difficult Weigl pages.

Run after compare_secondary_ocr.py and apply_visual_age_checks.py. Each ledger
lists every printed record line for its page, including the prior OCR row ID
when one existed. OCR prose remains distinct from image-verified fields.
"""

import csv
import os
import re
from collections import defaultdict
from pathlib import Path

import pdfplumber

ROOT = Path(__file__).resolve().parent.parent
PDF = ROOT / "Weigl_2005_LongevityOfMammalsInCaptivity_pp21-210.pdf"
TABLE = ROOT / "review/Weigl_2005_records_OCR_draft.csv"
OCR_DIR = Path(os.environ.get("OCR_OUT_DIR", "/tmp/weigl-secondary-ocr"))
PAGES = {97: (23, 30), 101: (22, 30), 105: (15, 27), 107: (17, 26)}
# printed page: (OCR draft row count, image-checked record-line count)
EXTRA_FIELDS = ["taxon_printed_verified", "sex_count_verified",
                "age_qualifier_verified", "row_start_visual_check"]


def image_lines(pdf_page):
    with pdfplumber.open(PDF) as doc:
        height = doc.pages[pdf_page - 1].height
    path = OCR_DIR / f"page-{pdf_page:03d}.tsv"
    with path.open(encoding="utf-8") as f:
        tsv = [line.rstrip("\n").split("\t", 11) for line in f]
    image_height = int(tsv[1][9])
    groups = defaultdict(list)
    for word in tsv[1:]:
        if len(word) == 12 and word[0] == "5" and word[11].strip():
            groups[tuple(word[2:5])].append(word)
    lines = []
    for words in groups.values():
        y = min(int(word[7]) for word in words) * height / image_height
        text = " ".join(word[11] for word in sorted(words, key=lambda word: int(word[6])))
        lines.append((y, text))
    return lines


def apply_page(page):
    draft_count, checked_count = PAGES[page]
    pdf_page = page - 19
    ledger_path = ROOT / "review" / f"page{page:03d}_visual_ledger.csv"
    with ledger_path.open(encoding="utf-8") as f:
        ledger = list(csv.DictReader(f))
    assert len(ledger) == checked_count, (page, len(ledger))
    assert [int(entry["row_on_page"]) for entry in ledger] == list(range(1, checked_count + 1))
    with TABLE.open(encoding="utf-8") as f:
        all_rows = list(csv.DictReader(f))
    old = {row["source_id"]: row for row in all_rows if row["printed_page"] == str(page)}
    already_applied = len(old) == checked_count
    assert len(old) in {draft_count, checked_count}, (page, len(old))
    prior_ids = [entry["prior_source_id"] for entry in ledger if entry["prior_source_id"]]
    assert len(prior_ids) == len(set(prior_ids))
    assert all(prior in old or already_applied for prior in prior_ids)
    fields = list(all_rows[0]) + [field for field in EXTRA_FIELDS if field not in all_rows[0]]
    lines = image_lines(pdf_page)
    new_page = []
    old_first = old[f"Weigl_2005_p{page:03d}_r001"]
    for entry in ledger:
        number = int(entry["row_on_page"])
        current_id = f"Weigl_2005_p{page:03d}_r{number:03d}"
        prior = entry["prior_source_id"]
        if already_applied:
            row = old[current_id].copy()
        elif prior:
            row = old[prior].copy()
        else:
            row = {field: "" for field in fields}
            row.update({
                "pdf_page": str(pdf_page), "printed_page": str(page),
                "record_y_pdf": entry["image_ocr_y_pdf"],
                "record_kind": "image_verified_record_start",
                "order_printed_ocr": old_first["order_printed_ocr"],
                "family_printed_ocr": old_first["family_printed_ocr"],
                "qa_flags": "inserted_after_page_image_review; full_prose_not_reviewed",
            })
        y = float(entry["image_ocr_y_pdf"])
        nearby = [item for item in lines if abs(item[0] - y) < 1.5]
        closest = max(nearby, key=lambda item: (
            bool(re.search(r"\b(?:died|living|released|escaped|Zoo|Aquarium)\b",
                           item[1], re.I)), -abs(item[0] - y))) if nearby else min(
                               lines, key=lambda item: abs(item[0] - y))
        assert abs(closest[0] - y) < 1.5, (page, number, y, closest[0])
        row["record_text_ocr2"] = closest[1]
        # OCR age cells were frequently assigned to an adjacent record on
        # these pages. Preserve the raw PDF text but clear derived candidates.
        for field in ("age_years_ocr2", "age_months_ocr2", "age_years_candidate",
                      "age_months_candidate", "age_candidate_basis"):
            row[field] = ""
        row["source_id"] = current_id
        row["record_on_page"] = str(number)
        for field in ("taxon_printed_verified", "sex_count_verified",
                      "age_years_verified", "age_months_verified",
                      "age_days_verified", "age_qualifier_verified"):
            row[field] = entry.get(field, "")
        row["row_start_visual_check"] = "2026-10-22; printed page image"
        row["review_status"] = "row start, taxon, sex/count, and primary age visually checked; prose and alternatives pending"
        flags = [flag for flag in row["qa_flags"].split("; ") if flag]
        flags.append("visual_primary_age_supersedes_ocr_candidate")
        row["qa_flags"] = "; ".join(dict.fromkeys(flags))
        new_page.append(row)
    first = next(i for i, row in enumerate(all_rows) if row["printed_page"] == str(page))
    result = [row for row in all_rows if row["printed_page"] != str(page)]
    result[first:first] = new_page
    assert len(result) == len(all_rows) + (0 if already_applied else checked_count - draft_count)
    assert len({row["source_id"] for row in result}) == len(result)
    tmp = TABLE.with_suffix(".tmp")
    with tmp.open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fields)
        writer.writeheader()
        writer.writerows(result)
    tmp.replace(TABLE)
    print(f"Applied {page} visual ledger: {checked_count} source rows" +
          (" (refreshed)" if already_applied else f" ({checked_count - draft_count:+d} net rows)"))


for page_number in PAGES:
    apply_page(page_number)
