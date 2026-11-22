"""Read-only source-to-item QA; writes only this paper's QA report.
Place in <Paper>/internal_checks and run with Python 3 (openpyxl required).
No source or analysis values are changed.
"""
from pathlib import Path
import csv,math,hashlib,urllib.parse,warnings
import openpyxl
warnings.filterwarnings('ignore',message='Unknown extension is not supported')
paper=Path(__file__).resolve().parents[1]
root=paper.parent
reports=[]
def number(v):
    try:return float(v)
    except (ValueError,TypeError):return float('nan')
def same(a,b):
    a,b=number(a),number(b)
    return (math.isnan(a) and math.isnan(b)) or math.isclose(a,b,rel_tol=1e-12,abs_tol=1e-14)
for meta in csv.DictReader((paper/'reference_tables/download_provenance.csv').open()):
    item=meta['item'];snap=paper/meta['snapshot'];out=list(csv.DictReader((paper/(item+'.csv')).open()))
    assert hashlib.sha256(snap.read_bytes()).hexdigest()==meta['sha256']
    checked=0
    if snap.suffix=='.csv':
        source=list(csv.DictReader(snap.open()))
        assert len(out)==len(source)==68
        for a,b in zip(out,source):
            b={k.strip():v for k,v in b.items()}
            assert a['structure_source']==b['Structure']
            for dest,key in [('effect','d_icv'),('se','se_icv'),('ci_low','low_ci_icv'),('ci_high','up_ci_icv'),('n_cases','n_patients'),('n_reference','n_controls'),('p','pobs'),('p_fdr','fdr_p')]:
                assert same(a[dest],b[key]),(item,a['structure_source'],dest,a[dest],b[key]);checked+=1
            # malformed source p is retained as text; no silent repaired number
            if b['fdr_p'] and math.isnan(number(b['fdr_p'])):assert a['p_fdr_source']==b['fdr_p']
    else:
        wb=openpyxl.load_workbook(snap,read_only=True,data_only=True)
        sheet=wb[out[0]['source_sheet']];matrix=list(sheet.values)
        dosage='dosage_beta'==out[0]['effect_type'];regional='Table S' in out[0]['source_sheet']
        seen=[]
        for a in out:
            i=int(a['source_row'])-1;j=int(a['source_column'])-1;b=matrix[i]
            assert a['region']==b[j]
            effect=b[j+(6 if dosage else 4)]
            half=number(str(b[j+(7 if dosage else 5)]).replace('[±','').replace(']',''))
            for dest,v in [('effect',effect),('ci_low',effect-half),('ci_high',effect+half),('p',b[j+(8 if dosage else 6 if regional else 7)]),('t_source',b[j+(4 if dosage else 3)])]:
                assert same(a[dest],v),(item,i+1,j+1,dest,a[dest],v);checked+=1
            ncols=['n_deletion','n_noncarrier','n_duplication'] if dosage else ['n_group1_source','n_group2_source']
            for k,col in enumerate(ncols,1):assert same(a[col],b[j+k]);checked+=1
            assert same(a['n'],sum(b[j+k] for k in range(1,len(ncols)+1)))
            seen.append((i,j))
        # All numeric sample-count rows in each source panel are extracted once.
        expected=[]
        offsets=[0,11] if dosage and regional else [0,9] if regional else [0]
        for j in offsets:
            for i,b in enumerate(matrix):
                if b[j] is not None and isinstance(b[j+1],(int,float)):expected.append((i,j))
        assert sorted(seen)==sorted(expected),(item,len(seen),len(expected))
        wb.close()
    doi=out[0]['doi'];locus=item[len(paper.name)+1:]
    tsv=root/'__Public/comparative-data'/(urllib.parse.quote(doi,safe='')+'_'+locus+'.tsv')
    public=list(csv.DictReader(tsv.open(),delimiter='\t'))
    assert public==out
    reports.append(dict(item=item,n=len(out),numeric_cells_checked=checked,mismatches=0,source_hash_verified=True,public_tsv_matches_csv=True,
                        note='Source-cell numeric and structure comparison; complete source-panel coverage; no statistical test. Master registry insertion pending.'))
with (paper/'reference_tables/ingestion_validation.csv').open('w') as h:
    w=csv.DictWriter(h,fieldnames=reports[0].keys());w.writeheader();w.writerows(reports)
print(paper.name,len(reports),'items;',sum(x['numeric_cells_checked'] for x in reports),'source numeric cells checked; zero mismatches')
