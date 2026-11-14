"""Post-item measurement stage. Python stdlib + openpyxl; no source-table edits."""
from pathlib import Path
import argparse,collections,csv,hashlib,json,math,re,sqlite3,shutil,tempfile,os
import openpyxl
csv.field_size_limit(10000000)
ROOT=Path(__file__).resolve().parents[1]
HERE=Path(__file__).resolve().parent
EMPTY={'','NA','N/A','NaN','nan','n.a.','—','–','-'}
INFO={'info','note','provenance','method','metadata','quality','flagged'}
def load(path):
    if not path.exists():return []
    with path.open(encoding='utf-8-sig',newline='') as f:return list(csv.DictReader(f))
def digest(text):return hashlib.sha256(text.encode()).hexdigest()
def number(text):
    try:
        value=float(text)
        return value if math.isfinite(value) else None
    except (ValueError,TypeError):return None
def write(path,fields,rows):
    with path.open('w',newline='') as f:
        w=csv.DictWriter(f,fieldnames=fields,extrasaction='ignore');w.writeheader();w.writerows(rows)
def role_of(variable_role,item_role):
    roles={x for x in (variable_role,item_role) if x in {'primary','secondary'}}
    if len(roles)==1:return next(iter(roles))
    return 'review'
def inferred_unit(code):
    # Only explicit terminal unit labels. No biological inference from trait names.
    m=re.search(r'(?:[._ ]|\()(?P<u>mm3|cm3|mg|kg|ml|g|W)(?:\))?$',code)
    return m.group('u') if m else ''
def standardize(value,unit,measure):
    if value is None:return None,''
    if measure=='mass_specific_whole_body_metabolic_rate' and unit=='W/kg':return value/1000,'W/g'
    if measure=='brain_mass' and unit in {'mg','g','kg'}:return value*{'mg':1,'g':1000,'kg':1e6}[unit],'mg'
    if measure=='body_mass' and unit in {'mg','g','kg'}:return value*{'mg':.001,'g':1,'kg':1000}[unit],'g'
    if measure in {'brain_tissue_volume','endocranial_volume','volume'} and unit in {'mm3','cm3','ml'}:return value*{'mm3':1,'cm3':1000,'ml':1000}[unit],'mm3'
    if measure=='whole_body_metabolic_rate' and unit=='W':return value,'W'
    return None,''
def brain_basis(basis,quantity):
    if basis in {'mass_fresh','mass_fixed','mass_fresh_or_fixed_mixed'}:return 'direct_weight'
    if quantity=='endocranial_volume' or basis=='endocranial_volume':return 'endocranial_volume'
    if basis in {'mass_estimated_from_brain_volume','mass_from_brain_volume'}:return 'estimated_from_brain_volume'
    if basis in {'mass_estimated_from_endocranial_volume','mass_from_endocranial_volume'}:return 'estimated_from_endocranial_volume'
    if basis=='mass_estimated_from_volume':return 'estimated_from_volume'
    return 'unresolved'
def build(root=ROOT,out=HERE,resume=False):
    out.mkdir(exist_ok=True,parents=True)
    for d in ['primary','secondary','review']: (out/d).mkdir(exist_ok=True)
    registry=openpyxl.load_workbook(root/'__ReadMe.xlsx',read_only=True,data_only=True)
    rows=list(registry['Sheet1'].values);headers=rows[0];by_stem=collections.defaultdict(list)
    for row in rows[1:]:
        d=dict(zip(headers,row));stem=d.get('Item encoded')
        if stem:by_stem[str(stem)].append(d)
    catalog=collections.defaultdict(list)
    for d in load(root/'_keys/variable_catalog.csv'):catalog[(d['item'],d['Code'])].append(d)
    basis={(d['paper'],d['column']):d for d in load(root/'_keys/brain_size_basis.csv')}
    overrides={(d['item'],d['column']):d for d in load(HERE/'config/column_rules.csv')}
    role_rules={d['item']:d for d in load(HERE/'config/item_roles.csv')}
    row_basis=collections.defaultdict(list)
    for r in load(root/'__merging_brain_mass/brain_mass_row_basis.csv'):
        for locator in r.get('source_records','').split('; '):
            m=re.search(r'([^/]+[.]tsv):(\d+)$',locator)
            if m:row_basis[(m.group(1),int(m.group(2)),r.get('column',''))].append(r)
    db=sqlite3.connect(out/'measurements.sqlite');db.execute('PRAGMA temp_store=MEMORY');db.executescript('''
    CREATE TABLE IF NOT EXISTS source_issues(source_file TEXT,row_number INTEGER,issue TEXT,raw_record_json TEXT);
    CREATE TABLE IF NOT EXISTS points(number INTEGER PRIMARY KEY AUTOINCREMENT,point_id TEXT UNIQUE,active INTEGER,
      source_file TEXT,item TEXT,row_id TEXT,row_number INTEGER,column_name TEXT,column_number INTEGER,
      raw_value TEXT,numeric_value REAL,source_unit TEXT,standard_value REAL,standard_unit TEXT,
      measure TEXT,structure TEXT,statistic TEXT,data_role TEXT,measurement_basis TEXT,species TEXT,
      method_raw TEXT,basis_evidence TEXT,definition TEXT,definition_file TEXT,role_evidence TEXT,
      source_reference_id TEXT,primary_reference_id TEXT,derivation_role TEXT,review_reason TEXT);
    CREATE TABLE IF NOT EXISTS item_context(item TEXT PRIMARY KEY,registry_json TEXT,definitions_json TEXT,references_json TEXT);
    CREATE TABLE IF NOT EXISTS report_relations(point_id TEXT,related_point_id TEXT,relation TEXT,evidence TEXT);
    CREATE TABLE IF NOT EXISTS source_rows(row_id TEXT PRIMARY KEY,item TEXT,source_file TEXT,row_number INTEGER,context_json TEXT);
    CREATE TABLE IF NOT EXISTS reference_links(point_id TEXT,source_reference_id TEXT,reference_raw TEXT,citation TEXT,reference_level TEXT,reference_role TEXT,evidence TEXT);
    CREATE TABLE IF NOT EXISTS files(source_file TEXT PRIMARY KEY,item TEXT,sha256 TEXT,status TEXT,n_rows INTEGER,n_points INTEGER,n_review INTEGER,note TEXT);
    ''')
    db.execute('CREATE INDEX IF NOT EXISTS point_file ON points(source_file)')
    cached={r[0]:r for r in db.execute('SELECT * FROM files').fetchall()} if resume else {}
    db.execute('UPDATE points SET active=0');db.execute('DELETE FROM files');db.execute('DELETE FROM item_context');db.execute('DELETE FROM report_relations')
    if not resume:
        db.execute('DELETE FROM reference_links');db.execute('DELETE FROM source_rows');db.execute('DELETE FROM source_issues')
    queue=[];counts=collections.Counter()
    for file in sorted((root/'__Public/comparative-data').glob('*.tsv')):
        regs=by_stem[file.stem];reg=regs[0] if len(regs)==1 else {}
        item=reg.get('Item name') or file.stem;paper=reg.get('Publication name') or ''
        itemrole=str(reg.get('Data role (primary/secondary/both)') or '').lower()
        if item in role_rules:itemrole=role_rules[item]['role']
        definitions={}
        definition_file=root/str(paper)/'reference_tables'/f'{item}_definitions.csv'
        for d in load(definition_file):
            if d.get('Code'):definitions.setdefault(d['Code'],[]).append(d)
        references=load(definition_file.with_name(f'{item}_references.csv'))
        db.execute('INSERT OR REPLACE INTO item_context VALUES (?,?,?,?)',(item,json.dumps(reg,default=str,ensure_ascii=False),json.dumps(definitions,ensure_ascii=False),json.dumps(references,ensure_ascii=False)))
        key_columns=collections.defaultdict(list)
        for r in references:key_columns[r.get('cited_in_column','')].append(r)
        filehash=hashlib.sha256(file.read_bytes()).hexdigest()
        if resume and file.name in cached and cached[file.name][2]==filehash:
            db.execute('UPDATE points SET active=1 WHERE source_file=?',(file.name,))
            for (bp,bc),br in basis.items():
                if bp==paper and br.get('role') in {'primary','secondary'}:
                    db.execute("UPDATE points SET data_role='review',review_reason=review_reason || '; basis-key source role conflicts' WHERE source_file=? AND column_name=? AND data_role<>? AND data_role<>'review'",(file.name,bc,br['role']))
            db.execute('INSERT INTO files VALUES (?,?,?,?,?,?,?,?)',cached[file.name]);db.commit();continue
        db.execute('DELETE FROM reference_links WHERE point_id IN (SELECT point_id FROM points WHERE source_file=?)',(file.name,))
        db.execute('DELETE FROM source_issues WHERE source_file=?',(file.name,))
        occurrence=collections.Counter();nrows=npoints=nreview=0;column_counts=collections.Counter();column_reasons={};ragged=0
        with file.open(encoding='utf-8-sig',newline='') as f:
            reader=csv.reader(f,delimiter='\t');cols=next(reader,[])
            if not cols or len(cols)!=len(set(cols)):
                db.execute('INSERT INTO files VALUES (?,?,?,?,?,?,?,?)',(file.name,item,digest(file.read_text()),'blocked',0,0,0,'Empty or duplicate column headers; manual adapter required'));continue
            for line,values in enumerate(reader,2):
                if len(values)!=len(cols):
                    ragged+=1
                    db.execute('INSERT INTO source_issues VALUES (?,?,?,?)',(file.name,line,'ragged row; adapter required',json.dumps({'columns':cols,'values':values},ensure_ascii=False)))
                    continue
                nrows+=1;row=dict(zip(cols,values));rowhash=digest(json.dumps(row,sort_keys=True,ensure_ascii=False));occurrence[rowhash]+=1
                rowid='ROW-'+digest(item+'|'+rowhash+'|'+str(occurrence[rowhash]))[:24]
                db.execute('INSERT OR REPLACE INTO source_rows VALUES (?,?,?,?,?)',(rowid,item,file.name,line,json.dumps(row,ensure_ascii=False)))
                species=next((row[k] for k in ['Species_Herberstein2022','Species','species','Species_Name','species_as_published','Species_accepted'] if row.get(k)), '')
                for ci,(col,raw) in enumerate(zip(cols,values),1):
                    if raw in EMPTY:continue
                    rule=overrides.get((item,col),{})
                    defs=definitions.get(col,[]);cats=catalog[(item,col)]
                    d=defs[0] if len(defs)==1 else {};c=cats[0] if len(cats)==1 else {}
                    vr=str(d.get('role') or c.get('role') or '').lower();numeric=number(raw)
                    # Explicit aliases/context never become independent observations.
                    if rule.get('action')=='context' or (vr in INFO and rule.get('action')!='measure'):continue
                    if numeric is None and not d and not c and not rule:continue
                    if numeric is None and vr in {'category','binary'}:continue
                    point='DP-'+digest(rowid+'|'+col)[:24]
                    measure=rule.get('measure') or c.get('measure_class') or d.get('Measure') or 'unclassified'
                    if measure in {'','NA'}:measure='unclassified'
                    unit=rule.get('unit') or (row.get(rule.get('unit_column','')) if rule.get('unit_column') else '') or inferred_unit(col)
                    b=basis.get((paper,col),{});measurement_basis=brain_basis(b.get('basis',''),b.get('quantity',''))
                    evidence=b.get('basis_statement_source') or b.get('definition_source') or ''
                    rb=row_basis[(file.name,line,col)]
                    if len(rb)==1:
                        r=rb[0];val_g=standardize(numeric,unit,'brain_mass')[0]
                        if r.get('Species')==species and val_g is not None and number(r.get('Value_g')) is not None and math.isclose(val_g/1000,float(r['Value_g']),rel_tol=1e-8):
                            measure='brain_mass';measurement_basis=brain_basis(r.get('basis',''),r.get('original_quantity',''))
                            evidence=r.get('evidence','')+'; __merging_brain_mass/brain_mass_row_basis.csv:'+r.get('resolution_id','')
                    method=row.get(rule.get('method_column',''),'')
                    if item=='Herberstein_etal_2022_Observations' and col=='brain size':
                        unit=row.get('brain size - units','');originalunit=row.get('original brain size - units','')
                        if method=='brain weighed' and originalunit in {'g','mg','kg','ug','cg'}:measurement_basis='direct_weight'
                        elif method=='skull filling':measurement_basis='estimated_from_endocranial_volume'
                        elif originalunit in {'ml','mm3','um3','x6.4e-5 mm3','x1e6 um3'}:measurement_basis='estimated_from_volume'
                        else:measurement_basis='unresolved'
                        evidence='source row: brain size - method and original brain size - units; paper Methods density 1.036 g/ml'
                    if item=='Herberstein_etal_2022_Observations' and col=='Brain_Volume_original.mm3':
                        measurement_basis='endocranial_volume' if row.get('brain size - method')=='skull filling' else 'brain_tissue_volume' if row.get('brain size - method') in {'histological reconstruction','immunostaining and microscopy','micro-CT','immunostaining and histological recontruction'} else 'unresolved'
                        measure='endocranial_volume' if measurement_basis=='endocranial_volume' else 'brain_tissue_volume' if measurement_basis=='brain_tissue_volume' else 'volume'
                    if b.get('quantity')=='endocranial_volume':measure='endocranial_volume'
                    if b.get('quantity')=='mass':measure='brain_mass'
                    if b.get('poolable_group')=='mass_measured_excl_ob':measure='brain_mass_excluding_olfactory_bulbs'
                    if b.get('poolable_group')=='not_a_size':measure='not_a_brain_size'
                    dr=role_of(vr,itemrole)
                    if b.get('role') in {'primary','secondary'} and dr!=b['role']:dr='review'
                    if item in role_rules and role_rules[item]['role']=='secondary':dr='secondary'
                    val,stdunit=standardize(numeric,unit,measure)
                    reasons=[]
                    if dr=='review':reasons.append('source role unresolved or conflicting')
                    if measure=='unclassified':reasons.append('measurement type unresolved')
                    if numeric is None:reasons.append('non-scalar source value retained')
                    if val is None:reasons.append('unit conversion requires mapping')
                    if measure=='brain_mass' and measurement_basis=='unresolved':reasons.append('brain mass method unresolved')
                    if not reg:reasons.append('registry match missing or ambiguous')
                    reason='; '.join(reasons)
                    links=[]
                    # Only exact single reference keys; compound citations remain unresolved.
                    for kc,refs in key_columns.items():
                        cell=row.get(kc,'')
                        for ref in refs:
                            if cell and cell==ref.get('ref_key'):
                                rid='REF-'+digest(ref.get('citation') or cell)[:24]
                                links.append((point,rid,cell,ref.get('citation',''),'unresolved','reported_source',str(definition_file.with_name(f'{item}_references.csv').relative_to(root))))
                    # Already-present citation fields retain the reported work without asserting primary status.
                    if not links and row.get('fullReference'):
                        rid='REF-'+digest(row['fullReference'])[:24];links.append((point,rid,row.get('inTextReference',''),row['fullReference'],'unresolved','reported_source','source row fullReference'))
                    db.executemany('INSERT INTO reference_links VALUES (?,?,?,?,?,?,?)',links)
                    source_ref=links[0][1] if len(links)==1 else ''
                    role_evidence='; '.join(filter(None,[str(definition_file.relative_to(root)) if d else '', '_keys/variable_catalog.csv' if c else '', '__ReadMe.xlsx by Item name',role_rules.get(item,{}).get('evidence','')]))
                    record=(point,1,file.name,item,rowid,line,col,ci,raw,numeric,unit,val,stdunit,measure,d.get('Structure') or c.get('canonical_structure',''),rule.get('statistic') or d.get('Stat') or c.get('Stat',''),dr,measurement_basis,species,method,evidence,d.get('Definition') or c.get('Definition',''),str(definition_file.relative_to(root)) if d else '',role_evidence,source_ref,'','reported_value',reason)
                    fields='point_id,active,source_file,item,row_id,row_number,column_name,column_number,raw_value,numeric_value,source_unit,standard_value,standard_unit,measure,structure,statistic,data_role,measurement_basis,species,method_raw,basis_evidence,definition,definition_file,role_evidence,source_reference_id,primary_reference_id,derivation_role,review_reason'
                    db.execute('INSERT INTO points ('+fields+') VALUES ('+','.join('?'*len(record))+') ON CONFLICT(point_id) DO UPDATE SET '+','.join(k+'=excluded.'+k for k in fields.split(',') if k!='point_id'),record)
                    npoints+=1;nreview+=bool(reason);counts[dr]+=1
                    if reason:column_counts[col]+=1;column_reasons[col]=reason
        db.execute('INSERT INTO files VALUES (?,?,?,?,?,?,?,?)',(file.name,item,hashlib.sha256(file.read_bytes()).hexdigest(),'partial' if ragged else 'inventoried',nrows,npoints,nreview,f'{ragged} malformed rows retained in source_issues' if ragged else ''))
        queue.extend(dict(item=item,column=col,n_points=n,reason=column_reasons[col]) for col,n in column_counts.items())
        db.commit()
    export(out,db,root)

def export(out,db,root=ROOT):
    db.execute('CREATE INDEX IF NOT EXISTS point_row ON points(row_id)')
    db.execute('CREATE INDEX IF NOT EXISTS point_item_column ON points(item,column_name)')
    db.execute('CREATE TABLE IF NOT EXISTS basis_context(paper TEXT,column_name TEXT,context_json TEXT,PRIMARY KEY(paper,column_name))')
    items=collections.defaultdict(list)
    for item,regjson in db.execute('SELECT item,registry_json FROM item_context'):
        reg=json.loads(regjson);items[reg.get('Publication name','')].append(item)
    for b in load(root/'_keys/brain_size_basis.csv'):
        db.execute('INSERT OR REPLACE INTO basis_context VALUES (?,?,?)',(b['paper'],b['column'],json.dumps(b,ensure_ascii=False)))
        special={'mass_measured_excl_ob':'brain_mass_excluding_olfactory_bulbs','not_a_size':'not_a_brain_size'}.get(b.get('poolable_group'))
        if special:
            for item in items[b['paper']]:
                # Keep anatomical scope distinct in filter outputs as well as in metadata.
                db.execute('UPDATE points SET measure=? WHERE item=? AND column_name=?',(special,item,b['column']))
    db.commit()
    # Methods and source roles are independent filters; unresolved methods never enter direct-only.
    db.executescript('''
    CREATE INDEX IF NOT EXISTS point_role_measure ON points(active,data_role,measure);
    DROP VIEW IF EXISTS direct_brain_weights;
    DROP VIEW IF EXISTS combined_brain_weights;
    DROP VIEW IF EXISTS endocranial_volumes;
    CREATE VIEW direct_brain_weights AS SELECT * FROM points WHERE active=1 AND measure='brain_mass' AND measurement_basis='direct_weight';
    CREATE VIEW combined_brain_weights AS SELECT * FROM points WHERE active=1 AND measure='brain_mass' AND measurement_basis IN ('direct_weight','estimated_from_brain_volume','estimated_from_endocranial_volume','estimated_from_volume');
    CREATE VIEW endocranial_volumes AS SELECT * FROM points WHERE active=1 AND measure='endocranial_volume' AND measurement_basis='endocranial_volume';
    ''')
    db.commit()
    export_fields=['number','point_id','item','source_file','row_id','row_number','column_name','raw_value','source_unit','standard_value','standard_unit','measure','structure','statistic','data_role','measurement_basis','species','source_reference_id','primary_reference_id','review_reason']
    partitions=[]
    for role in ['primary','secondary','review']:
        directory=out/role/'by_measure';directory.mkdir(exist_ok=True)
        # Rebuild only generated partitions; obsolete quantity partitions must disappear.
        for old in directory.glob('*.csv'):old.unlink()
        old=out/role/'measurements.csv'
        if old.exists():old.unlink()
        for (measure,) in db.execute('SELECT DISTINCT measure FROM points WHERE active=1 AND data_role=? ORDER BY measure',(role,)).fetchall():
            slug=re.sub('[^A-Za-z0-9_]+','_',measure).strip('_')[:75] or 'unclassified'
            name=slug+'_'+digest(measure)[:8]+'.csv'
            cur=db.execute('SELECT '+','.join(export_fields)+' FROM points WHERE active=1 AND data_role=? AND measure=? ORDER BY number',(role,measure))
            write(directory/name,export_fields,(dict(zip(export_fields,r)) for r in cur))
            partitions.append(dict(data_role=role,measure=measure,file=str((directory/name).relative_to(out))))
    write(out/'measure_files.csv',['data_role','measure','file'],partitions)
    db.execute('DELETE FROM report_relations')
    # Explicitly link two representations of the same AnimalTraits brain report.
    db.execute("""INSERT INTO report_relations
      SELECT v.point_id,m.point_id,'alternate_representation','same AnimalTraits source row; mass converted from original volume'
      FROM points v JOIN points m ON v.row_id=m.row_id
      WHERE v.active=1 AND m.active=1 AND v.item='Herberstein_etal_2022_Observations'
      AND v.column_name='Brain_Volume_original.mm3' AND m.column_name='brain size'""")
    for link in load(HERE/'config/report_links.csv'):
        if not all(link.get(k) for k in ['point_id','related_point_id','relation','evidence','reviewer']):
            raise ValueError('Curated report links require both IDs, relation, evidence and reviewer')
        ids={link['point_id'],link['related_point_id']}
        found={r[0] for r in db.execute('SELECT point_id FROM points WHERE active=1 AND point_id IN (?,?)',(link['point_id'],link['related_point_id']))}
        if ids!=found:raise ValueError('Curated report link references absent/inactive points: '+str(ids-found))
        db.execute('INSERT INTO report_relations VALUES (?,?,?,?)',(link['point_id'],link['related_point_id'],link['relation'],link['evidence']+'; reviewed by '+link['reviewer']))
    db.commit()
    for view in ['direct_brain_weights','combined_brain_weights','endocranial_volumes']:
        for role in ['primary','secondary']:
            cur=db.execute('SELECT '+','.join(export_fields)+' FROM '+view+' WHERE data_role=? ORDER BY number',(role,))
            write(out/role/(view+'.csv'),export_fields,(dict(zip(export_fields,r)) for r in cur))
    cur=db.execute('SELECT * FROM source_issues ORDER BY source_file,row_number');issue_keys=[d[0] for d in cur.description]
    write(out/'review/source_issues.csv',issue_keys,(dict(zip(issue_keys,r)) for r in cur))
    cur=db.execute('SELECT * FROM files ORDER BY source_file');write(out/'source_tables.csv',[d[0] for d in cur.description],(dict(zip([d[0] for d in cur.description],r)) for r in cur))
    cur=db.execute("SELECT item,column_name AS column,COUNT(*) AS n_points,GROUP_CONCAT(DISTINCT review_reason) AS reason FROM points WHERE active=1 AND review_reason<>'' GROUP BY item,column_name");write(out/'review/column_queue.csv',['item','column','n_points','reason'],(dict(zip(['item','column','n_points','reason'],r)) for r in cur))
    cur=db.execute('SELECT data_role,measure,measurement_basis,COUNT(*) AS n FROM points WHERE active=1 GROUP BY 1,2,3 ORDER BY 1,2,3');keys=[d[0] for d in cur.description];write(out/'measurement_summary.csv',keys,(dict(zip(keys,r)) for r in cur))
    write(out/'other_public_files.csv',['file','status'],
          (dict(file=p.name,status='Auxiliary, documentation, tree or legacy source; not ingested as an independent canonical table')
           for p in sorted((root/'__Public/comparative-data').iterdir()) if p.is_file() and p.suffix!='.tsv'))
    print('Active points by source role:',dict(db.execute('SELECT data_role,COUNT(*) FROM points WHERE active=1 GROUP BY data_role').fetchall()));print('Tables:',db.execute('SELECT COUNT(*) FROM files').fetchone()[0]);db.close()
def run_local(root,out,resume=False,exports_only=False):
    # SQLite locking and large index writes must run outside cloud-synced storage.
    out.mkdir(exist_ok=True,parents=True)
    with tempfile.TemporaryDirectory(prefix='evom1_measurements_') as tmp:
        work=Path(tmp)
        for role in ['primary','secondary','review']:(work/role).mkdir()
        if (out/'measurements.sqlite').exists():
            original=sqlite3.connect(out/'measurements.sqlite');local=sqlite3.connect(work/'measurements.sqlite')
            original.backup(local);original.close();local.close()
        if exports_only:
            db=sqlite3.connect(work/'measurements.sqlite');db.execute('PRAGMA temp_store=MEMORY');export(work,db,root)
        else:build(root,work,resume)
        # Publish only complete generated outputs; keep scripts and config in place.
        for role in ['primary','secondary','review']:
            old=out/role/'by_measure'
            if old.exists():shutil.rmtree(old)
            shutil.copytree(work/role,out/role,dirs_exist_ok=True)
        for path in work.glob('*.csv'):shutil.copy2(path,out/path.name)
        shutil.copy2(work/'measurements.sqlite',out/'measurements.sqlite.new')
        os.replace(out/'measurements.sqlite.new',out/'measurements.sqlite')

if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('--root',type=Path,default=ROOT);parser.add_argument('--out',type=Path,default=HERE)
    parser.add_argument('--resume',action='store_true',help='Reuse unchanged files after an interrupted initial inventory; do not use after changing processing rules')
    parser.add_argument('--exports-only',action='store_true',help='Recreate views and exports from a completed inventory')
    a=parser.parse_args();run_local(a.root,a.out,a.resume,a.exports_only)
