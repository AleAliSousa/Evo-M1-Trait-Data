#!/usr/bin/env python
"""EBRAINS receptor-density fingerprints (Palomero-Gallagher, Zilles, Amunts et al.) for Julich-Brain areas,
fetched through siibra.  Snapshot script: writes ONLY <Item>_snapshot.csv.

This is a CONSTRUCTED source: the values are not printed in Zilles & Palomero-Gallagher (2017); they are
the per-area EBRAINS Knowledge Graph datasets ("Density measurements of different receptors for <area>
[human, vX.Y]", each with its own DOI 10.25493/...) that siibra exposes as ReceptorDensityFingerprint
features of the Julich-Brain Cytoarchitectonic Atlas.  One row = one fingerprint feature x one receptor,
carrying the feature id, the dataset id / name / DOI, the EBRAINS KG page and the source TSV URL that
siibra parsed, so every value can be traced to its dataset.  Values are copied as parsed by siibra
(mean, std, unit) — nothing is typed here.

Requires network access to the siibra configuration (GitHub), the EBRAINS data proxy (TSV files) and the
dataset-metadata mirrors (gitlab.ebrains.eu / jugit.fz-juelich.de).  siibra version is recorded in a
column; a different siibra release may expose a different feature set — the frozen copy is the
snapshot, and the script refuses to overwrite a differing frozen copy unless run with --force.

Run:  conda run -n neuro-atlas python <this file>      (siibra 1.0.1a27 at build time)
"""
import csv, io, os, sys, logging

HERE      = os.path.dirname(os.path.abspath(__file__))
item_name = os.path.splitext(os.path.basename(__file__))[0].removesuffix("_snapshot")
out_csv   = os.path.join(HERE, item_name + "_snapshot.csv")

os.environ.setdefault("SIIBRA_LOG_LEVEL", "ERROR")
import siibra
logging.getLogger("siibra").setLevel(logging.ERROR)

PARCELLATION = "julich 3.0"
MODALITY     = "ReceptorDensityFingerprint"

parc  = siibra.parcellations.get(PARCELLATION)
feats = siibra.features.get(parc, MODALITY)

def dataset_fields(f):
    """first KG dataset entry (id, name) and the set of DOIs over all entries."""
    ds = list(f.datasets)
    dsid   = ds[0].id if ds else ""
    dsname = ds[0].name if ds else ""
    dois   = []
    for d in ds:
        for u in d.urls:
            u = u.get("url", u) if isinstance(u, dict) else u
            if u and u not in dois:
                dois.append(u)
    return dsid, dsname, "; ".join(dois)

rows = []
for f in feats:
    anchor   = str(f.anchor)
    regions  = "; ".join(sorted({str(r) for r in f.anchor.regions})) if hasattr(f.anchor, "regions") else anchor
    dsid, dsname, dois = dataset_fields(f)
    kgpage   = f"https://search.kg.ebrains.eu/instances/{dsid}" if dsid else ""
    src_tsv  = getattr(getattr(f, "_loader", None), "url", "")
    data     = f.data                       # DataFrame indexed by receptor: mean, std
    for receptor, rec in data.iterrows():
        rows.append([parc.name, anchor, regions, f.id, dsid, dsname, dois, kgpage, src_tsv,
                     receptor, rec["mean"], rec["std"], f.unit, len(data), siibra.__version__])

# deterministic order: by anchor, then feature id, then receptor order as parsed
rows.sort(key=lambda r: (r[1], r[3]))

header = ["parcellation", "anchor", "regions", "feature_id", "dataset_id", "dataset_name", "dataset_doi",
          "ebrains_page", "source_tsv", "receptor", "mean", "std", "unit", "n_receptors", "siibra_version"]
buf = io.StringIO(); w = csv.writer(buf, lineterminator="\n"); w.writerow(header); w.writerows(rows)
new = buf.getvalue()

n_feat = len({r[3] for r in rows})
if os.path.exists(out_csv) and "--force" not in sys.argv:
    old = open(out_csv, encoding="utf-8").read()
    if old != new:
        sys.exit(f"Frozen snapshot differs from the fresh siibra fetch ({n_feat} features, {len(rows)} rows): {out_csv}\n"
                 "Not overwritten. Re-run with --force only after checking the change and noting it in the README.")
    print(f"Snapshot unchanged: {os.path.basename(out_csv)} ({n_feat} features, {len(rows)} rows)")
else:
    with open(out_csv, "w", encoding="utf-8", newline="") as fh:
        fh.write(new)
    print(f"Wrote {len(rows)} rows ({n_feat} fingerprint features) -> {os.path.basename(out_csv)}")
