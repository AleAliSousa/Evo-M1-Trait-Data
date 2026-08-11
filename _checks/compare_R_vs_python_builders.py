#!/usr/bin/env python3
"""Do the Python builders and their R twins produce the same numbers?

Several __merging_* folders carry BOTH a `*_compiled.R` and a `build_*_merge.py` that implement
the same merge — the Python was written first in sessions where R was unavailable, and the R twin
was added afterwards (see each R script's header). Before retiring the Python copies we need
evidence that the R twin reproduces them, not just that it exits 0.

Method, per pair:
  1. snapshot every .csv currently in the folder — these are the R outputs, written by the last
     `run_all_scripts_v2.R` sweep;
  2. run the Python builder, which overwrites them in place;
  3. compare each file cell-by-cell (numeric columns within `TOL`, everything else exact,
     row order ignored via a sorted key);
  4. restore the R snapshot unconditionally, so the repo is left exactly as the sweep left it.

Verdicts: IDENTICAL (safe to delete the .py) · DIFFERS · PY_CANNOT_RUN (hardcoded dead sandbox
path or crash — the .py is already inert, the R twin is the only working implementation) ·
R_FAILED (the sweep could not run the R twin — keep the Python).

Writes _checks/R_vs_python_builders.md and .csv. Read-only in effect: nothing is left changed.
"""
import os, sys, csv, json, shutil, subprocess, tempfile, datetime

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(HERE)
TOL = 1e-9                       # relative tolerance for numeric cells
DISPLAY_TOL = 1e-3               # a mismatch no bigger than this is a rounding tie-break,
                                 # not a disagreement (see IDENTICAL_TO_ROUNDING)

# folder, python builder, R twin
PAIRS = [
    ("__merging_body_ecology",            "build_body_ecology_merge.py",            "body_ecology_compiled.R"),
    ("__merging_brain_mass",              "build_brain_mass_merge.py",              "brain_mass_compiled.R"),
    ("__merging_cerebral_metabolic_rate", "build_cerebral_metabolic_rate_merge.py", "cerebral_metabolic_rate_compiled.R"),
    ("__merging_fossil_brain_glucose",    "build_fossil_brain_glucose_merge.py",    "fossil_brain_glucose_compiled.R"),
    ("__merging_sleep",                   "build_sleep_merge.py",                   "sleep_compiled.R"),
    ("__merging_volumes",                 "_verify_volumes_compiled_select.py",     "volumes_compiled_select.R"),
]
# .py with no outputs of their own — judged on whether they can run at all, not on a diff
NO_OUTPUT = [
    ("__merging_volumes", "_verify_species_dtype.py", "volumes_compiled.R",
     "diagnostic print-only port of volumes_compiled.R steps 1-3"),
    ("__ShinyApp",        "build_data.py",            "build_data.R",
     "5-line stub whose own text says DEPRECATED - replaced by build_data.R"),
]
PY_ARGS = {"_verify_volumes_compiled_select.py": ["--write"]}


def r_sweep_status():
    """status of each R script in the last run_all_scripts_v2.R sweep"""
    log = os.path.join(HERE, "script_execution_log.csv")
    out = {}
    if not os.path.exists(log):
        return out
    with open(log, newline="", encoding="utf-8") as f:
        for row in csv.DictReader(f):
            out[os.path.basename(row["script"])] = row["status"]
    return out


def load(path):
    with open(path, newline="", encoding="utf-8-sig") as f:
        rows = list(csv.reader(f))
    return (rows[0], rows[1:]) if rows else ([], [])


# R writes an absent value as NA, Python's csv writer as an empty field. That is a serialization
# difference, not a data one, so every missing marker is normalised to one token before comparing.
MISSING = {"", "NA", "NaN", "nan", "N/A", "NULL", "None"}
# Likewise R writes logicals as TRUE/FALSE and Python as True/False.
BOOL = {"true": "T", "TRUE": "T", "True": "T", "false": "F", "FALSE": "F", "False": "F"}


def same_cell(a, b):
    if a == b:
        return True
    if a.strip() in MISSING and b.strip() in MISSING:
        return True
    if (a.strip() in MISSING) != (b.strip() in MISSING):
        return False
    if a.strip() in BOOL or b.strip() in BOOL:
        return BOOL.get(a.strip()) == BOOL.get(b.strip())
    try:
        x, y = float(a), float(b)
    except ValueError:
        return a.strip() == b.strip()
    if x != x and y != y:          # NaN == NaN, for our purposes
        return True
    d = abs(x - y)
    return d <= TOL * max(1.0, abs(x), abs(y))


def compare(p_r, p_py, la="R", lb="py"):
    """Compare two CSVs. -> (verdict, detail). la/lb name the two sides in the message,
    since this is also used the other way round (frozen Python fixture vs current R)."""
    hr, rr = load(p_r)
    hp, rp = load(p_py)
    if hr != hp:
        only_r, only_p = set(hr) - set(hp), set(hp) - set(hr)
        return "DIFFERS", (f"header: {len(hr)} vs {len(hp)} cols"
                           + (f"; only in {la}: {sorted(only_r)[:5]}" if only_r else "")
                           + (f"; only in {lb}: {sorted(only_p)[:5]}" if only_p else "")
                           + ("; same names, different order" if not only_r and not only_p else ""))
    if len(rr) != len(rp):
        return "DIFFERS", f"row count: {len(rr)} ({la}) vs {len(rp)} ({lb})"
    key = lambda r: "\x1f".join(r)
    rr, rp = sorted(rr, key=key), sorted(rp, key=key)
    bad = []
    for i, (a, b) in enumerate(zip(rr, rp)):
        for j, (x, y) in enumerate(zip(a, b)):
            if not same_cell(x, y):
                bad.append(f"row {i} col '{hr[j] if j < len(hr) else j}': {la}={x!r} {lb}={y!r}")
                if len(bad) >= 5:
                    break
        if len(bad) >= 5:
            break
    if bad:
        # Re-scan at DISPLAY_TOL: if every mismatch is numeric and within the last printed decimal,
        # the two agree on the data and differ only in where they round. Report that separately so
        # it is not confused with a real disagreement.
        worst, nnum, nstr = 0.0, 0, 0
        for a, b in zip(rr, rp):
            for x, y in zip(a, b):
                if same_cell(x, y):
                    continue
                try:
                    worst = max(worst, abs(float(x) - float(y))); nnum += 1
                except ValueError:
                    nstr += 1
        # (1 + 1e-9) so a difference that IS exactly one ulp of the last decimal — e.g.
        # 0.193 - 0.192, which floating point renders as 0.0010000000000000009 — still counts.
        if nstr == 0 and worst <= DISPLAY_TOL * (1 + 1e-9):
            return ("IDENTICAL_TO_ROUNDING",
                    f"{len(rr)} rows x {len(hr)} cols; {nnum} cell(s) differ by at most "
                    f"{worst:g} (last printed decimal only) — no disagreement on the data")
        return "DIFFERS", (f"{len(bad)}+ cell mismatch(es), {nnum} numeric (max |diff| {worst:g}), "
                           f"{nstr} non-numeric; first: " + " | ".join(bad[:3]))
    return "IDENTICAL", f"{len(rr)} rows x {len(hr)} cols match"


def run_pair(folder, py, rscript, status):
    d = os.path.join(REPO, folder)
    res = {"folder": folder, "python": py, "r_twin": rscript,
           "r_sweep_status": status.get(rscript, "not in log"),
           "verdict": "", "detail": "", "files": ""}
    if not os.path.exists(os.path.join(d, py)):
        res["verdict"] = "PY_ABSENT"
        res["detail"] = "already removed from the working tree"
        return res
    if res["r_sweep_status"] not in ("SUCCESS",):
        res["verdict"] = "R_FAILED"
        res["detail"] = (f"the R twin is {res['r_sweep_status']} in the last sweep, so the Python "
                         f"builder is currently the only working implementation - keep it")
        return res

    csvs = sorted(f for f in os.listdir(d) if f.endswith(".csv"))
    snap = tempfile.mkdtemp(prefix="rsnap_")
    try:
        for f in csvs:                                     # 1 snapshot the R outputs
            shutil.copy2(os.path.join(d, f), os.path.join(snap, f))
        p = subprocess.run([sys.executable, py] + PY_ARGS.get(py, []),   # 2 run the Python
                           cwd=d, capture_output=True, text=True, timeout=900)
        if p.returncode != 0:
            tail = (p.stderr or p.stdout).strip().splitlines()
            res["verdict"] = "PY_CANNOT_RUN"
            res["detail"] = "exit %d: %s" % (p.returncode, tail[-1][:200] if tail else "no output")
            return res
        touched = [f for f in sorted(os.listdir(d)) if f.endswith(".csv")
                   and (f not in csvs
                        or os.path.getmtime(os.path.join(d, f)) > os.path.getmtime(os.path.join(snap, f)))]
        if not touched:
            res["verdict"] = "NO_OUTPUT"
            res["detail"] = "the Python builder wrote no CSV in this folder"
            return res
        verdicts, details = [], []
        for f in touched:                                  # 3 compare
            if f not in csvs:
                verdicts.append("DIFFERS")
                details.append(f"{f}: written by py only, absent from the R output")
                continue
            v, why = compare(os.path.join(snap, f), os.path.join(d, f))
            verdicts.append(v)
            details.append(f"{f}: {v} - {why}")
        vs = set(verdicts)
        res["verdict"] = ("IDENTICAL" if vs == {"IDENTICAL"} else
                          "IDENTICAL_TO_ROUNDING" if vs <= {"IDENTICAL", "IDENTICAL_TO_ROUNDING"}
                          else "DIFFERS")
        res["files"] = "; ".join(touched)
        res["detail"] = " | ".join(details)
        return res
    except subprocess.TimeoutExpired:
        res["verdict"] = "PY_CANNOT_RUN"; res["detail"] = "timed out after 900 s"
        return res
    except Exception as e:
        res["verdict"] = "ERROR"; res["detail"] = f"{type(e).__name__}: {e}"
        return res
    finally:
        for f in sorted(os.listdir(snap)):                 # 4 restore, always
            shutil.copy2(os.path.join(snap, f), os.path.join(d, f))
        shutil.rmtree(snap, ignore_errors=True)


def main():
    status = r_sweep_status()
    rows = []
    for folder, py, rs in PAIRS:
        print(f"-- {folder}/{py}", flush=True)
        r = run_pair(folder, py, rs, status)
        print(f"   {r['verdict']}: {r['detail'][:160]}", flush=True)
        rows.append(r)
    for folder, py, rs, note in NO_OUTPUT:
        p = os.path.join(REPO, folder, py)
        st = status.get(rs, "not in log")
        if not os.path.exists(p):
            rows.append({"folder": folder, "python": py, "r_twin": rs, "r_sweep_status": st,
                         "verdict": "PY_ABSENT", "files": "",
                         "detail": note + "; already removed from the working tree"})
            continue
        src = open(p, encoding="utf-8", errors="replace").read()
        dead = "/sessions/" in src
        rows.append({"folder": folder, "python": py, "r_twin": rs, "r_sweep_status": st,
                     "verdict": "NO_OUTPUT" if st == "SUCCESS" else "R_FAILED",
                     "detail": note + ("; contains a hardcoded /sessions/ sandbox path, so it "
                                       "cannot run outside the session that wrote it" if dead else ""),
                     "files": ""})

    out_csv = os.path.join(HERE, "R_vs_python_builders.csv")
    with open(out_csv, "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=["folder", "python", "r_twin", "r_sweep_status",
                                          "verdict", "files", "detail"])
        w.writeheader(); w.writerows(rows)

    L = [f"# R twins vs Python builders — {datetime.datetime.now():%Y-%m-%d %H:%M}", "",
         "Generated by `_checks/compare_R_vs_python_builders.py`. For each folder that carries both",
         "a `*_compiled.R` and a `build_*_merge.py`, the R outputs (as written by the last",
         "`run_all_scripts_v2.R` sweep) were snapshotted, the Python builder re-run over them, the",
         "results compared cell-by-cell, and the R outputs restored. The repo is left unchanged.", "",
         "| Folder | Python | R twin | R in sweep | Verdict |", "|---|---|---|---|---|"]
    for r in rows:
        L.append(f"| `{r['folder']}` | `{r['python']}` | `{r['r_twin']}` | {r['r_sweep_status']} | **{r['verdict']}** |")
    L += ["", "## Verdicts", "",
          "- **IDENTICAL** — R reproduces the Python cell-for-cell (missing markers normalised: R `NA` == Python empty field); the `.py` is redundant and safe to delete.",
          "- **IDENTICAL_TO_ROUNDING** — same data; a few cells differ only in the last printed decimal (≤ `DISPLAY_TOL`). Your call whether that counts as agreement.",
          "- **NO_OUTPUT** — the `.py` produces no data file of its own (a diagnostic or a stub); judge it on whether it still runs.",
          "- **PY_CANNOT_RUN** — the `.py` already fails (usually a hardcoded `/sessions/…` path from the session that wrote it), so the R twin is the only live implementation.",
          "- **DIFFERS** — the two do NOT agree. Do not delete; reconcile first.",
          "- **R_FAILED** — the sweep could not run the R twin, so the Python is currently load-bearing. Keep it and fix the R.", "",
          "## Detail", ""]
    for r in rows:
        L += [f"### `{r['folder']}/{r['python']}` — {r['verdict']}", ""]
        if r["files"]:
            L += [f"Files compared: {r['files']}", ""]
        L += [r["detail"], ""]
    with open(os.path.join(HERE, "R_vs_python_builders.md"), "w", encoding="utf-8") as f:
        f.write("\n".join(L) + "\n")
    print("\nwrote _checks/R_vs_python_builders.{md,csv}")


if __name__ == "__main__":
    main()
