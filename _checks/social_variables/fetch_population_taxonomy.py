import csv,json,time,urllib.request,urllib.parse,xml.etree.ElementTree as ET
from pathlib import Path
P=Path(__file__).resolve().parent;E=P/'population_taxonomy_evidence';E.mkdir(exist_ok=True)
# Freeze the resolver's initial unresolved list so subsequent runs do not change inputs.
if not (E/'queries.csv').exists():
 rows=[]
 for folder in ['Jaeggi_etal_2020','Qiu_etal_2022']:
  for r in csv.DictReader(open('/tmp/social-census/'+folder+'_taxonomy.csv')):
   if r['unresolved']=='TRUE':rows.append(dict(source_publication=folder,printed_name=r['d$Species']))
 with (E/'queries.csv').open('w',newline='') as f:
  w=csv.DictWriter(f,list(rows[0]));w.writeheader();w.writerows(rows)
rows=list(csv.DictReader((E/'queries.csv').open()));names=sorted({x['printed_name'] for x in rows})
def fetch(endpoint,params,path):
 if path.exists():return path.read_bytes()
 time.sleep(.4)
 data=urllib.request.urlopen('https://eutils.ncbi.nlm.nih.gov/entrez/eutils/'+endpoint+'?'+urllib.parse.urlencode(params),timeout=90).read();path.write_bytes(data);return data
j=json.loads(fetch('esearch.fcgi',dict(db='taxonomy',term=' OR '.join('"'+n+'"[All Names]' for n in names),retmode='json',retmax=1000),E/'search.json'))
x=ET.fromstring(fetch('efetch.fcgi',dict(db='taxonomy',id=','.join(j['esearchresult']['idlist']),retmode='xml'),E/'records.xml'))
records=[]
for t in x.findall('Taxon'):
 tid=t.findtext('TaxId');ns={t.findtext('ScientificName')}
 for n in t.findall('OtherNames/*'):
  if n.tag in ('Synonym','EquivalentName','ScientificName','GenbankSynonym','Misspelling') and n.text:ns.add(n.text)
  if n.tag=='Name' and n.findtext('ClassCDE') in ('synonym','equivalent name','misspelling'):ns.add(n.findtext('DispName'))
 lin={n.findtext('Rank'):n.findtext('ScientificName') for n in t.findall('LineageEx/Taxon')}
 records.append(dict(queried_taxid=tid,ncbi_taxid=tid,ncbi_name=t.findtext('ScientificName'),ncbi_rank=t.findtext('Rank'),names_json=json.dumps(sorted(ns)),order=lin.get('order',''),family=lin.get('family',''),checked_on='2026-10-23',source_url='https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id='+tid))
with (E/'verified_records.csv').open('w',newline='') as f:
 w=csv.DictWriter(f,list(records[0]));w.writeheader();w.writerows(records)
for r in rows:
 hits=[t for t in records if r['printed_name'].casefold() in [n.casefold() for n in json.loads(t['names_json'])] and t['ncbi_rank']=='species']
 r.update(status='verified' if len(hits)==1 else 'review',ncbi_taxid=hits[0]['ncbi_taxid'] if len(hits)==1 else '',ncbi_name=hits[0]['ncbi_name'] if len(hits)==1 else '',evidence_url=hits[0]['source_url'] if len(hits)==1 else '')
with (P/'population_taxonomy_resolution.csv').open('w',newline='') as f:
 w=csv.DictWriter(f,list(rows[0]));w.writeheader();w.writerows(rows)
print('Verified',sum(r['status']=='verified' for r in rows),'review',[r['printed_name'] for r in rows if r['status']=='review'])
