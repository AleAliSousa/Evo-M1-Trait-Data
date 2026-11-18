#!/usr/bin/env python3
"""Build a provisional global item index from paper-local pilot registries.

This is an opt-in experiment, not the project's item authority. It does not
edit __ReadMe.xlsx, publish data, or infer items from filenames. Each folder's
item_registry.pilot.csv is an explicit, editable declaration. The generated CSV
contains only folders that have such a declaration; it is not a complete index.
"""
from __future__ import annotations

import argparse
import csv
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "__metadata" / "item_registry_index.pilot.csv"
MANIFEST_NAME = "item_registry.pilot.csv"
CORE_FIELDS = [
    "folder_id", "item_id", "item_kind", "visibility", "review_status",
    "source_file", "source_locator", "item_file", "public_tsv_path",
    "legacy_workbook_row",
]


def relative_file(value: str, field: str, item_id: str) -> None:
    """Check that a declared file exists inside the project, never guess one."""
    p = Path(value)
    if not value or p.is_absolute() or ".." in p.parts:
        raise ValueError(f"{item_id}: {field} must be a relative project path: {value!r}")
    path = (ROOT / p).resolve()
    if not path.is_relative_to(ROOT.resolve()) or not path.is_file():
        raise ValueError(f"{item_id}: missing or out-of-project {field}: {value!r}")


def read_manifests():
    records, headers, ids, public_names = [], [], set(), set()
    manifests = sorted(ROOT.glob(f"*/{MANIFEST_NAME}"))
    if not manifests:
        raise ValueError("No local pilot registries found; refusing to write an empty index")
    for path in manifests:
        with path.open(newline="", encoding="utf-8-sig") as handle:
            reader = csv.DictReader(handle)
            fields = reader.fieldnames or []
            if len(fields) != len(set(fields)) or any(x not in fields for x in CORE_FIELDS):
                raise ValueError(f"Invalid or duplicate headers in {path}")
            # A small local declaration need not repeat every workbook field.
            # Preserve any additional fields in the generated union of columns.
            for field in fields:
                if field not in headers:
                    headers.append(field)
            for row in reader:
                if None in row or any(value is None for value in row.values()):
                    raise ValueError(f"Malformed row in {path}")
                item_id = row["item_id"].strip()
                if not item_id or item_id in ids:
                    raise ValueError(f"Missing or duplicate item ID: {item_id!r}")
                ids.add(item_id)
                if row["folder_id"] != path.parent.name:
                    raise ValueError(f"{item_id}: folder_id does not match manifest location")
                if row["visibility"] not in {"public", "supporting"}:
                    raise ValueError(f"{item_id}: invalid visibility")
                if row["review_status"] != "provisional_unreviewed":
                    raise ValueError(f"{item_id}: pilot requires provisional_unreviewed status")
                if not row["item_kind"] or not row["source_locator"]:
                    raise ValueError(f"{item_id}: declare item_kind and source_locator")
                relative_file(row["source_file"], "source_file", item_id)
                relative_file(row["item_file"], "item_file", item_id)
                if row.get("definitions_file", "").strip():
                    relative_file(row["definitions_file"], "definitions_file", item_id)
                if row["visibility"] == "public":
                    relative_file(row["public_tsv_path"], "public_tsv_path", item_id)
                    if row["public_tsv_path"] in public_names:
                        raise ValueError(f"Duplicate public TSV: {row['public_tsv_path']}")
                    public_names.add(row["public_tsv_path"])
                    if row.get("legacy:Item name") and row["legacy:Item name"] != item_id:
                        raise ValueError(f"{item_id}: imported workbook item name differs")
                    encoded = row.get("legacy:Item encoded", "")
                    if encoded and Path(row["public_tsv_path"]).name != encoded + ".tsv":
                        raise ValueError(f"{item_id}: public filename differs from workbook encoding")
                elif row["public_tsv_path"]:
                    raise ValueError(f"{item_id}: supporting item cannot declare a public TSV")
                records.append({"index_scope": "partial_pilot", **row})
    return ["index_scope", *headers], sorted(records, key=lambda r: r["item_id"]), manifests


def compare_workbook(records):
    """Compare imported values with the current workbook; no workbook writes."""
    import openpyxl

    sheet = openpyxl.load_workbook(ROOT / "__ReadMe.xlsx", read_only=True, data_only=True)["Sheet1"]
    data = sheet.iter_rows(values_only=True)
    headers = next(data)
    if any(h is None for h in headers) or len(headers) != len(set(headers)):
        raise ValueError("Workbook Sheet1 has empty or duplicate headers")
    lookup = {}
    for row in data:
        d = dict(zip(headers, row))
        name = d.get("Item name")
        if name:
            lookup.setdefault(str(name), []).append(d)
    checked, with_legacy, identity_only = 0, 0, 0
    for record in records:
        if not record["legacy_workbook_row"]:
            continue
        item_id = record["item_id"]
        if len(lookup.get(item_id, [])) != 1:
            raise ValueError(f"{item_id}: workbook item is absent or duplicated")
        wb = lookup[item_id][0]
        # Compare identity and public filename even for a minimal declaration;
        # compare imported workbook fields only when they are actually present.
        if record["visibility"] == "public":
            encoded = wb.get("Item encoded")
            if not encoded or Path(record["public_tsv_path"]).name != str(encoded) + ".tsv":
                raise ValueError(f"{item_id}: public filename differs from workbook encoding")
        imported_count = 0
        for header in headers:
            if "legacy:" + header not in record:
                continue
            imported_count += 1
            value = "" if wb.get(header) is None else str(wb[header])
            if record.get("legacy:" + header) != value:
                raise ValueError(f"{item_id}: imported evaluated workbook field changed: {header}")
        if imported_count:
            with_legacy += 1
        else:
            identity_only += 1
        checked += 1
    return checked, with_legacy, identity_only


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check-workbook", action="store_true",
                        help="also compare seeded legacy fields to current workbook cached values")
    args = parser.parse_args()
    fields, records, manifests = read_manifests()
    checked = compare_workbook(records) if args.check_workbook else None
    # Validate before writing; use a temporary file then atomically replace the view.
    temp = OUT.with_suffix(OUT.suffix + ".tmp")
    try:
        with temp.open("w", newline="", encoding="utf-8") as handle:
            writer = csv.DictWriter(handle, fieldnames=fields, lineterminator="\n")
            writer.writeheader()
            writer.writerows(records)
        temp.replace(OUT)
    finally:
        if temp.exists():
            temp.unlink()
    print(f"Partial pilot index: {len(records)} items from {len(manifests)} folder(s): {OUT}")
    if checked is not None:
        total, with_legacy, identity_only = checked
        print(f"Compared {total} items to current workbook: {with_legacy} with imported "
              f"fields; {identity_only} by identity and public filename only")


if __name__ == "__main__":
    main()
