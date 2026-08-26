#!/usr/bin/env python3
"""Offline mirror of __merging_cortical_areas/cortical_areas_compiled.R (no R in sandbox).
Reproduces readr::write_csv conventions. Run from repo root."""
import csv, io, math, os, sys, zipfile
from collections import OrderedDict
from xml.etree import ElementTree as ET

ROOT = sys.argv[1] if len(sys.argv) > 1 else "."
MDIR = os.path.join(ROOT, "__merging_cortical_areas")
TSV  = os.path.join(ROOT, "__Public", "comparative-data")
OUT  = sys.argv[2] if len(sys.argv) > 2 else MDIR

# ---- registry: Item name -> Item encoded (paper-scoped; enc() fail-loudly)
NS='{http://schemas.openxmlformats.org/spreadsheetml/2006/main}'
z=zipfile.ZipFile(os.path.join(ROOT,"__ReadMe.xlsx"))
ss=[''.join(t.text or '' for t in si.iter(NS+'t')) for si in ET.fromstring(z.read('xl/sharedStrings.xml')).iter(NS+'si')]
rows=[]
for row in ET.fromstring(z.read('xl/worksheets/sheet1.xml')).iter(NS+'row'):
    d={}
    for c in row.iter(NS+'c'):
        col=''.join(ch for ch in c.get('r') if ch.isalpha())
        v=c.find(NS+'v'); isx=c.find(NS+'is')
        if c.get('t')=='s' and v is not None: val=ss[int(v.text)]
        elif isx is not None: val=''.join(t.text or '' for t in isx.iter(NS+'t'))
        elif v is not None: val=v.text
        else: val=None
        d[col]=val
    rows.append(d)
hdr=rows[0]; COL={v:k for k,v in hdr.items() if v}
ENC={}
for r in rows[1:]:
    nm=(r.get(COL['Item name']) or '').strip()
    en=(r.get(COL['Item encoded']) or '').strip()
    if nm and nm not in ENC: ENC[nm]=en
def enc(nm):
    e=ENC.get(nm)
    assert e, "enc(%r): no Item encoded" % nm
    f=os.path.join(TSV, e+".tsv")
    assert os.path.exists(f), "enc(%r): TSV missing %s" % (nm,f)
    return e

def read_dsv(path, delim):
    with open(path, newline='', encoding='utf-8') as f:
        return list(csv.DictReader(f, delimiter=delim))
def num(x):
    if x is None or x=="" or x=="NA": return None
    try: return float(x)
    except ValueError: return None

# readr::write_csv formatting: shortest round-trip repr, no sci notation for typical ranges
def fmt(v):
    if v is None: return "NA"
    if isinstance(v,bool): return "TRUE" if v else "FALSE"
    if isinstance(v,float):
        if v==int(v) and abs(v)<1e15: return str(int(v))
        r=repr(v)
        if 'e' in r or 'E' in r: r="%.15g" % v
        return r
    return str(v)
def csvfield(s):
    if s is None: return "NA"
    if isinstance(s,(int,float,bool)): return fmt(s)
    if any(ch in s for ch in ',"\n'): return '"'+s.replace('"','""')+'"'
    return s
def write_csv(path, header, rows):
    with open(path,'w',encoding='utf-8',newline='') as f:
        f.write(','.join(csvfield(h) for h in header)+'\n')
        for r in rows: f.write(','.join(csvfield(x) for x in r)+'\n')

terms = read_dsv(os.path.join(MDIR,"standardized_term_cortical_areas.csv"), ',')

sp_alias={"Otolemur garnetti":"Otolemur garnettii","Aotus nancymae":"Aotus nancymaae",
          "Papio hamadryas anubis":"Papio cynocephalus anubis",
          "Girafa camelopardalis":"Giraffa camelopardalis",
          "Tragelaphus stripceros":"Tragelaphus strepsiceros",
          "Dasyprocta promnolopha":"Dasyprocta prymnolopha",
          "Dasyprocta primnolopha":"Dasyprocta prymnolopha",
          "Papio anubis":"Papio cynocephalus anubis",
          "Papio anubis cynocephalus":"Papio cynocephalus anubis"}
unify=lambda s: sp_alias.get(s,s)
regional_terms={"M1_Surface_Area.mm2","V1_Surface_Area.mm2","V2_Surface_Area.mm2"}

long=[]  # dicts: Species, Standardized_Term, value, source
# generic TSV sources
for nm in ["Changizi__2001_Figure3","Finlay_etal_2006_Table6.1","Young_etal_2013_Table1",
           "Changizi_Shimojo_2005_Table1",
           "Mota_Herculano-Houzel_2015_TableS1",
           "Mota_etal_2019_SupplementaryTableS1"]:
    d=read_dsv(os.path.join(TSV, enc(nm)+".tsv"), '\t')
    spcol=[t['Original_Term'] for t in terms if t['Reference']==nm and t['Standardized_Term']=='Species']
    spcol=spcol[0] if spcol and d and spcol[0] in d[0] else 'Species'
    for t in terms:
        if t['Reference']!=nm or t['Standardized_Term']=='Species': continue
        oc,st=t['Original_Term'],t['Standardized_Term']
        if not d or oc not in d[0]: continue
        for row in d:
            long.append(dict(Species=row[spcol],Standardized_Term=st,value=num(row[oc]),source=nm))
# Collins 2010 surface from paper file
for row in read_dsv(os.path.join(MDIR,"collins_2010_surface_from_paper.csv"), ','):
    long.append(dict(Species=row['Species'],Standardized_Term="CorticalSurface_Area.mm2",
                     value=num(row['CorticalSurface_Area.mm2']),source="Collins_etal_2010_DatasetS1"))
# Turner 2016 case-level dedupe; average hemispheres per (Species, case) -- dplyr group order: C locale on (Species, case)
ts=[r for r in read_dsv(os.path.join(MDIR,"turner_2016_surface.csv"), ',') if r['dedupe_status']=='include']
gr=OrderedDict()
for r in ts: gr.setdefault((r['Species'],r['case']),[]).append(num(r['CorticalSurface_Area.mm2']))
for k in sorted(gr):  # C-locale sort of keys
    long.append(dict(Species=k[0],Standardized_Term="CorticalSurface_Area.mm2",
                     value=sum(gr[k])/len(gr[k]),source="Turner_etal_2016_Table1"))

# Collins 2016: chimp flattened areas by structure (cm2->mm2); architectonic regions only
c16map={"cerebral cortex":"CorticalSurface_Area.mm2","V1":"V1_Surface_Area.mm2",
        "V2":"V2_Surface_Area.mm2","M1":"M1_Surface_Area.mm2"}
for row in read_dsv(os.path.join(TSV, enc("Collins_etal_2016_Table1")+".tsv"), '\t'):
    if row['method']=="flattened" and row['structure'] in c16map and num(row['area_cm2']) is not None:
        long.append(dict(Species=row['Species'],Standardized_Term=c16map[row['structure']],
                         value=num(row['area_cm2'])*100,source="Collins_etal_2016_Table1"))

# filter NA, unify, trait_class
long=[r for r in long if r['value'] is not None]
for r in long:
    r['Species']=unify(r['Species'])
    r['trait_class']='regional' if r['Standardized_Term'] in regional_terms else 'whole_cortex'
# supersede Changizi lineage
newer={r['Species'] for r in long if r['source']=="Changizi_Shimojo_2005_Table1" and r['Standardized_Term']=="n_cortical_areas"}
for r in long:
    r['status']='active'
    if (r['source']=="Changizi__2001_Figure3" and r['Standardized_Term']=="n_cortical_areas"
            and r['Species'] in newer):
        r['status']='superseded_by_Changizi_Shimojo_2005'
# Mota 2019 printed-thickness repair: where printed T deviates >5% from VG/AT, use VG/AT
for row in read_dsv(os.path.join(TSV, enc("Mota_etal_2019_SupplementaryTableS1")+".tsv"), '\t'):
    t,vg,at = num(row['T_mm']), num(row['VG_mm3']), num(row['AT_mm2'])
    vt,vw = num(row['VT_mm3']), num(row['VW_mm3'])
    if None in (t,vg,at): continue
    if vt is not None and vw is not None and abs(vg+vw-vt)/vt > 0.02:
        vg = vt - vw   # Cavia: printed VG fails additivity; recover as VT - VW
    tdef = vg/at
    if abs(t-tdef)/tdef > 0.05:
        sp = unify(row['Species'])
        for r in long:
            if (r['source']=="Mota_etal_2019_SupplementaryTableS1"
                    and r['Standardized_Term']=="CorticalThickness.mm" and r['Species']==sp):
                r['value']=tdef

# supersede: Kaas-lab chimp — Young keeps M1 (same specimen KAAS-PAN-11_38)
y_m1={r['Species'] for r in long if r['source']=="Young_etal_2013_Table1" and r['Standardized_Term']=="M1_Surface_Area.mm2"}
for r in long:
    if (r['source']=="Collins_etal_2016_Table1" and r['Standardized_Term']=="M1_Surface_Area.mm2"
            and r['Species'] in y_m1):
        r['status']='superseded_by_Young_etal_2013'
# supersede: Mota lineage — 2019 wins over 2015 own columns per species x term
for tt in ["CorticalSurface_Area.mm2","CorticalThickness.mm"]:
    m19={r['Species'] for r in long if r['source']=="Mota_etal_2019_SupplementaryTableS1" and r['Standardized_Term']==tt}
    for r in long:
        if (r['source']=="Mota_Herculano-Houzel_2015_TableS1" and r['Standardized_Term']==tt
                and r['Species'] in m19):
            r['status']='superseded_by_Mota_etal_2019'
write_csv(os.path.join(OUT,"cortical_areas_long.csv"),
          ["Species","Standardized_Term","value","source","trait_class","status"],
          [[r['Species'],r['Standardized_Term'],r['value'],r['source'],r['trait_class'],r['status']] for r in long])

# wide: group_by(Species, Standardized_Term) -> C-locale sorted groups
act=[r for r in long if r['status']=='active']
groups=OrderedDict()
for r in act: groups.setdefault((r['Species'],r['Standardized_Term']),[]).append(r)
summ=[]
for k in sorted(groups):
    g=groups[k]; vals=[r['value'] for r in g]; srcs=sorted({r['source'] for r in g})
    mean=sum(vals)/len(vals); n=len(srcs)
    if n>1 and len(vals)>1:
        m=mean; sd=math.sqrt(sum((v-m)**2 for v in vals)/(len(vals)-1))
        cf = (sd/m)>0.15
    else: cf=False if n<=1 else None
    if cf is None: cf=False
    summ.append(dict(Species=k[0],term=k[1],mean=mean,n=n,srcs="; ".join(srcs),
                     vmin=min(vals),vmax=max(vals),cf=cf))
# pivot wider: id = Species (order of first appearance in summ), columns = order of first appearance of term
col_order=[]
for s in summ:
    if s['term'] not in col_order: col_order.append(s['term'])
sp_order=[]
for s in summ:
    if s['Species'] not in sp_order: sp_order.append(s['Species'])
cell={}
for s in summ: cell[(s['Species'],s['term'])]=s['mean']
write_csv(os.path.join(OUT,"cortical_areas_wide.csv"),
          ["Species"]+col_order,
          [[sp]+[cell.get((sp,t)) for t in col_order] for sp in sp_order])
print("long rows:",len(long),"wide species:",len(sp_order))
