#!/usr/bin/env python3
"""Copy the complete cell grid of one publisher XLS supplement to XLSX."""

from pathlib import Path
from tempfile import TemporaryDirectory
import subprocess

from openpyxl import Workbook, load_workbook
from openpyxl.styles import Font


def build(table_number: int) -> None:
    folder = Path(__file__).resolve().parent
    source = folder / f"nyas_5978_sm_table{table_number}.xls"
    output = folder / f"Zilles_etal_2011_TableS{table_number}_snapshot.xlsx"
    widths = {1: 9, 2: 11, 3: 10}
    ncol = widths[table_number]
    with TemporaryDirectory() as temporary:
        temp = Path(temporary)
        profile = (temp / "lo-profile").as_uri()
        subprocess.run(
            ["soffice", f"-env:UserInstallation={profile}", "--headless",
             "--convert-to", "xlsx", "--outdir", str(temp), str(source)],
            check=True, stdout=subprocess.DEVNULL,
        )
        converted = load_workbook(temp / (source.stem + ".xlsx"),
                                  read_only=True, data_only=False).active
        workbook = Workbook()
        snapshot = workbook.active
        snapshot.title = f"TableS{table_number}"
        for row in converted.iter_rows(min_row=1, max_row=converted.max_row,
                                       min_col=1, max_col=ncol):
            for cell in row:
                if cell.value is not None:
                    out = snapshot.cell(cell.row, cell.column, cell.value)
                    out.font = Font(name="Arial", size=10)
        workbook.save(output)
    print(f"Wrote {output.name}: {snapshot.max_row} source rows x {ncol} columns")
