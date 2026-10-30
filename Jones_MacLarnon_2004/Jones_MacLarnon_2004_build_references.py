#!/usr/bin/env python3
"""Bind published per-variable keys; preserve abbreviations and as-cited-in chains.

These are provenance links, never extra observations or verified primary records.
The untouched publisher text files are the frozen evidence.
"""
import csv,hashlib,re
from pathlib import Path
from collections import defaultdict
folder=Path(__file__).resolve().parent
item=folder.name+'_datafile1'
refdir=folder/'reference_tables'
def read(p,encoding='utf-8-sig',delimiter=','):
 with p.open(encoding=encoding,newline='') as f:return list(csv.DictReader(f,delimiter=delimiter))
def write(suffix,rows,fields=None):
 with (refdir/(item+suffix+'.csv')).open('w',encoding='utf-8-sig',newline='') as f:
  w=csv.DictWriter(f,fieldnames=fields or list(rows[0]));w.writeheader();w.writerows(rows)
refs=read(folder/(folder.name+'_datafile2_snapshot.txt'),'cp1252','\t')
bib={r['Ref No.']:r['Reference'] for r in refs}
data=read(folder/(item+'.csv'))
columns={'body_brain_ref_keys':'body_mass_g; brain_mass_mg','bmr_ref_keys':'bmr_mLO2_hr','intestine_ref_keys':'intestine_length_mm','gestation_ref_keys':'gestation_length_days','diet_ref_keys':'diet_code'}
used=defaultdict(set)
for r in data:
 for col in columns:
  for k in r[col].split(';'):
   if k.strip():used[k.strip()].add(col)
def rid(k):
 return 'citation:'+hashlib.sha256(bib[k].encode('utf-8')).hexdigest()[:16] if k in bib else 'unresolved:'+folder.name+':'+k
lookup=[];issues=[]
for k,cols in used.items():
 citation=bib.get(k,'')
 parent=re.search(r'cited in (?:Ref )?(\d+)',citation)
 level,typ='unverified','journal_article_primary_status_unchecked'
 status='full_citation_supplied'
 note='Primary status and measurement methods require inspection of the cited work'
 if k=='2603':level,typ='secondary','comparative_monograph_compilation';note='Baron et al. 1996 comparative compilation; do not treat this relay as an independent measurement'
 elif re.search(r'Mammalian Species|Walker.s|Compendium|compendium|Field Guide|Action Plan|In:|Symposia|Conservation International',citation):level,typ='secondary','reference_account_book_or_review'
 if parent:
  level,typ='as_cited_in','abbreviated_reference_via_secondary_work'
  status='abbreviated_citation_parent_identified';note='Preserve earlier work and intermediary separately; primary identity not fully resolved'
 if k=='9':typ='compound_abbreviated_reference';note+='; Dubois 1897 and 1914 remain one published compound key, not two assigned samples'
 if not citation:
  level,typ,status='unresolved','absent_reference_key','missing_from_published_source_file'
  note='Key 123 is printed for Cynopterus sphinx gestation but is absent from datafile2; no substitution inferred'
  issues.append(dict(ref_key=k,issue=status,affected_species='Cynopterus sphinx',field='gestation_length_days',note=note))
 lookup.append(dict(ref_key=k,cited_in_column='; '.join(sorted(cols)),citation=citation,note=note,
  source_reference_id=rid(k),reference_level=level,source_type=typ,primary_reference_id='',resolution_status=status,
  cited_in_reference_key=parent[1] if parent else '',evidence_locator='datafile2.txt line '+str(next((i+2 for i,r in enumerate(refs) if r['Ref No.']==k),''))))
links=[]
for r in data:
 for col,field in columns.items():
  for k in map(str.strip,r[col].split(';')):
   if not k:continue
   links.append(dict(compilation_id=item,source_row=r['source_row'],source_text_line=r['source_text_line'],species_as_published=r['species_as_published'],Species=r['Species'],
    field_scope=field,reference_raw=r[col],ref_key=k,source_reference_id=rid(k),primary_reference_id='',
    reference_role='joint_body_brain_source_not_partitioned' if col=='body_brain_ref_keys' else 'published_variable_source',
    value_present='; '.join(f+':'+str(bool(r[f])) for f in field.split('; ')),
    source_locator='datafile1.txt line '+r['source_text_line'],primary_pool_eligible=False))
chains=[]
for k,c in bib.items():
 p=re.search(r'cited in (?:Ref )?(\d+)',c)
 if p:
  assert p[1] in bib,(k,p[1])
  chains.append(dict(ref_key=k,source_reference_id=rid(k),citation_as_published=c,cited_in_reference_key=p[1],
   cited_in_source_reference_id=rid(p[1]),cited_in_citation=bib[p[1]],relation='earlier_work_reported_via_cited_intermediary',
   primary_reference_id='',note='Not a proven original-observation link; abbreviated compound keys remain compound'))
assert all(l['source_reference_id'] in {r['source_reference_id'] for r in lookup} for l in links)
assert all(not l['primary_pool_eligible'] for l in links)
write('_references',lookup)
write('_value_reference_links',links)
write('_reference_chain_links',chains)
write('_reference_issues',issues,['ref_key','issue','affected_species','field','note'])
write('_primary_references',[],list(lookup[0]))
print(f'{len(data)} species; {len(lookup)} cited keys; {len(links)} variable/source links; {len(chains)} as-cited-in chains; {len(issues)} unresolved key')
