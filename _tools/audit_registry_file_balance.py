#!/usr/bin/env python3
"""Audit exact registry CSV and public TSV paths."""

import csv
import os
from pathlib import Path

import openpyxl


ROOT = Path(__file__).resolve().parent.parent
REPORT = ROOT / "_checks/registry_file_balance_2026-11-26.csv"


def category(has_csv, has_tsv, non_tabular_asset=False):
    if has_csv and has_tsv:
        return "both"
    if has_csv:
        return "csv_only"
    if has_tsv:
        return "tsv_only"
    if non_tabular_asset:
        return "non_tabular"
    return "neither"


def main():
    book = openpyxl.load_workbook(ROOT / "__ReadMe.xlsx", data_only=True)
    sheet = book["Sheet1"]
    public_names = set(os.listdir(ROOT / "__Public/comparative-data"))
    results = []
    for row in range(2, sheet.max_row + 1):
        item = sheet[f"J{row}"].value
        if not item:
            continue
        folder = sheet[f"H{row}"].value or ""
        code = sheet[f"K{row}"].value or ""
        csv_path = f"{folder}/{item}.csv"
        tsv_path = f"__Public/comparative-data/{code}.tsv"
        # Ask the filesystem to resolve the path. macOS normalizes Unicode
        # filenames, so a literal directory-name set can reject a valid path
        # whose registry spelling uses the equivalent composed accent.
        has_csv = (ROOT / csv_path).is_file()
        has_tsv = f"{code}.tsv" in public_names
        source_format = str(sheet[f"O{row}"].value or "").lower()
        named_asset = sheet[f"U{row}"].value
        asset_path = ROOT / folder / str(named_asset) if named_asset else None
        if not asset_path or not asset_path.is_file():
            asset_path = ROOT / folder / (item if item.endswith(".nex") else f"{item}.nex")
        non_tabular_asset = ("tree" in source_format and asset_path.is_file())
        results.append({
            "sheet_row": row,
            "registry_item": item,
            "status": category(has_csv, has_tsv, non_tabular_asset),
            "csv_path": csv_path if has_csv else "",
            "public_tsv_path": tsv_path if has_tsv else "",
        })
    book.close()
    with REPORT.open("w", newline="") as stream:
        writer = csv.DictWriter(stream, fieldnames=list(results[0]))
        writer.writeheader()
        writer.writerows(results)
    counts = {status: sum(x["status"] == status for x in results)
              for status in ("both", "csv_only", "tsv_only", "non_tabular", "neither")}
    print("Registry exact-path status: " + ", ".join(f"{k}={v}" for k, v in counts.items()))
    print(f"Rows: {len(results)}; report: {REPORT}")


if __name__ == "__main__":
    main()
