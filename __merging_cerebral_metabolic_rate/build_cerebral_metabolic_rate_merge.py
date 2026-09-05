#!/usr/bin/env python3
"""build_cerebral_metabolic_rate_merge.py -- the tested builder for the cerebral
metabolic-rate merge. House twin: cerebral_metabolic_rate_compiled.R (same
pipeline, tidyverse idiom). See README__merging.md.

Sources (all BRAIN-only; whole-body BMR lives in __merging_body_ecology):
  Heiss_etal_2004  PRIMARY    Homo sapiens regional CMRgl (PET)
  Kaufman__2004    SECONDARY  A1-A14, one row per primary study (+ anesthesia state)
  Karbowski__2007  SECONDARY  S1-S23, one row per primary reference

Two measure classes are emitted:
  cerebral_metabolic_rate / cerebral_perfusion
      MASS-SPECIFIC rates: CMRgl, CMRO2 (umol/100g/min), CBF (mL/100g/min).
      Compilation-aware: both compilations are pulled down to primary-study level
      and studies they share are deduped before averaging.
  cerebral_absolute_rate
      ABSOLUTE whole-brain totals as printed by Karbowski Tables S1/S2:
      Total_glucose_utilization (umol/min), Total_O2_consumption (mL/min).
      These are DERIVED quantities (Karbowski's own mass-specific rate x brain
      mass), reported only by Karbowski, and are NOT independent of the rates
      above -- they are a different measure class and must never be pooled with,
      or averaged against, the per-100 g rates. They are carried because absolute
      whole-brain glucose and oxygen use is the quantity that compares directly
      against whole-body metabolic rate (BMR) and against the fossil-hominin BGU
      estimates in __merging_fossil_brain_glucose (same unit, umol/min).
"""
import csv, glob, math, os, re, sys
from collections import defaultdict

# Order-independent mean. Naive float accumulation makes a cell mean depend on the
# order the study values happen to be visited, and a few cell means (e.g. Mus
# musculus whole-brain CMRgl = 73.2075) sit on a .0005 decimal boundary where that
# last-bit difference flips the 3rd decimal. math.fsum returns the exactly-rounded
# sum whatever the order, so the cell mean no longer depends on file-read order.
def mean(xs):
    return math.fsum(xs) / len(xs)


def round3(x):
    """Round to 3 dp, half away from zero, IDENTICALLY in R and Python.

    Neither language's native rounding will do. Python's round() rounds the stored
    double (73.2074999... -> 73.207); R's round() rounds the shortest decimal you
    would print (73.2075 -> 73.208). Both are defensible and they disagree on a few
    percent of multi-study means, so the twin builders would silently diverge.

    So the rule is written out explicitly and identically in both: format to 9 dp
    with C printf (both languages call the same libc routine), then round half-up at
    the 4th decimal using exact INTEGER arithmetic. The double-rounding window this
    leaves is 5e-10 wide -- six orders of magnitude below the 2-3 decimals the
    sources print -- and R/Python agreement was checked over 200,000 simulated
    multi-study means with zero disagreements. See cerebral_metabolic_rate_compiled.R,
    which carries the same function.
    """
    s = "%.9f" % x
    neg = s.startswith("-")
    i, f = s.lstrip("-").split(".")
    n = int(i) * 10**9 + int(f)              # exact integer of value * 1e9
    v = ((n + 500_000) // 1_000_000) / 1000.0
    return -v if neg else v

HERE = os.path.dirname(os.path.abspath(__file__))
BASE = os.path.dirname(HERE)

# ---- crosswalks -------------------------------------------------------------
REGION_CANON = {
    "Whole Brain (direct measurement)": "Whole_brain", "Brain": "Whole_brain",
    "Whole Brain": "Whole_brain",
    "Neocortex": "Neocortex", "Cerebral cortex": "Neocortex",
    "Cerebral cortex (global average)": "Neocortex", "Cortex": "Neocortex",
    "Frontal Cortex": "Frontal_cortex", "Frontal cortex": "Frontal_cortex",
    "Frontal lobe": "Frontal_cortex", "Prefrontal cortex": "Prefrontal_cortex",
    "Parietal Cortex": "Parietal_cortex", "Parietal cortex": "Parietal_cortex",
    "Parietal lobe": "Parietal_cortex",
    "Temporal Cortex": "Temporal_cortex", "Temporal cortex": "Temporal_cortex",
    "Temporal lobe": "Temporal_cortex",
    "Occipital Cortex": "Occipital_cortex", "Occipital cortex": "Occipital_cortex",
    "Occipital lobe": "Occipital_cortex",
    "Visual cortex": "Visual_cortex", "Auditory Cortex": "Auditory_cortex",
    "Sensorimotor Cortex": "Sensorimotor_cortex", "Sensorimotor cortex": "Sensorimotor_cortex",
    "Cingulate Cortex": "Cingulate_cortex", "Cingulate cortex": "Cingulate_cortex",
    "Insular lobe": "Insula",
    "Thalamus": "Thalamus", "Nucleus medial thalami": "Thalamus_medial_nucleus",
    "Hypothalamus": "Hypothalamus", "Hippocampus": "Hippocampus",
    "Amygdala": "Amygdala", "Corpus amygdaloideum": "Amygdala", "Septum": "Septum",
    "Basal Ganglia": "Basal_ganglia", "Caudate": "Caudate_nucleus",
    "Caudatum": "Caudate_nucleus", "Putamen": "Putamen",
    "Globus pallidus": "Pallidum", "Pallidum": "Pallidum",
    "Nucleus accumbens": "Nucleus_accumbens", "Substantia nigra": "Substantia_nigra",
    "Nucleus subthalamicus": "Nucleus_subthalamicus", "Nucleus ruber": "Nucleus_ruber",
    "Basal forebrain": "Basal_forebrain",
    "Corpus geniculatum laterale": "Corpus_geniculatum_laterale",
    "Corpus geniculatum mediale": "Corpus_geniculatum_mediale",
    "Colliculus superior": "Colliculus_superior",
    "Colliculus inferior": "Colliculus_inferior",
    "Cerebellum": "Cerebellum", "Cerebellar cortex": "Cerebellar_cortex",
    "Nucleus dentatus cerebelli": "Nucleus_dentatus_cerebelli", "Vermis": "Vermis",
    "Brain stem": "Brain_stem",
    "White Matter": "White_matter", "White matter": "White_matter",
    "Capsula interna": "Capsula_interna", "Centrum semiovale": "Centrum_semiovale",
}
VOLUME_TERM = {
    "Neocortex": "Neocortex_Vol.mm3", "Cerebellum": "Cerebellum_Vol.mm3",
    "Thalamus": "Thalamus_Vol.mm3", "Hippocampus": "Hippocampus_Vol.mm3",
    "Amygdala": "Amygdala_Vol.mm3", "Pallidum": "Pallidum_Vol.mm3",
    "Nucleus_subthalamicus": "Nucleus_subthalamicus_Vol.mm3",
    "Corpus_geniculatum_laterale": "Corpus_geniculatum_laterale_Vol.mm3",
    "Whole_brain": "Total_brain_net_volume_Vol.mm3",
}
SPECIES_CANON = {
    "Homo": "Homo sapiens", "M mulatta": "Macaca mulatta", "M fascic": "Macaca fascicularis",
    "Macaca": "Macaca sp.", "Papio": "Papio anubis", "Saimiri": "Saimiri sciureus",
    "Canis": "Canis lupus familiaris", "Felis": "Felis catus", "Rattus": "Rattus norvegicus",
    "Mus": "Mus musculus", "Meriones": "Meriones unguiculatus",
    "Gerbil": "Meriones unguiculatus", "Ovis": "Ovis aries",
    "Capra": "Capra aegagrus hircus", "Sus": "Sus scrofa", "Equus": "Equus caballus",
    "Lepus": "Lepus sp.",
}
# measure -> (unit, measure_class, scale applied to the printed value)
MEASURES = {
    "CMRgl": ("umol/100g/min", "cerebral_metabolic_rate", 1.0),
    "CMRO2": ("umol/100g/min", "cerebral_metabolic_rate", 1.0),
    "CBF":   ("mL/100g/min",   "cerebral_perfusion",      1.0),
    "Total_glucose_utilization": ("umol/min", "cerebral_absolute_rate", 1.0),
    "Total_O2_consumption":     ("mL/min",   "cerebral_absolute_rate", 1.0),
}
KAUF_GENUS_ASSIGNED = {"Homo", "Papio", "Canis", "Felis", "Rattus", "Mus", "Meriones",
                       "Gerbil", "Ovis", "Capra", "Sus", "Equus", "Lepus", "Saimiri"}
COMP_PRIORITY = {"Kaufman__2004": 0, "Heiss_etal_2004": 1, "Karbowski__2007": 2}

canon_species = lambda s: SPECIES_CANON.get(s, s)
canon_region = lambda s: REGION_CANON.get(s, s)
SURNAME_RX = re.compile(r"[A-Za-z\u00c0-\u017f']+")
YEAR_RX = re.compile(r"(1[89][0-9]{2}|20[0-9]{2})")


def ref_key(x):
    """first-author surname + year -> token, e.g. '(Baxter et al., 1987)' -> 'baxter1987'."""
    x = ("" if x is None else str(x)).strip()
    if "present study" in x.lower():
        return "kaufman2004_present"
    x2 = x.replace("(", "").replace(")", "").strip()
    yr = YEAR_RX.search(x2)
    sur = SURNAME_RX.search(x2)
    return (sur.group(0).lower() if sur else "anon") + (yr.group(0) if yr else "NA")


def ref_keys_multi(x):
    return [ref_key(p.strip()) for p in str(x).split(";")] if x not in (None, "") else []


def conscious_kauf(a):
    if a is None or str(a).strip() == "" or str(a).strip().lower() == "na":
        return "unknown"
    a = str(a).strip().lower()
    return "conscious" if (a.startswith("none") or "awake" in a) else "anesthetized"


def num(x):
    try:
        v = float(str(x).strip())
        return None if v != v else v
    except (TypeError, ValueError):
        return None


def rows_of(path):
    with open(path, newline="", encoding="utf-8-sig") as fh:
        return list(csv.DictReader(fh))


# ---- 1. load & normalise to primary-study level -----------------------------
U = []

kauf_files = sorted(p for p in glob.glob(os.path.join(BASE, "Kaufman__2004", "Kaufman__2004_TableA*.csv"))
                    if re.search(r"TableA([1-9]|1[0-4])\.csv$", p))
for f in kauf_files:
    table = re.search(r"TableA[0-9]+", os.path.basename(f)).group(0)
    for r in rows_of(f):
        printed = (r.get("Species") or "").strip()
        if not printed:
            continue
        genus = ("Macaca" if printed in ("M mulatta", "M fascic")
                 else "Meriones" if printed == "Gerbil" else printed.split()[0])
        species = canon_species(printed if printed in SPECIES_CANON else genus)
        reg_raw = (r.get("Region") or "").strip()
        for col, meas in (("CMRgl_umol_100g_min", "CMRgl"),
                          ("CMRO2_umol_100g_min", "CMRO2"),
                          ("CBF_ml_100g_min", "CBF")):
            v = num(r.get(col))
            if v is None:
                continue
            unit, mclass, _ = MEASURES[meas]
            U.append(dict(Compilation="Kaufman__2004", Species_printed=printed,
                          Species=species, genus=genus, Region_raw=reg_raw,
                          Region=canon_region(reg_raw), Measure=meas, measure_class=mclass,
                          Value=v, SD=None, n=num(r.get("n")),
                          conscious=conscious_kauf(r.get("Anesthesia")),
                          ref_raw=r.get("Reference") or "",
                          ref_keys=[ref_key(r.get("Reference"))], Units=unit, Table=table))

karb_files = sorted(glob.glob(os.path.join(BASE, "Karbowski__2007", "Karbowski__2007_TableS*.csv")))
karb_files = [p for p in karb_files if re.search(r"TableS[0-9]+\.csv$", p)]
for f in karb_files:
    table = re.search(r"TableS[0-9]+", os.path.basename(f)).group(0)
    for r in rows_of(f):
        if str(r.get("is_average", "")).strip().upper() == "TRUE":
            continue          # Karbowski's own per-species means are dropped
        meas = (r.get("measure") or "").strip()
        if meas not in MEASURES:
            continue
        v = num(r.get("value"))
        if v is None:
            continue
        unit, mclass, _ = MEASURES[meas]
        # Karbowski prints mass-specific rates PER GRAM -> per 100 g project standard.
        # The absolute totals (umol/min, mL/min) are already whole-brain: no scaling.
        scale = 100.0 if mclass in ("cerebral_metabolic_rate", "cerebral_perfusion") else 1.0
        sd = num(r.get("sd"))
        species = canon_species((r.get("species") or "").strip())
        reg_raw = (r.get("structure") or "").strip()
        U.append(dict(Compilation="Karbowski__2007",
                      Species_printed=(r.get("species_printed") or "").strip(),
                      Species=species, genus=species.split()[0] if species else "",
                      Region_raw=reg_raw, Region=canon_region(reg_raw),
                      Measure=meas, measure_class=mclass, Value=v * scale,
                      SD=None if sd is None else sd * scale, n=None, conscious="unknown",
                      ref_raw=r.get("reference") or "",
                      ref_keys=ref_keys_multi(r.get("reference")), Units=unit, Table=table))

for r in rows_of(os.path.join(BASE, "Heiss_etal_2004", "Heiss_etal_2004_TABLE1.csv")):
    v = num(r.get("Both hemispheres Mean"))
    if v is None:
        continue
    reg_raw = (r.get("Region") or "").strip()
    U.append(dict(Compilation="Heiss_etal_2004", Species_printed="Homo sapiens",
                  Species="Homo sapiens", genus="Homo", Region_raw=reg_raw,
                  Region=canon_region(reg_raw), Measure="CMRgl",
                  measure_class="cerebral_metabolic_rate", Value=v,
                  SD=num(r.get("Both hemispheres SD")), n=None, conscious="conscious",
                  ref_raw="Heiss et al 2004", ref_keys=["heiss2004"],
                  Units="umol/100g/min", Table="TABLE1"))

for u in U:
    u["ref_keys_str"] = ";".join(k for k in u["ref_keys"] if k)

blank = lambda v: "" if v is None else (repr(v) if isinstance(v, str) else
                                        ("%g" % v if v == v else ""))

# ---- 2. unfiltered long table (full provenance) -----------------------------
UF_COLS = ["Species", "Species_printed", "Compilation", "Table", "Region", "Region_raw",
           "Measure", "measure_class", "Value", "SD", "n", "Units", "conscious",
           "ref_raw", "ref_keys_str"]
uf = sorted(U, key=lambda u: (u["Measure"], u["Species"], u["Region"], u["Compilation"]))
with open(os.path.join(HERE, "cerebral_metabolic_rate_unfiltered.csv"), "w", newline="",
          encoding="utf-8") as fh:
    w = csv.DictWriter(fh, fieldnames=UF_COLS, extrasaction="ignore")
    w.writeheader()
    for u in uf:
        w.writerow({c: ("" if u.get(c) is None else u[c]) for c in UF_COLS})

# ---- 3. filter: drop explicitly anesthetized (Kaufman's conscious-only rule) -
F = [u for u in U if u["conscious"] != "anesthetized"]

# ---- 4. compilation-aware dedupe of shared primary studies ------------------
by_cell_ref = defaultdict(list)
for i, u in enumerate(F):
    for k in u["ref_keys"]:
        if k:
            by_cell_ref[(u["Species"], u["Region"], u["Measure"], k)].append(i)
drop, report = set(), []
for (sp, reg, meas, k), idx in by_cell_ref.items():
    comps = {F[i]["Compilation"] for i in idx}
    if len(comps) < 2:
        continue
    keep_comp = min(comps, key=lambda c: COMP_PRIORITY.get(c, 99))
    dropped = sorted(c for c in comps if c != keep_comp)
    for i in idx:
        if F[i]["Compilation"] != keep_comp:
            drop.add(i)
    report.append(dict(Species=sp, Region=reg, Measure=meas, shared_ref=k,
                       reported_by="; ".join(sorted(comps)), kept=keep_comp,
                       dropped="; ".join(dropped)))
report.sort(key=lambda r: (r["Species"], r["Region"], r["Measure"]))
with open(os.path.join(HERE, "cerebral_metabolic_rate_dedupe_report.csv"), "w", newline="",
          encoding="utf-8") as fh:
    w = csv.DictWriter(fh, fieldnames=["Species", "Region", "Measure", "shared_ref",
                                       "reported_by", "kept", "dropped"])
    w.writeheader()
    w.writerows(report)
D = [u for i, u in enumerate(F) if i not in drop]

# ---- 5. aggregate: study-mean, then mean across distinct studies ------------
study = defaultdict(lambda: {"vals": [], "comps": set()})
for u in D:
    sid = u["ref_keys_str"] or f"{u['Compilation']}:{u['Table']}"
    s = study[(u["Species"], u["Region"], u["Measure"], u["Units"], u["measure_class"], sid)]
    s["vals"].append(u["Value"])
    s["comps"].add(u["Compilation"])
cells = defaultdict(lambda: {"vals": [], "sids": set(), "comps": set()})
for (sp, reg, meas, unit, mclass, sid), s in study.items():
    c = cells[(sp, reg, meas, unit, mclass)]
    c["vals"].append(mean(s["vals"]))
    c["sids"].add(sid)
    c["comps"] |= s["comps"]
merged = [dict(Species=sp, Region=reg, Measure=meas, measure_class=mclass, Units=unit,
               Value=round3(mean(c["vals"])), n_studies=len(c["sids"]),
               Compilations="; ".join(sorted(c["comps"])),
               Volume_term=VOLUME_TERM.get(reg, ""))
          for (sp, reg, meas, unit, mclass), c in cells.items()]
merged.sort(key=lambda m: (m["Species"], m["Region"], m["Measure"]))
LONG_COLS = ["Species", "Region", "Measure", "measure_class", "Units", "Value",
             "n_studies", "Compilations", "Volume_term"]
with open(os.path.join(HERE, "cerebral_metabolic_rate_long.csv"), "w", newline="",
          encoding="utf-8") as fh:
    w = csv.DictWriter(fh, fieldnames=LONG_COLS)
    w.writeheader()
    w.writerows(merged)

# ---- 6. wide ----------------------------------------------------------------
cols, wide = [], defaultdict(dict)
for m in merged:
    col = f"{m['Region']}__{m['Measure']}"
    if col not in cols:
        cols.append(col)
    wide[m["Species"]][col] = m["Value"]
with open(os.path.join(HERE, "cerebral_metabolic_rate_wide.csv"), "w", newline="",
          encoding="utf-8") as fh:
    w = csv.writer(fh)
    w.writerow(["Species"] + cols)
    for sp in sorted(wide):
        w.writerow([sp] + [wide[sp].get(c, "NA") for c in cols])

# ---- 7. species id / crosswalk ---------------------------------------------
sid_rows = defaultdict(lambda: {"comps": set(), "n": 0})
for u in U:
    s = sid_rows[(u["Species"], u["Species_printed"])]
    s["comps"].add(u["Compilation"])
    s["n"] += 1
with open(os.path.join(HERE, "cerebral_metabolic_rate_source_species_ids.csv"), "w",
          newline="", encoding="utf-8") as fh:
    w = csv.writer(fh)
    w.writerow(["Species", "Species_printed", "Compilations", "n_rows", "note"])
    for (sp, pr) in sorted(sid_rows):
        s = sid_rows[(sp, pr)]
        note = ("Kaufman genus label; binomial assigned by standard-lab-species convention"
                if pr in KAUF_GENUS_ASSIGNED else
                "generic Macaca kept as Macaca sp." if pr == "Macaca" else "")
        w.writerow([sp, pr, "; ".join(sorted(s["comps"])), s["n"], note])

n_sp = len({m["Species"] for m in merged})
n_reg = len({m["Region"] for m in merged})
print(f"{len(merged)} merged cells | {n_sp} species | {n_reg} regions", file=sys.stderr)
for mc in sorted({m["measure_class"] for m in merged}):
    sub = [m for m in merged if m["measure_class"] == mc]
    print(f"  {mc}: {len(sub)} cells, {len({m['Species'] for m in sub})} species,"
          f" measures {sorted({m['Measure'] for m in sub})}", file=sys.stderr)
