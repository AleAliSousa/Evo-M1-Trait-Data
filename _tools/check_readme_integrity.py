#!/usr/bin/env python3
"""Read-only structural and filename check for __ReadMe.xlsx."""
from pathlib import Path
import sys
import zipfile
import openpyxl
from lxml import etree

root = Path(__file__).resolve().parents[1]
path = root / '__ReadMe.xlsx'
with zipfile.ZipFile(path) as archive:
    bad = archive.testzip()
    if bad:
        raise SystemExit(f'Corrupt workbook ZIP member: {bad}')
    sheet_xml = archive.read('xl/worksheets/sheet1.xml')
    chain_xml = archive.read('xl/calcChain.xml')
    ns = {'m': 'http://schemas.openxmlformats.org/spreadsheetml/2006/main'}
    sheet_root = etree.fromstring(sheet_xml)
    chain_root = etree.fromstring(chain_xml)
    array_cells = {cell.get('r') for cell in sheet_root.xpath('.//m:c[m:f[@t="array"]]', namespaces=ns)}
    chain_arrays = {cell.get('r') for cell in chain_root if cell.get('a') == '1' and cell.get('i', '1') == '1'}
    if array_cells != chain_arrays:
        raise SystemExit(f'Formula-array metadata differs from calcChain: {sorted(array_cells ^ chain_arrays)[:20]}')
book = openpyxl.load_workbook(path, read_only=True, data_only=True)
expected = ['Sheet1', 'SOURCE_DISPOSITION', 'AUTO_Public_TSV_FileList']
if book.sheetnames != expected:
    raise SystemExit(f'Unexpected sheets: {book.sheetnames!r}')
source = book['SOURCE_DISPOSITION']
if source.max_column < 10 or source['A1'].value != 'Citation (APA 7th-Annotated)':
    raise SystemExit('SOURCE_DISPOSITION no longer contains registry-shaped rows')
actual = {row[0] for row in book['AUTO_Public_TSV_FileList'].values if row[0]}
on_disk = {p.name for p in (root / '__Public' / 'comparative-data').glob('*.tsv')}
if actual != on_disk:
    raise SystemExit(f'AUTO_Public_TSV_FileList differs from disk: {len(actual-on_disk)} extra, {len(on_disk-actual)} missing')
print(f'OK: Sheet1 {book["Sheet1"].max_row} rows; SOURCE_DISPOSITION {source.max_row}x{source.max_column}; {len(actual)} TSVs listed')
