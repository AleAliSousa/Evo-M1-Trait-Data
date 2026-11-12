#!/usr/bin/env python3
"""
add_sequence_letters_20261110.py -- give the missing sequence letter to papers that share
author + year with an already-lettered paper, everywhere in the repo (owner request, 10 Nov 2026).

Why: when two papers share a Publication name (e.g. Koay_etal_1998 and Koay_etal_1998_b), the one
without a letter must get one, or item names collide. __ReadMe.xlsx column B ("sequence") was set
on 10 Nov 2026; this tool brings folders, file names and every text reference in line with it.

  old publication name      new publication name       paper
  Heffner_Heffner_2010      Heffner_Heffner_2010_a     whitetail deer audiogram (JASA 127:EL111)
  Heffner_etal_2001         Heffner_etal_2001_b        audiograms of five rodents (Hear Res 157)
  Koay_etal_1998            Koay_etal_1998_a           megachiropteran fruit bat (J Comp Psychol 112)
  Lewitus_etal_2012         Lewitus_etal_2012_a        V1 cellular signatures (Brain Struct Funct)
  Smaers_etal_2011          Smaers_etal_2011_a         primate prefrontal cortex evolution (Front Hum Neurosci)
  Young_etal_2013           Young_etal_2013_a          cell and neuron densities in M1 (Front Neural Circuits)

(Plavcan_vanSchaik_1997: the folders were already _a/_b; only the registry needed letters.)

What it does (dry run by default; nothing changes until you add --apply):
  1. renames every folder or file whose name holds an old name (paper folder, item files,
     reference_tables/*, standardized_term_by_reference/*, ...), deepest first;
  2. rewrites the old name to the new one inside text files (.R .py .sh .md .txt .csv .tsv .json
     .yml .html .js ...): item scripts, READMEs, definitions, species keys, merges, the app,
     public TSVs and paper-level ReadMes.
An old name is only replaced as a whole token, never when it already carries a sequence letter
(Koay_etal_1998_b_Figure8 and Koay_etal_1998_a_Figure6 are left alone), so the tool is safe to run
twice. Not touched: .git, binary files (pdf, xlsx, docx; their names are still renamed), frozen
snapshots (*_snapshot.*: renamed, content never edited), R history, and execution logs in _checks
(they record what ran under the old names).

Usage (from Terminal):
  python3 _tools/add_sequence_letters_20261110.py             # dry run: lists every change
  python3 _tools/add_sequence_letters_20261110.py --apply     # make the changes
  python3 _tools/add_sequence_letters_20261110.py --root "/path/to/Evo-M1-Trait-Data-restricted"
                                                               # same for the restricted repo
Then re-run the six papers' R scripts, e.g.
  bash run_all_scripts.sh Heffner_Heffner_2010_a Heffner_etal_2001_b Koay_etal_1998_a \
       Lewitus_etal_2012_a Smaers_etal_2011_a Young_etal_2013_a
Close Excel and RStudio projects that have these files open before --apply.
"""
import argparse
import os
import re
import sys
import unicodedata

RENAMES = [
    ("Heffner_Heffner_2010", "Heffner_Heffner_2010_a"),
    ("Heffner_etal_2001", "Heffner_etal_2001_b"),
    ("Koay_etal_1998", "Koay_etal_1998_a"),
    ("Lewitus_etal_2012", "Lewitus_etal_2012_a"),
    ("Smaers_etal_2011", "Smaers_etal_2011_a"),
    ("Young_etal_2013", "Young_etal_2013_a"),
]

TEXT_EXT = {".r", ".rmd", ".qmd", ".py", ".sh", ".md", ".markdown", ".txt", ".csv", ".tsv",
            ".json", ".yml", ".yaml", ".html", ".htm", ".js", ".css", ".bib", ".tex", ".nex"}
SKIP_DIRS = {".git", ".Rproj.user", "node_modules", "renv", ".venv", "__pycache__"}
SKIP_NAMES = {".Rhistory", ".DS_Store"}
MAX_TEXT_BYTES = 200 * 1024 * 1024


def token_re(old):
    # whole token; not when followed by a single-letter sequence suffix (_a, _b, ...)
    return re.compile(r"(?<![A-Za-z0-9])" + re.escape(old) +
                      r"(?!_[a-z](?![A-Za-z0-9]))(?![A-Za-z0-9])")


PATTERNS = [(token_re(old), old, new) for old, new in RENAMES]


def nfc(s):
    return unicodedata.normalize("NFC", s)


def new_name(name):
    out, n = name, 0
    for rx, old, new in PATTERNS:
        out, k = rx.subn(new, out)
        n += k
    return out, n


def is_log(path, root):
    rel = os.path.relpath(path, root).replace(os.sep, "/")
    base = os.path.basename(rel).lower()
    return rel.startswith("_checks/") and ("log" in base)


def find_root(start):
    d = os.path.abspath(start)
    while True:
        if os.path.isfile(os.path.join(d, "__ReadMe.xlsx")):
            return d
        parent = os.path.dirname(d)
        if parent == d:
            return None
        d = parent


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--apply", action="store_true", help="make the changes (default: dry run)")
    ap.add_argument("--root", help="repo folder (default: the folder above this script holding __ReadMe.xlsx)")
    a = ap.parse_args()

    root = os.path.abspath(a.root) if a.root else find_root(os.path.dirname(os.path.abspath(__file__)))
    if not root or not os.path.isdir(root):
        sys.exit("Repo root not found; pass --root.")
    if os.path.exists(os.path.join(root, "~$__ReadMe.xlsx")):
        sys.exit("__ReadMe.xlsx is open in Excel (~$__ReadMe.xlsx present). Close it and run again.")
    mode = "APPLY" if a.apply else "DRY RUN"
    print(f"[{mode}] repo: {root}")

    # ---- pass 1: text content ------------------------------------------------------------
    edits, scanned, skipped_big = [], 0, []
    me = os.path.abspath(__file__)
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS and not d.startswith("__Archive")]
        for fn in filenames:
            if fn in SKIP_NAMES or fn.startswith("sequence_letters_20261110"):
                continue
            p = os.path.join(dirpath, fn)
            if os.path.abspath(p) == me or fn == os.path.basename(me):
                continue
            if os.path.splitext(fn)[1].lower() not in TEXT_EXT or is_log(p, root):
                continue
            if "_snapshot." in fn:          # frozen evidence: renamed below, content never edited
                continue
            try:
                size = os.path.getsize(p)
            except OSError:
                continue
            if size > MAX_TEXT_BYTES:
                skipped_big.append(p)
                continue
            scanned += 1
            with open(p, "rb") as fh:
                raw = fh.read()
            txt = raw.decode("utf-8", errors="surrogateescape")
            if not any(old in txt for old, _ in RENAMES):
                continue
            out, n = new_name(txt)
            if n:
                edits.append((p, n))
                if a.apply:
                    with open(p, "wb") as fh:
                        fh.write(out.encode("utf-8", errors="surrogateescape"))

    # ---- pass 2: names (deepest first so parent paths stay valid) ---------------------------
    moves = []
    for dirpath, dirnames, filenames in os.walk(root, topdown=False):
        rel_parts = os.path.relpath(dirpath, root).split(os.sep)
        if any(part in SKIP_DIRS or part.startswith("__Archive") for part in rel_parts):
            continue
        for name in filenames + dirnames:
            if name in SKIP_DIRS:
                continue
            nn, n = new_name(nfc(name))
            if n and nn != nfc(name):
                src, dst = os.path.join(dirpath, name), os.path.join(dirpath, nn)
                if os.path.exists(dst):
                    print(f"  ! target exists, not renamed: {os.path.relpath(dst, root)}")
                    continue
                moves.append((src, dst))
                if a.apply:
                    os.rename(src, dst)

    # ---- report ---------------------------------------------------------------------------------
    print(f"\nText files scanned: {scanned}; files with references: {len(edits)}; "
          f"replacements: {sum(n for _, n in edits)}")
    for p, n in sorted(edits):
        print(f"  edit  {n:>4}  {os.path.relpath(p, root)}")
    print(f"\nRenames: {len(moves)}")
    for src, dst in moves:
        print(f"  move  {os.path.relpath(src, root)}  ->  {os.path.basename(dst)}")
    for p in skipped_big:
        print(f"  ! not scanned (over {MAX_TEXT_BYTES // 2**20} MB): {os.path.relpath(p, root)}")
    if a.apply:
        rep = os.path.join(root, "_checks", "sequence_letters_20261110_report.csv")
        if os.path.isdir(os.path.dirname(rep)):
            with open(rep, "w", encoding="utf-8") as fh:
                fh.write("action,count,path,new_name\n")
                for p, n in sorted(edits):
                    fh.write(f'edit,{n},"{os.path.relpath(p, root)}",\n')
                for src, dst in moves:
                    fh.write(f'rename,1,"{os.path.relpath(src, root)}","{os.path.basename(dst)}"\n')
            print(f"\nReport written: {os.path.relpath(rep, root)}")
        print("\nDone. Next: re-run the six papers' R scripts (see the top of this file).")
    else:
        print("\nDry run only: nothing was changed. Add --apply to make these changes.")


if __name__ == "__main__":
    main()
