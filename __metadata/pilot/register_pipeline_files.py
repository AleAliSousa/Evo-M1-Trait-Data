#!/usr/bin/env python3
"""Seed and validate one file-level registry for the ten pilot paper folders.

`seed` is a one-time migration from metadata_sources.csv and artifacts.csv.
Afterwards pipeline_files.csv and file_dependencies.csv are authoritative.
`derive-legacy` can regenerate metadata_sources.csv as a compatibility view.
"""

from __future__ import annotations

import argparse
import csv
from pathlib import Path

from openpyxl import load_workbook


ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
FOLDERS = (
    "ManyPrimates__2022", "Mink_etal_1981", "Boddy_etal_2012",
    "Falcone_etal_2019", "Buchsbaum_etal_1989", "Kaufman__2004",
    "Heffner_Heffner_2010_b", "Bahney_vonBartheld_2018",
    "Fobbs_etal_2011", "Kennedy_etal_1978",
)
FILE_COLUMNS = (
    "file_id", "path", "item_id", "file_role", "content_role", "record_grain",
    "creation_mode", "stage", "authority_status", "producer_id",
    "lifecycle_status", "note",
)
DEPENDENCY_COLUMNS = (
    "output_file_id", "input_file_id", "relation", "source_locator", "note",
)
LEGACY_COLUMNS = (
    "resource_id", "source_class", "path", "registered_item_id", "builder_r",
    "public_tsv_path", "content_role", "record_grain", "authority_status",
    "related_item_id", "note",
)
FILE_ROLES = {
    "source_document", "source_table", "snapshot", "item_builder", "item_csv",
    "public_tsv", "metadata_table", "support_script", "pipeline_script",
    "pipeline_output", "documentation", "manifest",
}
CREATION_MODES = {"external", "copied", "transcribed", "manual_curated", "generated", "unknown"}
STAGES = {
    "source", "snapshot", "paper_metadata", "item_processing", "curation",
    "qualification", "selection", "audit", "registry", "documentation",
}
LIFECYCLE = {"active", "ancillary", "retired"}
DEPENDENCY_RELATIONS = {
    "produced_by", "exported_from", "copied_from", "transcribed_from",
    "derived_from", "reads", "derives_from", "validates_against",
}
MATRIX_ROLES = {"source_table", "snapshot", "metadata_table", "pipeline_output"}
OTHER_ROLES = {"source_document", "support_script", "documentation"}

# Each of these scripts was inspected for an actual write or file.copy call
# targeting the named snapshot. This map is intentionally explicit: a matching
# filename alone is not sufficient to claim a producer.
SNAPSHOT_WRITERS = {
    "ManyPrimates__2022_speciespredictors": "ManyPrimates__2022/ManyPrimates__2022_speciespredictors_snapshot.R",
    "Mink_etal_1981_TABLE1": "Mink_etal_1981/Mink_etal_1981_TABLE1_snapshot.R",
    "Buchsbaum_etal_1989_TableI": "Buchsbaum_etal_1989/Buchsbaum_etal_1989_TableI_snapshot.R",
    "Buchsbaum_etal_1989_Text": "Buchsbaum_etal_1989/Buchsbaum_etal_1989_Text_snapshot.R",
    "Kennedy_etal_1978_Table": "Kennedy_etal_1978/Kennedy_etal_1978_Table_snapshot.R",
    "Kennedy_etal_1978_Text": "Kennedy_etal_1978/Kennedy_etal_1978_Text_snapshot.R",
    **{f"Fobbs_etal_2011_TableS{suffix}":
       f"Fobbs_etal_2011/Fobbs_etal_2011_TableS{suffix}_snapshot.py"
       for suffix in ("1a", "1b", "2", "3", "4", "5a", "5b")},
}
TRANSCRIBED_SNAPSHOTS = {
    "Mink_etal_1981_REFERENCES",  # REFERENCES.README.md: manual transcription.
    "Bahney_vonBartheld_2018_TABLE1",  # TABLE1.README.md: transcribed from PDF text.
    "Bahney_vonBartheld_2018_TABLE2",  # TABLE2.README.md: transcribed from PDF text.
}
COPIED_SNAPSHOTS = {
    "ManyPrimates__2022_STMperformance": "ManyPrimates__2022/ManyPrimates_mp1_merged_data.csv",
}
SNAPSHOT_SOURCE_FILES = {
    "ManyPrimates__2022_speciespredictors": "ManyPrimates__2022/species_predictors.xlsx",
    **{f"Fobbs_etal_2011_TableS{suffix}":
       f"Fobbs_etal_2011/nyas_6036_sm_table{suffix}.doc"
       for suffix in ("1a", "1b", "2", "3", "4", "5a", "5b")},
}
ANCILLARY_PAPER_FILES = {
    "ManyPrimates__2022": (
        ("many-source-table-inventory-xlsx", "ManyPrimates_source_table_inventory_2026-10-21.xlsx",
         "metadata_table", "source_inventory", "source_item", "unknown", "paper_metadata",
         "project_inventory", "ancillary", "Earlier source-table inventory; outside the active ten-paper build"),
        ("many-legacy-build-all", "build_manyprimates_items.R", "pipeline_script",
         "pipeline_code", "script", "manual_curated", "item_processing", "processing_script",
         "ancillary", "Earlier cross-folder batch runner invokes a __merging_supplementary build"),
        ("many-legacy-build-chivers-gautier", "build_chivers_gautier.R",
         "pipeline_script", "pipeline_code", "script", "manual_curated", "item_processing",
         "processing_script", "ancillary", "Earlier Chivers/Gautier batch and merge runner"),
        ("many-legacy-refresh-source-manifest", "refresh_manyprimates_manifest.R",
         "pipeline_script", "pipeline_code", "script", "manual_curated", "registry",
         "processing_script", "ancillary", "Earlier Shiny app source-manifest refresh script"),
        ("many-source-note", "ManyPrimates_etal_2022.txt", "documentation",
         "item_note", "document", "manual_curated", "documentation",
         "project_documentation", "ancillary", "Historical source URL note"),
        ("many-missing-pdfs-note", "ManyPrimates_missing_PDFs_2026-10-21.txt", "documentation",
         "item_note", "document", "manual_curated", "documentation",
         "project_documentation", "ancillary", "Historical missing-source list"),
        ("many-source-review-note", "ManyPrimates_source_review_2026-10-21.txt", "documentation",
         "item_note", "document", "manual_curated", "documentation",
         "project_documentation", "ancillary", "Historical source-screening summary"),
        ("many-supplements-to-find-note", "ManyPrimates_supplements_to_find_2026-10-21.txt", "documentation",
         "item_note", "document", "manual_curated", "documentation",
         "project_documentation", "ancillary", "Historical missing-supplement list"),
        ("many-source-files-json", "ManyPrimates_source_files_2026-10-21.json", "metadata_table",
         "source_inventory", "source_item", "unknown", "paper_metadata",
         "project_inventory", "ancillary", "Historical source-file inventory"),
        ("many-source-table-inventory-json", "ManyPrimates_source_table_inventory_2026-10-21.json",
         "metadata_table", "source_inventory", "source_item", "unknown", "paper_metadata",
         "project_inventory", "ancillary", "Historical source-table inventory"),
        ("many-supplement-downloads-json", "ManyPrimates_supplement_downloads_2026-10-21.json",
         "metadata_table", "source_inventory", "source_item", "unknown", "paper_metadata",
         "project_inventory", "ancillary", "Historical supplement-download inventory"),
    ),
    "Kaufman__2004": (
        ("kaufman-old-a15-comparison-long", "old/Kaufman__2004_A15_comparison_long.csv",
         "pipeline_output", "generated_check_result", "comparison_row", "unknown", "audit",
         "generated_audit", "retired", "Historical Table A15 comparison; producer not documented here"),
        ("kaufman-old-a15-comparison-mismatches", "old/Kaufman__2004_A15_comparison_mismatches.csv",
         "pipeline_output", "generated_check_result", "comparison_row", "unknown", "audit",
         "generated_audit", "retired", "Historical Table A15 mismatch audit; producer not documented here"),
        ("kaufman-old-a15-readme", "old/Kaufman__2004_TableA15_README.md",
         "documentation", "item_documentation", "document", "manual_curated", "documentation",
         "project_documentation", "retired", "Historical Table A15 build and comparison notes"),
    ),
    "Kennedy_etal_1978": (
        ("kennedy-retired-snapshot-script", "Kennedy_etal_1978_extract_snapshot.R.retired",
         "support_script", "pipeline_code", "script", "manual_curated", "snapshot",
         "processing_script", "retired", "Retired combined snapshot extractor; active item snapshots use separate scripts"),
    ),
}


def read_csv(path: Path, columns: tuple[str, ...] | None = None) -> list[dict[str, str]]:
    with path.open(newline="", encoding="utf-8-sig") as stream:
        reader = csv.DictReader(stream)
        if columns is not None and tuple(reader.fieldnames or ()) != columns:
            raise ValueError(f"{path}: expected columns {columns}, got {reader.fieldnames}")
        return [dict(row) for row in reader]


def write_csv(path: Path, columns: tuple[str, ...], rows: list[dict[str, str]]) -> None:
    with path.open("w", newline="", encoding="utf-8") as stream:
        writer = csv.DictWriter(stream, fieldnames=columns, extrasaction="raise")
        writer.writeheader()
        writer.writerows(rows)


def artifact_ids() -> dict[str, str]:
    artifacts = read_csv(HERE / "artifacts.csv")
    paths = [row["path"] for row in artifacts]
    if len(paths) != len(set(paths)):
        raise ValueError("artifacts.csv has duplicate paths")
    return {row["path"]: row["artifact_id"] for row in artifacts}


def file_role(source: dict[str, str]) -> str:
    if source["source_class"] == "registered_matrix":
        return "item_csv"
    path = source["path"].lower()
    role = source["content_role"]
    if role == "frozen_snapshot":
        return "snapshot"
    if source["source_class"] == "unregistered_matrix":
        if role in {"supplied_source_matrix", "variable_workbook"}:
            return "source_table"
        if role.startswith("generated_") or role == "generated_check_result":
            return "pipeline_output"
        return "metadata_table"
    if path.endswith((".r", ".py", ".sh")):
        return "support_script"
    if path.endswith((".md", ".html")):
        return "documentation"
    if path.endswith((".pdf", ".doc", ".docx")):
        return "source_document"
    return "documentation"


def file_stage(role: str) -> str:
    return {
        "source_document": "source", "source_table": "source",
        "snapshot": "snapshot", "item_builder": "item_processing",
        "item_csv": "item_processing", "public_tsv": "item_processing",
        "metadata_table": "paper_metadata", "support_script": "paper_metadata",
        "pipeline_output": "audit", "documentation": "documentation",
        "manifest": "registry",
    }[role]


def creation_mode(source: dict[str, str], role: str) -> str:
    if role == "item_csv" or role == "pipeline_output" or source["builder_r"]:
        return "generated"
    if role in {"source_document", "source_table"} and source["authority_status"] == "source_evidence":
        return "external"
    if role == "snapshot":
        return "unknown"  # The manifest does not always prove manual vs scripted extraction.
    if role == "support_script" or role == "documentation":
        return "manual_curated"
    return "manual_curated"


def seed_folder(folder: str, artifacts: dict[str, str], force: bool) -> tuple[int, int]:
    folder_path = ROOT / folder
    target_files = folder_path / "pipeline_files.csv"
    target_deps = folder_path / "file_dependencies.csv"
    if (target_files.exists() or target_deps.exists()) and not force:
        raise FileExistsError(f"{folder}: file registry exists; use --force only for an intentional reseed")
    legacy = read_csv(folder_path / "metadata_sources.csv", LEGACY_COLUMNS)
    rows: list[dict[str, str]] = []
    by_path: dict[str, dict[str, str]] = {}

    def add(row: dict[str, str]) -> None:
        if row["path"] in by_path:
            raise ValueError(f"Duplicate file path in {folder}: {row['path']}")
        rows.append(row)
        by_path[row["path"]] = row

    for source in legacy:
        role = file_role(source)
        item_id = source["registered_item_id"] or source["related_item_id"]
        add(dict(
            file_id=artifacts.get(source["path"], source["resource_id"]),
            path=source["path"], item_id=item_id, file_role=role,
            content_role=source["content_role"], record_grain=source["record_grain"],
            creation_mode=creation_mode(source, role), stage=file_stage(role),
            authority_status=source["authority_status"], producer_id="",
            lifecycle_status="active", note=source["note"],
        ))

    for source in legacy:
        if source["source_class"] != "registered_matrix":
            continue
        item_id = source["registered_item_id"]
        builder_path = source["builder_r"]
        public_path = source["public_tsv_path"]
        for path, role, content, grain, mode, status in (
            (builder_path, "item_builder", "pipeline_code", "script",
             "manual_curated", "processing_script"),
            (public_path, "public_tsv", source["content_role"], source["record_grain"],
             "generated", "item_processing"),
        ):
            add(dict(
                file_id=artifacts.get(path, f"{role}_{item_id}"), path=path,
                item_id=item_id, file_role=role, content_role=content,
                record_grain=grain, creation_mode=mode,
                stage=file_stage(role), authority_status=status,
                producer_id="", lifecycle_status="active",
                note="Registered item build file" if role == "item_builder"
                     else "Encoded public output of the registered item",
            ))

    for folder_file, file_id, note in (
        ("metadata_sources.csv", f"manifest_{folder}",
         "Ancillary legacy metadata view; not read by the active pilot"),
        ("pipeline_files.csv", f"file_registry_{folder}",
         "Authoritative paper-folder file registry"),
        ("file_dependencies.csv", f"file_dependencies_{folder}",
         "Authoritative paper-folder file dependency table"),
    ):
        add(dict(
            file_id=file_id, path=f"{folder}/{folder_file}", item_id="",
            file_role="manifest", content_role="pipeline_resource_registry",
            record_grain="file", creation_mode="manual_curated", stage="registry",
            authority_status="project_inventory", producer_id="",
            lifecycle_status="ancillary" if folder_file == "metadata_sources.csv" else "active",
            note=note,
        ))

    for file_id, basename, role, content, grain, mode, stage, authority, lifecycle, note in \
            ANCILLARY_PAPER_FILES.get(folder, ()):
        add(dict(
            file_id=file_id, path=f"{folder}/{basename}", item_id="",
            file_role=role, content_role=content, record_grain=grain,
            creation_mode=mode, stage=stage,
            authority_status=authority, producer_id="",
            lifecycle_status=lifecycle, note=note,
        ))

    for source in legacy:
        if not source["builder_r"]:
            continue
        row = by_path[source["path"]]
        builder = by_path.get(source["builder_r"])
        if builder is None:
            raise ValueError(f"{folder}: listed builder is not registered: {source['builder_r']}")
        row["producer_id"] = builder["file_id"]
    for row in rows:
        if row["file_role"] == "public_tsv":
            builder = next(x for x in rows if x["item_id"] == row["item_id"]
                           and x["file_role"] == "item_builder")
            row["producer_id"] = builder["file_id"]
        if row["file_role"] == "snapshot":
            item_id = row["item_id"]
            if item_id in SNAPSHOT_WRITERS:
                writer_path = SNAPSHOT_WRITERS[item_id]
                if writer_path not in by_path:
                    raise ValueError(f"{folder}: documented snapshot writer missing: {writer_path}")
                row["creation_mode"] = "generated"
                row["producer_id"] = by_path[writer_path]["file_id"]
            elif item_id in TRANSCRIBED_SNAPSHOTS:
                row["creation_mode"] = "transcribed"
            elif item_id in COPIED_SNAPSHOTS:
                row["creation_mode"] = "copied"

    deps: list[dict[str, str]] = []
    for row in rows:
        if row["producer_id"]:
            deps.append(dict(output_file_id=row["file_id"],
                             input_file_id=row["producer_id"], relation="produced_by",
                             source_locator="", note="Producer declared in file registry"))
        if row["file_role"] == "public_tsv":
            local_csv = next(x for x in rows if x["item_id"] == row["item_id"]
                             and x["file_role"] == "item_csv")
            deps.append(dict(output_file_id=row["file_id"],
                             input_file_id=local_csv["file_id"], relation="exported_from",
                             source_locator="", note="Same registered item build"))
        if row["file_role"] == "snapshot" and row["item_id"] in SNAPSHOT_SOURCE_FILES:
            source_path = SNAPSHOT_SOURCE_FILES[row["item_id"]]
            if source_path not in by_path:
                raise ValueError(f"{folder}: documented snapshot input missing: {source_path}")
            deps.append(dict(output_file_id=row["file_id"],
                             input_file_id=by_path[source_path]["file_id"],
                             relation="derived_from", source_locator="",
                             note="Source named in the inspected snapshot writer"))
        if row["file_role"] == "snapshot" and row["item_id"] in COPIED_SNAPSHOTS:
            source_path = COPIED_SNAPSHOTS[row["item_id"]]
            if source_path not in by_path:
                raise ValueError(f"{folder}: documented byte-copy source missing: {source_path}")
            deps.append(dict(output_file_id=row["file_id"],
                             input_file_id=by_path[source_path]["file_id"],
                             relation="copied_from", source_locator="",
                             note="README documents byte-identical source copy"))
        if row["file_role"] == "snapshot" and row["item_id"] in TRANSCRIBED_SNAPSHOTS:
            papers = [x for x in rows if x["file_role"] == "source_document"
                      and x["content_role"] == "publication_evidence"]
            if len(papers) == 1:
                deps.append(dict(output_file_id=row["file_id"],
                                 input_file_id=papers[0]["file_id"],
                                 relation="transcribed_from", source_locator="",
                                 note="Item README documents manual paper transcription"))
    write_csv(target_files, FILE_COLUMNS, rows)
    write_csv(target_deps, DEPENDENCY_COLUMNS, deps)
    return len(rows), len(deps)


def registry_items() -> dict[str, str]:
    sheet = load_workbook(ROOT / "__ReadMe.xlsx", read_only=True, data_only=True)["Sheet1"]
    values = sheet.values
    header = list(next(values))
    item_col, encoded_col = header.index("Item name"), header.index("Item encoded")
    items: dict[str, str] = {}
    for row in values:
        item, encoded = row[item_col], row[encoded_col]
        if not isinstance(item, str) or not any(item.startswith(f + "_") for f in FOLDERS):
            continue
        if item in items or not isinstance(encoded, str) or not encoded:
            raise ValueError(f"Duplicate or incomplete pilot registry item: {item}")
        items[item] = encoded
    return items


def derive_legacy(files: list[dict[str, str]]) -> list[dict[str, str]]:
    by_id = {row["file_id"]: row for row in files}
    by_item_role = {(row["item_id"], row["file_role"]): row for row in files
                    if row["item_id"] and row["file_role"] in {"item_builder", "public_tsv"}}
    output = []
    for row in files:
        if row["lifecycle_status"] != "active":
            continue
        role = row["file_role"]
        if role == "item_csv":
            builder = by_item_role[(row["item_id"], "item_builder")]
            public = by_item_role[(row["item_id"], "public_tsv")]
            source_class = "registered_matrix"
            builder_r = builder["path"]
            public_path = public["path"]
            registered_item_id = row["item_id"]
            related_item_id = ""
        elif role in MATRIX_ROLES | OTHER_ROLES:
            source_class = "unregistered_matrix" if role in MATRIX_ROLES else "unregistered_other"
            producer = by_id.get(row["producer_id"])
            # The old `builder_r` field was sparsely populated for supporting
            # tables and omitted snapshot writers even when a writer exists.
            # Preserve that compatibility shape; the new producer_id carries
            # the fuller provenance for snapshots.
            builder_r = producer["path"] if producer and role != "snapshot" else ""
            public_path = registered_item_id = ""
            related_item_id = row["item_id"]
        else:
            continue
        output.append(dict(
            resource_id=row["file_id"], source_class=source_class, path=row["path"],
            registered_item_id=registered_item_id, builder_r=builder_r,
            public_tsv_path=public_path, content_role=row["content_role"],
            record_grain=row["record_grain"], authority_status=row["authority_status"],
            related_item_id=related_item_id, note=row["note"],
        ))
    return output


def compare_legacy(folder: str, derived: list[dict[str, str]]) -> tuple[int, int]:
    original = read_csv(ROOT / folder / "metadata_sources.csv", LEGACY_COLUMNS)
    by_path = {row["path"]: row for row in original}
    new_by_path = {row["path"]: row for row in derived}
    if set(by_path) != set(new_by_path):
        missing = sorted(set(by_path) - set(new_by_path))
        extra = sorted(set(new_by_path) - set(by_path))
        raise ValueError(f"{folder}: legacy resource path mismatch: missing={missing}, extra={extra}")
    fields = [name for name in LEGACY_COLUMNS if name not in {"resource_id"}]
    mismatches = [(path, name, by_path[path][name], new_by_path[path][name])
                  for path in by_path for name in fields
                  if by_path[path][name] != new_by_path[path][name]]
    if mismatches:
        raise ValueError(f"{folder}: round-trip metadata mismatch: {mismatches[:5]}")
    migrated_ids = sum(by_path[path]["resource_id"] != new_by_path[path]["resource_id"]
                       for path in by_path)
    return len(original), migrated_ids


def validate() -> tuple[list[dict[str, str]], list[dict[str, str]]]:
    all_files: list[dict[str, str]] = []
    all_deps: list[dict[str, str]] = []
    legacy_total = id_migrations = 0
    for folder in FOLDERS:
        files = read_csv(ROOT / folder / "pipeline_files.csv", FILE_COLUMNS)
        deps = read_csv(ROOT / folder / "file_dependencies.csv", DEPENDENCY_COLUMNS)
        folder_ids = {row["file_id"] for row in files}
        if len(folder_ids) != len(files):
            raise ValueError(f"{folder}: duplicate file_id")
        for row in files:
            path = row["path"]
            if not path.startswith(folder + "/") and row["file_role"] != "public_tsv":
                raise ValueError(f"{folder}: nonlocal paper file {path}")
            if ".." in Path(path).parts or Path(path).is_absolute() or not (ROOT / path).is_file():
                raise ValueError(f"{folder}: missing or unsafe path {path}")
        for path in (ROOT / folder).rglob("*"):
            if path.is_file() and not any(
                part.startswith(".") or part == "__pycache__"
                for part in path.relative_to(ROOT / folder).parts
            ):
                relative = path.relative_to(ROOT).as_posix()
                if relative not in {row["path"] for row in files}:
                    raise ValueError(f"{folder}: unregistered non-hidden file {relative}")
        n, m = compare_legacy(folder, derive_legacy(files))
        legacy_total += n
        id_migrations += m
        all_files.extend(files)
        all_deps.extend(deps)
    file_ids = [row["file_id"] for row in all_files]
    paths = [row["path"] for row in all_files]
    if len(file_ids) != len(set(file_ids)) or len(paths) != len(set(paths)):
        raise ValueError("Duplicate file ID or path across paper registries")
    by_id = {row["file_id"]: row for row in all_files}
    shared_path = HERE / "shared_pipeline_files.csv"
    if shared_path.exists():
        for row in read_csv(shared_path, FILE_COLUMNS):
            if row["file_id"] in by_id:
                raise ValueError(f"Shared/paper file ID collision: {row['file_id']}")
            by_id[row["file_id"]] = row
    roles = {row["content_role"] for row in read_csv(HERE / "content_role_vocabulary.csv")}
    statuses = {row["authority_status"] for row in read_csv(HERE / "authority_status_vocabulary.csv")}
    items = registry_items()
    for row in all_files:
        if row["file_role"] not in FILE_ROLES or row["creation_mode"] not in CREATION_MODES:
            raise ValueError(f"Invalid file_role or creation_mode: {row}")
        if (row["stage"] not in STAGES or row["lifecycle_status"] not in LIFECYCLE
                or row["content_role"] not in roles or row["authority_status"] not in statuses):
            raise ValueError(f"Invalid stage, lifecycle, role, or authority: {row}")
        if row["item_id"] and row["item_id"] not in items:
            raise ValueError(f"File has unregistered item_id: {row['path']}")
        if row["creation_mode"] == "generated" and not row["producer_id"]:
            raise ValueError(f"Generated paper file lacks a producer: {row['path']}")
        if row["producer_id"]:
            producer = by_id.get(row["producer_id"])
            if producer is None or producer["file_role"] not in {"item_builder", "support_script", "pipeline_script"}:
                raise ValueError(f"Invalid producer_id for {row['path']}")
    for item_id, encoded in items.items():
        for role, expected in (
            ("item_builder", f"{item_id}.R"), ("item_csv", f"{item_id}.csv"),
            ("public_tsv", f"{encoded}.tsv"),
        ):
            matches = [row for row in all_files if row["item_id"] == item_id
                       and row["file_role"] == role]
            if len(matches) != 1 or Path(matches[0]["path"]).name != expected:
                raise ValueError(f"{item_id}: expected one {role} named {expected}")
        csv_row = next(row for row in all_files if row["item_id"] == item_id
                       and row["file_role"] == "item_csv")
        public = next(row for row in all_files if row["item_id"] == item_id
                      and row["file_role"] == "public_tsv")
        builder = next(row for row in all_files if row["item_id"] == item_id
                       and row["file_role"] == "item_builder")
        if csv_row["producer_id"] != builder["file_id"] or public["producer_id"] != builder["file_id"]:
            raise ValueError(f"{item_id}: CSV/TSV producer does not match registered item builder")
        if public["path"] != f"__Public/comparative-data/{encoded}.tsv":
            raise ValueError(f"{item_id}: public TSV path differs from live registry")
    for dep in all_deps:
        if (dep["output_file_id"] not in by_id or dep["input_file_id"] not in by_id
                or dep["output_file_id"] == dep["input_file_id"]
                or dep["relation"] not in DEPENDENCY_RELATIONS):
            raise ValueError(f"Invalid file dependency: {dep}")
    if len(all_deps) != len({(d["output_file_id"], d["input_file_id"], d["relation"])
                            for d in all_deps}):
        raise ValueError("Duplicate file dependency")

    print(f"Paper file registry: {len(all_files)} files, {len(all_deps)} dependencies, "
          f"{len(items)} registered items, {legacy_total} legacy source rows round-tripped, "
          f"{id_migrations} intentional ID migrations, no missing file/producer/dependency IDs")
    return all_files, all_deps


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("command", nargs="?", choices=("seed", "validate", "derive-legacy"),
                        default="validate")
    parser.add_argument("--force", action="store_true", help="overwrite generated migration output")
    args = parser.parse_args()
    if args.command == "seed":
        artifacts = artifact_ids()
        counts = [seed_folder(folder, artifacts, args.force) for folder in FOLDERS]
        print(f"Seeded {sum(n for n, _ in counts)} paper file rows and "
              f"{sum(n for _, n in counts)} dependency rows")
        validate()
    elif args.command == "derive-legacy":
        for folder in FOLDERS:
            files = read_csv(ROOT / folder / "pipeline_files.csv", FILE_COLUMNS)
            rows = derive_legacy(files)
            if args.force:
                write_csv(ROOT / folder / "metadata_sources.csv", LEGACY_COLUMNS, rows)
            else:
                compare_legacy(folder, rows)
        print("Legacy metadata_sources views are derivable; use --force to write them")
    else:
        validate()


if __name__ == "__main__":
    main()
