#!/usr/bin/env python3
"""
audit_cytosplore_variables.py -- source-role and poolability audit of the
variables exported for the Cytosplore viewer.

Run AFTER build_cytosplore_traits.R (it reads that script's output):

    python3 __Cytosplore_export/audit_cytosplore_variables.py            # EvoM1
    python3 __Cytosplore_export/audit_cytosplore_variables.py V1 species
    python3 __Cytosplore_export/audit_cytosplore_variables.py HMBA genus    # reads output/HMBA_genus/

Standard library only. Two questions, answered per exported variable:

 Q1  SECONDARY vs PRIMARY.  Which paper folders contribute each species x
     variable cell of the cohort, and in what role (primary measurement vs
     secondary compilation)?  For cells fed ONLY by compilations: does a
     primary value exist in the compiled database for the same species and
     the same structure x measure (any variable of the same compatibility
     group), and do source_relationships.csv rows declare a better version
     (supersedes / reprints / derives_from) for the contributing papers?

 Q2  POOLABILITY.  Which exported variables measure the same structure x
     measure (variable_catalog_compatibility / variable_domain
     canonical_structure + measure_class), and how many extra cohort species
     would pooling them give?  Variables with DIFFERENT non-empty
     poolable_group values are the same family but a different measurement
     basis and are reported as "do not pool".

Roles come from the data, not from judgement:
  * per-cell `roles` / `data_role` / `Data_role` / `role` columns where a merge
    has them (body_ecology, brain_mass, behaviour, cerebellar_folding,
    endocranial_volume, sensory, cell_morphology, GLI, weights);
  * otherwise the paper's role profile in _keys/variable_catalog.csv (count of
    primary vs secondary Codes), resolved from the source id in the merge.
  * cerebral_metabolic_rate is built from compilations resolved to primary
    studies and is reported as such.

Outputs (__Cytosplore_export/output/<cohort>/):
  <cohort>_variable_audit.csv      one row per exported variable
  <cohort>_secondary_only_cells.csv  species x variable cells fed only by
                                   compilations, with primary-availability
  <cohort>_pooling_candidates.csv  one row per compatibility group with >= 2
                                   exported variables
  AUDIT_SUMMARY.md                 counts and the flagged cases
"""
import csv, os, re, sys, unicodedata, collections, datetime

csv.field_size_limit(10 ** 8)
COHORT = sys.argv[1] if len(sys.argv) > 1 and sys.argv[1] else "EvoM1"
LEVEL = (sys.argv[2] if len(sys.argv) > 2 and sys.argv[2] else "species").lower()
if LEVEL not in ("species", "genus"):
    sys.exit("match level must be 'species' or 'genus'")
PREFIX = f"{COHORT}_genus" if LEVEL == "genus" else COHORT
HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(HERE)
OUT = os.path.join(HERE, "output", PREFIX)
if not os.path.isdir(OUT):
    sys.exit(f"{OUT} not found -- run build_cytosplore_traits.R first")

def rd(path):
    with open(path, encoding="utf-8-sig", newline="") as f:
        return list(csv.DictReader(f))

def strip_acc(s):
    return "".join(c for c in unicodedata.normalize("NFKD", s) if not unicodedata.combining(c))

# ---------------------------------------------------------------- keys
species_tbl = rd(os.path.join(OUT, f"{PREFIX}_species.csv"))
dictionary  = rd(os.path.join(OUT, f"{PREFIX}_variable_dictionary.csv"))
cells       = rd(os.path.join(OUT, f"{PREFIX}_traits_cells.csv"))
longtab     = rd(os.path.join(OUT, f"{PREFIX}_traits_long.csv"))
# sources already pooled per cell by the merges (n_sources where the merge
# reports it, else the number of long rows behind the cell)
_ns = collections.defaultdict(list)
for r in longtab:
    n = r.get("n_sources") or ""
    _ns[(r["species_sci"], r["variable"])].append(int(float(n)) if n.strip() else 1)
sources_per_cell = {k: max(v) if len(v) == 1 else sum(v) for k, v in _ns.items()}
aliases     = {r["variant"]: r["canonical"] for r in rd(os.path.join(REPO, "_keys/species_display_aliases.csv"))}
vdom        = {r["label"]: r for r in rd(os.path.join(REPO, "_keys/variable_domain.csv"))}
authority   = {r["label"]: r for r in rd(os.path.join(REPO, "_keys/trait_authority.csv"))}
catalog     = rd(os.path.join(REPO, "_keys/variable_catalog.csv"))
compat      = rd(os.path.join(REPO, "_keys/variable_catalog_compatibility.csv"))
srel        = rd(os.path.join(REPO, "_keys/source_relationships.csv"))

# cohort species -> the labels its data live under (post-alias), plus the
# pre-alias variants the merge files actually print
label_to_sci = {}
for r in species_tbl:
    for lab in [x.strip() for x in r["data_labels"].split(";") if x.strip()]:
        label_to_sci[lab] = r["species_sci"]
        for var, canon in aliases.items():
            if canon == lab:
                label_to_sci[var] = r["species_sci"]
cohort_sci = [r["species_sci"] for r in species_tbl]
export_vars = {r["variable"]: r for r in dictionary}

# species per exported variable (cohort), from the cells table
var_species = collections.defaultdict(set)
for c in cells:
    var_species[c["variable"]].add(c["species_sci"])

# paper folders in the repo
folders = sorted(d for d in os.listdir(REPO)
                 if os.path.isdir(os.path.join(REPO, d)) and not d.startswith(("_", ".")))
folder_set = set(folders)
folder_plain = {strip_acc(f).lower(): f for f in folders}

def folder_of_source(src):
    """'MacLeod_etal_2003_Table1' -> 'MacLeod_etal_2003'; 'Latimer__1942_TABLEI.csv' -> 'Latimer__1942'."""
    s = re.sub(r"\.csv$", "", src.strip())
    parts = s.split("_")
    for k in range(len(parts), 0, -1):
        cand = "_".join(parts[:k])
        if cand in folder_set:
            return cand
        c2 = folder_plain.get(strip_acc(cand).lower())
        if c2:
            return c2
    return ""

def folders_of_citation(cit):
    """'Heffner & Masterton 1975 (corticospinal tract)' -> folders starting with Heffner and ending _1975."""
    m = re.match(r"\s*([A-Za-z\u00C0-\u024F'\-]+)", cit)
    y = re.search(r"\b(1[89]\d\d|20\d\d)[a-z]?\b", cit)
    if not m or not y:
        return []
    au = strip_acc(m.group(1)).lower(); yr = y.group(1)
    return [f for f in folders if strip_acc(f).lower().startswith(au) and re.search(rf"_{yr}(_[ab])?$", f)]

def folders_of_team(team):
    t = team.strip()
    if not t:
        return []
    if t in folder_set:
        return [t]
    t2 = re.sub(r"_collection$", "", t)
    m = re.match(r"([A-Za-z\u00C0-\u024F]+)_?(\d{4})?", t2)
    au = strip_acc(m.group(1)).lower() if m else strip_acc(t2).lower()
    yr = m.group(2) if m and m.group(2) else None
    hits = [f for f in folders if strip_acc(f).lower().startswith(au + "_") or strip_acc(f).lower().startswith(au + "__")]
    if yr:
        hits = [f for f in hits if yr in f] or hits
    return hits

# paper role profile from variable_catalog.csv
PRIM = {"primary", "both", "primary_or_secondary"}
SEC = {"secondary"}
prof = collections.defaultdict(lambda: collections.Counter())
all_roles = collections.defaultdict(collections.Counter)
for r in catalog:
    all_roles[r["paper"]][(r["role"] or "").strip() or "(blank)"] += 1
for r in catalog:
    role = (r["role"] or "").strip()
    if role in PRIM: prof[r["paper"]]["primary"] += 1
    elif role in SEC: prof[r["paper"]]["secondary"] += 1
    elif role.startswith("primary/secondary"): prof[r["paper"]]["primary"] += 1; prof[r["paper"]]["secondary"] += 1
def paper_class(paper):
    p = prof.get(paper)
    if not p: return "unknown"
    if p["secondary"] and not p["primary"]: return "secondary"
    if p["primary"] and not p["secondary"]: return "primary"
    return "mixed"
def class_of_folders(fs):
    cl = {paper_class(f) for f in fs} - {"unknown"}
    if not cl: return "unknown"
    if cl == {"secondary"}: return "secondary"
    if cl == {"primary"}: return "primary"
    return "mixed"

# ---------------------------------------------------------------- merge adapters
# Each yields (species_label, variable_label, papers:list, roles:set, note)
def split_list(s):
    return [x.strip() for x in (s or "").split(";") if x.strip()]

def ad_std_merge(path):
    for r in rd(path):
        lab = f'{r["Measure"]} ({r["Units"]})'
        teams = split_list(r["Teams"]); roles = set(split_list(r["roles"])) - {"info"}
        # a merge "team" may be one folder or a whole lab's series; keep the
        # team name when it is ambiguous so folder-level counts stay honest
        papers = []
        for t in teams:
            fs = folders_of_team(t)
            papers.append(fs[0] if len(fs) == 1 else f"{t} (team)")
        yield r["Species"], lab, sorted(set(papers)), roles, f'primary_used={r.get("primary_used","")}'

def ad_volumes(path):
    for r in rd(path):
        srcs = split_list(r["Sources"]); papers = sorted({folder_of_source(s) or s for s in srcs})
        roles = set()
        for p in papers:
            c = paper_class(p)
            if c in ("primary", "mixed"): roles.add("primary")
            if c in ("secondary", "mixed"): roles.add("secondary")
        yield r["Species"], r["Variable"], papers, roles, f'teams={r["Teams"]}'

def ad_simple_source(path, species_col, var_col, src_col, val_col=None):
    for r in rd(path):
        if val_col and not (r.get(val_col) or "").strip():
            continue
        p = folder_of_source(r[src_col]) or r[src_col]
        c = paper_class(p); roles = set()
        if c in ("primary", "mixed"): roles.add("primary")
        if c in ("secondary", "mixed"): roles.add("secondary")
        yield r[species_col], r[var_col], [p], roles, ""

CITATION_LIKE = re.compile(r"^(\d+|[A-Z][A-Z\-]+(,| and | et al| AND ).*|DERIVED.*)$")
def ad_traits(path):
    rows = rd(path)
    # The EvoM1 trait table records, for some cells, the ORIGINAL reference the
    # compiling paper cites ("PETRAS, 1968", or a bare reference number) rather
    # than the compiling paper. Those cells are secondary, and the primary is
    # not in the repo. Infer the compilation from the variable: the folder most
    # rows of that variable resolve to.
    comp_of_var = collections.defaultdict(collections.Counter)
    for r in rows:
        fs = folders_of_citation(r["Source"])
        if fs: comp_of_var[r["Variable"]][fs[0]] += 1
    for r in rows:
        fs = folders_of_citation(r["Source"])
        if not fs and CITATION_LIKE.match(r["Source"].strip()):
            comp = comp_of_var[r["Variable"]].most_common(1)
            # __ShinyApp/build_data.R: per-cell "_Ref" columns exist only in
            # dexterity_corticospinaltract.xlsx (Heffner & Masterton 1975), whose
            # Table 1 compiles tract depth/length/lamina data from earlier studies.
            comp = comp[0][0] if comp else "Heffner_Masterton_1975"
            yield (r["Species"], r["Variable"], [comp], {"secondary"},
                   f'cited within compilation: {r["Source"].strip()}; primary not in database')
            continue
        roles = set(); c = class_of_folders(fs)
        if c in ("primary", "mixed"): roles.add("primary")
        if c in ("secondary", "mixed"): roles.add("secondary")
        yield r["Species"], r["Variable"], fs or [r["Source"]], roles, ""

def ad_cmr(path):
    for r in rd(path):
        lab = f'{r["Region"]}_{r["Measure"]} ({r["Units"]})'
        comps = split_list(r["Compilations"])
        yield r["Species"], lab, comps, {"secondary"}, f'compilation resolved to {r["n_studies"]} primary studies'

def ad_gli(path):
    for r in rd(path):
        lab = f'GLI_{r["area_as_published"]}_{r["stratum"]} (%)'
        yield r["Species"], lab, [folder_of_source(r["source"]) or r["source"]], {r["data_role"]}, f'source_role={r["source_role"]}'

def ad_cortical_areas(path):
    for r in rd(path):
        if r["status"] != "active": continue
        p = folder_of_source(r["source"]) or r["source"]; c = paper_class(p); roles = set()
        if c in ("primary", "mixed"): roles.add("primary")
        if c in ("secondary", "mixed"): roles.add("secondary")
        yield r["Species"], r["Standardized_Term"], [p], roles, ""

def ad_cortical_layers(path):
    for r in rd(path):
        if r["merge_default"] != "TRUE" or not r["value"].strip(): continue
        meas = "Thickness_abs" if r["measure"] == "absolute thickness" else "Thickness_prop"
        layer = re.sub(r"[^A-Za-z0-9]+", "_", r["layer"])
        lab = f'M1_Layer{layer}_{meas} ({r["unit"]})'
        p = folder_of_source(r["source"]) or r["source"]; c = paper_class(p); roles = set()
        if c in ("primary", "mixed"): roles.add("primary")
        if c in ("secondary", "mixed"): roles.add("secondary")
        yield r["Species"], lab, [p], roles, r.get("value_basis", "")

def ad_cell_morphology(path):
    for r in rd(path):
        if r["merge_default"] != "TRUE": continue
        val = r["value"] if r["value"].strip() else r["value_text"]
        if not val.strip(): continue
        lab = f'{r["variable_label"]} ({r["unit"]})'
        yield r["Species"], lab, [folder_of_source(r["source"]) or r["source"]], {r["data_role"]}, ""

def ad_sensory(path):
    for r in rd(path):
        srcs = split_list(r["Sources"]) or [f'EvoM1 sensory merge ({r["n_studies"]} studies)']
        papers = sorted({folder_of_source(s) or s for s in srcs})
        yield r["Species"], r["Measure"], papers, {r["Data_role"]}, f'value_origin={r["value_origin"]}; studies={r["Study_keys"]}'

def ad_weights(path):
    for r in rd(path):
        if not (r["canonical_structure"] or "").strip(): continue
        lab = f'{r["canonical_structure"]}_Mass (g)'
        yield r["Species"], lab, [folder_of_source(r["source"]) or r["source"]], {r["role"]}, r["derivation"]

def ad_term(path, src_col="source"):   # sleep, gyrification
    for r in rd(path):
        p = folder_of_source(r[src_col]) or r[src_col]; c = paper_class(p); roles = set()
        if c in ("primary", "mixed"): roles.add("primary")
        if c in ("secondary", "mixed"): roles.add("secondary")
        lab = r["Standardized_Term"]
        yield r["Species"], lab, [p], roles, ""

def ad_fossil(path):
    for r in rd(path):
        yield r["Species"], f'Fossil_{r["Measure"]} ({r["Units"]}) - {r["Team"]}', [r["Source"]], {"derived"}, r["Scope"]
        yield r["Species"], f'Fossil_{r["Measure"]}_Ratio_MH - {r["Team"]}', [r["Source"]], {"derived"}, r["Scope"]

M = lambda *p: os.path.join(REPO, *p)
ADAPTERS = [
    ("Body & ecology",            ad_std_merge(M("__merging_body_ecology/body_ecology_long.csv"))),
    ("Brain mass",                ad_std_merge(M("__merging_brain_mass/brain_mass_long.csv"))),
    ("Endocranial volume",        ad_std_merge(M("__merging_endocranial_volume/endocranial_volume_long.csv"))),
    ("Behaviour",                 ad_std_merge(M("__merging_behaviour/behaviour_long.csv"))),
    ("Cerebellar folding",        ad_std_merge(M("__merging_cerebellar_folding/cerebellar_folding_long.csv"))),
    ("Brain-structure volumes",   ad_volumes(M("__merging_volumes/volumes_long.csv"))),
    ("Cell counts",               ad_simple_source(M("__merging_cellcounts/cellcounts_long.csv"), "Species", "Variable", "Source")),
    ("EvoM1 traits",              ad_traits(M("__ShinyApp/data/evom1_traits_long.csv"))),
    ("Cerebral metabolic rate",   ad_cmr(M("__merging_cerebral_metabolic_rate/cerebral_metabolic_rate_long.csv"))),
    ("Grey-level index",          ad_gli(M("__merging_GLI/GLI_long.csv"))),
    ("Cortical areas & surfaces", ad_cortical_areas(M("__merging_cortical_areas/cortical_areas_long.csv"))),
    ("Cortical layer thickness",  ad_cortical_layers(M("__merging_cortical_layers/cortical_layers_m1_long.csv"))),
    ("Cell type, size & morphology", ad_cell_morphology(M("__merging_cell_morphology/cell_morphology_long.csv"))),
    ("Sensory performance",       ad_sensory(M("__merging_sensory/sensory_long.csv"))),
    ("Brain-part weights",        ad_weights(M("__merging_weights/weights_long.csv"))),
    ("Gyrification (GI)",         ad_term(M("__merging_gyrification/gyrification_long.csv"))),
    ("Fossil brain glucose",      ad_fossil(M("__merging_fossil_brain_glucose/fossil_brain_glucose_long.csv"))),
]
# sleep merge is folded into the EvoM1-traits bucket by the app; include its rows anyway
ADAPTERS.append(("Sleep", ad_term(M("__merging_sleep/sleep_long.csv"))))

# variable_canonical supersession renames raw labels (e.g. Body_Mass.g -> Body_Mass (g));
# cover the renamed labels by also keying on canonical names
canon = rd(M("_keys/variable_canonical.csv"))
rename = {}
for r in canon:
    if (r.get("action") or "") == "supersede":
        rename[r["raw_variable"]] = (f'{r["canonical_variable"]} ({r["canonical_unit"]})'
                                     if r["canonical_unit"] and not r["canonical_variable"].endswith(")")
                                     else r["canonical_variable"])

# ---------------------------------------------------------------- collect cell provenance
# cell key: (species_sci, variable) -> list of (dataset, papers, roles, note)
cellprov = collections.defaultdict(list)
unmapped_sources = collections.Counter()
for dataset, gen in ADAPTERS:
    for sp_label, lab, papers, roles, note in gen:
        sp_label = aliases.get(sp_label, sp_label)
        sci = label_to_sci.get(sp_label)
        if not sci:
            continue
        labs = {lab}
        if lab in rename: labs.add(rename[lab])
        if lab in export_vars or any(l in export_vars for l in labs):
            for l in labs:
                if l in export_vars:
                    cellprov[(sci, l)].append((dataset, papers, roles, note))
        for p in papers:
            if p and p not in folder_set and not p.startswith("EvoM1 ") and not p.endswith("(team)"):
                unmapped_sources[p] += 1

# ---------------------------------------------------------------- compatibility groups
def compat_key_of(label):
    """Group of variables that are candidate estimates of the same quantity.
    Authority order: the curated poolable_family in variable_domain.csv; else
    canonical_structure x measure_class when the structure is specific. A
    structure-agnostic label without a family gets NO group: inventing one
    (e.g. Gait with Limb_posture because both are 'locomotion') is exactly the
    kind of decision that must be made by a curator, not a script."""
    d = vdom.get(label)
    if not d: return ""
    fam = (d.get("poolable_family") or "").strip()
    if fam: return f"family: {fam}"
    cs = (d.get("canonical_structure") or d.get("Structure") or "").strip()
    mc = (d.get("measure_class") or "").strip()
    if cs and not cs.startswith("(structure-agnostic") and mc:
        return f"{cs} | {mc}"
    return ""
def group_basis_of(label):
    d = vdom.get(label, {})
    if (d.get("poolable_family") or "").strip(): return "poolable_family"
    cs = (d.get("canonical_structure") or d.get("Structure") or "").strip()
    if cs and not cs.startswith("(structure-agnostic"): return "structure x measure_class"
    return "none (structure-agnostic label without poolable_family)"
compat_papers = {r["compat_key"]: r for r in compat}
groups = collections.defaultdict(list)
for v in export_vars:
    k = compat_key_of(v)
    if k: groups[k].append(v)

# primary availability per (species, compat group): any cell in the group with a primary role
group_primary_species = collections.defaultdict(set)
for (sci, v), provs in cellprov.items():
    k = compat_key_of(v)
    if k and any("primary" in roles for _, _, roles, _ in provs):
        group_primary_species[k].add(sci)

# declared relationships touching a paper
rel_by_paper = collections.defaultdict(list)
for r in srel:
    if r["relationship"] in ("supersedes", "reprints", "derives_from", "extends_sample"):
        s = f'{r["pair_id"]}: {r["paper_b"]} {r["relationship"]} {r["paper_a"]} -> {r["direction"]}'
        rel_by_paper[r["paper_a"]].append(s); rel_by_paper[r["paper_b"]].append(s)

# ---------------------------------------------------------------- per-variable audit
audit_rows, sec_rows = [], []
for v, d in export_vars.items():
    sps = sorted(var_species[v])
    papers_all = collections.Counter(); roles_all = collections.Counter()
    n_prim = n_sec_only = n_unknown = n_mixed = 0
    sec_papers = collections.Counter()
    k = compat_key_of(v)
    for sci in sps:
        provs = cellprov.get((sci, v), [])
        roles = set().union(*[r for _, _, r, _ in provs]) if provs else set()
        ps = sorted({p for _, pp, _, _ in provs for p in pp})
        for p in ps: papers_all[p] += 1
        for r in roles: roles_all[r] += 1
        if not provs or not roles:
            n_unknown += 1
        elif "primary" in roles:
            n_prim += 1
            if "secondary" in roles: n_mixed += 1
        else:
            n_sec_only += 1
            for p in ps: sec_papers[p] += 1
            prim_avail = sci in group_primary_species.get(k, set())
            prim_vars = sorted({v2 for v2 in groups.get(k, []) if v2 != v and
                                any("primary" in r for _, _, r, _ in cellprov.get((sci, v2), []))})
            rels = sorted({s for p in ps for s in rel_by_paper.get(p, [])})
            sec_rows.append({"species_sci": sci, "variable": v, "domain": d["domain"],
                             "compilations": "; ".join(ps), "roles": "; ".join(sorted(roles)),
                             "primary_available_same_group": prim_avail,
                             "primary_variables_same_group": "; ".join(prim_vars),
                             "declared_relationships": " | ".join(rels),
                             "note": " | ".join(sorted({n for _, _, _, n in provs if n}))[:300]})
    paper_classes = {p: paper_class(p) for p in papers_all}
    comp_row = compat_papers.get(k)
    group_primary_papers = ""
    if comp_row:
        cp = [p.strip() for p in comp_row["papers"].split(";")]
        group_primary_papers = "; ".join(sorted(p for p in cp if paper_class(p) == "primary" and p not in papers_all))
    rels = sorted({s for p in papers_all for s in rel_by_paper.get(p, [])})
    auth = authority.get(v, {})
    # pooling
    members = [v2 for v2 in groups.get(k, []) if v2 != v]
    pg = (vdom.get(v, {}).get("poolable_group") or "").strip()
    poolable, nonpool = [], []
    for v2 in members:
        pg2 = (vdom.get(v2, {}).get("poolable_group") or "").strip()
        (poolable if (pg == pg2 or not pg or not pg2) else nonpool).append(v2)
    union = set(sps).union(*[var_species[v2] for v2 in poolable]) if poolable else set(sps)
    gain = len(union) - len(sps)
    flags = []
    if len(sps) < 3: flags.append("low_n(<3 species)")
    if n_sec_only and n_prim == 0: flags.append("secondary_only")
    if any(r["primary_available_same_group"] for r in sec_rows if r["variable"] == v): flags.append("primary_available_for_some_secondary_cells")
    if rels: flags.append("declared_relationship_among_sources")
    if auth and auth.get("status") not in ("", "active"): flags.append(f'authority_{auth.get("status")}')
    if auth and auth.get("other_producers"): flags.append("multiple_producers")
    if gain >= 3: flags.append(f"pool_gain_{gain}")
    if nonpool: flags.append("same_family_different_basis")
    if re.search(r"_(left|right)_|_(L|R)_|\b(left|right)\b", v, re.I): flags.append("laterality_variant")
    if n_unknown: flags.append(f"role_unknown_{n_unknown}_cells")
    # transparent summary labels for filtering (rules, not judgement)
    n_sp = len(sps)
    tier = ("core (>=20 sp)" if n_sp >= 20 else "broad (10-19 sp)" if n_sp >= 10
            else "sparse (3-9 sp)" if n_sp >= 3 else "minimal (<3 sp)")
    cited = any("cited within compilation" in r["note"] for r in sec_rows if r["variable"] == v)
    if n_prim and not n_sec_only: src_class = "primary-backed"
    elif n_prim and n_sec_only: src_class = "mixed (some species compilation-only)"
    elif n_sec_only and cited: src_class = "compilation of earlier literature; primaries not in database"
    elif n_sec_only: src_class = "compilation-only"
    else: src_class = "role unknown (source lacks role in definitions)"
    audit_rows.append({
        "variable": v, "domain": d["domain"], "datasets": d["datasets"], "unit": d["unit"],
        "n_species": len(sps), "suggested_tier": tier, "source_class": src_class,
        "in_core": d["in_core"], "m1_motor_related": d["m1_motor_related"],
        "n_papers": len(papers_all),
        "papers": "; ".join(f"{p} [{paper_classes[p][:4]}]" for p in sorted(papers_all)),
        "cells_with_primary": n_prim, "cells_primary_and_secondary": n_mixed,
        "cells_secondary_only": n_sec_only, "cells_role_unknown": n_unknown,
        "compilations_used": "; ".join(sorted(sec_papers)),
        "species_secondary_only_with_primary_in_group": "; ".join(
            sorted(r["species_sci"] for r in sec_rows if r["variable"] == v and r["primary_available_same_group"])),
        "primary_papers_in_group_not_used": group_primary_papers,
        "declared_relationships": " | ".join(rels),
        "authority": auth.get("authority", ""), "authority_status": auth.get("status", ""),
        "other_producers": auth.get("other_producers", ""),
        "sources_per_cell_mean": round(sum(sources_per_cell.get((sci, v), 1) for sci in sps) / len(sps), 2) if sps else 0,
        "cells_multi_source": sum(1 for sci in sps if sources_per_cell.get((sci, v), 1) > 1),
        "group_key": k, "group_basis": group_basis_of(v), "poolable_group": pg,
        "poolable_family": (vdom.get(v, {}).get("poolable_family") or "").strip(),
        "pool_candidates_same_basis": "; ".join(sorted(poolable)),
        "pool_species_gain": gain, "pool_union_species": len(union),
        "same_family_different_basis": "; ".join(sorted(nonpool)),
        "flags": "; ".join(flags),
    })

# ---------------------------------------------------------------- pooling candidates
pool_rows = []
for k, vs in groups.items():
    if len(vs) < 2: continue
    by_basis = collections.defaultdict(list)
    for v in vs: by_basis[(vdom.get(v, {}).get("poolable_group") or "").strip()].append(v)
    union_all = set().union(*[var_species[v] for v in vs])
    best = max(len(var_species[v]) for v in vs)
    pool_rows.append({
        "group_key": k, "n_variables": len(vs),
        "variables": "; ".join(f"{v} [{len(var_species[v])}]" for v in sorted(vs, key=lambda x: -len(var_species[x]))),
        "bases": "; ".join(f'{b or "(none)"}: {len(x)}' for b, x in by_basis.items()),
        "n_bases": len([b for b in by_basis if b]),
        "best_single_species": best, "union_species": len(union_all), "gain_if_pooled": len(union_all) - best,
        "catalog_papers": (compat_papers.get(k, {}).get("papers") or "")[:300],
        "recommendation": ("do not pool across bases; pool within a basis only" if len([b for b in by_basis if b]) > 1
                           else ("candidate: review definitions, then pool" if len(union_all) - best >= 2
                                 else "little to gain")),
    })
pool_rows.sort(key=lambda r: -r["gain_if_pooled"])

# ---------------------------------------------------------------- write
def wcsv(rows, name):
    p = os.path.join(OUT, f"{PREFIX}_{name}.csv")
    with open(p, "w", encoding="utf-8", newline="") as f:
        w = csv.DictWriter(f, fieldnames=list(rows[0].keys())); w.writeheader(); w.writerows(rows)
    print(f"  wrote {os.path.basename(p):<40} {len(rows):>6} rows")
    return p
wcsv(audit_rows, "variable_audit")
wcsv(sec_rows or [{"species_sci": "", "variable": "", "domain": "", "compilations": "", "roles": "",
                   "primary_available_same_group": "", "primary_variables_same_group": "",
                   "declared_relationships": "", "note": ""}], "secondary_only_cells")
wcsv(pool_rows, "pooling_candidates")

# ---------------------------------------------------------------- summary
n = len(audit_rows)
cnt = lambda pred: sum(1 for r in audit_rows if pred(r))
sec_only_vars = [r for r in audit_rows if r["cells_secondary_only"] and not r["cells_with_primary"]]
prim_avail = [r for r in audit_rows if r["species_secondary_only_with_primary_in_group"]]
used_unknown = collections.Counter()
for (sci, v), provs in cellprov.items():
    for _, pp, roles, _ in provs:
        for p in pp:
            if p in folder_set and paper_class(p) == "unknown":
                used_unknown[p] += 1
by_comp = collections.Counter()
for r in sec_rows:
    for p in r["compilations"].split("; "):
        if p: by_comp[p] += 1
lines = [
    f"# {COHORT} variable audit -- sources and poolability ({LEVEL}-level match)",
    "", f"Built {datetime.date.today()} by `__Cytosplore_export/audit_cytosplore_variables.py` "
        f"from the tables in this folder and the repo keys.", "",
    "## Q1. Secondary compilations vs primary sources", "",
    f"- {n} exported variables; {sum(r['n_species'] for r in audit_rows)} species x variable cells.",
    f"- cells with at least one primary source: {sum(r['cells_with_primary'] for r in audit_rows)}",
    f"- cells fed only by compilations (secondary): {sum(r['cells_secondary_only'] for r in audit_rows)}"
    f" in {cnt(lambda r: r['cells_secondary_only'] > 0)} variables",
    f"- of those, cells where a PRIMARY value for the same species and structure x measure exists in the"
    f" compiled database (another variable of the same compatibility group): "
    f"{sum(1 for r in sec_rows if r['primary_available_same_group'])}",
    f"- cells whose role could not be resolved: {sum(r['cells_role_unknown'] for r in audit_rows)}",
    f"- variables with NO primary source at all: {len(sec_only_vars)}",
    f"- variables whose sources have a declared supersedes/reprints/derives_from relationship: "
    f"{cnt(lambda r: bool(r['declared_relationships']))}",
    "", "Compilations contributing secondary-only cells (cells):", "",
    *[f"- {p}: {c}" for p, c in by_comp.most_common(15)],
    "", "Variables with secondary-only cells for which a primary exists in the same group:", "",
    *[f"- `{r['variable']}` ({r['n_species']} sp): {r['cells_secondary_only']} secondary-only cells; primary for "
      f"{len(r['species_secondary_only_with_primary_in_group'].split('; '))} of them via {r['group_key']}"
      for r in sorted(prim_avail, key=lambda r: -r['cells_secondary_only'])[:25]],
    "", "Source class of exported variables:", "",
    *[f"- {k}: {c}" for k, c in collections.Counter(r["source_class"] for r in audit_rows).most_common()],
    "", "Suggested tier (cohort species covered):", "",
    *[f"- {k}: {c}" for k, c in sorted(collections.Counter(r["suggested_tier"] for r in audit_rows).items())],
    "", "## Q2. Poolability and individual relevance", "",
    f"- compatibility groups with >= 2 exported variables: {len(pool_rows)}",
    f"- groups where pooling would add >= 2 cohort species: {sum(1 for r in pool_rows if r['gain_if_pooled'] >= 2)}",
    f"- groups spanning more than one measurement basis (do not pool across): {sum(1 for r in pool_rows if r['n_bases'] > 1)}",
    f"- variables with < 3 cohort species: {cnt(lambda r: r['n_species'] < 3)}",
    f"- laterality (left/right) variants: {cnt(lambda r: 'laterality_variant' in r['flags'])}",
    "", "Top pooling candidates (gain in cohort species):", "",
    *[f"- {r['group_key']}: {r['n_variables']} vars, best single {r['best_single_species']} -> union "
      f"{r['union_species']} (+{r['gain_if_pooled']}); bases: {r['bases']} -- {r['recommendation']}"
      for r in pool_rows[:25] if r['gain_if_pooled'] >= 1],
    "", "## Key gaps found upstream", "",
    "Paper folders contributing to the export whose *_definitions.csv has no primary/secondary role",
    "(so their cells count as role-unknown). Fill `role` in the folder's definitions file and rebuild",
    "_keys/variable_catalog.csv:", "",
    *([f"- {p}: {c} cells; catalog roles = {dict(all_roles[p]) if all_roles.get(p) else 'no catalog rows (no *_definitions.csv in folder?)'}"
       for p, c in used_unknown.most_common(30)] or ["- none"]),
    "", f"Exported variables with no group (structure-agnostic label, no poolable_family in variable_domain.csv): "
        f"{cnt(lambda r: r['group_basis'].startswith('none'))}. These cannot be assessed for cross-variable pooling until a family is assigned.",
    "", "## Source identifiers not resolved to a repo folder", "",
    "(merge team names such as 'Lewitus (team)' are fine -- their roles come from the merge's own roles column)", "",
    *([f"- {s}: {c}" for s, c in unmapped_sources.most_common(20)] or ["- none"]),
    "", "## How to read the columns", "",
    "- `papers`: contributing folders with the paper's catalog role class in brackets (prim / seco / mixe / unkn).",
    "- `cells_secondary_only`: cohort species whose value comes only from compilations.",
    "- `species_secondary_only_with_primary_in_group`: those species for which a primary value exists in another",
    "  exported variable of the same structure x measure group -- the viewer could show that instead.",
    "- `primary_papers_in_group_not_used`: primary-role papers the catalog lists for this structure x measure that",
    "  do not contribute to this variable -- places to look for a better version.",
    "- `pool_candidates_same_basis` / `pool_species_gain`: exported variables that measure the same thing on the",
    "  same basis, and the extra cohort species pooling them would give. `same_family_different_basis` lists",
    "  variables that must NOT be pooled (different poolable_group).",
    "- Pooling is a proposal only: nothing here is pooled. A decision belongs in _keys/variable_canonical.csv or",
    "  the relevant merge, with its reason recorded.",
]
with open(os.path.join(OUT, "AUDIT_SUMMARY.md"), "w", encoding="utf-8") as f:
    f.write("\n".join(lines) + "\n")
print("\n".join(lines[:22]))
print(f"done -> {OUT}")
