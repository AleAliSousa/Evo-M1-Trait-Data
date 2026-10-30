#!/usr/bin/env python3
"""Extract Baron, Stephan & Frahm (1996) Tables 10 and 32 from the PDF text layer.

The two emitted CSVs are frozen source transcriptions.  Numeric OCR repairs are
restricted to the handful of malformed tokens listed in ``LINE_REPAIRS`` below;
the script otherwise preserves the printed row order and species strings.  The
source page number is retained so every row can be checked against the scan.
"""

from __future__ import annotations

import csv
import re
from pathlib import Path

from pypdf import PdfReader


HERE = Path(__file__).resolve().parent
PDF = HERE / "baron_etal_1996 book Comparative Neurobiology.pdf"

# The PDF has a good OCR text layer, but eight Table 32 rows and two Table 10
# rows contain malformed numeric glyphs.  These literal repairs were checked
# against the rendered pages; no biological value is inferred or recomputed.
LINE_REPAIRS = {
    "Saccopteryx leptura 3 21.l 22.2 27.4 13.3 68.5":
        "Saccopteryx leptura 3 21.1 22.2 27.4 13.3 68.5",
    "Peropteryx macrotis 3 20.3 19.3 30.4 12.9 71.l":
        "Peropteryx macrotis 3 20.3 19.3 30.4 12.9 71.1",
    "Megaerops ecaudatus 45.5 39.2 34.1 11.5 17.4 71. 4 36.5 246.8":
        "Megaerops ecaudatus 45.5 39.2 34.1 11.5 17.4 71.4 36.5 246.8",
    "H. calcaratus cupidus §) 8.79 14.2 19.6 3.53 11.2 20.3 9.33 /\",2.6":
        "H. calcaratus cupidus §) 8.79 14.2 19.6 3.53 11.2 20.3 9.33 72.6",
    "Hipposideros lekaguli lO.7 16.9 26.3 6.40 19.2 35.8 19.3 123.1":
        "Hipposideros lekaguli 10.7 16.9 26.3 6.40 19.2 35.8 19.3 123.1",
    "H. maggietayl. erroris §) 13.8 22.1 27.0 4.70 15.8 24.5 lO.7 90.0":
        "H. maggietayl. erroris §) 13.8 22.1 27.0 4.70 15.8 24.5 10.7 90.0",
    "Macrophyllum macrophyll. 4.39 9.70 17.8 3.00 lO.5 19.6 9.23 80.3":
        "Macrophyllum macrophyll. 4.39 9.70 17.8 3.00 10.5 19.6 9.23 80.3",
    "Mimon crenulatum 7.30 lO.3 15.8 2.94 11.3 18.2 8.96 87.1":
        "Mimon crenulatum 7.30 10.3 15.8 2.94 11.3 18.2 8.96 87.1",
    "Scotozous dormeri 3.76 6.67 5.71 1.85 7.09 7.95 3.93 ~1.4":
        "Scotozous dormeri 3.76 6.67 5.71 1.85 7.09 7.95 3.93 21.4",
    "Molossus trinitatis 10.4 15.7 17.0 4.39 21.0 20.8 11.8 89.6 (":
        "Molossus trinitatis 10.4 15.7 17.0 4.39 21.0 20.8 11.8 89.6",
}

# OCR-only letterform/spacing errors.  These substitutions restore what is
# visibly printed; the abbreviated taxon wording itself is deliberately kept.
NAME_REPAIRS = {
    "Laviafrons": "Lavia frons",
    "Nycteris macro tis": "Nycteris macrotis",
    "CaroWa perspicillata": "Carollia perspicillata",
    "Sturn ira lilium": "Sturnira lilium",
    "Sturn ira ludovici": "Sturnira ludovici",
    "Sturn ira tUdae": "Sturnira tildae",
    "Uroderma bUobatum": "Uroderma bilobatum",
    "Lionycteris spurreUi": "Lionycteris spurrelli",
    "Tadarida pUcata pUcata": "Tadarida plicata plicata",
    "Cyttarops alec to": "Cyttarops alecto",
    "EctophyUa macconnelli": "Ectophylla macconnelli",
    "Artibeus cine reus": "Artibeus cinereus",
    "Artibeus jamaicen;is": "Artibeus jamaicensis",
    "Miniopterus in flatus": "Miniopterus inflatus",
    "fa io": "Ia io",
    "Tonatia schuld": "Tonatia schulzi",
}

SKIP_PREFIXES = (
    "Table ", "For ", "n ", "Abbreviations", "CER ", "DIE ", "MES ",
    "OBL ", "TEL ", "AMY ", "HIP ", "MOB ", "NEO ", "PAL ", "SCH ",
    "SEP ", "STR ", "§)",
)


def repair_name(name: str) -> str:
    name = NAME_REPAIRS.get(name, name)
    return re.sub(r"\s+", " ", name).strip()


def parse_table(reader: PdfReader, pages: range, n_values: int, has_n: bool):
    number = r"\d+(?:\.\d+)?"
    values = rf"(?P<values>(?:{number}\s+){{{n_values - 1}}}{number})"
    if has_n:
        pattern = re.compile(rf"^(?P<name>.+?)(?:\s+(?P<n>\d+|I))?\s+{values}$")
    else:
        pattern = re.compile(rf"^(?P<name>.+?)\s+{values}$")

    rows = []
    for page_index in pages:
        page_number = page_index + 1
        text = reader.pages[page_index].extract_text() or ""
        for raw_line in text.splitlines():
            line = " ".join(raw_line.split())
            line = LINE_REPAIRS.get(line, line)
            match = pattern.match(line)
            if not match:
                continue
            name = repair_name(match.group("name"))
            if not name or name.startswith(SKIP_PREFIXES):
                continue
            row = {
                "source_pdf_page": page_number,
                "species_printed": name,
            }
            if has_n:
                n = match.group("n") or ""
                row["n"] = "1" if n == "I" else n
            for key, value in zip(
                ("OBL", "MES", "CER", "DIE", "TEL") if has_n
                else ("MOB", "PAL", "STR", "SEP", "AMY", "HIP", "SCH", "NEO"),
                match.group("values").split(),
            ):
                row[key] = value
            rows.append(row)
    return rows


def write_snapshot(path: Path, rows: list[dict]):
    with path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=["species_row", *rows[0].keys()])
        writer.writeheader()
        for index, row in enumerate(rows, 1):
            writer.writerow({"species_row": index, **row})


def main():
    reader = PdfReader(PDF)
    table10 = parse_table(reader, range(55, 63), 5, True)   # PDF pages 56-63
    table32 = parse_table(reader, range(137, 145), 8, False) # PDF pages 138-145

    if len(table10) != 272 or len(table32) != 272:
        raise RuntimeError(
            f"Unexpected row count: Table 10={len(table10)}, Table 32={len(table32)}; expected 272 each"
        )
    if table10[0]["species_printed"] != "Eidolon helvum" or table32[0]["species_printed"] != "Eidolon helvum":
        raise RuntimeError("Unexpected first species")
    if table10[-1]["species_printed"] != "Cheiromeles torquatus" or table32[-1]["species_printed"] != "Cheiromeles torquatus":
        raise RuntimeError("Unexpected final species")

    write_snapshot(HERE / "Baron_etal_1996_Table10_snapshot.csv", table10)
    write_snapshot(HERE / "Baron_etal_1996_Table32_snapshot.csv", table32)
    print("Wrote Baron Table 10 and Table 32 snapshots (272 rows each)")


if __name__ == "__main__":
    main()
