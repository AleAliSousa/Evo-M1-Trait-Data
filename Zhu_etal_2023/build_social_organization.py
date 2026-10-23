"""Build the social-only merge view; retain all original snapshots and citations."""
import csv
from pathlib import Path
P = Path(__file__).resolve().parent

def read(name):
    with (P / name).open(encoding='utf-8-sig', newline='') as f:
        return list(csv.DictReader(f))

def write(name, rows):
    with (P / name).open('w', encoding='utf-8', newline='') as f:
        w = csv.DictWriter(f, fieldnames=list(rows[0])); w.writeheader(); w.writerows(rows)

labels = {'S': 'Solitary', 'PL': 'Pair-living', 'GL': 'Group-living'}
rows, overlaps, seen = [], [], {}
for table in ('SupplementaryData1', 'SupplementaryData3'):
    data = read(f'Zhu_etal_2023_{table}.csv')
    assert len({r['SpeciesName'] for r in data}) == len(data)
    for r in data:
        states = r['SocialPolymorphism'].replace(',', ';').split(';')
        assert len(states) == len(set(states)) and set(states) <= labels.keys()
        for code, col in [('S', 'Solitary/S'), ('PL', 'PairLiving/PL'),
                          ('GL', 'GroupLiving/GL' if table == 'SupplementaryData1' else 'GroupLiving.GL')]:
            assert r[col] in ('Yes', 'No') and (r[col] == 'Yes') == (code in states)
        value = '; '.join(labels[s] for s in labels if s in states)
        name = r['SpeciesName']
        if name in seen:
            assert seen[name] == value, (name, seen[name], value)
            overlaps.append(dict(SpeciesName=name,Data1=seen[name],Data3=value,decision='Data1 retained; identical social classification'))
            continue
        seen[name] = value
        refs = r['Supplementary_References_codes']
        role = 'primary' if 'Social organization was observed in this study' in refs else 'secondary'
        rows.append(dict(SpeciesName=name, Social_organization=value,
                         Solitary='Yes' if 'S' in states else 'No',
                         Pair_living='Yes' if 'PL' in states else 'No',
                         Group_living='Yes' if 'GL' in states else 'No',
                         source_item=f'Zhu_etal_2023_{table}', source_row_ID=r['ID'],
                         role=role, Supplementary_References_codes=refs,
                         provenance_scope='References supplied for the species row across traits; not individually assigned to social organization'))
assert len(rows) == 1008 and len(overlaps) == 60
assert sum(r['role'] == 'primary' for r in rows) == 5
write('Zhu_etal_2023_SocialOrganization.csv', rows)
write('Zhu_etal_2023_SocialOrganization_overlap_audit.csv', overlaps)
print(f'{len(rows)} species; {len(overlaps)} repeated source rows retained in overlap audit')
