"""Fetch NCBI Taxonomy name reports for every species name the project serves, offline afterwards.

Writes _keys/ncbi_name_reports.csv: one row per queried name with NCBI's taxid, rank, current
scientific name and how NCBI classes the queried name for that taxon (current, homotypic_synonym,
basionym, heterotypic_synonym, other = matched through a common name, not_found), with the author
and year NCBI gives the queried name (name_authority) and the current name (current_authority). The table builder reads only that file; nothing
queries NCBI at build time (owner, 26 November 2026: one name per NCBI taxon, homotypic synonyms
joined to NCBI's current name).

Names queried: the Species column of every feed in _keys/app_feeds.csv (the names the table receives),
the names of __compiled/species_names.csv and species_name_register.csv, Species and Subspecies of
__compiled/compiled_long.csv.gz, the species names of
__compiled/datapoints.csv.gz, the accepted names of _keys/species_reference.csv, the names in
_keys/species_display_aliases.csv and _keys/species_pooling.csv, and the tip binomials of
_keys/mammal_tree.nwk.

Usage:  python3 _keys/fetch_ncbi_names.py [repo]      (needs network access to api.ncbi.nlm.nih.gov)
"""
import csv, gzip, json, re, sys, time, datetime, urllib.request
from pathlib import Path

API = "https://api.ncbi.nlm.nih.gov/datasets/v2/taxonomy/name_report"
BATCH = 200
FIELDS = ["query", "tax_id", "rank", "current_name", "current_authority", "name_class", "name_authority",
          "group_name", "n_reports", "checked_on", "note"]


def names_to_query(repo):
    names = set()
    with gzip.open(repo / "__compiled" / "compiled_long.csv.gz", "rt", encoding="utf-8") as f:
        for r in csv.DictReader(f):
            for c in ("Species", "Subspecies"):
                v = (r.get(c) or "").strip()
                if v and v != "NA":
                    names.add(v)
    # the names the table receives: every feed in _keys/app_feeds.csv, and the build's own name files
    feeds = [repo / "__compiled" / "species_names.csv", repo / "__compiled" / "species_name_register.csv"]
    with open(repo / "_keys" / "app_feeds.csv", encoding="utf-8-sig") as f:
        for r in csv.DictReader(f):
            if (r.get("path") or "").endswith(".csv"):
                feeds.append(repo / r["path"])
    for fp in feeds:
        if not fp.exists():
            continue
        with open(fp, encoding="utf-8-sig", errors="replace") as f:
            rd = csv.DictReader(f)
            col = next((c for c in ("Species", "name", "species") if c in (rd.fieldnames or [])), None)
            if col:
                for r in rd:
                    v = (r.get(col) or "").strip()
                    if v and v != "NA":
                        names.add(v)
    dp = repo / "__compiled" / "datapoints.csv.gz"
    if dp.exists():
        with gzip.open(dp, "rt", encoding="utf-8") as f:
            for r in csv.DictReader(f):
                for c in ("species_resolved", "species", "species_accepted"):
                    v = (r.get(c) or "").strip()
                    if v and v != "NA":
                        names.add(v)
    for rel, cols in ((("_keys", "species_reference.csv"), ("accepted_name",)),
                      (("_keys", "species_display_aliases.csv"), ("variant", "canonical")),
                      (("_keys", "species_pooling.csv"), ("member",))):
        with open(repo.joinpath(*rel), encoding="utf-8-sig") as f:
            for r in csv.DictReader(f):
                for c in cols:
                    v = (r.get(c) or "").strip()
                    if v and v != "NA":
                        names.add(v)
    tree = (repo / "_keys" / "mammal_tree.nwk").read_text(encoding="utf-8")
    for tip in re.findall(r"[(,]\s*([A-Za-z][A-Za-z0-9_.'-]*)\s*(?=[:,)])", tree):
        parts = tip.replace("_", " ").split()
        if len(parts) >= 2:
            names.add(" ".join(parts[:2]))
    # NCBI only knows Latin binomials and trinomials: skip labels with notes, digits or parentheses
    return sorted(n for n in names if re.fullmatch(r"[A-Z][a-z-]+( [a-z][a-z-]+){1,2}( sp\.)?", n) or
                  re.fullmatch(r"[A-Z][a-z-]+ sp\.", n))


def post(batch):
    body = json.dumps({"taxons": batch}).encode()
    for attempt in range(5):
        try:
            req = urllib.request.Request(API, data=body, headers={"Content-Type": "application/json",
                                                                  "Accept": "application/json"})
            with urllib.request.urlopen(req, timeout=120) as r:
                return json.load(r)
        except Exception as e:  # rate limit or a transient error: wait and retry
            if attempt == 4:
                raise
            time.sleep(2 * (attempt + 1))


def classify(q, t):
    """How NCBI classes the queried name for this taxon, and the author and year NCBI gives it."""
    ql = q.lower()
    cur = t.get("current_scientific_name") or {}
    if (cur.get("name") or "").lower() == ql:
        return "current", cur.get("authority", "")
    for x in cur.get("homotypic_synonyms") or []:
        if (x.get("name") or "").lower() == ql:
            return "homotypic_synonym", x.get("authority", "")
    b = cur.get("basionym") or {}
    if (b.get("name") or "").lower() == ql:
        return "basionym", b.get("authority", "")
    for x in t.get("heterotypic_synonyms") or cur.get("heterotypic_synonyms") or []:
        if (x.get("name") or "").lower() == ql:
            return "heterotypic_synonym", x.get("authority", "")
    return "other", ""


def main():
    repo = Path(sys.argv[1] if len(sys.argv) > 1 else Path(__file__).resolve().parent.parent)
    names = names_to_query(repo)
    today = datetime.date.today().isoformat()
    rows = []
    for i in range(0, len(names), BATCH):
        batch = names[i:i + BATCH]
        got = {}
        for rep in post(batch).get("reports", []):
            for q in rep.get("query") or []:
                got.setdefault(q, []).append(rep)
        for q in batch:
            reps = [r for r in got.get(q, []) if r.get("taxonomy")]
            if not reps:
                err = "; ".join(e.get("reason", "") for r in got.get(q, []) for e in (r.get("errors") or [])
                                if "is not a recognized NCBI Taxonomy name" not in e.get("reason", ""))
                rows.append(dict(query=q, name_class="not_found", n_reports=0, checked_on=today, note=err[:200]))
                continue
            for r in reps:
                t = r["taxonomy"]; cur = t.get("current_scientific_name") or {}
                cls, auth = classify(q, t)
                rows.append(dict(query=q, tax_id=t.get("tax_id", ""), rank=(t.get("rank") or "").lower(),
                                 current_name=cur.get("name", ""), current_authority=cur.get("authority", ""),
                                 name_class=cls, name_authority=auth, group_name=t.get("group_name", ""),
                                 n_reports=len(reps), checked_on=today, note=""))
        time.sleep(0.4)
        print(f"  {min(i + BATCH, len(names))}/{len(names)} names", file=sys.stderr)
    out = repo / "_keys" / "ncbi_name_reports.csv" if len(sys.argv) < 3 else Path(sys.argv[2])
    with open(out, "w", encoding="utf-8", newline="") as f:
        w = csv.DictWriter(f, fieldnames=FIELDS, lineterminator="\n")
        w.writeheader()
        for r in sorted(rows, key=lambda r: (r["query"], r.get("tax_id", ""))):
            w.writerow({k: r.get(k, "") for k in FIELDS})
    print(f"{out}: {len(rows)} rows for {len(names)} names")


if __name__ == "__main__":
    main()
