#!/usr/bin/env bash
# Compare TSV-only registry rows with local CSVs by parsed table content.
# This reads the live first sheet and writes a reconciliation report; it does
# not rename, duplicate, or rebuild any data files.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT
Rscript --vanilla - "$tmp" <<'RS'
suppressPackageStartupMessages(library(readxl))
args <- commandArgs(trailingOnly = TRUE)
write.csv(read_excel("__ReadMe.xlsx", sheet = "Sheet1"), args[[1]],
          row.names = FALSE, na = "")
RS
python3 - "$tmp" <<'PY'
import csv
import os
import re
import sys
import unicodedata
from pathlib import Path

rows = list(csv.DictReader(open(sys.argv[1], newline="")))
root = Path.cwd()
public = root / "__Public" / "comparative-data"
tsv_names = set(os.listdir(public))
folders = [d for d in root.iterdir() if d.is_dir() and not d.name.startswith("_")]
folder_names = {d.name for d in folders}

def norm(value):
    value = value.translate(str.maketrans({"ø": "o", "Ø": "O", "ł": "l"}))
    value = unicodedata.normalize("NFKD", value)
    return re.sub(r"[^a-z0-9]", "", value.encode("ascii", "ignore").decode().lower())

def table(path, delimiter):
    try:
        with path.open(newline="", encoding="utf-8-sig") as fh:
            return list(csv.reader(fh, delimiter=delimiter))
    except (OSError, UnicodeError, csv.Error):
        return None

def candidate_folders(publication):
    year_match = re.search(r"(?:19|20)\d{2}", publication)
    year = year_match.group() if year_match else ""
    family = norm(publication.split("_")[0])
    candidate = []
    for folder in folders:
        name = folder.name
        same_name = norm(name) == norm(publication)
        same_family_year = family and norm(name).startswith(family) and year in name
        hardus_chapter = publication == "Hardus_etal_2008" and name == "Hardus_etal_2009"
        if same_name or same_family_year or hardus_chapter:
            candidate.append(folder)
    return candidate

def rank(path, item):
    name = norm(path.stem)
    target = norm(item)
    # Prefer the analysis item over a transcription/intermediate with the same values.
    return (0 if name == target else 1, len(path.name), path.name)

out = []
counts = {"both": 0, "csv_only": 0, "tsv_only": 0, "neither": 0}
for sheet_row, row in enumerate(rows, 2):
    item = row["Item name"]
    code = row["Item encoded"]
    publication = row["Publication name"]
    if not item:
        continue
    exact_csv = root / publication / (item + ".csv")
    # Match the earlier audit's rule: the publication directory name must be
    # exact, while macOS resolves case variants within that directory.
    exact = publication in folder_names and exact_csv.is_file()
    has_tsv = bool(code) and code + ".tsv" in tsv_names
    category = ("both" if exact and has_tsv else
                "csv_only" if exact else
                "tsv_only" if has_tsv else "neither")
    counts[category] += 1
    if category != "tsv_only":
        continue
    tsv = public / (code + ".tsv")
    tsv_table = table(tsv, "\t")
    matches = []
    for folder in candidate_folders(publication):
        for csv_path in folder.glob("*.csv"):
            if any(s in csv_path.name for s in ("_snapshot", "_definitions")):
                continue
            if table(csv_path, ",") == tsv_table and tsv_table is not None:
                matches.append(csv_path)
    matches.sort(key=lambda p: rank(p, item))
    recorded = row.get("Verified local CSV path (alias; blank means item path)", "")
    chosen = str(matches[0].relative_to(root)) if matches else ""
    if recorded and recorded != chosen:
        raise SystemExit(f"Registry CSV alias differs from audit at sheet row {sheet_row}: {recorded} != {chosen}")
    out.append({
        "sheet_row": sheet_row,
        "registry_item": item,
        "public_tsv": str(tsv.relative_to(root)),
        "matching_local_csv": chosen,
        "status": ("registry alias recorded and identical" if recorded else
                   "identical CSV under alternate name" if matches else
                   "no matching local CSV found"),
    })

report = root / "_checks" / "registry_tsv_only_aliases_2026-11-26.csv"
with report.open("w", newline="") as fh:
    writer = csv.DictWriter(fh, fieldnames=list(out[0]) if out else [
        "sheet_row", "registry_item", "public_tsv", "matching_local_csv", "status"])
    writer.writeheader()
    writer.writerows(out)
matched = sum(bool(x["matching_local_csv"]) for x in out)
recorded = sum(x["status"] == "registry alias recorded and identical" for x in out)
print("Exact-path registry count:", ", ".join(f"{k}={v}" for k, v in counts.items()))
print(f"TSV-only exact-name rows: {len(out)}")
print(f"Identical CSV found under another name: {matched}")
print(f"Verified aliases recorded in registry: {recorded}")
print(f"No matching local CSV: {len(out) - matched}")
print(f"Unreconciled TSV-only rows: {len(out) - recorded}")
print(f"CSV and TSV paired by exact path or identical content: {counts['both'] + matched}")
for row in out:
    if not row["matching_local_csv"]:
        print(f"  {row['registry_item']} (sheet row {row['sheet_row']})")
print(f"Report: {report}")
PY
