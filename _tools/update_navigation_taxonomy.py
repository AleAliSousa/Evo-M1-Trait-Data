#!/usr/bin/env python3
"""Refresh missing Orders: NCBI, then MDD -> GBIF -> ITIS -> PBDB.

Run after _keys/build_species_taxonomy.py. Rebuilds between providers so an
NCBI miss or error automatically reaches the next database; see
_keys/README_navigation_taxonomy.md. --ncbi-only disables the continuation.
This supplements navigation metadata only, never species identities or traits.
Scientific names and explicit synonyms must match exactly; homonyms with
conflicting orders remain unresolved. Requires network access, no API key.
"""
import csv
import datetime
import json
import re
import subprocess
import sys
import time
import urllib.parse
import urllib.request
import xml.etree.ElementTree as ET
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / '_keys/genus_navigation_taxonomy.csv'
ENDPOINT = 'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/'


def fetch(endpoint, params):
    url = ENDPOINT + endpoint + '?' + urllib.parse.urlencode(params)
    for attempt in range(3):
        try:
            time.sleep(0.4)
            with urllib.request.urlopen(url, timeout=30) as response:
                return response.read()
        except Exception:
            if attempt == 2:
                raise
            time.sleep(2 ** attempt)


def update_ncbi():
    with (ROOT / '_keys/species_taxonomy.csv').open() as fh:
        genera = sorted({r['Species'].split()[0] for r in csv.DictReader(fh)
                         if not r['Order'] and re.fullmatch(r'[A-Z][a-z]{2,}', r['Species'].split()[0])})
    ids = set()
    for start in range(0, len(genera), 30):
        term = ' OR '.join('"' + g + '"[All Names]' for g in genera[start:start + 30])
        result = json.loads(fetch('esearch.fcgi', dict(db='taxonomy', term=term, retmode='json', retmax=2000)))
        result = result['esearchresult']
        if int(result['count']) > 2000:
            raise ValueError('Truncated taxonomy search')
        ids.update(result['idlist'])
        print('Searched', min(start + 30, len(genera)), '/', len(genera), flush=True)

    records = defaultdict(list)
    ids = sorted(ids, key=int)
    for start in range(0, len(ids), 100):
        xml = fetch('efetch.fcgi', dict(db='taxonomy', id=','.join(ids[start:start + 100]), retmode='xml'))
        for taxon in ET.fromstring(xml).findall('Taxon'):
            if taxon.findtext('Rank') != 'genus':
                continue
            names = {taxon.findtext('ScientificName')}
            for name in taxon.findall('OtherNames/*'):
                if name.tag in ('Synonym', 'EquivalentName', 'GenbankSynonym', 'Misspelling'):
                    names.add(name.text)
            lineage = {t.findtext('Rank'): t.findtext('ScientificName')
                       for t in taxon.findall('LineageEx/Taxon')}
            order = lineage.get('order', '')
            if not order and not lineage.get('family'):
                continue
            for genus in names.intersection(genera):
                records[genus].append(dict(Genus=genus, Order=order,
                    Family=lineage.get('family', ''), NCBI_name=taxon.findtext('ScientificName'),
                    Source='https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=' + taxon.findtext('TaxId'),
                    Checked_on=datetime.date.today().isoformat()))

    rows = {}
    if OUTPUT.exists():
        with OUTPUT.open() as fh:
            rows.update((r['Genus'], r) for r in csv.DictReader(fh))
    for genus, candidates in records.items():
        if len({(r['Order'], r['Family']) for r in candidates}) == 1:
            rows[genus] = candidates[0]
        else:
            rows.pop(genus, None)
            print('Ambiguous genus, left unresolved:', genus)
    with (ROOT / '_keys/ncbi_navigation_search_log.csv').open('w', newline='') as fh:
        writer = csv.DictWriter(fh, fieldnames=['Genus', 'Database', 'Outcome', 'Next_database', 'Checked_on', 'Detail'])
        writer.writeheader()
        for genus in genera:
            complete = genus in rows and bool(rows[genus]['Order'])
            writer.writerow(dict(Genus=genus, Database='NCBI',
                Outcome='matched' if complete else ('ambiguous' if genus in records and genus not in rows else 'no_usable_order'),
                Next_database='' if complete else 'MDD -> GBIF -> ITIS -> PBDB / literature',
                Checked_on=datetime.date.today().isoformat(), Detail=''))
    with OUTPUT.open('w', newline='') as fh:
        writer = csv.DictWriter(fh, fieldnames=['Genus', 'Order', 'Family', 'NCBI_name', 'Source', 'Checked_on'])
        writer.writeheader()
        writer.writerows(rows[g] for g in sorted(rows))
    print('Cached', len(rows), 'unambiguous genus classifications in', OUTPUT)


def record_ncbi_error(error):
    with (ROOT / '_keys/species_taxonomy.csv').open() as fh:
        genera = sorted({r['Species'].split()[0] for r in csv.DictReader(fh) if not r['Order'] and r['Species']})
    with (ROOT / '_keys/ncbi_navigation_search_log.csv').open('w', newline='') as fh:
        writer = csv.DictWriter(fh, fieldnames=['Genus', 'Database', 'Outcome', 'Next_database', 'Checked_on', 'Detail'])
        writer.writeheader()
        writer.writerows(dict(Genus=g, Database='NCBI', Outcome='service_error',
            Next_database='MDD -> GBIF -> ITIS -> PBDB / literature',
            Checked_on=datetime.date.today().isoformat(), Detail=str(error)) for g in genera)


def main():
    try:
        update_ncbi()
    except Exception as exc:
        print('NCBI service error (not a no-match):', exc, flush=True)
        record_ncbi_error(exc)
        if '--ncbi-only' in sys.argv: raise
    if '--ncbi-only' not in sys.argv:
        subprocess.run([sys.executable, str(ROOT / '_keys/build_species_taxonomy.py')], check=True)
        subprocess.run([sys.executable, str(ROOT / '_tools/update_order_fallbacks.py')], check=True)
        subprocess.run([sys.executable, str(ROOT / '_keys/build_species_taxonomy.py')], check=True)


if __name__ == '__main__':
    main()
