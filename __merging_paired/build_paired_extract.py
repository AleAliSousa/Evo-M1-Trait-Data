#!/usr/bin/env python3
"""Paired extract: neocortex volume + brain size from the SAME source wherever possible.

Reads the merge outputs from a checkout of this repository and writes
paired_neocortex_brainmass.csv next to this script (in __merging_paired/).

Usage: python3 build_paired_extract.py [repo_root] [output_csv]
  repo_root defaults to the parent folder of __merging_paired/.

Pairing preference per species:
  1. same_item_mass    - one dataset item gives the neocortex volume (volumes merge)
                         AND a measured brain mass (brain-mass merge)
  2. same_item_volume  - one dataset item gives neocortex AND total brain volume
  3. same_team_mass    - one team gives neocortex and a measured brain mass
  4. same_team_volume  - one team gives neocortex and total brain volume
  5. none              - merged (mixed-source) values, flagged
Ties within a class: paired neocortex closest to the merged neocortex value.
Brain volume from a mass uses Stephan's density: volume = mass / 1.036.
Nr = neocortex / (brain volume - neocortex), after Dunbar / Castillo-Morales 2016.
"""
import csv, os, statistics, sys
from collections import defaultdict

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
ROOT = sys.argv[1] if len(sys.argv) > 1 else os.path.dirname(SCRIPT_DIR)
OUT = sys.argv[2] if len(sys.argv) > 2 else os.path.join(SCRIPT_DIR, "paired_neocortex_brainmass.csv")
DENSITY = 1.036

def load(p):
    return list(csv.DictReader(open(p, encoding="utf-8")))

man = {r["file"]: r["item_name"] for r in load(f"{ROOT}/__ShinyApp/data/source_manifest.csv")}
vl = load(f"{ROOT}/__merging_volumes/volumes_long.csv")
vuf = load(f"{ROOT}/__merging_volumes/volumes_unfiltered.csv")
bl = load(f"{ROOT}/__merging_brain_mass/brain_mass_long.csv")
buf = load(f"{ROOT}/__merging_brain_mass/brain_mass_unfiltered.csv")
cohort = {r["species_sci"] for r in load(f"{ROOT}/_keys/species_cohorts.csv")
          if r["cohort"] == "compiled_genome_data"}

merged_neo = {r["Species"]: float(r["Value"]) for r in vl if r["Variable"] == "Neocortex_Vol.mm3"}
merged_tot = {r["Species"]: float(r["Value"]) for r in vl if r["Variable"] == "Total_brain_net_volume_Vol.mm3"}
merged_mass = {r["Species"]: float(r["Value"]) for r in bl
               if r["Measure"] == "Brain mass (measured or estimated from volume)"}

# per (species, item): neocortex / total-volume means from the volumes side
item_vol = defaultdict(lambda: defaultdict(list))
item_team = {}
for r in vuf:
    if r["Variable"] in ("Neocortex_Vol.mm3", "Total_brain_net_volume_Vol.mm3"):
        item_vol[(r["Species"], r["Source"])][r["Variable"]].append(float(r["Value"]))
        item_team[r["Source"]] = r["Team"]
# per (species, item): measured brain-mass mean from the brain-mass side
item_mass = defaultdict(list)
item_mass_team = {}
for r in buf:
    if r["measure_emitted"] == "Brain_Mass_measured" and r["pool_eligible"] == "True":
        it = man.get(r["Source"])
        if it:
            item_mass[(r["Species"], it)].append(float(r["Value_g"]))
            item_mass_team[it] = r["Team"]

def team_agg(pairs):
    """(species, team) -> mean of item means, from a {(sp, item): {var: mean}} map."""
    out = defaultdict(dict)
    bucket = defaultdict(lambda: defaultdict(list))
    for (sp, it), d in pairs.items():
        for var, v in d.items():
            bucket[(sp, item_team.get(it, ""))][var].append(v)
    for k, d in bucket.items():
        for var, vs in d.items():
            out[k][var] = statistics.mean(vs)
    return out

item_pairs = {}
for k, d in item_vol.items():
    item_pairs[k] = {var: statistics.mean(vs) for var, vs in d.items()}
team_vol = team_agg(item_pairs)
# per (species, team): mass mean (brain-mass side) and neocortex mean (volumes side)
team_mass = {}
bucket = defaultdict(list)
for (sp, it), vs in item_mass.items():
    bucket[(sp, item_mass_team[it])].append(statistics.mean(vs))
for k, vs in bucket.items():
    team_mass[k] = statistics.mean(vs)
team_neo = {}
bucket = defaultdict(list)
for (sp, it), d in item_pairs.items():
    if "Neocortex_Vol.mm3" in d:
        bucket[(sp, item_team.get(it, ""))].append(d["Neocortex_Vol.mm3"])
for k, vs in bucket.items():
    team_neo[k] = statistics.mean(vs)

rows = []
for sp in sorted(merged_neo):
    mneo = merged_neo[sp]
    cands = []  # (rank, pairing, source, neo, brainvol, basis, mass)
    for (s2, it), d in item_pairs.items():
        if s2 != sp or "Neocortex_Vol.mm3" not in d:
            continue
        neo = d["Neocortex_Vol.mm3"]
        if (sp, it) in item_mass:
            m = statistics.mean(item_mass[(sp, it)])
            cands.append((0, "same_item_mass", it, neo, m * 1000.0 / DENSITY, "measured_mass", m))
        if "Total_brain_net_volume_Vol.mm3" in d:
            t = d["Total_brain_net_volume_Vol.mm3"]
            cands.append((1, "same_item_volume", it, neo, t, "total_volume", t * DENSITY / 1000.0))
    teams = {item_team.get(it, "") for (s2, it) in item_pairs if s2 == sp}
    for tm in teams:
        if not tm:
            continue
        neo_t = team_neo.get((sp, tm))
        if neo_t is None:
            continue
        if (sp, tm) in team_mass:
            m = team_mass[(sp, tm)]
            cands.append((2, "same_team_mass", tm, neo_t, m * 1000.0 / DENSITY, "measured_mass", m))
        d = team_vol.get((sp, tm), {})
        if "Total_brain_net_volume_Vol.mm3" in d:
            t = d["Total_brain_net_volume_Vol.mm3"]
            cands.append((3, "same_team_volume", tm, neo_t, t, "total_volume", t * DENSITY / 1000.0))
    cands = [c for c in cands if c[4] > c[3]]  # brain volume must exceed neocortex
    if cands:
        cands.sort(key=lambda c: (c[0], abs(c[3] - mneo)))
        rank, pairing, src, neo, bvol, basis, mass = cands[0]
    else:
        pairing, src, neo, basis = "none", "", mneo, "merged_combined"
        mass = merged_mass.get(sp)
        bvol = mass * 1000.0 / DENSITY if mass else None
    nr = neo / (bvol - neo) if bvol and bvol > neo else ""
    nr_m = ""
    if sp in merged_tot and merged_tot[sp] > mneo:
        nr_m = mneo / (merged_tot[sp] - mneo)
    def fmt(v):
        s = f"{v:.4f}".rstrip("0").rstrip(".")
        return s if s else "0"
    rows.append({
        "Species": sp,
        "In_compiled_genome_cohort": "yes" if sp in cohort else "no",
        "Pairing": pairing,
        "Pairing_source": src,
        "Neocortex_Vol_mm3_paired": fmt(neo),
        "Brain_mass_g_paired": fmt(mass) if mass else "",
        "Brain_size_basis": basis,
        "Brain_volume_mm3_paired": fmt(bvol) if bvol else "",
        "Nr_paired": f"{nr:.4f}" if nr != "" else "",
        "Neocortex_Vol_mm3_merged": fmt(mneo),
        "Brain_mass_g_merged_combined": fmt(merged_mass[sp]) if sp in merged_mass else "",
        "Nr_merged": f"{nr_m:.4f}" if nr_m != "" else "",
    })

with open(OUT, "w", newline="") as f:
    w = csv.DictWriter(f, fieldnames=list(rows[0].keys()))
    w.writeheader(); w.writerows(rows)

from collections import Counter
print("species:", len(rows), "| by pairing:", Counter(r["Pairing"] for r in rows))
sub = [r for r in rows if r["In_compiled_genome_cohort"] == "yes"]
print("cohort:", len(sub), "| by pairing:", Counter(r["Pairing"] for r in sub))
