#!/usr/bin/env python3
"""Python port of sleep_compiled.R — regenerates the sleep merge outputs without R.

Reads each source's harmonized TSV from ../__Public/comparative-data/ when it exists, otherwise
falls back to the source folder's <Item>.csv (identical content — the source .R writes both). This
lets the merge be rebuilt/verified before the official TSVs are generated. R (sleep_compiled.R) is
the canonical path and reads the TSVs only. Run from inside __merging_sleep:  python3 build_sleep_merge.py
"""
import csv, os

HERE = os.path.dirname(os.path.abspath(__file__))
BASE = os.path.normpath(os.path.join(HERE, ".."))
TSV  = os.path.join(BASE, "__Public", "comparative-data")

# source -> (encoded TSV basename, folder-CSV fallback path, team)
SRC = {
 "Eagleman_Vaughn_2021_TABLE1": ("10.3389%2Ffnins.2021.632853_TABLE1",
    "Eagleman_Vaughn_2021/Eagleman_Vaughn_2021_TABLE1.csv", "Eagleman_2021"),
 "HerculanoHouzel__2015_Table1": ("10.1098%2Frspb.2015.1853_Table1",
    "HerculanoHouzel__2015/HerculanoHouzel__2015_Table1.csv", "HerculanoHouzel_2015"),
 "Lyamin_etal_2008_Table2": ("10.1016%2Fj.neubiorev.2008.05.023_Table2",
    "Lyamin_etal_2008/Lyamin_etal_2008_Table2.csv", "Lyamin_2008"),
 "Ruf_Geiser_2015_Table1": ("10.1111%2Fbrv.12137_Table1",
    "Ruf_Geiser_2015/Ruf_Geiser_2015_Table1.csv", "RufGeiser_2015"),
}

def load(src):
    enc, csvrel, team = SRC[src]
    tsv = os.path.join(TSV, enc + ".tsv")
    if os.path.exists(tsv):
        with open(tsv, newline="", encoding="utf-8") as f:
            rows = [[c.strip('"') for c in r] for r in csv.reader(f, delimiter="\t")]
        hdr, body = rows[0], rows[1:]
        recs = [dict(zip(hdr, r)) for r in body]
        origin = "TSV"
    else:
        with open(os.path.join(BASE, csvrel), newline="", encoding="utf-8") as f:
            recs = list(csv.DictReader(f))
        origin = "folder-CSV (TSV not yet published)"
    return recs, team, origin

def num(v):
    if v is None: return None
    s = str(v).strip()
    if s in ("", "NA", "NaN", "nan", "None"): return None
    try: return float(s)
    except ValueError: return None

def fmt(f):
    if f is None: return None
    return str(int(f)) if f == int(f) else ("%g" % f)

# Eagleman common->binomial resolution (editable CSV)
res = {}
with open(os.path.join(HERE, "species_resolution_Eagleman.csv"), newline="", encoding="utf-8") as f:
    for row in csv.DictReader(f):
        res[row["Species_common"]] = (row["Species"], row["species_confidence"])
hh_alias = {"Loxodonta Africana": "Loxodonta africana"}
def ruf_clean(s):                         # strip subspecies parenthetical, trim
    return s.split("(")[0].strip()

# long rows: Species, Species_printed, Standardized_Term, Value, Units, source, team, ref, conf, dep
long, origins = [], {}
def add(sp, printed, term, val, units, src, team, conf, dep):
    if val is None or str(val).strip() in ("", "NA", "None"): return
    long.append([sp, printed, term, val, units, src, team, "Table", conf, dep])

# --- Eagleman -> REM_sleep_pct ---
recs, team, origins["Eagleman_Vaughn_2021_TABLE1"] = load("Eagleman_Vaughn_2021_TABLE1")
for r in recs:
    common = r["Species"]; b, conf = res.get(common, (common, "review"))
    add(b, common, "REM_sleep_pct", fmt(num(r.get("REM_sleep_percent"))), "percent",
        "Eagleman_Vaughn_2021_TABLE1", team, conf, "REM_pct")

# --- Herculano-Houzel -> Sleep_h_day ---
recs, team, origins["HerculanoHouzel__2015_Table1"] = load("HerculanoHouzel__2015_Table1")
for r in recs:
    sp = r["species"]; sp2 = hh_alias.get(sp, sp)
    add(sp2, sp, "Sleep_h_day", fmt(num(r.get("daily.sleep..h."))), "hours/day",
        "HerculanoHouzel__2015_Table1", team, "high", "dailysleep")

# --- Lyamin Table2 -> SWS_total_pct + USWS_pctTST (= low+high amp USWS) ---
recs, team, origins["Lyamin_etal_2008_Table2"] = load("Lyamin_etal_2008_Table2")
for r in recs:
    sp = r["species"]
    add(sp, sp, "SWS_total_pct", fmt(num(r.get("total_sws_pct"))), "percent of sleep",
        "Lyamin_etal_2008_Table2", team, "high", "SWS")
    lo, hi = num(r.get("low_amp_usws_pct_tst")), num(r.get("high_amp_usws_pct_tst"))
    usws = None if (lo is None and hi is None) else round((lo or 0) + (hi or 0), 3)
    add(sp, sp, "USWS_pctTST", fmt(usws), "percent of TST",
        "Lyamin_etal_2008_Table2", team, "high", "SWS")

# --- Ruf & Geiser -> torpor family ---
recs, team, origins["Ruf_Geiser_2015_Table1"] = load("Ruf_Geiser_2015_Table1")
for r in recs:
    sp0 = r["taxon"]; sp = ruf_clean(sp0)
    conf = "high" if sp == sp0 else "review"
    add(sp, sp0, "Torpor_type", (r.get("torpor_type") or "").strip() or None, "DT|HIB",
        "Ruf_Geiser_2015_Table1", team, conf, "torpor")
    add(sp, sp0, "Torpor_Tb_min_C", fmt(num(r.get("tb_min_c"))), "deg C",
        "Ruf_Geiser_2015_Table1", team, conf, "torpor")
    add(sp, sp0, "Torpor_bout_max_h", fmt(num(r.get("tbd_max_h"))), "hours",
        "Ruf_Geiser_2015_Table1", team, conf, "torpor")

with open(os.path.join(HERE, "sleep_long.csv"), "w", newline="") as f:
    w = csv.writer(f)
    w.writerow(["Species","Species_printed","Standardized_Term","Value","Units",
                "source","team","ref","species_confidence","dependency_group"])
    w.writerows(long)

# wide: one row per species, one column per standardized term
TERMS = ["REM_sleep_pct","Sleep_h_day","SWS_total_pct","USWS_pctTST",
         "Torpor_type","Torpor_Tb_min_C","Torpor_bout_max_h"]
by_sp = {}
for r in long:
    by_sp.setdefault(r[0], {})[r[2]] = r[3]
with open(os.path.join(HERE, "sleep_wide.csv"), "w", newline="") as f:
    w = csv.writer(f)
    w.writerow(["Species"] + TERMS + ["n_traits"])
    for sp in sorted(by_sp):
        vals = [by_sp[sp].get(t, "") for t in TERMS]
        w.writerow([sp] + vals + [sum(1 for v in vals if v != "")])

with open(os.path.join(HERE, "sleep_source_species_ids.csv"), "w", newline="") as f:
    w = csv.writer(f)
    w.writerow(["source","Species","Species_printed","Standardized_Term","Value","species_confidence"])
    for r in long:
        w.writerow([r[5], r[0], r[1], r[2], r[3], r[8]])

# report
from collections import Counter
tc = Counter(r[2] for r in long)
print("SOURCES READ FROM:")
for k, v in origins.items(): print(f"  {k}: {v}")
print(f"\nlong rows: {len(long)} | species: {len(by_sp)}")
for t in TERMS: print(f"  {t}: {tc.get(t,0)}")
