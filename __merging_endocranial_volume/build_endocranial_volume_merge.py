#!/usr/bin/env python3
"""build_endocranial_volume_merge.py -- compile species-level ENDOCRANIAL VOLUME
(cranial capacity), in millilitres. See README__merging.md.

Why this is a separate merge and not part of __merging_brain_mass: endocranial
volume is the capacity of the braincase, so it contains the brain PLUS the
meninges, cerebrospinal fluid and vessels, and therefore exceeds brain volume.
It is not a brain mass and is never converted to one here.

Sources
  Isler_etal_2008   TableS2   PRIMARY    293 primate species, 'ECV species mean' (cc = mL);
                                         264 of them measured by that study itself
  Powell_etal_2017  Dataset1  SECONDARY  289 species, 'ECV'; its own 'Source ECV' column
                                         names Isler et al. 2008 for 29 of them, and those
                                         rows are DROPPED as double counts
  Seymour_etal_2015 TableS1   SECONDARY  60 extant primates, 'Brain_volume_ml'
  Caspar_etal_2022  Suppfile3 PRIMARY    38 species, 'female_endocranial_volume_ml'

Not used
  10.6084/m9.figshare.c.3899422.v1_Dataset1.tsv is the figshare export of the SAME
  Powell et al. 2017 dataset (identical 289 rows and columns) -- including both would
  double-count every species.
  Seymour_etal_2017 rsos.170846 is specimen-level FOSSIL hominin material; per-specimen
  fossil endocranial data lives in __merging_fossil_brain_glucose.

Sex scope is SPLIT, not silently pooled: Caspar reports female-only means and Powell
labels each row 'fem' or 'all individuals'. A female mean and a both-sexes species mean
are different quantities in a dimorphic clade, so they are emitted as two variables --
Endocranial_volume (both sexes / unspecified) and Endocranial_volume_female -- and never
averaged together.

Run: python3 __merging_endocranial_volume/build_endocranial_volume_merge.py
"""
import csv, glob, os, re, sys
from collections import defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(HERE)
PUB = os.path.join(REPO, "__Public", "comparative-data")
KEYS = os.path.join(REPO, "_keys")

SOURCES = [
    dict(file="10.1016%2Fj.jhevol.2008.08.004_TableS2.tsv", team="Isler", author="Isler",
         year="2008", role="primary", col="ECV species mean", species_col="Species",
         src_col="Source of ECV", sex_col=None),
    dict(file="10.1098%2Frspb.2017.1765_Dataset1.tsv", team="Powell", author="Powell",
         year="2017", role="secondary", col="ECV", species_col="Species Name",
         src_col="Source ECV", sex_col="Sex ECV"),
    dict(file="10.1242%2Fjeb.124826_TableS1.tsv", team="Seymour", author="Seymour",
         year="2015", role="secondary", col="Brain_volume_ml", species_col="Species",
         src_col=None, sex_col=None),
    dict(file="10.7554%2FeLife.77875_Supplementaryfile3.tsv", team="Caspar", author="Caspar",
         year="2022", role="primary", col="female_endocranial_volume_ml",
         species_col="Species", src_col="endocranial_volume_ref", sex_col=None,
         sex_fixed="female"),
    dict(file="10.1038%2Fsrep24528_TableS1.tsv", team="Heldstab", author="Heldstab",
         year="2016", role="secondary", col="ECV_ml", species_col="Species",
         src_col=None, sex_col=None, sex_fixed="female",
         reprint_of=("Isler", "Powell")),
]
# `reprint_of` — a source whose ECV column is, by its own definitions file, a reprint of an
# upstream compilation that ANOTHER team in this merge already carries. Heldstab et al. 2016's
# definitions attribute its ECV to "Lonsdorf & Ross and van Woerden et al."; Powell et al. 2017
# labels 219 of its own rows "van Woerden compilation". 36 of Heldstab's 37 species are already
# in Powell (33 of them from that same van Woerden compilation, agreeing to within 2% for 28),
# so keeping both would double-count van Woerden. Heldstab rows are therefore dropped for any
# species already carried by Isler or Powell, which leaves exactly one: Homo sapiens.
# a source-of-value string naming one of these teams means the row is that team's datum
# reprinted, not an independent one
UPSTREAM = {"isler": "Isler"}


def read_rows(p, sep="\t"):
    with open(p, newline="", encoding="utf-8-sig", errors="replace") as fh:
        return list(csv.DictReader(fh, delimiter=sep))


def num(x):
    try:
        v = float(str(x).strip().replace('"', "").replace(",", ""))
        return None if v != v else v
    except (TypeError, ValueError):
        return None


# ---- species resolution (same rule as the other merges) --------------------
ref_l = {}
for r in read_rows(os.path.join(KEYS, "species_reference.csv"), ","):
    a = (r.get("accepted_name") or "").strip()
    if a:
        ref_l[a.lower()] = a
variant = {}
for kf in sorted(glob.glob(os.path.join(KEYS, "**", "*species_key.csv"), recursive=True)):
    rows = read_rows(kf, ",")
    if not rows or not {"variant_name", "accepted_name"} <= set(rows[0]):
        continue
    for r in rows:
        v = (r["variant_name"] or "").strip().lower()
        acc = (r["accepted_name"] or "").strip()
        # a blank accepted_name is written as the literal "NA" in
        # HerculanoHouzel/species_key.csv; letting it through blanks the label and
        # silently drops the row
        if v and acc and acc.upper() != "NA":
            variant.setdefault(v, acc)


def resolve(x):
    c = re.sub(r"\s+", " ", str(x).replace("*", "").replace("_", " ")).strip()
    return ref_l.get(c.lower()) or variant.get(c.lower()) or c


# ---- harvest ---------------------------------------------------------------
U = []
for s in SOURCES:
    p = os.path.join(PUB, s["file"])
    if not os.path.exists(p):
        sys.exit(f"ABORT: missing source table {s['file']}")
    for r in read_rows(p):
        v = num(r.get(s["col"]))
        if v is None:
            continue
        sp = resolve(r.get(s["species_col"], ""))
        if not sp or sp.lower() in ("na", "none", "nan"):
            continue
        # NB no genus-level filter. Genus buckets like "Macaca sp." and "Pongo sp." are
        # accepted names in _keys/species_reference.csv and are legitimate rows in the other
        # merges, so dropping them here would both lose data and diverge from house convention.
        # It also silently discarded Heldstab's validly-printed Pongo abelii, which
        # _keys/*/species_key.csv maps onto the Pongo sp. bucket.
        src = (r.get(s["src_col"]) or "").strip() if s["src_col"] else ""
        up = next((t for k, t in UPSTREAM.items() if k in src.lower() and t != s["team"]), "")
        sex = s.get("sex_fixed") or ((r.get(s["sex_col"]) or "").strip() if s["sex_col"] else "")
        sex_scope = ("female" if re.match(r"fem", sex, re.I) else
                     "both" if sex else "unknown")
        U.append(dict(Species=sp, Species_printed=str(r.get(s["species_col"], "")).strip(),
                      Measure="Endocranial_volume", Units="mL", Value=v,
                      Source=s["file"], first_author=s["author"], Year=s["year"],
                      Team=s["team"], role=s["role"], source_of_value=src,
                      upstream_team=up, sex_scope=sex_scope,
                      reprint_of="; ".join(s.get("reprint_of", ()))))

# Second pass for `reprint_of`: now that every source is loaded, a row is a reprint if one of
# the named carrier teams already has that species. Marked in upstream_team so it flows into
# the dedupe report and the filter below with the per-row reprints.
sp_by_team = defaultdict(set)
for r in U:
    sp_by_team[r["Team"]].add(r["Species"])
for r in U:
    if r["upstream_team"] or not r["reprint_of"]:
        continue
    carrier = next((t for t in r["reprint_of"].split("; ")
                    if r["Species"] in sp_by_team.get(t, ())), "")
    if carrier:
        r["upstream_team"] = carrier

UF_COLS = ["Species", "Species_printed", "Measure", "Units", "Value", "Source", "first_author",
           "Year", "Team", "role", "source_of_value", "upstream_team", "reprint_of", "sex_scope"]
U.sort(key=lambda r: (r["Species"], r["Team"]))
with open(os.path.join(HERE, "endocranial_volume_unfiltered.csv"), "w", newline="",
          encoding="utf-8") as fh:
    w = csv.DictWriter(fh, fieldnames=UF_COLS)
    w.writeheader()
    w.writerows(U)

# ---- filter: drop reprints of another team's datum, and female-only rows ----
dedupe = [dict(Species=r["Species"], Team=r["Team"], upstream_team=r["upstream_team"],
               source_of_value=r["source_of_value"], Value=r["Value"],
               reason=("value attributed by its own source column to " + r["upstream_team"]
                       if not r["reprint_of"] else
                       "source's definitions attribute its ECV to an upstream compilation that "
                       + r["upstream_team"] + " already carries for this species"))
          for r in U if r["upstream_team"]]
with open(os.path.join(HERE, "endocranial_volume_dedupe_report.csv"), "w", newline="",
          encoding="utf-8") as fh:
    w = csv.DictWriter(fh, fieldnames=["Species", "Team", "upstream_team", "source_of_value",
                                       "Value", "reason"], extrasaction="ignore")
    w.writeheader()
    w.writerows(sorted(dedupe, key=lambda r: r["Species"]))

F = [r for r in U if not r["upstream_team"]]
for r in F:
    r["measure_emitted"] = ("Endocranial_volume_female" if r["sex_scope"] == "female"
                            else "Endocranial_volume")

# ---- pool: team-collapse, primary-preferred (as in __merging_brain_mass) ----
long_rows, cmp_rows = [], []
by_sp = defaultdict(list)
for r in F:
    by_sp[(r["Species"], r["measure_emitted"])].append(r)
for (sp, meas) in sorted(by_sp):
    d = by_sp[(sp, meas)]
    tv = defaultdict(list)
    for r in d:
        tv[r["Team"]].append(r["Value"])
    trole = {t: ("primary" if any(r["role"] == "primary" for r in d if r["Team"] == t)
                 else "secondary") for t in tv}
    tmean = {t: sum(v) / len(v) for t, v in tv.items()}
    prim = [v for t, v in tmean.items() if trole[t] == "primary"]
    used = prim if prim else list(tmean.values())
    vals = [r["Value"] for r in d]
    long_rows.append(dict(Species=sp, measure_class="endocranial_volume",
                          Measure=meas, Units="mL",
                          Value=round(sum(used) / len(used), 3),
                          n_sources=len(d), n_teams=len(tv), n_teams_primary=len(prim),
                          primary_used=len(prim) > 0, Teams="; ".join(sorted(tv)),
                          roles="; ".join(sorted({r["role"] for r in d})),
                          sex_scope="; ".join(sorted({r["sex_scope"] for r in d})),
                          value_min=round(min(vals), 3), value_max=round(max(vals), 3)))
    if len(tv) > 1:
        spread = max(tmean.values()) / min(tmean.values()) if min(tmean.values()) else ""
        cmp_rows.append(dict(Species=sp, Measure=meas, n_teams=len(tv),
                             per_team=" | ".join(f"{t}={round(m, 2)}" for t, m in
                                                 sorted(tmean.items())),
                             pooled=round(sum(used) / len(used), 3),
                             ratio_max_over_min=round(spread, 3) if spread else "",
                             flag="DISAGREEMENT>1.5x" if spread and spread > 1.5 else ""))

LONG_COLS = ["Species", "measure_class", "Measure", "Units", "Value", "n_sources", "n_teams",
             "n_teams_primary", "primary_used", "Teams", "roles", "sex_scope",
             "value_min", "value_max"]
with open(os.path.join(HERE, "endocranial_volume_long.csv"), "w", newline="",
          encoding="utf-8") as fh:
    w = csv.DictWriter(fh, fieldnames=LONG_COLS)
    w.writeheader()
    w.writerows(long_rows)
with open(os.path.join(HERE, "endocranial_volume_wide.csv"), "w", newline="",
          encoding="utf-8") as fh:
    w = csv.writer(fh)
    meas_order = sorted({r["Measure"] for r in long_rows})
    w.writerow(["Species"] + [m + ".mL" for m in meas_order])
    wide = defaultdict(dict)
    for r in long_rows:
        wide[r["Species"]][r["Measure"]] = r["Value"]
    for sp in sorted(wide):
        w.writerow([sp] + [wide[sp].get(m, "") for m in meas_order])
cmp_rows.sort(key=lambda r: -(r["ratio_max_over_min"] or 0))
with open(os.path.join(HERE, "endocranial_volume_team_comparison.csv"), "w", newline="",
          encoding="utf-8") as fh:
    w = csv.DictWriter(fh, fieldnames=["Species", "Measure", "n_teams", "per_team", "pooled",
                                       "ratio_max_over_min", "flag"])
    w.writeheader()
    w.writerows(cmp_rows)

print(f"harvested {len(U)} rows | dropped {len(dedupe)} reprints | pooled {len(long_rows)} cells",
      file=sys.stderr)
for m in sorted({r["Measure"] for r in long_rows}):
    print(f"  {m:28s} {sum(1 for r in long_rows if r['Measure'] == m):4d} species",
          file=sys.stderr)
for t in sorted({r["Team"] for r in U}):
    sub = [r for r in U if r["Team"] == t]
    print(f"  {t:10s} {len(sub):4d} rows, {len({r['Species'] for r in sub}):4d} species,"
          f" role {sub[0]['role']}", file=sys.stderr)
print(f"  species with >1 team: {len(cmp_rows)} (>1.5x apart: "
      f"{sum(1 for r in cmp_rows if r['flag'])})", file=sys.stderr)
