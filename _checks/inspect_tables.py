#!/usr/bin/env python3
"""For a candidate reference id, show what a human would check before ingesting:
table captions, and lines that look like species-level data rows."""

import re, sqlite3, sys

PDB = "/sessions/peaceful-charming-feynman/mnt/References.Data/sdb/pdb.eni"
SDB = "/sessions/peaceful-charming-feynman/mnt/References.Data/sdb/sdb.eni"

CAPTION = re.compile(
    r"(?:^|\n)\s*(tables?\s+(?:[0-9]{1,2}|[IVX]{1,5})[.:]?\s+[^\n]{8,150})", re.I)
# a species name followed by numbers on the same line = data row
DATAROW = re.compile(
    r"(?:^|\n)\s*([A-Z][a-z]+(?:\s+[a-z]+){1,2}|[A-Z]\.\s?[a-z]+)"
    r"[^\n0-9]{0,28}((?:\s+[\d.,]{2,10}){2,})")


def main(ids):
    scon = sqlite3.connect(f"file:{SDB}?mode=ro", uri=True)
    scon.create_collation("ENCI_Base", lambda a, b: (a > b) - (a < b))
    pcon = sqlite3.connect(f"file:{PDB}?mode=ro", uri=True)
    for rid in ids:
        r = scon.execute(
            "SELECT author,year,title,secondary_title,volume,pages,publisher "
            "FROM refs WHERE id=?", (rid,)).fetchone()
        txt = "\n".join(x[0] for x in pcon.execute(
            "SELECT contents FROM pdf_index WHERE refs_id=?", (rid,)))
        print("\n" + "=" * 100)
        print(f"[{rid}] {r[0].split(chr(13))[0]} ({r[1]}) {r[2]}")
        print(f"      {r[3] or r[6]} {r[4] or ''} {r[5] or ''}   [{len(txt):,} chars]")

        caps = []
        for m in CAPTION.finditer(txt):
            c = re.sub(r"\s+", " ", m.group(1)).strip()
            if c.lower() not in [x.lower() for x in caps]:
                caps.append(c)
        print(f"\n  -- table captions ({len(caps)}) --")
        for c in caps[:14]:
            print(f"     {c[:120]}")
        if len(caps) > 14:
            print(f"     ... +{len(caps) - 14} more")

        rows = []
        for m in DATAROW.finditer(txt):
            line = re.sub(r"\s+", " ", m.group(0)).strip()
            if len(line) < 120:
                rows.append(line)
        print(f"\n  -- species-shaped data rows ({len(rows)}) --")
        for line in rows[:12]:
            print(f"     {line[:110]}")


if __name__ == "__main__":
    main([int(a) for a in sys.argv[1:]])
