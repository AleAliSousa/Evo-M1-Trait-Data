#!/usr/bin/env python3
"""Trace remaining Shiny Unknown labels to publications and original columns.

Passive report only: reads current compiled products and public source tables;
writes its own CSV/HTML reports. Does not edit taxonomy, source data or merges.
"""
import csv
import html
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / '_checks'


def read(path, delimiter=','):
    with path.open(encoding='utf-8-sig') as fh:
        return list(csv.DictReader(fh, delimiter=delimiter))


def joined(values):
    return ' | '.join(sorted({str(v) for v in values if v not in (None, '', 'NA')}))


def main():
    unresolved = {r['Species']: r for r in read(OUT / 'shiny_taxonomy_unresolved.csv')}
    manifest = read(ROOT / '__ShinyApp/data/source_manifest.csv')
    by_file = {r['file']: r for r in manifest}
    by_item = {r['item_name']: r for r in manifest}
    groups = defaultdict(list)
    inputs = [('Body & ecology', '__merging_body_ecology/body_ecology_unfiltered.csv'),
              ('Brain mass', '__merging_brain_mass/brain_mass_unfiltered.csv')]
    for dataset, relative in inputs:
        for r in read(ROOT / relative):
            if r['Species'] in unresolved:
                groups[(r['Species'], r['Source'])].append((dataset, relative, r))
    for r in read(ROOT / '__merging_supplementary/supplementary_long.csv'):
        if r['Species'] in unresolved:
            for item in r.get('items', '').split(';'):
                m = by_item.get(item.strip())
                if m:
                    groups[(r['Species'], m['file'])].append(('Additional published datasets',
                        '__merging_supplementary/supplementary_long.csv', r))

    source_cache = {f: read(ROOT / '__Public/comparative-data' / f, '\t') for f in {f for label, f in groups}}
    results = []
    papers = defaultdict(list)
    taxon_fields = {'species', 'species_as_published', 'species_printed', 'scientific_name',
        'speciesacceptedname', 'speciesverbatim', 'species_stephan1991', 'genus', 'population'}
    for (label, filename), harvested in sorted(groups.items()):
        m = by_file[filename]
        matches = [(i, r) for i, r in enumerate(source_cache[filename], 1) if label in r.values()]
        fields = joined(k for i, r in matches for k, v in r.items() if v == label)
        context = joined(f'{k}={v}' for i, r in matches for k, v in r.items()
                         if k.lower() in taxon_fields and v and v != label)
        row = dict(Label=label, Datasets=joined(d for d, path, r in harvested),
            Publication=m['publication'], Source_item=m['item_name'], Citation=m['citation'],
            Publication_URL=m['url'], Source_table='__Public/comparative-data/' + filename,
            Label_occurs_in_columns=fields, Matching_source_records=joined(i for i, r in matches),
            Taxon_context_in_matching_rows=context, Harvested_rows=len(harvested),
            Harvested_measurements=joined(r.get('Measure', '') for d, path, r in harvested),
            Harvest_files=joined(path for d, path, r in harvested))
        results.append(row)
        papers[m['item_name']].append(row)
    assert {r['Label'] for r in results} == set(unresolved), 'An unresolved app label lacks source provenance'
    assert all(r['Label_occurs_in_columns'] for r in results), 'A label was not found in its original table'
    with (OUT / 'shiny_taxonomy_unresolved_sources.csv').open('w', newline='', encoding='utf-8') as fh:
        writer = csv.DictWriter(fh, fieldnames=list(results[0]))
        writer.writeheader(); writer.writerows(results)

    esc = html.escape
    sections = []
    for item, rows in sorted(papers.items(), key=lambda kv: (-len(kv[1]), kv[0])):
        r = rows[0]
        source_path = ROOT / r['Source_table']
        items = ''.join('<li><code>' + esc(x['Label']) + '</code></li>' for x in rows)
        sections.append('<section><h2>' + esc(r['Publication']) + ' — ' + str(len(rows)) + ' labels</h2>'
            '<p><a href="' + esc(r['Publication_URL'], quote=True) + '">' + esc(r['Citation']) + '</a></p>'
            '<p>Table: <a href="' + esc(source_path.as_uri(), quote=True) + '">' + esc(item) + '</a><br>'
            'Labels occur in: <strong>' + esc(joined(x['Label_occurs_in_columns'] for x in rows)) + '</strong></p>'
            '<ol>' + items + '</ol></section>')
    report = ('<!doctype html><html lang="en"><meta charset="utf-8"><title>Remaining Unknown labels and sources</title>'
        '<style>body{font:16px/1.55 system-ui,sans-serif;max-width:1050px;margin:40px auto;padding:0 24px;color:#192d38}'
        'h1,h2{line-height:1.25}h2{font-size:21px}section{border-top:1px solid #cbd6dc;margin-top:30px;padding-top:12px}'
        'li{margin:6px 0;overflow-wrap:anywhere}a{color:#12687c}code{font:14px/1.5 ui-monospace,monospace}</style>'
        '<h1>Remaining Unknown labels and their sources</h1>'
        f'<p><strong>{len(unresolved)} distinct app labels, from {len(papers)} source tables.</strong> '
        'There are no named fossil species in this remaining list. Most entries are anatomy, causes of death, '
        'methods, references or notes read into the Species field. Unknown and unspecified placeholders need '
        'row-level source repair, not a single Order assigned to the placeholder.</p>'
        '<p>The companion CSV includes original columns, matching source data-record numbers, taxon context '
        'and harvest provenance for every label. Shared placeholders can occur in multiple source rows; '
        'these matches are trace locations, not proof that they describe one animal.</p>' + ''.join(sections) + '</html>')
    (OUT / 'shiny_taxonomy_unresolved_sources.html').write_text(report, encoding='utf-8')
    print(f'Traced all {len(unresolved)} labels across {len(papers)} source tables.')
    for item, rows in sorted(papers.items(), key=lambda kv: (-len(kv[1]), kv[0])):
        print(item, len(rows), joined(x['Label_occurs_in_columns'] for x in rows))


if __name__ == '__main__':
    main()
