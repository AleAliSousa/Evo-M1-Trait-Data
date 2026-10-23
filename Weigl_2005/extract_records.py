"""Extract an auditable, single-table draft from the Weigl (2005) PDF text layer.

The output is deliberately a draft: every row requires comparison with the scan.
Run with the bundled Codex Python containing pdfplumber.
"""

import csv
import re
from collections import Counter
from pathlib import Path

import pdfplumber


ROOT = Path(__file__).resolve().parent
PDF = ROOT / "Weigl_2005_LongevityOfMammalsInCaptivity_pp21-210.pdf"
OUT = ROOT / "Weigl_2005_records_OCR_draft.csv"
AUDIT = ROOT / "Weigl_2005_extraction_audit.csv"
SEX = re.compile(r"^([0-9Il]{1,2}\s*\.\s*[0-9Il]{1,2}(?:\s*\.\s*[0-9Il]{1,2})?)")
IGNORE = re.compile(r"^(?:AGE|years\b|months\b|rnonths\b|LONGEVITY\b|FROM THE LIVING|by Richard|\d{1,3})$", re.I)


def clean(s):
    return re.sub(r"\s+", " ", s).strip()


def join_chars(chars):
    out = []
    previous = None
    for char in chars:
        if previous and char["x0"] - previous["x1"] > 1.5:
            out.append(" ")
        out.append(char["text"])
        previous = char
    return clean("".join(out))


def parts(line, cutoff):
    return (
        join_chars([c for c in line["chars"] if c["x0"] < cutoff]),
        join_chars([c for c in line["chars"] if c["x0"] >= cutoff]),
    )


rows = []
audit = []
order = family = taxon = common = ""
taxon_pdf_page = taxon_y_pdf = ""
current = None
page_record = 0


def flush():
    global current
    if current is None:
        return
    current["record_text_ocr"] = clean(" ".join(current.pop("record_lines")))
    current["age_column_ocr"] = clean(" ".join(current.pop("age_lines")))
    current["age_years_ocr"] = clean(" ".join(current.pop("year_lines")))
    current["age_months_ocr"] = clean(" ".join(current.pop("month_lines")))
    flags = []
    if not current["taxon_printed_ocr"]:
        flags.append("missing_taxon")
    if not current["age_column_ocr"]:
        flags.append("missing_age_column")
    if current["record_kind"] == "record_without_sex_count":
        flags.append("no_sex_count_start")
    current["qa_flags"] = "; ".join(flags)
    current["review_status"] = "OCR draft; image review required"
    rows.append(current)
    current = None


def new_record(pdf_page, y, kind, sex_count=""):
    global current, page_record
    flush()
    page_record += 1
    current = {
        "source_id": f"Weigl_2005_p{pdf_page + 19:03d}_r{page_record:03d}",
        "pdf_page": pdf_page,
        "printed_page": pdf_page + 19,
        "record_on_page": page_record,
        "record_y_pdf": round(y, 2),
        "record_kind": kind,
        "order_printed_ocr": order,
        "family_printed_ocr": family,
        "taxon_printed_ocr": taxon,
        "taxon_pdf_page": taxon_pdf_page,
        "taxon_y_pdf": taxon_y_pdf,
        "common_name_printed_ocr": common,
        "sex_count_printed_ocr": sex_count,
        "record_lines": [],
        "age_lines": [],
        "year_lines": [],
        "month_lines": [],
    }


with pdfplumber.open(PDF) as doc:
    # PDF page 1 is the loan cover; pages 181–191 are acknowledgments,
    # institution list, and references. Data pages are PDF pages 2–180.
    for pdf_page in range(2, 181):
        # A printed record may begin at the top of a new page under the
        # preceding taxon. Do not append it to the last row of the prior page.
        flush()
        page_record = 0
        page = doc.pages[pdf_page - 1]
        header_words = [w for w in page.extract_words() if w["top"] < 140]
        year_header = next((w for w in header_words if re.search(r"y[eac]ars", w["text"], re.I)), None)
        month_header = next((w for w in header_words if re.search(r"(?:months|rnonths)", w["text"], re.I)), None)
        if year_header and month_header:
            year_x = year_header["x0"]
            month_x = month_header["x0"]
        else:
            # Alternating outer margins; first page's header reads "rnonths".
            year_x, month_x = ((425, 464) if pdf_page % 2 == 0 else (451, 490))
        age_start = year_x - 12
        age_mid = (year_x + month_x) / 2
        cutoff = age_start
        for line in page.extract_text_lines(return_chars=True):
            raw = join_chars(line["chars"])
            if not raw:
                continue
            chars = [c for c in line["chars"] if not c["text"].isspace()]
            if not chars:
                continue
            left, right = parts(line, cutoff)
            first = chars[0]
            if raw.startswith("ORDER "):
                flush()
                order = raw[6:]
                family = ""
                taxon = common = ""
                taxon_pdf_page = taxon_y_pdf = ""
                continue
            if raw.startswith("Family "):
                flush()
                family = raw[7:]
                taxon = common = ""
                taxon_pdf_page = taxon_y_pdf = ""
                continue
            italic = "Italic" in first["fontname"]
            italic_prefix = []
            for char in line["chars"]:
                if not char["text"].isspace() and "Italic" not in char["fontname"]:
                    break
                italic_prefix.append(char)
            taxon_prefix = clean(join_chars(italic_prefix)).rstrip(",. ")
            if (italic and first["x0"] < page.width * 0.32
                    and re.match(r"^[A-Za-z]", raw) and len(taxon_prefix) >= 8):
                flush()
                taxon = taxon_prefix
                common = clean(join_chars(line["chars"][len(italic_prefix):]).lstrip(",. "))
                taxon_pdf_page = pdf_page
                taxon_y_pdf = round(line["top"], 2)
                continue
            if IGNORE.match(raw) or first["x0"] > page.width * 0.86 and raw.isdigit():
                continue
            # Sex notation marks the vast majority of source record starts.
            match = SEX.match(left)
            if match and first["x0"] < page.width * 0.25:
                new_record(pdf_page, line["top"], "sex_count_record", clean(match.group(1)))
            elif current is None and taxon and left:
                # Some cetacean records give a decade or year without sex notation.
                new_record(pdf_page, line["top"], "record_without_sex_count")
            if current is not None:
                if raw:
                    current["record_lines"].append(raw)
                if right:
                    current["age_lines"].append(right)
                year_chars = [c for c in line["chars"] if age_start <= c["x0"] < age_mid]
                month_chars = [c for c in line["chars"] if c["x0"] >= age_mid]
                if year_chars:
                    current["year_lines"].append(join_chars(year_chars))
                if month_chars:
                    current["month_lines"].append(join_chars(month_chars))
        audit.append({"pdf_page": pdf_page, "printed_page": pdf_page + 19, "record_starts": page_record})
    flush()

fields = [
    "source_id", "pdf_page", "printed_page", "record_on_page", "record_y_pdf", "record_kind",
    "order_printed_ocr", "family_printed_ocr", "taxon_printed_ocr", "taxon_pdf_page", "taxon_y_pdf",
    "common_name_printed_ocr", "sex_count_printed_ocr", "record_text_ocr",
    "age_column_ocr", "age_years_ocr", "age_months_ocr", "qa_flags", "review_status",
]
with OUT.open("w", newline="", encoding="utf-8") as f:
    writer = csv.DictWriter(f, fieldnames=fields)
    writer.writeheader()
    writer.writerows(rows)
with AUDIT.open("w", newline="", encoding="utf-8") as f:
    writer = csv.DictWriter(f, fieldnames=audit[0])
    writer.writeheader()
    writer.writerows(audit)
print(f"{len(rows)} draft records, {len(audit)} data pages, {Counter(r['record_kind'] for r in rows)}")
