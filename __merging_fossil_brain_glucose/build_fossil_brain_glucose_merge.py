#!/usr/bin/env python3
# =====================================================================
# build_fossil_brain_glucose_merge.py
# ---------------------------------------------------------------------
# Compile fossil-hominin BRAIN GLUCOSE metabolism from three independent
# estimators into one merged dataset (long + wide + unfiltered), mirroring the
# other __merging_* pipelines. This is the tested builder that generated the
# shipped CSVs; the house-style R equivalent is fossil_brain_glucose_compiled.R
# (R was unavailable in the build environment -- same arrangement noted in
# __merging_cerebral_metabolic_rate/README__merging.md).
#
# MEASURE
#   BGU = whole-brain glucose utilization, umol glucose / min.
#
# ESTIMATORS ("teams"): each is a different rationale, not an independent
# measurement of the same quantity, so they are averaged only on the
# scope/convention-invariant RATIO to the modern human (see README).
#   Seymour_flow        carotid blood-flow, scaled from modern-human reference
#   Boyer_ACA_scaled    Boyer BGU~ACA+ECV; fossil ACA = carotid-ratio-scaled  [PRIMARY arterial]
#   Boyer_ACA_ecvpred   Boyer BGU~ACA+ECV; fossil ACA predicted from ECV       [UPPER BOUND -> unfiltered only]
#   s4_volume           Kochiyama regional volumes x Heiss rCMRGlc (6-region)  [brain-tissue, cortical+cerebellar scope]
#
# RESOLUTION
#   Merged consensus per specimen = mean Ratio_MH across the FILTERED teams
#   (Seymour_flow, Boyer_ACA_scaled, s4_volume). The ecvpred upper bound is kept
#   in *_unfiltered.csv only (analogous to the anesthesia filter in the CMR merge).
#   Consensus absolute = consensus Ratio_MH x 428.55 umol/min (whole-brain modern human).
#
# INPUTS (inputs/ ; staged copies for a self-contained build)
#   Boyer_Harrington_2018_Table2.csv   7-taxon BGU calibration
#   Boyer_Harrington_2018_Table1.csv   extant euarchontans (catarrhine ACA~ECV)
#   Seymour_etal_2017_TableS1.csv      30 fossil hominin specimens
#   s4_specimen_budgets.csv            s4 per-specimen volume budgets (8 specimens)
#
# OUTPUTS
#   fossil_brain_glucose_long.csv        one row per Specimen x Team (filtered)
#   fossil_brain_glucose_wide.csv        one row per Specimen (+ consensus)
#   fossil_brain_glucose_unfiltered.csv  all rows incl. the ecvpred upper bound
# =====================================================================
import os, numpy as np, pandas as pd

HERE = os.path.dirname(os.path.abspath(__file__))
IN   = os.path.join(HERE, "inputs")
rd   = lambda f: pd.read_csv(os.path.join(IN, f), comment="#")

# ---- constants / modern-human anchors -------------------------------
BGU_MODH = 428.55   # umol/min whole-brain glucose (Clarke & Sokoloff 1994 / Boyer Table 2)
ACA_HOMO = 159.81   # mm^2 Boyer Table 1 total ACA, Homo
Q_MODH   = 7.34     # cm^3/s total Q_ICA, Seymour AS8078
R_MODH   = 0.302    # cm carotid foramen radius, AS8078
ECV_MODH = 1493     # cc endocranial CAPACITY, AS8078
S4_MODH  = 328.51   # umol/min s4 modern-human 6-region budget (76.7% of whole brain)

# ---- 1. Boyer BGU calibration (log-log OLS + Duan smearing) ---------
def ols(y, *xs):
    X = np.column_stack([np.ones(len(y))] + list(xs))
    b, *_ = np.linalg.lstsq(X, y, rcond=None)
    return b, float(np.mean(np.exp(y - X @ b)))
cal = rd("Boyer_Harrington_2018_Table2.csv")
bf, smf = ols(np.log(cal.BGU_umol_min), np.log(cal.ACA_mm2), np.log(cal.ECV_cc))
boyer = lambda aca, ecv: np.exp(bf[0] + bf[1]*np.log(aca) + bf[2]*np.log(ecv)) * smf

# ---- 2. catarrhine ACA~ECV allometry (for ecvpred bound) ------------
t1 = rd("Boyer_Harrington_2018_Table1.csv")
for c in ("ACA_mm2", "ECV_cc"):
    t1[c] = pd.to_numeric(t1[c], errors="coerce")
t1 = t1.dropna(subset=["ACA_mm2", "ECV_cc"])
cat = t1[t1.Taxonomic_group.isin(["Hominoidea", "Cercopithecoidea"])]
bc, smc = ols(np.log(cat.ACA_mm2), np.log(cat.ECV_cc))
aca_from_ecv = lambda ecv: np.exp(bc[0] + bc[1]*np.log(ecv)) * smc
BGU_boyer_modH = float(boyer(ACA_HOMO, ECV_MODH))

# ---- 3. taxon-group tag ---------------------------------------------
def group_of(sp):
    s = sp.lower()
    if "neanderthal" in s: return "Neanderthal"
    if sp.startswith("H. sapiens"): return "H. sapiens (early/recent)"
    if any(k in s for k in ("erectus","heidelberg","rudolf","habilis","georgicus","naledi","floresiensis")):
        return "early Homo"
    if sp.startswith("A."): return "Australopithecus"
    return "other"

# ---- 3b. intra-species temporal grade -------------------------------
# Generic column: the within-species temporal/chronological level of a
# specimen, for taxa that have such levels. Only H. sapiens is graded in this
# dataset; extend GRADE_BY_SPECIMEN for other taxa as needed.
#   early            : early/fossil H. sapiens. The 4 Kochiyama EH fossils
#                      (Qafzeh 9, Skhul 5, Mladeč 1, Cro-Magnon 1) PLUS two
#                      other early H. sapiens carried by Seymour/Boyer that are
#                      NOT in Kochiyama's set: BC1 (Border Cave, ~80 ka) and
#                      LH 18 (Ngaloba, ~120 ka).
#   recent           : recent modern-human specimens (M3-A343, M4-A344 Bushmen).
#   modern_reference : the mean-modern-human anchor (AS8078; ratio_MH == 1.0).
#   NA               : no intra-species grade applies (Neanderthal, early Homo,
#                      Australopithecus, and any non-graded taxon).
GRADE_BY_SPECIMEN = {
    "Qafzeh 9": "early", "Skhul 5": "early", "Mladeč 1": "early",
    "Cro-Magnon 1": "early", "BC1": "early", "LH 18": "early",
    "M3-A343": "recent", "M4-A344": "recent",
    "AS8078": "modern_reference",
}
def grade_of(species, spec_key):
    return GRADE_BY_SPECIMEN.get(spec_key, "NA")

# ---- 4. arterial estimates (Seymour specimens) ----------------------
sey = rd("Seymour_etal_2017_TableS1.csv")
for c in ("Foramen_radius_cm","Total_QICA_cm3_s","Brain_volume_cm3"):
    sey[c] = pd.to_numeric(sey[c], errors="coerce")
sey["Group"]      = sey.Species.map(group_of)
sey["ACA_scaled"] = ACA_HOMO * (sey.Foramen_radius_cm / R_MODH)**2
sey["ACA_ecv"]    = aca_from_ecv(sey.Brain_volume_cm3)
sey["Seymour_flow"]      = BGU_MODH * sey.Total_QICA_cm3_s / Q_MODH
sey["Boyer_ACA_scaled"]  = boyer(sey.ACA_scaled, sey.Brain_volume_cm3)
sey["Boyer_ACA_ecvpred"] = boyer(sey.ACA_ecv,    sey.Brain_volume_cm3)
sey["r_Seymour_flow"]     = sey.Total_QICA_cm3_s / Q_MODH
sey["r_Boyer_ACA_scaled"] = sey.Boyer_ACA_scaled  / BGU_boyer_modH
sey["r_Boyer_ACA_ecvpred"]= sey.Boyer_ACA_ecvpred / BGU_boyer_modH

# ---- 5. s4 volume estimates (own specimen set) ----------------------
s4 = rd("s4_specimen_budgets.csv")
s4["budget_umol_min"] = pd.to_numeric(s4.budget_umol_min, errors="coerce")
s4["budget_ratio_MH"] = pd.to_numeric(s4.budget_ratio_MH, errors="coerce")

# Specimen crosswalk (Seymour label / s4 label -> canonical specimen key)
canon = {
    "Gibraltar (Forbes Quarry)": "Forbes' Quarry 1",
    "La Chapelle-aux-Saints":    "La Chapelle-aux-Saints 1",
    "Skhul 5":                   "Skhul 5",
}
sey["Specimen_key"] = sey.Specimen.map(lambda s: canon.get(s, s))
s4["Specimen_key"]  = s4.specimen

# per-team unit metadata
META = {
 "Seymour_flow":      dict(Scope="whole_brain",         Volume_basis="endocranial_capacity",
                           Source="Seymour_etal_2017",  filtered=True),
 "Boyer_ACA_scaled":  dict(Scope="whole_brain",         Volume_basis="endocranial_capacity",
                           Source="Boyer_Harrington_2018", filtered=True),
 "Boyer_ACA_ecvpred": dict(Scope="whole_brain",         Volume_basis="endocranial_capacity",
                           Source="Boyer_Harrington_2018", filtered=False),  # upper bound
 "s4_volume":         dict(Scope="cortical+cerebellar", Volume_basis="brain_tissue_GMWM",
                           Source="Kochiyama_2018 x Heiss_2004 (s4)", filtered=True),
}

# ---- 6. assemble LONG (one row per Specimen x Team) -----------------
rows = []
def add(spec_key, species, group, team, value, ratio):
    if not np.isfinite(value): return
    m = META[team]
    rows.append(dict(Specimen=spec_key, Species=species, Group=group,
                     sapiens_grade=grade_of(species, spec_key),
                     Measure="BGU", Units="umol/min",
                     Value=round(float(value),1), Ratio_MH=round(float(ratio),3),
                     Scope=m["Scope"], Volume_basis=m["Volume_basis"],
                     Team=team, Source=m["Source"], filtered=m["filtered"]))
for _, x in sey.iterrows():
    add(x.Specimen_key, x.Species, x.Group, "Seymour_flow",      x.Seymour_flow,      x.r_Seymour_flow)
    add(x.Specimen_key, x.Species, x.Group, "Boyer_ACA_scaled",  x.Boyer_ACA_scaled,  x.r_Boyer_ACA_scaled)
    add(x.Specimen_key, x.Species, x.Group, "Boyer_ACA_ecvpred", x.Boyer_ACA_ecvpred, x.r_Boyer_ACA_ecvpred)
# s4 specimens (map s4 group code -> group label and binomial)
s4grp     = {"NT":"Neanderthal","EH":"H. sapiens (early/recent)"}
s4species = {"NT":"Homo neanderthalensis","EH":"Homo sapiens"}
for _, x in s4.iterrows():
    gcode = str(x.get("group","")).strip()
    add(x.Specimen_key, s4species.get(gcode,""), s4grp.get(gcode,"other"),
        "s4_volume", x.budget_umol_min, x.budget_ratio_MH)

long_all = pd.DataFrame(rows)
long_filt = long_all[long_all.filtered].drop(columns=["filtered"])
long_all_out = long_all.drop(columns=["filtered"]).assign(
    note=np.where(long_all.Team=="Boyer_ACA_ecvpred","ECV-predicted ACA (upper bound; unfiltered only)",""))

# fill Species/Group for s4-only specimens from any arterial row of same key
key2sp = {r.Specimen:(r.Species,r.Group) for r in long_filt.itertuples() if r.Species}
def fillsp(df):
    for i,r in df.iterrows():
        if (not r.Species or pd.isna(r.Species)) and r.Specimen in key2sp:
            df.at[i,"Species"], df.at[i,"Group"] = key2sp[r.Specimen]
    return df
long_filt = fillsp(long_filt); long_all_out = fillsp(long_all_out)

long_filt.to_csv(os.path.join(HERE,"fossil_brain_glucose_long.csv"), index=False)
long_all_out.to_csv(os.path.join(HERE,"fossil_brain_glucose_unfiltered.csv"), index=False)

# ---- 7. WIDE (one row per Specimen) + consensus resolution ----------
specs = sorted(long_filt.Specimen.unique())
FILT_TEAMS = ["Seymour_flow","Boyer_ACA_scaled","s4_volume"]
wrows=[]
for k in specs:
    sub = long_filt[long_filt.Specimen==k]
    sp  = sub.Species.dropna().iloc[0] if sub.Species.notna().any() else ""
    gp  = sub.Group.dropna().iloc[0]   if sub.Group.notna().any()   else ""
    grd = sub.sapiens_grade.dropna().iloc[0] if sub.sapiens_grade.notna().any() else "NA"
    d = dict(Specimen=k, Species=sp, Group=gp, sapiens_grade=grd)
    ratios=[]; teams=[]
    for t in FILT_TEAMS:
        row = sub[sub.Team==t]
        if len(row):
            d[f"{t}__BGU"]      = row.Value.iloc[0]
            d[f"{t}__ratio_MH"] = row.Ratio_MH.iloc[0]
            ratios.append(row.Ratio_MH.iloc[0]); teams.append(t)
        else:
            d[f"{t}__BGU"]=np.nan; d[f"{t}__ratio_MH"]=np.nan
    d["n_teams"]        = len(teams)
    d["teams"]          = "; ".join(teams)
    d["consensus_ratio_MH"]   = round(float(np.mean(ratios)),3) if ratios else np.nan
    d["consensus_ratio_sd"]   = round(float(np.std(ratios,ddof=1)),3) if len(ratios)>1 else np.nan
    d["consensus_BGU_umol_min"]= round(float(np.mean(ratios))*BGU_MODH,1) if ratios else np.nan
    wrows.append(d)
wide = pd.DataFrame(wrows)
# order by consensus size, then group
wide = wide.sort_values(["consensus_ratio_MH"], ascending=False)
wide.to_csv(os.path.join(HERE,"fossil_brain_glucose_wide.csv"), index=False)

# ---- 8. console report ----------------------------------------------
print("Boyer calib: ln(BGU)=%.3f + %.3f lnACA + %.3f lnECV  (smear %.3f)"%(bf[0],bf[1],bf[2],smf))
print("modern-human anchors: whole-brain %.1f | Boyer-pred %.1f | s4 6-region %.1f (%.1f%%)"%(
    BGU_MODH,BGU_boyer_modH,S4_MODH,100*S4_MODH/BGU_MODH))
print("specimens (union) = %d | long rows (filtered) = %d | unfiltered = %d"%(
    wide.Specimen.nunique(), len(long_filt), len(long_all_out)))
print("\nconsensus (top rows):")
print(wide[["Specimen","Group","n_teams","consensus_ratio_MH","consensus_ratio_sd","consensus_BGU_umol_min"]]
      .head(12).to_string(index=False))
print("\noverlap (all 3 teams):")
ov = wide[wide.n_teams==3][["Specimen","Seymour_flow__ratio_MH","Boyer_ACA_scaled__ratio_MH","s4_volume__ratio_MH","consensus_ratio_MH"]]
print(ov.to_string(index=False))
