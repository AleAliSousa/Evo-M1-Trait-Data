#!/usr/bin/env python3
"""Is every doubled brain-volume value marked, and marked as provenance rather than as a veto?

Two different things can make a "both-hemisphere" volume out of one measured side, and the merge has
to keep them apart:

  doubling = none       the source printed one side AS MEASURED; the x2 (if any) is done by THIS
                        project in step 7 of the merge  -> flag `estimated_bilateral_from_unilateral`
  doubling = by_source  the source PUBLISHED 2x one side, with the authors' own symmetry argument
                        (de Sousa 2010 V1/LGN; de Sousa 2013 LGN)
                                                         -> flag `published_bilateral_estimate`

Both are PROVENANCE: they record how a both-sides number came to exist and never remove a value.
Only an `action = skip` row in volumes_select_value_flags.csv drops anything. This script exists
because that distinction is easy to lose.

What it checks
  1. laterality_known.csv parses, and every `doubling` is one of {none, by_source}.
  2. Every registered column resolves to a standardized term.
  3. doubling = none      -> the term CARRIES its required laterality suffix
     doubling = by_source -> the term carries NO laterality suffix (it stands for both sides).
  4. No author-doubled stem is in the merge's bilateral-doubling set, i.e. nothing gets doubled twice.
  5. Predicts the exact `published_bilateral_estimate` rows the R merge should emit (from the last
     written volumes_unfiltered.csv / volumes_resolution_audit_select.csv) and, once the R scripts
     have been re-run, diffs that prediction against the actual volumes_flags*.csv.
  6. No author-doubled term appears as a `skip` in volumes_select_value_flags.csv -- doubling must
     never be treated as grounds for omission.

Run:  python3 _checks/check_laterality_doubling.py
Exit: 0 = all checks pass (pending checks are not failures), 1 = at least one FAIL.
"""
import csv, os, re, sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(HERE)
MV   = os.path.join(REPO, "__merging_volumes")
SUFFIX = re.compile(r"_(unilateral|left|right)_Vol\.mm3$")
VALID  = {"none", "by_source"}

fails, pending = [], []


def rd(path):
    if not os.path.exists(path):
        return None
    with open(path, newline="", encoding="utf-8-sig") as fh:
        return list(csv.DictReader(fh))


def report(ok, label, detail=""):
    print(f"  [{'PASS' if ok else 'FAIL'}] {label}{(' -- ' + detail) if detail else ''}")
    if not ok:
        fails.append(label)


print(__doc__.splitlines()[0])
print()

# ---------------------------------------------------------------- 1-3 registry vs term map
lat = rd(os.path.join(MV, "laterality_known.csv"))
terms = rd(os.path.join(MV, "standardized_term_volumes.csv"))
if lat is None or terms is None:
    sys.exit("laterality_known.csv or standardized_term_volumes.csv not found -- run from the repo.")

for r in lat:
    r["doubling"] = (r.get("doubling") or "none").strip() or "none"
tmap = {(t["Reference"], t["Original_Term"]): t["Standardized_Term"] for t in terms}

print("Registry")
bad_vals = sorted({r["doubling"] for r in lat} - VALID)
report(not bad_vals, "every `doubling` is none|by_source", ", ".join(bad_vals))

unmapped = [r for r in lat if (r["Reference"], r["Original_Term"]) not in tmap]
report(not unmapped, "every registered column has a standardized term",
       "; ".join(f"{r['Reference']}:{r['Original_Term']}" for r in unmapped))

one_side, by_source = [], []
for r in lat:
    st = tmap.get((r["Reference"], r["Original_Term"]))
    if st is None:
        continue
    (one_side if r["doubling"] == "none" else by_source).append((r, st))

# Anchored, matching the R guard: the suffix must sit immediately before _Vol.mm3.
miss = [(r, st) for r, st in one_side
        if not (r["required_suffix"] and st.endswith(r["required_suffix"] + "_Vol.mm3"))]
report(not miss, f"doubling=none ({len(one_side)}) carry their laterality suffix (anchored)",
       "; ".join(f"{r['Original_Term']} -> {st}" for r, st in miss))

wrong = [(r, st) for r, st in by_source if SUFFIX.search(st)]
report(not wrong, f"doubling=by_source ({len(by_source)}) carry NO laterality suffix",
       "; ".join(f"{r['Original_Term']} -> {st}" for r, st in wrong))

doubled = {(r["Reference"], st) for r, st in by_source}
doubled_terms = {st for _, st in doubled}
print("    author-doubled terms: " + ", ".join(sorted(doubled_terms)))

# ---------------------------------------------------------------- 4 never doubled twice
# Each merge script decides which stems get a both-sides partner built. An author-doubled stem must
# not be in that set, or the merge would double an already-doubled figure. The three scripts express
# this differently, so check each on its own terms.
print("\nNo value is doubled twice")
stems = {SUFFIX.sub("", t).removesuffix("_Vol.mm3") for t in doubled_terms}


def strip_r_comments(text):
    """Drop `#` comments, but not a `#` inside a string literal."""
    out, i, n, in_str, quote, esc = [], 0, len(text), False, "", False
    while i < n:
        ch = text[i]
        if in_str:
            out.append(ch)
            if esc:
                esc = False
            elif ch == "\\":
                esc = True
            elif ch == quote:
                in_str = False
        elif ch in "\"'":
            in_str, quote = True, ch
            out.append(ch)
        elif ch == "#":
            while i < n and text[i] != "\n":     # swallow to end of line
                i += 1
            out.append("\n")
        else:
            out.append(ch)
        i += 1
    return "".join(out)


def rlist(text, name):
    """String literals from a `name <- c( ... )` assignment.

    Scans to the BALANCED closing paren rather than the first `)` — a `)` inside a trailing
    comment (`# cranial motor nuclei (Sherwood 2005):`) truncated an earlier regex version and made
    this check silently pass on a partial list.
    """
    m = re.search(re.escape(name) + r"\s*<-\s*c\(", text)
    if not m:
        return None
    i, depth = m.end(), 1
    while i < len(text) and depth:
        if text[i] == "(":
            depth += 1
        elif text[i] == ")":
            depth -= 1
        i += 1
    if depth:
        return None                              # unbalanced — treat as unreadable
    return set(re.findall(r'"([^"]+)"', text[m.end():i - 1]))


for script, listname, mode in [
    ("volumes_compiled_select.R", "bilateral_stems_exclude", "exclude"),
    ("volumes_compiled.R",         "insula_stems",           "allowlist"),
    ("volumes_compiled_DeCasien.R", "bilateral_stems",       "allowlist"),
]:
    path = os.path.join(MV, script)
    if not os.path.exists(path):
        print(f"  [PEND] {script} not found")
        pending.append(f"{script} not found")
        continue
    text = strip_r_comments(open(path, encoding="utf-8").read())
    got = rlist(text, listname)
    if got is None:
        # `"auto"` (or any non-literal) means the stem set is discovered at run time, so an
        # exclusion list is the only thing standing between us and a double-doubling.
        auto = re.search(re.escape(listname) + r'\s*<-\s*"auto"', text) is not None
        report(False, f"{script}: could not read `{listname}`",
               "set to \"auto\" — verify by hand" if auto else "assignment not found or not a c(...)")
        continue
    if mode == "exclude":
        bad_stems = sorted(stems - got)
        report(not bad_stems, f"{script}: every author-doubled stem is in `{listname}`",
               ", ".join(bad_stems))
    else:
        bad_stems = sorted(stems & got)
        report(not bad_stems, f"{script}: no author-doubled stem is in `{listname}`",
               ", ".join(bad_stems))

# ---------------------------------------------------------------- 6 provenance != veto
print("\nDoubling is provenance, never a veto")


def pat_match(pattern, value):
    """Port of `.pat_match` in volumes_compiled_select.R: `*` = any, trailing `*` = prefix."""
    p = (pattern or "").strip()
    if p in ("", "*"):
        return True
    if p.endswith("*"):
        return (value or "").startswith(p[:-1])
    return p == value


vf = rd(os.path.join(MV, "volumes_select_value_flags.csv")) or []
skips = [(r, ref, term) for r in vf if (r.get("action") or "").strip() == "skip"
         for ref, term in doubled
         if pat_match(r.get("Source"), ref) and pat_match(r.get("Variable"), term)]
report(not skips,
       "no author-doubled column is skipped in the value-flag registry (wildcards expanded)",
       "; ".join(f"{r.get('Source')}/{r.get('Variable')} hits {ref}:{term}"
                 for r, ref, term in skips))

# ---------------------------------------------------------------- 5 predicted vs actual flags
print("\nPredicted `published_bilateral_estimate` rows")


def predicted(rows, source_key, keep=None):
    out = set()
    for r in rows or []:
        if keep and not keep(r):
            continue
        if (r[source_key], r["Variable"]) in doubled:
            out.add((r["Species"], r["Variable"]))
    return out


def actual(path):
    rows = rd(path)
    if rows is None:
        return None
    return {(r["Species"], r["Variable"]) for r in rows
            if r.get("flag") == "published_bilateral_estimate"}


for label, src_csv, keep, flags_csv in [
    ("volumes_compiled.R",
     "volumes_unfiltered.csv", None, "volumes_flags.csv"),
    ("volumes_compiled_select.R",
     "volumes_resolution_audit_select.csv",
     lambda r: r.get("status", "").startswith("USED"), "volumes_flags_select.csv"),
    ("volumes_compiled_DeCasien.R",
     "volumes_unfiltered_DeCasien.csv", None, "volumes_flags_DeCasien.csv"),
]:
    exp = predicted(rd(os.path.join(MV, src_csv)), "Source", keep)
    got = actual(os.path.join(MV, flags_csv))
    print(f"  {label}: expect {len(exp)} row(s) from {src_csv}")
    if got is None:
        pending.append(f"{flags_csv} not found")
        print(f"    [PEND] {flags_csv} not found")
    elif not got and exp:
        pending.append(f"{flags_csv} has no published_bilateral_estimate rows yet "
                       f"-- re-run {label} in R, then re-run this check")
        print(f"    [PEND] {flags_csv} carries none yet -- re-run {label} in R")
    else:
        missing, extra = sorted(exp - got), sorted(got - exp)
        report(not missing and not extra, f"{flags_csv} matches the prediction",
               f"missing {missing[:4]} extra {extra[:4]}")
    for sp, var in sorted(exp)[:3]:
        print(f"      e.g. {sp} | {var}")
    if len(exp) > 3:
        print(f"      ... and {len(exp) - 3} more")

# ---------------------------------------------------------------- summary
print()
if fails:
    print(f"FAILED {len(fails)} check(s): " + "; ".join(fails))
elif pending:
    print("All checks pass. Pending (re-run the R merge, then re-run this script):")
    for p in pending:
        print("  - " + p)
else:
    print("All checks pass.")
sys.exit(1 if fails else 0)
