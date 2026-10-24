"""Trace explicit Zhu ref 1 links, never infer source attribution from value agreement."""
import csv,json,collections,re
from pathlib import Path
R=Path(__file__).resolve().parents[2];P=R/'_checks/social_variables'
def read(path):return list(csv.DictReader(path.open(encoding='utf-8-sig')))
def write(path,rows):
 with path.open('w',newline='') as f:
  w=csv.DictWriter(f,list(rows[0]));w.writeheader();w.writerows(rows)
z=read(R/'Zhu_etal_2023/Zhu_etal_2023_SocialOrganization.csv')
l=read(R/'Lukas_CluttonBrock/Lukas_CluttonBrock_2013_SupplementaryData.csv')
refs={r['ref_key']:r for r in read(R/'Lukas_CluttonBrock/reference_tables/Lukas_CluttonBrock_2013_SupplementaryData_references.csv')}
normal=lambda s:s.replace('_',' ').strip().casefold()
name_ids=collections.defaultdict(set)
for r in read(R/'_keys/ncbi_taxonomy_snapshot.csv'):
 if r['ncbi_rank']=='species':
  for n in json.loads(r['names_json']):name_ids[normal(n)].add(r['ncbi_taxid'])
for r in read(R/'_keys/species_reference.csv'):
 if r['ncbi_rank']=='species' and r['ncbi_taxid'] not in ('','NA') and r['temporal_grade'] in ('','NA'):
  name_ids[normal(r['accepted_name'])].add(r['ncbi_taxid'])
for r in read(P/'Zhu_taxonomy_resolution.csv'):name_ids[normal(r['printed_name'])].add(r['ncbi_taxid'])
byname=collections.defaultdict(list); byid=collections.defaultdict(list)
for r in l:
 byname[normal(r['SpeciesName'])].append(r)
 ids=name_ids.get(normal(r['SpeciesName']),set())
 if len(ids)==1:byid[next(iter(ids))].append(r)
out=[]
for r in z:
 cited='1' in [x.strip() for x in r['Supplementary_References_codes'].split(',')]
 hits=[];match='not_attributed_to_Lukas_by_Zhu'
 if cited:
  hits=byname.get(normal(r['SpeciesName']),[]);match='exact_printed_name'
  if not hits:
   ids=name_ids.get(normal(r['SpeciesName']),set())
   if len(ids)==1:hits=byid.get(next(iter(ids)),[]);match='verified_NCBI_identity'
  if len(hits)!=1:match='unresolved_or_ambiguous_name';hits=[]
 hit=hits[0] if hits else {}; ref=refs.get(hit.get('Reference_code'),{})
 code=hit.get('Reference_code','');citation=ref.get('citation','')
 comparison='not_compared'
 if hit:
  a=[r['Solitary'],r['Pair_living'],r['Group_living']];b=[hit['Solitary'],hit['SocialMonogamy'],hit['GroupLiving']]
  comparison='same_three_state_flags_but_pair_living_not_equivalent_to_monogamy' if a==b else 'different_state_flags_review_required'
 hint='unclassified_reference_requires_reading'
 if citation and re.search(r'book|mammals of|mammal.*world|walkers|walker.s|handbook|primates of',citation,re.I):hint='book_or_compilation_title_hint'
 if 'Murariu' in code:hint='order_default_reference_concern'
 out.append(dict(Zhu_species_printed=r['SpeciesName'],Zhu_social_organization=r['Social_organization'],Zhu_item=r['source_item'],Zhu_row_ID=r['source_row_ID'],Zhu_reference_codes=r['Supplementary_References_codes'],Zhu_cites_Lukas=cited,name_match=match,Lukas_species_printed=hit.get('SpeciesName',''),Lukas_solitary=hit.get('Solitary',''),Lukas_social_monogamy=hit.get('SocialMonogamy',''),Lukas_group_living=hit.get('GroupLiving',''),Lukas_reference_code=code,bibliography_ref_id=ref.get('ref_id',''),supporting_citation=citation,bibliography_match_note=ref.get('note',''),state_comparison=comparison,reference_type_hint=hint,primary_social_evidence_verified='No; bibliography linkage only',attribution_limit='Zhu codes cover multiple traits; explicit ref 1 establishes a cited source, not which social state it supports'))
write(P/'Zhu_Lukas_provenance_trace.csv',out)
queue=[]
for code in sorted({r['Lukas_reference_code'] for r in out if r['Lukas_reference_code']}):
 rr=[r for r in out if r['Lukas_reference_code']==code]
 queue.append(dict(reference_code=code,n_Zhu_rows=len(rr),citation=rr[0]['supporting_citation'],bibliography_match_note=rr[0]['bibliography_match_note'],reference_type_hint=rr[0]['reference_type_hint'],species='; '.join(r['Zhu_species_printed'] for r in rr),next_action='Read original source for social evidence; do not promote compilation to primary'))
queue.sort(key=lambda r:-r['n_Zhu_rows']);write(P/'Zhu_Lukas_supporting_source_queue.csv',queue)
print('explicit cites',sum(r['Zhu_cites_Lukas'] for r in out))
print('name matches',collections.Counter(r['name_match'] for r in out))
print('comparisons',collections.Counter(r['state_comparison'] for r in out))
print('top supporting refs',[(r['reference_code'],r['n_Zhu_rows']) for r in queue[:8]])
