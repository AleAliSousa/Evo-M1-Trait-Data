#!/usr/bin/env python3
"""
Reference-chain resolution graph for Evo-M1-Trait-Data  (C -> B -> A).

Builds a directed citation graph at PAPER level:
    Secondary_Ref  --cites-for-data-->  Target_Ref
and resolves every edge to its terminal (root empirical) node(s).

Inputs (read-only):
  <ROOT>/*/**/*reference*.csv            per-paper reference lists (schemas normalised)
  <ROOT>/_keys/source_relationships.csv   reprints / derives_from  (later -> primary)
  <ROOT>/__ReadMe.xlsx                    registry 'Data role (primary/secondary/both)'
Outputs (to OUT dir):
  citation_edges.csv        one row per (Secondary_Ref, Target_Ref) with evidence + Resolution_Level
  root_resolution.csv       one row per edge: Primary_Ref_Terminal, path, depth, root status
  node_table.csv            one row per node: in_repo, registry role, out/in degree, node_class
  review_queue.csv          orphans / ambiguous / unverified roots / cycles for manual review
  run_summary.json          counts; the script stop()s (raises) on input problems

Stage R (review queue, same schema as the *_refs_check REVIEW_QUEUE.csv):
  <FINDINGS>/REVIEW_QUEUE.csv              one row per link needing manual review (queues R, M, K)
  <FINDINGS>/REVIEW_QUEUE_resolutions.csv  persistent decisions keyed on queue_key; joined back every run;
                                           'match_confirmed' / 'match_rejected' override the matcher.
  Queue R rows can become errata via queue_to_errata_rows() (skill evom1-errata-convention);
  queues M and K never do. See reference_chains/README.md.

Caveat: paper-level. A chain C->B->A says C cites B for data and B cites A;
it does not prove a given cell travelled that path (that is the *_refs_check job).
"""
import os, re, sys, glob, json, unicodedata, collections
_missing = []
for _mod in ("pandas", "networkx", "openpyxl"):
    try:
        __import__(_mod)
    except ImportError:
        _missing.append(_mod)
if _missing:
    _req = os.path.join(os.path.dirname(os.path.abspath(__file__)), "reference_chains", "requirements.txt")
    sys.exit(f"STOP: {sys.executable} lacks {', '.join(_missing)}.\n"
             f"  Install:  {sys.executable} -m pip install --user -r \"{_req}\"\n"
             f"  or run with an interpreter that has them (see reference_chains/README.md).")
import pandas as pd, networkx as nx

# repo root = two levels above this file (_tools/dataset_builder/), so the script runs from any cwd
ROOT = sys.argv[1] if len(sys.argv) > 1 else \
    os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
HERE = os.path.join(ROOT, "_tools", "dataset_builder", "reference_chains")
OUT = sys.argv[2] if len(sys.argv) > 2 else os.path.join(HERE, "out")
FINDINGS = sys.argv[3] if len(sys.argv) > 3 else os.path.join(HERE, "findings")
os.makedirs(OUT, exist_ok=True); os.makedirs(FINDINGS, exist_ok=True)
RES_PATH = os.path.join(FINDINGS, "REVIEW_QUEUE_resolutions.csv")
RES_COLS = ["queue_key", "resolution", "resolved_to", "evidence", "date"]
RESOLUTIONS_VOCAB = {"repo_transcription_error_fixed", "publication_ambiguity", "publication_error",
                     "match_confirmed", "match_rejected", "registry_updated", "relationship_declared",
                     "not_an_error", "deferred"}
if os.path.exists(RES_PATH):
    RES = pd.read_csv(RES_PATH, dtype=str, keep_default_na=False, encoding="utf-8-sig")
    if list(RES.columns) != RES_COLS:
        raise SystemExit(f"STOP: {RES_PATH} columns {list(RES.columns)} != {RES_COLS}")
    bad = set(RES.resolution) - RESOLUTIONS_VOCAB
    if bad:
        raise SystemExit(f"STOP: unknown resolution value(s) {bad} in {RES_PATH}")
    if RES.queue_key.duplicated().any():
        raise SystemExit("STOP: duplicated queue_key in resolutions")
else:
    RES = pd.DataFrame(columns=RES_COLS)
QK_SEP = " | "
# match overrides: queue_key = "<queue> | <paper> | <evidence file> | <ref_key> | <target>"
OVERRIDE = {}
for r in RES[RES.resolution.isin(["match_confirmed", "match_rejected"])].itertuples():
    parts = r.queue_key.split(QK_SEP)
    if len(parts) != 5 or not r.resolved_to:
        raise SystemExit(f"STOP: match resolution needs a 5-part queue_key and resolved_to: {r.queue_key}")
    OVERRIDE[(parts[1], parts[2], parts[3])] = (r.resolved_to, r.resolution)

# ---------------------------------------------------------------- helpers
NFC = lambda x: unicodedata.normalize("NFC", x) if isinstance(x, str) else x
def norm(s):
    s = unicodedata.normalize("NFKD", str(s))
    s = "".join(c for c in s if not unicodedata.combining(c))
    return re.sub(r"[^a-z]", "", s.lower())

PARTICLES = {"de", "da", "do", "dos", "das", "van", "von", "der", "den", "la", "le", "di", "du", "del", "mc"}
YEAR_RE = re.compile(r"(?<!\d)(1[6-9]\d{2}|20[0-2]\d)(?!\d)")
NONREF_RE = re.compile(r"\b(p\.\s?c\.|pers(onal)?\.?\s*comm|in prep|unpublished|this issue|present (report|study|paper)|"
                       r"this study|this paper|in press|submitted)\b", re.I)

def parse_folder(name):
    """Folder 'A_etal_1999_b' -> (surname_norm, year, pattern, suffix)."""
    toks = name.split("_")
    yi = next((i for i, t in enumerate(toks) if re.fullmatch(r"\d{4}", t)), None)
    if yi is None:
        return None
    pre = toks[:yi]
    suffix = "_".join(toks[yi + 1:])
    if len(pre) >= 2 and pre[-1] == "" :           # double underscore => single author
        pat, authors = "single", [pre[0]]
    elif "etal" in pre:
        pat, authors = "etal", [pre[0]]
    elif len(pre) == 2:
        pat, authors = "two", pre
    else:
        pat, authors = "other", [pre[0]]
    return dict(first=norm(authors[0]), second=norm(authors[1]) if pat == "two" else None,
                year=toks[yi], pattern=pat, suffix=suffix)


INIT_RE = re.compile(r"(?:[A-Z]\.?-?){1,3}\.?|[A-Z]\.-[A-Z]\.?")
SKIPTOK = {"jr", "jr.", "sr", "sr.", "eds", "eds.", "ed", "ed.", "in"}
def author_block(pre):
    """Surnames from the author block preceding the year; stops at the title."""
    toks = re.findall(r"[A-Za-zÀ-ÿ'’\-]+\.?", pre)
    kinds = []
    for t in toks:
        tl = t.lower().rstrip(".")
        if tl in ("and", "et", "al", "und"): kinds.append("CONJ")
        elif t.lower() in SKIPTOK: kinds.append("SKIP")
        elif INIT_RE.fullmatch(t) and not (len(t) > 3 and t.isupper()): kinds.append("INIT")
        else: kinds.append("WORD")
    has_init = "INIT" in kinds
    names, i = [], 0
    while i < len(toks):
        k, t = kinds[i], toks[i]
        if k != "WORD":
            i += 1; continue
        if t.lower().rstrip(".") in PARTICLES and i + 1 < len(toks) and kinds[i + 1] == "WORD":
            t2 = t + toks[i + 1]; nxt = i + 2
        else:
            t2, nxt = t, i + 1
        if not has_init:
            names.append(t2.rstrip(".")); i = nxt; continue
        nxt_init = nxt < len(toks) and kinds[nxt] in ("INIT", "SKIP")
        j = i - 1
        while j >= 0 and kinds[j] == "INIT": j -= 1
        prev_run = (j < i - 1) and (j < 0 or kinds[j] in ("CONJ", "SKIP"))
        first_init_first = (j < i - 1) and j < 0
        if nxt_init or prev_run or first_init_first:
            names.append(t2.rstrip(".")); i = nxt; continue
        if names:
            break
        i = nxt
    return names[:6]

def parse_citation(txt):
    """Return dict(first, second, year, pattern, key) or None if not identifiable."""
    if txt is None or (isinstance(txt, float) and pd.isna(txt)):
        return None
    t = str(txt).strip()
    if not t:
        return None
    t = t.replace("’", "'")
    m = YEAR_RE.search(t)
    if not m:
        m2 = re.search(r"\('(\d{2})\)", t)                  # Lassek and Rasmussen ('39)
        if not m2:
            return None
        year, pre = "19" + m2.group(1), t[:m2.start()]
    else:
        year, pre = m.group(1), t[:m.start()]
    pre = re.sub(r"^[\[\(\d\.\s]+", "", pre)              # leading numbering
    etal = bool(re.search(r"\bet\.?\s*al", pre, re.I))
    names = author_block(pre)
    if not names:
        return None
    first = names[0]
    if etal or len(names) >= 3:
        pat = "etal"
    elif len(names) == 2:
        pat = "two"
    else:
        pat = "single"
    fn = norm(first)
    if len(fn) < 2:
        return None
    sec = norm(names[1]) if pat == "two" else None
    disp = re.sub(r"[^A-Za-zÀ-ÿ]", "", first[:1].upper() + first[1:]) if first.isupper() else re.sub(r"[^A-Za-zÀ-ÿ]", "", first)
    if pat == "single":
        key = f"{disp}__{year}"
    elif pat == "two":
        s2 = names[1]; s2 = s2.capitalize() if s2.isupper() else s2
        key = f"{disp}_{re.sub(r'[^A-Za-zÀ-ÿ]', '', s2)}_{year}"
    else:
        key = f"{disp}_etal_{year}"
    return dict(first=fn, second=sec, year=year, pattern=pat, key=NFC(key))

# ---------------------------------------------------------------- repo folders + registry roles
folders = sorted(NFC(d) for d in os.listdir(ROOT)
                 if os.path.isdir(os.path.join(ROOT, d)) and not d.startswith(("_", ".")))
fmeta = {f: parse_folder(f) for f in folders}
by_first_year = collections.defaultdict(list)
for f, m in fmeta.items():
    if m:
        by_first_year[(m["first"], m["year"])].append(f)

def match_folder(p):
    """Return (folder or None, status, candidates)."""
    cands = by_first_year.get((p["first"], p["year"]), [])
    if not cands:
        return None, "not_in_repo", []
    exact = [c for c in cands if fmeta[c]["pattern"] == p["pattern"] and
             (p["pattern"] != "two" or fmeta[c]["second"] == p["second"])]
    pool = exact or cands
    if len(pool) == 1:
        return pool[0], "matched" if exact else "matched_pattern_differs", cands
    return None, "ambiguous_repo_match", pool

reg = pd.read_excel(os.path.join(ROOT, "__ReadMe.xlsx"), sheet_name="Sheet1")
reg = reg.rename(columns={"Data role (primary/secondary/both)": "role", "Source (if secondary)": "src"})
def item_folder(item):
    item = str(item)
    best = [f for f in folders if item == f or item.startswith(f + "_")]
    return max(best, key=len) if best else None
reg["folder"] = reg["Item name"].map(NFC).map(item_folder)
def role_class(r):
    if pd.isna(r): return None
    r = str(r).lower()
    p, s = "primary" in r, ("secondary" in r or "reuse" in r or "comparator" in r)
    if "derived" in r and not s: p = True
    return "both" if (p and s) else "primary" if p else "secondary" if s else None
reg["role_c"] = reg["role"].map(role_class)
folder_cit = {f: " ".join(g["Citation (APA 7th-Annotated)"].dropna().astype(str))
              for f, g in reg.dropna(subset=["folder"]).groupby("folder")}
def toks(x): return {w for w in re.findall(r"[a-z]{4,}", norm_keep(x))}
def norm_keep(x):
    x = unicodedata.normalize("NFKD", str(x)); x = "".join(c for c in x if not unicodedata.combining(c))
    return x.lower()
def by_title(cit, pool):
    t = toks(cit)
    if len(t) < 4: return None
    sc = {c: len(t & toks(folder_cit.get(c, ""))) / len(t) for c in pool}
    best = sorted(sc.items(), key=lambda kv: -kv[1])
    if best[0][1] >= 0.5 and (len(best) == 1 or best[0][1] - best[1][1] >= 0.2):
        return best[0][0]
    return None
folder_role = {}
for f, g in reg.dropna(subset=["folder"]).groupby("folder"):
    rs = set(g["role_c"].dropna())
    folder_role[f] = ("both" if ("both" in rs or {"primary", "secondary"} <= rs)
                      else rs.pop() if len(rs) == 1 else None)

# ---------------------------------------------------------------- reference lists
SKIP = re.compile(r"(definitions|availability|consistency|counts|page_check|alignment|malformed|"
                  r"species_references|mismatches|cell_references|candidates|unparsed|reference_columns|"
                  r"species_not_in_reference|_snapshot|reference_keys)", re.I)
CIT_COLS = ["full_citation", "citation", "Citation", "full_reference", "Source_name"]
KEY_COLS = ["ref_key", "ref_number", "Ref_number", "ref_id", "source_number", "ref", "short_reference",
            "source_id", "ref_key_norm", "Row_ID"]
files = [f for f in glob.glob(os.path.join(ROOT, "*", "**", "*eference*.csv"), recursive=True)
         if "/.claude/" not in f and "/__" not in f and "/_keys/" not in f
         and not os.path.basename(f).startswith((".!", "._")) and not SKIP.search(os.path.basename(f))]

def read_any(f):
    for enc in ("utf-8-sig", "latin-1"):
        try:
            return pd.read_csv(f, encoding=enc, dtype=str, on_bad_lines="error")
        except UnicodeDecodeError:
            continue
        except pd.errors.ParserError:
            return pd.DataFrame()

rows, skipped_files = [], []
for f in sorted(files):
    rel = os.path.relpath(f, ROOT)
    rel = NFC(rel); owner = rel.split(os.sep)[0]
    df = read_any(f)
    ccol = next((c for c in CIT_COLS if c in df.columns), None)
    kcol = next((c for c in KEY_COLS if c in df.columns), None)
    if ccol is None:
        skipped_files.append((rel, "no citation column")); continue
    has_level = "reference_level" in df.columns and "primary_reference_id" in df.columns
    for _, r in df.iterrows():
        cit = r.get(ccol)
        short = r.get("short") or r.get("short_citation") or r.get("short_reference") or r.get("table_heading_citation")
        note = r.get("note") if "note" in df.columns else None
        rows.append(dict(Secondary_Ref=owner, evidence_file=rel, ref_key=r.get(kcol) if kcol else None,
                         cited_in_column=r.get("cited_in_column") if "cited_in_column" in df.columns else kcol,
                         citation_as_printed=cit if isinstance(cit, str) and cit.strip() else (short or cit),
                         short=short, note=note,
                         ext_level=r.get("reference_level") if has_level else None,
                         ext_primary=r.get("primary_reference_id") if has_level else None,
                         ext_self=r.get("source_reference_id") if has_level else None,
                         edge_source="reference_table"))
refs = pd.DataFrame(rows)

# parse + match
def resolve_row(r):
    ov = OVERRIDE.get((r["Secondary_Ref"], os.path.basename(r["evidence_file"]), str(r["ref_key"])))
    if ov:
        return pd.Series(dict(Target_Ref=NFC(ov[0]), match_status=ov[1], nonref_flag=None, candidates=""))
    txt = r["citation_as_printed"]
    if isinstance(txt, str) and NONREF_RE.search(txt) and not YEAR_RE.search(txt.split("present")[0] or ""):
        pass
    p = parse_citation(txt) or parse_citation(r["short"]) or parse_citation(r["ref_key"])
    flag = None
    s = " ".join(str(x) for x in (txt, r["note"], r["ref_key"]) if isinstance(x, str))
    if NONREF_RE.search(s):
        flag = NONREF_RE.search(s).group(0).lower()
    if p is None:
        return pd.Series(dict(Target_Ref=None, match_status="unparseable", nonref_flag=flag, candidates=""))
    f, st, c = match_folder(p)
    if st == "ambiguous_repo_match":
        if r["Secondary_Ref"] in c and flag and re.search(r"present|this (study|paper|report)", flag):
            f, st = r["Secondary_Ref"], "matched_self"
        else:
            b = by_title(txt, c)
            if b: f, st = b, "matched_by_title"
    return pd.Series(dict(Target_Ref=f or p["key"], match_status=st, nonref_flag=flag, candidates="; ".join(c)))
refs = pd.concat([refs, refs.apply(resolve_row, axis=1)], axis=1)
# full bibliographic entry? (has more than author+year: a title-ish tail)
def is_full(t):
    return isinstance(t, str) and len(t) > 45
refs["full_entry"] = refs["citation_as_printed"].map(is_full)
refs["is_self"] = refs["Target_Ref"] == refs["Secondary_Ref"]

# ---------------------------------------------------------------- relationship key edges (later -> primary)
sr = pd.read_csv(os.path.join(ROOT, "_keys", "source_relationships.csv"), dtype=str).map(NFC)
rel_rows, rel_sibling = [], []
for _, r in sr[sr.relationship.isin(["reprints", "derives_from"])].iterrows():
    if str(r["direction"]).strip().lower() == "none":
        # declared: both reprint a common third primary -> no chain edge between them
        rel_sibling.append(r["pair_id"]); continue
    m = re.match(r"\s*(\S+)\s+over\s+(\S+)", str(r["direction"]))
    if not m:
        raise SystemExit(f"STOP: unparseable direction in source_relationships {r['pair_id']}: {r['direction']}")
    primary, later = m.group(1), m.group(2)
    rel_rows.append(dict(Secondary_Ref=later, Target_Ref=primary, evidence_file="_keys/source_relationships.csv",
                         ref_key=r["pair_id"], citation_as_printed=f"{r['relationship']}: {r['direction']}",
                         match_status="matched" if primary in fmeta else "not_in_repo",
                         edge_source=f"source_relationships:{r['relationship']}:{r['status']}",
                         full_entry=True, is_self=False, nonref_flag=None, candidates=""))
rel = pd.DataFrame(rel_rows)

# ---------------------------------------------------------------- external resolutions (Kaufman/Karbowski)
ext = refs[refs.ext_level.notna() & refs.ext_primary.notna() & (refs.ext_primary != refs.ext_self)]
ext_rows = [dict(Secondary_Ref=f"{r.ext_self}", Target_Ref=f"{r.ext_primary}", evidence_file=r.evidence_file,
                 ref_key=r.ref_key, citation_as_printed=f"reference_level={r.ext_level}",
                 match_status="external_id", edge_source="table_primary_reference_id",
                 full_entry=True, is_self=False, nonref_flag=None, candidates="") for r in ext.itertuples()]

declared_secondary = set(refs.loc[refs.ext_level.eq("secondary") & refs.ext_primary.isna(), "Target_Ref"].dropna())
# ---------------------------------------------------------------- edges
self_primary = set(refs.loc[refs.is_self, "Secondary_Ref"])
E = pd.concat([refs[~refs.is_self & refs.Target_Ref.notna()], rel, pd.DataFrame(ext_rows)], ignore_index=True)
agg = (E.groupby(["Secondary_Ref", "Target_Ref"], dropna=False)
         .agg(edge_source=("edge_source", lambda x: "; ".join(sorted(set(x)))),
              evidence=("evidence_file", lambda x: "; ".join(sorted(set(x)))),
              ref_keys=("ref_key", lambda x: "; ".join(sorted({str(v) for v in x if pd.notna(v)}))[:200]),
              citation_as_printed=("citation_as_printed", "first"),
              match_status=("match_status", lambda x: sorted(set(x))[0]),
              nonref_flag=("nonref_flag", lambda x: "; ".join(sorted({v for v in x if isinstance(v, str)}))),
              full_entry=("full_entry", "max"),
              candidates=("candidates", "first"),
              first_file=("evidence_file", "first"), first_key=("ref_key", "first"),
              cited_in_column=("cited_in_column", "first"))
         .reset_index())

G = nx.DiGraph()
G.add_edges_from(zip(agg.Secondary_Ref, agg.Target_Ref))
in_repo = lambda n: n in fmeta

# cycles
cyc_nodes, cycles = set(), []
for scc in nx.strongly_connected_components(G):
    if len(scc) > 1:
        cyc_nodes |= scc
        cycles.append(sorted(scc))
cycle_edges = {(u, v) for u, v in G.edges if u in cyc_nodes and v in cyc_nodes and
               any(u in c and v in c for c in map(set, cycles))}

# node classes
def node_class(n):
    role = folder_role.get(n) if in_repo(n) else None
    out = G.out_degree(n) if n in G else 0
    if n in cyc_nodes:
        return "cycle_member"
    if out > 0:
        return "intermediate"            # cites further (may also hold own data if role 'both')
    if n in declared_secondary:
        return "terminal_unverified_repo"   # citing table's own audit: secondary, primary lineage not traced
    if in_repo(n):
        if role == "primary" or n in self_primary:
            return "terminal_verified"
        return "terminal_unverified_repo"    # in repo, secondary/both/unknown, sources not transcribed
    return "terminal_external"           # identified, not in repo: primary status not checked

nodes = sorted(set(G.nodes) | set(refs.Secondary_Ref))
NT = pd.DataFrame(dict(node=nodes))
NT["in_repo"] = NT.node.map(in_repo)
NT["registry_role"] = NT.node.map(lambda n: folder_role.get(n))
NT["self_declared_primary"] = NT.node.isin(self_primary)
NT["out_degree"] = NT.node.map(lambda n: G.out_degree(n) if n in G else 0)
NT["in_degree"] = NT.node.map(lambda n: G.in_degree(n) if n in G else 0)
NT["node_class"] = NT.node.map(node_class)
ncls = dict(zip(NT.node, NT.node_class))

LEVEL = {"intermediate": "Intermediate", "terminal_verified": "Terminal",
         "terminal_unverified_repo": "Terminal_unverified", "terminal_external": "Terminal_external",
         "cycle_member": "Cycle"}
agg["Resolution_Level"] = agg.Target_Ref.map(lambda n: LEVEL[ncls[n]])
orph = (agg.match_status == "unparseable") | agg.nonref_flag.astype(bool) | \
       ((agg.Resolution_Level == "Terminal_external") & ~agg.full_entry.astype(bool))
agg.loc[orph & agg.Resolution_Level.isin(["Terminal_external"]), "Resolution_Level"] = "Orphan"
agg.loc[agg.match_status == "ambiguous_repo_match", "Resolution_Level"] = "Ambiguous"

# unparseable rows never became edges: add them as orphan edges with a placeholder target
unp = (refs[refs.Target_Ref.isna()].assign(ref_key=lambda d: d.ref_key.astype(str))
         .groupby(["Secondary_Ref", "evidence_file", "ref_key"], as_index=False)
         .agg(citation_as_printed=("citation_as_printed", "first"),
              nonref_flag=("nonref_flag", lambda x: "; ".join(sorted({v for v in x if isinstance(v, str)}))),
              cited_in_column=("cited_in_column", lambda x: "; ".join(sorted({str(v) for v in x if pd.notna(v)})))))
unp_edges = pd.DataFrame(dict(Secondary_Ref=unp.Secondary_Ref,
                              Target_Ref="UNRESOLVED::" + unp.evidence_file.str.split("/").str[-1] + "::" + unp.ref_key.astype(str),
                              edge_source="reference_table", evidence=unp.evidence_file, ref_keys=unp.ref_key,
                              citation_as_printed=unp.citation_as_printed, match_status="unparseable",
                              first_file=unp.evidence_file, first_key=unp.ref_key, cited_in_column=unp.cited_in_column,
                              nonref_flag=unp.nonref_flag, full_entry=False, candidates="",
                              Resolution_Level="Orphan"))
EDGES = pd.concat([agg, unp_edges], ignore_index=True)

# ---------------------------------------------------------------- root resolution
H = G.copy()
H.remove_edges_from(cycle_edges)     # resolve on the acyclic part; cycle edges reported separately
def roots_of(t):
    if t not in H or H.out_degree(t) == 0:
        return {t}
    desc = nx.descendants(H, t) | {t}
    sinks = {d for d in desc if H.out_degree(d) == 0}
    # a 'both'/'primary' intermediate also contributes its own data
    own = {d for d in desc if H.out_degree(d) > 0 and (folder_role.get(d) in ("primary", "both") or d in self_primary)}
    return sinks | own

def root_status(r):
    if str(r).startswith("UNRESOLVED::"): return "orphan"
    c = ncls.get(r)
    if c in ("terminal_verified",) or (in_repo(r) and (folder_role.get(r) in ("primary", "both") or r in self_primary)):
        return "verified_primary_in_repo"
    if c == "terminal_unverified_repo": return "in_repo_role_unverified"
    return "external_unverified"

ROOTS = {}
def roots_cached(t):
    if t not in ROOTS: ROOTS[t] = roots_of(t)
    return ROOTS[t]
RR, LOOK = [], []
for e in EDGES.itertuples():
    if e.Resolution_Level in ("Orphan", "Ambiguous"):
        RR.append(dict(Secondary_Ref=e.Secondary_Ref, Target_Ref=e.Target_Ref, Resolution_Level=e.Resolution_Level,
                       n_terminal_roots=0, Primary_Ref_Terminal=None, terminal_roots_in_repo=None,
                       n_roots_external=0, max_depth=None, example_path=None, root_status=e.Resolution_Level.lower()))
        continue
    rts = sorted(roots_cached(e.Target_Ref))
    st = {r: root_status(r) for r in rts}
    inrepo = [r for r in rts if in_repo(r)]
    ext_ = [r for r in rts if not in_repo(r)]
    depths, paths = [], []
    for rt in (inrepo + ext_)[:1] if len(rts) > 200 else rts:
        p = nx.shortest_path(H, e.Target_Ref, rt) if e.Target_Ref in H and rt != e.Target_Ref else [e.Target_Ref]
        depths.append(len(p)); paths.append(" -> ".join([e.Secondary_Ref] + p))
    deep = max(range(len(depths)), key=lambda k: depths[k])
    overall = ("verified_primary_in_repo" if all(v in ("verified_primary_in_repo",) for v in st.values()) else
               "mixed" if len(set(st.values())) > 1 else next(iter(st.values())))
    RR.append(dict(Secondary_Ref=e.Secondary_Ref, Target_Ref=e.Target_Ref, Resolution_Level=e.Resolution_Level,
                   n_terminal_roots=len(rts),
                   Primary_Ref_Terminal=rts[0] if len(rts) == 1 else ("; ".join(rts) if len(rts) <= 10 else f"{len(rts)} roots - see terminal_lookup.csv"),
                   terminal_roots_in_repo="; ".join(inrepo), n_roots_external=len(ext_),
                   max_depth=depths[deep], example_path=paths[deep], root_status=overall))
for t in sorted({e for e in EDGES.Target_Ref if e in H and H.out_degree(e) > 0}):
    for rt in sorted(roots_cached(t)):
        p = nx.shortest_path(H, t, rt) if rt != t else [t]
        LOOK.append(dict(Intermediate_Ref=t, Primary_Ref_Terminal=rt, hops=len(p) - 1, path=" -> ".join(p),
                         root_status=root_status(rt)))
RR = pd.DataFrame(RR); LOOK = pd.DataFrame(LOOK)
selfrows = pd.DataFrame(dict(Secondary_Ref=sorted(self_primary), Target_Ref=sorted(self_primary),
                             Resolution_Level="Terminal", n_terminal_roots=1, Primary_Ref_Terminal=sorted(self_primary),
                             terminal_roots_in_repo=sorted(self_primary), n_roots_external=0, max_depth=1,
                             example_path=sorted(self_primary), root_status="self_declared_primary"))
RR = pd.concat([RR, selfrows], ignore_index=True)

# ---------------------------------------------------------------- review queue
Q = []
for e in EDGES.itertuples():
    reason = None
    if e.Resolution_Level == "Orphan":
        reason = ("unparseable citation" if e.match_status == "unparseable" else
                  f"non-citable source ({e.nonref_flag})" if e.nonref_flag else
                  "abbreviated citation, no full bibliography entry")
        pri = "P1"
    elif e.Resolution_Level == "Ambiguous":
        reason, pri = f"matches several repo folders: {e.candidates}", "P1"
    elif e.Resolution_Level == "Cycle":
        reason, pri = "edge lies on a citation cycle", "P1"
    elif e.Resolution_Level == "Terminal_unverified" and e.Target_Ref in declared_secondary:
        reason, pri = "cited source is itself declared secondary (review/book) by the citing table; primary lineage not traced", "P1"
    elif e.Resolution_Level == "Terminal_unverified":
        reason, pri = f"root is a repo item with role={folder_role.get(e.Target_Ref)}; its own sources are not transcribed", "P2"
    elif e.match_status in ("matched_pattern_differs", "matched_by_title"):
        reason, pri = f"repo match is {e.match_status} (not exact key): {e.Target_Ref}; confirm", "P2"
    elif e.Resolution_Level == "Terminal_external":
        reason, pri = "root identified bibliographically but not in repo; primary status unverified", "P3"
    if reason:
        Q.append(dict(priority=pri, match_status=e.match_status, Secondary_Ref=e.Secondary_Ref, Target_Ref=e.Target_Ref,
                      Resolution_Level=e.Resolution_Level, reason=reason, evidence=e.evidence,
                      ref_keys=e.ref_keys, citation_as_printed=e.citation_as_printed, review_status="open"))
Q = pd.DataFrame(Q).sort_values(["priority", "Secondary_Ref", "Target_Ref"])
QE = {(e.Secondary_Ref, e.Target_Ref): e for e in EDGES.itertuples()}

# ---------------------------------------------------------------- guards (fail, don't print)
n_ref_rows = len(refs)
n_accounted = int((~refs.is_self & refs.Target_Ref.notna()).sum() + refs.is_self.sum() + refs.Target_Ref.isna().sum())
if n_ref_rows != n_accounted:
    raise SystemExit(f"STOP: {n_ref_rows} reference rows read but {n_accounted} accounted for")
missing_pairs = set(zip(E.Secondary_Ref, E.Target_Ref)) - set(zip(EDGES.Secondary_Ref, EDGES.Target_Ref))
if missing_pairs:
    raise SystemExit(f"STOP: {len(missing_pairs)} edges lost in aggregation")
if not set(EDGES[EDGES.Resolution_Level.isin(['Orphan','Ambiguous','Cycle','Terminal_unverified'])]
           .set_index(['Secondary_Ref','Target_Ref']).index) <= set(Q.set_index(['Secondary_Ref','Target_Ref']).index):
    raise SystemExit("STOP: an unresolved edge is missing from the review queue")


# ---------------------------------------------------------------- stage R: REVIEW_QUEUE (refs_check schema)
def queue_letter(q):
    if q.priority == "P1": return "R"            # root unresolved -> may become errata
    if q.match_status in ("matched_pattern_differs", "matched_by_title"): return "M"
    return "K"                                    # registry role blank/secondary -> registry fix
def paper_pdf(folder):
    d = os.path.join(ROOT, folder)
    if not os.path.isdir(d): return ""
    p = sorted(glob.glob(os.path.join(d, "*.pdf")) + glob.glob(os.path.join(d, "*", "*.pdf")))
    return os.path.relpath(p[0], d) if p else ""
def item_of(f):
    b = os.path.basename(str(f))
    return re.sub(r"(_[Rr]eferences?.*|_reference.*)\.csv$", "", b) if b.endswith(".csv") and "_keys/" not in str(f) else ""
RQ = Q[Q.priority.isin(["P1", "P2"])].copy()
RQ["queue"] = [queue_letter(q) for q in RQ.itertuples()]
e_ = [QE[(a, b)] for a, b in zip(RQ.Secondary_Ref, RQ.Target_Ref)]
RQ["paper_folder"] = RQ.Secondary_Ref
RQ["pdf"] = RQ.paper_folder.map(paper_pdf)
RQ["item"] = [item_of(e.first_file) for e in e_]
RQ["variable"] = [str(e.cited_in_column) if isinstance(e.cited_in_column, str) else "*" for e in e_]
RQ["locator"] = [f"{e.first_file} ref_key={e.first_key}" for e in e_]
RQ["species"] = ""; RQ["measure_term"] = ""
RQ["audited_value"] = RQ.citation_as_printed
RQ["repo_value"] = RQ.Target_Ref.where(~RQ.Target_Ref.astype(str).str.startswith("UNRESOLVED::"), "")
RQ["other_source"] = [e.candidates if isinstance(e.candidates, str) else "" for e in e_]
RQ["other_value"] = ""
RQ["verification_status"] = RQ.Resolution_Level.str.lower() + ": " + RQ.reason
RQ["implicated"] = RQ.queue.map({"R": "citing paper's reference list (PDF) or its repo transcription",
                                 "M": "resolver match; confirm with match_confirmed/match_rejected",
                                 "K": "registry __ReadMe.xlsx Data role of the target"})
RQ["source_row_id"] = [str(e.first_key) for e in e_]
RQ["queue_key"] = [QK_SEP.join([q, p, os.path.basename(str(e.first_file)), str(e.first_key), str(t)])
                   for q, p, e, t in zip(RQ.queue, RQ.paper_folder, e_, RQ.Target_Ref)]
if RQ.queue_key.duplicated().any():
    raise SystemExit(f"STOP: {int(RQ.queue_key.duplicated().sum())} duplicated queue_key values")
RQ = RQ.merge(RES.rename(columns={"evidence": "resolution_evidence", "date": "resolution_date"}),
              on="queue_key", how="left").fillna({"resolution": "", "resolved_to": "",
                                                  "resolution_evidence": "", "resolution_date": ""})
# overridden matches leave the queue (their edge now carries match_confirmed); keep their resolutions
stale = RES[~RES.queue_key.isin(RQ.queue_key) & ~RES.resolution.isin(["match_confirmed", "match_rejected"])]
RQ = RQ.sort_values(["queue", "paper_folder", "queue_key"]).reset_index(drop=True)
RQ.insert(0, "row_id", [f"RC{i+1:04d}" for i in range(len(RQ))])
QCOLS = ["row_id", "queue", "paper_folder", "pdf", "item", "variable", "locator", "species", "measure_term",
         "audited_value", "repo_value", "other_source", "other_value", "verification_status", "implicated",
         "source_row_id", "queue_key", "resolution", "resolved_to", "resolution_evidence", "resolution_date"]
RQ[QCOLS].to_csv(os.path.join(FINDINGS, "REVIEW_QUEUE.csv"), index=False, encoding="utf-8-sig")
if not os.path.exists(RES_PATH):
    RES.to_csv(RES_PATH, index=False, encoding="utf-8-sig")
## CONVENTION-OK: stale resolutions are expected when an upstream fix (e.g. a transcribed bibliography) removes the row
stale.to_csv(os.path.join(FINDINGS, "REVIEW_QUEUE_resolutions_stale.csv"), index=False, encoding="utf-8-sig")

# ---------------------------------------------------------------- write
cols = ["Secondary_Ref", "Target_Ref", "Resolution_Level", "match_status", "edge_source", "evidence",
        "ref_keys", "citation_as_printed", "nonref_flag", "candidates"]
EDGES[cols].sort_values(["Secondary_Ref", "Target_Ref"]).to_csv(f"{OUT}/citation_edges.csv", index=False, encoding="utf-8-sig")
RR.sort_values(["Secondary_Ref", "Target_Ref"]).to_csv(f"{OUT}/root_resolution.csv", index=False, encoding="utf-8-sig")
LOOK.to_csv(f"{OUT}/terminal_lookup.csv", index=False, encoding="utf-8-sig")
NT.to_csv(f"{OUT}/node_table.csv", index=False, encoding="utf-8-sig")
Q.drop(columns=["match_status"]).to_csv(f"{OUT}/review_queue_all_priorities.csv", index=False, encoding="utf-8-sig")
summary = dict(relationship_rows_sibling_reprints_no_edge=rel_sibling,
               relationship_edges=len(rel_rows), reference_files_read=len(files) - len(skipped_files), files_skipped=skipped_files,
               reference_rows=n_ref_rows, self_citations=int(refs.is_self.sum()),
               edges=len(EDGES), nodes=G.number_of_nodes(), repo_folders=len(folders),
               resolution_levels=EDGES.Resolution_Level.value_counts().to_dict(),
               match_status=EDGES.match_status.value_counts().to_dict(),
               root_status=RR.root_status.value_counts().to_dict(),
               max_depth_hops=int(LOOK.hops.max()) + 1 if len(LOOK) else 1, terminal_lookup_rows=len(LOOK), cycles=cycles,
               review_queue=Q.priority.value_counts().to_dict(),
               REVIEW_QUEUE=RQ.queue.value_counts().to_dict(),
               REVIEW_QUEUE_worked=int((RQ.resolution != "").sum()), resolutions_stale=len(stale),
               match_overrides_applied=int(refs.match_status.isin(["match_confirmed", "match_rejected"]).sum()))
json.dump(summary, open(f"{OUT}/run_summary.json", "w"), indent=1, default=str)
print(json.dumps({k: v for k, v in summary.items() if k != "files_skipped"}, indent=1, default=str))
