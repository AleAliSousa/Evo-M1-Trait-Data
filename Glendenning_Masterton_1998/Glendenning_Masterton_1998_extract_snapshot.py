"""Glendenning_Masterton_1998_extract_snapshot.py -- frozen sources for Tables 1-7.

Glendenning, K. K., & Masterton, R. B. (1998). Comparative morphometry of
mammalian central auditory systems: Variation in nuclei and form of the
ascending system. Brain Behav Evol 51:59-89. doi:10.1159/000006530

The PDF is born-digital (Karger) with a clean text layer. Every cell is taken
from the text layer by word COORDINATES (Table 1 is printed rotated 90 deg, so
rows are page-x positions and columns page-y bands); no value is typed in this
script. Header labels are the printed literals; captions and footnotes are
captured verbatim by anchored regex into reference_tables/<Item>_footnotes.csv.
Structural checks (row counts, every cell filled except the printed blanks,
each rank column a permutation of the 53 animals + Average, alphabetical and
descending r lists identical) run before anything is written, and an existing
frozen snapshot that differs is never overwritten.

Run in conda env "python" (pymupdf, pandas):  python Glendenning_Masterton_1998_extract_snapshot.py
Extraction by an AI assistant 2026-10-28; verified against page renders
(pp. 62, 70-73, 77, 81, 84).
"""
import os, re, sys, csv, io
import pandas as pd, pymupdf

HERE = os.path.dirname(os.path.abspath(__file__))
PDF = os.path.join(HERE, "Glendenning-1998-Comparative Morphometry of Ma.pdf")
P = "Glendenning_Masterton_1998_"
doc = pymupdf.open(PDF)
NUC = ["AVCN", "PVCN", "DCN", "MTB", "LSO", "MSO", "VLL", "DLL", "IC", "MG"]

def words(page):
    W = doc[page - 1].get_text("words")
    d = pd.DataFrame(W, columns=["x0", "y0", "x1", "y1", "w", "b", "l", "n"])
    d["xc"] = (d.x0 + d.x1) / 2; d["yc"] = (d.y0 + d.y1) / 2
    return d

def lines(d, tol=2.0):
    d = d.sort_values(["yc", "x0"]); out, cur, ref = [], [], None
    for _, r in d.iterrows():
        if ref is None or abs(r.yc - ref) <= tol:
            cur.append(r); ref = r.yc if ref is None else ref
        else:
            out.append(pd.DataFrame(cur)); cur, ref = [r], r.yc
    if cur: out.append(pd.DataFrame(cur))
    return out

def text(page): return re.sub(r"\s+", " ", doc[page - 1].get_text())

def grab(page, start, end):
    t = text(page); m = re.search(re.escape(start) + r".*?" + end, t)
    if not m: sys.exit(f"anchor not found p{page}: {start!r}")
    return m.group(0).strip()

# ---------------------------------------------------------------- Table 1 (rotated)
def table1():
    d = words(4); body = d[(d.x0 > 95) & (d.x1 < 520)].copy()
    body["row"] = ((body.xc - 103.45) / 7.798).round().astype(int) + 1
    bands = [("Animal No.", 680, 800), ("Common name", 600, 680), ("Genus and species", 500, 600),
             ("Source", 460, 500), ("Body gm", 425, 460), ("Brain gm", 390, 425),
             ("AVCN", 362, 390), ("PVCN", 332, 362), ("DCN", 303, 332), ("MTB", 275, 303),
             ("LSO", 245, 275), ("MSO", 215, 245), ("VLL", 186, 215), ("DLL", 155, 186),
             ("IC", 125, 155), ("MG", 92, 125), ("Total", 0, 92)]
    recs = []
    for r in range(1, 54):
        s = body[body.row == r].sort_values("y1", ascending=False)
        rec = {b[0]: [] for b in bands}
        for _, w in s.iterrows():
            for nm, lo, hi in bands:
                if lo <= w.yc < hi: rec[nm].append(w.w); break
        rec = {k: " ".join(v) for k, v in rec.items()}
        rec["Animal No."] = re.search(r"(\d+)$", rec["Animal No."]).group(1)   # drop running-head words
        recs.append(rec)
    t = pd.DataFrame(recs)
    assert t["Animal No."].tolist() == [str(i) for i in range(1, 54)]
    blanks = [(a, c) for c in t.columns for a, v in zip(t["Common name"], t[c]) if v == ""]
    assert blanks == [("Chinchilla", "Brain gm"), ("Mink", "Brain gm")], blanks   # printed blanks
    notes = [("caption", grab(4, "Table 1. In vitro volumes", r"\(.total.\)")),
             ("footnote", grab(4, "Body weights in parentheses", r"Indiana University\.")),
             ("abbreviations", grab(4, "AVCN = Anteroventral", r"MG = medial geniculate\."))]
    return t, notes

# ------------------------------------------------- Tables 2, 3 (species rows, numbers)
def numeric(page, hdrs, ymin, ymax, name_xmax):
    d = words(page)
    h = d[d.w.isin(hdrs) & (abs(d.yc - d[d.w == hdrs[0]].yc.min()) < 3)].drop_duplicates("w").set_index("w")
    right = {k: h.loc[k, "x1"] for k in hdrs}
    rows = []
    for L in lines(d[(d.yc > ymin) & (d.yc < ymax)]):
        L = L.sort_values("x0"); nm = L[L.x1 <= name_xmax].w.tolist(); nums = L[L.x1 > name_xmax]
        no = nm.pop(0) if nm and re.fullmatch(r"\d{1,2}", nm[0]) else ""
        rec = {"No.": no, "Animal": " ".join(nm), **{k: "" for k in hdrs}}
        for _, r in nums.iterrows():
            k = min(hdrs, key=lambda k: abs(right[k] - r.x1))
            assert rec[k] == "", (rec["Animal"], k)
            rec[k] = r.w
        rows.append(rec)
    return pd.DataFrame(rows)

def table2():
    t = numeric(12, NUC, 95, 670, 160)
    assert len(t) == 56 and t["No."].tolist()[:53] == [str(i) for i in range(1, 54)]
    assert t.Animal.tolist()[53:] == ["Average", "Standard deviation", "% variation"]
    assert (t[NUC] != "").all().all()
    return t, [("caption", grab(12, "Table 2. Percentage size", r"for each animal")),
               ("footnote", grab(12, "Note that each row sums to 100%", r"100× standard deviation/mean\."))]

def table3():
    H = ["AVCN", "PVCN", "DCN", "CN", "MTB", "LSO", "MSO", "SO", "VLL", "DLL", "IC", "MG"]
    t = numeric(13, H, 95, 675, 160)
    assert len(t) == 53 and (t[H] != "").all().all()
    return t, [("caption", grab(13, "Table 3. Normalized logarithmic", r"table 2")),
               ("footnote", grab(13, "In each column, mean is 0", r"is 0\.137\."))]

# ------------------------------------------------------- Table 4 (rank lists, 2 pages)
def ranklists(page, heads, ystart, stop_word):
    d = words(page); edges = [0, 120, 210, 295, 380, 465, 1e9]
    stop = d[(d.w == stop_word) & (d.yc > 600) & (d.x0 < 560)].yc.min()   # footer / footnote, not the rotated sidebar
    body = d[(d.yc > ystart) & (d.yc < stop - 2) & (d.x0 < 560)]
    cols = {h: [] for h in heads}
    for L in lines(body):
        for i, h in enumerate(heads):
            seg = L[(L.x0 >= edges[i]) & (L.x0 < edges[i + 1])].sort_values("x0")
            cols[h].append(" ".join(seg.w))
    return pd.DataFrame(cols)

def table4(animals):
    A = ranklists(14, ["AVCN", "PVCN", "DCN", "CN (AVCN + PVCN + DCN)", "MTB", "LSO"], 112, "Behav")
    B = ranklists(15, ["MSO", "SO (MTB + LSO + MSO)", "VLL", "DLL", "IC", "MG"], 112, "CN")
    A = A[(A != "").any(axis=1)].reset_index(drop=True); B = B[(B != "").any(axis=1)].reset_index(drop=True)
    assert len(A) == 54 and len(B) == 54, (len(A), len(B))
    t = pd.concat([A, B], axis=1)
    # printed misspellings, kept verbatim in the snapshot; mapped only for this check
    PRINTED_VARIANTS = {"Gropher, pocket": "Gopher, pocket"}   # Table 4A, LSO column (p. 72)
    for c in t.columns:
        names = sorted(PRINTED_VARIANTS.get(re.sub(r"\*+$", "", v), re.sub(r"\*+$", "", v)) for v in t[c])
        assert names == sorted(list(animals) + ["Average"]), (c, set(names) ^ set(list(animals) + ["Average"]))
    notes = [("caption", grab(14, "Table 4. A, B", r"two nuclear clusters")),
             ("footnote", grab(15, "CN = AVCN + PVCN + DCN and SO", r"\*\* = p\s?<\s?0\.01\."))]
    return t, notes

# ------------------------------------------------------------ Tables 5-7 (r lists)
def rtable(page, label, anchor_end):
    d = words(page)
    stop = d[d.w == "Ranks"].yc.min()
    body = d[(d.yc > 92) & (d.yc < stop - 2) & (d.x0 >= 200)]   # caption sits in the left margin
    rows = []
    for L in lines(body):
        g = lambda lo, hi: " ".join(L[(L.x0 >= lo) & (L.x0 < hi)].sort_values("x0").w)
        rows.append({"Alphabetical order": g(200, 312), "r": g(312, 370), "Descending order": g(370, 470),
                     "r ": g(470, 503), "": g(503, 1e9)})
    t = pd.DataFrame(rows)
    assert len(t) == 54 and t["Alphabetical order"].iloc[-1] == "" and (t["Alphabetical order"].iloc[:53] != "").all()
    num = re.compile(r"^[–-]?\d\.\d{3}$")
    assert t["r"].iloc[:53].str.match(num).all() and t["r "].str.match(num).all()
    a = dict(zip(t["Alphabetical order"].iloc[:53].str.replace(r"\s+", " ", regex=True), t["r"].iloc[:53]))
    dsc = dict(zip(t["Descending order"].str.replace(r"\s+", " ", regex=True), t["r "]))
    avg = [k for k in dsc if k.startswith("Average")]; assert len(avg) == 1
    dsc.pop(avg[0]); assert a == dsc, set(a.items()) ^ set(dsc.items())
    notes = [("caption", grab(page, f"Table {label}. Animal rankings based on", anchor_end)),
             ("footnote", grab(page, "Ranks less than", r"reliably different\."))]
    t.columns = ["Alphabetical order", "r", "Descending order", "r", ""]   # headers exactly as printed
    return t, notes

def write(df, path, header=True):
    s = io.StringIO(); df.to_csv(s, index=False, header=header, lineterminator="\n"); out = s.getvalue()
    if os.path.exists(path):
        if open(path, encoding="utf-8").read() != out: sys.exit("REFUSING to overwrite differing " + path)
        return "unchanged"
    open(path, "w", encoding="utf-8").write(out); return "written"

def main():
    t1, n1 = table1()
    animals = t1["Common name"].tolist()
    built = {"Table1": (t1, n1), "Table2": table2(), "Table3": table3(), "Table4": table4(animals),
             "Table5": rtable(19, 5, r"form of system"), "Table6": rtable(23, 6, r"form of cochlear nuclei"),
             "Table7": rtable(26, 7, r"form of superior olives")}
    for k in ["Table2", "Table3"]:
        assert built[k][0].Animal.iloc[:53].tolist() == animals, k
    os.makedirs(os.path.join(HERE, "reference_tables"), exist_ok=True)
    for k, (t, notes) in built.items():
        print(k, t.shape, write(t, os.path.join(HERE, P + k + "_snapshot.csv")),
              write(pd.DataFrame(notes, columns=["element", "text_as_printed"]),
                    os.path.join(HERE, "reference_tables", P + k + "_footnotes.csv")))

if __name__ == "__main__":
    main()
