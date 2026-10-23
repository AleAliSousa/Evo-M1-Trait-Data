"""Reconcile hub/spoke taxids against the checked-in NCBI snapshot, offline.

Default: check only. --apply writes reconciled keys and an audit of changed IDs.
Preserves project accepted_name anchors, including fossil grades. Taxids identify
NCBI taxa; they never authorize pooling across grades or specimen kinds.
"""
import argparse
import csv
import io
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent
EMPTY = ('', 'NA')
GRADE = {'Homo sapiens (early)': 'early', 'Homo sapiens (archaic)': 'archaic'}
# Existing historical spellings/combinations whose current record omits the alias.
LEGACY = {'Onychogalea fraenata': '114227', 'Pteropus giganteus': '143291'}


def read(path):
    with path.open(encoding='utf-8-sig', newline='') as f:
        r = csv.DictReader(f)
        return r.fieldnames, list(r)


def write(path, fields, rows):
    old = path.read_bytes() if path.exists() else b''
    newline = '\r\n' if b'\r\n' in old else '\n'
    buf = io.StringIO(newline='')
    w = csv.DictWriter(buf, fieldnames=fields, lineterminator=newline)
    w.writeheader(); w.writerows(rows)
    data = buf.getvalue().encode('utf-8')
    if data != old:
        path.write_bytes(data)


def reconcile(apply=False):
    _, records = read(ROOT / 'ncbi_taxonomy_snapshot.csv')
    snap = {r['queried_taxid']: r for r in records}
    paths = [ROOT / 'species_reference.csv'] + sorted(ROOT.glob('*/species_key.csv'))
    tables = {p: read(p) for p in paths}
    hp = paths[0]; fields, hub = tables[hp]
    by_name = {r['accepted_name']: r for r in hub}
    candidates = {}
    for _, rows in tables.values():
        for r in rows:
            if r['ncbi_taxid'] not in EMPTY:
                candidates.setdefault(r['accepted_name'], set()).add(r['ncbi_taxid'])
    # Missing hub anchors already used by spokes: preserve their name and rank.
    for name in sorted(set(candidates) - set(by_name)):
        r = dict.fromkeys(fields, 'NA')
        r.update(accepted_name=name, ncbi_taxid='NA', needs_taxonomy_review='TRUE',
                 rank='genus' if name.endswith(' sp.') else 'species', taxon_type='extant',
                 taxonomy_source='Added from existing spoke anchor; NCBI snapshot 2026-10-22')
        if name == 'Chiroptera sp.': r['rank'] = 'order'
        for col in ('in_Stephan', 'in_HerculanoHouzel', 'in_Allman'): r[col] = 'FALSE'
        hub.append(r); by_name[name] = r
    extra = ['taxon_name', 'temporal_grade', 'ncbi_name', 'ncbi_rank', 'ncbi_mapping_basis']
    for col in extra:
        if col not in fields: fields.append(col)
    changes = []
    chosen = {}
    for name, r in by_name.items():
        target = name[:-4] if name.endswith(' sp.') else name
        ids = candidates.get(name, set())
        if name in GRADE:
            tid = '9606'; basis = 'source_hypothesis' if GRADE[name] == 'archaic' else 'source_species'
        elif name == 'Callicebus sp.':
            tid = '9522'; basis = 'genus_rank'
        elif name in LEGACY:
            tid = snap[LEGACY[name]]['ncbi_taxid']; basis = 'retained_legacy_name'
        elif ids:
            matches = {snap[t]['ncbi_taxid'] for t in ids
                       if t in snap and target.lower() in
                       [n.lower() for n in json.loads(snap[t]['names_json'])]}
            if len(matches) != 1:
                raise ValueError(f'No unique verified mapping for {name}: {ids} -> {matches}')
            tid = matches.pop(); basis = 'genus_rank' if name.endswith(' sp.') else 'NCBI_name_or_synonym'
        else:
            tid = 'NA'; basis = 'unmapped'
        chosen[name] = tid
        r['taxon_name'] = 'Homo sapiens' if name in GRADE else name
        r['temporal_grade'] = GRADE.get(name, 'NA')
        r['ncbi_name'] = snap[tid]['ncbi_name'] if tid != 'NA' else 'NA'
        r['ncbi_rank'] = snap[tid]['ncbi_rank'] if tid != 'NA' else 'NA'
        r['ncbi_mapping_basis'] = basis
        if r['ncbi_taxid'] != tid:
            changes.append(dict(file=str(hp.relative_to(ROOT)), accepted_name=name,
                                source_publication='', old_taxid=r['ncbi_taxid'], new_taxid=tid, basis=basis))
            r['ncbi_taxid'] = tid
            r['taxonomy_source'] += '; taxid reconciled against NCBI snapshot 2026-10-22'
        if tid != 'NA':
            for col, key in [('Order_resolved', 'order'), ('Family_resolved', 'family')]:
                if r[col] in EMPTY and snap[tid][key]: r[col] = snap[tid][key]
        if name in GRADE:
            r['taxonomy_source'] = ('Published temporal grade; taxon_name and ncbi_taxid encode the source assignment; '
                'temporal_grade is independent. Shared taxid does not authorize pooling. ' +
                ('Kabwe and Swanscombe retain Weaver 2001 hypothesis; no modern specimen re-identification.'
                 if GRADE[name] == 'archaic' else 'Early anatomically modern Homo sapiens; NCBI 9606.'))
    for p in paths[1:]:
        for r in tables[p][1]:
            name = r['accepted_name']; tid = chosen.get(name, 'NA')
            new = '' if tid == 'NA' else tid
            if r['ncbi_taxid'] != new:
                changes.append(dict(file=str(p.relative_to(ROOT)), accepted_name=name,
                    source_publication=r['source_publication'], old_taxid=r['ncbi_taxid'], new_taxid=new,
                    basis=by_name[name]['ncbi_mapping_basis']))
                r['ncbi_taxid'] = new
                r['note'] += '; taxid reconciled against NCBI snapshot 2026-10-22'
            if name in GRADE:
                # Replace the former policy of encoding grade through a missing taxid.
                r['note'] = r['note'].split('; fossil grade')[0].split('; taxon_name=Homo sapiens')[0]
                r['note'] += ('; taxon_name=Homo sapiens; temporal_grade=' + GRADE[name] +
                    '; ncbi_taxid=9606 represents the published taxonomic assignment; retain grade and specimen identity when aggregating')
                if GRADE[name] == 'archaic':
                    r['note'] += '; source hypothesis only: Kabwe and Swanscombe not re-identified as modern H. sapiens'
    if apply:
        for p, (cols, rows) in tables.items(): write(p, cols, rows)
        if changes:
            write(ROOT / 'ncbi_taxid_reconciliation.csv', list(changes[0]), changes)
    else:
        differences = []
        for p, (cols, rows) in tables.items():
            oldcols, oldrows = read(p)
            if cols != oldcols or rows != oldrows: differences.append(str(p.relative_to(ROOT)))
        if differences: raise SystemExit('Reconciliation needed: ' + ', '.join(differences))
    print(f'{len(hub)} hub anchors; {len(changes)} taxid changes; ' + ('applied' if apply else 'consistent'))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--apply', action='store_true')
    reconcile(parser.parse_args().apply)
