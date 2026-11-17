#!/usr/bin/env python
"""Dickscheid T, Bludau S, Paquola C, Schiffer C, Upschulte E, Amunts K (2021). Layer-specific distributions of
segmented cells in different cytoarchitectonic regions of BigBrain iso cortex. EBRAINS dataset series, one dataset
version (DOI 10.25493/...) per Julich-Brain area; 12 items Dickscheid_etal_2021_Area44 ... Dickscheid_etal_2021_AreahOc5.

PARAMETERISED snapshot script: frozen per-patch downloads -> <Item name>_snapshot.csv (one file per item).
It writes ONLY snapshots.  The companion Dickscheid_etal_2021_build.R reads them and never writes them.

Why the snapshot is constructed.  Each dataset's "averaged report" (<area>/v1.0/stats.pdf) and per-patch
report.pdf are FIGURE-ONLY pdfs (bar charts, no table); the dataset holds no averaged table in CSV/JSON form.
The tabular data are per image patch: layerinfo.txt (measured area in square micron and average thickness in
micron per layer I-VI, in the physical image coordinates of the 20-micron section, NOT shrinkage-corrected) and
segments.txt (one row per segmented cell body: x, y, area, layer index, label).  The snapshot is therefore the
published-table view of those two files: one row per patch x layer with the layerinfo.txt values AS PRINTED (the
numeric strings are copied verbatim) and the count of segments.txt rows carrying that layer index.  Nothing is
averaged or unit-converted here; that is done in the build script, where the formula is documented.

Inputs (all under ebrains_downloads/, bytes untouched; see Dickscheid_etal_2021_download.py):
  reference_tables/Dickscheid_etal_2021_datasets.csv   Item name -> bucket folder (area_dir), DOI, KG version
  ebrains_downloads/download_manifest.csv              per-patch files with sha256 (verified before use; a missing
                                                       file is re-downloaded from its url and must match the sha256)
  ebrains_downloads/<area_dir>/v1.0/<section>/<patch>/{info.txt, layerinfo.txt, segments.txt}

Snapshot columns (row order: section, patch folder, layer number):
  area_dir, brain_id, section_id, patch_id, patch_dir, inplane_resolution_micron, section_thickness_micron
      -- info.txt fields as printed (patch_dir = the 4-digit patch folder; patch_id = info.txt 'patch_id')
  layer_number, layer_name, Area_micron2, AvgThickness_micron
      -- layerinfo.txt row as printed ('# Number Name Area(micron**2) AvgThickness(micron)')
  n_cells_in_layer           -- rows of segments.txt whose 'layer' column equals layer_number
  n_cells_patch_total        -- all rows of segments.txt (layer indices 0..7 occur; 0 and 7 lie outside layers I-VI)
  n_cells_layer_index_0, n_cells_layer_index_7   -- the rows outside I-VI, for completeness (same value on the
                                                    6 rows of a patch)
  layerinfo_file, segments_file                  -- bucket paths of the two source files

Run:  conda run -n neuro-atlas python Dickscheid_etal_2021_snapshot.py                 (all 12 items)
      conda run -n neuro-atlas python Dickscheid_etal_2021_snapshot.py --item Dickscheid_etal_2021_Area44
      add --force to overwrite a differing frozen copy (then explain the change in the README).
"""
import argparse, csv, hashlib, io, os, sys, time
import requests

HERE   = os.path.dirname(os.path.abspath(__file__))
series = os.path.splitext(os.path.basename(__file__))[0].removesuffix("_snapshot")        # Dickscheid_etal_2021
datasets_csv = os.path.join(HERE, "reference_tables", series + "_datasets.csv")
manifest_csv = os.path.join(HERE, "ebrains_downloads", "download_manifest.csv")

ap = argparse.ArgumentParser()
ap.add_argument("--item", action="append", help="Item name(s) to build; default: every item of the series")
ap.add_argument("--force", action="store_true")
args = ap.parse_args()

datasets = list(csv.DictReader(open(datasets_csv, encoding="utf-8")))
manifest = [r for r in csv.DictReader(open(manifest_csv, encoding="utf-8")) if r["file_kind"] == "per-patch"]
wanted = args.item or [d["item_name"] for d in datasets]
unknown = [w for w in wanted if w not in {d["item_name"] for d in datasets}]
if unknown:
    sys.exit("not in " + os.path.basename(datasets_csv) + ": " + ", ".join(unknown))

def local_file(row):
    """Return the local path of a manifest row, verifying sha256; download if missing."""
    dest = os.path.join(HERE, row["local_path"]) if row["local_path"] else os.path.join(HERE, "ebrains_downloads", row["bucket_path"])
    if not os.path.exists(dest):
        os.makedirs(os.path.dirname(dest), exist_ok=True)
        for attempt in range(5):
            try:
                r = requests.get(row["url"], params={"redirect": "true"}, timeout=180); r.raise_for_status()
                open(dest + ".part", "wb").write(r.content); os.replace(dest + ".part", dest); break
            except Exception as e:
                err = e; time.sleep(5 * (attempt + 1))
        else:
            raise err
        print("downloaded", row["bucket_path"])
    sha = hashlib.sha256(open(dest, "rb").read()).hexdigest()
    if row["sha256"] and sha != row["sha256"]:
        sys.exit(f"sha256 mismatch for {row['bucket_path']}: manifest {row['sha256']} vs file {sha}")
    return dest

HEADER = ["area_dir", "brain_id", "section_id", "patch_id", "patch_dir", "inplane_resolution_micron",
          "section_thickness_micron", "layer_number", "layer_name", "Area_micron2", "AvgThickness_micron",
          "n_cells_in_layer", "n_cells_patch_total", "n_cells_layer_index_0", "n_cells_layer_index_7",
          "layerinfo_file", "segments_file"]

for item_name in wanted:
    ds = next(d for d in datasets if d["item_name"] == item_name)
    area = ds["area_dir"]
    rows_m = [r for r in manifest if r["area_dir"] == area]
    patches = sorted({(r["section"], r["patch"]) for r in rows_m})
    out_rows = []
    for section, patch in patches:
        byname = {r["file"]: r for r in rows_m if r["section"] == section and r["patch"] == patch}
        for need in ("info.txt", "layerinfo.txt", "segments.txt"):
            if need not in byname:
                sys.exit(f"{area}/{section}/{patch}: {need} not in manifest")
        info = dict(l.split(" ", 1) for l in open(local_file(byname["info.txt"]), encoding="utf-8").read().strip().splitlines())
        li_lines = [l for l in open(local_file(byname["layerinfo.txt"]), encoding="utf-8").read().splitlines() if l.strip()]
        assert li_lines[0].strip() == "# Number Name Area(micron**2) AvgThickness(micron)", li_lines[0]
        layers = [l.split() for l in li_lines[1:]]
        assert [l[0] for l in layers] == ["1", "2", "3", "4", "5", "6"], (area, section, patch, layers)
        assert [l[1] for l in layers] == ["I", "II", "III", "IV", "V", "VI"], (area, section, patch, layers)
        seg_lines = open(local_file(byname["segments.txt"]), encoding="utf-8").read().splitlines()
        assert seg_lines[0].strip() == "# x y area(micron**2) layer label", seg_lines[0]
        counts = {}
        for l in seg_lines[1:]:
            if not l.strip():
                continue
            k = int(float(l.split()[3]))
            counts[k] = counts.get(k, 0) + 1
        total = sum(counts.values())
        assert set(counts) <= set(range(0, 8)), (area, section, patch, sorted(counts))
        assert info["section_id"] == section.lstrip("0") or info["section_id"] == section, (info, section)
        for num, name, area_um2, thick in layers:
            out_rows.append([area, info["brain_id"], section, info["patch_id"], patch, info["inplane_resolution_micron"],
                             info["section_thickness_micron"], num, name, area_um2, thick,
                             counts.get(int(num), 0), total, counts.get(0, 0), counts.get(7, 0),
                             byname["layerinfo.txt"]["bucket_path"], byname["segments.txt"]["bucket_path"]])
    buf = io.StringIO(); w = csv.writer(buf, lineterminator="\n"); w.writerow(HEADER); w.writerows(out_rows)
    new = buf.getvalue()
    out_csv = os.path.join(HERE, item_name + "_snapshot.csv")
    if os.path.exists(out_csv) and not args.force:
        old = open(out_csv, encoding="utf-8").read()
        if old != new:
            sys.exit(f"Frozen snapshot differs from the fresh extraction: {out_csv}\nNot overwritten. "
                     "Re-run with --force only after checking the sources and noting the change in the README.")
        print("Snapshot unchanged:", os.path.basename(out_csv), f"({len(out_rows)} rows, {len(patches)} patches)")
    else:
        open(out_csv, "w", encoding="utf-8", newline="").write(new)
        print("Wrote", os.path.basename(out_csv), f"({len(out_rows)} rows, {len(patches)} patches, area_dir {area})")
