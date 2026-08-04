#!/usr/bin/env python3
"""Which EndNote papers in Alexandra's data-bearing groups are NOT yet in the
Evo-M1 merge? Matches on DOI first, then normalised first-author+year."""

import json, re, sqlite3, sys, unicodedata, urllib.parse
from collections import OrderedDict
import openpyxl

PROJ = "/sessions/peaceful-charming-feynman/mnt/Evo-M1-Trait-Data"
SDB = "/sessions/peaceful-charming-feynman/mnt/References.Data/sdb/sdb.eni"

# Groups Alexandra named as holding comparative data, plus the structure-specific
# volume groups that feed ____Brain_structure_volumes.
TARGETS = OrderedDict([
    ("explicit data flags", [
        "brain structure size data",
        "brain structure metabolism data for comparing",
        "comparative_data",
        "brain structure cell composition data",
        "Brain Size Measures",
        "catarrhine aging brain structure data",
        "auditory visual evolution data refs",
        "brain structure vol life history health",
        "Brain Size Scaling",
        "brain structure size scaling",
        "brain structure size domestication",
        "cellular composition",
        "brain structure volumes MRI",
        "home range data",
    ]),
    ("project scoping", [
        "traits evo M1", "evo M1 reading list", "Stephan Zilles collections",
        "Neuroanatomical Phylogenies", "Brains and Endocrania",
    ]),
    ("trait domains already merged", [
        "gyrification", "sleep and AI etc", "Spinal Cord", "home range",
        "mating system", "metabolic cost tissues", "endocranial refs",
        "fossil hominin endocranial volume", "hominin brain component size",
        "glia", "cellular composition",
    ]),
    ("structure-specific volumes", [
        "lgn", "cerebellum", "Visual Cortex", "claustrum", "insula",
        "hippocampus", "Hippocampus regions", "prefrontal", "striatum subcomp",
        "V1 vol interindiv", "V1 traits", "sensorimotor cortex",
        "Primary Motor Cortex", "VENs", "entorhinal cortex and grid cells",
        "Perirhinal Cortex",
    ]),
])


def norm(s: str) -> str:
    s = unicodedata.normalize("NFKD", str(s or ""))
    return re.sub(r"[^a-z]", "", s.encode("ascii", "ignore").decode().lower())


def clean_doi(d: str) -> str:
    d = urllib.parse.unquote(str(d or "")).strip().lower()
    d = re.sub(r"^(https?://(dx\.)?doi\.org/|doi:\s*)", "", d)
    return "" if d.startswith(("pmid:", "isbn:", "oclc:", "umi:", "nq:")) \
        or "placeholder" in d or d in ("#n/a", "") else d


# ---- registry -------------------------------------------------------------
wb = openpyxl.load_workbook(f"{PROJ}/__ReadMe.xlsx", read_only=True, data_only=True)
rows = list(wb["Sheet1"].iter_rows(values_only=True))
ix = {h: i for i, h in enumerate(rows[0]) if h}

reg_doi, reg_ay, reg_pub = set(), set(), {}
for r in rows[1:]:
    pub = r[ix["Publication name"]]
    if not pub:
        continue
    d = clean_doi(r[ix["DOI (or Alt)"]])
    if d:
        reg_doi.add(d)
    au, yr = norm(r[ix["1st Author"]]), str(r[ix["year"]] or "").strip()
    if au and yr:
        reg_ay.add((au, yr))
    reg_pub[pub] = (au, yr, d)

# ---- endnote --------------------------------------------------------------
con = sqlite3.connect(f"file:{SDB}?mode=ro", uri=True)
con.create_collation("ENCI_Base", lambda a, b: (a > b) - (a < b))
con.row_factory = sqlite3.Row

refs = {}
for r in con.execute("SELECT * FROM refs WHERE trash_state=0"):
    refs[r["id"]] = r

sys.path.insert(0, f"{PROJ}/_tools")
import endnote as en  # reuse group parser + attachment resolver

groups = {g["name"]: g for g in en.load_groups(con)}


def status(r) -> str:
    d = clean_doi(r["electronic_resource_number"])
    if d and d in reg_doi:
        return "ingested (doi)"
    surname = norm(r["author"].split("\r")[0].split(",")[0])
    yr = re.search(r"\d{4}", r["year"] or "")
    if surname and yr and (surname, yr.group()) in reg_ay:
        return "ingested (author+year)"
    return "NOT in merge"


out = {}
print(f"{'group':<46} {'n':>4} {'in merge':>9} {'gap':>5}")
print("-" * 68)
for section, names in TARGETS.items():
    print(f"\n## {section}")
    for name in names:
        g = groups.get(name)
        if not g:
            print(f"  !! group not found: {name}")
            continue
        members = [refs[m] for m in g["members"] if m in refs]
        st = [(m, status(m)) for m in members]
        gap = [m for m, s in st if s == "NOT in merge"]
        have = len(st) - len(gap)
        print(f"  {name:<44} {len(st):>4} {have:>9} {len(gap):>5}")
        out[name] = {
            "section": section, "n": len(st), "in_merge": have,
            "gap": [{
                "id": m["id"],
                "cite": f'{m["author"].split(chr(13))[0].split(",")[0]} {m["year"]}',
                "authors": en.authors(m["author"], 3),
                "year": m["year"], "title": m["title"],
                "journal": m["secondary_title"],
                "doi": m["electronic_resource_number"],
                "pdf": en.attachments(con, m["id"]),
            } for m in gap],
        }

with open("gap_by_group.json", "w") as fh:
    json.dump(out, fh, indent=2)

allgap = {p["id"]: p for g in out.values() for p in g["gap"]}
print(f"\n\n{len(allgap)} distinct un-ingested references across these groups.")
with open("gap_unique.json", "w") as fh:
    json.dump(sorted(allgap.values(), key=lambda p: -int(
        re.search(r"\d{4}", p["year"] or "0").group() if re.search(r"\d{4}", p["year"] or "") else 0)), fh, indent=2)
