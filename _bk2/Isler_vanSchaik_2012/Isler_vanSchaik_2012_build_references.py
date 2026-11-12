#!/usr/bin/env python3
"""Resolve the published reference scopes without inventing per-trait primaries.

All input is public frozen evidence in this paper folder. Output is item-scoped
source provenance, not cross-compilation validation or a primary-data pool.
"""
import csv,hashlib,re,unicodedata
from collections import defaultdict,Counter
from pathlib import Path
folder=Path(__file__).resolve().parent
repo=folder.parent
publication=folder.name
item=publication+'_1-s2.0-S0047248412000577-mmc2.xls'
refdir=folder/'reference_tables'

def read(p):
 with p.open(encoding='utf-8-sig',newline='') as f:return list(csv.DictReader(f))
def write(name,rows,fields=None):
 with (refdir/name).open('w',encoding='utf-8-sig',newline='') as f:
  w=csv.DictWriter(f,fieldnames=fields or list(rows[0]));w.writeheader();w.writerows(rows)
def norm(s):return re.sub('[^a-z0-9]','',unicodedata.normalize('NFKD',s).encode('ascii','ignore').decode().lower())
def sid(c):return 'citation:'+hashlib.sha256(c.encode()).hexdigest()[:16]
def citation_type(c):
 if re.search(r'\b(In:|\(eds?\)|Handbook|Field Guide|Accounts|Encyclopedia|Mammals of|Mammals:)',c):return 'secondary','book_chapter_or_reference_compilation'
 if re.search(r'\b(thesis|University Press|Academic Press|Edicions)\b',c,re.I):return 'unverified','book_or_thesis'
 return 'unverified','journal_article_primary_status_unchecked'
refs=read(folder/(publication+'_SupplementaryInformation4.References_snapshot.csv'))
by_author_year=defaultdict(list)
for r in refs:
 c=' '.join(r['citation_as_printed'].split());r['citation']=c
 y=re.search(r'\((\d{4}(?:[a-z]|-\d{4})?)\)',c)[1]
 first=re.match(r'^(.+?)\s+[A-Z]',c)[1]
 by_author_year[(norm(first),y)].append(r)
scopes=read(folder/(publication+'_SupplementaryInformation1.3_snapshot.csv'))
# Explicit aliases/year discrepancies remain visible; no automatic author/year collision merge.
aliases={'Gubernick 1981':('gubernick','1981'),'König 2006':('konig','2006')}
parsed=[]
for block in scopes:
 text=' '.join(block['references_as_printed'].split())
 # The Rodentia block contains two separate number-restricted source statements.
 chunks=re.split(r';\s*|(?<=2007) (?=Blumstein)|(?<=\)) (?=Blumstein)',text)
 for chunk in chunks:
  restrict=re.search(r'\(([\d,\- ]+)\)',chunk)
  numbers=restrict[1] if restrict else block['species_numbers_as_printed']
  key=re.sub(r'\s*\([\d,\- ]+\)','',chunk).strip().rstrip(';')
  if key=='Owens and Owens 1979a, b, 1996':keys=['Owens and Owens 1979a','Owens and Owens 1979b','Owens and Owens 1996']
  else:keys=[key]
  for key in keys:
   parsed.append(dict(scope_row=block['source_row'],scope_key=block['scope_key'],scope_as_printed=block['scope_as_printed'],
                      species_numbers_as_printed=numbers,reference_raw=chunk,ref_key=key,source_pdf_page=block['source_pdf_page']))
# Resolve item-cited sources, not all 143 bibliography works.
lookup={};issues=[]
for p in parsed:
 key=p['ref_key']
 if key in lookup:continue
 m=re.search(r'(\d{4}(?:[a-z]|-\d{4})?)$',key)
 author=re.split(r' et al\.| and ',key[:m.start()].strip())[0] if m else ''
 candidates=by_author_year.get(aliases.get(key,(norm(author),m[1] if m else '')),[])
 if len(candidates)==1:
  r=candidates[0];citation=r['citation'];status='resolved_to_local_bibliography';loc='mmc1 PDF p.'+r['source_pdf_page']
 else:
  citation='';status='unresolved' if not candidates else 'author_year_collision';loc=''
  issues.append(dict(reference_raw=key,issue=status,candidate_citations=' | '.join(r['citation'] for r in candidates),note='No guessed substitution applied'))
 level,typ=citation_type(citation) if citation else ('unresolved','unresolved')
 lookup[key]=dict(ref_key=key,cited_in_column='social_ecology_life_history_ref_keys',citation=citation,note='Section 1.3 candidate source scope, not a brain-size citation and not a variable-specific source assertion',
                  source_reference_id=sid(citation or key),reference_level=level,source_type=typ,primary_reference_id='',resolution_status=status,evidence_locator=loc)
brainkey='Isler and van Schaik 2009a'
braincite='Isler, K., van Schaik, C.P., 2009a. The expensive brain: a framework for explaining evolutionary changes in brain size. J. Hum. Evol. 57, 392-400.'
lookup[brainkey]=dict(ref_key=brainkey,cited_in_column='brain_body_source_ref_keys',citation=braincite,note='Main article Methods/Data names 2009a for brain/body and life-history compilation; original per-species sources not supplied by the 2012 workbook',
 source_reference_id='doi:10.1016/j.jhevol.2009.04.009',reference_level='secondary',source_type='secondary_compilation',primary_reference_id='',resolution_status='resolved_citation_primary_chain_open',evidence_locator='main PDF pp.2 and 11')
data=read(folder/(item+'.csv'))
by_n={int(r['species_number']):r for r in data}
hub={r['accepted_name']:r for r in read(repo/'_keys/species_reference.csv')}
def expand(s):
 out=[]
 for t in s.replace(' ','').split(','):
  if not t:continue
  if '-' in t:
   a,b=map(int,t.split('-'));out.extend(range(a,b+1))
  else:out.append(int(t))
 return out
# Lower taxon scopes are expanded only where membership is explicit and stable.
clades={
 'Cercopithecinae':set('Allenopithecus Cercocebus Cercopithecus Chlorocebus Erythrocebus Lophocebus Macaca Mandrillus Papio Theropithecus'.split()),
 'Colobinae':set('Colobus Nasalis Piliocolobus Presbytis Procolobus Pygathrix Rhinopithecus Semnopithecus Simias Trachypithecus'.split()),
 'Tarsiidae':{'Tarsius','Cephalopachus','Carlito'},
 'Platyrrhini':set('Alouatta Aotus Ateles Brachyteles Cacajao Callicebus Callimico Callithrix Cebuella Cebus Chiropotes Lagothrix Leontopithecus Pithecia Saguinus Saimiri'.split()),
 'Lemuriformes':set('Avahi Cheirogaleus Daubentonia Eulemur Hapalemur Indri Lemur Lepilemur Microcebus Mirza Phaner Propithecus Varecia'.split())}
links=[]
for p in parsed:
 if p['species_numbers_as_printed']:
  selected=[by_n[n] for n in expand(p['species_numbers_as_printed'])];assignment='explicit_species_number'
 else:
  scope=p['scope_key'];selected=[];assignment='published_taxonomic_scope'
  for r in data:
   genus=r['species_as_published'].split('_')[0]
   family=hub.get(r['Species'],{}).get('Family_resolved','')
   if scope=='all_mammals' or r['group_as_published']==scope or family==scope or genus in clades.get(scope,set()) or (scope=='Insectivora' and family in {'Erinaceidae','Soricidae','Talpidae','Chrysochloridae','Tenrecidae'}):selected.append(r)
 for r in selected:
  ref=lookup[p['ref_key']]
  links.append(dict(compilation_id=item,source_row=r['source_excel_row'],species_number=r['species_number'],species_as_published=r['species_as_published'],Species=r['Species'],
   field_scope='social_behavior_ecology_life_history',source_reference_id=ref['source_reference_id'],primary_reference_id='',reference_raw=p['reference_raw'],ref_key=p['ref_key'],
   reference_role='candidate_scope_source',assignment_basis=assignment,source_scope_row=p['scope_row'],source_locator='mmc1 PDF p.'+p['source_pdf_page'],primary_pool_eligible=False))
for r in data:
 links.append(dict(compilation_id=item,source_row=r['source_excel_row'],species_number=r['species_number'],species_as_published=r['species_as_published'],Species=r['Species'],
   field_scope='brain_size; body_mass',source_reference_id=lookup[brainkey]['source_reference_id'],primary_reference_id='',reference_raw=brainkey,ref_key=brainkey,
   reference_role='direct_reported_secondary_source',assignment_basis='main_article_Methods_Data',source_scope_row='',source_locator='main PDF p.2',primary_pool_eligible=False))
assert all(l['source_reference_id'] in {r['source_reference_id'] for r in lookup.values()} for l in links)
assert all(not l['primary_reference_id'] and not l['primary_pool_eligible'] for l in links)
write(item+'_references.csv',list(lookup.values()))
write(item+'_value_reference_links.csv',links)
write(item+'_source_scope_reference_links.csv',parsed)
write(item+'_reference_issues.csv',issues,['reference_raw','issue','candidate_citations','note'])
write(item+'_primary_references.csv',[],list(next(iter(lookup.values()))))
# Convenience keys are derived from the authoritative links, with the raw scope preserved.
keys=defaultdict(set)
for l in links:
 if l['field_scope']=='social_behavior_ecology_life_history':keys[l['species_number']].add(l['ref_key'])
for r in data:r['social_ecology_life_history_ref_keys']='; '.join(sorted(keys[r['species_number']]))
with (folder/(item+'.csv')).open('w',encoding='utf-8',newline='') as f:
 w=csv.DictWriter(f,fieldnames=list(data[0]));w.writeheader();w.writerows(data)
# The production R reader writes the TSV after this provenance enrichment.
print(f'{len(lookup)} cited-source keys, {len(links)} value/scope links, {len(issues)} unresolved aliases, 0 primary-eligible values')
for i in issues:print(i)
