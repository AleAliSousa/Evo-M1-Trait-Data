#!/usr/bin/env python3
"""verify_source_statements.py -- check that every basis statement in
_keys/build_brain_size_basis.py is actually quoted from its source, not paraphrased.

Why this exists: the measurement basis of a brain-size column is only defensible if the
source says it. An inference written in quotation marks looks identical to a quotation in
the emitted key, and a later reader has no way to tell them apart. So each entry in
SOURCE_STATEMENTS is re-checked here against the PDF text it claims to come from, and the
script exits non-zero if a statement cannot be found. Run it after editing that dict.

Text is compared after Unicode normalisation, ligature repair, soft-hyphen removal and
punctuation stripping, because PDF extraction breaks words across line ends. A statement
passes if a run of at least MIN_RUN consecutive words occurs verbatim in the paper.
"""
import glob
import os
import re
import sys
import unicodedata

MIN_RUN = 8          # consecutive words that must match verbatim
HERE = os.path.dirname(os.path.abspath(__file__))
BASE = os.path.dirname(HERE)

try:
    import pypdfium2 as pdfium
except ImportError:
    sys.exit("pypdfium2 is required: pip install pypdfium2")


def normalise(x):
    x = unicodedata.normalize("NFKD", x)
    # PDF extraction marks a hyphenated line break with U+FFFE in these files (and U+00AC
    # in others); dropping it rejoins the split word so a quote can match across the break.
    for ch in ("\u00ad", "\u00ac", "\ufffe", "\ufffd", "\u2010"):
        x = x.replace(ch, "")
    x = x.replace("\ufb01", "fi").replace("\ufb02", "fl")
    # German umlauts are transliterated in the dict (ae/oe/ue) to keep the file ASCII
    for a, b in (("ä", "ae"), ("ö", "oe"), ("ü", "ue"), ("ß", "ss")):
        x = x.replace(a, b)
    x = re.sub(r"[^a-z0-9 ]", " ", x.lower())
    return re.sub(r"\s+", " ", x).strip()


def paper_text(folder):
    pdfs = [p for p in glob.glob(os.path.join(BASE, folder, "*.pdf"))
            if "-s1" not in os.path.basename(p).lower()]
    if not pdfs:
        return None
    doc = pdfium.PdfDocument(max(pdfs, key=os.path.getsize))
    return normalise(" ".join((doc[i].get_textpage().get_text_range() or "")
                              for i in range(len(doc))))


def longest_run(statement, text):
    w = normalise(statement).split()
    for L in range(len(w), 2, -1):
        if any(" ".join(w[i:i + L]) in text for i in range(len(w) - L + 1)):
            return L
    return 0


src = open(os.path.join(HERE, "build_brain_size_basis.py"), encoding="utf-8").read()
i = src.index("SOURCE_STATEMENTS = {")
ns = {}
exec(src[src.index("PAPER_PROSE = "):src.index("\n}\n", i) + 3], ns)
STATEMENTS, FOLDER_NOTE = ns["SOURCE_STATEMENTS"], ns["FOLDER_NOTE"]

fails, checked = [], 0
print(f"{'paper':28s} {'verdict':9s} run  source")
for folder, (text, where) in sorted(STATEMENTS.items()):
    if where == FOLDER_NOTE:
        # not a PDF claim: assert the note really is in the folder definitions file
        got = "".join(open(f, encoding="utf-8", errors="replace").read()
                      for f in glob.glob(os.path.join(BASE, folder, "reference_tables", "*.csv")))
        ok = normalise(text) in normalise(got)
        print(f"{folder:28s} {'OK' if ok else 'FAIL':9s}  --  folder definitions file")
        checked += 1
        if not ok:
            fails.append((folder, "not found in the folder definitions file"))
        continue
    body = paper_text(folder)
    if body is None:
        print(f"{folder:28s} {'SKIP':9s}  --  no PDF in folder")
        continue
    run = longest_run(text, body)
    n = len(normalise(text).split())
    ok = run >= min(MIN_RUN, n)
    print(f"{folder:28s} {'OK' if ok else 'FAIL':9s} {run:3d}/{n:<3d} {where.split(' (')[0]}")
    checked += 1
    if not ok:
        fails.append((folder, f"longest verbatim run {run} words, need {min(MIN_RUN, n)}"))

print(f"\n{checked} statements checked, {len(fails)} failed")
for folder, why in fails:
    print(f"  {folder}: {why}")
sys.exit(1 if fails else 0)
