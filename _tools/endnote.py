#!/usr/bin/env python3
"""
Query the EndNote library (References.enl / References.Data) from the shell.

The library is three SQLite files. Nothing here ever writes to them --
every connection is opened read-only, so it is safe to run while
EndNote itself is open.

    References.Data/sdb/sdb.eni   metadata: refs, file_res, groups, terms
    References.Data/sdb/pdb.eni   ~509 MB of PDF text EndNote already extracted
    References.enl                thin shell index (enl_refs); not needed

Because pdb.eni holds pre-extracted text for 8,279 of the 8,469 PDFs,
`search` does full-text over the whole library in about a second without
opening a single PDF. Fall back to `pdf`/pdftotext only when you need
layout, tables, figures, or one of the ~190 unindexed files.

Usage
    endnote.py stats
    endnote.py groups [--members]
    endnote.py find   <terms...> [--group NAME] [--year 1990-2000] [--limit N]
    endnote.py search <terms...> [--group NAME] [--context N] [--limit N]
    endnote.py show   <id>...
    endnote.py text   <id> [--out FILE]
    endnote.py pdf    <id>...

`find` searches metadata (author/title/journal/keywords/abstract/notes).
`search` searches the text inside the PDFs. Multiple terms are ANDed.
Add --json to any subcommand for machine-readable output.

Set ENDNOTE_DATA to override library location.
"""

from __future__ import annotations

import argparse
import glob
import json
import os
import re
import sqlite3
import struct
import sys

# ---------------------------------------------------------------- locating

CANDIDATES = [
    os.environ.get("ENDNOTE_DATA", ""),
    *glob.glob("/sessions/*/mnt/References.Data"),
    os.path.expanduser("~/Documents/References.Data"),
]


def find_root() -> str:
    for c in CANDIDATES:
        if c and os.path.isfile(os.path.join(c, "sdb", "sdb.eni")):
            return c
    sys.exit(
        "Could not find References.Data. Set ENDNOTE_DATA to the folder "
        "containing sdb/sdb.eni."
    )


ROOT = find_root()
SDB = os.path.join(ROOT, "sdb", "sdb.eni")
PDB = os.path.join(ROOT, "sdb", "pdb.eni")
PDFDIR = os.path.join(ROOT, "PDF")


def connect(path: str) -> sqlite3.Connection:
    """Read-only connection. EndNote uses a custom collation on some
    tables; register a case-insensitive stand-in so those queries work."""
    con = sqlite3.connect(f"file:{path}?mode=ro", uri=True)
    con.create_collation(
        "ENCI_Base", lambda a, b: (a.lower() > b.lower()) - (a.lower() < b.lower())
    )
    con.row_factory = sqlite3.Row
    return con


# ---------------------------------------------------------------- helpers

# EndNote's internal reference_type codes. Best-effort; unknown codes
# fall through to "type:N" rather than being mislabelled.
REFTYPE = {
    0: "Journal Article", 1: "Book", 2: "Thesis", 3: "Conference Paper",
    5: "Newspaper Article", 6: "Computer Program", 7: "Book Section",
    8: "Magazine Article", 9: "Edited Book", 10: "Report",
    16: "Web Page", 20: "Unpublished Work", 21: "Generic",
    22: "Statute", 29: "Book", 30: "Online Database", 31: "Classical Work",
    33: "Conference Proceedings", 37: "Dataset", 40: "Encyclopedia Entry",
    43: "Blog", 47: "Standard", 48: "Dataset",
}


def reftype(n: int) -> str:
    return REFTYPE.get(n, f"type:{n}")


def authors(raw: str, maxn: int = 0) -> str:
    """EndNote separates authors with \\r."""
    parts = [a.strip() for a in (raw or "").split("\r") if a.strip()]
    if maxn and len(parts) > maxn:
        return "; ".join(parts[:maxn]) + f"; +{len(parts) - maxn}"
    return "; ".join(parts)


def first_author(raw: str) -> str:
    a = (raw or "").split("\r")[0].strip()
    return a.split(",")[0].strip() or "?"


def cite(r: sqlite3.Row) -> str:
    return f"{first_author(r['author'])} {r['year'] or 'n.d.'}"


def squeeze(s: str) -> str:
    return re.sub(r"\s+", " ", s).strip()


def snippets(text: str, terms: list[str], width: int, maxn: int = 3) -> list[str]:
    """Context windows around matches, one set per term."""
    out, seen = [], []
    for t in terms:
        for m in re.finditer(re.escape(t), text, re.I):
            a, b = max(0, m.start() - width), min(len(text), m.end() + width)
            if any(abs(a - p) < width for p in seen):
                continue
            seen.append(a)
            frag = squeeze(text[a:b])
            frag = re.sub(f"({re.escape(t)})", r"**\1**", frag, flags=re.I)
            out.append(("..." if a else "") + frag + ("..." if b < len(text) else ""))
            break
        if len(out) >= maxn:
            break
    return out


def parse_members(blob: bytes) -> list[int]:
    """Group members blob: <uint32 magic><uint32 count><uint32 id * count>."""
    if not blob or len(blob) < 8:
        return []
    _, count = struct.unpack("<2I", blob[:8])
    count = min(count, (len(blob) - 8) // 4)
    return list(struct.unpack(f"<{count}I", blob[8 : 8 + 4 * count]))


def load_groups(con: sqlite3.Connection) -> list[dict]:
    groups = []
    for row in con.execute("SELECT group_id, spec, members FROM groups"):
        spec = bytes(row["spec"])
        name = re.search(rb"<name>(.*?)</name>", spec, re.S)
        rules = re.findall(rb"<rule>TYPE;(\d+)</rule>", spec)
        kinds = {"1": "set", "3": "custom", "4": "smart", "6": "online search"}
        groups.append({
            "id": row["group_id"],
            "name": name.group(1).decode("utf-8", "replace") if name else "?",
            "kind": kinds.get(rules[0].decode() if rules else "", "other"),
            "members": parse_members(bytes(row["members"])),
        })
    return sorted(groups, key=lambda g: g["name"].lower())


def group_ids(con: sqlite3.Connection, pattern: str) -> tuple[set[int], list[str]]:
    matched = [g for g in load_groups(con) if pattern.lower() in g["name"].lower()]
    ids: set[int] = set()
    for g in matched:
        ids |= set(g["members"])
    return ids, [g["name"] for g in matched]


def attach_path(rel: str) -> str:
    """PDFs live under PDF/<hash>/; other attachment types (file_type != 1)
    sit at the library root instead. Try both, prefer whichever exists."""
    for base in (PDFDIR, ROOT):
        p = os.path.join(base, rel)
        if os.path.exists(p):
            return p
    return os.path.join(PDFDIR, rel)


def attachments(con: sqlite3.Connection, rid: int) -> list[str]:
    return [
        attach_path(r["file_path"])
        for r in con.execute(
            "SELECT file_path FROM file_res WHERE refs_id=? ORDER BY file_pos", (rid,)
        )
    ]


def year_filter(spec: str):
    if "-" in spec:
        lo, hi = spec.split("-", 1)
    else:
        lo = hi = spec
    lo, hi = int(lo or 0), int(hi or 9999)
    def ok(y: str) -> bool:
        m = re.search(r"\d{4}", y or "")
        return bool(m) and lo <= int(m.group()) <= hi
    return ok


# ---------------------------------------------------------------- commands

def cmd_stats(a) -> None:
    con, pcon = connect(SDB), connect(PDB)
    n_refs = con.execute("SELECT COUNT(*) FROM refs WHERE trash_state=0").fetchone()[0]
    n_att = con.execute("SELECT COUNT(DISTINCT refs_id) FROM file_res").fetchone()[0]
    n_idx = pcon.execute("SELECT COUNT(DISTINCT refs_id) FROM pdf_index").fetchone()[0]
    chars = pcon.execute("SELECT SUM(length(contents)) FROM pdf_index").fetchone()[0]
    paths = [r["file_path"] for r in con.execute("SELECT file_path FROM file_res")]
    missing = [p for p in paths if not os.path.exists(attach_path(p))]
    grp = load_groups(con)
    years = [r["year"] for r in con.execute("SELECT year FROM refs WHERE year<>''")]
    yy = sorted(int(m.group()) for y in years if (m := re.search(r"\d{4}", y or "")))

    if a.json:
        print(json.dumps({
            "root": ROOT, "references": n_refs, "with_attachments": n_att,
            "fulltext_indexed": n_idx, "fulltext_chars": chars,
            "attachments": len(paths), "missing_files": missing,
            "groups": len(grp), "year_range": [yy[0], yy[-1]] if yy else None,
        }, indent=2))
        return

    print(f"library          {ROOT}")
    print(f"references       {n_refs:,} (in library, excluding trash)")
    print(f"with attachment  {n_att:,}")
    print(f"attachments      {len(paths):,}  ({len(missing)} file(s) missing on disk)")
    print(f"full text ready  {n_idx:,} refs, {chars / 1e6:,.0f} M characters")
    print(f"groups           {len(grp):,}")
    if yy:
        print(f"years            {yy[0]}-{yy[-1]}")
    for m in missing:
        print(f"  missing: {m}")
    types = con.execute(
        "SELECT reference_type t, COUNT(*) n FROM refs WHERE trash_state=0 "
        "GROUP BY 1 ORDER BY n DESC LIMIT 8"
    ).fetchall()
    print("\ntop reference types")
    for r in types:
        print(f"  {r['n']:6,}  {reftype(r['t'])}")


def cmd_groups(a) -> None:
    con = connect(SDB)
    grp = [g for g in load_groups(con)
           if not a.filter or a.filter.lower() in g["name"].lower()]
    if a.json:
        print(json.dumps(grp if a.members else
                         [{k: v for k, v in g.items() if k != "members"} for g in grp],
                         indent=2))
        return
    for g in grp:
        n = len(g["members"])
        print(f"{g['id']:>4}  {n:>5}  {g['kind']:<13} {g['name']}")
        if a.members and n:
            for rid in g["members"]:
                r = con.execute("SELECT author,year,title FROM refs WHERE id=?",
                                (rid,)).fetchone()
                if r:
                    print(f"          {rid:>6}  {cite(r):<22} {r['title'][:64]}")
    print(f"\n{len(grp)} group(s). Columns: id, members, kind, name.")


FIND_FIELDS = ["author", "title", "secondary_title", "keywords", "abstract",
               "notes", "year", "publisher", "research_notes"]


def cmd_find(a) -> None:
    con = connect(SDB)
    where = ["trash_state=0"]
    params: list[str] = []
    for t in a.terms:
        where.append("(" + " OR ".join(f"{f} LIKE ?" for f in FIND_FIELDS) + ")")
        params += [f"%{t}%"] * len(FIND_FIELDS)

    keep = None
    if a.group:
        keep, names = group_ids(con, a.group)
        if not names:
            sys.exit(f"No group matching {a.group!r}. Try: endnote.py groups")
        print(f"# group filter: {', '.join(names)} ({len(keep)} refs)", file=sys.stderr)

    yok = year_filter(a.year) if a.year else None
    rows = []
    for r in con.execute(
        f"SELECT * FROM refs WHERE {' AND '.join(where)} ORDER BY year DESC", params
    ):
        if keep is not None and r["id"] not in keep:
            continue
        if yok and not yok(r["year"]):
            continue
        rows.append(r)
        if len(rows) >= a.limit:
            break
    emit_list(con, rows, a)


def cmd_search(a) -> None:
    con, pcon = connect(SDB), connect(PDB)
    sql = "SELECT refs_id, contents FROM pdf_index WHERE " + " AND ".join(
        ["contents LIKE ?"] * len(a.terms)
    )
    params = [f"%{t}%" for t in a.terms]

    keep = None
    if a.group:
        keep, names = group_ids(con, a.group)
        if not names:
            sys.exit(f"No group matching {a.group!r}. Try: endnote.py groups")
        print(f"# group filter: {', '.join(names)} ({len(keep)} refs)", file=sys.stderr)

    hits, total = [], 0
    for row in pcon.execute(sql, params):
        rid = row["refs_id"]
        if keep is not None and rid not in keep:
            continue
        total += 1
        if len(hits) >= a.limit:
            continue
        r = con.execute("SELECT * FROM refs WHERE id=? AND trash_state=0",
                        (rid,)).fetchone()
        if r:
            hits.append((r, snippets(row["contents"], a.terms, a.context)))

    if a.json:
        print(json.dumps([{
            "id": r["id"], "cite": cite(r), "authors": authors(r["author"]),
            "year": r["year"], "title": r["title"], "journal": r["secondary_title"],
            "doi": r["electronic_resource_number"],
            "pdf": attachments(con, r["id"]), "snippets": s,
        } for r, s in hits], indent=2))
        return

    for r, snips in hits:
        print(f"\n[{r['id']}] {authors(r['author'], 3)} ({r['year']})")
        print(f"      {r['title']}")
        if r["secondary_title"]:
            print(f"      {r['secondary_title']}")
        for s in snips:
            print(f"      > {s}")
    shown = len(hits)
    print(f"\n{total} document(s) matched {' AND '.join(a.terms)!r}"
          + (f"; showing {shown}. Use --limit to see more." if total > shown else "."))


def emit_list(con, rows, a) -> None:
    if a.json:
        print(json.dumps([{
            "id": r["id"], "cite": cite(r), "authors": authors(r["author"]),
            "year": r["year"], "title": r["title"], "journal": r["secondary_title"],
            "type": reftype(r["reference_type"]),
            "doi": r["electronic_resource_number"],
            "pdf": attachments(con, r["id"]),
        } for r in rows], indent=2))
        return
    for r in rows:
        pdfs = attachments(con, r["id"])
        mark = "*" if pdfs else " "
        print(f"{mark}[{r['id']}] {authors(r['author'], 3)} ({r['year']}) "
              f"{reftype(r['reference_type'])}")
        print(f"      {r['title']}")
        if r["secondary_title"]:
            print(f"      {r['secondary_title']}")
    print(f"\n{len(rows)} result(s). '*' = has PDF. Use `show <id>` for detail.")


SHOW_FIELDS = [
    ("author", "authors"), ("year", "year"), ("title", "title"),
    ("secondary_title", "journal"), ("volume", "volume"), ("number", "issue"),
    ("pages", "pages"), ("publisher", "publisher"),
    ("place_published", "place"), ("edition", "edition"),
    ("electronic_resource_number", "doi"), ("url", "url"),
    ("isbn", "isbn"), ("keywords", "keywords"), ("label", "label"),
    ("call_number", "call number"), ("language", "language"),
    ("abstract", "abstract"), ("notes", "notes"),
    ("research_notes", "research notes"),
]


def cmd_show(a) -> None:
    con, pcon = connect(SDB), connect(PDB)
    groups = load_groups(con)
    out = []
    for rid in a.ids:
        r = con.execute("SELECT * FROM refs WHERE id=?", (rid,)).fetchone()
        if not r:
            print(f"[{rid}] not found", file=sys.stderr)
            continue
        pdfs = attachments(con, rid)
        ln = pcon.execute(
            "SELECT SUM(length(contents)) FROM pdf_index WHERE refs_id=?", (rid,)
        ).fetchone()[0]
        memb = [g["name"] for g in groups if rid in g["members"]]

        if a.json:
            out.append({
                **{k: r[f] for f, k in SHOW_FIELDS},
                "id": rid, "type": reftype(r["reference_type"]),
                "authors": authors(r["author"]), "groups": memb,
                "pdf": pdfs, "fulltext_chars": ln or 0,
            })
            continue

        print(f"\n=== [{rid}] {reftype(r['reference_type'])}"
              + (" (IN TRASH)" if r["trash_state"] else ""))
        for f, label in SHOW_FIELDS:
            v = squeeze(authors(r[f]) if f == "author" else r[f] or "")
            if v:
                print(f"  {label:<15} {v}")
        if memb:
            print(f"  {'groups':<15} {', '.join(memb)}")
        for p in pdfs:
            ok = "" if os.path.exists(p) else "  [FILE MISSING]"
            print(f"  {'pdf':<15} {p}{ok}")
        print(f"  {'full text':<15} "
              + (f"{ln:,} chars indexed (endnote.py text {rid})" if ln else "not indexed"))
    if a.json:
        print(json.dumps(out, indent=2))


def cmd_text(a) -> None:
    con, pcon = connect(SDB), connect(PDB)
    rows = pcon.execute(
        "SELECT contents FROM pdf_index WHERE refs_id=? ORDER BY pdfi_id", (a.id,)
    ).fetchall()
    text = "\n".join(r["contents"] for r in rows)

    if not text.strip():
        pdfs = [p for p in attachments(con, a.id) if os.path.exists(p)]
        if not pdfs:
            sys.exit(f"[{a.id}] no indexed text and no PDF on disk.")
        sys.exit(
            f"[{a.id}] not in the text index. Extract from the PDF instead:\n"
            f"  pdftotext -layout {pdfs[0]!r} -"
        )
    if a.out:
        with open(a.out, "w") as fh:
            fh.write(text)
        print(f"{len(text):,} chars -> {a.out}")
    else:
        sys.stdout.write(text)


def cmd_pdf(a) -> None:
    con = connect(SDB)
    for rid in a.ids:
        found = attachments(con, rid)
        if not found:
            print(f"[{rid}] no attachment", file=sys.stderr)
        for p in found:
            print(p if os.path.exists(p) else f"{p}  [MISSING]")


# ---------------------------------------------------------------- cli

def main() -> None:
    p = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter
    )
    sub = p.add_subparsers(dest="cmd", required=True)

    def add(name, fn, help_):
        s = sub.add_parser(name, help=help_)
        s.add_argument("--json", action="store_true", help="machine-readable output")
        s.set_defaults(func=fn)
        return s

    add("stats", cmd_stats, "library overview and integrity check")

    g = add("groups", cmd_groups, "list EndNote groups")
    g.add_argument("filter", nargs="?", help="substring of group name")
    g.add_argument("--members", action="store_true", help="list references in each")

    f = add("find", cmd_find, "search reference metadata")
    f.add_argument("terms", nargs="+")
    f.add_argument("--group", help="restrict to a group")
    f.add_argument("--year", help="e.g. 1990-2000 or 1997")
    f.add_argument("--limit", type=int, default=40)

    s = add("search", cmd_search, "full-text search inside the PDFs")
    s.add_argument("terms", nargs="+")
    s.add_argument("--group", help="restrict to a group")
    s.add_argument("--context", type=int, default=110, help="snippet width")
    s.add_argument("--limit", type=int, default=15)

    sh = add("show", cmd_show, "full record for one or more ids")
    sh.add_argument("ids", nargs="+", type=int)

    t = add("text", cmd_text, "dump extracted PDF text")
    t.add_argument("id", type=int)
    t.add_argument("--out", help="write to file instead of stdout")

    d = add("pdf", cmd_pdf, "print PDF path(s) for ids")
    d.add_argument("ids", nargs="+", type=int)

    a = p.parse_args()
    a.func(a)


if __name__ == "__main__":
    try:  # allow piping into head/less without a traceback
        import signal
        signal.signal(signal.SIGPIPE, signal.SIG_DFL)
    except (ImportError, AttributeError, ValueError):
        pass
    main()
