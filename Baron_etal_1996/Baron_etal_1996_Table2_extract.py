#!/usr/bin/env python3
"""Extract Baron, Stephan & Frahm (1996) Table 2 ("Linear measures of brains
in mm", PDF pp. 4-11, printed pp. 266-273) from the PDF text layer.

Companion to Baron_etal_1996_extract_snapshots.py (which covers Tables 10 and
32 with the same book PDF). Table 2 needed a more general parser because rows
are not one-per-line in the source PDF text (many species are crammed onto a
single extracted "line"), and because the printed table has TWO independent
optional fields (BL/HL/HW/HH's leading n, and CCL's own n), either of which
can be dashed out ("-", "-.--") for a given species.

Pipeline
--------
1. Per-page PDF text (pageN.txt, N = 0-based PDF page index) is cleaned of
   common OCR digit/letter confusions (l/I -> 1, o/O -> 0 in numeric-only
   tokens; three specific letters-plus-digits artifacts where an italic "m"
   was OCR'd as "l11" mid-word).
2. Family/subfamily all-caps heading lines and page furniture (page-number
   headers, "Table 2 <" running heads, the Table 3/4 cross-reference lines,
   the addendum footnote) are stripped before parsing.
3. A single global regex walks the cleaned text as alternating
   (species name)(numeric run) pairs. Each numeric run is tokenized and typed
   as INT or FLOAT (FLOAT tokens contain a decimal point; n-columns never
   do), then assigned by a small state machine in strict column order
   n1, BL, HL, HW, HH, n2, CCL - each of these 7 slots is independently
   optional, matching what is actually dashed out in the printed table.
4. One page in this range (PDF page 7, printed p. 269) has NO extractable
   text layer at all (a pure scanned image in this otherwise well-OCR'd
   book) - all 39 rows on that page were hand-transcribed directly from the
   rendered page image and are hard-coded in PAGE269_ROWS below.
5. Eight rows (all single-specimen entries, n=1) had BOTH their n1 and/or n2
   integer silently dropped by the text extraction (not represented by any
   garbled token - a true invisible extraction failure, distinct from the
   letter/digit confusions step 1 repairs). These were caught because a row
   with a CCL value but no n2 is structurally inconsistent with the print
   convention (CCL is always accompanied by its own n when present), and
   were individually confirmed against the rendered page images. See
   CELL_FIXES below.

Output: Baron_etal_1996_Table2_snapshot.csv, 303 rows, matching the
registry's expected row count and sharing its first (Eidolon helvum) and
last (Cheiromeles torquatus) species with the already-built Tables 10/32.
"""

from __future__ import annotations

import csv
import re
from pathlib import Path

HERE = Path(__file__).resolve().parent

LETTER_REPAIRS = {
    "bilobatul11": "bilobatum",     # Uroderma bilobatum
    "trinitatul11": "trinitatum",   # Chiroderma trinitatum
    "l11orio": "morio",             # Chalinolobus morio
}

WORD = r"[A-Za-z\u00a7+][A-Za-z\.\+\u00a7/'%()?-]*"
NAME_RE = rf"{WORD}(?:\s+{WORD})*"
BLOCK_RE = re.compile(rf'({NAME_RE})\s+((?:\d+\.\d+|\d+)(?:\s+(?:\d+\.\d+|\d+))*)')

SKIP_NAME_EXACT_PREFIXES = (
    "Table", "For proportion", "For average", "Abbreviations", "BL brain", "CCL corpus",
    "HH hemisphere", "n= number", "See addendum", "see addendum", "pp.",
)

# Hand-transcribed from the rendered page image (PDF page 7, printed p. 269) -
# the one page in range with no extractable text layer at all.
PAGE269_ROWS = [
    ("Hipposideros bicolor gentilis", "6", "11.3", "6.4", "7.4", "5.5", None, None),
    ("Hipposideros bicolor atrox", "3", "11.5", "6.6", "7.6", "5.7", None, None),
    ("Hipposideros caffer", "14", "11.0", "6.8", "8.0", "5.9", "3", "1.52"),
    ("Hipposideros caffer ssp.", "5", "12.3", "7.0", "8.4", "5.9", None, None),
    ("Hipposideros c. calcaratus \u00a7)", "7", "14.2", "7.7", "8.6", "6.5", "3", "2.49"),
    ("Hipposideros c. cupidus \u00a7)", "6", "12.8", "7.3", "8.0", "6.2", "3", "2.28"),
    ("Hipposideros cervinus", "17", "11.1", "6.2", "7.1", "5.3", "3", "1.76"),
    ("Hipposideros commersoni", "10", "15.4", "9.9", "11.1", "7.9", "3", "2.17"),
    ("Hipposideros diadema", "21", "17.7", "9.5", "10.9", "7.6", "4", "1.96"),
    ("Hipposideros fulvus", "6", "11.3", "6.5", "7.5", "5.5", "2", "1.50"),
    ("Hipposideros galeritus", "3", "11.9", "6.8", "7.9", "5.8", None, None),
    ("Hipposideros halophyllus", "2", "9.8", "5.6", "6.1", "4.5", "2", "1.46"),
    ("Hipposideros lankadiva", "9", "18.2", "9.8", "11.0", "7.5", "3", "2.37"),
    ("Hipposideros larvatus", "20", "14.3", "7.9", "9.0", "6.5", "3", "1.72"),
    ("Hipposideros lekaguli", "10", "16.1", "8.6", "10.1", "7.5", "2", "1.85"),
    ("Hipp. m. maggietaylorae \u00a7)", "1", "16.5", "9.3", "10.0", "7.6", "1", "2.92"),
    ("Hipp. m. erroris \u00a7)", "4", "14.4", "7.8", "8.7", "7.1", "3", "2.48"),
    ("Hipposideros ridleyi", "10", "11.6", "5.9", "7.8", "5.8", "3", "1.33"),
    ("Hipposideros ruber", "1", "10.0", "6.9", "7.9", "5.6", None, None),
    ("Hipposideros speoris", "6", "12.5", "7.1", "8.1", "5.8", "2", "1.57"),
    ("Hipposideros turpis", "4", "16.3", "9.0", "9.9", "7.6", "3", "1.93"),
    ("Aselliscus stoliczkanus", "3", "9.1", "5.2", "5.9", "4.7", "3", "1.11"),
    ("Aselliscus tricuspidatus", "10", "9.5", "5.5", "5.9", "4.7", "3", "1.38"),
    ("Triaenops persicus", "10", "10.9", "6.2", "7.0", "5.9", "3", "1.89"),
    ("Noctilio albiventris", "10", "12.7", "8.6", "11.1", "8.4", "3", "2.67"),
    ("Noctilio leporinus", "9", "15.9", "10.8", "13.6", "9.9", "3", "4.28"),
    ("Pteronotus gymnonotus", "6", "11.2", "6.1", "8.4", "7.1", "3", "2.03"),
    ("Pteronotus personatus", "17", "9.6", "5.5", "7.3", "6.2", "3", "1.79"),
    ("Pteronotus parnelli", "15", "13.3", "7.6", "10.4", "8.0", "3", "2.11"),
    ("Mormoops megalophylla", "9", "9.8", "5.2", "8.6", "7.7", "3", "1.34"),
    ("Micronycteris megalotis", "9", "11.1", "6.8", "7.2", "6.7", "3", "2.03"),
    ("Micronycteris minuta", "1", "11.3", "6.7", "7.2", "6.5", "1", "2.00"),
    ("Micronycteris schmidtorum", "10", "11.5", "6.9", "7.6", "7.0", "3", "2.34"),
    ("Micronycteris brachyotis", "1", "12.9", "7.2", "8.3", "7.2", "1", "2.68"),
    ("Macrophyllum macrophyllum", "10", "11.2", "7.1", "7.8", "6.7", "3", "2.54"),
    ("Tonatia bidens", "10", "16.6", "10.1", "10.2", "9.4", "3", "3.70"),
    ("Tonatia schulzi", "1", "13.6", "8.2", "9.2", "8.3", "1", "3.27"),
    ("Tonatia sylvicola", "1", "15.0", "10.2", "10.4", "9.4", "1", "3.52"),
    ("Mimon crenulatum", "2", "12.5", "7.4", "8.1", "6.7", "2", "2.23"),
]

# (species_row, field) -> corrected value. All eight are single-specimen (n=1)
# rows where the text layer silently dropped an n1 and/or n2 token (no
# garbled remnant to repair programmatically). Each was individually
# confirmed against the rendered page image before being applied here.
CELL_FIXES = {
    (9, "n2"): "1",     # Pteropus hypomelanus (p. 266) - n2 dropped, CCL=7.98 present
    (74, "n"): "1",     # Cyttarops alecto (p. 267)
    (74, "n2"): "1",
    (171, "n"): "1",    # Choeroniscus minor (p. 270)
    (171, "n2"): "1",
    (201, "n"): "1",    # Sphaeronycteris toxophyllum (p. 271)
    (201, "n2"): "1",
    (280, "n"): "1",    # Kerivoula papillosa (p. 273)
    (280, "n2"): "1",
    (281, "n"): "1",    # Kerivoula pellucida (p. 273)
    (281, "n2"): "1",
    (282, "n"): "1",    # Kerivoula phalaena (p. 273)
    (282, "n2"): "1",
    (283, "n"): "1",    # Phoniscus atrox (p. 273)
    (283, "n2"): "1",
}
NAME_FIXES = {
    282: "Kerivoula phalaena",  # name itself was truncated to "a" by the same digit-adjacent parsing issue
}


def clean_ocr_numbers(text: str) -> str:
    for bad, good in LETTER_REPAIRS.items():
        text = text.replace(bad, good)

    def fix_token(m: re.Match) -> str:
        tok = m.group(0)
        if tok in ("I", "l"):
            return "1"
        if len(tok) < 2:
            return tok
        if re.fullmatch(r"[\dlIoO]*\.?[\dlIoO]*", tok) and tok not in ("", "."):
            cand = tok.replace("l", "1").replace("I", "1").replace("o", "0").replace("O", "0")
            if re.fullmatch(r"\d+(\.\d+)?|\.\d+", cand):
                return cand
        return tok

    return re.sub(r"\S+", fix_token, text)


def is_all_caps_header(line: str) -> bool:
    letters = re.sub(r"[^A-Za-z]", "", line.strip())
    return len(letters) >= 3 and letters.isupper()


def is_skip_name(name: str) -> bool:
    n = name.strip()
    if not n:
        return True
    if any(n.startswith(p) for p in SKIP_NAME_EXACT_PREFIXES):
        return True
    return n.isupper()


def parse_page(text: str, page_num: int):
    text = clean_ocr_numbers(text)
    keep_lines = []
    for ln in text.splitlines():
        s = ln.strip()
        if not s:
            continue
        if re.match(r"^\d+\s+Brains of Chiroptera", s):
            continue
        if re.match(r"^>\s*Table", s):
            continue
        if s.startswith("Table 2."):
            continue
        if s.startswith("For proportion") or s.startswith("For average"):
            continue
        if re.match(r"^n\s+BL\s+HL", s):
            continue
        if "addendum" in s.lower() or "Voume" in s:
            continue
        if is_all_caps_header(s):
            continue
        keep_lines.append(ln)
    text2 = "\n".join(keep_lines)

    rows, issues = [], []
    for m in BLOCK_RE.finditer(text2):
        name_raw, nums_raw = m.group(1), m.group(2)
        if is_skip_name(name_raw):
            continue
        name = re.sub(r"\s+", " ", name_raw).strip()
        for junk in ("cont.) ", "cant.) "):
            if name.startswith(junk):
                name = name[len(junk):]

        typed = [("FLOAT" if "." in t else "INT", t) for t in nums_raw.split()]
        i, n1 = 0, None
        if i < len(typed) and typed[i][0] == "INT":
            n1, i = typed[i][1], i + 1
        measures, mi = [None, None, None, None], 0
        while i < len(typed) and typed[i][0] == "FLOAT" and mi < 4:
            measures[mi], mi, i = typed[i][1], mi + 1, i + 1
        n2 = None
        if i < len(typed) and typed[i][0] == "INT":
            n2, i = typed[i][1], i + 1
        ccl = None
        if i < len(typed) and typed[i][0] == "FLOAT":
            ccl, i = typed[i][1], i + 1
        leftover = typed[i:]

        row = {
            "source_pdf_page": page_num, "species_printed": name, "n": n1,
            "BL": measures[0], "HL": measures[1], "HW": measures[2], "HH": measures[3],
            "n2": n2, "CCL": ccl,
        }
        if leftover or measures[0] is None:
            issues.append({"name": name, "raw": nums_raw, "leftover": leftover, "page": page_num})
        rows.append(row)
    return rows, issues


def main():
    all_rows = []
    for pidx, page_num in [(3, 4), (4, 5), (5, 6)]:
        text = (HERE / f"page{pidx}.txt").read_text()
        rows, issues = parse_page(text, page_num)
        if issues:
            raise RuntimeError(f"Unresolved parse issues on page {page_num}: {issues}")
        all_rows.extend(rows)

    for name, n1, bl, hl, hw, hh, n2, ccl in PAGE269_ROWS:
        all_rows.append({
            "source_pdf_page": 7, "species_printed": name, "n": n1,
            "BL": bl, "HL": hl, "HW": hw, "HH": hh, "n2": n2, "CCL": ccl,
        })

    for pidx, page_num in [(7, 8), (8, 9), (9, 10), (10, 11)]:
        text = (HERE / f"page{pidx}.txt").read_text()
        rows, issues = parse_page(text, page_num)
        if issues:
            raise RuntimeError(f"Unresolved parse issues on page {page_num}: {issues}")
        all_rows.extend(rows)

    if len(all_rows) != 303:
        raise RuntimeError(f"Expected 303 rows, got {len(all_rows)}")

    for idx, row in enumerate(all_rows, 1):
        for field in ("n", "n2"):
            if (idx, field) in CELL_FIXES:
                row[field] = CELL_FIXES[(idx, field)]
        if idx in NAME_FIXES:
            row["species_printed"] = NAME_FIXES[idx]

    if all_rows[0]["species_printed"] != "Eidolon helvum":
        raise RuntimeError("Unexpected first species")
    if all_rows[-1]["species_printed"] != "Cheiromeles torquatus":
        raise RuntimeError("Unexpected final species")

    out = HERE / "Baron_etal_1996_Table2_snapshot.csv"
    fieldnames = ["species_row", "source_pdf_page", "species_printed", "n", "BL", "HL", "HW", "HH", "n2", "CCL"]
    with out.open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=fieldnames)
        w.writeheader()
        for i, r in enumerate(all_rows, 1):
            w.writerow({"species_row": i, **r})

    print(f"Wrote {out.name}: {len(all_rows)} rows")


if __name__ == "__main__":
    main()
