#!/usr/bin/env python3
"""Offline Python mirror for Kirk_Kay_2004_Table1.R / Table2.R (no R in the build sandbox).
Generates the committed analysis CSVs + public TSVs from the frozen snapshots, byte-identically
to what the .R scripts must reproduce. DELETE THIS FILE once an RStudio run verifies the .R
outputs match (house policy, cf. Veilleux_Kirk_2014 README)."""
import csv, os, re

HERE = os.path.dirname(os.path.abspath(__file__))
BASE = os.path.dirname(HERE)
EN = "–"
CROSS = {  # printed scientific name -> (binomial, basis) ; only deviations, per VK crosswalk style
 "Camelus bactrius":   ("Camelus bactrianus", "printed misspelling"),
 "Zalophus californicus": ("Zalophus californianus", "older/incorrect ending as printed"),
 "Eumetopias jubata":  ("Eumetopias jubatus", "older form as printed"),
 "Sciurus caroliniensis": ("Sciurus carolinensis", "printed misspelling (same form as VK2014)"),
 "Amblonyx cinerea":   ("Aonyx cinereus", "genus/gender change; Bath compilation used Aonyx cinerea"),
 "Rhinolophus rouxi":  ("Rhinolophus rouxii", "orthographic variant as printed"),
 "Rousettus sp.":      ("Rousettus sp.", "genus-level as printed"),
 "Saccopteryx sp.":    ("Saccopteryx sp.", "genus-level as printed"),
 "Eptesicus sp.":      ("Eptesicus sp.", "genus-level as printed"),
}
def binom(printed): return CROSS.get(printed, (printed, "as printed"))[0]

def segments(va):
    """'1.6–2.5 (air); 2.5–3.8 (water)' -> [(min,max,substrate,segment_as_printed)]"""
    out=[]
    for seg in [s.strip() for s in va.split(";")]:
        m=re.match(r'^([\d.]+)(?:'+EN+r'([\d.]+))?\s*(?:\((air and water|air|water)\))?$', seg)
        assert m, va
        lo=float(m.group(1)); hi=float(m.group(2)) if m.group(2) else lo
        sub=m.group(3) or "air (unspecified; per table notes)"
        out.append((lo,hi,sub,seg))
    return out

HDR=["Species_KK2004","common_name_KK2004","binomial","activity_pattern","method","substrate",
     "va_cdeg_min","va_cdeg_max","va_as_printed","source_as_printed","source"]
def fmt(v):
    if isinstance(v,float): return "%.15g"%v
    return '"%s"'%str(v).replace('"','""')

for tab, method, enc in (("Table1","behavioral","10.1007%2F978-1-4419-8873-7_20_Table1"),
                         ("Table2","anatomical (eye/retina morphology)","10.1007%2F978-1-4419-8873-7_20_Table2")):
    item=f"Kirk_Kay_2004_{tab}"
    snap=list(csv.DictReader(open(os.path.join(HERE,f"{item}_snapshot.csv"),encoding="utf-8")))
    rows=[]
    for r in snap:
        for lo,hi,sub,seg in segments(r["visual_acuity_cdeg_as_printed"]):
            rows.append([r["scientific_name"],r["common_name"],binom(r["scientific_name"]),
                         r["activity_pattern"],method,sub,lo,hi,r["visual_acuity_cdeg_as_printed"],
                         r["source_as_printed"],item])
    for path,sep in [(os.path.join(HERE,f"{item}.csv"),","),
                     (os.path.join(BASE,"__Public","comparative-data",enc+".tsv"),"\t")]:
        with open(path,"w",newline="",encoding="utf-8") as f:
            f.write(sep.join('"%s"'%h for h in HDR)+"\n")
            for rr in rows: f.write(sep.join(fmt(v) for v in rr)+"\n")
    print(f"{item}: {len(snap)} species -> {len(rows)} substrate rows")
