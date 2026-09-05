#!/usr/bin/env python3
"""build_brain_mass_merge.py -- the tested builder for the whole-brain-size merge.
House twin: brain_mass_compiled.R. See README__merging.md.

Harvest every source table's whole-brain-size column -> resolve species -> grams
-> pool. Pooling is TEAM-COLLAPSED and PRIMARY-PREFERRED as before, but is now
also SPLIT BY MEASUREMENT BASIS: values are only ever pooled with values of the
same basis, because the sources are not all reporting the same quantity.

  Brain_Mass_measured                 a weighed brain mass
  Brain_Mass_excl_olfactory_bulb      a weighed brain mass explicitly excluding the
                                      olfactory bulbs (isotropic-fractionator group:
                                      Herculano-Houzel 2015, Kazu 2014/2015,
                                      Avelino-de-Souza 2025) - systematically smaller
  Brain_Mass_mass_or_volume           compilations whose values are masses for some
                                      species and volumes converted at 1 cm3 = 1 g for
                                      others, not distinguishable per row (Burger 2019,
                                      Herculano-Houzel 2015 'brain.mass..g.or.cm3.')
  Brain_size_sum_of_structures        a whole-brain figure obtained by summing measured
                                      sub-structures, olfactory bulbs included
                                      (Kverkova 2018)

The basis of each source column is read from _keys/brain_size_basis.csv, which
records it from the source's own definitions file and marks it `unknown` where the
source does not say. Endocranial volume is NOT here: cranial capacity is the
capacity of the braincase, not a brain mass, and lives in
__merging_endocranial_volume/.

Run: python3 __merging_brain_mass/build_brain_mass_merge.py
"""
import csv, glob, os, re, sys
from collections import defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(HERE)
PUB = os.path.join(REPO, "__Public", "comparative-data")
KEYS = os.path.join(REPO, "_keys")

BRAIN_RX = re.compile(r"brain.{0,3}(mass|weight|wt)", re.I)
EXCLUDE = ["neonat", "fetal", "cerebel", "cortex", "cortic", "olfact", "rest of brain",
           "diencephal", "mesencephal", "pons", "medulla", "hemisphere", "white", "grey",
           "gray", "region", "residual", "resid", "net", "ratio", "source", "ref", "note",
           "_sd", " sd", ": data", "%", "index", "relative"]
FACTOR = {"g": 1.0, "kg": 1000.0, "mg": 0.001}
BINOM_RX = re.compile(r"^[A-Z][a-z]+ [a-z][a-z-]+")
# poolable_group in brain_size_basis.csv -> the Measure emitted for it
FAMILY = {
    "mass_measured": "Brain_Mass_measured",
    "mass_measured_specimen": "Brain_Mass_measured",
    "mass_measured_excl_ob": "Brain_Mass_excl_olfactory_bulb",
    "mass_or_volume_mixed": "Brain_Mass_mass_or_volume",
    "sum_of_parts_incl_ob": "Brain_size_sum_of_structures",
    # Weaver 2001: "brain mass" computed from a measured brain volume (extant) or from an
    # endocranial volume via Ruff et al. 1997 (fossils). Not a weighed mass, and not the
    # same as the mass-or-volume compilations either -- those at least weigh some species.
    "mass_from_volume_or_ecv": "Brain_Mass_from_volume_or_ecv",
}
# FAMILY is many-to-one (mass_measured and mass_measured_specimen both emit
# Brain_Mass_measured), so de-duplicate before using the Measures as column names
MEASURES_OUT = sorted(set(FAMILY.values()))
def round_n(x, d):
    """Round half away from zero at `d` decimals, identically in R and Python.

    Base R rounds the shortest decimal it would print; Python rounds the stored double. They
    disagree wherever a value sits on a tie, so neither native rule can be used if the two
    builders are to agree. Format at d+6 dp with C printf (same libc routine in both), then
    round with exact integer arithmetic. See brain_mass_compiled.R, which carries the twin.
    """
    s = "%.*f" % (d + 6, x)
    neg = s.startswith("-")
    i, f = s.lstrip("-").split(".")
    v = ((int(i) * 10 ** (d + 6) + int(f) + 500_000) // 1_000_000) / 10 ** d
    return -v if neg else v


n = lambda h: h.strip().strip('"').lower()


def read_csv_rows(p):
    with open(p, newline="", encoding="utf-8-sig") as fh:
        return list(csv.DictReader(fh))


def pick_column(headers):
    cand = [h for h in headers if BRAIN_RX.search(n(h))]
    cand = [h for h in cand if not any(e in n(h) for e in EXCLUDE)]
    cand = [h for h in cand if not re.match(r"^n[ _]", n(h)) and "sample_size" not in n(h)]
    if not cand:
        return None
    if any("whole" in n(h) for h in cand):
        cand = [h for h in cand if "whole" in n(h)]
    return cand[0]


def named_unit(colname):
    c = n(colname)
    if "kg" in c:
        return "kg"
    if re.search(r"\bmg\b|\(mg\)|_mg", c):
        return "mg"
    if re.search(r"\(g\)|_g$|, g|cm3|\bg\b", c):
        return "g"
    return None


def num(x):
    try:
        v = float(str(x).strip().replace('"', ""))
        return None if v != v else v
    except (TypeError, ValueError):
        return None


# ---- keys -------------------------------------------------------------------
manifest = {r["file"]: r for r in read_csv_rows(os.path.join(REPO, "__ShinyApp", "data",
                                                             "source_manifest.csv"))}
team_ay = {}
with open(os.path.join(KEYS, "team_grouping_crosswalk.csv"), newline="", encoding="utf-8") as fh:
    rd = csv.reader(fh)
    hdr = next(rd)
    for row in rd:
        if len(row) < 2 or not row[1].strip():
            continue
        m = re.search(r"([A-Za-z]+).*?((?:19|20)[0-9]{2})", row[0])
        if m:
            team_ay[(m.group(1).lower(), m.group(2))] = row[1].strip()

role_ay, cat_rows = {}, read_csv_rows(os.path.join(KEYS, "variable_catalog.csv"))
for r in cat_rows:
    if r["measure_class"] != "mass":
        continue
    t = (r["Code"] + " " + r["Definition"]).lower()
    if "brain" not in t or "body" in t:
        continue
    m = re.search(r"([A-Za-z]+).*?((?:19|20)[0-9]{2})", r["paper"])
    if m:
        role_ay.setdefault((m.group(1).lower(), m.group(2)), r["role"])

ref = [r["accepted_name"] for r in read_csv_rows(os.path.join(KEYS, "species_reference.csv"))]
ref_l = {a.lower(): a for a in ref if a}
variant = {}
# sorted(): first mapping wins, so the read order decides cases where two key files
# disagree (Stephan/species_key.csv keeps "Cebus apella"; HerculanoHouzel/species_key.csv
# maps it to the accepted "Sapajus apella"). R's list.files() is sorted, so sort here too.
for kf in sorted(glob.glob(os.path.join(KEYS, "**", "*species_key.csv"), recursive=True)):
    rows = read_csv_rows(kf)
    if not rows or not {"variant_name", "accepted_name"} <= set(rows[0]):
        continue
    for r in rows:
        v = (r["variant_name"] or "").strip().lower()
        acc = (r["accepted_name"] or "").strip()
        # Skip rows with a BLANK accepted_name. HerculanoHouzel/species_key.csv carries
        # several (Cynomys sp., Dasyprocta prymnolopha) awaiting taxonomy review; letting
        # them through blanks the species label and the row is then silently dropped from
        # the merge. Falling through to the printed name keeps the datum. See APP_PLAN.md
        # ("skip blank keys in the build, surface on Coverage"). The blank is written as the
        # literal string "NA" in that file, which is why a plain emptiness test misses it.
        if v and acc and acc.upper() != "NA":
            variant.setdefault(v, acc)


def resolve(x):
    c = re.sub(r"\s+", " ", str(x).replace("*", "").replace("_", " ")).strip()
    lc = c.lower()
    return ref_l.get(lc) or variant.get(lc) or c


# basis: (paper folder, column) -> poolable_group
basis_rows = read_csv_rows(os.path.join(KEYS, "brain_size_basis.csv"))
basis_grp = {(r["paper"], r["column"]): r["poolable_group"] for r in basis_rows}
basis_col = {(r["paper"], r["column"]): r for r in basis_rows}
folders = sorted(d for d in os.listdir(REPO) if os.path.isdir(os.path.join(REPO, d))
                 and not d.startswith((".", "_")))


def folder_of(author, year, col):
    a, y = (author or "").lower(), str(year or "")
    hits = [f for f in folders if f.lower().startswith(a) and y in f]
    if len(hits) > 1:
        for h in hits:
            if (h, col) in basis_grp:
                return h
    return hits[0] if hits else ""


def species_getter(headers, sample):
    def val(r, i):
        return r[i].strip().replace('"', "") if len(r) > i else ""

    def score(i):
        v = [val(r, i) for r in sample]
        v = [x for x in v if x]
        return 0 if not v else sum(bool(BINOM_RX.match(x)) for x in v) / len(v)

    sc = [score(i) for i in range(len(headers))]
    if sc:
        b = max(range(len(sc)), key=lambda i: sc[i])
        if sc[b] >= 0.5:
            return lambda r: val(r, b)
    low = [n(h) for h in headers]
    if "genus" in low and ("species" in low or "species epithet" in low):
        gi = low.index("genus")
        si = low.index("species") if "species" in low else low.index("species epithet")
        return lambda r: (val(r, gi) + " " + val(r, si)).strip()
    for c in ("species", "scientific", "scientific name", "taxon", "binomial",
              "genus species", "species name", "animal"):
        if c in low:
            i = low.index(c)
            return lambda r: val(r, i)
    return lambda r: val(r, 0)


# ---- pass 1: locate column + per (author, column) magnitude for unit-less cols
targets, gmax = [], defaultdict(float)
for path in sorted(glob.glob(os.path.join(PUB, "*.tsv"))):
    fn = os.path.basename(path)
    with open(path, encoding="utf-8", errors="replace") as fh:
        lines = fh.read().splitlines()
    if not lines:
        continue
    rows = [ln.split("\t") for ln in lines]
    headers = [h.replace('"', "") for h in rows[0]]
    if not any(BRAIN_RX.search(n(h)) for h in headers):
        continue
    col = pick_column(headers)
    if col is None:
        continue
    ci = headers.index(col)
    vals = [num(r[ci]) for r in rows[1:] if len(r) > ci]
    vals = [v for v in vals if v is not None]
    if not vals:
        continue
    mi = manifest.get(fn, {})
    author, year = mi.get("first_author", ""), str(mi.get("year", "") or "")
    targets.append(dict(fn=fn, rows=rows, headers=headers, col=col, ci=ci,
                        author=author, year=year))
    if named_unit(col) is None:
        k = (author.lower(), n(col))
        gmax[k] = max(gmax[k], max(vals))

# ---- pass 2: harvest --------------------------------------------------------
uf = []
for t in targets:
    unit = named_unit(t["col"]) or ("mg" if gmax[(t["author"].lower(), n(t["col"]))] > 20000 else "g")
    ay = (t["author"].lower(), t["year"])
    team = team_ay.get(ay) or (t["author"] if t["author"] else t["fn"])
    role = role_ay.get(ay, "secondary")
    folder = folder_of(t["author"], t["year"], t["col"])
    grp = basis_grp.get((folder, t["col"]), "")
    get_sp = species_getter(t["headers"], t["rows"][1:60])
    for r in t["rows"][1:]:
        if len(r) <= t["ci"]:
            continue
        v = num(r[t["ci"]])
        if v is None:
            continue
        sp = resolve(get_sp(r))
        if not sp or sp.lower() in ("na", "none"):
            continue
        uf.append(dict(Species=sp, Measure="Brain_Mass", Units="g", # 10 significant digits: the mg->g conversion leaves float noise (3550 * 0.001 =
                           # 3.5500000000000003) that would be written out verbatim here and
                           # would not match the R twin. 10 sig digits is far finer than any
                           # source reports and makes the two builders write the same double.
                           Value_g=float("%.10g" % (v * FACTOR[unit])),
                       raw_value=r[t["ci"]].replace('"', ""), raw_unit=unit, Source=t["fn"],
                       first_author=t["author"], Year=t["year"], Team=team, role=role,
                       paper=folder, column=t["col"], poolable_group=grp,
                       basis=basis_col.get((folder, t["col"]), {}).get("basis", ""),
                       measure_emitted=FAMILY.get(grp, "")))

unattributed = [r for r in uf if not r["poolable_group"]]
if unattributed:
    seen = sorted({(r["paper"], r["column"]) for r in unattributed})
    sys.exit(f"ABORT: {len(unattributed)} harvested rows have no basis in "
             f"_keys/brain_size_basis.csv: {seen}\nAdd them there before pooling.")

UF_COLS = ["Species", "Measure", "Units", "Value_g", "raw_value", "raw_unit", "Source",
           "first_author", "Year", "Team", "role", "paper", "column", "poolable_group",
           "basis", "measure_emitted"]
with open(os.path.join(HERE, "brain_mass_unfiltered.csv"), "w", newline="", encoding="utf-8") as fh:
    w = csv.DictWriter(fh, fieldnames=UF_COLS)
    w.writeheader()
    w.writerows(uf)

# ---- pool, WITHIN basis family ---------------------------------------------
long_rows, dedupe, cross = [], [], []
by_sp_fam = defaultdict(list)
for r in uf:
    by_sp_fam[(r["Species"], r["measure_emitted"])].append(r)

for (sp, meas) in sorted(by_sp_fam):
    d = by_sp_fam[(sp, meas)]
    tv, trole = defaultdict(list), {}
    for r in d:
        tv[r["Team"]].append(r["Value_g"])
    for team in tv:
        roles = [r["role"] for r in d if r["Team"] == team]
        trole[team] = "primary" if "primary" in roles else roles[0]
    team_mean = {t: sum(v) / len(v) for t, v in tv.items()}
    prim = [v for t, v in team_mean.items() if trole[t] == "primary"]
    used = prim if prim else list(team_mean.values())
    vals = [r["Value_g"] for r in d]
    long_rows.append(dict(Species=sp, measure_class="mass", Measure=meas, Units="g",
                          Value=round_n(sum(used) / len(used), 4),
                          Value_median=round_n(sorted(used)[len(used) // 2] if len(used) % 2
                                               else sum(sorted(used)[len(used) // 2 - 1:
                                                                     len(used) // 2 + 1]) / 2, 4),
                          n_sources=len(d), n_teams=len(tv), n_teams_primary=len(prim),
                          primary_used=len(prim) > 0,
                          Teams="; ".join(sorted(tv)),
                          roles="; ".join(sorted({r["role"] for r in d})),
                          basis="; ".join(sorted({r["basis"] for r in d})),
                          value_min=round_n(min(vals), 4), value_max=round_n(max(vals), 4)))
    if len(d) > 1:
        spread = max(vals) / min(vals) if min(vals) else float("inf")
        dedupe.append(dict(Species=sp, Measure=meas, n_sources=len(d), n_teams=len(tv),
                           pooled_g=round_n(sum(used) / len(used), 4),
                           spread_max_over_min=round_n(spread, 2),
                           flag="DISAGREEMENT>2x" if spread > 2 else "",
                           per_source=" | ".join(
                               f"{r['first_author']}{r['Year']}({r['Team']},{r['role']})="
                               f"{r['Value_g']:.2f}" for r in d)))

long_rows.sort(key=lambda r: (r["Species"], r["Measure"]))
LONG_COLS = ["Species", "measure_class", "Measure", "Units", "Value", "Value_median",
             "n_sources", "n_teams", "n_teams_primary", "primary_used", "Teams", "roles",
             "basis", "value_min", "value_max"]
with open(os.path.join(HERE, "brain_mass_long.csv"), "w", newline="", encoding="utf-8") as fh:
    w = csv.DictWriter(fh, fieldnames=LONG_COLS)
    w.writeheader()
    w.writerows(long_rows)

dedupe.sort(key=lambda r: -r["n_sources"])
with open(os.path.join(HERE, "brain_mass_dedupe_report.csv"), "w", newline="",
          encoding="utf-8") as fh:
    w = csv.DictWriter(fh, fieldnames=["Species", "Measure", "n_sources", "n_teams", "pooled_g",
                                       "spread_max_over_min", "flag", "per_source"])
    w.writeheader()
    w.writerows(dedupe)

# ---- cross-basis comparison report -----------------------------------------
# The one thing the split makes impossible to read off the long table: how the
# bases differ for the species that have more than one. This is the review list.
bysp = defaultdict(dict)
for r in long_rows:
    bysp[r["Species"]][r["Measure"]] = r["Value"]
for sp in sorted(bysp):
    got = bysp[sp]
    if len(got) < 2:
        continue
    lo, hi = min(got.values()), max(got.values())
    cross.append(dict(Species=sp, n_bases=len(got),
                      **{k: got.get(k, "") for k in MEASURES_OUT},
                      ratio_max_over_min=round_n(hi / lo, 3) if lo else "",
                      flag="DISAGREEMENT>2x" if lo and hi / lo > 2 else ""))
cross.sort(key=lambda r: -(r["ratio_max_over_min"] or 0))
with open(os.path.join(HERE, "brain_size_basis_comparison.csv"), "w", newline="",
          encoding="utf-8") as fh:
    w = csv.DictWriter(fh, fieldnames=["Species", "n_bases"] + MEASURES_OUT
                       + ["ratio_max_over_min", "flag"])
    w.writeheader()
    w.writerows(cross)

# ---- wide ------------------------------------------------------------------
meas_order = sorted({r["Measure"] for r in long_rows})
wide = defaultdict(dict)
for r in long_rows:
    wide[r["Species"]][r["Measure"]] = r["Value"]
with open(os.path.join(HERE, "brain_mass_wide.csv"), "w", newline="", encoding="utf-8") as fh:
    w = csv.writer(fh)
    w.writerow(["Species"] + [m + ".g" for m in meas_order])
    for sp in sorted(wide):
        w.writerow([sp] + [wide[sp].get(m, "") for m in meas_order])

print(f"harvested rows: {len(uf)} | pooled cells: {len(long_rows)} | "
      f"species: {len({r['Species'] for r in long_rows})}", file=sys.stderr)
for m in meas_order:
    sub = [r for r in long_rows if r["Measure"] == m]
    print(f"  {m:32s} {len(sub):5d} species", file=sys.stderr)
print(f"  species with >1 basis: {len(cross)} (of which >2x apart: "
      f"{sum(1 for r in cross if r['flag'])})", file=sys.stderr)
