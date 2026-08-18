#!/usr/bin/env python3
"""Audit paper folders in Evo-M1-Trait-Data:
   1) lacks a PDF of the paper
   2) lacks the frozen source data in the folder (any format; URL in registry excuses it)
   3) lacks a row in __ReadMe.xlsx Sheet1
"""
import os, re, zipfile, csv
from xml.etree import ElementTree as ET

# Derived from this script's own location (_tools/ lives at the dataset root), so the audit
# runs on any machine. It used to hardcode a sandbox path that no longer existed.
ROOT = os.environ.get("EVOM1_ROOT") or os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
NS = '{http://schemas.openxmlformats.org/spreadsheetml/2006/main}'

# ---------------------------------------------------------------- registry
z = zipfile.ZipFile(os.path.join(ROOT, "__ReadMe.xlsx"))
ss = [''.join(t.text or '' for t in si.iter(NS + 't'))
      for si in ET.fromstring(z.read('xl/sharedStrings.xml')).iter(NS + 'si')]

def grid(path):
    sh = ET.fromstring(z.read(path)); out = []
    for row in sh.iter(NS + 'row'):
        d = {}
        for c in row.iter(NS + 'c'):
            col = ''.join(ch for ch in c.get('r') if ch.isalpha())
            v = c.find(NS + 'v'); isx = c.find(NS + 'is')
            if c.get('t') == 's' and v is not None: val = ss[int(v.text)]
            elif isx is not None: val = ''.join(t.text or '' for t in isx.iter(NS + 't'))
            elif v is not None: val = v.text
            else: val = None
            d[col] = val
        out.append(d)
    return out

g = grid('xl/worksheets/sheet1.xml')
hdr = g[0]
COL = {v: k for k, v in hdr.items() if v}
def cell(r, name): return (r.get(COL.get(name, '~')) or '').strip()
reg = g[1:]
print("registry data rows: %d" % len(reg))

# ---------------------------------------------------------------- folders
SKIP_PREFIX = ('_', '.')
NON_PAPER = set()   # thematic folders that are not one publication (none at present:
                    # Corticospinal_terminations was renamed to Bortoff_Strick_1993 on 2026-08-15)
folders = sorted(d for d in os.listdir(ROOT)
                 if os.path.isdir(os.path.join(ROOT, d)) and not d.startswith(SKIP_PREFIX))

DATA_EXT = {'.csv', '.tsv', '.xlsx', '.xls', '.xlsm', '.txt', '.json', '.dta', '.dat', '.docx', '.doc', '.rtf', '.zip'}
SUPP_PAT = re.compile(r'MOESM|_ESM|suppl|supp[0-9]|_si_|Supplement|TableS|Table_S|Data_S|DataS|sd[0-9]|appendix',
                      re.I)

def norm(s): return re.sub(r'[^a-z0-9]', '', (s or '').lower())

rows = []
for d in folders:
    p = os.path.join(ROOT, d)
    files = []
    for dp, dn, fn in os.walk(p):
        for f in fn:
            if f.startswith('.'): continue
            files.append(os.path.relpath(os.path.join(dp, f), p))

    pdfs = [f for f in files if f.lower().endswith('.pdf')]
    # a PDF is "the paper" if its name does not look like a supplement
    paper_pdfs = [f for f in pdfs if not SUPP_PAT.search(os.path.basename(f))]
    supp_pdfs = [f for f in pdfs if SUPP_PAT.search(os.path.basename(f))]

    datafiles = [f for f in files
                 if os.path.splitext(f)[1].lower() in DATA_EXT
                 and not f.lower().endswith('_definitions.csv')
                 and 'reference_tables' not in f.replace('\\', '/')]
    snaps   = [f for f in datafiles if 'snapshot' in f.lower()]
    # publisher-style download: supplement-looking name, or name not starting with the folder name
    nd_local = norm(d)
    downloads = [f for f in datafiles
                 if SUPP_PAT.search(os.path.basename(f))
                 or not norm(os.path.basename(f)).startswith(nd_local)]
    supp_pdf_as_source = supp_pdfs
    frozen = sorted(set(snaps) | set(downloads) | set(supp_pdf_as_source))
    derived = [f for f in datafiles if f not in frozen]

    # registry rows for this folder
    nd = norm(d)
    hits = []
    for r in reg:
        item = cell(r, 'Item name')
        if item and norm(item).startswith(nd):
            hits.append(r); continue
        a, y = cell(r, '1st Author'), cell(r, 'year')
        yr = re.search(r'(1[89]|20)\d{2}', d)
        if a and y and norm(a) and norm(a).split(',')[0][:6] in nd and yr and y[:4]==yr.group(0):
            hits.append(r)
    urls = sorted({cell(r, 'Source URL direct access') or cell(r, 'Source URL link')
                   for r in hits} - {''})

    rows.append(dict(folder=d, files=len(files), paper_pdf=len(paper_pdfs),
                     supp_pdf=len(supp_pdfs), frozen=frozen, derived=derived,
                     nreg=len(hits), urls=urls,
                     items=sorted({cell(r, 'Item name') for r in hits} - {''})))

# ---------------------------------------------------------------- report
def show(title, sel, extra=lambda r: ''):
    print('\n' + '=' * 100); print(title); print('=' * 100)
    if not sel: print('  (none)'); return
    for r in sel:
        tag = '  [not a single-paper folder]' if r['folder'] in NON_PAPER else ''
        print('  %-32s files=%-3d %s%s' % (r['folder'], r['files'], extra(r), tag))

show('1) NO PDF OF THE PAPER',
     [r for r in rows if r['paper_pdf'] == 0],
     lambda r: 'supp_pdf=%d frozen=%d derived=%d reg=%d' % (r['supp_pdf'], len(r['frozen']), len(r['derived']), r['nreg']))

show('2) NO FROZEN SOURCE DATA IN FOLDER',
     [r for r in rows if not r['frozen']],
     lambda r: 'derived=%s reg=%d url=%s' % (r['derived'] or '-', r['nreg'], (r['urls'][0][:40] if r['urls'] else '-')))

show('2b) DERIVED DATA BUT NO FROZEN SOURCE (invariant-1 risk)',
     [r for r in rows if not r['frozen'] and r['derived']],
     lambda r: 'derived=%s' % r['derived'])

show('3) NO ROW IN __ReadMe.xlsx Sheet1',
     [r for r in rows if r['nreg'] == 0],
     lambda r: 'paper_pdf=%d frozen=%d derived=%d' % (r['paper_pdf'], len(r['frozen']), len(r['derived'])))

print('\n%d folders scanned; %d clean on all three' % (
    len(rows), sum(1 for r in rows if r['paper_pdf'] and r['frozen'] and r['nreg'])))

OUT = os.path.join(ROOT, '_checks', 'folder_audit.csv')   # was a hardcoded sandbox path
os.makedirs(os.path.dirname(OUT), exist_ok=True)
with open(OUT, 'w', newline='') as fh:
    w = csv.writer(fh)
    w.writerow(['folder', 'n_files', 'paper_pdf', 'supp_pdf', 'n_frozen', 'frozen_files',
                'n_derived', 'derived_files', 'n_registry_rows', 'registry_items', 'source_urls'])
    for r in rows:
        w.writerow([r['folder'], r['files'], r['paper_pdf'], r['supp_pdf'], len(r['frozen']),
                    '; '.join(r['frozen']), len(r['derived']), '; '.join(r['derived']),
                    r['nreg'], '; '.join(r['items']), '; '.join(r['urls'])])
print('wrote ' + OUT)
