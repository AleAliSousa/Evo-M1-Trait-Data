#!/usr/bin/env python3
"""Freeze printed Table 19.1 from the PDF text layer; never replace changed evidence."""
import csv
import io
import re
import subprocess
from pathlib import Path


def capture(text):
    pages = [p for p in text.split("\f") if "Table 19.1 Sound localization" in p]
    if len(pages) != 1:
        raise ValueError("Expected exactly one printed Table 19.1 page")
    page = pages[0]
    caption = re.search(r"^\s*(Table 19\.1 Sound localization[^\n]+)$", page, re.M)
    header = re.search(r"^\s*(Species\s{2,}Midline acuity\s{2,}Binaural phase cue\s{2,}Binaural intensity cue)\s*$", page, re.M)
    if caption is None or header is None:
        raise ValueError("Printed caption or four-column header not found")
    body = page[header.end():page.index("Dashes indicate no data.")]
    rows = []
    for line in body.splitlines():
        if not line.strip():
            continue
        match = re.fullmatch(r"\s*(.+?)\s{2,}(\d+(?:\.\d+)?°(?:\*\*)?)\s{2,}(yes|no|—)\s{2,}(yes\*?|no|—)\s*", line)
        if match is None:
            raise ValueError(f"Unparsed printed data row: {line!r}")
        rows.append(list(match.groups()))
    notes = [line.strip() for line in page.splitlines() if line.strip().startswith(("Dashes indicate", "* ", "** "))]
    if len(rows) != 37 or len(notes) != 3:
        raise ValueError("Expected 37 printed data rows and three table notes")
    return [[caption.group(1).strip(), "", "", ""], re.split(r"\s{2,}", header.group(1).strip())] + rows + [[note, "", "", ""] for note in notes]


def main():
    folder = Path(__file__).resolve().parent
    item_name = Path(__file__).stem.removesuffix("_extract_snapshot")
    text = subprocess.run(["pdftotext", "-layout", str(folder / "HeffnerHeffner2003.pdf"), "-"], check=True, capture_output=True, text=True, encoding="utf-8").stdout
    rows = capture(text)
    saved_layer = folder / "HeffnerHeffner2003.source.txt"
    if saved_layer.exists() and capture(saved_layer.read_text(encoding="utf-8")) != rows:
        raise ValueError("Saved text layer differs from direct PDF capture")
    buffer = io.StringIO(newline="")
    csv.writer(buffer, lineterminator="\n").writerows(rows)
    frozen = folder / f"{item_name}_snapshot.csv"
    content = buffer.getvalue().encode("utf-8")
    if frozen.exists():
        if frozen.read_bytes() != content:
            raise ValueError("Refusing to overwrite a differing frozen snapshot")
        print(f"Frozen snapshot unchanged: {frozen.name}")
    else:
        with frozen.open("xb") as stream:
            stream.write(content)
        print(f"Captured {len(rows) - 5} printed rows: {frozen.name}")


if __name__ == "__main__":
    main()
