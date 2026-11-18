#!/usr/bin/env python3
"""Read-only naming, placement, and schema checks for pilot metadata CSVs."""

from __future__ import annotations

import argparse
import csv
from collections import Counter
from pathlib import Path
import sys


PAPERS = (
    "ManyPrimates__2022",
    "Mink_etal_1981",
    "Boddy_etal_2012",
    "Falcone_etal_2019",
    "Buchsbaum_etal_1989",
    "Kaufman__2004",
    "Heffner_Heffner_2010_b",
    "Bahney_vonBartheld_2018",
    "Fobbs_etal_2011",
    "Kennedy_etal_1978",
)
EXPECTED_ACTIVE_TABLES = 49  # Includes Kaufman's bibliography and OCR audit.

# Keep the suffixes required by build_variable_catalog.R and source_match.R.
ROLE_SUFFIXES = {
    "bibliography": ("bibliography",),
    "field_definitions": ("definitions",),
    "citation_lookup": ("references", "footnotes"),
    "citation_scope": ("reference_columns",),
    "errata_ledger": ("errata", "ocr_audit"),
    "proposed_taxon_mapping": ("species_key_proposed",),
    "taxon_annotation_lookup": ("taxa",),
    "generated_source_match": ("source_match",),
    "generated_source_match_issues": ("source_match_issues",),
    "generated_source_match_summary": ("source_match_summary",),
}

# Exact headers are enforced only where the table type already has one schema.
HEADERS = {
    "definitions": ("Code", "Definition", "Structure", "Measure", "Stat", "role", "taxon", "Reference", "Note", "Source Note"),
    "footnotes": ("letter", "definition"),
    "reference_columns": ("key_column", "applies_to", "separator", "note"),
    "errata": ("errata_id", "item", "variable", "locator", "printed_value", "repo_value_before", "issue_type", "proposed_value", "evidence", "status", "status_reason", "raised_by", "date_raised", "date_resolved", "note"),
    "ocr_audit": ("entry_id", "pdf_page", "original_ocr", "page_checked_transcription", "review_scope"),
    "species_key_proposed": ("variant_name", "accepted_name", "source_publication", "collection", "ncbi_taxid", "basis", "note"),
    "taxa": ("printed_name", "printed_column", "Species_binomial", "taxon_rank", "species_basis", "taxon_type", "note"),
    "source_match": ("item", "row_id", "species", "key_column", "key_cell_as_printed", "n_keys_in_cell", "ref_key", "citation", "variable", "value", "match_basis", "status"),
    "source_match_issues": ("item", "issue", "key_column", "ref_key", "row_id", "species", "variable", "detail"),
    "source_match_summary": ("item", "ref_key", "citation", "variable", "key_column", "n_rows", "n_species", "species", "n_rows_shared_key", "match_basis", "status"),
}

# These files can intentionally cover more than the manifest's related item.
PAPER_SCOPED_ROLES = {"errata_ledger", "proposed_taxon_mapping"}
SHARED_SCOPES = {"Kaufman__2004_TablesA1-A14", "Kaufman__2004_bibliography"}


def read_rows(path: Path) -> list[dict[str, str]]:
    with path.open(newline="", encoding="utf-8-sig") as stream:
        return list(csv.DictReader(stream))


def suffix_and_scope(name: str) -> tuple[str, str] | None:
    for suffix in sorted({s for values in ROLE_SUFFIXES.values() for s in values}, key=len, reverse=True):
        ending = f"_{suffix}.csv"
        if name.endswith(ending):
            return suffix, name[: -len(ending)]
    return None


def validate(root: Path) -> int:
    errors: list[str] = []
    active: list[dict[str, str]] = []
    by_file_id: dict[str, str] = {}
    for paper in PAPERS:
        manifest = root / paper / "pipeline_files.csv"
        if not manifest.is_file():
            errors.append(f"{paper}: missing pipeline_files.csv")
            continue
        for row in read_rows(manifest):
            if ((row.get("content_role") == "bibliography"
                 and row.get("file_role") != "metadata_table")
                    or row.get("content_role") not in ROLE_SUFFIXES
                    or row.get("lifecycle_status") != "active"):
                continue
            row = {**row, "paper": paper}
            active.append(row)
            file_id = row.get("file_id", "")
            if not file_id:
                errors.append(f"{paper}: supporting metadata row has no file_id")
            elif file_id in by_file_id:
                errors.append(f"{paper}: duplicate file_id {file_id}")
            else:
                by_file_id[file_id] = row.get("path", "")

        for file in (root / paper).glob("*_definitions.csv"):
            errors.append(f"{file.relative_to(root)}: definition must be under reference_tables/")

    if len(active) != EXPECTED_ACTIVE_TABLES:
        errors.append(f"expected {EXPECTED_ACTIVE_TABLES} active supporting metadata CSVs, found {len(active)}")

    registered_paths: set[str] = set()
    role_counts: Counter[str] = Counter()
    for row in active:
        paper, path_text = row["paper"], row.get("path", "")
        file_id, role = row.get("file_id", ""), row["content_role"]
        rel = Path(path_text)
        expected_folder = (paper, "reference_tables")
        if len(rel.parts) != 3 or rel.parts[:2] != expected_folder or rel.suffix != ".csv":
            errors.append(f"{file_id}: expected <Paper>/reference_tables/<name>.csv, got {path_text}")
        if path_text in registered_paths:
            errors.append(f"{file_id}: duplicate registered path {path_text}")
        registered_paths.add(path_text)
        file = root / rel
        if not file.is_file():
            errors.append(f"{file_id}: missing file {path_text}")
            continue
        parsed = suffix_and_scope(file.name)
        if parsed is None:
            errors.append(f"{file_id}: no controlled metadata suffix in {file.name}")
            continue
        suffix, scope = parsed
        if suffix not in ROLE_SUFFIXES[role]:
            errors.append(f"{file_id}: suffix _{suffix} conflicts with content_role {role}")
        item = row.get("item_id", "").strip()
        valid_scopes = {paper}
        if item:
            valid_scopes.add(item)
        if paper == "Kaufman__2004":
            valid_scopes |= SHARED_SCOPES
        if scope not in valid_scopes:
            errors.append(f"{file_id}: scope {scope!r} is not item ID, paper ID, or declared shared item set")
        if item and scope == paper and role not in PAPER_SCOPED_ROLES:
            errors.append(f"{file_id}: item-scoped {role} must use exact item ID {item}")
        with file.open(newline="", encoding="utf-8-sig") as stream:
            try:
                header = tuple(next(csv.reader(stream)))
            except StopIteration:
                errors.append(f"{file_id}: empty CSV")
                continue
        if suffix in HEADERS and header != HEADERS[suffix]:
            errors.append(f"{file_id}: _{suffix} header differs from its table-type schema")
        if suffix == "references" and not {"ref_key", "citation"}.issubset(header):
            errors.append(f"{file_id}: _references requires ref_key and citation columns")
        role_counts[role] += 1

    for paper in PAPERS:
        for file in (root / paper / "reference_tables").glob("*.csv"):
            rel = str(file.relative_to(root))
            if rel not in registered_paths:
                errors.append(f"{rel}: metadata CSV is absent from active pipeline_files.csv")

    issue_file = root / "__metadata" / "pilot" / "file_registration_issues.csv"
    unresolved: list[dict[str, str]] = []
    if issue_file.is_file():
        unresolved = [r for r in read_rows(issue_file)
                      if r.get("issue_code") == "metadata_source_locator_missing"
                      and r.get("file_id") in by_file_id]
    print(f"Pilot metadata: {len(active)} active CSVs in {len(PAPERS)} paper folders; "
          f"{len(HEADERS) + 1} controlled suffixes ({len(HEADERS)} fixed headers)")
    print("Types: " + ", ".join(f"{role}={n}" for role, n in sorted(role_counts.items())))
    unresolved_ids = {r["file_id"] for r in unresolved}
    print("File inventory (scope; provenance locator):")
    scope_counts: Counter[str] = Counter()
    for row in sorted(active, key=lambda r: r.get("path", "")):
        parsed = suffix_and_scope(Path(row.get("path", "")).name)
        scope = parsed[1] if parsed else "?"
        if scope == row.get("item_id", "") and scope:
            scope_kind = "item"
        elif scope in SHARED_SCOPES:
            scope_kind = "item_set"
        elif scope == row["paper"]:
            scope_kind = "paper"
        else:
            scope_kind = "INVALID"
        scope_counts[scope_kind] += 1
        locator = "MISSING" if row.get("file_id") in unresolved_ids else "no_open_issue"
        print(f"  {row.get('file_id', '')}: {row.get('path', '')} "
              f"[{row['content_role']}; {scope_kind}; locator={locator}]")
    print("Scope pattern: " + ", ".join(f"{kind}={n}" for kind, n in sorted(scope_counts.items())))
    if issue_file.is_file():
        counts = Counter(Path(by_file_id[r["file_id"]]).parts[0] for r in unresolved)
        detail = ", ".join(f"{paper}={n}" for paper, n in sorted(counts.items()))
        print(f"Unresolved source locators: {len(unresolved)} active files ({detail})")
        print(f"  Details: {issue_file.relative_to(root)}")
    else:
        print("Unresolved source locators: issue register not found; run build_file_registry.R")
    if errors:
        print(f"FAIL: {len(errors)} error(s)", file=sys.stderr)
        for error in errors:
            print(f"  - {error}", file=sys.stderr)
        return 1
    print("PASS: naming, placement, registration, and stable headers")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[2],
                        help="repository root (default: inferred from script path)")
    args = parser.parse_args()
    return validate(args.root.resolve())


if __name__ == "__main__":
    raise SystemExit(main())
