"""Cache exact-name NCBI taxonomy searches and records; no fuzzy matching."""
import csv,json,time,urllib.request,urllib.parse,xml.etree.ElementTree as ET
from pathlib import Path
P=Path(__file__).resolve().parent; E=P/'taxonomy_evidence';E.mkdir(exist_ok=True)
if (E/'query_names.json').exists():
 names=json.loads((E/'query_names.json').read_text())
else:
 rows=list(csv.DictReader((P/'Zhu_provenance_audit.csv').open()))
 names=sorted(r['species_printed'] for r in rows if r['species_basis']=='unresolved')
assert len(names)==563
(E/'query_names.json').write_text(json.dumps(names,indent=2)+'\n')
def fetch(endpoint,params,path):
 if path.exists(): return path.read_bytes()
 url='https://eutils.ncbi.nlm.nih.gov/entrez/eutils/'+endpoint+'?'+urllib.parse.urlencode(params)
 for attempt in range(4):
  try:
   time.sleep(.4);data=urllib.request.urlopen(url,timeout=90).read();path.write_bytes(data);return data
  except Exception:
   if attempt==3: raise
   time.sleep(2**attempt)
ids=set()
for i in range(0,len(names),40):
 terms=' OR '.join('"'+n+'"[All Names]' for n in names[i:i+40])
 d=json.loads(fetch('esearch.fcgi',dict(db='taxonomy',term=terms,retmode='json',retmax=1000),E/f'search_{i//40:02}.json'))
 assert int(d['esearchresult']['count'])<=1000
 ids.update(d['esearchresult']['idlist'])
 print('searched',min(i+40,len(names)),flush=True)
manual = {r['printed_name']: r for r in csv.DictReader((E/'manual_name_crosswalk.csv').open())}
terms=' OR '.join('"'+r['lookup_name']+'"[All Names]' for r in manual.values())
d=json.loads(fetch('esearch.fcgi',dict(db='taxonomy',term=terms,retmode='json',retmax=100),E/'manual_search.json'))
# Keep the original bulk fetch batch membership stable on subsequent runs.
manual_ids = d['esearchresult']['idlist']
fetch('efetch.fcgi',dict(db='taxonomy',id=','.join(manual_ids),retmode='xml'),E/'records_manual.xml')
ids=sorted(ids,key=int)
for i in range(0,len(ids),100):
 fetch('efetch.fcgi',dict(db='taxonomy',id=','.join(ids[i:i+100]),retmode='xml'),E/f'records_{i//100:02}.xml')
 print('fetched',min(i+100,len(ids)),flush=True)
records={}
for f in sorted(E.glob('records_*.xml')):
 for t in ET.fromstring(f.read_bytes()).findall('Taxon'):
  tid=t.findtext('TaxId');nameset={t.findtext('ScientificName')}
  for n in t.findall('OtherNames/*'):
   if n.tag in ('Synonym','EquivalentName','ScientificName','GenbankSynonym','Includes','Misspelling') and n.text:nameset.add(n.text)
   if n.tag=='Name' and n.findtext('ClassCDE') in ('synonym','equivalent name','misspelling'):
    nameset.add(n.findtext('DispName'))
  lineage={x.findtext('Rank'):x.findtext('ScientificName') for x in t.findall('LineageEx/Taxon')}
  records[tid]=dict(queried_taxid=tid,ncbi_taxid=tid,ncbi_name=t.findtext('ScientificName'),ncbi_rank=t.findtext('Rank'),names_json=json.dumps(sorted(n for n in nameset if n)),order=lineage.get('order',''),family=lineage.get('family',''),checked_on='2026-10-23',source_url='https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id='+tid)
with (E/'verified_records.csv').open('w',newline='') as f:
 w=csv.DictWriter(f,fieldnames=list(next(iter(records.values()))));w.writeheader();w.writerows(records.values())
lookup={}
for tid,r in records.items():
 for n in json.loads(r['names_json']):lookup.setdefault(n.casefold(),[]).append(tid)
out=[]
for n in names:
 lookup_name=manual[n]['lookup_name'] if n in manual else n
 candidates=[records[t] for t in lookup.get(lookup_name.casefold(),[]) if records[t]['ncbi_rank']=='species']
 unique=len(candidates)==1
 out.append(dict(printed_name=n,status=('verified_MDD_crosswalk_to_NCBI' if n in manual else 'verified_exact_name_or_synonym') if unique else 'needs_review',ncbi_taxid=candidates[0]['ncbi_taxid'] if unique else '',ncbi_name=candidates[0]['ncbi_name'] if unique else '',candidate_ids=';'.join(lookup.get(lookup_name.casefold(),[])),evidence_url=manual[n]['evidence_url'] if n in manual else (candidates[0]['source_url'] if unique else ''),note=manual[n]['note'] if n in manual else 'Exact name or synonym in NCBI; identity only, not a population or subspecies reassignment'))
with (P/'Zhu_taxonomy_resolution.csv').open('w',newline='') as f:
 w=csv.DictWriter(f,fieldnames=list(out[0]));w.writeheader();w.writerows(out)
print('verified',sum(r['status'].startswith('verified') for r in out),'review',[r for r in out if r['status']=='needs_review'])
