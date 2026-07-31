#!/usr/bin/env python3
"""
build_body_ecology_merge.py  --  whole-organism (body & ecology) merge.

First measure class: BODY MASS, harvested from every source table that records
it (39 tables), pooled team/role-aware so the same specimens / compilations are
not double-counted. Structured (measure_class column) so body BMR and
ecological/life-history measures can be appended as further classes later.

Pipeline (mirrors __merging_cerebral_metabolic_rate):
  1. pick the species-level body-mass column + unit per source (auditable map)
  2. harvest -> resolve species -> convert to grams  -> *_unfiltered.csv
  3. team-dedupe (same collection = one value), then pool across teams
     (primary preferred)                                -> *_long.csv / *_wide.csv
  4. dedupe / disagreement report                       -> *_dedupe_report.csv

R is unavailable in the build env, so this tested builder ships the CSVs; the
house-style twin `body_ecology_compiled.R` implements the same logic.
"""
import csv, collections, glob, os, re, statistics, sys

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
PUB  = os.path.join(REPO, "__Public", "comparative-data")
OUT  = os.path.dirname(__file__)

# ---------------------------------------------------------------- lookups ----
def read_csv(path):
    with open(path, encoding="utf-8") as f:
        return list(csv.DictReader(f))

manifest = {r["file"]: r for r in read_csv(os.path.join(REPO, "__ShinyApp", "data", "source_manifest.csv"))}

# crosswalk: (first_author_lower, year) -> team (same-collection dedupe)
team_by_ay = {}
for r in read_csv(os.path.join(REPO, "_keys", "team_grouping_crosswalk.csv")):
    item = (r.get("item (papers tribble)") or "").strip()
    team = (r.get("script_team (volumes_compiled.R)") or "").strip()
    m = re.match(r"([A-Za-z]+).*?_((?:19|20)\d\d)", item)
    if m and team:
        team_by_ay[(m.group(1).lower(), m.group(2))] = team

# role from variable_catalog: (first_author_lower, year) -> role (body-mass rows)
role_by_ay = {}
for r in read_csv(os.path.join(REPO, "_keys", "variable_catalog.csv")):
    if r["measure_class"] != "mass":
        continue
    t = (r["Code"] + " " + r["Definition"]).lower()
    if "body" not in t or "brain" in t:
        continue
    m = re.match(r"([A-Za-z]+).*?((?:19|20)\d\d)", r["paper"])
    if m:
        role_by_ay.setdefault((m.group(1).lower(), m.group(2)), r["role"])

# species resolver: combine every _keys/*/species_key.csv + species_reference
ref = [r["accepted_name"] for r in read_csv(os.path.join(REPO, "_keys", "species_reference.csv"))]
ref_l = {r.lower(): r for r in ref}
variant = {}
for kf in glob.glob(os.path.join(REPO, "_keys", "*", "species_key.csv")):
    for r in read_csv(kf):
        v = (r.get("variant_name") or "").strip()
        a = (r.get("accepted_name") or "").strip()
        if v and a:
            variant.setdefault(v.lower(), a)
def clean_sp(x):
    x = re.sub(r"\*", "", str(x)).replace("_", " ")
    return re.sub(r"\s+", " ", x).strip()
def resolve(x):
    c = clean_sp(x)
    if c.lower() in ref_l: return ref_l[c.lower()]
    if c.lower() in variant: return variant[c.lower()]
    return c  # keep cleaned printed name if unresolved

# ------------------------------------------------ body-mass column picker ----
BODY_RX = re.compile(r"(body.?mass|body.?weight|bodyweight|bo[wm]ass|bo?w_g|body_?wt)", re.I)
EXCLUDE = ("source", "ref", "note", "_sd", " sd", "sem", "dimorph", "log", "raw",
           "spinal", "brain", "assoc", ": data", "original")
SKIP_FILES = {  # tables whose only body column is not a species mass value
    "10.1016%2Fj.jhevol.2008.08.004_Table7.tsv",  # body mass *dimorphism* (ratio)
}
def norm(h): return h.strip().strip('"').lower()

def pick_column(headers, fn):
    cands = [h for h in headers if BODY_RX.search(norm(h)) and not any(e in norm(h) for e in EXCLUDE)]
    # drop count columns ("N body mass ...")
    cands = [h for h in cands if not (norm(h).startswith(("n ", "n_")) or "sample_size" in norm(h))]
    if not cands:
        return None, None
    # drop a "(mg)" duplicate when a "(g)" sibling exists
    if any("(g)" in norm(h) for h in cands):
        cands = [h for h in cands if "(mg)" not in norm(h)]
    # prefer an explicit species mean over sex-specific
    sp = [h for h in cands if "species" in norm(h)]
    if sp:
        pick = sp[0]
    else:
        cands2 = [h for h in cands if not any(s in norm(h) for s in ("male", "female"))]
        pick = (cands2 or cands)[0]
    n = norm(pick)
    unit = "kg" if "kg" in n else ("mg" if re.search(r"\bmg\b|\(mg\)|_mg", n) else "g")
    return pick, unit

FACTOR = {"g": 1.0, "kg": 1000.0, "mg": 0.001}

# ---------------------------------------------------------------- harvest ----
def paper_key(file):
    m = manifest.get(file, {})
    return (m.get("first_author", "").strip(), m.get("year", "").strip())

BINOM = re.compile(r"^[A-Z][a-z]+ [a-z][a-z-]+")
def species_getter(headers, sample):
    """Return f(row)->species string. Detect the binomial column by value
    pattern; if none, combine a Genus + Species split; else fall back."""
    idx = {h: i for i, h in enumerate(headers)}
    def val(row, i): return row[i].strip().strip('"') if len(row) > i else ""
    def score(i):
        vals = [val(r, i) for r in sample if val(r, i)]
        return (sum(bool(BINOM.match(v)) for v in vals) / len(vals)) if vals else 0.0
    scores = {h: score(idx[h]) for h in headers}
    best = max(scores, key=scores.get) if scores else None
    if best is not None and scores[best] >= 0.5:
        i = idx[best]; return (lambda r: val(r, i)), best
    genus = next((h for h in headers if norm(h) == "genus"), None)
    spec  = next((h for h in headers if norm(h) in ("species", "species epithet")), None)
    if genus and spec:
        gi, si = idx[genus], idx[spec]
        return (lambda r: (val(r, gi) + " " + val(r, si)).strip()), f"{genus}+{spec}"
    for h in headers:
        if norm(h) in ("species", "scientific", "scientific name", "taxon", "binomial",
                       "genus species", "species name", "species_name", "animal"):
            i = idx[h]; return (lambda r: val(r, i)), h
    return (lambda r: val(r, 0)), headers[0]

unfiltered = []            # dict rows
colmap_rows = []           # audit: which column/unit chosen per source
for path in sorted(glob.glob(os.path.join(PUB, "*.tsv"))):
    fn = os.path.basename(path)
    with open(path, encoding="utf-8") as f:
        rows = list(csv.reader(f, delimiter="\t"))
    if not rows:
        continue
    headers = rows[0]
    if not any(BODY_RX.search(norm(h)) for h in headers):
        continue
    author, year = paper_key(fn)
    col, unit = (None, None) if fn in SKIP_FILES else pick_column(headers, fn)
    colmap_rows.append({"file": fn, "first_author": author, "year": year,
                        "chosen_column": col or "(none/skipped)", "unit": unit or "",
                        "all_body_columns": "; ".join(h for h in headers
                                                       if BODY_RX.search(norm(h)))})
    if not col:
        continue
    ay = (author.lower(), year)
    team = team_by_ay.get(ay, author or fn)          # independent team if not a known collection
    role = role_by_ay.get(ay, "secondary")           # default secondary if not catalogued
    idx = {h: i for i, h in enumerate(headers)}
    get_sp, sp_src = species_getter(headers, rows[1:60])
    for r in rows[1:]:
        if len(r) <= idx[col]:
            continue
        raw = r[idx[col]].strip().strip('"')
        try:
            val = float(raw)
        except ValueError:
            continue
        sp_raw = get_sp(r)
        sp = resolve(sp_raw)
        if not sp or sp.lower() in ("na", "none", ""):
            continue
        unfiltered.append({
            "Species": sp, "Species_raw": sp_raw, "measure_class": "mass",
            "Measure": "Body_Mass", "Units": "g",
            "Value_canonical": val * FACTOR[unit], "raw_value": raw, "raw_unit": unit,
            "Source": fn, "first_author": author, "Year": year,
            "Team": team, "role": role,
        })

# ------------------------------------------------------- BMR harvest (body) --
# Whole-animal BMR pooled to mL O2/h; mass-specific derived per row (/body mass),
# kept as a SEPARATE measure. 1 mL O2 = 20.1 J; 1 kcal = 4184 J = 208.16 mL O2;
# per day -> per hour  =>  kcal/day * (4184 / 20.1 / 24).
KCAL_DAY_TO_MLO2H = 4184.0 / 20.1 / 24.0
BMR_SOURCES = {   # file : (bmr_col, bmr_unit, bodymass_col, bodymass_unit)
    "10.1016%2Fj.jhevol.2008.08.004_TableS3.tsv": ("BMR (ml O2/h)", "mlO2h", "Body mass (g)", "g"),
    "10.1016%2Fj.jhevol.2017.09.003_Table1.tsv":  ("BMR_kcal_day", "kcal_day", "BM_g", "g"),
    "10.1111%2Fbrv.12350_TableS2.tsv":            ("BMR.mlO2_h", "mlO2h", "Body_mass.g", "g"),
    "10.1371%2Fjournal.pbio.1002000_TableS1.tsv": ("Basal_metabolic_rate", "mlO2h", "Body_weight", "g"),
}
def to_mlo2h(v, unit): return v * KCAL_DAY_TO_MLO2H if unit == "kcal_day" else v
for fn, (bcol, bunit, bmcol, bmunit) in BMR_SOURCES.items():
    path = os.path.join(PUB, fn)
    if not os.path.exists(path):
        continue
    with open(path, encoding="utf-8") as f:
        rows = list(csv.reader(f, delimiter="\t"))
    headers = [h.strip('"') for h in rows[0]]
    if bcol not in headers:
        continue
    bi = headers.index(bcol)
    mi = headers.index(bmcol) if bmcol in headers else None
    author, year = paper_key(fn)
    team = team_by_ay.get((author.lower(), year), author or fn)
    role = "secondary"                              # the 4 BMR sources are compilations
    get_sp, _ = species_getter(headers, rows[1:60])
    for r in rows[1:]:
        if len(r) <= bi:
            continue
        raw = r[bi].strip().strip('"')
        try:
            bval = float(raw)
        except ValueError:
            continue
        sp = resolve(get_sp(r))
        if not sp or sp.lower() in ("na", "none", ""):
            continue
        wa = to_mlo2h(bval, bunit)
        unfiltered.append({"Species": sp, "Species_raw": get_sp(r),
            "measure_class": "metabolic (body)", "Measure": "BMR_wholeanimal", "Units": "mL O2/h",
            "Value_canonical": wa, "raw_value": raw, "raw_unit": bunit,
            "Source": fn, "first_author": author, "Year": year, "Team": team, "role": role})
        if mi is not None and len(r) > mi:          # derive mass-specific (separate measure)
            try:
                bm = float(r[mi].strip().strip('"'))
            except ValueError:
                bm = None
            if bm and bm > 0:
                unfiltered.append({"Species": sp, "Species_raw": get_sp(r),
                    "measure_class": "metabolic (body)", "Measure": "BMR_massspecific", "Units": "mL O2/h/g",
                    "Value_canonical": wa / bm, "raw_value": raw, "raw_unit": f"{bunit}/{bmunit}",
                    "Source": fn, "first_author": author, "Year": year, "Team": team, "role": role})

# --------------------------------------------------- life-history harvest ----
# Numeric life-history measures, one canonical unit each (no cross-unit convert).
# Gestation and weaning age have 3 sources (pooled); the rest are Lewitus 2014.
# Weaning: lactation length is used as a weaning-age proxy (lactation ends at
# weaning), so it pools with weaning-period / time-to-weaning.
LIFE_SOURCES = [
    ("Maximum_longevity", "yr", {
        "10.1371%2Fjournal.pbio.1002000_TableS1.tsv": "Maximum_lifespan_yrs"}),
    ("Gestation", "days", {
        "10.1371%2Fjournal.pbio.1002000_TableS1.tsv": "Gestation_days",
        "10.1016%2Fj.jhevol.2008.08.004_TableS3.tsv": "Gestation length (d)",
        "10.1073%2Fpnas.0905777106_TableS1.tsv":      "Gestation (days)"}),
    ("Weaning_age", "days", {
        "10.1371%2Fjournal.pbio.1002000_TableS1.tsv": "Weaning_period_days",
        "10.1016%2Fj.jhevol.2008.08.004_TableS3.tsv": "Lactation length (d)",
        "10.3389%2Ffnins.2021.632853_TABLE1.tsv":     "Time_to_weaning_days"}),
    ("Litter_size", "count", {
        "10.1371%2Fjournal.pbio.1002000_TableS1.tsv": "Litter_size"}),
    ("Female_sexual_maturity", "days", {
        "10.1371%2Fjournal.pbio.1002000_TableS1.tsv": "Female_sexual_maturity_days"}),
]
for measure, units, srcmap in LIFE_SOURCES:
    for fn, col in srcmap.items():
        path = os.path.join(PUB, fn)
        if not os.path.exists(path):
            continue
        with open(path, encoding="utf-8") as f:
            rows = list(csv.reader(f, delimiter="\t"))
        headers = [h.strip('"') for h in rows[0]]
        if col not in headers:
            continue
        ci = headers.index(col)
        author, year = paper_key(fn)
        team = team_by_ay.get((author.lower(), year), author or fn)
        role = "secondary"
        get_sp, _ = species_getter(headers, rows[1:60])
        for r in rows[1:]:
            if len(r) <= ci:
                continue
            raw = r[ci].strip().strip('"')
            try:
                v = float(raw)
            except ValueError:
                continue
            if v <= 0:
                continue
            sp = resolve(get_sp(r))
            if not sp or sp.lower() in ("na", "none", ""):
                continue
            unfiltered.append({"Species": sp, "Species_raw": get_sp(r),
                "measure_class": "life_history", "Measure": measure, "Units": units,
                "Value_canonical": v, "raw_value": raw, "raw_unit": units,
                "Source": fn, "first_author": author, "Year": year, "Team": team, "role": role})

# ----------------------------------------------------- diet & ecology --------
# Wilman 2014 (EltonTraits) is the single source; harvested at full coverage
# (5,403 mammals). Numeric diet %s + Diet_breadth; categorical dominant diet,
# trophic guild, foraging stratum, activity pattern.
WILMAN_TSV = "10.1890%2F13-1917.1_MamFuncDat.tsv"
DIET_PCT = ["Diet_Inv", "Diet_Vend", "Diet_Vect", "Diet_Vfish", "Diet_Vunk",
            "Diet_Scav", "Diet_Fruit", "Diet_Nect", "Diet_Seed", "Diet_PlantO"]
DIET_MEASURES = ([(c, "%", "num") for c in DIET_PCT] +
                 [("Diet_breadth", "count", "num"),
                  ("Diet_dominant", "category", "cat"), ("Trophic_guild", "category", "cat"),
                  ("ForStrat_stratum", "category", "cat"), ("Activity_pattern", "category", "cat")])
_wp = os.path.join(PUB, WILMAN_TSV)
if os.path.exists(_wp):
    with open(_wp, encoding="utf-8") as f:
        rows = list(csv.reader(f, delimiter="\t"))
    headers = [h.strip('"') for h in rows[0]]
    idx = {h: i for i, h in enumerate(headers)}
    author, year = paper_key(WILMAN_TSV)
    team = team_by_ay.get((author.lower(), year), author or "Wilman")
    get_sp, _ = species_getter(headers, rows[1:60])
    for r in rows[1:]:
        sp = resolve(get_sp(r))
        if not sp or sp.lower() in ("na", "none", ""):
            continue
        for col, units, kind in DIET_MEASURES:
            if col not in idx or len(r) <= idx[col]:
                continue
            raw = r[idx[col]].strip().strip('"')
            if not raw or raw.lower() in ("na", "none", "nan"):
                continue
            if kind == "num":
                try:
                    vc = float(raw)
                except ValueError:
                    continue
            else:
                vc = raw
            unfiltered.append({"Species": sp, "Species_raw": get_sp(r),
                "measure_class": "diet_ecology", "Measure": col, "Units": units,
                "Value_canonical": vc, "raw_value": raw, "raw_unit": units,
                "Source": WILMAN_TSV, "first_author": author, "Year": year,
                "Team": team, "role": "secondary"})

# ------------------------------------------------------------------ pool -----
# Pool team/role-aware within each (Species x measure_class x Measure x Units).
groups = {}
for row in unfiltered:
    groups.setdefault((row["Species"], row["measure_class"], row["Measure"], row["Units"]), []).append(row)

def _num(x):
    try: return float(x)
    except (ValueError, TypeError): return None

long_rows, dedupe_rows = [], []
for (sp, mclass, measure, units), rows in sorted(groups.items()):
    teams = {}
    for r in rows:
        teams.setdefault(r["Team"], []).append(r)
    team_role = {t: ("primary" if any(x["role"] == "primary" for x in rs) else
                     rs[0]["role"]) for t, rs in teams.items()}
    numeric = all(_num(r["Value_canonical"]) is not None for r in rows)
    if numeric:                                    # mean/median, primary-preferred
        team_vals = {t: statistics.mean(_num(x["Value_canonical"]) for x in rs) for t, rs in teams.items()}
        prim = {t: v for t, v in team_vals.items() if team_role[t] == "primary"}
        used = prim if prim else team_vals
        pooled = round(statistics.mean(used.values()), 4)
        pooled_med = round(statistics.median(used.values()), 4)
        vals_all = [_num(r["Value_canonical"]) for r in rows]
        vmin, vmax = round(min(vals_all), 4), round(max(vals_all), 4)
        spread = (max(vals_all) / min(vals_all)) if min(vals_all) > 0 else float("nan")
        n_prim = len(prim); n_teams = len(team_vals)
        per_val = lambda r: round(_num(r["Value_canonical"]), 3)
        flag = "DISAGREEMENT>2x" if (spread == spread and spread > 2) else ""
        spread_out = round(spread, 2) if spread == spread else ""
    else:                                          # categorical -> mode (primary-preferred)
        prim_rows = [r for r in rows if team_role.get(r["Team"]) == "primary"]
        pool_rows = prim_rows if prim_rows else rows
        pooled = collections.Counter(str(r["Value_canonical"]) for r in pool_rows).most_common(1)[0][0]
        pooled_med = pooled; vmin = vmax = ""
        n_prim = len({r["Team"] for r in prim_rows}); n_teams = len(teams)
        per_val = lambda r: r["Value_canonical"]
        distinct = len({str(r["Value_canonical"]) for r in rows})
        flag = "MULTIPLE" if distinct > 1 else ""; spread_out = ""
    long_rows.append({
        "Species": sp, "measure_class": mclass, "Measure": measure, "Units": units,
        "Value": pooled, "Value_median": pooled_med,
        "n_sources": len(rows), "n_teams": n_teams,
        "n_teams_primary": n_prim, "primary_used": bool(n_prim),
        "Teams": "; ".join(sorted(teams)),
        "roles": "; ".join(sorted({r["role"] for r in rows})),
        "value_min": vmin, "value_max": vmax,
    })
    if len(rows) > 1:
        dedupe_rows.append({
            "Species": sp, "Measure": measure, "Units": units,
            "n_sources": len(rows), "n_teams": n_teams, "pooled": pooled,
            "spread_max_over_min": spread_out, "flag": flag,
            "per_source": " | ".join(f'{r["first_author"]}{r["Year"]}({r["Team"]},{r["role"]})='
                                     f'{per_val(r)}' for r in rows),
        })

# ------------------------------------------------------------------ write ----
def write(fn, rows, cols):
    with open(os.path.join(OUT, fn), "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=cols); w.writeheader()
        for r in rows: w.writerow(r)

write("body_ecology_source_columns.csv", colmap_rows,
      ["file", "first_author", "year", "chosen_column", "unit", "all_body_columns"])
write("body_ecology_unfiltered.csv", unfiltered,
      ["Species", "Species_raw", "measure_class", "Measure", "Units", "Value_canonical",
       "raw_value", "raw_unit", "Source", "first_author", "Year", "Team", "role"])
write("body_ecology_long.csv", long_rows,
      ["Species", "measure_class", "Measure", "Units", "Value", "Value_median",
       "n_sources", "n_teams", "n_teams_primary", "primary_used", "Teams", "roles",
       "value_min", "value_max"])
write("body_ecology_dedupe_report.csv", sorted(dedupe_rows, key=lambda x: -x["n_sources"]),
      ["Species", "Measure", "Units", "n_sources", "n_teams", "pooled",
       "spread_max_over_min", "flag", "per_source"])
# wide: one column per Measure
WCOL = {"Body_Mass": "Body_Mass.g", "BMR_wholeanimal": "BMR_wholeanimal.mLO2h",
        "BMR_massspecific": "BMR_massspecific.mLO2hg",
        "Maximum_longevity": "Maximum_longevity.yr", "Gestation": "Gestation.days",
        "Weaning_age": "Weaning_age.days", "Litter_size": "Litter_size",
        "Female_sexual_maturity": "Female_sexual_maturity.days"}
wide_cols = ["Species", "Body_Mass.g", "BMR_wholeanimal.mLO2h", "BMR_massspecific.mLO2hg",
             "Maximum_longevity.yr", "Gestation.days", "Weaning_age.days", "Litter_size",
             "Female_sexual_maturity.days",
             "Diet_Inv", "Diet_Vend", "Diet_Vect", "Diet_Vfish", "Diet_Vunk", "Diet_Scav",
             "Diet_Fruit", "Diet_Nect", "Diet_Seed", "Diet_PlantO", "Diet_breadth",
             "Diet_dominant", "Trophic_guild", "ForStrat_stratum", "Activity_pattern"]
wide = {}
for r in long_rows:
    wide.setdefault(r["Species"], {"Species": r["Species"]})[WCOL.get(r["Measure"], r["Measure"])] = r["Value"]
write("body_ecology_wide.csv", list(wide.values()), wide_cols)

import collections as _c
print(f"body-mass sources: {sum(1 for c in colmap_rows if c['chosen_column'] not in ('(none/skipped)',))}")
print(f"unfiltered rows: {len(unfiltered)}  |  long rows: {len(long_rows)}")
for k, n in sorted(_c.Counter(f"{r['measure_class']} / {r['Measure']} ({r['Units']})" for r in long_rows).items()):
    print(f"   {n:5d}  {k}")
print(f"disagreement>2x flags: {sum(1 for d in dedupe_rows if d['flag'])}")
