#!/usr/bin/env python3
"""Rank un-ingested EndNote papers by how likely they carry species-level
comparative trait data relevant to Evo-M1.

Features per paper, from the text EndNote already extracted:
  n_species   distinct Evo-M1 reference species named in the paper
  measure     hits on volume/mass/count measurement vocabulary
  tables      how many numbered tables the paper appears to have
  primary     wording suggesting own measurements rather than a re-report
  review      wording suggesting a review/meta-analysis
"""

import csv, json, re, sqlite3
from collections import Counter

PROJ = "/sessions/peaceful-charming-feynman/mnt/Evo-M1-Trait-Data"
PDB = "/sessions/peaceful-charming-feynman/mnt/References.Data/sdb/pdb.eni"

# ---- Evo-M1 species scope -------------------------------------------------
species = set()
for fn, col in [("species_reference.csv", "accepted_name"), ("species_taxonomy.csv", "Species")]:
    with open(f"{PROJ}/_keys/{fn}") as fh:
        for row in csv.DictReader(fh):
            s = (row.get(col) or "").strip()
            if re.fullmatch(r"[A-Z][a-z]+ [a-z]+", s):
                species.add(s)
print(f"Evo-M1 species scope: {len(species)}")

# One cheap pass extracting "Genus species" / "G. species" shaped bigrams, then
# set-intersect. A 600-way alternation regex over 45 MB is far too slow.
KEYS = {f"{s.split()[0][0]}{s.split()[1]}".lower() for s in species}
BIGRAM = re.compile(r"\b([A-Z][a-z]{2,}|[A-Z])\.?\s+([a-z]{3,})\b")


def species_hits(txt: str) -> set[str]:
    return {k for g, sp in BIGRAM.findall(txt)
            if (k := f"{g[0]}{sp}".lower()) in KEYS}

MEASURE = re.compile(
    r"\bmm\s?3\b|\bmm³|\bcm\s?3\b|\bcm³|\bmg\b|\bgram\b|volume[sd]?\b|"
    r"\bmass\b|\bweight\b|neuron numbers?|cell counts?|\bdensit|surface area",
    re.I)
TABLE = re.compile(r"\btable\s+([0-9]{1,2}|[IVX]{1,4})\b", re.I)
PRIMARY = re.compile(
    r"\bwe measured\b|\bwere measured\b|\bspecimens?\b|\bperfus|\bNissl\b|"
    r"stereolog|\bcavalieri\b|isotropic fractionat|\bautopsy\b|\bformalin\b|"
    r"\bsectioned\b|our sample|\bhistolog", re.I)
REVIEW = re.compile(
    r"\bwe review\b|this review\b|\bmeta-analys|literature search|"
    r"\bcompiled from\b|\bdata were taken from\b|\btaken from the literature\b|"
    r"published (?:data|values|estimates)", re.I)

gaps = json.load(open("gap_unique.json"))
by_group = json.load(open("gap_by_group.json"))
group_of = {}
for name, g in by_group.items():
    for p in g["gap"]:
        group_of.setdefault(p["id"], []).append(name)

con = sqlite3.connect(f"file:{PDB}?mode=ro", uri=True)
out = []
for p in gaps:
    rows = con.execute(
        "SELECT contents FROM pdf_index WHERE refs_id=?", (p["id"],)).fetchall()
    txt = "\n".join(r[0] for r in rows)
    if not txt.strip():
        p |= {"n_species": 0, "measure": 0, "tables": 0, "primary": 0,
              "review": 0, "indexed": False, "groups": group_of.get(p["id"], [])}
        out.append(p)
        continue
    p |= {
        "n_species": len(species_hits(txt)),
        "measure": len(MEASURE.findall(txt)),
        "tables": len({m.group(1).upper() for m in TABLE.finditer(txt)}),
        "primary": len(PRIMARY.findall(txt)),
        "review": len(REVIEW.findall(txt)),
        "indexed": True,
        "groups": group_of.get(p["id"], []),
        "chars": len(txt),
    }
    out.append(p)

# rank: species breadth dominates, measurement density confirms it's a data paper
for p in out:
    p["score"] = round(
        p["n_species"] * 3
        + min(p["measure"], 120) * 0.25
        + p["tables"] * 1.5
        + min(p["primary"], 30) * 0.5
        - min(p["review"], 10) * 1.0, 1)

out.sort(key=lambda p: -p["score"])
json.dump(out, open("gap_scored.json", "w"), indent=2)

print(f"scored {len(out)} papers; {sum(1 for p in out if not p['indexed'])} had no text\n")
print(f"{'score':>6} {'spp':>4} {'meas':>5} {'tbl':>4} {'pri':>4} {'rev':>4}  cite / title")
print("-" * 118)
for p in out[:35]:
    print(f"{p['score']:>6} {p['n_species']:>4} {p['measure']:>5} {p['tables']:>4} "
          f"{p['primary']:>4} {p['review']:>4}  [{p['id']}] {p['cite']} — {p['title'][:62]}")
    print(f"{'':>32}  {', '.join(p['groups'])[:100]}")

print("\n\nSpecies-breadth leaders (>=25 Evo-M1 species):")
for p in sorted([q for q in out if q["n_species"] >= 25], key=lambda q: -q["n_species"]):
    print(f"  {p['n_species']:>3} spp  [{p['id']}] {p['cite']:<24} {p['title'][:70]}")
