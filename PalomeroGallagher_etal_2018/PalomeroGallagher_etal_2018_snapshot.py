#!/usr/bin/env python
"""EBRAINS receptor-density fingerprint series (Palomero-Gallagher & Zilles, 2018-2022; Knowledge Graph project
77aeb65e-9ff1-46b2-9f58-e11b2a0687d2) -- ONE parameterised snapshot script for the whole series.

Snapshot rule (born-digital source): each dataset's fingerprint TSV is downloaded ONCE from the EBRAINS data proxy
and copy-renamed, bytes untouched, to  <Item name>_snapshot.tsv  in this folder.  Nothing is typed or re-saved.
The script refuses to overwrite an existing snapshot whose bytes differ from the fresh download unless run with
--force (after the change has been checked and noted in the README).

What drives it: the registry (__ReadMe.xlsx, Sheet1, read by column header, rows looked up by Item name, never by
position).  A row belongs to the series when its citation (column A) starts with SERIES_CITATION_PREFIX and its
'Data series' column equals SERIES_ID.  Column C holds the dataset DOI, column 'Item number' the structure, column
'N.B.' the KG uuid ('KG dataset-version <uuid>').

Resolution per row:  KG record  ->  (if the uuid is a version-less Dataset record: its highest version)  ->
fileRepositoryId  ->  file list  ->  exactly one *_fp*.tsv  (fingerprint: receptor label, density mean/sd/unit).
Laminar-profile TSVs (*_pr_*) and autoradiograph files (*_ar_*) are only RECORDED, never downloaded.

Side outputs (all in ebrains_downloads/ or reference_tables/, never the snapshot itself):
  ebrains_downloads/kg_records/<uuid>.json              KG search-API records used (dataset + version)
  ebrains_downloads/download_manifest.csv               item_name, doi, kg_uuid, bucket, file, url, bytes, sha256, downloaded (+ provenance columns)
  ebrains_downloads/laminar_profiles_present.csv        *_pr_* TSVs present per dataset (recorded, not snapshotted)
  reference_tables/<series>_dataset_metadata.csv        per-item KG metadata the build script joins on
                                                        (species, strain, n subjects, title, version, studied region ...)

Run:  conda run -n neuro-atlas python PalomeroGallagher_etal_2018_snapshot.py [--force] [--refresh] [ITEM_NAME ...]
      --refresh re-downloads (default: an existing snapshot is reused and never re-fetched; a re-download that
      differs from the frozen snapshot is reported and not written unless --force);
      ITEM_NAME restricts the run to the named registry items.
Network: search.kg.ebrains.eu (KG search API) and data-proxy.ebrains.eu (files).
"""
import csv, hashlib, io, json, os, re, shutil, sys, datetime
import requests
import openpyxl

SERIES_CITATION_PREFIX = ("Palomero-Gallagher, N., Zilles, K., & Amunts, K. (2018). Quantitative receptor data for human, "
                          "non-human primate, and rodent brains")
SERIES_ID = "EBRAINS_receptor_densities_Juelich"
KG_API    = "https://search.kg.ebrains.eu/api/groups/public"

HERE        = os.path.dirname(os.path.abspath(__file__))
series_name = os.path.splitext(os.path.basename(__file__))[0].removesuffix("_snapshot")   # PalomeroGallagher_etal_2018
dl_dir      = os.path.join(HERE, "ebrains_downloads")
kg_dir      = os.path.join(dl_dir, "kg_records")
ref_dir     = os.path.join(HERE, "reference_tables")
manifest_csv = os.path.join(dl_dir, "download_manifest.csv")
laminar_csv  = os.path.join(dl_dir, "laminar_profiles_present.csv")
metadata_csv = os.path.join(ref_dir, series_name + "_dataset_metadata.csv")
for d in (kg_dir, ref_dir):
    os.makedirs(d, exist_ok=True)

FORCE   = "--force"   in sys.argv
REFRESH = "--refresh" in sys.argv
ONLY    = [a for a in sys.argv[1:] if not a.startswith("--")]

## ---- registry rows for this series (by header, by Item name) --------------------------------------
def repo_root(start):
    d = start
    while os.path.dirname(d) != d and not os.path.exists(os.path.join(d, "__ReadMe.xlsx")):
        d = os.path.dirname(d)
    if not os.path.exists(os.path.join(d, "__ReadMe.xlsx")):
        sys.exit("__ReadMe.xlsx not found walking up from " + start)
    return d

root = repo_root(HERE)
wb   = openpyxl.load_workbook(os.path.join(root, "__ReadMe.xlsx"), read_only=True, data_only=True)
rows = list(wb["Sheet1"].iter_rows(values_only=True))
hdr  = [str(h) if h is not None else "" for h in rows[0]]
col  = {h: i for i, h in enumerate(hdr)}
def cell(r, name):
    v = r[col[name]]
    return "" if v is None else str(v).strip()
registry = []
for r in rows[1:]:
    if cell(r, hdr[0]).startswith(SERIES_CITATION_PREFIX) and cell(r, "Data series") == SERIES_ID:
        registry.append(dict(item_name=cell(r, "Item name"), item_number=cell(r, "Item number"),
                             item_encoded=cell(r, "Item encoded"),
                             doi=cell(r, "DOI if different from article or doi Alt"),
                             nb=cell(r, "N.B."), taxon=cell(r, "Taxon"), title_registry=cell(r, "Item full original title")))
if not registry:
    sys.exit("No registry rows found for series " + SERIES_ID)
if ONLY:
    registry = [x for x in registry if x["item_name"] in ONLY]
    missing = set(ONLY) - {x["item_name"] for x in registry}
    if missing:
        sys.exit("Item name(s) not in the series registry rows: " + ", ".join(sorted(missing)))
print(f"{len(registry)} registry rows for series {SERIES_ID}")

## ---- KG helpers ---------------------------------------------------------------------------------
S = requests.Session()
def GET(url, **kw):
    """GET with 3 attempts (the EBRAINS proxies occasionally drop a connection mid-batch)."""
    import time
    for attempt in range(3):
        try:
            r = S.get(url, timeout=120, **kw); r.raise_for_status(); return r
        except (requests.exceptions.ConnectionError, requests.exceptions.Timeout) as e:
            if attempt == 2: raise
            time.sleep(5 * (attempt + 1))
def kg_record(uuid):
    p = os.path.join(kg_dir, uuid + ".json")
    if os.path.exists(p) and not REFRESH:
        return json.load(open(p, encoding="utf-8"))
    r = GET(f"{KG_API}/documents/{uuid}")
    j = r.json()
    json.dump(j, open(p, "w", encoding="utf-8"), indent=1, ensure_ascii=False)
    return j

def kg_files(repo_id):
    url, out, seen = f"{KG_API}/repositories/{repo_id}/files", [], 0
    r = GET(url); j = r.json(); out += j["data"]
    while j.get("searchAfter") and seen < 50:          # defensive pagination
        r = GET(url, params={"searchAfter": j["searchAfter"]})
        j = r.json(); out += j["data"]; seen += 1
    return out

def specimen_summary(fields):
    """species / strain / n subjects / sexes / ages / hemispheres from the specimenBySubject tree."""
    species, strains, sexes, ages, subj, lat, overview_n = set(), set(), set(), [], set(), [], None
    def walk(n):
        nonlocal overview_n
        if isinstance(n, dict):
            d = n.get("data")
            if isinstance(d, dict):
                t = (d.get("type") or {}).get("value", "")
                for s in d.get("species") or []: species.add(s.get("value"))
                for s in d.get("strain")  or []: strains.add(s.get("value"))
                if t == "Dataset.SpecimenOverview":
                    q = d.get("quantity") or d.get("numberOfSubjects")
                    overview_n = (q or {}).get("value") if isinstance(q, dict) else q
                    for s in d.get("sex") or []: sexes.add(s.get("value"))
                if t == "Dataset.Subject":
                    subj.add(d.get("id"))
                    a = d.get("age"); ages.append((a or {}).get("value", "") if isinstance(a, dict) else (a or ""))
                if t == "Dataset.TissueSampleCollection":
                    lat.append(";".join(s.get("value") for s in d.get("laterality") or []))
            for v in n.values(): walk(v)
        elif isinstance(n, list):
            for v in n: walk(v)
    walk(fields.get("specimenBySubject"))
    return dict(species_kg="; ".join(sorted(x for x in species if x)), strain_kg="; ".join(sorted(x for x in strains if x)),
                n_subjects_kg=overview_n if overview_n is not None else (len(subj) or ""),
                n_subject_records_kg=len(subj), sexes_kg="; ".join(sorted(x for x in sexes if x)),
                ages_kg="; ".join(a for a in ages if a), hemispheres_kg="; ".join(x for x in lat if x))

def val(fields, k):
    v = fields.get(k)
    if isinstance(v, dict): return v.get("value", "")
    if isinstance(v, list): return "; ".join(str(x.get("value", "")) for x in v)
    return v or ""

## ---- previous manifest (keeps first-download timestamps) -----------------------------------------
prev = {}
if os.path.exists(manifest_csv):
    for r in csv.DictReader(open(manifest_csv, encoding="utf-8")):
        prev[r["item_name"]] = r

## ---- main loop ------------------------------------------------------------------------------------
manifest, laminar, metadata, problems = [], [], [], []
for reg in registry:
    item_name = reg["item_name"]
    m = re.search(r"KG dataset-version ([0-9a-f-]{36})", reg["nb"])
    if not m:
        problems.append(f"{item_name}: no KG uuid in N.B."); continue
    kg_registry_uuid = m.group(1)
    rec = kg_record(kg_registry_uuid)
    rec_type = (rec.get("type") or [""])[0]
    if rec_type == "Dataset":                       # version-less concept record -> highest version
        vs = [(d["children"]["version"]["value"], d["children"]["version"]["reference"]) for d in rec["fields"]["datasets"]]
        vs.sort(key=lambda x: float(re.sub(r"[^0-9.]", "", x[0]) or 0))
        version_label, version_uuid = vs[-1]
        all_versions = "; ".join(f"{a}:{b}" for a, b in vs)
        vrec = kg_record(version_uuid)
    else:
        version_label, version_uuid, all_versions, vrec = "", kg_registry_uuid, "", rec
    f = vrec["fields"]
    repo_id = f.get("fileRepositoryId")
    if not repo_id:
        problems.append(f"{item_name}: no fileRepositoryId on KG record {version_uuid}"); continue
    fl = kg_files(repo_id)
    names = [(x["title"]["value"], x["iri"]["value"], x.get("size", {}).get("value", "")) for x in fl]
    fp = [x for x in names if "_fp" in x[0] and x[0].lower().endswith(".tsv")]
    if len(fp) != 1:
        problems.append(f"{item_name}: expected exactly one fingerprint TSV, found {[x[0] for x in fp]}"); continue
    fname, url, size_label = fp[0]
    mm = re.match(r"https://data-proxy\.ebrains\.eu/api/v1/buckets/([^/]+)/(.*)$", url)
    bucket, path = (mm.group(1), mm.group(2)) if mm else ("", url)
    for n_, u_, s_ in names:
        if "_pr_" in n_ and n_.lower().endswith(".tsv"):
            laminar.append(dict(item_name=item_name, file=n_, url=u_, size=s_))
    n_pr = sum(1 for n_, _, _ in names if "_pr_" in n_)
    n_ar = sum(1 for n_, _, _ in names if "_ar_" in n_)

    ## download once -> the snapshot IS the untouched download (bytes as served); no second copy is kept ----------
    snap = os.path.join(HERE, item_name + "_snapshot.tsv")
    downloaded = prev.get(item_name, {}).get("downloaded", "")
    if os.path.exists(snap) and not REFRESH:
        data = open(snap, "rb").read()                      # already downloaded once: reuse, never re-fetch
        if not downloaded:
            downloaded = datetime.datetime.fromtimestamp(os.path.getmtime(snap), datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    else:
        r = GET(url); data = r.content
        now = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
        if os.path.exists(snap) and open(snap, "rb").read() != data and not FORCE:
            problems.append(f"{item_name}: existing snapshot differs from the fresh download; NOT overwritten (use --force after checking)")
            data = open(snap, "rb").read()                  # manifest keeps describing the frozen copy
        else:
            with open(snap, "wb") as fh: fh.write(data)     # bytes untouched
            downloaded = now
    sha = hashlib.sha256(data).hexdigest()
    manifest.append(dict(item_name=item_name, doi=reg["doi"], kg_uuid=version_uuid, bucket=bucket, file=path, url=url,
                         bytes=len(data), sha256=sha, downloaded=downloaded,
                         kg_registry_uuid=kg_registry_uuid, kg_record_type=rec_type, version_label=version_label,
                         snapshot=os.path.basename(snap), n_laminar_profile_tsv=n_pr, n_autoradiograph_files=n_ar, n_files=len(names)))
    sp = specimen_summary(f)
    title = vrec.get("title", "")
    metadata.append(dict(item_name=item_name, item_number=reg["item_number"], item_encoded=reg["item_encoded"], doi=reg["doi"],
                         kg_registry_uuid=kg_registry_uuid, kg_record_type=rec_type, kg_version_uuid=version_uuid,
                         version_label=version_label, all_versions=all_versions, version_doi_kg=val(f, "doi"),
                         title_kg=title, studied_brain_region_kg=val(f, "studiedBrainRegion"),
                         new_in_this_version_kg=val(f, "newInThisVersion"), released_at_kg=val(f, "releasedAt"),
                         preparation_kg=val(f, "preparation"), technique_kg=val(f, "technique"),
                         **sp, fingerprint_file=path, fingerprint_url=url, snapshot=os.path.basename(snap)))
    print(f"  {item_name:68s} {bucket}/{path}  {len(data)} B  pr={n_pr} ar={n_ar}  species={sp['species_kg']} n={sp['n_subjects_kg']}")

## ---- write side outputs ----------------------------------------------------------------------------
def write_csv(path, rows):
    if not rows: return
    keys = list(rows[0].keys())
    with open(path, "w", encoding="utf-8", newline="") as fh:
        w = csv.DictWriter(fh, fieldnames=keys, lineterminator="\n"); w.writeheader(); w.writerows(rows)
if ONLY and os.path.exists(manifest_csv):        # partial run: merge into the existing manifest/metadata
    def merge(path, rows):
        old = list(csv.DictReader(open(path, encoding="utf-8"))) if os.path.exists(path) else []
        new = {r["item_name"]: r for r in rows}
        merged = [new.pop(r["item_name"], r) for r in old] + list(new.values())
        write_csv(path, merged)
    merge(manifest_csv, manifest); merge(metadata_csv, metadata)
    lam_old = [r for r in csv.DictReader(open(laminar_csv, encoding="utf-8"))] if os.path.exists(laminar_csv) else []
    done = {r["item_name"] for r in manifest}
    write_csv(laminar_csv, [r for r in lam_old if r["item_name"] not in done] + laminar)
else:
    write_csv(manifest_csv, manifest); write_csv(metadata_csv, metadata)
    write_csv(laminar_csv, laminar if laminar else [dict(item_name="", file="", url="", size="")])

print(f"\n{len(manifest)} fingerprint TSVs resolved; {len(laminar)} laminar-profile TSVs recorded (not downloaded)")
print("manifest:", os.path.relpath(manifest_csv, HERE)); print("metadata:", os.path.relpath(metadata_csv, HERE))
if problems:
    print("\nPROBLEMS:"); print("\n".join("  " + p for p in problems)); sys.exit(1)
