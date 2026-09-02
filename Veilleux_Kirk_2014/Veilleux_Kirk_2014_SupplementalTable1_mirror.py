#!/usr/bin/env python3
"""Offline Python mirror of Veilleux_Kirk_2014_SupplementalTable1.R (no R in the build
sandbox). Regenerated 2026-08-31 during the folder streamline: the original mirror had been
removed before an R run could verify it, breaking the documented chain. Running this script
must reproduce the committed CSV + public TSV byte-for-byte (it did on regeneration -- see
README). DELETE once an RStudio run of the .R verifies the same."""
import csv, io, os, re

HERE = os.path.dirname(os.path.abspath(__file__))
BASE = os.path.dirname(HERE)
item = "Veilleux_Kirk_2014_SupplementalTable1"

snap = list(csv.DictReader(open(os.path.join(HERE, item + "_snapshot.csv"), encoding="utf-8")))
assert len(snap) == 91

def squish(s): return re.sub(r"\s+", " ", (s or "").strip())
def num(s):
    s = (s or "").strip()
    return None if s in ("", "NA") else float(s)
def g15(x):  # R numeric printing (up to 15 significant digits)
    return "%.15g" % x

rows = []
for r in snap:
    src_va = squish(r["src_VA"])
    cone = bool(re.search(r"\]2$", src_va))
    src_va = re.sub(r"2$", "", src_va)
    src_adbm = squish(r["src_AD_BM"])
    rmf = "**" in src_adbm
    src_adbm = src_adbm.replace("**", "")
    bm = num(r["BM"])
    rows.append({
        "Order_VK2014": r["Order"], "Species_VK2014": r["Species"],
        "eye_axial_diameter_mm": num(r["AD"]),
        "ad_estimated_from_RMF": "TRUE" if rmf else "FALSE",
        "visual_acuity_cdeg": num(r["VA"]),
        "va_cone_density_footnote2": "TRUE" if cone else "FALSE",
        "body_mass_kg_VK": bm, "Body_mass.g": None if bm is None else bm * 1000,
        "measurement_type": r["MT"] or "", "max_running_speed_kph": num(r["MRS"]),
        "activity_pattern": r["AP"] or "", "diet": r["D1"] or "",
        "va_this_study": "TRUE" if src_va.startswith("this study") else "FALSE",
        "src_VA": src_va, "src_AD_BM": src_adbm,
        "src_D_AP": squish(r["src_D_AP"]), "src_MRS": squish(r["src_MRS"]),
    })

NUMCOLS = {"eye_axial_diameter_mm","visual_acuity_cdeg","body_mass_kg_VK","Body_mass.g","max_running_speed_kph"}
HDR = ["Order_VK2014","Species_VK2014","eye_axial_diameter_mm","ad_estimated_from_RMF",
 "visual_acuity_cdeg","va_cone_density_footnote2","body_mass_kg_VK","Body_mass.g",
 "measurement_type","max_running_speed_kph","activity_pattern","diet","va_this_study",
 "src_VA","src_AD_BM","src_D_AP","src_MRS"]

def cell(col, v):
    if col in NUMCOLS:
        return "" if v is None else g15(v)          # write.csv(..., na = "")
    return '"%s"' % str(v).replace('"', '""')       # character columns quoted

def render(sep):
    out = io.StringIO()
    out.write(sep.join('"%s"' % h for h in HDR) + "\n")
    for r in rows:
        out.write(sep.join(cell(c, r[c]) for c in HDR) + "\n")
    return out.getvalue()

targets = [(os.path.join(HERE, item + ".csv"), ","),
           (os.path.join(BASE, "__Public", "comparative-data",
                         "10.1159%2F000357830_SupplementalTable1.tsv"), "\t")]
for path, sep in targets:
    new = render(sep)
    old = open(path, encoding="utf-8").read() if os.path.exists(path) else None
    print(("IDENTICAL " if old == new else "DIFFERS   ") + os.path.basename(path))
    if old != new:
        open(path + ".mirror_regen", "w", encoding="utf-8", newline="").write(new)
