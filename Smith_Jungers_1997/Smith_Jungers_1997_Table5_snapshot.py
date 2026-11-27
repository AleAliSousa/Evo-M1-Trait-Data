#!/usr/bin/env python3
"""Freeze Table 5's source-layout rows from the held searchable PDF.

The four numeric columns are assigned by their positions under each page's
printed M/F/M/F header. Raw source lines are retained for review. This parser
does not reconcile names, sources, or repeated population rows.
"""

import csv
import re
import subprocess
from pathlib import Path

HERE = Path(__file__).resolve().parent
PDF = HERE / "Smith-1997-Body mass in compara.pdf"
OUT = HERE / "Smith_Jungers_1997_Table5_snapshot.csv"
TOKEN = re.compile(r"(?:[<>])?~?\d+(?:[·.]\d+)?(?:\(\?\)|\?)?|\?")
SPECIES = re.compile(r"^[A-Z][a-z]+(?:\s+\([A-Z][a-z]+\))?\s+[a-z]+(?:\s|$)")
FAMILY = re.compile(r"^[A-Z][A-Za-z]+idae$")


def page_lines(number):
    result = subprocess.check_output(
        ["pdftotext", "-f", str(number), "-l", str(number), "-layout", str(PDF), "-"],
        text=True,
    )
    return result.splitlines()


def main():
    rows = []
    family = ""
    species = ""
    for pdf_page in range(16, 27):
        lines = page_lines(pdf_page)
        header_index = next(i for i, line in enumerate(lines)
                            if re.search(r"^\s+M\s+F\s+M\s+F", line))
        header = lines[header_index]
        centers = [m.start() for m in re.finditer(r"\b[MF]\b", header[:80])][:4]
        assert len(centers) == 4
        for line_number, line in enumerate(lines[header_index + 1:], header_index + 2):
            if line.lstrip().startswith("Abbreviations used in Comments"):
                break
            left = line[: centers[0] - 1].strip()
            if FAMILY.match(left):
                family = left
                continue
            name = left if SPECIES.match(left) else ""
            if left and not name:
                continue
            numerical_region = line[: centers[3] + 12]
            tokens = [(m.group(), (m.start() + m.end()) / 2)
                      for m in TOKEN.finditer(numerical_region)]
            if not tokens and not name:
                continue
            if not name and not any("·" in value or "." in value for value, _ in tokens):
                continue
            if name:
                species = name
            if not species:
                raise ValueError(f"No species at PDF page {pdf_page}, line {line_number}")
            columns = ["", "", "", ""]
            overflow = []
            for value, center in tokens:
                k = min(range(4), key=lambda index: abs(center - centers[index]))
                if columns[k]:
                    overflow.append(value)
                    continue
                columns[k] = value
            if overflow and not all(value.isdigit() for value in overflow):
                raise ValueError(f"Unparsed table token at p{pdf_page}:{line_number}: {overflow}")
            rows.append({
                "source_row": len(rows) + 1,
                "source_pdf_page": pdf_page,
                "source_line_on_page": line_number,
                "family_as_published": family,
                "species_as_published": species,
                "species_label_printed_this_row": name,
                "male_sample_size_as_printed": columns[0],
                "female_sample_size_as_printed": columns[1],
                "male_body_mass_kg_as_printed": columns[2],
                "female_body_mass_kg_as_printed": columns[3],
                "raw_source_line": line.rstrip(),
                "parser_overflow_tokens": "; ".join(overflow),
            })
    assert len(rows) == 317, len(rows)
    assert len({row["species_as_published"] for row in rows}) == 249
    print("parsed", len(rows), "rows and", len({row["species_as_published"] for row in rows}), "species labels")
    with OUT.open("w", newline="", encoding="utf-8") as stream:
        writer = csv.DictWriter(stream, fieldnames=list(rows[0]))
        writer.writeheader()
        writer.writerows(rows)
    print(f"{len(rows)} source-layout rows -> {OUT.name}; merge and source-row review remain separate")


if __name__ == "__main__":
    main()
