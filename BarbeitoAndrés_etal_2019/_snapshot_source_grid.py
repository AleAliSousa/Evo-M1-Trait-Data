#!/usr/bin/env python3
"""Copy the complete Hoja1 cell grid to an item CSV and TSV snapshot."""

import csv
import sys
from pathlib import Path

from openpyxl import load_workbook


def main(stem: str) -> None:
    folder = Path(__file__).resolve().parent
    sheet = load_workbook(folder / "data_figshare.xlsx", read_only=True,
                          data_only=False)["Hoja1"]
    rows = [["" if cell.value is None else cell.value for cell in row]
            for row in sheet.iter_rows(min_row=1, max_row=69,
                                       min_col=1, max_col=16)]
    for suffix, delimiter in (("csv", ","), ("tsv", "\t")):
        output = folder / f"BarbeitoAndrés_etal_2019_{stem}_snapshot.{suffix}"
        with output.open("w", newline="") as target:
            writer = csv.writer(target, delimiter=delimiter)
            writer.writerows(rows)
        print(f"Wrote {output.name}: 69 source rows x 16 columns")


if __name__ == "__main__":
    if len(sys.argv) != 2 or sys.argv[1] not in {"volumes", "cellnumber", "celldensity"}:
        raise SystemExit("Usage: python3 _snapshot_source_grid.py volumes|cellnumber|celldensity")
    main(sys.argv[1])
