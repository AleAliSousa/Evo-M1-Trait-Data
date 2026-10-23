"""Add independent image-OCR readings to the one Weigl record table.

Run after extract_records.py and secondary_ocr.cjs. Agreement is a review aid,
not a substitute for checking the printed page.
"""

import csv
import os
import re
from collections import defaultdict
from difflib import SequenceMatcher
from pathlib import Path

import pdfplumber


ROOT = Path(__file__).resolve().parent
TABLE = ROOT / "Weigl_2005_records_OCR_draft.csv"
PDF = ROOT / "Weigl_2005_LongevityOfMammalsInCaptivity_pp21-210.pdf"
OCR_DIR = Path(os.environ.get("OCR_OUT_DIR", "/tmp/weigl-secondary-ocr"))
TSV_FIELDS = ["level", "page_num", "block_num", "par_num", "line_num", "word_num",
              "left", "top", "width", "height", "conf", "text"]


def read_ocr_lines(path, page):
    with path.open(encoding="utf-8") as f:
        # Tesseract's TSV is unquoted. OCR text can contain a literal `"`, so
        # csv.DictReader's quote handling would swallow many subsequent rows.
        entries = [dict(zip(TSV_FIELDS, line.rstrip("\n").split("\t", 11)))
                   for line in f if line.strip()]
    width = int(entries[0]["width"])
    height = int(entries[0]["height"])
    xscale = width / page.width
    yscale = height / page.height
    groups = defaultdict(list)
    for word in entries:
        if word["level"] == "5" and word["text"].strip():
            key = (word["block_num"], word["par_num"], word["line_num"])
            groups[key].append(word)
    lines = []
    for words in groups.values():
        words.sort(key=lambda w: int(w["left"]))
        lines.append({
            "top": min(int(w["top"]) for w in words) / yscale,
            "text": " ".join(w["text"] for w in words),
            "words": [{"text": w["text"], "x0": int(w["left"]) / xscale} for w in words],
        })
    return sorted(lines, key=lambda line: line["top"])


def number(raw, maximum):
    stripped = re.sub(r"^[.·•\s]+", "", raw)
    if stripped.startswith(("(", "<", ">")) or re.search(r"\b(?:days?|years?|months?)\b", stripped, re.I):
        return None
    matches = [int(n) for n in re.findall(r"(?<!\d)\d{1,3}(?!\d)", raw)]
    return next((n for n in matches if n <= maximum), None)


def numeric_sequence(raw, maximum):
    return [int(n) for n in re.findall(r"(?<!\d)\d{1,3}(?!\d)", raw) if int(n) <= maximum]


def normalized_taxon(text):
    return re.sub(r"[^a-z]", "", text.split(",", 1)[0].lower())


def normalized_text(text):
    return re.sub(r"[^a-z0-9]", "", text.lower())


with TABLE.open(encoding="utf-8") as f:
    rows = list(csv.DictReader(f))
by_page = defaultdict(list)
for row in rows:
    by_page[int(row["pdf_page"])].append(row)
secondary_counts = {}
taxon_readings = {}

new_fields = [
    "taxon_ocr2", "record_text_ocr2", "age_years_ocr2", "age_months_ocr2",
    "taxon_similarity", "age_years_candidate", "age_months_candidate",
    "age_candidate_basis",
]
old_fields = [name for name in rows[0] if name not in new_fields]
compare_flags = {"second_ocr_row_missing", "taxon_ocr_disagreement",
                 "age_ocr_disagreement_or_missing", "age_full_column_disagreement"}
with pdfplumber.open(PDF) as doc:
    for pdf_page in range(2, 181):
        tsv = OCR_DIR / f"page-{pdf_page:03d}.tsv"
        if not tsv.exists():
            raise FileNotFoundError(tsv)
        page = doc.pages[pdf_page - 1]
        ocr_lines = read_ocr_lines(tsv, page)
        secondary_counts[pdf_page] = sum(bool(re.match(r"^\s*[0-9Il]\s*\.\s*[0-9Il](?:\s*\.\s*\d+)?\b", line["text"]))
                                         for line in ocr_lines)
        native_rows = by_page[pdf_page]
        taxa_y = sorted({float(r["taxon_y_pdf"]) for r in native_rows
                         if r["taxon_pdf_page"] == str(pdf_page) and r["taxon_y_pdf"]})
        header_words = [w for w in page.extract_words() if w["top"] < 140]
        years = next((w for w in header_words if re.search(r"y[eac]ars", w["text"], re.I)), None)
        months = next((w for w in header_words if re.search(r"(?:months|rnonths)", w["text"], re.I)), None)
        if years and months:
            age_start = years["x0"] - 12
            age_mid = (years["x0"] + months["x0"]) / 2
        else:
            age_start = page.width * 0.68
            age_mid = page.width * 0.75
        for i, row in enumerate(native_rows):
            start = float(row["record_y_pdf"])
            end = page.height
            if i + 1 < len(native_rows):
                end = min(end, float(native_rows[i + 1]["record_y_pdf"]) - 2)
            next_taxon = next((y for y in taxa_y if y > start + 2), None)
            if next_taxon is not None:
                end = min(end, next_taxon - 2)
            block = [line for line in ocr_lines if start - 3 <= line["top"] < end]
            old_age_words = [w for line in block for w in line["words"] if w["x0"] >= age_start]
            old_year = " ".join(w["text"] for w in old_age_words if w["x0"] < age_mid)
            old_month = " ".join(w["text"] for w in old_age_words if w["x0"] >= age_mid)
            old_pair = number(old_year, 110) is not None and number(old_month, 11) is not None
            # The PDF text layer and rendered-image OCR can disagree on a
            # line's top by 5–10 PDF points. Anchor the second reading to the
            # record's words as well as its vertical position.
            target = normalized_text(row["record_text_ocr"][:140])
            nearby = [line for line in ocr_lines if abs(line["top"] - start) <= 14]
            if target and nearby and not old_pair:
                anchor = max(nearby, key=lambda line: SequenceMatcher(
                    None, target, normalized_text(line["text"][:140])).ratio())
                score = SequenceMatcher(None, target, normalized_text(anchor["text"][:140])).ratio()
                if score >= 0.35:
                    block = [anchor]
            row["record_text_ocr2"] = " ".join(line["text"] for line in block)
            age_words = [w for line in block for w in line["words"] if w["x0"] >= age_start]
            row["age_years_ocr2"] = " ".join(w["text"] for w in age_words if w["x0"] < age_mid)
            row["age_months_ocr2"] = " ".join(w["text"] for w in age_words if w["x0"] >= age_mid)
            row["taxon_ocr2"] = ""
            taxon_key = (row["taxon_pdf_page"], row["taxon_y_pdf"])
            if row["taxon_pdf_page"] == str(pdf_page) and row["taxon_y_pdf"]:
                ty = float(row["taxon_y_pdf"])
                taxon_candidates = [line for line in ocr_lines
                                    if abs(line["top"] - ty) < 14
                                    and not re.search(r"\b(?:died|living|born)\b", line["text"], re.I)]
                nearest = max(taxon_candidates, key=lambda line: SequenceMatcher(
                    None, normalized_taxon(row["taxon_printed_ocr"]),
                    normalized_taxon(line["text"])).ratio()) if taxon_candidates else None
                if nearest is not None:
                    row["taxon_ocr2"] = nearest["text"].split(",", 1)[0]
                    taxon_readings[taxon_key] = row["taxon_ocr2"]
            elif taxon_key in taxon_readings:
                row["taxon_ocr2"] = taxon_readings[taxon_key]
            a = normalized_taxon(row["taxon_printed_ocr"])
            b = normalized_taxon(row["taxon_ocr2"])
            row["taxon_similarity"] = f"{SequenceMatcher(None, a, b).ratio():.3f}" if a and b else ""
            native_year = number(row["age_years_ocr"], 110)
            native_month = number(row["age_months_ocr"], 11)
            second_year = number(row["age_years_ocr2"], 110)
            second_month = number(row["age_months_ocr2"], 11)
            native_pair = (native_year, native_month) if native_year is not None and native_month is not None else None
            second_pair = (second_year, second_month) if second_year is not None and second_month is not None else None
            if native_pair and second_pair and native_pair == second_pair:
                candidate, basis = native_pair, "two OCR readings agree; image review pending"
            elif native_pair and not second_pair:
                candidate, basis = native_pair, "PDF text layer only; image review pending"
            elif second_pair and not native_pair:
                candidate, basis = second_pair, "independent image OCR only; image review pending"
            else:
                candidate, basis = None, ""
            row["age_years_candidate"] = candidate[0] if candidate else ""
            row["age_months_candidate"] = candidate[1] if candidate else ""
            row["age_candidate_basis"] = basis
            flags = [f for f in row["qa_flags"].split("; ") if f and f not in compare_flags]
            if not row["record_text_ocr2"]:
                flags.append("second_ocr_row_missing")
            if row["taxon_similarity"] and float(row["taxon_similarity"]) < 0.85:
                flags.append("taxon_ocr_disagreement")
            if row["age_candidate_basis"] != "two OCR readings agree; image review pending":
                flags.append("age_ocr_disagreement_or_missing")
            if (numeric_sequence(row["age_years_ocr"], 110) != numeric_sequence(row["age_years_ocr2"], 110)
                    or numeric_sequence(row["age_months_ocr"], 11) != numeric_sequence(row["age_months_ocr2"], 11)):
                flags.append("age_full_column_disagreement")
            row["qa_flags"] = "; ".join(flags)

tmp = TABLE.with_suffix(".tmp")
with tmp.open("w", encoding="utf-8", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=old_fields + new_fields)
    writer.writeheader()
    writer.writerows(rows)
tmp.replace(TABLE)
audit_path = ROOT / "Weigl_2005_extraction_audit.csv"
with audit_path.open(encoding="utf-8") as f:
    audit = list(csv.DictReader(f))
with audit_path.open("w", encoding="utf-8", newline="") as f:
    audit_fields = [name for name in audit[0] if name not in ("secondary_ocr_starts", "start_count_difference")]
    writer = csv.DictWriter(f, fieldnames=audit_fields + ["secondary_ocr_starts", "start_count_difference"])
    writer.writeheader()
    for entry in audit:
        native_count = int(entry["record_starts"])
        second_count = secondary_counts[int(entry["pdf_page"])]
        entry["secondary_ocr_starts"] = second_count
        entry["start_count_difference"] = native_count - second_count
        writer.writerow(entry)
print(f"Compared independent OCR for {len(rows)} rows; "
      f"{sum(r['age_candidate_basis'].startswith('two OCR') for r in rows)} age pairs agree across both readings; "
      f"{sum(bool(r['age_candidate_basis']) for r in rows)} total age candidates.")
