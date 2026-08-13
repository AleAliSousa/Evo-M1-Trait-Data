#!/usr/bin/env python3
"""Offline mirror of the four new comparison/*.R checking scripts.

There is no R in the sandbox, so the .R files stay canonical and this mirror
reproduces their logic to generate the *_from_R.csv outputs and to verify the
counts. Output formatting follows readr::write_csv (NA as "NA", TRUE/FALSE,
minimal quoting, %.15g floats).
"""
import math
import re
import warnings

import pandas as pd

warnings.filterwarnings("ignore")

ROOT = "/sessions/upbeat-kind-archimedes/mnt/Evo-M1-Trait-Data"

NA_TOKENS = {"", "-", "–", "—", "NA", "n.a.", "_", "__", "nan", "None"}


def num(x):
    if x is None:
        return float("nan")
    s = str(x).strip()
    if s in NA_TOKENS:
        return float("nan")
    m = re.search(r"-?\d*\.?\d+(?:[eE][-+]?\d+)?", s.replace(",", ""))
    return float(m.group()) if m else float("nan")


def txt(x):
    if x is None:
        return None
    s = str(x).strip()
    return None if s in NA_TOKENS else s


def dp_of(s):
    if s is None or "." not in s:
        return 0
    m = re.search(r"\.(\d+)", s)
    return len(m.group(1)) if m else 0


def isna(v):
    return v is None or (isinstance(v, float) and math.isnan(v))


def rounds_to(a, b_txt):
    """TRUE when full-precision `a` rounds to the printed value `b_txt`.

    None (R: NA) when the reference is blank but the comparison file has a value:
    nothing to check against, and the value is a candidate gap-filler.
    """
    b = num(b_txt) if b_txt is not None else float("nan")
    d = dp_of(b_txt) if b_txt is not None else 0
    if isna(a) and isna(b):
        return True
    if isna(a):
        return False
    if isna(b):
        return None
    return abs(a - b) <= 0.5 * 10 ** (-d) + 1e-9


def close_to(a, b, tol):
    if isna(a) and isna(b):
        return True
    if isna(a) or isna(b):
        return False
    return abs(a - b) <= tol


def rel_equal(a, b, tol=1e-6):
    if isna(a) and isna(b):
        return True
    if isna(a) or isna(b):
        return False
    return abs(a - b) <= tol * max(1.0, abs(a), abs(b))


def key(x):
    return re.sub(r"\s+", " ", str(x).replace("_", " ").strip().lower())


# ------------------------------------------------------------- csv writing --
def fmt(v):
    if isinstance(v, bool):
        return "TRUE" if v else "FALSE"
    if v is None:
        return "NA"
    if isinstance(v, float):
        if math.isnan(v):
            return "NA"
        return "%.15g" % v
    if isinstance(v, int):
        return str(v)
    s = str(v)
    if s == "nan" or s == "":
        return "NA" if s == "nan" else ""
    if any(c in s for c in ',"\n'):
        return '"' + s.replace('"', '""') + '"'
    return s


def write_csv(rows, cols, path):
    with open(path, "w", newline="\n") as fh:
        fh.write(",".join(fmt(c) for c in cols) + "\n")
        for r in rows:
            fh.write(",".join(fmt(r.get(c)) for c in cols) + "\n")
    print(f"  wrote {path.split('/')[-1]}  ({len(rows)} rows)")


def read_ref_csv(path):
    """Reference CSVs are read as text so printed precision is preserved."""
    d = pd.read_csv(path, dtype=str, keep_default_na=False, na_values=[])
    return [{k: txt(v) for k, v in rec.items()} for rec in d.to_dict("records")]


def read_sheet(path, sheet, names, skip=0):
    d = pd.read_excel(path, sheet_name=sheet, header=None, dtype=str)
    d = d.iloc[skip:, : len(names)]
    d.columns = names
    return [{k: txt(v) for k, v in rec.items()} for rec in d.to_dict("records")]


# ============================================================ 1. de Sousa ====
def desousa():
    print("de Sousa et al. 2010  <-  Visual_volumes.xlsx")
    base = f"{ROOT}/deSousa_etal_2010"
    comp = f"{base}/comparison"
    canon_map = {
        "sanguinus midas": "saguinus midas",
        "sanguinus oedipus": "saguinus oedipus",
        "pithecus monachus": "pithecia monachus",
        "cercopithecus mitus": "cercopithecus mitis",
        "lagothix lagathricha": "lagothrix lagotricha",
        "lagothix lagothricha": "lagothrix lagotricha",
        "lagothrix lagothricha": "lagothrix lagotricha",
        "loris tardigradius": "loris tardigradus",
        "cebuella pygmaea": "callithrix pygmaea",
        "procolobus badius": "piliocolobus badius",
        "callicebus moloch": "plecturocebus moloch",
        "syndactylus symphalangus": "symphalangus syndactylus",
    }

    def canon(x):
        k = key(x)
        return canon_map.get(k, k)

    measures = ["brain", "neo", "V1", "LGN"]
    pos1 = ["category", "species_file", "brain_cm3", "neo_cm3", "V1_cm3", "LGN_cm3",
            "brain_mm3", "neo_mm3", "V1_mm3", "LGN_mm3"]
    pos2 = ["code", "species_file", "brain_s2", "neo_s2", "V1_s2", "LGN_s2"]
    f = f"{comp}/Visual_volumes.xlsx"
    s1 = [r for r in read_sheet(f, "Sheet1", pos1, skip=2) if r["species_file"]]
    s2 = [r for r in read_sheet(f, "Sheet2", pos2, skip=2) if r["species_file"]]

    vv = []
    for i, r in enumerate(s1):
        o = {"row_id": i + 1, "category": r["category"], "species_file": r["species_file"],
             "species_key": canon(r["species_file"])}
        for c in pos1[2:]:
            o[c] = num(r[c])
        b = s2[i] if i < len(s2) else {}
        o["species_s2"] = b.get("species_file")
        for c in pos2[2:]:
            o[c] = num(b.get(c))
        vv.append(o)

    # (A) internal
    internal, icols = [], ["row_id", "category", "species_file", "species_s2",
                           "species_rows_aligned", "n_internal_problem"]
    for m in measures:
        icols += [f"{m}_cm3", f"{m}_mm3", f"{m}_s2",
                  f"{m}_mm3_eq_cm3x1000", f"{m}_sheet1_eq_sheet2"]
    for r in vv:
        o = {k: r[k] for k in ("row_id", "category", "species_file", "species_s2")}
        bad = 0
        for m in measures:
            a = rel_equal(r[f"{m}_mm3"], r[f"{m}_cm3"] * 1000)
            b = rel_equal(r[f"{m}_mm3"], r[f"{m}_s2"])
            o[f"{m}_cm3"], o[f"{m}_mm3"], o[f"{m}_s2"] = r[f"{m}_cm3"], r[f"{m}_mm3"], r[f"{m}_s2"]
            o[f"{m}_mm3_eq_cm3x1000"], o[f"{m}_sheet1_eq_sheet2"] = a, b
            bad += (not a) + (not b)
        o["species_rows_aligned"] = key(r["species_file"]) == key(r["species_s2"] or "")
        o["n_internal_problem"] = bad
        internal.append(o)
    write_csv(internal, icols,
              f"{comp}/deSousa_etal_2010_Visual_volumes_internal_check_from_R.csv")

    # (B) vs Supp. Table 2
    sup = read_ref_csv(f"{base}/deSousa_etal_2010_SupTable2.csv")
    sup_keyed = {}
    for r in sup:
        r["_corr"] = "neocortex value corrected" in (r.get("correction") or "")
        sup_keyed.setdefault(canon(r["species"]), r)
    for r in sup:
        k = canon(r.get("species_as_published") or "")
        if k and k not in sup_keyed:
            sup_keyed[k] = r
    supcol = {"brain": "brain_volume_cm3", "neo": "neocortex_volume_cm3",
              "V1": "V1_area_striata_volume_cm3", "LGN": "LGN_volume_cm3"}

    repB, seen = [], set()
    for r in vv:
        if r["category"] not in ("Simians", "Prosimians"):
            continue
        s = sup_keyed.get(r["species_key"])
        if s:
            seen.add(id(s))
        o = {"join_key": r["species_key"], "category": r["category"],
             "species_file": r["species_file"],
             "species_sup": s["species"] if s else None,
             "species_as_published": s["species_as_published"] if s else None,
             "neocortex_was_corrected": s["_corr"] if s else None}
        n_bad, n_corr = 0, 0
        for m in measures:
            o[f"{m}_vv"] = r[f"{m}_cm3"]
            o[f"{m}_sup"] = num(s[supcol[m]]) if s and s[supcol[m]] else float("nan")
            ok = rounds_to(r[f"{m}_cm3"], s[supcol[m]]) if s else None
            o[f"{m}_match"] = ok
            if m == "neo" and s and s["_corr"] and ok is False:
                o["neo_match"], o["neo_expected_correction"], n_corr = None, True, 1
            elif ok is False:
                n_bad += 1
        o.setdefault("neo_expected_correction", False)
        o["status"] = "matched_by_species" if s else "comparison_only_not_in_SupTable2"
        o["n_measure_mismatch"], o["n_expected_correction"] = n_bad, n_corr
        repB.append(o)
    for s in sup:
        if id(s) not in seen:
            o = {"join_key": canon(s["species"]), "species_sup": s["species"],
                 "species_as_published": s["species_as_published"],
                 "neocortex_was_corrected": s["_corr"],
                 "status": "SupTable2_only_not_in_comparison",
                 "n_measure_mismatch": 0, "n_expected_correction": 0,
                 "neo_expected_correction": False}
            for m in measures:
                o[f"{m}_sup"] = num(s[supcol[m]]) if s[supcol[m]] else float("nan")
            repB.append(o)
    for r in vv:
        if r["category"] in ("Simians", "Prosimians"):
            continue
        o = {"join_key": r["species_key"], "category": r["category"],
             "species_file": r["species_file"],
             "status": "outside_deSousa_2010 (Stephan/Frahm rows in the comparison file)",
             "n_measure_mismatch": 0, "n_expected_correction": 0}
        for m in measures:
            o[f"{m}_vv"] = r[f"{m}_cm3"]
        repB.append(o)
    repB.sort(key=lambda o: (o["status"], o["join_key"]))
    bcols = ["status", "join_key", "category", "species_file", "species_sup",
             "n_measure_mismatch", "n_expected_correction", "species_as_published",
             "neocortex_was_corrected", "neo_expected_correction"]
    for m in measures:
        bcols += [f"{m}_vv", f"{m}_sup", f"{m}_match"]
    write_csv(repB, bcols,
              f"{comp}/deSousa_etal_2010_Visual_volumes_vs_SupTable2_report_from_R.csv")

    # (C) vs V1LGN
    v1l = read_ref_csv(f"{base}/deSousa_etal_2010_V1LGN.csv")
    v1k = {canon(r["species"]): r for r in v1l}
    refcol = {"V1": "V1_area_striata_grey_mm3", "LGN": "LGN_mm3", "brain": "brain_volume_mm3"}
    repC, seenc = [], set()
    for r in vv:
        if r["category"] not in ("Simians", "Prosimians"):
            continue          # V1LGN is a primate compilation
        s = v1k.get(r["species_key"])
        if s:
            seenc.add(r["species_key"])
        o = {"join_key": r["species_key"], "category": r["category"],
             "species_file": r["species_file"],
             "species_v1lgn": s["species"] if s else None}
        n_bad = 0
        for m in refcol:
            o[f"{m}_vv_mm3"] = r[f"{m}_mm3"]
            o[f"{m}_ref"] = num(s[refcol[m]]) if s and s[refcol[m]] else float("nan")
            ok = rounds_to(r[f"{m}_mm3"], s[refcol[m]]) if s else None
            o[f"{m}_match"] = ok
            n_bad += ok is False
        o["status"] = "matched_by_species" if s else "comparison_only_not_in_V1LGN"
        o["n_measure_mismatch"] = n_bad
        repC.append(o)
    for k2, s in v1k.items():
        if k2 not in seenc:
            o = {"join_key": k2, "species_v1lgn": s["species"],
                 "status": "V1LGN_only_not_in_comparison", "n_measure_mismatch": 0}
            for m in refcol:
                o[f"{m}_ref"] = num(s[refcol[m]]) if s[refcol[m]] else float("nan")
            repC.append(o)
    repC.sort(key=lambda o: (o["status"], o["join_key"]))
    ccols = ["status", "join_key", "category", "species_file", "species_v1lgn",
             "n_measure_mismatch"]
    for m in refcol:
        ccols += [f"{m}_vv_mm3", f"{m}_ref", f"{m}_match"]
    write_csv(repC, ccols,
              f"{comp}/deSousa_etal_2010_Visual_volumes_vs_V1LGN_report_from_R.csv")

    mis = []
    for o in internal:
        if o["n_internal_problem"] > 0 or not o["species_rows_aligned"]:
            mis.append({"check": "internal_units_Sheet1_vs_Sheet2", "key": o["species_file"],
                        "detail": f"row {o['row_id']}; {o['n_internal_problem']} unit/alignment problem(s)"})
    for o in repB:
        if o["status"].startswith("outside_deSousa_2010"):
            continue
        if o["status"] != "matched_by_species" or o["n_measure_mismatch"] > 0:
            mis.append({"check": "vs_SupTable2", "key": o["join_key"],
                        "detail": f"{o['status']}; {o['n_measure_mismatch']} value mismatch(es)"})
    for o in repC:
        if o["status"] != "matched_by_species" or o["n_measure_mismatch"] > 0:
            mis.append({"check": "vs_V1LGN", "key": o["join_key"],
                        "detail": f"{o['status']}; {o['n_measure_mismatch']} value mismatch(es)"})
    write_csv(mis, ["check", "key", "detail"],
              f"{comp}/deSousa_etal_2010_Visual_volumes_mismatches_from_R.csv")

    print(f"  rows {len(vv)} | internal problems {sum(o['n_internal_problem'] > 0 for o in internal)}"
          f" | SupTable2 matched {sum(o['status'] == 'matched_by_species' for o in repB)},"
          f" mismatches {sum(o['status'] == 'matched_by_species' and o['n_measure_mismatch'] > 0 for o in repB)},"
          f" expected corrections {sum(o.get('n_expected_correction') or 0 for o in repB)}"
          f" | V1LGN matched {sum(o['status'] == 'matched_by_species' for o in repC)},"
          f" mismatches {sum(o['status'] == 'matched_by_species' and o['n_measure_mismatch'] > 0 for o in repC)}")
    return repB, repC, internal


# ========================================================= 2. Bauernfeind ====
def bauernfeind():
    print("Bauernfeind et al. 2013  <-  insulaAmy.xls")
    base = f"{ROOT}/Bauernfeind_etal_2013"
    comp = f"{base}/comparison"
    canon_map = {"pongo abelli": "pongo abelii", "varecia variegatus": "varecia variegata",
                 "cebuella pygmaea": "callithrix pygmaea",
                 "procolobus badius": "piliocolobus badius"}

    def canon(x):
        return canon_map.get(key(x), key(x))

    pos = ["species_file", "brain_mass_g", "hemisphere", "total_cm3", "doubled_cm3"]
    raw = read_sheet(f"{comp}/insulaAmy.xls", "Sheet1", pos)
    raw = [r for r in raw if not (r["hemisphere"] and r["hemisphere"].lower().startswith("hemisphere"))]

    recs, cur = [], None
    for r in raw:
        if r["species_file"]:
            cur = {"species_file": r["species_file"], "brain_mass_g": num(r["brain_mass_g"]),
                   "doubled_cm3": num(r["doubled_cm3"]), "left_cm3": float("nan"),
                   "right_cm3": float("nan"), "n_hemispheres_listed": 0}
            recs.append(cur)
        if cur is None:
            continue
        h = (r["hemisphere"] or "").strip().lower()
        if h.startswith("l"):
            cur["n_hemispheres_listed"] += 1
            if not isna(num(r["total_cm3"])):
                cur["left_cm3"] = num(r["total_cm3"])
        elif h.startswith("r"):
            cur["n_hemispheres_listed"] += 1
            if not isna(num(r["total_cm3"])):
                cur["right_cm3"] = num(r["total_cm3"])
    for i, c in enumerate(recs, 1):
        c["record_id"] = i
        c["species_key"] = canon(c["species_file"])
        c["left_mm3"] = c["left_cm3"] * 1000
        c["right_mm3"] = c["right_cm3"] * 1000
        if not isna(c["left_cm3"]) and not isna(c["right_cm3"]):
            c["doubling_basis"], c["doubled_expected"] = "L+R", c["left_cm3"] + c["right_cm3"]
        elif not isna(c["left_cm3"]):
            c["doubling_basis"], c["doubled_expected"] = "2 x left", 2 * c["left_cm3"]
        elif not isna(c["right_cm3"]):
            c["doubling_basis"] = "2 x right (left not measured)"
            c["doubled_expected"] = 2 * c["right_cm3"]
        else:
            c["doubling_basis"], c["doubled_expected"] = None, float("nan")
        c["doubling_ok"] = close_to(c["doubled_cm3"], c["doubled_expected"], 1e-6)

    tab1 = []
    for i, r in enumerate(read_ref_csv(f"{base}/Bauernfeind_etal_2013_Table1.csv")):
        if not r.get("Species"):
            continue
        tab1.append({"idx": i, "individual": r["Individual"], "collection": r["Collection"],
                     "species_csv": r["Species"], "species_key": canon(r["Species"]),
                     "brain_mass_g_csv": num(r["brain_mass_mg"]) / 1000,
                     "total_insula_L_mm3": num(r["total_insula_L_mm3"])})

    matched, uc, us = [], set(), set()
    for c in recs:                       # stage 1: species + brain mass
        for t in tab1:
            if t["idx"] in us or c["record_id"] in uc:
                continue
            if t["species_key"] == c["species_key"] and close_to(c["brain_mass_g"], t["brain_mass_g_csv"], 0.05):
                m = dict(c, **t); m["match_basis"] = "species + brain mass"
                matched.append(m); uc.add(c["record_id"]); us.add(t["idx"]); break
    lc = [c for c in recs if c["record_id"] not in uc]
    ls = [t for t in tab1 if t["idx"] not in us]
    by_c, by_s = {}, {}
    for c in sorted(lc, key=lambda z: (z["species_key"], -(z["brain_mass_g"] if not isna(z["brain_mass_g"]) else -1))):
        by_c.setdefault(c["species_key"], []).append(c)
    for t in sorted(ls, key=lambda z: (z["species_key"], -(z["brain_mass_g_csv"] if not isna(z["brain_mass_g_csv"]) else -1))):
        by_s.setdefault(t["species_key"], []).append(t)
    m2c, m2s = set(), set()
    for k2, cs in by_c.items():
        for c, t in zip(cs, by_s.get(k2, [])):
            m = dict(c, **t); m["match_basis"] = "species + brain-mass rank (approximate)"
            matched.append(m); m2c.add(c["record_id"]); m2s.add(t["idx"])

    rep = []
    for m in matched:
        m["status"] = "matched"; rep.append(m)
    for c in lc:
        if c["record_id"] not in m2c:
            rep.append(dict(c, status="comparison_only_not_in_Table1"))
    for t in ls:
        if t["idx"] not in m2s:
            rep.append(dict(t, status="Table1_only_not_in_comparison"))
    for o in rep:
        lm, tm = o.get("left_mm3", float("nan")), o.get("total_insula_L_mm3", float("nan"))
        o["left_diff_mm3"] = lm - tm if not (isna(lm) or isna(tm)) else float("nan")
        o["left_match"] = close_to(lm, tm, 1.0) if o["status"] == "matched" else None
        o["brain_mass_match"] = (close_to(o.get("brain_mass_g"), o.get("brain_mass_g_csv"), 0.05)
                                 if o["status"] == "matched" else None)
    rep.sort(key=lambda o: (o["status"], o.get("species_key") or "",
                            -(o.get("brain_mass_g") if not isna(o.get("brain_mass_g")) else -1)))
    cols = ["status", "match_basis", "species_key", "species_file", "species_csv", "individual",
            "brain_mass_g", "brain_mass_g_csv", "brain_mass_match",
            "left_mm3", "total_insula_L_mm3", "left_diff_mm3", "left_match",
            "right_mm3", "doubling_basis", "doubled_cm3", "doubled_expected", "doubling_ok",
            "collection", "n_hemispheres_listed", "record_id"]
    write_csv(rep, cols, f"{comp}/Bauernfeind_etal_2013_insulaAmy_individual_report_from_R.csv")

    sheet2 = [r for r in read_sheet(f"{comp}/insulaAmy.xls", "Sheet2",
                                    ["species_file", "insula_cm3"])
              if r["species_file"] and key(r["species_file"]) != "species"]
    s2m = {canon(r["species_file"]): (r["species_file"], num(r["insula_cm3"])) for r in sheet2}
    s1m = {}
    for c in recs:
        s1m.setdefault(c["species_key"], []).append(c)
    csm = {}
    for t in tab1:
        csm.setdefault(t["species_key"], []).append(t)

    gm = {}
    for c in recs:
        gm.setdefault(c["species_key"].split(" ")[0], []).append(c)

    sp = []
    for k2 in sorted(set(s2m) | set(s1m) | set(csm)):
        cs, ts = s1m.get(k2, []), csm.get(k2, [])
        gs = gm.get(k2.split(" ")[0], [])
        d = [c["doubled_cm3"] for c in cs if not isna(c["doubled_cm3"])]
        gd = [c["doubled_cm3"] for c in gs if not isna(c["doubled_cm3"])]
        lv = [2 * t["total_insula_L_mm3"] for t in ts if not isna(t["total_insula_L_mm3"])]
        bases = "; ".join(sorted({c["doubling_basis"] for c in cs if c["doubling_basis"]}))
        o = {"species_key": k2, "sheet2_species": s2m.get(k2, (None, None))[0],
             "n_individuals_cmp": len(cs) or None, "n_individuals_csv": len(ts) or None,
             "sheet2_insula_cm3": s2m.get(k2, (None, float("nan")))[1],
             "sheet1_mean_doubled_cm3": sum(d) / len(d) if d else float("nan"),
             "genus_mean_doubled_cm3": sum(gd) / len(gd) if gd else float("nan"),
             "n_individuals_genus": len(gs) or None,
             "congeners": " + ".join(sorted({c["species_key"] for c in gs})) or None,
             "csv_mean_2x_left_cm3": (sum(lv) / len(lv)) / 1000 if lv else float("nan"),
             "doubling_bases": bases or None}
        o["sheet2_eq_sheet1_mean"] = close_to(o["sheet2_insula_cm3"], o["sheet1_mean_doubled_cm3"], 1e-6)
        o["sheet2_eq_genus_mean"] = close_to(o["sheet2_insula_cm3"], o["genus_mean_doubled_cm3"], 1e-6)
        o["sheet2_basis"] = (None if isna(o["sheet2_insula_cm3"]) else
                             "species mean of the doubled values" if o["sheet2_eq_sheet1_mean"] else
                             f"GENUS-POOLED (sensu lato) mean over {o['congeners']}"
                             if o["sheet2_eq_genus_mean"] else
                             "unresolved - neither the species nor the genus mean")
        o["sheet2_vs_csv_diff_cm3"] = (o["sheet2_insula_cm3"] - o["csv_mean_2x_left_cm3"]
                                       if not (isna(o["sheet2_insula_cm3"]) or isna(o["csv_mean_2x_left_cm3"]))
                                       else float("nan"))
        o["note"] = ("in Table1 only (not in the comparison file)"
                     if isna(o["sheet2_insula_cm3"]) and not cs
                     else "no Sheet2 digest row for this species" if isna(o["sheet2_insula_cm3"])
                     else "in comparison file only" if isna(o["csv_mean_2x_left_cm3"])
                     else "digest label is broader than the species - do not read as a species mean"
                     if not o["sheet2_eq_sheet1_mean"]
                     else "expected offset: digest doubles as L+R, merge convention doubles the left"
                     if "L+R" in (bases or "") else "same doubling basis")
        sp.append(o)
    spcols = ["species_key", "sheet2_species", "n_individuals_cmp", "n_individuals_csv",
              "sheet2_insula_cm3", "sheet1_mean_doubled_cm3", "sheet2_eq_sheet1_mean",
              "sheet2_basis", "csv_mean_2x_left_cm3", "sheet2_vs_csv_diff_cm3",
              "doubling_bases", "note", "genus_mean_doubled_cm3", "sheet2_eq_genus_mean",
              "n_individuals_genus", "congeners"]
    write_csv(sp, spcols, f"{comp}/Bauernfeind_etal_2013_insulaAmy_species_report_from_R.csv")

    mis = []
    for o in rep:
        if (o["status"] != "matched" or o["left_match"] is False
                or o.get("doubling_ok") is False or o["brain_mass_match"] is False):
            d = o["status"]
            if o["left_match"] is False:
                d += f"; left insula {round(o['left_mm3'], 1)} vs {o['total_insula_L_mm3']} mm3"
            if o.get("doubling_ok") is False:
                d += "; doubling not reproduced"
            mis.append({"check": "individual",
                        "key": o.get("species_key") or o.get("species_csv"), "detail": d})
    for o in sp:
        if o["sheet2_eq_sheet1_mean"] is False and not isna(o["sheet2_insula_cm3"]):
            mis.append({"check": "species_digest", "key": o["species_key"],
                        "detail": "Sheet2 value is not the species mean of the Sheet1 "
                                  f"doubled values; {o['sheet2_basis']}"})
    write_csv(mis, ["check", "key", "detail"],
              f"{comp}/Bauernfeind_etal_2013_insulaAmy_mismatches_from_R.csv")

    print(f"  comparison individuals {len(recs)} | Table1 individuals {len(tab1)}"
          f" | matched {sum(o['status'] == 'matched' for o in rep)}"
          f" (by mass {sum(o.get('match_basis') == 'species + brain mass' for o in rep)})"
          f" | left mismatches {sum(o['left_match'] is False for o in rep)}"
          f" | comparison-only {sum(o['status'] == 'comparison_only_not_in_Table1' for o in rep)}"
          f" | Table1-only {sum(o['status'] == 'Table1_only_not_in_comparison' for o in rep)}")
    return rep, sp


# ============================================================= 3. MacLeod ====
def macleod():
    print("MacLeod et al. 2003  <-  cerebellumMacLeod.xlsx")
    base = f"{ROOT}/MacLeod_etal_2003"
    comp = f"{base}/comparison"
    measures = ["brain", "cerebellum", "vermis", "hemisphere"]
    pos = ["species_file", "brain_cmp", "cerebellum_cmp", "vermis_cmp", "hemisphere_cmp"]
    f = f"{comp}/cerebellumMacLeod.xlsx"

    cmp = []
    for r in read_sheet(f, "specimens", pos):
        if not r["species_file"] or key(r["species_file"]) == "species":
            continue
        o = {"cmp_row": len(cmp) + 1, "species_file": r["species_file"],
             "species_key": key(r["species_file"])}
        for c in pos[1:]:
            o[c] = num(r[c])
        o["sig"] = "|".join("NA" if isna(o[f"{m}_cmp"]) else "%.1f" % round(o[f"{m}_cmp"], 1)
                            for m in measures)
        cmp.append(o)

    def read_tab(path, tbl):
        out = []
        for r in read_ref_csv(path):
            if not r.get("species"):
                continue
            o = {"table": tbl, "species_csv": r["species"], "species_key": key(r["species"]),
                 "specimen": r["specimen"], "sample": r["sample"]}
            for m, c in zip(measures, ["brain_volume_cm3", "cerebellum_volume_cm3",
                                       "vermis_volume_cm3", "hemisphere_volume_cm3"]):
                o[f"{m}_csv_txt"] = r[c]
                o[f"{m}_csv"] = num(r[c])
            o["sig"] = "|".join("NA" if isna(o[f"{m}_csv"]) else "%.1f" % round(o[f"{m}_csv"], 1)
                                for m in measures)
            out.append(o)
        return out

    csv = read_tab(f"{base}/MacLeod_etal_2003_Table2.csv", "Table2") + \
        read_tab(f"{base}/MacLeod_etal_2003_Table1.csv", "Table1")
    for i, o in enumerate(csv, 1):
        o["csv_row"] = i

    vp, uc, us = {}, set(), set()      # greedy one-to-one value match
    for c in cmp:
        for s in csv:
            if s["csv_row"] in us:
                continue
            if s["species_key"] == c["species_key"] and s["sig"] == c["sig"]:
                vp[c["cmp_row"]] = s
                uc.add(c["cmp_row"]); us.add(s["csv_row"]); break

    rep = []
    for i in range(max(len(cmp), len(csv))):
        c = cmp[i] if i < len(cmp) else {}
        s = csv[i] if i < len(csv) else {}
        v = vp.get(c.get("cmp_row"))
        o = {"row_index": i + 1, "table": s.get("table"), "specimen": s.get("specimen"),
             "sample": s.get("sample"), "species_file": c.get("species_file"),
             "species_csv": s.get("species_csv"),
             "positional_species_agree": (key(c["species_file"]) == key(s["species_csv"])
                                          if c and s else False),
             "value_match_found": v is not None,
             "value_specimen": v["specimen"] if v else None,
             "value_table": v["table"] if v else None}
        o["positional_eq_value_match"] = bool(v and s and v["specimen"] == s["specimen"])
        o["status"] = ("comparison_only_not_in_extraction" if not s else
                       "extraction_only_not_in_comparison" if not c else "matched_positionally")
        n = 0
        for m in measures:
            o[f"{m}_cmp"] = c.get(f"{m}_cmp", float("nan"))
            o[f"{m}_csv"] = s.get(f"{m}_csv", float("nan"))
            ok = rounds_to(c.get(f"{m}_cmp", float("nan")), s.get(f"{m}_csv_txt")) if (c and s) else None
            o[f"{m}_match"] = ok
            n += ok is False
        o["n_measure_mismatch"] = n
        rep.append(o)
    cols = ["status", "row_index", "table", "specimen", "species_file", "species_csv",
            "positional_species_agree", "value_match_found", "value_specimen", "value_table",
            "positional_eq_value_match", "n_measure_mismatch", "sample"]
    for m in measures:
        cols += [f"{m}_cmp", f"{m}_csv", f"{m}_match"]
    write_csv(rep, cols,
              f"{comp}/MacLeod_etal_2003_cerebellumMacLeod_specimen_report_from_R.csv")

    cmp_sp = {}
    for r in read_sheet(f, "species", pos):
        if not r["species_file"] or key(r["species_file"]) == "species":
            continue
        o = {"species_file": r["species_file"], "species_key": key(r["species_file"])}
        for c in pos[1:]:
            o[c] = num(r[c])
        cmp_sp[o["species_key"]] = o
    csv_sp = {}
    for s in csv:
        csv_sp.setdefault(s["species_key"], []).append(s)

    cmp_own = {}
    for c in cmp:
        cmp_own.setdefault(c["species_key"], []).append(c)

    sp = []
    for k2 in sorted(set(cmp_sp) | set(csv_sp)):
        c, ss = cmp_sp.get(k2), csv_sp.get(k2, [])
        own = cmp_own.get(k2, [])
        o = {"species_key": k2, "species_file": c["species_file"] if c else None,
             "species_csv": ss[0]["species_csv"] if ss else None,
             "n_specimens_cmp": len(own) or None, "n_specimens_csv": len(ss) or None}
        n = nd = 0
        for m in measures:
            vals = [x[f"{m}_csv"] for x in ss if not isna(x[f"{m}_csv"])]
            ovals = [x[f"{m}_cmp"] for x in own if not isna(x[f"{m}_cmp"])]
            o[f"{m}_cmp"] = c[f"{m}_cmp"] if c else float("nan")
            o[f"{m}_csv"] = sum(vals) / len(vals) if vals else float("nan")
            o[f"{m}_cmp_from_specimens"] = sum(ovals) / len(ovals) if ovals else float("nan")
            ok = close_to(o[f"{m}_cmp"], o[f"{m}_csv"], 1e-6)
            okd = close_to(o[f"{m}_cmp"], o[f"{m}_cmp_from_specimens"], 1e-6)
            o[f"{m}_match"], o[f"{m}_digest_eq_own_specimens"] = ok, okd
            n += not ok
            nd += not okd
        o["status"] = ("comparison_only_not_in_extraction" if not ss else
                       "extraction_only_not_in_comparison" if not c else "matched_by_species")
        o["n_measure_mismatch"], o["n_digest_self_mismatch"] = n, nd
        o["mean_note"] = ("means agree" if n == 0 else
                          f"digest does not average this file's own {len(own)} specimen rows"
                          " - specimen(s) dropped from the digest" if nd > 0 else
                          "digest reproduces this file's specimens but differs from the extraction")
        sp.append(o)
    spcols = ["status", "species_key", "species_file", "species_csv",
              "n_specimens_cmp", "n_specimens_csv", "n_measure_mismatch",
              "n_digest_self_mismatch", "mean_note"]
    for m in measures:
        spcols += [f"{m}_cmp", f"{m}_csv", f"{m}_cmp_from_specimens",
                   f"{m}_match", f"{m}_digest_eq_own_specimens"]
    write_csv(sp, spcols,
              f"{comp}/MacLeod_etal_2003_cerebellumMacLeod_species_report_from_R.csv")

    mis = []
    for o in rep:
        if (o["status"] != "matched_positionally" or o["n_measure_mismatch"] > 0
                or not o["positional_species_agree"] or not o["value_match_found"]):
            mis.append({"check": "specimen", "key": o["species_file"] or o["species_csv"],
                        "detail": f"{o['status']}; row {o['row_index']}; {o['specimen']}; "
                                  f"{o['n_measure_mismatch']} value mismatch(es)" +
                                  ("" if o["value_match_found"] else "; no one-to-one value match")})
    for o in sp:
        if o["status"] != "matched_by_species" or o["n_measure_mismatch"] > 0:
            mis.append({"check": "species_mean", "key": o["species_key"],
                        "detail": f"{o['status']}; {o['n_measure_mismatch']} mean mismatch(es); {o['mean_note']}"})
    write_csv(mis, ["check", "key", "detail"],
              f"{comp}/MacLeod_etal_2003_cerebellumMacLeod_mismatches_from_R.csv")

    print(f"  comparison specimens {len(cmp)} | extraction specimens {len(csv)}"
          f" | positional value mismatches {sum(o['status'] == 'matched_positionally' and o['n_measure_mismatch'] > 0 for o in rep)}"
          f" | no one-to-one value match {sum(not o['value_match_found'] for o in rep)}"
          f" | positional == value {sum(o['positional_eq_value_match'] for o in rep)}"
          f" | species means matched {sum(o['status'] == 'matched_by_species' and o['n_measure_mismatch'] == 0 for o in sp)}/{len(sp)}")
    return rep, sp


# =========================================================== 4. Bush/Allman ===
def bush():
    print("Bush & Allman 2003  <-  cerebellumBush.xls")
    base = f"{ROOT}/Bush_Allman_2003"
    comp = f"{base}/comparison"
    measures = ["cer_white", "cer_gray", "neo_white", "neo_gray"]
    pos = ["order_file", "clade_file", "species_file",
           "cer_white_cmp", "cer_gray_cmp", "neo_white_cmp", "neo_gray_cmp"]
    cmp = []
    for r in read_sheet(f"{comp}/cerebellumBush.xls", "table_bush.txt", pos):
        if not r["species_file"] or key(r["species_file"]) == "species":
            continue
        o = {"species_file": r["species_file"], "species_key": key(r["species_file"]),
             "order_file": r["order_file"], "clade_file": r["clade_file"]}
        for c in pos[3:]:
            o[c] = num(r[c])
        cmp.append(o)

    csv = []
    for r in read_ref_csv(f"{base}/Bush_Allman_2003_Table1.csv"):
        if not r.get("species"):
            continue
        csv.append({"species_csv": r["species"], "species_key": key(r["species"]),
                    "group_csv": r["group"],
                    "cer_white_txt": r["cer_white_cm3"], "cer_gray_txt": r["cer_gray_cm3"],
                    "neo_white_txt": r["neo_white_cm3"], "neo_gray_txt": r["neo_gray_cm3"]})
    csvk = {r["species_key"]: r for r in csv}

    rep, seen = [], set()
    for c in cmp:
        s = csvk.get(c["species_key"])
        if s:
            seen.add(c["species_key"])
        o = dict(c, species_csv=s["species_csv"] if s else None,
                 group_csv=s["group_csv"] if s else None)
        n = 0
        for m in measures:
            o[f"{m}_csv"] = num(s[f"{m}_txt"]) if s else float("nan")
            ok = rounds_to(c[f"{m}_cmp"], s[f"{m}_txt"]) if s else None
            o[f"{m}_match"] = ok
            n += ok is False
        o["status"] = "matched_by_species" if s else "comparison_only_not_in_Table1"
        o["n_measure_mismatch"] = n
        rep.append(o)
    for s in csv:
        if s["species_key"] not in seen:
            o = dict(s, status="Table1_only_not_in_comparison", n_measure_mismatch=0)
            for m in measures:
                o[f"{m}_csv"] = num(s[f"{m}_txt"])
            rep.append(o)
    rep.sort(key=lambda o: (o["status"], o["species_key"]))
    cols = ["status", "species_key", "species_file", "species_csv", "n_measure_mismatch",
            "order_file", "clade_file", "group_csv"]
    for m in measures:
        cols += [f"{m}_cmp", f"{m}_csv", f"{m}_match"]
    write_csv(rep, cols, f"{comp}/Bush_Allman_2003_cerebellumBush_report_from_R.csv")
    write_csv([o for o in rep if o["status"] != "matched_by_species" or o["n_measure_mismatch"] > 0],
              cols, f"{comp}/Bush_Allman_2003_cerebellumBush_mismatches_from_R.csv")
    print(f"  comparison species {len(cmp)} | Table1 species {len(csv)}"
          f" | matched {sum(o['status'] == 'matched_by_species' for o in rep)}"
          f" | value mismatches {sum(o['status'] == 'matched_by_species' and o['n_measure_mismatch'] > 0 for o in rep)}"
          f" | comparison-only {sum(o['status'] == 'comparison_only_not_in_Table1' for o in rep)}"
          f" | Table1-only {sum(o['status'] == 'Table1_only_not_in_comparison' for o in rep)}")
    return rep


if __name__ == "__main__":
    desousa()
    bauernfeind()
    macleod()
    bush()
