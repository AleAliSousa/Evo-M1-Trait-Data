"""Apply reviewed NCBI identity mappings; preserve existing project anchors and sources."""
import csv,io,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]; P=ROOT/'_checks/social_variables'; K=ROOT/'_keys'
def read(p):
 with p.open(encoding='utf-8-sig',newline='') as f:
  r=csv.DictReader(f);return r.fieldnames,list(r)
def write(p,fields,rows):
 old=p.read_bytes() if p.exists() else b''
 eol='\r\n' if b'\r\n' in old else '\n'
 out=io.StringIO(newline='');w=csv.DictWriter(out,fields,lineterminator=eol);w.writeheader();w.writerows(rows)
 p.write_bytes(out.getvalue().encode('utf-8-sig' if old.startswith(b'\xef\xbb\xbf') else 'utf-8'))
hf,hub=read(K/'species_reference.csv');sf,snap=read(K/'ncbi_taxonomy_snapshot.csv')
_,rec=read(P/'population_taxonomy_evidence/verified_records.csv'); records={r['ncbi_taxid']:r for r in rec}
_,audit=read(P/'population_taxonomy_resolution.csv'); audit=[r for r in audit if r['status']=='verified']
anchors={}
for r in hub:
 if r['ncbi_rank']=='species' and r['temporal_grade'] in ('','NA'):
  anchors.setdefault(r['ncbi_taxid'],[]).append(r['accepted_name'])
byname={r['accepted_name']:r for r in hub};sfound={r['ncbi_taxid'] for r in snap}
kf,key=read(K/'General/species_key.csv')
if 'ncbi_taxid' not in kf:kf.append('ncbi_taxid')
for r in key:r.setdefault('ncbi_taxid','')
af,aliases=read(K/'species_display_aliases.csv');ab={r['variant']:r['canonical'] for r in aliases}
tf,tax=read(K/'species_taxonomy.csv');tb={r['Species']:r for r in tax}
for r in audit:
 t=records[r['ncbi_taxid']]; possible=anchors.get(r['ncbi_taxid'],[])
 assert len(possible)<=1,(r,possible)
 anchor=possible[0] if possible else t['ncbi_name']
 r['accepted_name']=anchor
 if anchor not in byname:
  h=dict.fromkeys(hf,'NA');h.update(accepted_name=anchor,ncbi_taxid=t['ncbi_taxid'],ncbi_name=t['ncbi_name'],ncbi_rank='species',ncbi_mapping_basis='NCBI_name_or_synonym',taxon_name=anchor,rank='species',taxon_type='extant',needs_taxonomy_review='FALSE',Order_resolved=t['order'],Family_resolved=t['family'],taxonomy_source='NCBI verified 2026-10-23; population social-data identity reconciliation')
  for c in ['in_Stephan','in_HerculanoHouzel','in_Allman']:h[c]='FALSE'
  hub.append(h);byname[anchor]=h;anchors[t['ncbi_taxid']]=[anchor]
 if t['ncbi_taxid'] not in sfound:snap.append(t);sfound.add(t['ncbi_taxid'])
 existing=next((x for x in key if x['variant_name']==r['printed_name'] and x['source_publication']==r['source_publication']),None)
 k=dict(variant_name=r['printed_name'],accepted_name=anchor,source_publication=r['source_publication'],collection='General',basis='synonym:NCBI',ncbi_taxid=t['ncbi_taxid'],note='Verified 2026-10-23. '+r['evidence_url']+'; '+'Exact NCBI name or synonym; source scope retained'+'; NCBI '+t['ncbi_taxid']+'. Identity mapping only; original row and category retained.')
 if existing: existing.update(k)
 else:key.append(k)
 # Align the old source spelling in compiled display tables, backed by this same taxid.
 if r['printed_name']!=anchor:
  if r['printed_name'] in ab:
   assert ab[r['printed_name']]==anchor or ab[r['printed_name']]==ab.get(anchor), (r,ab[r['printed_name']])
  else:
   aliases.append(dict(variant=r['printed_name'],canonical=ab.get(anchor,anchor),note='NCBI identity verified 2026-10-23; '+r['evidence_url']+'; retain source context and do not infer subspecies.'));ab[r['printed_name']]=ab.get(anchor,anchor)
 display=ab.get(anchor,anchor)
 if display not in tb:
  tr=dict(Species=display,Order=t['order'],Family=t['family']);tax.append(tr);tb[display]=tr
 else:
  for c,f in [('Order','order'),('Family','family')]:
   if not tb[display][c]:tb[display][c]=t[f]
write(K/'species_reference.csv',hf,hub)
write(K/'ncbi_taxonomy_snapshot.csv',sf,snap)
write(K/'General/species_key.csv',kf,key)
write(K/'species_display_aliases.csv',af,aliases)
write(K/'species_taxonomy.csv',tf,tax)
write(P/'population_taxonomy_applied.csv',list(audit[0]),audit)
print('Applied',len(audit),'verified source mappings;',len(hub),'hub anchors')
