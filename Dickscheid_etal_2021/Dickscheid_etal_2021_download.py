#!/usr/bin/env python
"""Dickscheid T, Bludau S, Paquola C, Schiffer C, Upschulte E, Amunts K (2021). Layer-specific distributions of
segmented cells in different cytoarchitectonic regions of BigBrain iso cortex. EBRAINS dataset series
(Knowledge Graph project f06a2fd1-a9ca-42a3-b754-adaa025adb10; one dataset version + DOI 10.25493/... per area).

DOWNLOAD / INVENTORY script for the series folder.  It writes ONLY provenance files, never a snapshot, CSV or TSV:

  ebrains_downloads/kg_records/<kg_dataset_version>.json      KG search-API record of each dataset version (untouched)
  ebrains_downloads/<area_dir>/v1.0/...                         the bucket files listed below, bytes untouched
  ebrains_downloads/download_manifest.csv                       every object of the 12 area folders of the bucket
                                                                (2283 objects), with bucket md5/bytes; sha256 for the
                                                                objects that were downloaded
  reference_tables/Dickscheid_etal_2021_datasets.csv            Item name <-> dataset DOI, KG dataset version, bucket
                                                                folder, Julich-Brain area, number of sections/patches

Which rows are the series: the registry (__ReadMe.xlsx, Sheet1) rows whose citation (column A) starts with the
series citation below; Item name (col J), Item number (col D), dataset DOI (col C) and the KG dataset-version
uuid (in the N.B. column) are read from those rows -- the registry is the authority, nothing is retyped here.

What is downloaded (the tabular / documentary part of each dataset; the images, segmentation masks and pdf
reports stay in the bucket and are only listed in the manifest):
  <area>/v1.0/README.md, stats.pdf, DataDescriptor_*.pdf                     per dataset (3 files)
  <area>/v1.0/<section>/<patch>/info.txt, layerinfo.txt, segments.txt       per image patch (3 files)
The data-proxy returns public objects without authentication; the bucket is
p22717-hbp-d000061_BB-CorticalCellDistribution_pub.  Listing the whole bucket in one call times out (504), so the
listing is done per section folder.  A file already present locally is not re-downloaded; its sha256 is recomputed
and its md5 is compared with the bucket ETag (the manifest column md5_matches_bucket).

Run:  conda run -n neuro-atlas python Dickscheid_etal_2021_download.py     (needs pandas, openpyxl, requests)
"""
import csv, datetime, hashlib, json, os, re, sys, time
import concurrent.futures as cf
import requests, pandas as pd, openpyxl

HERE   = os.path.dirname(os.path.abspath(__file__))
series = os.path.splitext(os.path.basename(__file__))[0].removesuffix("_download")       # Dickscheid_etal_2021
root   = HERE
while not os.path.exists(os.path.join(root, "__ReadMe.xlsx")) and os.path.dirname(root) != root:
    root = os.path.dirname(root)
registry_xlsx = os.path.join(root, "__ReadMe.xlsx")
dl_dir        = os.path.join(HERE, "ebrains_downloads")
kg_dir        = os.path.join(dl_dir, "kg_records")
manifest_csv  = os.path.join(dl_dir, "download_manifest.csv")
datasets_csv  = os.path.join(HERE, "reference_tables", series + "_datasets.csv")
os.makedirs(kg_dir, exist_ok=True); os.makedirs(os.path.dirname(datasets_csv), exist_ok=True)

CITATION_START = ("Dickscheid, T., Bludau, S., Paquola, C., Schiffer, C., Upschulte, E., & Amunts, K. (2021). "
                  "Layer-specific distributions of segmented cells in different cytoarchitectonic regions of BigBrain iso cortex")
KG_DOC  = "https://search.kg.ebrains.eu/api/groups/public/documents/{}"
KG_REPO = "https://search.kg.ebrains.eu/api/groups/public/repositories/{}/files?size=5"
PROXY   = "https://data-proxy.ebrains.eu/api/v1/buckets/"
BUCKET  = "p22717-hbp-d000061_BB-CorticalCellDistribution_pub"
WANT_PATCH = {"info.txt", "layerinfo.txt", "segments.txt"}
WANT_TOP   = {"README.md", "stats.pdf"}            # + DataDescriptor_*.pdf

## 1. registry rows of the series -------------------------------------------------------------------------------
wb = openpyxl.load_workbook(registry_xlsx, read_only=True, data_only=True)
rows = list(wb["Sheet1"].iter_rows(values_only=True)); hdr = list(rows[0])
col = {h: i for i, h in enumerate(hdr)}
reg = [r for r in rows[1:] if r[0] and str(r[0]).startswith(CITATION_START)]
if not reg:
    sys.exit("no registry rows found for the series citation")
items = []
for r in reg:
    nb = str(r[col["N.B."]])
    m = re.search(r"KG dataset-version ([0-9a-f-]{36})", nb)
    if not m:
        sys.exit("no KG dataset-version uuid in N.B. of " + str(r[col["Item name"]]))
    items.append(dict(item_name=r[col["Item name"]], item_number=r[col["Item number"]],
                      dataset_doi=r[col["DOI if different from article or doi Alt"]], kg_dataset_version=m.group(1)))
print(len(items), "registry rows")

## 2. KG records -> bucket folder of each dataset version ---------------------------------------------------------
def get_json(url):
    for attempt in range(5):
        try:
            r = requests.get(url, timeout=90); r.raise_for_status(); return r.json()
        except Exception as e:
            err = e; time.sleep(5 * (attempt + 1))
    raise err

def region_label(fields):
    for b in fields.get("studiedBrainRegion") or []:
        if "(Julich-Brain Atlas)" in b["value"]:
            return b["value"].replace(" (Julich-Brain Atlas)", "")
    return None

for it in items:
    p = os.path.join(kg_dir, it["kg_dataset_version"] + ".json")
    if os.path.exists(p):
        j = json.load(open(p))
    else:
        j = get_json(KG_DOC.format(it["kg_dataset_version"]))
        json.dump(j, open(p, "w"), indent=1)
    f = j["fields"]
    it["kg_doi"] = f["doi"]["value"]
    it["file_repository_id"] = f["fileRepositoryId"]
    it["julich_area"] = region_label(f)
    it["kg_page"] = "https://search.kg.ebrains.eu/instances/" + it["kg_dataset_version"]
    it["kg_record_json"] = os.path.relpath(p, HERE)
    rf = get_json(KG_REPO.format(it["file_repository_id"]))
    url = rf["data"][0]["iri"]["value"]
    it["bucket"] = BUCKET
    it["area_dir"] = url.split(BUCKET + "/")[1].split("/")[0]
    if it["kg_doi"] != it["dataset_doi"]:
        sys.exit(f"DOI mismatch registry {it['dataset_doi']} vs KG {it['kg_doi']} for {it['item_name']}")
    print(it["item_name"], it["dataset_doi"], it["area_dir"], it["julich_area"])

## 3. bucket listing (per section folder; whole-bucket listing times out) ----------------------------------------
def listing(prefix, delimiter=None, limit=2000):
    out, marker = [], None
    while True:
        p = {"prefix": prefix, "limit": limit}
        if delimiter: p["delimiter"] = delimiter
        if marker: p["marker"] = marker
        for attempt in range(5):
            try:
                r = requests.get(PROXY + BUCKET, params=p, timeout=120); r.raise_for_status(); break
            except Exception as e:
                err = e; time.sleep(5 * (attempt + 1))
        else:
            raise err
        objs = r.json()["objects"]; out += objs
        if len(objs) < limit: break
        marker = objs[-1].get("name") or objs[-1].get("subdir")
    return out

objs = []
for it in items:
    top = listing(it["area_dir"] + "/v1.0/", delimiter="/")
    objs += [o for o in top if o.get("name")]
    for sd in [o["subdir"] for o in top if o.get("subdir")]:
        objs += [o for o in listing(sd) if o.get("name")]
man = pd.DataFrame(objs).drop_duplicates("name")
man = man[man["bytes"] > 0].copy()                      # zero-byte folder placeholders dropped
man["area_dir"] = man["name"].str.split("/").str[0]
parts = man["name"].str.split("/")
man["depth"] = man["name"].str.count("/")
man["file"] = parts.str[-1]
man["section"] = parts.apply(lambda p: p[2] if len(p) == 5 else "")
man["patch"]   = parts.apply(lambda p: p[3] if len(p) == 5 else "")
man["file_kind"] = man["depth"].map({2: "dataset-level", 4: "per-patch"})
man["wanted"] = man.apply(lambda r: (r.file in WANT_TOP or r.file.startswith("DataDescriptor_")) if r.depth == 2
                          else r.file in WANT_PATCH, axis=1)
a2i = {it["area_dir"]: it for it in items}
man["item_name"] = man["area_dir"].map(lambda a: a2i[a]["item_name"])
man["dataset_doi"] = man["area_dir"].map(lambda a: a2i[a]["dataset_doi"])
man["kg_dataset_version"] = man["area_dir"].map(lambda a: a2i[a]["kg_dataset_version"])
man["url"] = PROXY + BUCKET + "/" + man["name"]
print(len(man), "bucket objects;", int(man.wanted.sum()), "to download,", round(man.bytes[man.wanted].sum() / 1e6, 1), "MB")

## 4. download the wanted files (skip existing), sha256 + md5 check ------------------------------------------------
def fetch(name):
    dest = os.path.join(dl_dir, name)
    if not (os.path.exists(dest) and os.path.getsize(dest) > 0):
        os.makedirs(os.path.dirname(dest), exist_ok=True)
        for attempt in range(5):
            try:
                r = requests.get(PROXY + BUCKET + "/" + name, params={"redirect": "true"}, timeout=180)
                r.raise_for_status()
                tmp = dest + ".part"; open(tmp, "wb").write(r.content); os.replace(tmp, dest); break
            except Exception as e:
                err = e; time.sleep(5 * (attempt + 1))
        else:
            return name, None, None, None
    data = open(dest, "rb").read()
    return name, hashlib.sha256(data).hexdigest(), hashlib.md5(data).hexdigest(), len(data)

res = {}
with cf.ThreadPoolExecutor(8) as ex:
    for name, sha, md5, nbytes in ex.map(fetch, man.name[man.wanted].tolist()):
        res[name] = (sha, md5, nbytes)
man["downloaded"] = man.name.map(lambda n: n in res and res[n][0] is not None)
man["local_path"] = man.apply(lambda r: os.path.join("ebrains_downloads", r["name"]) if r.downloaded else "", axis=1)
man["sha256"] = man.name.map(lambda n: res.get(n, (None,))[0] or "")
man["local_bytes"] = man.name.map(lambda n: res.get(n, (None, None, None))[2])
man["md5_matches_bucket"] = man.apply(lambda r: (res[r["name"]][1] == r["hash"]) if r.downloaded else "", axis=1)
man["downloaded_utc"] = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
failed = man[man.wanted & ~man.downloaded]
if len(failed):
    print("FAILED downloads:", failed.name.tolist())
bad = man[(man.md5_matches_bucket == False)]
if len(bad):
    print("md5 != bucket ETag:", bad.name.tolist())
cols = ["item_name", "dataset_doi", "kg_dataset_version", "area_dir", "file_kind", "section", "patch", "file", "name",
        "url", "bytes", "hash", "last_modified", "content_type", "downloaded", "local_path", "local_bytes", "sha256",
        "md5_matches_bucket", "downloaded_utc"]
man = man.sort_values("name")[cols].rename(columns={"name": "bucket_path", "hash": "bucket_md5", "bytes": "bucket_bytes"})
man.to_csv(manifest_csv, index=False, lineterminator="\n")
print("wrote", os.path.relpath(manifest_csv, HERE), len(man), "rows;", int(man.downloaded.sum()), "downloaded")

## 5. item <-> dataset table ---------------------------------------------------------------------------------------
pp = man[(man.file == "layerinfo.txt")].groupby("item_name")
ds = pd.DataFrame(items)
ds["bucket_prefix"] = ds["area_dir"] + "/v1.0/"
ds["n_sections"] = ds["item_name"].map(pp["section"].nunique())
ds["n_patches"]  = ds["item_name"].map(pp.size())
ds["data_descriptor_pdf"] = ds["item_name"].map(man[man.file.str.startswith("DataDescriptor_")].set_index("item_name")["local_path"])
ds["stats_pdf"]  = ds["item_name"].map(man[man.file == "stats.pdf"].set_index("item_name")["local_path"])
ds = ds[["item_name", "item_number", "dataset_doi", "kg_dataset_version", "kg_page", "file_repository_id", "bucket",
         "bucket_prefix", "area_dir", "julich_area", "n_sections", "n_patches", "data_descriptor_pdf", "stats_pdf",
         "kg_record_json"]]
ds.to_csv(datasets_csv, index=False, lineterminator="\n")
print("wrote", os.path.relpath(datasets_csv, HERE)); print(ds[["item_name", "area_dir", "julich_area", "n_sections", "n_patches"]].to_string(index=False))
