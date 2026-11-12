#!/usr/bin/env python3
"""Frost_etal_2000_TABLE1_python_mirror.py -- R NOT RUN stand-in.

R was not available in the assistant's environment (2026-11-06, and again on
2026-11-07 when the snapshot was re-taken line by line at the owner's
request), so the files that the two R scripts write were written by this
line-for-line Python mirror of them:

  Frost_etal_2000_TABLE1_extract_snapshot.R -> extract_snapshot()
      writes Frost_etal_2000_TABLE1_snapshot.csv (frozen; a differing frozen
      copy is never overwritten unless --retake is given, which first moves it
      to archive/<item>_snapshot_superseded_<date>.csv)
  Frost_etal_2000_TABLE1.R                  -> build()
      writes Frost_etal_2000_TABLE1.csv and
      __Public/comparative-data/<Item encoded>.tsv

The R scripts are the deliverables. This file is provenance only: once
Alexandra has run the R scripts and they reproduce the files on disk, it can be
deleted. Emulated R behaviour:
  * pdftools::pdf_text  -> poppler `pdftotext -layout` (same physical-layout
    text engine), one string per page; regex character positions = R's
    gregexpr positions (characters, not bytes);
  * write.table(..., qmethod = "double") of a character matrix -> every field
    quoted, embedded quotes doubled, "\\n" line ends, UTF-8;
  * write.csv(na = "NA") / write.table(sep = "\\t", quote = TRUE, na = "") ->
    character columns quoted, numbers unquoted with up to 15 significant
    digits, NA unquoted;
  * mean() and sd() (n - 1) -> statistics.mean / statistics.stdev;
  * sprintf("%.*f") / sprintf("%.3f") -> the same C formats.
--retake is the R script's --retake switch; --extract-only stops after the
extract step (the R extract script run on its own). The optional --checks-out PATH
writes the R session's `table_checks` data frame to PATH for review (the R
script keeps it in memory only, per build HOWTO 7a); never point it into the
paper folder.
"""
import argparse
import csv
import io
import math
import os
import re
import statistics
import subprocess
import sys

import openpyxl

HERE = os.path.dirname(os.path.abspath(__file__))
FOLDER = HERE
PAPER = os.path.basename(FOLDER)                     # Frost_etal_2000
ITEM_NAME = "Frost_etal_2000_TABLE1"
PDF_FILE = os.path.join(FOLDER, "Frost-2000-Somatosensory and motor representat.pdf")

PM_TL = "\u2afe"
PM = "\u00b1"
CAPTION_PRINTED = ("TABLE 1. Area Measurements (in mm\u00b2) and Percentages of Body "
                   "Part Representations Within Somatosensory Cortex^1")
CAPTION_TEXTLAYER = ("TABLE 1. Area Measurements (in mm2) and Percentages of Body "
                     "Part Representations Within Somatosensory Cortex1")
HEADER_PRINTED = ["Case no.", "Tot. SS", "S1", "S2", "Digits", "Vibrissae", "Rostrum",
                  "HL/trunk"]
FOOTNOTE_BODY = " ".join([
    "The three cases shown had the highest resolution, the most definable boundaries and",
    "were considered fairly complete. Percentages of S1 and S2 areas are relative to Tot. SS.",
    "Area measurements of the digits, vibrissae, rostrum, and hindlimb/trunk are taken from",
    "the S1 area only and percentages reflect the proportion of that representation within",
    "S1. For abbreviations, see list. Table was produced by using Canvas 3.5.5."])


def find_root(folder):
    d = folder
    while os.path.dirname(d) != d and not os.path.exists(os.path.join(d, "__ReadMe.xlsx")):
        d = os.path.dirname(d)
    return d


# ---------------------------------------------------------------- R-style I/O
def r_quote(s):
    return '"' + s.replace('"', '""') + '"'


def write_grid(grid, path):
    """write.table(grid, sep = ",", row.names = FALSE, col.names = FALSE, qmethod = "double")."""
    with open(path, "w", encoding="utf-8", newline="") as f:
        for row in grid:
            f.write(",".join(r_quote(x) for x in row) + "\n")


def read_grid(path):
    """read.csv(header = FALSE, colClasses = "character", na.strings = character(0))."""
    with open(path, encoding="utf-8", newline="") as f:
        return [row for row in csv.reader(f)]


def r_num(x):
    """as.character() of a double the way write.table prints it (15 significant digits)."""
    if isinstance(x, int):
        return str(x)
    return "%.15g" % x


def write_df(cols, rows, path, sep, na, escape="double"):
    """write.csv / write.table with row.names = FALSE, quote = TRUE."""
    with open(path, "w", encoding="utf-8", newline="") as f:
        f.write(sep.join(r_quote(c) for c in cols) + "\n")
        for r in rows:
            out = []
            for c in cols:
                v = r[c]
                if v is None:
                    out.append(na)
                elif isinstance(v, str):
                    if escape == "double":
                        out.append(r_quote(v))
                    else:                                # write.table default qmethod "escape"
                        out.append('"' + v.replace('"', '\\"') + '"')
                else:
                    out.append(r_num(v))
            f.write(sep.join(out) + "\n")


# ------------------------------------------------- extract_snapshot.R mirror
def squish(x):
    return re.sub(r"\s+", " ", x).strip()


def pdf_text(pdf):
    out = subprocess.run(["pdftotext", "-layout", "-enc", "UTF-8", pdf, "-"],
                         check=True, capture_output=True).stdout.decode("utf-8")
    pages = out.split("\f")
    return pages[:-1] if pages and pages[-1] == "" else pages


def cells_of(line):
    """gregexpr("[^[:space:]]+( [^[:space:]]+)*", line): cells with 1-based start/end."""
    return [(m.group(0), m.start() + 1, m.end()) for m in re.finditer(r"\S+(?: \S+)*", line)]


def centre(d):
    return [(s + e) / 2 for _, s, e in d]


def extract_snapshot(retake=False):
    import datetime
    import shutil
    if not os.path.exists(PDF_FILE):
        sys.exit("Source PDF not found: " + PDF_FILE)
    pages = pdf_text(PDF_FILE)
    def nows(x):
        return re.sub(r"\s+", "", x)
    pg = [i for i, p in enumerate(pages) if nows(CAPTION_TEXTLAYER) in nows(p)]
    if len(pg) != 1:
        sys.exit("TABLE 1 caption not found on exactly one PDF page.")
    L = pages[pg[0]].split("\n")
    L = [re.sub(r"\s+$", "", x) for x in L]
    L = [re.sub(" *" + PM_TL + " *", " " + PM_TL + " ", x) for x in L]

    i_cap = [i for i, x in enumerate(L) if nows(x) == nows(CAPTION_TEXTLAYER)]
    if len(i_cap) != 1:
        sys.exit("TABLE 1 caption line not found once in the text layer.")
    nxt = [i for i, x in enumerate(L) if squish(x) != "" and i > i_cap[0]]

    H = cells_of(L[nxt[0]])
    if [t for t, _, _ in H] != HEADER_PRINTED:
        sys.exit("Column header line is not as printed: " + L[nxt[0]])
    hc = centre(H)

    def place(line):
        d = cells_of(line)
        col = [min(range(len(hc)), key=lambda j: abs(hc[j] - x)) for x in centre(d)]
        if len(set(col)) != len(col):
            sys.exit("Two text-layer cells fall under one column: " + line)
        out = [""] * len(HEADER_PRINTED)
        for (t, _, _), j in zip(d, col):
            out[j] = t
        return out

    body_lines = nxt[1:9]
    B = [place(L[i]) for i in body_lines]

    NUM = r"[0-9]+\.[0-9]+"
    area_ln = [0, 2, 4]
    ok = {
        "case_numbers": all(re.search(r"^[0-9]{4}$", B[r][0]) for r in area_ln)
                        and len({B[r][0] for r in area_ln}) == 3,
        "case_areas": all(re.search("^" + NUM + "$", B[r][c]) for r in area_ln for c in range(1, 8)),
        "case_pct": all(re.search(r"^\([0-9]+%\)$", B[r + 1][c]) for r in area_ln for c in range(2, 8)),
        "average_label": B[6][0] == "Average",
        "average_areas": all(re.search("^" + NUM + " " + PM_TL + " " + NUM + "$", B[6][c])
                             for c in range(1, 8)),
        "average_pct": all(re.search(r"^\(" + NUM + "%? " + PM_TL + " " + NUM + r"%\)$", B[7][c])
                           for c in range(2, 8)),
        "pct_lines_blank_under_case_and_tot_ss": all(B[r][c] == "" for r in (1, 3, 5, 7)
                                                     for c in (0, 1)),
    }
    if not all(ok.values()):
        sys.exit("TABLE 1 body lines do not have the printed structure (failed: "
                 + ", ".join(k for k, x in ok.items() if not x) + "):\n"
                 + "\n".join(L[i] for i in body_lines))

    f1 = squish(L[nxt[9]])
    if f1 == "1":
        fn = [squish(L[i]) for i in nxt[10:13]]
    elif re.search(r"^1 ?The three cases", f1):
        fn = [squish(L[i]) for i in nxt[9:12]]
        fn[0] = re.sub(r"^1 ?", "", fn[0])
    else:
        sys.exit("Footnote mark '1' not found after the table body: " + f1)
    if " ".join(fn) != FOOTNOTE_BODY:
        sys.exit("TABLE 1 footnote lines do not read as printed:\n" + "\n".join(fn))

    grid = [[""] * 8 for _ in range(13)]
    grid[0][0] = CAPTION_PRINTED
    grid[1] = [t for t, _, _ in H]
    for k in range(8):
        grid[2 + k] = [x.replace(PM_TL, PM) for x in B[k]]
    grid[10][0] = "^1" + fn[0]
    grid[11][0] = fn[1]
    grid[12][0] = fn[2]
    assert len(grid) == 13 and all(len(r) == 8 for r in grid)
    assert not any(PM_TL in x for r in grid for x in r)

    path = os.path.join(FOLDER, ITEM_NAME + "_snapshot.csv")
    alt = re.sub(r"\.csv$", "_NEW.csv", path)
    if not os.path.exists(path):
        write_grid(grid, path)
        print(f"{os.path.basename(path)}: wrote {len(grid)} rows x {len(grid[0])} cols")
        return
    old = read_grid(path)
    if old == grid:
        print(os.path.basename(path) + ": frozen snapshot already on disk and identical; nothing written.")
        return
    if not retake:
        write_grid(grid, alt)
        sys.exit(os.path.basename(path) + ": the frozen snapshot on disk differs from the text-layer "
                 "extraction. Refusing to overwrite; the new extraction is in "
                 + os.path.basename(alt) + ". Reconcile it against the PDF; to replace the frozen "
                 "copy deliberately, re-run with --retake (or RETAKE <- TRUE), which first moves "
                 "the superseded file to archive/.")
    arch = os.path.join(os.path.dirname(path), "archive",
                        re.sub(r"\.csv$", "_superseded_" + datetime.date.today().isoformat() + ".csv",
                               os.path.basename(path)))
    if os.path.exists(arch):
        sys.exit("Archive copy already exists: " + arch)
    os.makedirs(os.path.dirname(arch), exist_ok=True)
    shutil.copyfile(path, arch)                                 # file.rename(): copy, then
    os.remove(path)                                             # remove the original
    write_grid(grid, path)
    if os.path.exists(alt) and read_grid(alt) == grid:
        os.remove(alt)
    print(f"{os.path.basename(path)}: RE-TAKEN -- the superseded frozen copy is now archive/"
          f"{os.path.basename(arch)}; wrote {len(grid)} rows x {len(grid[0])} cols. "
          "Record the re-take in the README.")


# ------------------------------------------------------------- TABLE1.R mirror
def unparen(x):
    if x is None:
        return None
    m = re.match(r"^\((.*)\)$", x, re.S)
    return m.group(1) if m else x


def mean_lexeme(x):
    if x is None:
        return None
    return re.sub(r"\s*" + PM + ".*$", "", x, flags=re.S).strip()


def disp_lexeme(x):
    if x is None or PM not in x:
        return None
    return re.sub(r"^.*" + PM + r"\s*", "", x, flags=re.S).strip()


def num_of(x):
    if x is None:
        return None
    try:
        return float(re.sub(r"[()%]", "", x))
    except ValueError:
        return None


def unit_of(lex):
    if lex is None:
        return None
    s = re.sub(r"[^0-9.]", "", lex)
    if "." in s:
        return 10 ** -len(re.sub(r"^[^.]*\.", "", s))
    return 1


def f3(x):
    return "%.3f" % x


def exact(observed, printed, unit):
    return abs(observed - printed) <= unit / 2 + 1e-9


def at_precision(x, unit):
    """sprintf("%.*f", as.integer(round(-log10(unit))), x)."""
    return "%.*f" % (int(round(-math.log10(unit))), x)


def read_key(path):
    if not os.path.exists(path):
        return None
    with open(path, encoding="utf-8", newline="") as f:
        rows = list(csv.DictReader(f))
    for r in rows:                                   # read.csv na.strings = "NA"
        for k in r:
            if r[k] == "NA":
                r[k] = None
    return [r for r in rows if (r["source_publication"] or "").strip() == PAPER]


def build(checks_out=None):
    root = find_root(FOLDER)
    snap = read_grid(os.path.join(FOLDER, ITEM_NAME + "_snapshot.csv"))
    fn_start = next(i + 1 for i, r in enumerate(snap) if r[0].startswith("^1The three cases shown"))
    body = list(range(3, fn_start))
    area_rows = [r for r in body if snap[r - 1][0] != ""]          # 3, 5, 7, 9
    pct_rows = [r for r in body if snap[r - 1][0] == ""]           # 4, 6, 8, 10
    assert len(snap) == 13 and all(len(r) == 8 for r in snap)
    assert snap[0][0].startswith("TABLE 1. Area Measurements")
    assert snap[1] == HEADER_PRINTED
    assert fn_start == 11 and pct_rows == [r + 1 for r in area_rows]
    assert all(re.match(r"^[0-9]{4}$", snap[r - 1][0]) for r in area_rows[:3])
    assert snap[area_rows[3] - 1][0] == "Average"
    assert all(snap[r - 1][c] == "" for r in pct_rows for c in (0, 1))
    assert all(re.match(r"^\(.*%\)$", snap[r - 1][c]) for r in pct_rows for c in range(2, 8))

    labels = {
        "Tot. SS":   ("Tot_SS", "S1+S2", None),
        "S1":        ("S1", "S1", "Tot. SS"),
        "S2":        ("S2", "S2", "Tot. SS"),
        "Digits":    ("S1_digits", "S1", "S1"),
        "Vibrissae": ("S1_vibrissae", "S1", "S1"),
        "Rostrum":   ("S1_rostrum", "S1", "S1"),
        "HL/trunk":  ("S1_hindlimb_trunk", "S1", "S1"),
    }
    rep_order = [labels[h][0] for h in HEADER_PRINTED[1:]]
    lbl = {labels[h][0]: h for h in HEADER_PRINTED[1:]}
    base_of = {labels[h][0]: (labels[labels[h][2]][0] if labels[h][2] else None)
               for h in HEADER_PRINTED[1:]}

    rows, pct_inner_v = [], []
    case_rows = [r for r in area_rows if snap[r - 1][0] != "Average"]
    n_cases = len({snap[r - 1][0] for r in case_rows})
    for srow in area_rows:                            # expand.grid: column varies fastest
        for scol in range(2, 9):
            case_no = snap[srow - 1][0]
            is_avg = case_no == "Average"
            col = snap[1][scol - 1]
            rep, field, pbase = labels[col]
            a_pr = snap[srow - 1][scol - 1]           # the area line
            p_pr = snap[srow][scol - 1] or None       # the percentage line beneath it
            p_in = unparen(p_pr)
            pct_inner_v.append(p_in)
            rows.append({
                "snapshot_row": srow, "snapshot_col": scol,
                "case_no_as_printed": case_no,
                "case_id": None if is_avg else case_no,
                "statistic": "mean of cases" if is_avg else "individual case",
                "n_cases": n_cases if is_avg else 1,
                "column_as_printed": col, "representation": rep,
                "cortical_field": field, "percentage_base": pbase,
                "cell_as_printed": a_pr if p_pr is None else a_pr + " " + p_pr,
                "area_printed": a_pr, "percentage_printed": p_pr,
                "area_mm2": num_of(mean_lexeme(a_pr)),
                "area_sd_mm2": num_of(disp_lexeme(a_pr)),
                "percentage": num_of(mean_lexeme(p_in)),
                "percentage_sd": num_of(disp_lexeme(p_in)),
                "dispersion_type": None,
                "species_as_published": "Monodelphis domestica",
                "species": None, "data_role": "primary", "note": None,
                # helper (the R `lx` data frame), dropped before writing
                "_uA": unit_of(mean_lexeme(a_pr)), "_uAsd": unit_of(disp_lexeme(a_pr)),
                "_uP": unit_of(mean_lexeme(p_in)), "_uPsd": unit_of(disp_lexeme(p_in)),
            })
    assert len(rows) == 28 and all(r["area_mm2"] is not None for r in rows)
    assert sum(r["percentage"] is None for r in rows) == 4

    # species
    key = read_key(os.path.join(root, "_keys", "General", "species_key.csv"))
    if not key:
        prop = os.path.join(FOLDER, "reference_tables", PAPER + "_species_key_proposed.csv")
        key = read_key(prop)
        print(f"{ITEM_NAME}: no '{PAPER}' rows in _keys/General/species_key.csv yet; species "
              f"resolved from reference_tables/{PAPER}_species_key_proposed.csv (adopt those rows).")
    if not key:
        sys.exit("No species key rows for " + PAPER)
    lk = {}
    for k in key:
        lk.setdefault((k["variant_name"] or "").strip().lower(), k["accepted_name"])
    for r in rows:
        r["species"] = lk.get(r["species_as_published"].strip().lower())
    assert all(r["species"] for r in rows)

    CASE, AVG = "individual case", "mean of cases"

    def v(col, rep, stat):
        return [r[col] for r in rows if r["representation"] == rep and r["statistic"] == stat]

    def u(col, rep, stat):
        return [r["_" + col] for r in rows if r["representation"] == rep and r["statistic"] == stat]

    case_ids = []
    for r in rows:
        if r["statistic"] == CASE and r["case_no_as_printed"] not in case_ids:
            case_ids.append(r["case_no_as_printed"])
    sd_factor = math.sqrt(n_cases / (n_cases - 1))

    checks = []

    def chk(ids, bases, observed, printed, tol, notes=None):
        n = len(ids)
        printed = printed if isinstance(printed, list) else [printed] * n
        tol = tol if isinstance(tol, list) else [tol] * n
        notes = notes if isinstance(notes, list) else [notes] * n
        for i in range(n):
            o, p, t = observed[i], printed[i], tol[i]
            ok = o is not None and p is not None
            st = "not_evaluable" if not ok else ("pass" if abs(o - p) <= t + 1e-9 else "mismatch")
            checks.append({"check_id": ids[i], "basis": bases[i], "observed": o, "printed": p,
                           "difference": (o - p) if ok else None, "tolerance": t,
                           "status": st, "note": notes[i]})

    def exact_note(o, p, unit):
        return "exact at printed precision: " + ("yes" if exact(o, p, unit) else "no")

    ids_c = case_ids + ["Average"]
    # (1) Tot. SS = S1 + S2
    obs = ([a + b for a, b in zip(v("area_mm2", "S1", CASE), v("area_mm2", "S2", CASE))]
           + [v("area_mm2", "S1", AVG)[0] + v("area_mm2", "S2", AVG)[0]])
    tol = ([a / 2 + b / 2 for a, b in zip(u("uA", "S1", CASE), u("uA", "S2", CASE))]
           + [u("uA", "S1", AVG)[0] / 2 + u("uA", "S2", AVG)[0] / 2])
    chk(["tot_ss_eq_s1_plus_s2_" + c for c in ids_c],
        ["Tot. SS = S1 + S2 (areas) [" + c + "]" for c in ids_c],
        obs, v("area_mm2", "Tot_SS", CASE) + v("area_mm2", "Tot_SS", AVG), tol)

    # (2) percentage = 100 x area / base
    pct_reps = [r for r in rep_order if base_of[r] is not None]
    for rp in pct_reps:
        b = base_of[rp]
        o = [100 * x / y for x, y in zip(v("area_mm2", rp, CASE), v("area_mm2", b, CASE))]
        pr = v("percentage", rp, CASE)
        un = u("uP", rp, CASE)
        lex = [mean_lexeme(pct_inner_v[i]) for i, r in enumerate(rows)
               if r["representation"] == rp and r["statistic"] == CASE]
        chk(["pct_" + rp + "_" + c for c in case_ids],
            [f"{lbl[rp]} % = 100 x {lbl[rp]} / {lbl[b]} (areas) [{c}]" for c in case_ids],
            o, pr, un, [exact_note(o[i], pr[i], un[i]) + " (recomputed " + f3(o[i])
                        + "% rounds to " + at_precision(o[i], un[i]) + "%; printed " + lex[i] + ")"
                        for i in range(len(o))])

    # (3) S1 % + S2 % = 100
    obs = ([a + b for a, b in zip(v("percentage", "S1", CASE), v("percentage", "S2", CASE))]
           + [v("percentage", "S1", AVG)[0] + v("percentage", "S2", AVG)[0]])
    tol = ([a / 2 + b / 2 for a, b in zip(u("uP", "S1", CASE), u("uP", "S2", CASE))]
           + [u("uP", "S1", AVG)[0] / 2 + u("uP", "S2", AVG)[0] / 2])
    chk(["pct_s1_plus_s2_eq_100_" + c for c in ids_c],
        ["S1 % + S2 % = 100 [" + c + "]" for c in ids_c], obs, 100.0, tol)

    # (4) body-part percentages within each case: summed and recorded, not tested
    bp_reps = [r for r in pct_reps if base_of[r] == "S1"]
    for i, c in enumerate(case_ids):
        p = [v("percentage", r, CASE)[i] for r in bp_reps]
        q = [100 * v("area_mm2", r, CASE)[i] / v("area_mm2", "S1", CASE)[i] for r in bp_reps]
        up = [u("uP", r, CASE)[i] for r in bp_reps]
        nv = [r != "S1_vibrissae" for r in bp_reps]
        sp = sum(p)
        checks.append({
            "check_id": "pct_body_parts_sum_" + c,
            "basis": " + ".join(lbl[r] + " %" for r in bp_reps) + " summed [" + c + "]",
            "observed": sp, "printed": 100.0, "difference": sp - 100.0,
            "tolerance": sum(up) / 2, "status": "not_evaluable",
            "note": ("No total of 100 to test: the Vibrissae area lies within the Rostrum area "
                     "(Results p. 33) and the four parts need not cover S1. Printed percentages "
                     "sum to " + r_num(sp) + "%; from 100 x area / S1 " + f3(sum(q))
                     + "%; without Vibrissae " + r_num(sum(x for x, k in zip(p, nv) if k))
                     + "% (" + f3(sum(x for x, k in zip(q, nv) if k))
                     + "% from areas). Kept as printed.")})

    # (5a) areas: mean and SD
    for rp in rep_order:
        x = v("area_mm2", rp, CASE)
        ux = max(u("uA", rp, CASE))
        m = v("area_mm2", rp, AVG)[0]
        s = v("area_sd_mm2", rp, AVG)[0]
        um, us = u("uA", rp, AVG)[0], u("uAsd", rp, AVG)[0]
        chk(["mean_area_" + rp], [f"Average {lbl[rp]} area = mean of the {n_cases} cases"],
            [statistics.mean(x)], m, ux / 2 + um / 2, exact_note(statistics.mean(x), m, um))
        chk(["sd_area_" + rp],
            [f"Average {lbl[rp]} area dispersion = sample SD (n - 1) of the {n_cases} cases"],
            [statistics.stdev(x)], s, sd_factor * ux / 2 + us / 2,
            exact_note(statistics.stdev(x), s, us))

    # (5b) percentages: mean and SD, with the area-ratio basis in the note
    for rp in pct_reps:
        p = v("percentage", rp, CASE)
        up = max(u("uP", rp, CASE))
        q = [100 * x / y for x, y in zip(v("area_mm2", rp, CASE), v("area_mm2", base_of[rp], CASE))]
        m = v("percentage", rp, AVG)[0]
        s = v("percentage_sd", rp, AVG)[0]
        um, us = u("uP", rp, AVG)[0], u("uPsd", rp, AVG)[0]

        def alt(stat, printed, unit):
            return (f"; from 100 x area / {lbl[base_of[rp]]}: {f3(stat)} (exact: "
                    + ("yes" if exact(stat, printed, unit) else "no") + ")")
        chk(["mean_pct_" + rp],
            [f"Average {lbl[rp]} % = mean of the {n_cases} printed case percentages"],
            [statistics.mean(p)], m, up / 2 + um / 2,
            exact_note(statistics.mean(p), m, um) + alt(statistics.mean(q), m, um))
        chk(["sd_pct_" + rp],
            [f"Average {lbl[rp]} % dispersion = sample SD (n - 1) of the {n_cases} printed case percentages"],
            [statistics.stdev(p)], s, sd_factor * up / 2 + us / 2,
            exact_note(statistics.stdev(p), s, us) + alt(statistics.stdev(q), s, us))

    tally = {k: sum(c["status"] == k for c in checks) for k in ("pass", "mismatch", "not_evaluable")}
    print(f"{ITEM_NAME}: table checks  pass={tally['pass']}  mismatch={tally['mismatch']}  "
          f"not_evaluable={tally['not_evaluable']}  (of {len(checks)})")
    for c in checks:
        if c["status"] == "mismatch":
            print("WARNING:", c["check_id"], c["basis"], c["observed"], c["printed"])

    # per-row notes
    def add_note(idx, txt):
        for i in idx:
            rows[i]["note"] = txt if rows[i]["note"] is None else rows[i]["note"] + " | " + txt

    avg_rows = [i for i, r in enumerate(rows) if r["statistic"] == AVG]
    sd_all_pass = all(c["status"] == "pass" for c in checks if c["check_id"].startswith("sd_"))
    for i in avg_rows:
        rows[i]["dispersion_type"] = "SD" if sd_all_pass else "not stated"
    add_note(avg_rows, "Average row: printed mean " + PM + " dispersion of the " + str(n_cases)
             + " cases. The print does not say SD or SEM; "
             + ("every printed dispersion reproduces as the sample SD (n - 1) of the case rows "
                "within rounding (table_checks)." if sd_all_pass else
                "not every printed dispersion reproduces as the sample SD of the case rows "
                "(see table_checks)."))
    status_of = {c["check_id"]: c["status"] for c in checks}
    for rp in pct_reps:
        p = v("percentage", rp, CASE)
        q = [100 * x / y for x, y in zip(v("area_mm2", rp, CASE), v("area_mm2", base_of[rp], CASE))]
        row = [i for i, r in enumerate(rows) if r["representation"] == rp and r["statistic"] == AVG]
        for what in ("mean", "SD"):
            fun = statistics.mean if what == "mean" else statistics.stdev
            printed = rows[row[0]]["percentage"] if what == "mean" else rows[row[0]]["percentage_sd"]
            lexeme = (mean_lexeme(pct_inner_v[row[0]]) if what == "mean"
                      else disp_lexeme(pct_inner_v[row[0]]))
            unit = rows[row[0]]["_uP"] if what == "mean" else rows[row[0]]["_uPsd"]
            st = status_of[("mean_pct_" if what == "mean" else "sd_pct_") + rp]
            if not exact(fun(p), printed, unit):
                add_note(row, "Printed percentage " + what + " " + lexeme
                         + " is not reproduced from the printed case percentages ("
                         + ", ".join(r_num(x) for x in p) + " give " + f3(fun(p)) + ") "
                         + ("but is reproduced" if exact(fun(q), printed, unit) else "nor")
                         + " from 100 x area / " + lbl[base_of[rp]] + " ("
                         + ", ".join(f3(x) for x in q) + " give " + f3(fun(q)) + "); "
                         + ("within the rounding tolerance of the printed cells (table_checks: pass)"
                            if st == "pass" else "table_checks: " + st)
                         + "; kept as printed.")
    stray = [i for i, r in enumerate(rows)
             if r["statistic"] == AVG and pct_inner_v[i] is not None
             and "%" in mean_lexeme(pct_inner_v[i])]
    add_note(stray, "Percentage cell typeset with a '%' after the mean as well as after the "
             "dispersion, unlike the other Average percentage cells; kept as printed.")
    overlap = [i for i, r in enumerate(rows) if r["representation"] in ("S1_vibrissae", "S1_rostrum")]
    add_note(overlap, "Not additive with the other S1 body-part columns: the Results (p. 33) "
             "define the rostrum as the glabrous snout, mystacial vibrissae, lower jaw, lips and "
             "oral cavity, so the Vibrissae area lies within the Rostrum area.")

    cols = ["snapshot_row", "snapshot_col", "case_no_as_printed", "case_id", "statistic",
            "n_cases", "column_as_printed", "representation", "cortical_field",
            "percentage_base", "cell_as_printed", "area_printed", "percentage_printed",
            "area_mm2", "area_sd_mm2", "percentage", "percentage_sd", "dispersion_type",
            "species_as_published", "species", "data_role", "note"]
    write_df(cols, rows, os.path.join(FOLDER, ITEM_NAME + ".csv"), ",", "NA", "double")
    print(f"{ITEM_NAME}: {len(rows)} rows x {len(cols)} cols written to {ITEM_NAME}.csv")

    reg = os.path.join(root, "__ReadMe.xlsx")
    if os.path.exists(reg):
        wb = openpyxl.load_workbook(reg, data_only=True, read_only=True)
        ws = wb["Sheet1"]
        it = ws.iter_rows(values_only=True)
        hdr = list(next(it))
        i_name, i_enc = hdr.index("Item name"), hdr.index("Item encoded")
        item_encoded = None
        for r in it:
            if r[i_name] == ITEM_NAME:
                item_encoded = r[i_enc]
                break
        if not item_encoded or item_encoded.endswith("_"):
            sys.exit("No usable 'Item encoded' in __ReadMe.xlsx for " + ITEM_NAME)
        tsv_dir = os.path.join(root, "__Public", "comparative-data")
        if os.path.isdir(tsv_dir):
            write_df(cols, rows, os.path.join(tsv_dir, item_encoded + ".tsv"), "\t", "", "escape")
            print(f"{ITEM_NAME}: public TSV {item_encoded}.tsv")
        else:
            print("WARNING: __Public/comparative-data not found; public TSV not written.")
    else:
        print("WARNING: __ReadMe.xlsx not found; public TSV not written.")

    if checks_out:
        ccols = ["check_id", "basis", "observed", "printed", "difference", "tolerance", "status", "note"]
        write_df(ccols, checks, checks_out, ",", "NA", "double")
    return rows, checks


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--checks-out", default=None)
    ap.add_argument("--retake", action="store_true")
    ap.add_argument("--extract-only", action="store_true")
    a = ap.parse_args()
    extract_snapshot(a.retake)
    if not a.extract_only:
        build(a.checks_out)
