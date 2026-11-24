"""Freeze one publisher DOCX table as an XLSX, preserving source cells and emphasis.

R xml2 can read this DOCX, but the available R openxlsx writer emitted broken
drawing references in the XLSX. Python is used only for the frozen snapshot.
"""
from pathlib import Path
from zipfile import ZipFile
from lxml import etree
from openpyxl import Workbook
from openpyxl.styles import Font, Alignment
from openpyxl.utils import get_column_letter
import re

folder = Path(__file__).resolve().parent
item_name = Path(__file__).stem.removesuffix('_snapshot')
table_no = int(re.search(r'_TableS([3-6])$', item_name).group(1))
source_file = folder / '1-s2.0-S0149763422003116-mmc1.docx'
snapshot = folder / f'{item_name}_snapshot.xlsx'
if snapshot.exists():
    raise SystemExit('Frozen snapshot exists; inspect before replacing')

ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
with ZipFile(source_file) as z:
    root = etree.fromstring(z.read('word/document.xml'))
tables = root.xpath('.//w:body/w:tbl', namespaces=ns)
assert len(tables) == 6
table = tables[table_no - 1]

def text(element):
    return ''.join(element.xpath('.//w:t/text()', namespaces=ns))

caption = next(
    text(el).strip() for el in table.itersiblings(preceding=True)
    if el.tag.endswith('}p') and text(el).strip().startswith(f'Table S{table_no}:')
)
rows = table.findall('w:tr', ns)
assert len(rows) == {3: 22, 4: 13, 5: 22, 6: 13}[table_no]
wb = Workbook()
ws = wb.active
ws.title = f'Table S{table_no}'
ws['A1'] = caption
ws['A1'].font = Font(name='Arial', size=11, bold=True)
ws['A1'].alignment = Alignment(wrap_text=True, vertical='top')
ws.merge_cells(start_row=1, start_column=1, end_row=1, end_column=7)
ws.row_dimensions[1].height = 32
for i, row in enumerate(rows, start=2):
    cells = row.findall('w:tc', ns)
    assert len(cells) == 7
    for j, cell in enumerate(cells, start=1):
        x = ws.cell(i, j, text(cell))
        x.font = Font(
            name='Arial', size=10,
            bold=(i == 2 or bool(cell.xpath('.//w:r[w:rPr/w:b]', namespaces=ns))),
            italic=bool(cell.xpath('.//w:r[w:rPr/w:i]', namespaces=ns)),
        )
        x.alignment = Alignment(wrap_text=True, vertical='top')
ws.column_dimensions['A'].width = 37
for j in range(2, 8):
    ws.column_dimensions[get_column_letter(j)].width = 18
ws.freeze_panes = 'A3'
wb.save(snapshot)
print(f'{item_name}: captured {len(rows)-1} source rows')
