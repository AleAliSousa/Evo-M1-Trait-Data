#!/usr/bin/env python3
"""Offline mirror of Bauernfeind_etal_2013_reconcile_to_Table3.R (the .R is canonical)."""
import csv, os, statistics

F = "/sessions/practical-tender-fermat/mnt/Evo-M1-Trait-Data/Bauernfeind_etal_2013"
SUBDIV = [("Granular", "granular"), ("Dysgranular", "dysgranular"),
          ("Agranular", "agranular"), ("FI", "FI"), ("Total", "total_insula")]


def rd(n):
    return list(csv.DictReader(open(os.path.join(F, n), encoding="utf-8")))


def num(x):
    try:
        return float(x)
    except (TypeError, ValueError):
        return None


t1, t2, t3 = (rd("Bauernfeind_etal_2013_Table1.csv"), rd("Bauernfeind_etal_2013_Table2.csv"),
              rd("Bauernfeind_etal_2013_Table3.csv"))

ind = []
for d, side, hemi in ((t1, "L", "left"), (t2, "R", "right")):
    for r in d:
        for label, stem in SUBDIV:
            v = num(r.get("%s_%s_mm3" % (stem, side)))
            if v is not None:
                ind.append((r["Species"], hemi, label, r["Individual"], v))

rec = {}
for sp, hemi, sub, who, v in ind:
    rec.setdefault((sp, hemi, sub), []).append((who, v))

recon = []
for r in t3:
    key = (r["Species"], r["hemisphere"], r["subdivision"])
    blk = rec.get(key, [])
    vals = [v for _, v in blk]
    pm, ps, pn = num(r["mean_mm3"]), num(r["sd_mm3"]), int(r["n"])
    m = statistics.fmean(vals) if vals else None
    sd = statistics.stdev(vals) if len(vals) > 1 else None
    recon.append({
        "Species": r["Species"], "hemisphere": r["hemisphere"], "subdivision": r["subdivision"],
        "published_n": pn, "n_individuals": len(vals),
        "n_agrees": "TRUE" if pn == len(vals) else "FALSE",
        "published_mean": pm, "mean_recomputed": m,
        "mean_pct_diff": (100 * (pm - m) / m) if (pm is not None and m) else None,
        "published_sd": ps, "sd_recomputed": sd,
        "sd_pct_diff": (100 * (ps - sd) / sd) if (ps is not None and sd) else None,
        "individuals_used": "; ".join(sorted(w for w, _ in blk))})
order = {s: i for i, (s, _) in enumerate(SUBDIV)}
recon.sort(key=lambda r: (r["Species"], r["hemisphere"], order[r["subdivision"]]))

RCOLS = ["Species", "hemisphere", "subdivision", "published_n", "n_individuals", "n_agrees",
         "published_mean", "mean_recomputed", "mean_pct_diff", "published_sd",
         "sd_recomputed", "sd_pct_diff", "individuals_used"]
CHAR = {"Species", "hemisphere", "subdivision", "individuals_used", "Individual",
        "Collection", "measurement_software", "sides_measured"}


def fmt(v, name):
    if v is None or v == "" or v == "NA":
        return "NA"
    if v in ("TRUE", "FALSE"):
        return v
    if name in CHAR:
        return '"%s"' % str(v).replace('"', '""')
    return "%.15g" % float(v)


def wt(path, cols, recs, sep=","):
    with open(path, "w", encoding="utf-8", newline="") as f:
        f.write(sep.join('"%s"' % c for c in cols) + "\n")
        for r in recs:
            f.write(sep.join(fmt(r.get(c), c) for c in cols) + "\n")


wt(os.path.join(F, "Bauernfeind_etal_2013_Table3_reconciliation.csv"), RCOLS, recon)
assert all(r["n_agrees"] == "TRUE" for r in recon), \
    [r for r in recon if r["n_agrees"] != "TRUE"]
mx = max(abs(r["mean_pct_diff"]) for r in recon if r["mean_pct_diff"] is not None)
print("Table 3 reconciliation: %d comparisons, %d with matching n, max |mean diff| = %.2f%%"
      % (len(recon), sum(1 for r in recon if r["n_agrees"] == "TRUE"), mx))

# ---- bilateral individuals ----
t2i = {(r["Species"], r["Individual"]): r for r in t2}
bil = []
for r in t1:
    k = (r["Species"], r["Individual"])
    o = t2i.get(k, {})
    L = num(r.get("total_insula_L_mm3")); R = num(o.get("total_insula_R_mm3"))
    both = L is not None and R is not None
    rec2 = {"Species": r["Species"], "Individual": r["Individual"],
            "Collection": r["Collection"],
            "measurement_software": r["measurement_software"],
            "sides_measured": "both" if both else ("left only" if L is not None else
                                                   ("right only" if R is not None else "neither")),
            "total_insula_L_mm3": L, "total_insula_R_mm3": R,
            "total_insula_LR_mm3": (L + R) if both else None,
            "asymmetry_pct_total": (100 * (L - R) / (L + R)) if both else None}
    for label, stem in SUBDIV[:4]:
        a, b = num(r.get("%s_L_mm3" % stem)), num(o.get("%s_R_mm3" % stem))
        rec2["%s_LR_mm3" % stem] = (a + b) if (a is not None and b is not None) else None
    bil.append(rec2)
for k, o in t2i.items():                      # right-only individuals absent from Table 1
    if not any(b["Species"] == k[0] and b["Individual"] == k[1] for b in bil):
        bil.append({"Species": k[0], "Individual": k[1], "Collection": None,
                    "measurement_software": None, "sides_measured": "right only",
                    "total_insula_R_mm3": num(o.get("total_insula_R_mm3"))})
bil.sort(key=lambda r: (r["Species"], r["Individual"]))
BCOLS = ["Species", "Individual", "Collection", "measurement_software", "sides_measured",
         "total_insula_L_mm3", "total_insula_R_mm3", "total_insula_LR_mm3",
         "asymmetry_pct_total", "granular_LR_mm3", "dysgranular_LR_mm3",
         "agranular_LR_mm3", "FI_LR_mm3"]
wt(os.path.join(F, "Bauernfeind_etal_2013_bilateral_individuals.csv"), BCOLS, bil)
import collections
c = collections.Counter(r["sides_measured"] for r in bil)
print("Bilateral: %d of %d individuals measured on both sides (%d left only, %d right only) "
      "across %d species" % (c["both"], len(bil), c["left only"], c["right only"],
                             len({r["Species"] for r in bil if r["sides_measured"] == "both"})))
print("\nboth-hemisphere individuals:")
for r in bil:
    if r["sides_measured"] == "both":
        print("   %-18s %-14s L=%-7.0f R=%-7.0f L+R=%-7.0f asym=%+.1f%%  [%s]"
              % (r["Species"], r["Individual"], r["total_insula_L_mm3"],
                 r["total_insula_R_mm3"], r["total_insula_LR_mm3"],
                 r["asymmetry_pct_total"], r["measurement_software"]))
