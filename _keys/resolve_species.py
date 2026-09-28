"""_keys/resolve_species.py -- Python mirror of _keys/resolve_species.R (SPECIES_NAMING.md v1, sec. 3c).

Identical contract to the R resolver so the Python-built merges (__merging_GLI, __merging_weights,
__merging_endocranial_volume, __merging_cerebral_metabolic_rate) resolve exactly like the R ones:

    from resolve_species import resolve_species, paper_folder_of_item
    r = resolve_species(printed, source_publication=<paper folder | list | None>)
    # -> pandas.DataFrame aligned to `printed` with columns
    #    accepted_name, species_basis, reidentified, match_level, unresolved

Normalisation before matching: bytes declared UTF-8, NBSP -> space, strip '*', '_' -> ' ', collapse
whitespace, trim, case-insensitive. Match order: (source_publication, variant_name) -> variant_name
only (if it maps to ONE accepted_name across papers; else match_level 'ambiguous', not applied) ->
hub accepted_name -> cleaned printed string with unresolved=True and species_basis 'unresolved'.
All _keys/*/species_key.csv spokes (unified schema) are bound once and cached at module level.
stdlib + pandas only; no network.

Self-test:  python _keys/resolve_species.py --selftest
  checks the 25 R self-test pairs and 200 random spoke rows, and (when Rscript is on PATH) asserts
  agreement with resolve_species.R on every one of them.
"""
import os, re, sys, csv, glob, json, random, subprocess, tempfile
import pandas as pd

KEYS_DIR = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(KEYS_DIR)
_ENV = {}


def species_normalise(x):
    """Same cleaning as species_normalise() in resolve_species.R (vectorised over a list/Series)."""
    def one(s):
        if s is None or (isinstance(s, float) and pd.isna(s)):
            return None
        s = str(s)
        if isinstance(s, str):
            s = s.encode("utf-8", "surrogateescape").decode("utf-8", "replace")
        s = s.replace("\u00a0", " ").replace("*", "").replace("_", " ")
        s = re.sub(r"\s+", " ", s).strip()
        return s
    return [one(s) for s in x]


def _key(x):
    return [None if s is None else s.lower() for s in species_normalise(x)]


def _load(keys_dir=KEYS_DIR):
    if _ENV.get("keys_dir") == keys_dir and "variants" in _ENV:
        return _ENV
    files = sorted(glob.glob(os.path.join(keys_dir, "*", "species_key.csv")))
    files = [f for f in files if os.path.basename(os.path.dirname(f)) != "specimen_crosswalk"]
    need = ["variant_name", "accepted_name", "source_publication", "collection", "basis"]
    tabs = []
    for f in files:
        k = pd.read_csv(f, dtype=str, keep_default_na=False, na_values=["", "NA"], encoding="utf-8")
        miss = [c for c in need if c not in k.columns]
        if miss:
            raise ValueError(f"resolve_species: spoke {f} lacks column(s) {miss} (unified schema required, see _keys/SPECIES_NAMING.md sec. 3b)")
        k["spoke_file"] = f
        tabs.append(k)
    v = pd.concat(tabs, ignore_index=True)
    v = v[v.variant_name.notna() & (v.variant_name.str.strip() != "") & v.accepted_name.notna() & (v.accepted_name.str.strip() != "")].copy()
    v["accepted_name"] = v.accepted_name.str.strip()
    v["variant_key"] = _key(v.variant_name)
    v["pub_key"] = _key(v.source_publication)
    v["basis"] = v.basis.where(v.basis.notna() & (v.basis != ""), "unspecified_in_source")
    dup = v.duplicated(["pub_key", "variant_key"])
    if dup.any():
        d = v[dup].iloc[0]
        print(f"resolve_species: {int(dup.sum())} duplicate (source_publication, variant_name) spoke row(s) ignored (first wins), e.g. {d.source_publication} / {d.variant_name}", file=sys.stderr)
        v = v[~dup].copy()
    pair = dict(zip(zip(v.pub_key, v.variant_key), zip(v.accepted_name, v.basis)))
    vo = {}
    for vk, grp in v.groupby("variant_key", sort=False):
        vo[vk] = (grp.accepted_name.nunique(), grp.accepted_name.iloc[0], grp.basis.iloc[0])
    hub = pd.read_csv(os.path.join(keys_dir, "species_reference.csv"), dtype=str, keep_default_na=False, na_values=["", "NA"], encoding="utf-8")
    hub = hub[hub.accepted_name.notna() & (hub.accepted_name != "")]
    hubmap = {}
    for a in hub.accepted_name:
        hubmap.setdefault(_key([a])[0], a)
    _ENV.update(keys_dir=keys_dir, variants=v, pair=pair, variant_only=vo, hub=hub, hubmap=hubmap)
    return _ENV


def species_variant_table(keys_dir=KEYS_DIR):
    """Audit view of the bound spoke table (all _keys/*/species_key.csv rows, with normalised keys)."""
    return _load(keys_dir)["variants"].copy()


def resolve_species(printed, source_publication=None, keys_dir=KEYS_DIR):
    """Resolve printed species names to the identity anchor; returns a DataFrame aligned to `printed`."""
    e = _load(keys_dir)
    printed = list(printed) if not isinstance(printed, str) else [printed]
    n = len(printed)
    cleaned = species_normalise(printed)
    vkey = [None if c is None else c.lower() for c in cleaned]
    if source_publication is None or (isinstance(source_publication, float) and pd.isna(source_publication)):
        pubs = [None] * n
    elif isinstance(source_publication, str):
        pubs = [source_publication] * n
    else:
        pubs = list(source_publication)
        if len(pubs) == 1 and n != 1:
            pubs = pubs * n
        if len(pubs) != n:
            raise ValueError("resolve_species: source_publication must be None, a string, or aligned to printed")
    pkey = _key([None if (p is None or (isinstance(p, float) and pd.isna(p))) else p for p in pubs])
    out = dict(accepted_name=[], species_basis=[], reidentified=[], match_level=[], unresolved=[])
    for i in range(n):
        acc, basis, level, unres = cleaned[i], "unresolved", "unresolved", True
        ok = printed[i] is not None and not (isinstance(printed[i], float) and pd.isna(printed[i])) and cleaned[i] not in (None, "")
        if ok:
            hit = e["pair"].get((pkey[i], vkey[i])) if pkey[i] is not None else None
            if hit is not None:
                acc, basis, level, unres = hit[0], hit[1], "paper", False
            else:
                vo = e["variant_only"].get(vkey[i])
                if vo is not None and vo[0] == 1:
                    acc, basis, level, unres = vo[1], vo[2], "variant", False
                else:
                    if vo is not None:
                        level = "ambiguous"
                    h = e["hubmap"].get(vkey[i])
                    if h is not None:
                        acc, basis, level, unres = h, "hub", "hub", False
        out["accepted_name"].append(acc); out["species_basis"].append(basis)
        out["reidentified"].append(basis == "reident"); out["match_level"].append(level); out["unresolved"].append(unres)
    return pd.DataFrame(out)


def paper_folder_of_item(item, repo=REPO):
    """Item name (Stephan_etal_1981_TableI) -> paper folder (Stephan_etal_1981): longest matching
    top-level repo folder, else the item with its trailing _<Table> token stripped. Scalar or list."""
    if "folders" not in _ENV or _ENV.get("repo") != repo:
        _ENV["folders"] = [d for d in os.listdir(repo) if os.path.isdir(os.path.join(repo, d)) and not d.startswith((".", "_"))]
        _ENV["repo"] = repo
    import unicodedata
    fl = {unicodedata.normalize("NFC", f): f for f in _ENV["folders"]}
    def one(it):
        if it is None or (isinstance(it, float) and pd.isna(it)):
            return None
        it = unicodedata.normalize("NFC", str(it))
        hits = [f for f in fl if it == f or it.startswith(f + "_")]
        return max(hits, key=len) if hits else re.sub(r"_[^_]*$", "", it)
    return one(item) if isinstance(item, str) or item is None else [one(i) for i in item]


def paper_folder_of_author_year(author, year, repo=REPO):
    """(first author, year) -> the ONE repo paper folder starting with that author and carrying that
    year (e.g. ('Isler', 2008) -> 'Isler_etal_2008'); None when no folder or several match (ambiguous
    -> the caller resolves without paper scope, as the R merges do)."""
    paper_folder_of_item("x", repo)  # ensure folder cache
    a, y = str(author or "").strip().lower(), str(year or "").strip()
    if not a or not y:
        return None
    hits = [f for f in _ENV["folders"] if re.match(r"^" + re.escape(a) + r"(_|$)", f, re.I) and y in f]
    return hits[0] if len(hits) == 1 else None


def species_columns_summary(rows, by):
    """Collapse per-row species columns onto an aggregated table: one row per `by` group with the
    distinct printed names / bases '; '-joined, accepted_name (joined if not single), reidentified=any."""
    g = rows.groupby(by, sort=False, dropna=False)
    return g.agg(species_printed=("species_printed", lambda x: "; ".join(sorted({str(s) for s in x if pd.notna(s)}))),
                 accepted_name=("accepted_name", lambda x: "; ".join(sorted({str(s) for s in x if pd.notna(s)}))),
                 species_basis=("species_basis", lambda x: "; ".join(sorted({str(s) for s in x if pd.notna(s)}))),
                 reidentified=("reidentified", lambda x: bool(any(bool(v) for v in x)))).reset_index()


# ---- self-test: python _keys/resolve_species.py --selftest -----------------------------------------
if __name__ == "__main__" and "--selftest" in sys.argv:
    cases = [  # (collection, printed, source_publication, expected) -- same 25 pairs as resolve_species.R
        ("Stephan", "Alouatta spp.", "Baron_etal_1983", "Alouatta seniculus"),
        ("Stephan", "Gorilla gorilla", "Stephan_etal_1981", "Gorilla sp."),
        ("Stephan", "Avahi lan. occidentalis", "Frahm_etal_1984", "Avahi occidentalis"),
        ("Allman", "Ateles sp.", "Bush_Allman_2004_b", "Ateles geoffroyi"),
        ("Allman", "Callicebus sp.", "Bush_Allman_2004_a", "Callicebus sp."),
        ("Allman", "Ailurus fulgens", "Bush_Allman_2003", "Ailurus fulgens"),
        ("HerculanoHouzel", "Cynomys sp.", "HerculanoHouzel_etal_2015", "Cynomys sp."),
        ("HerculanoHouzel", "Amblysomus hottentotus", "HerculanoHouzel_etal_2015", "Amblysomus hottentotus"),
        ("HerculanoHouzel", "Homo sapiens sapiens", "Kazu_etal_2014", "Homo sapiens"),
        ("Ashwell", "Aotus trivirgata", "Ashwell__2020", "Aotus trivirgatus"),
        ("Ashwell", "Macropus agilis", "Ashwell__2020", "Notamacropus agilis"),
        ("Ashwell", "Acrobates pygmaeus", "Ashwell__2020", "Acrobates pygmaeus"),
        ("Hof", "Bowhead whale", "Raghanti_etal_2015", "Balaena mysticetus"),
        ("Hof", "Aotus trivirgatus", "Nimchinsky_etal_1999", "Aotus trivirgatus"),
        ("Hof", "Cebus apella", "Raghanti_etal_2015", "Cebus apella"),
        ("Lyamin", "Beluga", "Lyamin_etal_2008", "Delphinapterus leucas"),
        ("Lyamin", "Commerson's dolphin", "Lyamin_etal_2008", "Cephalorhynchus commersonii"),
        ("Lyamin", "Beluga", None, "Delphinapterus leucas"),
        ("Sato", "Mus musculus", "Taniguchi_etal_2022", "Mus musculus"),
        ("Sato", "MUS MUSCULUS", "Taniguchi_etal_2022", "Mus musculus"),
        ("Sato", " Mus_musculus* ", "Taniguchi_etal_2022", "Mus musculus"),
        ("General", "Homo s.", "Armstrong__1979", "Homo sapiens"),
        ("General", "AMH", "Balzeau_etal_2012", "Homo sapiens"),
        ("General", "Neanderthal", "Kochiyama_etal_2018", "Homo neanderthalensis"),
        ("General", "Zaphod beeblebrox", "Nowhere__2099", "Zaphod beeblebrox"),
    ]
    r = resolve_species([c[1] for c in cases], [c[2] for c in cases])
    ok = [a == c[3] for a, c in zip(r.accepted_name, cases)]
    print(f"25 known pairs: {sum(ok)}/25 passed; unresolved fallback flagged: {bool(r.unresolved.iloc[-1])}; reident flagged: {bool(r.reidentified.any())}")
    assert all(ok) and r.unresolved.iloc[-1] and r.reidentified.any()
    vt = species_variant_table()
    assert set(vt.accepted_name) <= set(_load()["hub"].accepted_name), "spoke accepted_name missing from hub"
    random.seed(20260928)
    samp = vt.sample(200, random_state=20260928)
    rs = resolve_species(list(samp.variant_name), list(samp.source_publication))
    agree = (rs.accepted_name.values == samp.accepted_name.values)
    print(f"200 random spoke rows: {int(agree.sum())}/200 resolve to their own accepted_name at match_level=paper ({int((rs.match_level == 'paper').sum())} paper-level)")
    assert agree.all() and (rs.match_level == "paper").all()
    # cross-check against the R resolver on the same 225 inputs
    inp = pd.DataFrame(dict(printed=[c[1] for c in cases] + list(samp.variant_name),
                            pub=[c[2] for c in cases] + list(samp.source_publication)))
    py = pd.concat([r, rs], ignore_index=True)
    with tempfile.TemporaryDirectory() as td:
        fi, fo = os.path.join(td, "in.csv"), os.path.join(td, "out.csv")
        inp.to_csv(fi, index=False)
        rcode = (f'source("{os.path.join(KEYS_DIR, "resolve_species.R")}"); '
                 f'x <- readr::read_csv("{fi}", col_types = readr::cols(.default = readr::col_character())); '
                 f'r <- resolve_species(x$printed, x$pub); readr::write_csv(r, "{fo}")')
        try:
            subprocess.run(["Rscript", "-e", rcode], check=True, capture_output=True, text=True,
                           env={**os.environ, "LC_ALL": os.environ.get("LC_ALL", "en_US.UTF-8"), "LANG": os.environ.get("LANG", "en_US.UTF-8")})
        except (FileNotFoundError, subprocess.CalledProcessError) as ex:
            print(f"R cross-check SKIPPED (Rscript unavailable or failed): {getattr(ex, 'stderr', ex)}"[:300])
        else:
            rr = pd.read_csv(fo, dtype=str, keep_default_na=False)
            same = ((rr.accepted_name.values == py.accepted_name.values) & (rr.species_basis.values == py.species_basis.values)
                    & (rr.match_level.values == py.match_level.values)
                    & (rr.reidentified.str.upper().values == py.reidentified.map(lambda b: "TRUE" if b else "FALSE").values)
                    & (rr.unresolved.str.upper().values == py.unresolved.map(lambda b: "TRUE" if b else "FALSE").values))
            print(f"R cross-check: {int(same.sum())}/{len(same)} inputs agree on accepted_name, species_basis, match_level, reidentified, unresolved")
            if not same.all():
                print(pd.concat([inp[~same], py[~same].reset_index(drop=True), rr[~same].reset_index(drop=True).add_prefix("R_")], axis=1).to_string())
            assert same.all()
    pf = paper_folder_of_item(["Stephan_etal_1981_TableI", "Bush_Allman_2004_a_Table2", "Ashwell__2020_SupplementaryTable", "DosSantos_etal_2020_unpublished", None])
    assert pf == ["Stephan_etal_1981", "Bush_Allman_2004_a", "Ashwell__2020", "DosSantos_etal_2020", None], pf
    print(f"spoke rows bound: {len(vt)} | hub rows: {len(_load()['hub'])} | paper_folder_of_item OK")
    print("SELFTEST OK")
