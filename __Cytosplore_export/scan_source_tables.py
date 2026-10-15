#!/usr/bin/env python3
"""
scan_source_tables.py -- where in the repo is there data for the target species
that is NOT reaching the cohort exports, and why?

    python3 __Cytosplore_export/scan_source_tables.py            # all cohorts' species
    python3 __Cytosplore_export/scan_source_tables.py EvoM1 HMBA # restrict targets

Standard library only (calls Rscript once to dump __ReadMe.xlsx; falls back to the
last dump if R is unavailable).

WHAT IT SCANS
  1. Every public source table  __Public/comparative-data/*.tsv  (the frozen
     per-paper tables). Species columns are detected by name (species / taxon /
     binomial / animal ...); values are normalised and matched to the target
     species at species level (after _keys/species_display_aliases.csv) and at
     genus level (first word, so congeners, "Genus sp.", hybrids count).
     Tables with only common names are matched on the cohort common_name as a
     low-confidence hit.
  2. Every paper folder (_checks/folder_audit.csv + __ReadMe.xlsx): folders with
     a PDF but no frozen/derived CSV or no public TSV are "not built"; their
     README/notes/CSV text is grepped for target binomials and genera so unbuilt
     sources that mention the targets are listed.

HOW "REACHES THE EXPORT" IS DECIDED
  A table is wired if its registry Item name (or its paper folder) appears in a
  __merging_* long table's text or in a __merging_* build script. The export
  (build_cytosplore_traits.R) reads exactly the merges, so wired == can reach
  the cohort tables (subject to the merge's own select/flag filters).

FLAGS carried per table
  registry "Flags active (skips)", "Progress stage", "Data role", disposition
  (SOURCE_DISPOSITION sheet + SOURCE_DISPOSITION_REGISTER.md), *_errata.csv in
  the folder, and in-table status/flag columns on rows of target species.

OUTPUTS (__Cytosplore_export/output/_source_scan/)
  source_table_scan.csv        one row per public TSV
  unbuilt_sources.csv          folders/items with no public table, with target mentions
  target_species_gaps.csv      one row per target species: tables in merge vs not
  SCAN_SUMMARY.md
"""
import csv, os, re, sys, glob, subprocess, unicodedata, collections, datetime

csv.field_size_limit(10 ** 8)
HERE = os.path.dirname(os.path.abspath(__file__)); REPO = os.path.dirname(HERE)
OUT = os.path.join(HERE, "output", "_source_scan"); os.makedirs(OUT, exist_ok=True)
P = lambda *a: os.path.join(REPO, *a)
def rd(path, delim=","):
    with open(path, encoding="utf-8-sig", newline="", errors="replace") as f:
        return list(csv.DictReader(f, delimiter=delim))
def norm(s):
    s = unicodedata.normalize("NFKC", str(s or "")).replace("*", "").replace("_", " ")
    s = re.sub(r"\s+", " ", s).strip()
    return s
def genus(s): return norm(s).split(" ")[0] if norm(s) else ""

# ---------------------------------------------------------------- targets
want = set(a for a in sys.argv[1:] if a)
coh = rd(P("_keys/species_cohorts.csv"))
if want: coh = [r for r in coh if r["cohort"] in want]
aliases = {norm(r["variant"]): norm(r["canonical"]) for r in rd(P("_keys/species_display_aliases.csv"))}
targets = collections.OrderedDict()      # species_sci -> {cohorts, common, labels}
for r in coh:
    t = targets.setdefault(r["species_sci"], {"cohorts": set(), "common": r["common_name"], "labels": set()})
    t["cohorts"].add(r["cohort"])
    labs = [x.strip() for x in (r["lookup_name"] or "").split(";") if x.strip()] or [r["species_sci"]]
    t["labels"].update(norm(l) for l in labs); t["labels"].add(norm(r["species_sci"]))
    for var, can in aliases.items():
        if can in t["labels"]: t["labels"].add(var)
label_to_target = {}
for sci, t in targets.items():
    for l in t["labels"]: label_to_target.setdefault(l, set()).add(sci)
    # species-level also accepts the binomial prefix of a trinomial cohort name
    w = norm(sci).split(" ")
    if len(w) >= 3: label_to_target.setdefault(" ".join(w[:2]), set()).add(sci)
genus_to_target = collections.defaultdict(set)
for sci in targets: genus_to_target[genus(sci)].add(sci)
common_to_target = {norm(t["common"]).lower(): sci for sci, t in targets.items() if t["common"]}
print(f"targets: {len(targets)} species, {len(genus_to_target)} genera, cohorts {sorted({c for t in targets.values() for c in t['cohorts']})}")

# ---------------------------------------------------------------- registry
reg_csv = os.path.join(HERE, ".registry_dump.csv"); disp_csv = os.path.join(HERE, ".registry_SOURCE_DISPOSITION.csv")
try:
    subprocess.run(["Rscript", "-e",
        'suppressMessages(library(readxl));'
        f'write.csv(read_excel("{P("__ReadMe.xlsx")}", sheet=1), "{reg_csv}", row.names=FALSE, fileEncoding="UTF-8");'
        f'write.csv(read_excel("{P("__ReadMe.xlsx")}", sheet="SOURCE_DISPOSITION"), "{disp_csv}", row.names=FALSE, fileEncoding="UTF-8")'],
        check=True, capture_output=True, timeout=300)
except Exception as e:
    print("  (Rscript registry dump failed, using previous dump)", type(e).__name__)
reg = rd(reg_csv) if os.path.exists(reg_csv) else []
disp_rows = rd(disp_csv) if os.path.exists(disp_csv) else []
col = lambda r, k: (r.get(k) or "").strip() if (r.get(k) or "").strip() != "NA" else ""
ENC = "Public TSV match from AUTO_Public_TSV_FileList (generated by _tools/file_list.R; do not edit manually)"
by_item = {col(r, "Item name"): r for r in reg if col(r, "Item name")}
by_encoded = {}
for r in reg:
    for k in ("Item encoded", ENC):
        e = col(r, k)
        if e: by_encoded[e.replace(".tsv", "")] = r
disp_by_item = {col(r, "Item name"): r for r in disp_rows if col(r, "Item name")}

# disposition register (markdown tables): first cell -> disposition text
disp_md = {}
md = P("SOURCE_DISPOSITION_REGISTER.md")
if os.path.exists(md):
    for line in open(md, encoding="utf-8"):
        if line.startswith("|") and not re.match(r"^\|\s*-+", line) and "current disposition" not in line:
            cells = [c.strip() for c in line.strip().strip("|").split("|")]
            if len(cells) >= 2 and cells[0] and cells[0] not in ("source", "item", "status"):
                key = re.sub(r"[`*]", "", cells[0])
                disp_md[key] = re.sub(r"[`*]", "", cells[1])
def disposition_of(folder, item):
    hits = []
    for k, v in disp_md.items():
        if k and (k == folder or k == item or (folder and k.startswith(folder)) or (item and item.startswith(k))):
            hits.append(f"{k}: {v}")
    if item in disp_by_item:
        d = disp_by_item[item]
        hits.append("registry SOURCE_DISPOSITION: " + (col(d, "Flags active (skips)") or col(d, "Progress stage") or col(d, "recommendation")))
    return " | ".join(sorted(set(hits)))

# folders and audit
folders = sorted(d for d in os.listdir(REPO) if os.path.isdir(P(d)) and not d.startswith(("_", ".")))
folder_set = set(folders)
audit = {r["folder"]: r for r in rd(P("_checks/folder_audit.csv"))} if os.path.exists(P("_checks/folder_audit.csv")) else {}
def folder_of_item(item):
    parts = item.split("_")
    for k in range(len(parts), 0, -1):
        c = "_".join(parts[:k])
        if c in folder_set: return c
    return ""

# errata per folder
errata = collections.defaultdict(list)
for f in glob.glob(P("*", "**", "*_errata.csv"), recursive=True):
    fold = os.path.relpath(f, REPO).split(os.sep)[0]
    for r in rd(f):
        errata[fold].append(f'{r.get("issue_type","")}:{r.get("status","")}')

# ---------------------------------------------------------------- merge wiring
merge_text = {}           # merge folder -> big text (long tables + scripts)
for m in sorted(d for d in os.listdir(REPO) if d.startswith("__merging_")):
    buf = []
    for f in glob.glob(P(m, "*")):
        if f.endswith((".csv", ".R", ".py", ".md")) and os.path.getsize(f) < 200_000_000:
            try: buf.append(open(f, encoding="utf-8", errors="replace").read())
            except Exception: pass
    merge_text[m] = "\n".join(buf)
# the EvoM1 trait melt is a second route into the app/export
melt_text = ""
for f in glob.glob(P("____EvoM1_TraitTable", "*.R")) + [P("__ShinyApp", "build_data.R")]:
    try: melt_text += open(f, encoding="utf-8", errors="replace").read()
    except Exception: pass
# One pass per merge: find every registry item name, encoded filename and
# paper folder that the merge's tables/scripts mention.
_names = set(by_item) | set(by_encoded) | set(folders)
_names.discard("")
_rx = re.compile(r"(?<![A-Za-z0-9])(?:" + "|".join(re.escape(n) for n in sorted(_names, key=len, reverse=True)) + r")(?![A-Za-z0-9])")
found = {}
for _m, _txt in list(merge_text.items()) + [("EvoM1 trait table (melt)", melt_text)]:
    found[_m.replace("__merging_", "")] = set(_rx.findall(_txt))
def wired(item, folder, enc=""):
    """(merges referencing THIS table, merges referencing any table of the same paper).
    A table is referenced by its registry Item name or by its DOI-encoded public
    filename -- the harvest-style merges (body_ecology, brain_mass, ...) record
    sources by encoded filename in *_source_columns.csv, never by item name."""
    item_hits, folder_hits = [], []
    for name, toks in found.items():
        if (item and item in toks) or (enc and enc in toks):
            item_hits.append(name)
        elif folder and (folder in toks or any(t.startswith(folder + "_") for t in toks)):
            folder_hits.append(name)
    return item_hits, folder_hits

# ---------------------------------------------------------------- scan TSVs
SPCOL = re.compile(r"species|taxon|binomial|scientific|^animal", re.I)
COMMON = re.compile(r"common|animal", re.I)
FLAGCOL = re.compile(r"^(status|flag|flagged|qc|quality|errat|caveat|exclude)", re.I)
rows_out = []; per_target = collections.defaultdict(lambda: collections.defaultdict(list))
tsv_dir = P("__Public", "comparative-data")
for fn in sorted(os.listdir(tsv_dir)):
    if not fn.endswith(".tsv"): continue
    enc = fn[:-4]
    try: data = rd(os.path.join(tsv_dir, fn), delim="\t")
    except Exception as e:
        rows_out.append({"file": fn, "verdict": f"unreadable ({type(e).__name__})"}); continue
    hdr = list(data[0].keys()) if data else []
    spcols = [h for h in hdr if SPCOL.search(h) and not re.search(r"^n_|_n$|count|basis|level|confidence|note", h, re.I)]
    commoncols = [h for h in hdr if COMMON.search(h) and h not in spcols]
    flagcols = [h for h in hdr if FLAGCOL.search(h)]
    sp_hits, gen_hits, com_hits, flag_rows = collections.defaultdict(int), collections.defaultdict(int), collections.defaultdict(int), collections.Counter()
    n_rows_target = 0
    for r in data:
        matched = set(); gmatched = set()
        for h in spcols:
            v = norm(r.get(h)); v = aliases.get(v, v)
            if not v: continue
            if v in label_to_target: matched |= label_to_target[v]
            else:
                w = v.split(" ")
                if len(w) >= 2 and " ".join(w[:2]) in label_to_target: matched |= label_to_target[" ".join(w[:2])]
            g = genus(v)
            if g in genus_to_target: gmatched |= genus_to_target[g]
        if not matched and not gmatched:
            for h in commoncols:
                v = norm(r.get(h)).lower()
                if v in common_to_target: com_hits[common_to_target[v]] += 1
        for s in matched: sp_hits[s] += 1
        for s in gmatched - matched: gen_hits[s] += 1
        if matched or gmatched:
            n_rows_target += 1
            for h in flagcols:
                fv = (r.get(h) or "").strip()
                if fv and fv.lower() not in ("active", "ok", "false", "0", "none", "na", "", "printed"):
                    flag_rows[f"{h}={fv[:40]}"] += 1
    regr = by_encoded.get(enc) or {}
    item = col(regr, "Item name"); folder = folder_of_item(item) if item else ""
    if not folder and item: folder = item.split("_Table")[0]
    w, wf = wired(item, folder, enc)
    disp = disposition_of(folder, item)
    flags_active = col(regr, "Flags active (skips)")
    stage = col(regr, "Progress stage"); role = col(regr, "Data role (primary/secondary/both)")
    any_target = bool(sp_hits or gen_hits)
    if not any_target and not com_hits: verdict = "no target species"
    elif not any_target: verdict = "common-name hits only (check manually)"
    elif w and not re.search(r"EXCLUDED|HOLD|SKIP|SUPERSEDED|superseded|exclude|HOLD", flags_active + " " + disp): verdict = "in merge -> reaches export"
    elif w: verdict = "wired but flagged/held/excluded"
    elif re.search(r"EXCLUDED|HOLD|SKIP|SUPERSEDED|superseded|exclude|OUT OF SCOPE", flags_active + " " + disp): verdict = "built; excluded/held by decision"
    elif not spcols: verdict = "built; no binomial column"
    elif wf: verdict = "paper in merge; this table not individually referenced (check merge inputs)"
    else: verdict = "built; NOT wired to any merge"
    if any_target and (flags_active or errata.get(folder) or flag_rows): verdict += " [flagged]"
    rec = {
        "file": fn, "item_name": item, "paper_folder": folder,
        "citation": col(regr, "Citation (APA 7th-Annotated)")[:120], "doi": col(regr, "DOI (or Alt)"),
        "n_rows": len(data), "n_rows_target": n_rows_target, "species_columns": "; ".join(spcols),
        "n_target_species": len(sp_hits), "target_species": "; ".join(f"{s} ({n})" for s, n in sorted(sp_hits.items())),
        "n_target_genus_only": len(gen_hits), "genus_only_targets": "; ".join(f"{s} ({n})" for s, n in sorted(gen_hits.items())),
        "common_name_hits": "; ".join(f"{s} ({n})" for s, n in sorted(com_hits.items())),
        "wired_in": "; ".join(w), "paper_wired_in": "; ".join(wf), "progress_stage": stage, "data_role": role,
        "flags_active": flags_active, "disposition": disp,
        "errata": "; ".join(sorted(set(errata.get(folder, [])))),
        "in_table_flags_on_target_rows": "; ".join(f"{k} x{v}" for k, v in flag_rows.most_common(6)),
        "registry_taxon": col(regr, "Taxon")[:60], "main_traits": col(regr, "Main Trait(s)")[:120],
        "verdict": verdict}
    rows_out.append(rec)
    for s in set(sp_hits) | set(gen_hits):
        per_target[s][verdict.split(" [")[0]].append(f"{fn}" if not item else item)

# ---------------------------------------------------------------- unbuilt folders / items
built_items = set(by_encoded)        # registry items with a public TSV
have_tsv_folder = {folder_of_item(i) or i.split("_Table")[0] for i in built_items}
unbuilt = []
target_words = sorted({norm(s) for s in targets} | set(genus_to_target), key=len, reverse=True)
TARGET_RX = re.compile(r"\b(" + "|".join(re.escape(w) for w in target_words) + r")\b")
_mention_cache = {}
def mentions(folder):
    if folder in _mention_cache: return _mention_cache[folder]
    hits = collections.Counter()
    for f in glob.glob(P(folder, "**", "*"), recursive=True):
        if f.endswith((".md", ".csv", ".txt", ".R", ".tsv")) and os.path.getsize(f) < 20_000_000:
            try: txt = open(f, encoding="utf-8", errors="replace").read()
            except Exception: continue
            for wd in set(TARGET_RX.findall(txt)): hits[wd] += 1
    _mention_cache[folder] = hits
    return hits
for r in reg:
    item = col(r, "Item name"); enc = col(r, "Item encoded")
    if not item or enc.replace(".tsv", "") in by_encoded and os.path.exists(os.path.join(tsv_dir, enc.replace(".tsv", "") + ".tsv")): continue
    folder = folder_of_item(item) or item.split("_Table")[0]
    a = audit.get(folder, {})
    m = mentions(folder) if folder in folder_set else collections.Counter()
    unbuilt.append({
        "item_name": item, "paper_folder": folder, "folder_exists": folder in folder_set,
        "progress_stage": col(r, "Progress stage"), "flags_active": col(r, "Flags active (skips)"),
        "data_role": col(r, "Data role (primary/secondary/both)"), "taxon": col(r, "Taxon")[:80],
        "main_traits": col(r, "Main Trait(s)")[:120], "recommendation": col(r, "recommendation")[:160],
        "disposition": disposition_of(folder, item),
        "paper_pdf": a.get("paper_pdf", ""), "n_frozen": a.get("n_frozen", ""), "n_derived": a.get("n_derived", ""),
        "wired_in": "; ".join(wired(item, folder)[0]), "paper_wired_in": "; ".join(wired(item, folder)[1]),
        "target_mentions_in_folder": "; ".join(f"{k} ({v})" for k, v in m.most_common(12)),
        "n_target_species_mentioned": sum(1 for k in m if k in targets),
        "n_target_genera_mentioned": sum(1 for k in m if k in genus_to_target and k not in targets),
        "citation": col(r, "Citation (APA 7th-Annotated)")[:120]})
unbuilt.sort(key=lambda r: (-(r["n_target_species_mentioned"] + r["n_target_genera_mentioned"]), r["item_name"]))

# ---------------------------------------------------------------- per-target summary
gap_rows = []
for sci, t in targets.items():
    d = per_target.get(sci, {})
    gap_rows.append({
        "species_sci": sci, "cohorts": "; ".join(sorted(t["cohorts"])), "genus": genus(sci),
        "n_tables_any": sum(len(v) for v in d.values()),
        "n_in_merge": len(d.get("in merge -> reaches export", [])),
        "n_wired_flagged": len(d.get("wired but flagged/held/excluded", [])),
        "n_built_not_wired": len(d.get("built; NOT wired to any merge", [])),
        "n_paper_wired_table_unclear": len(d.get("paper in merge; this table not individually referenced (check merge inputs)", [])),
        "n_excluded_by_decision": len(d.get("built; excluded/held by decision", [])),
        "n_no_binomial": len(d.get("built; no binomial column", [])),
        "tables_not_wired": "; ".join(sorted(set(d.get("built; NOT wired to any merge", [])))),
        "tables_paper_wired_unclear": "; ".join(sorted(set(d.get("paper in merge; this table not individually referenced (check merge inputs)", [])))),
        "tables_wired_flagged": "; ".join(sorted(set(d.get("wired but flagged/held/excluded", [])))),
        "tables_excluded": "; ".join(sorted(set(d.get("built; excluded/held by decision", [])))),
        "unbuilt_items_mentioning": "; ".join(u["item_name"] for u in unbuilt
                                             if any(k == norm(sci) or k == genus(sci) for k in
                                                    [x.split(" (")[0] for x in u["target_mentions_in_folder"].split("; ") if x]))[:600]})

# ---------------------------------------------------------------- write
def w(rows, name):
    p = os.path.join(OUT, name)
    keys = []
    for r in rows:
        for k in r:
            if k not in keys: keys.append(k)
    with open(p, "w", encoding="utf-8", newline="") as f:
        wr = csv.DictWriter(f, fieldnames=keys); wr.writeheader(); wr.writerows(rows)
    print(f"  wrote {name:<30} {len(rows):>5} rows")
w(rows_out, "source_table_scan.csv"); w(unbuilt, "unbuilt_sources.csv"); w(gap_rows, "target_species_gaps.csv")

vc = collections.Counter(r.get("verdict", "") for r in rows_out)
tgt_tables = [r for r in rows_out if r.get("n_target_species") or r.get("n_target_genus_only")]
nw = [r for r in tgt_tables if r["verdict"].startswith("built; NOT wired")]
pu = [r for r in tgt_tables if r["verdict"].startswith("paper in merge")]
fl = [r for r in tgt_tables if "[flagged]" in r["verdict"] or r["verdict"].startswith("wired but")]
ex = [r for r in tgt_tables if r["verdict"].startswith("built; excluded")]
ub_hit = [u for u in unbuilt if u["n_target_species_mentioned"] + u["n_target_genera_mentioned"] > 0]
lines = [
    f"# Source-table scan for target species ({len(targets)} species, cohorts: "
    f"{', '.join(sorted({c for t in targets.values() for c in t['cohorts']}))})", "",
    f"Built {datetime.date.today()} by `__Cytosplore_export/scan_source_tables.py`.", "",
    "## Public source tables (__Public/comparative-data)", "",
    f"- {len(rows_out)} tables scanned; {len(tgt_tables)} hold at least one target species (species or genus level).",
    *[f"- {k}: {v}" for k, v in vc.most_common()], "",
    f"## Tables with target species that do NOT reach the export ({len(nw)})", "",
    "| table (item) | folder | target species | genus-only | stage | role | main traits |", "|---|---|---|---|---|---|---|",
    *[f"| {r['item_name'] or r['file']} | {r['paper_folder']} | {r['n_target_species']} | {r['n_target_genus_only']} | {r['progress_stage']} | {r['data_role']} | {r['main_traits'][:70]} |"
      for r in sorted(nw, key=lambda r: -(r['n_target_species'] + r['n_target_genus_only']))], "",
    f"## Tables whose paper is in a merge but the table itself is not individually referenced ({len(pu)})", "",
    "Compilations loaded as a whole (Karbowski 2007, Kaufman 2004) land here by construction; the rest need a look at the merge inputs.", "",
    "| table (item) | paper wired in | target species | genus-only | main traits |", "|---|---|---|---|---|",
    *[f"| {r['item_name'] or r['file']} | {r['paper_wired_in']} | {r['n_target_species']} | {r['n_target_genus_only']} | {r['main_traits'][:70]} |"
      for r in sorted(pu, key=lambda r: (r['paper_folder'], r['item_name']))], "",
    f"## Tables with target species that are flagged, held or excluded ({len(fl) + len(ex)})", "",
    "| table (item) | verdict | registry flag / disposition | errata | in-table flags |", "|---|---|---|---|---|",
    *[f"| {r['item_name'] or r['file']} | {r['verdict']} | {(r['flags_active'] + ' ' + r['disposition'])[:110]} | {r['errata'][:50]} | {r['in_table_flags_on_target_rows'][:60]} |"
      for r in fl + ex], "",
    f"## Registry items without a public table ({len(unbuilt)}; {len(ub_hit)} mention a target species/genus in the folder)", "",
    "| item | stage | role | target mentions | recommendation |", "|---|---|---|---|---|",
    *[f"| {u['item_name']} | {u['progress_stage'][:40]} | {u['data_role'][:20]} | {u['target_mentions_in_folder'][:80]} | {u['recommendation'][:80]} |"
      for u in ub_hit[:60]], "",
    "## Per target species", "",
    "| species | cohorts | tables any | in merge | NOT wired | paper wired, table unclear | flagged/held | excluded |", "|---|---|---|---|---|---|---|---|",
    *[f"| {g['species_sci']} | {g['cohorts']} | {g['n_tables_any']} | {g['n_in_merge']} | {g['n_built_not_wired']} | {g['n_paper_wired_table_unclear']} | {g['n_wired_flagged']} | {g['n_excluded_by_decision']} |" for g in gap_rows], "",
    "## Reading notes", "",
    "- `in merge -> reaches export` means the table (item name or DOI-encoded filename) is referenced by a",
    "  __merging_* table or build script. Harvest-style merges (body_ecology, brain_mass) may consume only some",
    "  columns of a table -- see <merge>_source_columns.csv -- and every merge's select/flag filters may still drop rows.",
    "- `built; NOT wired to any merge` is the actionable gap: a frozen public table exists with target-species rows",
    "  but no merge consumes it.",
    "- `built; no binomial column` tables hold common names or specimen ids only; check `common_name_hits`.",
    "- Genus-level hits count congeners, `Genus sp.` and hybrids; the species-level count is the strict one.",
    "- Flags come from __ReadMe.xlsx (Flags active), SOURCE_DISPOSITION_REGISTER.md, *_errata.csv and any",
    "  status/flag column inside the table, restricted to rows of target species.",
]
open(os.path.join(OUT, "SCAN_SUMMARY.md"), "w", encoding="utf-8").write("\n".join(lines) + "\n")
print("\n".join(lines[:12])); print(f"done -> {OUT}")
