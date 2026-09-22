#!/usr/bin/env python3
"""Convert one Fobbs et al. (2011) legacy Word supplementary table to XLSX.
Usage: python Fobbs_etal_2011_build_snapshot.py Fobbs_etal_2011_TableS2
Requires LibreOffice and python-docx. The source .doc remains authoritative.
"""
from pathlib import Path
from copy import copy
import shutil, subprocess, sys, tempfile, re
from docx import Document

## Locate a LibreOffice CLI binary. On Linux the command is usually `libreoffice`
## (sometimes `soffice`); on macOS neither is normally on PATH -- only the binary
## inside LibreOffice.app is, so fall back to that fixed install location.
def _find_soffice():
    for name in ('libreoffice', 'soffice'):
        found = shutil.which(name)
        if found:
            return found
    mac_default = '/Applications/LibreOffice.app/Contents/MacOS/soffice'
    if Path(mac_default).exists():
        return mac_default
    raise SystemExit('LibreOffice not found (checked PATH for libreoffice/soffice and '
                      f'{mac_default}).')
SOFFICE = _find_soffice()
from openpyxl import Workbook
from openpyxl.styles import Font, Alignment, PatternFill, Border, Side
from openpyxl.utils import get_column_letter

CFG={
'Fobbs_etal_2011_TableS1a':('nyas_6036_sm_table1a.doc',1,10,'TableS1a'),
'Fobbs_etal_2011_TableS1b':('nyas_6036_sm_table1b.doc',1,9,'TableS1b'),
'Fobbs_etal_2011_TableS2': ('nyas_6036_sm_table2.doc', 1,13,'TableS2'),
'Fobbs_etal_2011_TableS3': ('nyas_6036_sm_table3.doc', 1,6, 'TableS3'),
'Fobbs_etal_2011_TableS4': ('nyas_6036_sm_table4.doc', 3,6, 'TableS4'),
'Fobbs_etal_2011_TableS5a':('nyas_6036_sm_table5a.doc',1,9,'TableS5a'),
'Fobbs_etal_2011_TableS5b':('nyas_6036_sm_table5b.doc',1,7,'TableS5b'),
}
def clean(x):
    return re.sub(r'[ \t\r\n]+',' ',x.replace('\xa0',' ')).strip()
def main(stem):
    if stem not in CFG: raise SystemExit('Unknown item: '+stem)
    src_name, header_row, ncol, sheet=CFG[stem]
    folder=Path(__file__).resolve().parent; src=folder/src_name
    if not src.exists(): raise SystemExit('Missing source: '+str(src))
    with tempfile.TemporaryDirectory() as td:
        subprocess.run([SOFFICE,'--headless','--convert-to','docx','--outdir',td,str(src)],check=True,stdout=subprocess.DEVNULL)
        d=Document(Path(td)/(src.stem+'.docx'))
        if len(d.tables)!=1: raise SystemExit(f'Expected one table; found {len(d.tables)}')
        t=d.tables[0]
        title=clean(t.rows[0].cells[0].text)
        headers=[clean(c.text) for c in t.rows[header_row].cells[:ncol]]
        rows=[[clean(c.text) for c in r.cells[:ncol]] for r in t.rows[header_row+1:]]
        rows=[r for r in rows if any(r)]
    wb=Workbook(); ws=wb.active; ws.title=sheet; ws.sheet_view.showGridLines=False
    ws.merge_cells(start_row=1,start_column=1,end_row=1,end_column=ncol); ws.cell(1,1,title)
    ws.cell(1,1).font=Font(bold=True); ws.cell(1,1).alignment=Alignment(wrap_text=True)
    for c,h in enumerate(headers,1):
        x=ws.cell(2,c,h); x.font=Font(bold=True); x.fill=PatternFill('solid',fgColor='D9EAF7'); x.alignment=Alignment(wrap_text=True,vertical='bottom')
        x.border=Border(top=Side(style='thin'),bottom=Side(style='thin'))
    for r,row in enumerate(rows,3):
        for c,v in enumerate(row,1): ws.cell(r,c,v if v else None)
    ws.freeze_panes='A3'; ws.auto_filter.ref=f'A2:{get_column_letter(ncol)}{len(rows)+2}'
    ws.column_dimensions['A'].width=28
    for c in range(2,ncol+1): ws.column_dimensions[get_column_letter(c)].width=20
    ws.row_dimensions[1].height=34; ws.row_dimensions[2].height=45
    ws.page_setup.orientation='landscape'; ws.sheet_properties.pageSetUpPr.fitToPage=True; ws.page_setup.fitToWidth=1
    out=folder/f'{stem}_snapshot.xlsx'; wb.save(out)
    print(f'Wrote {out.name}: {len(rows)} nonblank source rows')
if __name__=='__main__':
    if len(sys.argv)!=2: raise SystemExit('Supply one item stem')
    main(sys.argv[1])
