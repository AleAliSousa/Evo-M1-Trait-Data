#!/usr/bin/env python3
"""Index the exact SD1 citation tokens against the supplied SD2 bibliography.

Read both journal downloads as frozen inputs. Split lists at semicolons, slashes
and citation-separating commas; retain spelling and punctuation of each token.
Only exact author/year matches are resolved, with explicit aliases for two
unambiguous abbreviated labels. Other citations remain blank for review.
"""
import csv
from pathlib import Path
import re
import unicodedata
from xml.etree import ElementTree as ET
from zipfile import ZipFile

folder = Path(__file__).resolve().parent
item = 'Burger_etal_2019_SupplementaryDataSD1'
source = folder / 'gyz043_suppl_Supplement_Data.csv'
doc = folder / 'gyz043_suppl_supplement_material.docx'
out = folder / 'reference_tables' / (item + '_references.csv')
ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
with ZipFile(doc) as z:
    root = ET.fromstring(z.read('word/document.xml'))
paragraphs = [' '.join(''.join(p.itertext()).split()) for p in root.findall('.//w:body/w:p', ns)]
paragraphs = [p for p in paragraphs if p and not p.startswith('Supplementary Data')]

def plain(s):
    return ''.join(c for c in unicodedata.normalize('NFKD', s.lower()) if not unicodedata.combining(c))

def tokens(s):
    # The only comma inside one short citation is "Baron, et al 1996".
    return [s.strip() for s in re.split(r';|/|,(?!\s*et\s+al\b)', s, flags=re.I) if s.strip()]

keys = {}
with source.open(encoding='utf-8-sig', newline='') as f:
    for row in csv.DictReader(f):
        for col in ('BrainReference1', 'BrainReference2'):
            for token in tokens(row[col]):
                keys.setdefault(token, set()).add(col)

aliases = {'islerprim2008': ('isler', '2008'), 'vonbonin1937': ('bonin', '1937'),
           'pantheria': ('jones', '2009')}
records = []
for key, cols in sorted(keys.items(), key=lambda kv: kv[0].lower()):
    norm = plain(key)
    year = re.search(r'(?:19|20)\d{2}', norm)
    ident = aliases.get(norm)
    hits = []
    if year or ident:
        yr = ident[1] if ident else year.group(0)
        short = re.sub(r'[^a-z]', '', norm.split(yr)[0])
        for p in paragraphs:
            pn = plain(p)
            first = re.sub(r'[^a-z]', '', pn.split(',', 1)[0])
            if ((ident and first == ident[0]) or (not ident and short.startswith(first))) and re.search(r'\b' + yr + r'[a-z]?\b', pn):
                hits.append(p)
    citation = hits[0] if len(hits) == 1 else ''
    note = ('Matched by first author and year to SD2; source may be secondary.' if citation
            else 'Not uniquely resolved in SD2; retain the SD1 label for review.')
    records.append({'ref_key': key, 'cited_in_column': '; '.join(sorted(cols)),
                    'citation': citation, 'note': note,
                    'resolution_status': 'matched_SD2' if citation else 'unresolved',
                    'evidence_file': doc.name if citation else ''})
with out.open('w', encoding='utf-8-sig', newline='') as f:
    w = csv.DictWriter(f, fieldnames=list(records[0])); w.writeheader(); w.writerows(records)
print(f'{len(records)} source tokens: {sum(bool(x["citation"]) for x in records)} matched SD2, '
      f'{sum(not x["citation"] for x in records)} unresolved')
for r in records:
    if not r['citation']: print('  unresolved:', r['ref_key'])
