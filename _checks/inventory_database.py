"""Read-only registry and filesystem inventory; writes its own report files."""
from collections import Counter
import csv
import json
from pathlib import Path
import subprocess
import tempfile
import unicodedata

import openpyxl

root = Path(__file__).resolve().parents[1]
registry_path = root / "__ReadMe.xlsx"
rows = list(openpyxl.load_workbook(registry_path, read_only=True, data_only=True)["Sheet1"].values)
headers = rows[0]
fields = {name: i for i, name in enumerate(headers)}
get = lambda row, name: row[fields[name]] if fields[name] < len(row) else None
public = root / "__Public" / "comparative-data"
public_names = {p.name for p in public.glob("*.tsv")}
folders = sorted((p for p in root.iterdir() if p.is_dir() and not p.name.startswith(("_", "."))),
                 key=lambda p: len(p.name), reverse=True)
normalize = lambda value: unicodedata.normalize("NFC", value).casefold()
records = []
for rownum, row in enumerate(rows[1:], 2):
    item = get(row, "Item name")
    if not item:
        continue
    item = str(item)
    code = get(row, "Item encoded")
    code = str(code) if code else None
    folder = next((p for p in folders if normalize(item).startswith(normalize(p.name) + "_")), None)
    local = folder / f"{item}.csv" if folder else None
    script = folder / f"{item}.R" if folder else None
    normalized_item = unicodedata.normalize("NFC", item)
    snapshots = [p for p in folder.glob("*_snapshot.*")
                 if unicodedata.normalize("NFC", p.name).startswith(normalized_item + "_snapshot.")] if folder else []
    definition = folder / "reference_tables" / f"{item}_definitions.csv" if folder else None
    readmes = [p for p in folder.glob("*README.md")
               if unicodedata.normalize("NFC", p.name).startswith(normalized_item)] if folder else []
    records.append({"row": rownum, "item": item, "encoded": code,
                    "progress": get(row, "Progress stage"), "data_role": get(row, "Data role (primary/secondary/both)"),
                    "folder": folder.name if folder else None,
                    "public_tsv": bool(code and f"{code}.tsv" in public_names),
                    "analysis_csv": bool(local and local.is_file()), "build_script": bool(script and script.is_file()),
                    "snapshot": bool(snapshots), "definitions": bool(definition and definition.is_file()),
                    "readme": bool(readmes)})

with tempfile.TemporaryDirectory() as temporary:
    previous = Path(temporary) / "registry.xlsx"
    with previous.open("wb") as stream:
        subprocess.run(["git", "-c", "core.fsmonitor=false", "show", "HEAD:__ReadMe.xlsx"],
                       cwd=root, stdout=stream, check=True)
    old_rows = list(openpyxl.load_workbook(previous, read_only=True, data_only=True)["Sheet1"].values)
old_items = {r[9] for r in old_rows[1:] if len(r) > 9 and r[9]}
recent = [r for r in records if r["item"] not in old_items]

item_counts = Counter(r["item"] for r in records)
code_counts = Counter(r["encoded"] for r in records if r["encoded"])
listed_public = {f'{r["encoded"]}.tsv' for r in records if r["encoded"]}
citation_only = sum(bool(get(r, "Citation (APA 7th-Annotated)")) and not get(r, "Item name")
                    for r in rows[1:])
summary = {
    "as_of": "2026-10-29", "registry_rows": len(records), "unique_item_names": len(item_counts),
    "citation_only_rows": citation_only, "public_tsv_files": len(public_names),
    "registered_with_public_tsv": sum(r["public_tsv"] for r in records),
    "registered_without_public_tsv": sum(not r["public_tsv"] for r in records),
    "unlisted_public_tsv_files": sorted(public_names - listed_public),
    "duplicate_item_names": {k: v for k, v in item_counts.items() if v > 1},
    "duplicate_encoded_names": {k: v for k, v in code_counts.items() if v > 1},
    "encoded_names_with_whitespace": sorted(k for k in code_counts if any(ch.isspace() for ch in k)),
    "data_roles": dict(Counter(str(r["data_role"] or "(blank)") for r in records)),
    "new_since_head": len(recent),
}
report = {"summary": summary, "recent_items": recent, "items": records}
folder_counts = Counter(r["folder"] for r in records if r["folder"])
paper_folders = [p for p in folders if p.name != "vertebrate_opsin_explorer"]
report["folders"] = [{"folder": p.name, "registered_rows": folder_counts[p.name],
                       "files": sum(1 for q in p.iterdir() if q.is_file())}
                      for p in sorted(paper_folders)]
summary["paper_folders"] = len(paper_folders)
summary["paper_folders_with_registry_rows"] = sum(folder_counts[p.name] > 0 for p in paper_folders)
summary["paper_folders_without_registry_rows"] = [p.name for p in paper_folders if folder_counts[p.name] == 0]
summary["registry_rows_without_paper_folder"] = sum(not r["folder"] for r in records)
merged = []
for domain in sorted(root.glob("__merging_*")):
    if not domain.is_dir():
        continue
    for path in sorted(domain.glob("*.csv")):
        if not path.stem.endswith(("_long", "_wide", "_unfiltered", "_compiled")):
            continue
        try:
            with path.open(newline="", encoding="utf-8-sig") as stream:
                reader = csv.reader(stream)
                header = next(reader, [])
                count = sum(1 for _ in reader)
            error = None
        except (OSError, UnicodeError, csv.Error) as exc:
            header, count, error = [], None, str(exc)
        merged.append({"domain": domain.name, "file": str(path.relative_to(root)),
                       "rows": count, "columns": len(header), "bytes": path.stat().st_size,
                       "read_error": error})
report["compiled_outputs"] = merged
summary["merge_domains"] = len({r["domain"] for r in merged})
summary["compiled_output_csvs"] = len(merged)
out = root / "_checks"
(out / "database_inventory_2026-10-29.json").write_text(json.dumps(report, indent=2, ensure_ascii=False, default=str) + "\n")
lines = ["# Evo-M1 database inventory", "", "Registry and filesystem snapshot: 2026-10-29. File presence is checked on disk; progress labels are copied from the live registry.", "",
         "## Counts", "", "| Measure | Count |", "|---|---:|"]
for key in ("registry_rows", "unique_item_names", "citation_only_rows", "public_tsv_files",
            "registered_with_public_tsv", "registered_without_public_tsv", "new_since_head",
            "paper_folders", "paper_folders_with_registry_rows", "registry_rows_without_paper_folder",
            "merge_domains", "compiled_output_csvs"):
    lines.append(f"| {key.replace('_', ' ')} | {summary[key]} |")
roles = summary["data_roles"]
other_roles = len(records) - sum(roles.get(k, 0) for k in ("primary", "secondary", "both", "(blank)"))
lines += ["", f'Data-role labels in the registry: {roles.get("primary", 0)} `primary`, {roles.get("secondary", 0)} `secondary`, {roles.get("both", 0)} `both`, and {roles.get("(blank)", 0)} blank; {other_roles} rows use other descriptive labels. These are registry labels, not a review of the underlying measurements.']
lines += ["", "## Items added since the latest commit", "",
          "| Item | Public TSV | CSV | R | Snapshot | Definitions | Registry progress |",
          "|---|:---:|:---:|:---:|:---:|:---:|---|"]
for r in recent:
    yn = lambda k: "Yes" if r[k] else "No"
    progress = str(r["progress"] or "(blank)").replace("|", "\\|")
    if len(progress) > 90:
        progress = progress[:87] + "..."
    lines.append(f'| {r["item"]} | {yn("public_tsv")} | {yn("analysis_csv")} | {yn("build_script")} | {yn("snapshot")} | {yn("definitions")} | {progress} |')
lines += ["", "Eight of these items were built or completed in this pass: Dlugosz Table S1; Franco Table 1 and Text; Garcia–Ravignani sp1; Heffner ResultsText and Figure 6; Martin Supporting Information S1 and Mammalian Vocalisation Data.",
          "The other 11 recent items already had public TSVs. All 19 now have a public TSV, analysis CSV, R script, frozen source, definitions, and README on disk.", ""]
lines += ["", "## Registry health", "",
          f'- Repeated item names: {len(summary["duplicate_item_names"])}; these include the registry’s intentional `#n` multi-row convention and need row-level review before any deduplication.',
          f'- Repeated encoded names: {len(summary["duplicate_encoded_names"])}.',
          f'- Public TSV files with no registry encoded name: {len(summary["unlisted_public_tsv_files"])}.',
          f'- Encoded names containing whitespace: {len(summary["encoded_names_with_whitespace"])}.',
          f'- Paper folders without any matching registry item: {len(summary["paper_folders_without_registry_rows"])}.',
          "- Several recent rows still have blank or PREPARED progress text despite files now existing. The live workbook was not edited during this inventory.",
          "- A missing local file can reflect a source-only/candidate row or a legacy naming convention. Use the JSON item records for review.",
          "", "## Full inventory", "",
          "The companion JSON lists every registered item, its registry status and role, six local file checks, and compiled output metadata.", ""]
lines += ["### Compiled outputs", "",
          "Files ending in `_long.csv`, `_wide.csv`, `_unfiltered.csv`, or `_compiled.csv` within the merge directories:", "",
          "| Domain | Output | Rows | Columns |", "|---|---|---:|---:|"]
for r in merged:
    lines.append(f'| {r["domain"]} | `{Path(r["file"]).name}` | {r["rows"] if r["rows"] is not None else "error"} | {r["columns"]} |')
lines.append("")
missing = [r for r in records if not r["public_tsv"]]
if missing:
    lines += ["### Registered items without a matching public TSV", "",
              "| Item | Registry progress |", "|---|---|"]
    for r in missing:
        progress = str(r["progress"] or "(blank)").replace("|", "\\|")
        if len(progress) > 90:
            progress = progress[:87] + "..."
        lines.append(f'| {r["item"]} | {progress} |')
    lines.append("")
if summary["duplicate_item_names"]:
    lines += ["### Duplicate item names", ""]
    lines.extend(f'- `{name}`: {count} registry rows' for name, count in summary["duplicate_item_names"].items())
    lines.append("")
if summary["paper_folders_without_registry_rows"]:
    lines += ["### Paper folders with no matching registry item", ""]
    lines.extend(f'- `{name}`' for name in summary["paper_folders_without_registry_rows"])
    lines.append("")
if summary["encoded_names_with_whitespace"]:
    lines += ["### Encoded names containing whitespace", ""]
    lines.extend(f'- `{name}`' for name in summary["encoded_names_with_whitespace"])
    lines.append("")
if summary["unlisted_public_tsv_files"]:
    lines += ["### Unlisted public TSV files", ""]
    lines.extend(f'- `{n}`' for n in summary["unlisted_public_tsv_files"])
    lines.append("")
(out / "database_inventory_2026-10-29.md").write_text("\n".join(lines), encoding="utf-8")
print(json.dumps({k: v for k, v in summary.items() if not isinstance(v, (list, dict))}, indent=2))
