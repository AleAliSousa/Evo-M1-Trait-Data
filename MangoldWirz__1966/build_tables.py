#!/usr/bin/env python3
"""Build the three public Wirz/Mangold-Wirz tables from checked source transcriptions."""
import csv
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PUB = ROOT / "__Public" / "comparative-data"


def read_tsv(path):
    with path.open(encoding="utf-8", newline="") as handle:
        return list(csv.DictReader(handle, delimiter="\t"))


def write_table(rows, fields, csv_path, public_path):
    for path, delimiter in ((csv_path, ","), (public_path, "\t")):
        with path.open("w", encoding="utf-8", newline="") as handle:
            writer = csv.DictWriter(handle, fieldnames=fields, delimiter=delimiter)
            writer.writeheader()
            writer.writerows(rows)


def mass(raw, multiplier=1):
    """Only scalar printed masses become mergeable grams; ranges remain source text."""
    raw = raw.strip()
    if not raw or re.search(r"[-–—]|\bto\b|[()]", raw):
        return ""
    match = re.fullmatch(r"([0-9]+(?:\.[0-9]+)?)\s*(kg|g)?", raw)
    if not match:
        return ""
    value = float(match.group(1)) * (1000 if match.group(2) == "kg" else multiplier)
    return format(value, ".12g")


base = ROOT / "MangoldWirz__1966"
rows = []
for i, source in enumerate(read_tsv(base / "MangoldWirz__1966_TableI_source.tsv"), 1):
    own = source["source_flag"] == "author_own"
    rows.append({
        "source_row": i,
        **source,
        "species": source["species_as_printed"],
        "body_weight_g": mass(source["body_as_printed"]),
        "brain_weight_g": mass(source["brain_as_printed"]),
        "TI": source["TI_as_printed"],
        "merge_eligible": "FALSE",
        "data_role": "primary" if own else "secondary",
    })
assert len(rows) == 212
assert sum(r["data_role"] == "primary" for r in rows) == 3
assert all(r["merge_eligible"] == "FALSE" for r in rows)
fields = list(rows[0])
write_table(rows, fields, base / "MangoldWirz__1966_TableI.csv",
            PUB / "10.1159%2F000142809_TableI.tsv")

rows = []
for i, source in enumerate(read_tsv(base / "MangoldWirz__1966_TableII_source.tsv"), 1):
    rows.append({"source_row": i, **source, "species": source["species_as_printed"]})
assert len(rows) == 93
write_table(rows, list(rows[0]), base / "MangoldWirz__1966_TableII.csv",
            PUB / "10.1159%2F000142809_TableII.tsv")

base = ROOT / "Wirz__1950"
rows = []
for i, source in enumerate(read_tsv(base / "Wirz__1950_TableI_source.tsv"), 1):
    rows.append({"source_row": i, **source})
assert len(rows) == 45
write_table(rows, list(rows[0]), base / "Wirz__1950_TableI.csv",
            PUB / "10.1159%2F000140431_TableI.tsv")
