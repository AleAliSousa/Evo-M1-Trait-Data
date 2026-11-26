"""Extract the Kappeler/Pereira appendix without interpreting multi-value cells.

Run with Python and xlrd >= 2 installed. The input workbook remains unchanged.
"""

import csv
from pathlib import Path

import xlrd


HERE = Path(__file__).resolve().parent
WORKBOOK = HERE / "LH_appendix.xls"
OUTPUT = HERE / "LH_appendix_cells.csv"

SOURCE_BY_COLOUR = {
    None: "Smith_Jungers_1997",  # Excel automatic font colour (black)
    (0, 0, 0): "Smith_Jungers_1997",
    (0, 0, 255): "Ross_chapter_11",
    (51, 102, 255): "Ross_chapter_11",
    (255, 0, 255): "Godfrey_etal_2001",
    (0, 255, 0): "Lee_Kappeler_chapter_3",
    (255, 0, 0): "Smith_Leigh_1998",
}


def cell_text(cell):
    if cell.ctype == xlrd.XL_CELL_NUMBER:
        return format(cell.value, ".15g")
    return str(cell.value).strip()


def main():
    book = xlrd.open_workbook(str(WORKBOOK), formatting_info=True)
    sheet = book.sheet_by_name("Tabelle1")
    assert sheet.nrows == 318 and sheet.ncols == 16
    headers = [cell_text(sheet.cell(1, col)).rstrip("*") for col in range(16)]
    rows = []
    for row in range(2, 311):  # 1-based Excel rows 3–311; notes begin at 312
        family, genus, species = (cell_text(sheet.cell(row, col)) for col in range(3))
        assert family and genus and species, f"Missing taxon in row {row + 1}"
        for col in range(3, 16):
            value = cell_text(sheet.cell(row, col))
            if not value:
                continue
            xf = book.xf_list[sheet.cell_xf_index(row, col)]
            colour_index = book.font_list[xf.font_index].colour_index
            rgb = book.colour_map.get(colour_index)
            source = SOURCE_BY_COLOUR.get(rgb, "unresolved_colour")
            rows.append({
                "workbook_row": row + 1,
                "workbook_column": col + 1,
                "family_printed": family,
                "genus_printed": genus,
                "species_printed": species,
                "trait_printed": headers[col],
                "value_printed": value,
                "font_colour_index": colour_index,
                "font_rgb": "" if rgb is None else ",".join(map(str, rgb)),
                "source_key": source,
            })
    with OUTPUT.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=list(rows[0]))
        writer.writeheader()
        writer.writerows(rows)
    print(f"{len(rows)} nonempty trait cells from 309 species rows -> {OUTPUT}")
    print(f"Unresolved source colors: {sum(r['source_key'] == 'unresolved_colour' for r in rows)}")


if __name__ == "__main__":
    main()
