#!/usr/bin/env python3
"""Continue missing-Order lookup after NCBI: MDD -> GBIF -> ITIS -> PBDB.

Classification only: preserve the compiled label and species identity. See
_keys/README_navigation_taxonomy.md. Network responses are cached outside the
repository; accepted classifications and every attempt are recorded in CSVs.
"""
import concurrent.futures
import csv
import datetime
import hashlib
import io
import json
import re
import tempfile
import time
import urllib.parse
import urllib.request
import zipfile
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
KEYS = ROOT / '_keys'
CACHE = Path(tempfile.gettempdir()) / 'evom1_order_lookup_cache'
FIELDS = ['Species', 'Order', 'Family', 'Genus', 'Authority', 'Matched_name',
          'Match_basis', 'Source', 'Checked_on', 'Notes']
MDD_URL = 'https://raw.githubusercontent.com/mammaldiversity/mammaldiversity.github.io/master/assets/data/MDD.zip'
TODAY = datetime.date.today().isoformat()


def read_csv(path):
    return list(csv.DictReader(path.open(encoding='utf-8-sig'))) if path.exists() else []


def write_csv(path, rows, fields):
    temporary = path.with_name('.' + path.name + '.tmp')
    with temporary.open('w', newline='', encoding='utf-8') as fh:
        writer = csv.DictWriter(fh, fieldnames=fields)
        writer.writeheader()
        writer.writerows(rows)
    temporary.replace(path)


def download(url):
    CACHE.mkdir(exist_ok=True)
    path = CACHE / hashlib.sha256(url.encode()).hexdigest()
    if path.exists():
        return path.read_bytes()
    error = None
    for attempt in range(2):
        try:
            request = urllib.request.Request(url, headers={'User-Agent': 'EvoM1-taxonomy-curation/1.0'})
            with urllib.request.urlopen(request, timeout=18) as response:
                data = response.read()
            path.write_bytes(data)
            return data
        except Exception as exc:
            error = exc
            time.sleep(0.4)
    raise error


def get_json(base, **params):
    url = base + '?' + urllib.parse.urlencode(params)
    return json.loads(download(url)), url


def norm(name):
    return ' '.join(str(name).replace('_', ' ').split()).casefold()


def label_status(label):
    low = label.casefold()
    anatomy = ('allocortex', 'amygdaloid complex', 'bulbus olfactorius', 'cerebellum',
        'corpus striatum', 'diencephalon', 'limbic structures', 'medulla oblongata',
        'mesencephalon', 'neocortex', 'nuclei basalis', 'palaeocortex', 'regio ',
        'schizocortex', 'septum', 'telencephalon', 'tuberculum olfactorium')
    clinical = ('asphyxia', 'bronchopneumonia', 'cardiac ', 'coronary ', 'emphysema',
        'failed prosthetic', 'gastrointestinal hemorrhage', 'heroin overdose',
        'motor vehicle accident', 'myocardial infarction', 'myxoid leiomyosarcoma',
        'pneumonia', 'prostate cancer', 'pulmonary hemorrhage', 'respiratory arrest', 'sepsis')
    metadata = ('actigraphy', 'videography', 'body weight;', 'published values',
        'printed source block', 'phylogeny of sleep', 'hafner et al', 'isler et al')
    if low.startswith(anatomy + clinical + metadata):
        return 'non_taxon_label'
    if low in ('na', 'unknown', 'not specified', 'not recognised', 'northern group',
               'southern group', 'east-central group', 'human synthesis', 'gray-necked species group'):
        return 'unspecified_source_label'
    return 'animal_name'


def queries(label):
    value = re.sub(r'\s*\([^)]*\)', '', label).strip()
    value = re.sub(r'^Subgenus\s+', '', value)
    words = value.split()
    # Abbreviations need the source's context, never a global fuzzy expansion.
    if not words or not re.fullmatch(r'[A-Za-z]{3,}', words[0]):
        return []
    words[0] = words[0].capitalize()
    if len(words) > 1 and words[1].lower().rstrip('.') in ('sp', 'spp', 'larva'):
        words = words[:1]
    return list(dict.fromkeys([' '.join(words[:3]), ' '.join(words[:2]), words[0]]))


def record(label, authority, name, order, family, genus, basis, source, notes=''):
    return dict(Species=label, Order=order, Family=family, Genus=genus,
        Authority=authority, Matched_name=name, Match_basis=basis, Source=source,
        Checked_on=TODAY, Notes=notes)


def mdd_index():
    # Reuse an already downloaded official release when available.
    local = Path(tempfile.gettempdir()) / 'evom1_MDD.zip'
    archive = zipfile.ZipFile(io.BytesIO(local.read_bytes() if local.exists() else download(MDD_URL)))
    paths = [p for p in archive.namelist() if p.startswith('MDD/') and p.endswith('.csv')]
    species_file = next(p for p in paths if '/MDD_v' in p)
    synonym_file = next(p for p in paths if '/Species_Syn' in p)
    rows = list(csv.DictReader(io.StringIO(archive.read(species_file).decode('utf-8-sig'))))
    index = defaultdict(list)
    by_id = {r['id']: r for r in rows}
    for r in rows:
        for name, basis in [(r['sciName'], 'exact accepted name'), (r['genus'], 'exact genus'),
                             (r['family'], 'exact family')]:
            index[norm(name)].append((r, basis))
    for s in csv.DictReader(io.StringIO(archive.read(synonym_file).decode('utf-8-sig'))):
        r = by_id.get(s['MDD_species_id'])
        if r:
            for name in (s['MDD_original_combination'], s['MDD_normalized_original_combination']):
                if name and name != 'NA': index[norm(name)].append((r, 'exact documented synonym'))
    version = species_file.split('/')[-1].split('_')[1]
    return index, version


def lookup_mdd(label, index, version):
    for query in queries(label):
        hits = index.get(norm(query), [])
        if hits and len({r['order'] for r, basis in hits}) == 1:
            r, basis = hits[0]
            name = r['family'] if basis == 'exact family' else r['genus'] if basis == 'exact genus' else r['sciName'].replace('_', ' ')
            return record(label, 'MDD ' + version, name,
                r['order'], r['family'], '' if basis == 'exact family' else r['genus'], basis + ': ' + query,
                'https://www.mammaldiversity.org/taxon/' + r['id'])


def lookup_gbif(label):
    attempts = []
    for query in queries(label):
        result, url = get_json('https://api.gbif.org/v2/species/match', scientificName=query, kingdom='Animalia')
        usage = result.get('usage', {})
        classification = {r['rank']: r['name'] for r in result.get('classification', [])}
        diag = result.get('diagnostics', {})
        kind = diag.get('matchType', 'NONE')
        canonical = usage.get('canonicalName', '')
        exact = norm(canonical) == norm(query) and kind in ('EXACT', 'VARIANT', 'HIGHERRANK')
        # An exact synonym may point to a differently named accepted usage.
        synonym = kind == 'EXACT' and result.get('synonym', False)
        if classification.get('KINGDOM') == 'Animalia' and classification.get('ORDER') and (exact or synonym):
            attempts.append((query, 'matched', kind + ': ' + canonical))
            return record(label, 'GBIF', canonical, classification['ORDER'], classification.get('FAMILY', ''),
                classification.get('GENUS', canonical if usage.get('rank') == 'GENUS' else ''),
                kind + ' ' + ('synonym' if synonym else 'name') + ': ' + query,
                url, 'GBIF usage ' + str(usage.get('key', ''))), attempts
        attempts.append((query, 'candidate_requires_review' if kind not in ('NONE', '') else 'no_match',
                         kind + ': ' + canonical + '; confidence=' + str(diag.get('confidence', ''))))
    return None, attempts


def lookup_itis(label):
    attempts = []
    for query in queries(label):
        result, url = get_json('https://www.itis.gov/ITISWebService/jsonservice/searchByScientificName', srchKey=query)
        hits = [r for r in result.get('scientificNames', []) if r and norm(r.get('combinedName', '')) == norm(query)]
        candidates = []
        for hit in hits:
            h, source = get_json('https://www.itis.gov/ITISWebService/jsonservice/getFullHierarchyFromTSN', tsn=hit['tsn'])
            ranks = {r['rankName'].lower(): r['taxonName'] for r in h.get('hierarchyList', []) if r}
            if ranks.get('kingdom') == 'Animalia' and ranks.get('order'):
                candidates.append((hit, ranks, source))
        if candidates and len({r['order'] for hit, r, source in candidates}) == 1:
            hit, ranks, source = candidates[0]
            attempts.append((query, 'matched', 'TSN=' + hit['tsn']))
            return record(label, 'ITIS', hit['combinedName'], ranks['order'], ranks.get('family', ''),
                ranks.get('genus', ''), 'exact name: ' + query, source), attempts
        attempts.append((query, 'ambiguous' if candidates else 'no_match', 'exact records=' + str(len(hits))))
    return None, attempts


def lookup_pbdb(label):
    attempts = []
    for query in queries(label):
        result, url = get_json('https://paleobiodb.org/data1.2/taxa/list.json', name=query, show='class,ref')
        hits = [r for r in result.get('records', []) if norm(r.get('nam', '')) == norm(query) and r.get('odl')]
        if hits and len({r['odl'] for r in hits}) == 1:
            r = hits[0]
            attempts.append((query, 'matched', r.get('oid', '')))
            return record(label, 'PBDB', r['nam'], r['odl'], r.get('fml', ''), r.get('gnl', ''),
                'exact name: ' + query, url, r.get('ref', '')), attempts
        attempts.append((query, 'ambiguous' if hits else 'no_match', 'exact classified records=' + str(len(hits))))
    return None, attempts


def resolve_label(label, index, version, mdd_error=''):
    status = label_status(label)
    if status != 'animal_name':
        return None, [], dict(Species=label, Status=status,
            Next_action='Repair the source Species field; do not assign a taxonomic Order.' if status == 'non_taxon_label'
            else 'Trace the source context to identify an animal or a higher taxon.', Checked_on=TODAY)
    attempts = []
    result = lookup_mdd(label, index, version)
    attempts.append(('MDD', label, 'service_error' if mdd_error else 'matched' if result else 'no_match', mdd_error or version))
    if result: return result, attempts, None
    for authority, lookup in [('GBIF', lookup_gbif), ('ITIS', lookup_itis), ('PBDB', lookup_pbdb)]:
        try:
            result, provider_attempts = lookup(label)
            attempts.extend((authority, *a) for a in provider_attempts)
            if result: return result, attempts, None
        except Exception as exc:
            attempts.append((authority, label, 'service_error', str(exc)))
            # An outage is not a no-match: continue to the next provider.
    return None, attempts, dict(Species=label, Status='needs_source_or_literature_review',
        Next_action='Inspect recorded candidates and source context; verify spelling, synonyms, abbreviations or taxonomic literature. Retry service errors.', Checked_on=TODAY)


def main():
    targets = [r['Species'] for r in read_csv(KEYS / 'species_taxonomy.csv') if not r['Order']]
    output = {r['Species']: r for r in read_csv(KEYS / 'order_navigation_fallbacks.csv')}
    # Preserve completed names' search history when continuing a later pass.
    log = [r for r in read_csv(KEYS / 'navigation_taxonomy_search_log.csv') if r['Species'] not in targets]
    review = []
    mdd_error = ''
    try:
        index, version = mdd_index()
    except Exception as exc:
        mdd_error = str(exc)
        index, version = {}, ''
        print('MDD service error (continuing to GBIF):', exc, flush=True)

    with concurrent.futures.ThreadPoolExecutor(max_workers=5) as executor:
        reviewed = {r['Species']: r for r in read_csv(KEYS / 'navigation_label_queries.csv')}
        evidence = {r['Species']: r for r in read_csv(KEYS / 'navigation_order_evidence.csv')}
        issues = {r['Species']: r for r in read_csv(KEYS / 'navigation_label_issues.csv')}
        def resolve(label):
            if label in issues:
                issue = issues[label]
                return None, [], dict(Species=label, Status=issue['Status'],
                    Next_action=issue['Next_action'] + ' Source: ' + issue['Source_context'], Checked_on=TODAY)
            if label in evidence:
                r = evidence[label]
                return r, [(r['Authority'], r['Matched_name'], 'matched', r['Source'])], None
            query = reviewed[label]['Query_name'] if label in reviewed else label
            result, attempts, unresolved = resolve_label(query, index, version, mdd_error)
            if result and label in reviewed:
                result['Species'] = label
                result['Match_basis'] = 'Source-reviewed classification query ' + query + '; ' + result['Match_basis']
                result['Notes'] = '; '.join(filter(None, [result['Notes'], reviewed[label]['Reason'], reviewed[label]['Source_context']]))
            if unresolved: unresolved['Species'] = label
            return result, attempts, unresolved
        for i, (label, resolved) in enumerate(zip(targets, executor.map(resolve, targets)), 1):
            result, attempts, unresolved = resolved
            if result: output[label] = result
            if unresolved: review.append(unresolved)
            log.extend(dict(Species=label, Database=db, Query=q, Outcome=status, Detail=detail, Checked_on=TODAY)
                       for db, q, status, detail in attempts)
            if i % 20 == 0 or i == len(targets):
                print('Processed', i, '/', len(targets), '; classified', len(output), '; review', len(review), flush=True)
                # Atomic checkpoints also avoid repeatedly rewriting cloud-synced
                # files for every name. Requests already completed are cached.
                write_csv(KEYS / 'order_navigation_fallbacks.csv', [output[s] for s in sorted(output)], FIELDS)
                write_csv(KEYS / 'navigation_taxonomy_search_log.csv', log,
                          ['Species', 'Database', 'Query', 'Outcome', 'Detail', 'Checked_on'])
                write_csv(KEYS / 'navigation_taxonomy_review.csv', review,
                          ['Species', 'Status', 'Next_action', 'Checked_on'])


if __name__ == '__main__':
    main()
