#!/usr/bin/env python3
"""Offline mirror of Ashwell__2020_SupplementaryTable.R.

The .R file is CANONICAL. This mirror exists only so the outputs can be regenerated in an
environment without R; it reproduces R's write.csv/write.table conventions (character values
and column names quoted, numerics bare, NA unquoted, %.15g float formatting, no scientific
notation). If the two ever disagree, the .R file wins and this file is the bug.

Reads  : Ashwell__2020_SupplementaryTable_snapshot.xlsx   (frozen, faithful to the print)
Writes : Ashwell__2020_SupplementaryTable.csv
         Ashwell__2020_published_mean_reconciliation.csv
         ../__Public/comparative-data/<Item encoded>.tsv
"""
import os
import re
import statistics
import zipfile

FOLDER = os.path.dirname(os.path.abspath(__file__))
ITEM = "Ashwell__2020_SupplementaryTable"
SNAPSHOT = os.path.join(FOLDER, ITEM + "_snapshot.xlsx")

CLEAN_NAMES = [
    "group", "species", "common_name", "brain_volume_mm3", "total_cb_volume_mm3",
    "vermis_excl_cb10_mm3", "hemisphere_excl_fl_mm3", "flocculo_nodular_cb_cx_mm3",
    "ratio_hemisph_vermis", "total_cb_cx_volume_mm3", "cb_white_matter_mm3",
    "pn_rttg_volume_mm3", "deep_cb_nu_volume_mm3", "cb_ext_surface_esa_mm2",
    "cb_pial_surface_psa_mm2", "foliation_index",
]
NUMERIC_COLS = CLEAN_NAMES[3:16]


# ---- minimal xlsx reader (openpyxl chokes on these hand-edited workbooks) ------------------
def read_sheet(path, sheet=1):
    z = zipfile.ZipFile(path)
    shared = []
    if "xl/sharedStrings.xml" in z.namelist():
        sx = z.read("xl/sharedStrings.xml").decode("utf-8")
        shared = [re.sub(r"<[^>]+>", "", m) for m in re.findall(r"<si>(.*?)</si>", sx, re.S)]
    xml = z.read("xl/worksheets/sheet%d.xml" % sheet).decode("utf-8")
    out = []
    for _, body in re.findall(r'<row[^>]*r="(\d+)"[^>]*>(.*?)</row>', xml, re.S):
        cells = {}
        for m in re.finditer(r'<c r="([A-Z]+)\d+"([^>]*?)(?:/>|>(.*?)</c>)', body, re.S):
            col, attrs, inner = m.group(1), m.group(2), m.group(3) or ""
            t = re.search(r't="([^"]+)"', attrs)
            v = re.search(r"<v>(.*?)</v>", inner, re.S)
            if t and t.group(1) == "s" and v:
                val = shared[int(v.group(1))]
            elif t and t.group(1) == "inlineStr":
                val = re.sub(r"<[^>]+>", "", inner)
            else:
                val = v.group(1) if v else ""
            cells[col] = val.strip()
        out.append(cells)
    return out


def col_letter(i):
    s = ""
    while True:
        s = chr(65 + i % 26) + s
        i = i // 26 - 1
        if i < 0:
            return s


rows = read_sheet(SNAPSHOT)
header = [rows[0].get(col_letter(i), "") for i in range(len(CLEAN_NAMES))]
assert len(header) == len(CLEAN_NAMES), header
raw = []
for r in rows[1:]:
    rec = {name: r.get(col_letter(i), "") for i, name in enumerate(CLEAN_NAMES)}
    if rec["species"].strip():                                   # trailing all-blank row
        raw.append(rec)
n_in = len(raw)


def num(x):
    x = str(x).replace(",", "").strip()
    if x == "":
        return None
    try:
        return float(x)
    except ValueError:
        return None


# ---- split the printed summary rows away from the observations ------------------------------
SUMMARY = re.compile(r"\s+(mean|SD)$")
printed, dat = [], []
for r in raw:
    (printed if SUMMARY.search(r["species"]) else dat).append(r)
for r in printed:
    r["stat"] = SUMMARY.search(r["species"]).group(1)
    for c in NUMERIC_COLS:
        r[c] = num(r[c])

# ---- observations: keep every printed specimen row ------------------------------------------
clean = []
for r in dat:
    pub = re.sub(r"\s+", " ", r["species"]).strip()
    m = re.search(r"\s(\d+)$", pub)
    rec = {
        "group": r["group"],
        "species": re.sub(r"\s+\d+$", "", pub).strip(),
        "common_name": r["common_name"],
        "species_as_published": pub,
        "specimen_number": int(m.group(1)) if m else None,
        "row_type": "species" if m is None else "specimen",
        "n_specimen_rows": None,
    }
    for c in NUMERIC_COLS:
        rec[c] = num(r[c])
    rec["source"] = "Ashwell__2020"
    clean.append(rec)

counts = {}
for r in clean:
    counts[r["species"]] = counts.get(r["species"], 0) + 1
for r in clean:
    r["n_specimen_rows"] = counts[r["species"]]
clean.sort(key=lambda r: (r["group"], r["species"], r["specimen_number"] or 0))

# Guards mirroring the stopifnot() block in the .R file.
assert len(clean) == n_in - len(printed), (len(clean), n_in, len(printed))
keys = [(r["species"], r["specimen_number"]) for r in clean]
assert len(keys) == len(set(keys)), "duplicate species x specimen_number"
assert sum(1 for r in clean if r["row_type"] == "specimen") == 6
assert {"Ornithorhynchus anatinus", "Tachyglossus aculeatus"} <= {
    r["species"] for r in clean if r["n_specimen_rows"] == 3}

COLS = (["group", "species", "common_name", "species_as_published", "specimen_number",
         "row_type", "n_specimen_rows"] + NUMERIC_COLS + ["source"])
CHAR = {"group", "species", "common_name", "species_as_published", "row_type", "source"}


def fmt(v, name):
    if v is None or v == "":
        return "NA"
    if v in ("TRUE", "FALSE"):          # R writes logicals unquoted
        return v
    if name in CHAR:
        return '"%s"' % str(v).replace('"', '""')
    if isinstance(v, int):
        return str(v)
    return "%.15g" % float(v)


def write_table(path, cols, records, sep=","):
    with open(path, "w", encoding="utf-8", newline="") as f:
        f.write(sep.join('"%s"' % c for c in cols) + "\n")
        for r in records:
            f.write(sep.join(fmt(r.get(c), c) for c in cols) + "\n")


write_table(os.path.join(FOLDER, ITEM + ".csv"), COLS, clean)
print("Ashwell: %d snapshot rows -> %d observation rows across %d species "
      "(%d per-specimen rows kept; %d printed mean/SD rows moved to the reconciliation file)"
      % (n_in, len(clean), len(counts),
         sum(1 for r in clean if r["row_type"] == "specimen"), len(printed)))

# ---- reconciliation: Ashwell's printed mean/SD vs the specimen rows -------------------------
recomputed = {}
for sp, n in counts.items():
    if n < 2:
        continue
    block = [r for r in clean if r["species"] == sp]
    cn = block[0]["common_name"]
    for c in NUMERIC_COLS:
        vals = [r[c] for r in block if r[c] is not None]
        recomputed[(cn, c, "mean")] = (sp, n, statistics.fmean(vals) if vals else None)
        recomputed[(cn, c, "SD")] = (
            sp, n, statistics.stdev(vals) if len(vals) > 1 else None)


def n_sig(x):
    s = ("%.15g" % abs(x)).replace(".", "").lstrip("0")
    return max(1, len(s.rstrip("0")))


def signif(x, d):
    if x == 0:
        return 0.0
    from math import floor, log10
    return round(x, -int(floor(log10(abs(x)))) + (d - 1))


recon = []
seen = set()
for r in printed:
    for c in NUMERIC_COLS:
        key = (r["common_name"], c, r["stat"])
        seen.add(key)
        sp, n, rec = recomputed.get(key, (None, None, None))
        p = r[c]
        pct = (100 * (p - rec) / rec) if (p is not None and rec not in (None, 0)) else None
        agrees = (p is not None and rec is not None
                  and abs(p - signif(rec, n_sig(p))) < 1e-9)
        recon.append({"species": sp, "common_name": r["common_name"], "variable": c,
                      "stat": r["stat"], "n_specimens": n, "printed": p,
                      "recomputed": rec, "pct_diff": pct,
                      "agrees_at_printed_precision": "TRUE" if agrees else "FALSE"})
for key, (sp, n, rec) in recomputed.items():          # full_join: recomputed with no printed row
    if key not in seen:
        recon.append({"species": sp, "common_name": key[0], "variable": key[1], "stat": key[2],
                      "n_specimens": n, "printed": None, "recomputed": rec, "pct_diff": None,
                      "agrees_at_printed_precision": "FALSE"})
recon.sort(key=lambda r: (r["species"] or "", r["variable"], r["stat"]))

RCOLS = ["species", "common_name", "variable", "stat", "n_specimens", "printed",
         "recomputed", "pct_diff", "agrees_at_printed_precision"]
CHAR |= {"variable", "stat"}
write_table(os.path.join(FOLDER, "Ashwell__2020_published_mean_reconciliation.csv"),
            RCOLS, recon)
bad = [r for r in recon if r["pct_diff"] is not None and abs(r["pct_diff"]) > 1]
print("Reconciliation: %d printed-vs-recomputed comparisons; %d differ by >1%% %s"
      % (len(recon), len(bad),
         "(" + ", ".join(sorted({r["variable"] for r in bad})) + ")" if bad else ""))

# ---- public TSV ----------------------------------------------------------------------------
base = FOLDER
while os.path.dirname(base) != base and not os.path.exists(os.path.join(base, "__ReadMe.xlsx")):
    base = os.path.dirname(base)
tsv_dir = os.path.join(base, "__Public", "comparative-data")
enc = None
if os.path.isdir(tsv_dir):
    for f in os.listdir(tsv_dir):
        if f.endswith("_SupplementaryTable.tsv") and "zool.2020.125753" in f:
            enc = f[:-4]
if enc is None:
    print("WARNING: could not resolve the encoded TSV name; TSV skipped.")
else:
    p = os.path.join(tsv_dir, enc + ".tsv")
    write_table(p, COLS, clean, sep="\t")
    print("Wrote " + p)
