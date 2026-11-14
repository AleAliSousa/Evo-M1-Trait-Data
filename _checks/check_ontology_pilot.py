"""Validate pilot rule links and report where source variables enter current merges.

This is a QA gate only. Draft comparison decisions never select or pool values.
"""
import csv
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PILOT = ROOT / '_keys' / 'ontology_pilot'


def read(path):
    with (ROOT / path).open(newline='', encoding='utf-8-sig') as f:
        return list(csv.DictReader(f))


def main():
    rows = read('_keys/ontology_pilot/paper_variable_crosswalk.csv')
    defs = {r['label']: r for r in read('_keys/variable_definitions.csv')}
    boundaries = {(r['concept'], r['domain'], r['term']) for r in read('_keys/anatomy_crosswalk.csv')}
    methods = {r['item_name']: r for r in read('_keys/cell_count_methods/source_methods.csv') if not r['filter']}
    relationships = {r['pair_id']: r for r in read('_keys/source_relationships.csv')}
    if_rows = read('__merging_cell_counts_isotropic_fractionator/cell_counts_isotropic_fractionator_long.csv')
    if_counts = Counter((r['Source'], r['Variable']) for r in if_rows)
    contributions = read('__merging_volumes/volumes_source_contributions.csv')
    volume_counts = Counter((r['Source'], r['Variable']) for r in contributions)
    behavior_counts = Counter(r['Measure'] for r in read('__merging_behaviour/behaviour_long.csv'))
    sleep_counts = Counter(r['Standardized_Term'] for r in read('__merging_sleep/sleep_long.csv'))
    ids = [r['mapping_id'] for r in rows]
    assert len(ids) == len(set(ids)), 'duplicate mapping_id'
    report = []
    errors = []
    for r in rows:
        mid = r['mapping_id']
        if r['poolable_group_ref']:
            d = defs.get(r['standardized_variable'])
            if not d or d['poolable_group'] != r['poolable_group_ref']:
                errors.append(f'{mid}: poolable_group link does not match variable_definitions')
        if r['boundary_rule_ref']:
            parts = tuple(r['boundary_rule_ref'].split('|'))
            if len(parts) != 3 or parts not in boundaries:
                errors.append(f'{mid}: boundary_rule_ref not found in anatomy_crosswalk')
        if r['method_rule_ref'] and r['method_rule_ref'] not in methods:
            errors.append(f'{mid}: method_rule_ref not found in source_methods')
        for link in filter(None, r['source_relationship_refs'].split(';')):
            if link not in relationships:
                errors.append(f'{mid}: source_relationship_ref {link} not found')
            elif r['paper'] not in (relationships[link]['paper_a'], relationships[link]['paper_b']):
                errors.append(f'{mid}: source_relationship_ref {link} does not involve {r["paper"]}')
        source = r['source_item']
        variable = r['merge_variable']
        if_n = if_counts[source, variable]
        # Volumes use full registry item names; the key's reference may be abbreviated.
        vol_n = sum(n for (item, term), n in volume_counts.items()
                    if term == variable and (item == source or item.startswith(r['paper'] + '_')))
        behavior_n = behavior_counts[variable] if r['behavior'] and variable else 0
        sleep_n = sleep_counts[variable] if r['behavior'] and variable else 0
        report.append({
            'mapping_id': mid, 'comparison_decision': r['comparison_decision'],
            'poolable_group_ref': r['poolable_group_ref'],
            'boundary_rule_ref': r['boundary_rule_ref'],
            'method_rule_ref': r['method_rule_ref'],
            'source_relationship_refs': r['source_relationship_refs'],
            'if_long_rows': if_n, 'volumes_contribution_rows': vol_n,
            'behavior_variable_rows': behavior_n, 'sleep_variable_rows': sleep_n,
            'integration_status': 'observed_in_current_merge' if if_n or vol_n or behavior_n or sleep_n else 'not_matched_to_current_merges',
        })
    if errors:
        raise SystemExit('\n'.join(errors))
    out = PILOT / 'merge_alignment.csv'
    with out.open('w', newline='', encoding='utf-8') as f:
        w = csv.DictWriter(f, fieldnames=report[0].keys())
        w.writeheader()
        w.writerows(report)
    print(f'ontology pilot: validated {len(rows)} mappings; {sum(x["integration_status"] == "observed_in_current_merge" for x in report)} observed in current merge outputs; report {out}')


if __name__ == '__main__':
    main()
