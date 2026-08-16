#!/usr/bin/env python3
"""Verify the local Hutsler PDF and rebuild its exact Table 1 snapshot.

Figure 3 and Figure 6 snapshots are manually reviewed pixel-boundary captures and
are intentionally not overwritten here. Use --extract-figures-dir to recover the
embedded figure JPEGs used by those snapshots.
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import io
from pathlib import Path

import pdfplumber
from PIL import Image
from pypdf import PdfReader


EXPECTED_SHA256 = "93c8718ba14f86e30eef3fabd135c263f86e1de195239f9a1909cb640da8d665"
PDF_NAME = "Hutsler-2005-Comparative analysis of cortical.pdf"
TABLE1_NAME = "Hutsler_etal_2005_Table1_snapshot.csv"

TABLE1_ROWS = [
    ("Primate", "Human", "Homo sapiens", 3, "Dartmouth Hitchcock Medical Center"),
    ("Primate", "Gorilla", "Gorilla gorilla", 1, "Harvard Univ."),
    ("Primate", "Chimpanzee", "Pan troglodytes", 3, "Harvard Univ. (1); Yakovlev Collection (2)"),
    ("Primate", "Rhesus Macaque", "Macaca mulatta", 4, "UC Davis (1); Yakovlev Collection (3)"),
    ("Primate", "Squirrel Monkey", "Saimiri sciureus", 2, "Yakovlev Collection"),
    ("Carnivore", "Dog", "Canis (lupus) familiaris", 3, "Harvard Univ."),
    ("Carnivore", "Ferret", "Mustela furo", 1, "Smith College"),
    ("Carnivore", "Cat", "Felis silvestris catus", 2, "UC Davis (1); Yakovlev Collection (1)"),
    ("Rodent", "Woodchuck", "Marmota monax", 1, "Harvard Univ."),
    ("Rodent", "Porcupine", "Erethizon dorsatum", 1, "Harvard Univ."),
    ("Rodent", "Capybara", "Hydrochoerus hydrochaeris", 3, "Yakovlev Collection"),
    ("Rodent", "Rat", "Rattus rattus norwegicus", 3, "Pfizer, Inc."),
    ("Rodent", "Guinea Pig", "Cavia porcellus", 2, "Harvard Univ. (1); Yakovlev Collection (1)"),
    ("Rodent", "Mouse", "Mus musculus", 3, "Pfizer, Inc."),
]


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for block in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def verify_table_text(pdf_path: Path) -> None:
    with pdfplumber.open(pdf_path) as document:
        if len(document.pages) != 11:
            raise RuntimeError(f"Expected 11 pages, found {len(document.pages)}")
        text = " ".join((document.pages[2].extract_text(x_tolerance=2, y_tolerance=3) or "").split())
    for _, common, scientific, count, source in TABLE1_ROWS:
        for token in (common, scientific, str(count), source):
            if " ".join(token.split()) not in text:
                raise RuntimeError(f"Table 1 token missing from PDF text layer: {token!r}")


def write_table1(target: Path) -> None:
    with target.open("w", newline="", encoding="utf-8") as stream:
        writer = csv.writer(stream)
        writer.writerow(
            ("order_printed", "common_name_printed", "scientific_name_printed", "n_specimens", "source_printed")
        )
        writer.writerows(TABLE1_ROWS)


def extract_figures(pdf_path: Path, output_dir: Path) -> None:
    output_dir.mkdir(parents=True, exist_ok=True)
    reader = PdfReader(pdf_path)
    expected = {5: [(646, 834), (645, 850)], 7: [(591, 788)]}
    for page_number, expected_sizes in expected.items():
        images = reader.pages[page_number - 1].images
        if len(images) != len(expected_sizes):
            raise RuntimeError(f"Page {page_number}: expected {len(expected_sizes)} images, found {len(images)}")
        for index, (image_file, expected_size) in enumerate(zip(images, expected_sizes), start=1):
            image = Image.open(io.BytesIO(image_file.data))
            if image.size != expected_size:
                raise RuntimeError(f"Page {page_number} image {index}: expected {expected_size}, found {image.size}")
            suffix = image.format.lower() if image.format else "bin"
            target = output_dir / f"page{page_number}_image{index}.{suffix}"
            target.write_bytes(image_file.data)
            print(f"Wrote {target} ({image.size[0]} x {image.size[1]})")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("pdf", nargs="?", type=Path)
    parser.add_argument("--extract-figures-dir", type=Path)
    args = parser.parse_args()

    folder = Path(__file__).resolve().parent
    pdf_path = args.pdf.resolve() if args.pdf else folder / PDF_NAME
    checksum = sha256(pdf_path)
    if checksum != EXPECTED_SHA256:
        raise RuntimeError(f"Unexpected PDF checksum: {checksum}")

    verify_table_text(pdf_path)
    target = folder / TABLE1_NAME
    write_table1(target)
    print(f"Verified PDF and wrote {target} ({len(TABLE1_ROWS)} rows; checksum {checksum})")

    if args.extract_figures_dir:
        extract_figures(pdf_path, args.extract_figures_dir.resolve())


if __name__ == "__main__":
    main()
