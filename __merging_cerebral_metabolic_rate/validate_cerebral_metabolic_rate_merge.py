#!/usr/bin/env python3
"""Regression checks for the source-aware cerebral metabolic-rate merge."""

import csv
import glob
import math
import os
import re
import zipfile
from collections import defaultdict
from pathlib import Path
from xml.etree import ElementTree


HERE = Path(__file__).resolve().parent
BASE = HERE.parent
XLSX_NS = {"m": "http://schemas.openxmlformats.org/spreadsheetml/2006/main"}
NUMBER_LEXEME = re.compile(r"[−-]?(?:\d+(?:[.,]\d+)?|[.,]\d+)")
KAUF_REPAIRED_PRINTED = {
    "Kaufman__2004:TableA1:60:CBF": ("86.0", "7.3"),
    "Kaufman__2004:TableA1:120:CMRgl": ("73.4", "5.2"),
    "Kaufman__2004:TableA3:52:CMRO2": ("245.0", "34.0"),
    "Kaufman__2004:TableA3:52:CBF": ("70.5", "15.0"),
    "Kaufman__2004:TableA3:59:CBF": ("76.8", "4.5"),
    "Kaufman__2004:TableA3:60:CBF": ("46.2", "3.0"),
    "Kaufman__2004:TableA3:61:CBF": ("59.0", "5.5"),
    "Kaufman__2004:TableA3:69:CBF": ("139.5", "22.0"),
    "Kaufman__2004:TableA6:67:CMRO2": ("342.0", "20.1"),
    "Kaufman__2004:TableA6:67:CBF": ("108.2", "6.3"),
    "Kaufman__2004:TableA6:68:CMRO2": ("171.9", "7.6"),
    "Kaufman__2004:TableA6:68:CBF": ("68.4", "3.5"),
    "Kaufman__2004:TableA6:69:CMRO2": ("162.5", "19.2"),
    "Kaufman__2004:TableA6:69:CBF": ("77.7", "8.7"),
    "Kaufman__2004:TableA6:71:CBF": ("55.0", "12.0"),
    "Kaufman__2004:TableA6:72:CBF": ("69.0", "23.0"),
    "Kaufman__2004:TableA6:73:CBF": ("41.0", "16.0"),
    "Kaufman__2004:TableA11:75:CMRgl": ("92.0", "17.9"),
    "Kaufman__2004:TableA11:99:CMRgl": ("83.3", "10.0"),
    "Kaufman__2004:TableA13:13:CMRO2": ("185.0", "27.2"),
    "Kaufman__2004:TableA13:14:CMRO2": ("111.6", "31.9"),
    "Kaufman__2004:TableA13:15:CMRO2": ("155.8", "21.1"),
    "Kaufman__2004:TableA14:84:CMRgl": ("27.67", "3.99"),
    "Kaufman__2004:TableA14:84:CMRO2": ("167.40", "53.00"),
    "Kaufman__2004:TableA14:84:CBF": ("45.60", "7.20"),
    "Kaufman__2004:TableA14:110:CMRO2": ("218.75", ".20"),
    "Kaufman__2004:TableA14:194:CMRO2": ("192.40", "16.10"),
    "Kaufman__2004:TableA14:194:CBF": ("77.00", "7.00"),
    "Kaufman__2004:TableA14:195:CMRO2": ("154.46", "4.50"),
}
KAUF_SOKOLOFF_PRINTED = {
    "Kaufman__2004:TableA1:109:CMRgl": ("84.5", "2.5"),
    "Kaufman__2004:TableA2:69:CMRgl": ("79.0", "1.0"),
    "Kaufman__2004:TableA3:111:CMRgl": ("104.0", "2.0"),
    "Kaufman__2004:TableA4:77:CMRgl": ("61.0", "2.0"),
    "Kaufman__2004:TableA5:73:CMRgl": ("36.0", "2.0"),
    "Kaufman__2004:TableA6:130:CMRgl": ("124.4", "3.6"),
    "Kaufman__2004:TableA7:109:CMRgl": ("112.0", "4.0"),
    "Kaufman__2004:TableA8:97:CMRgl": ("110.0", "3.0"),
    "Kaufman__2004:TableA10:39:CMRgl": ("163.0", "4.0"),
    "Kaufman__2004:TableA11:103:CMRgl": ("113.0", "4.0"),
    "Kaufman__2004:TableA12:64:CMRgl": ("124.00", "3.00"),
}


def read(name):
    with (HERE / name).open(newline="", encoding="utf-8-sig") as handle:
        return list(csv.DictReader(handle))


def source_refs(pattern, field, multi=False):
    values = set()
    for filename in glob.glob(str(BASE / pattern)):
        if not re.search(r"Table[AS](?:[1-9]|1\d|2[0-3])\.csv$", filename):
            continue
        with open(filename, newline="", encoding="utf-8-sig") as handle:
            for row in csv.DictReader(handle):
                raw = (row.get(field) or "").strip()
                if not raw or re.fullmatch(r"N=\d+", raw):
                    continue
                values.update(part.strip() for part in raw.split(";") if part.strip()) if multi else values.add(raw)
    return values


def source_rows(path):
    with path.open(newline="", encoding="utf-8-sig") as handle:
        return list(csv.DictReader(handle))


def karbowski_snapshot_cells():
    """Read exact inline strings from the frozen xlsx using only stdlib XML."""
    path = BASE / "Karbowski__2007/Karbowski__2007_TablesS1-S23_snapshot.xlsx"
    sheets = {}
    with zipfile.ZipFile(path) as archive:
        for number in range(1, 24):
            root = ElementTree.fromstring(
                archive.read(f"xl/worksheets/sheet{number}.xml")
            )
            cells = {}
            for cell in root.findall(".//m:c", XLSX_NS):
                coordinate = cell.attrib["r"]
                if cell.attrib.get("t") == "inlineStr":
                    value = "".join(
                        text.text or "" for text in cell.findall(".//m:t", XLSX_NS)
                    )
                else:
                    node = cell.find("m:v", XLSX_NS)
                    value = "" if node is None else node.text or ""
                cells[coordinate] = value
            sheets[f"TableS{number}"] = cells
    return sheets


def number_lexemes(value):
    return NUMBER_LEXEME.findall(value or "")


def lexeme_float(value):
    return float(value.replace("−", "-").replace(",", "."))


def normalized_space(value):
    return " ".join((value or "").split())


def mean(values):
    return math.fsum(values) / len(values)


def round3(value):
    """Mirror the builder's half-away-from-zero, three-decimal rule."""
    printed = f"{value:.9f}"
    negative = printed.startswith("-")
    integer, fraction = printed.lstrip("-").split(".")
    scaled = int(integer) * 10**9 + int(fraction)
    rounded = ((scaled + 500_000) // 1_000_000) / 1000.0
    return -rounded if negative else rounded


def validate_raw_value_round_trip(unfiltered):
    """Raw value/SD fields must reproduce the authoritative printed strings."""
    kauf_columns = {
        "CMRgl": ("CMRgl_umol_100g_min", "CMRgl_SD", "Glucose", "Glucose_SD"),
        "CMRO2": ("CMRO2_umol_100g_min", "CMRO2_SD", "Oxygen", "Oxygen_SD"),
        "CBF": ("CBF_ml_100g_min", "CBF_SD", "BloodFlow", "BloodFlow_SD"),
    }
    cache = {}
    karb_snapshot = karbowski_snapshot_cells()
    karb_printed = {}
    for row in unfiltered:
        compilation = row["Compilation"]
        table = row["Table"]
        source_row = int(row["source_row"])
        if compilation == "Kaufman__2004":
            path = BASE / "Kaufman__2004" / f"Kaufman__2004_{table}.csv"
            value_column, sd_column, printed_value_column, printed_sd_column = kauf_columns[row["Measure"]]
            snapshot_path = path.with_name(path.stem + "_snapshot.csv")
        elif compilation == "Karbowski__2007":
            path = BASE / "Karbowski__2007" / f"Karbowski__2007_{table}.csv"
            value_column, sd_column = "value_printed", "sd_printed"
        elif compilation == "Heiss_etal_2004":
            path = BASE / "Heiss_etal_2004" / "Heiss_etal_2004_TABLE1.csv"
            value_column, sd_column = "Both hemispheres Mean", "Both hemispheres SD"
        else:
            raise AssertionError(f"Unexpected compilation {compilation}")
        if path not in cache:
            cache[path] = source_rows(path)
        source = cache[path][source_row - 1]
        if compilation == "Kaufman__2004" and row["record_id"] in KAUF_REPAIRED_PRINTED:
            expected_value, expected_sd = KAUF_REPAIRED_PRINTED[row["record_id"]]
            assert row["Value_raw"] == expected_value
            assert row["SD_raw"] == expected_sd
            assert math.isclose(float(source[value_column]), float(expected_value), abs_tol=1e-9)
            assert math.isclose(float(source[sd_column]), float(expected_sd), abs_tol=1e-9)
        elif compilation == "Kaufman__2004" and row["record_id"] in KAUF_SOKOLOFF_PRINTED:
            expected_value, expected_sd = KAUF_SOKOLOFF_PRINTED[row["record_id"]]
            assert row["Value_raw"] == expected_value and row["SD_raw"] == expected_sd
            assert math.isclose(float(source[value_column]), float(expected_value), abs_tol=1e-9)
            assert math.isclose(float(source[sd_column]), float(expected_sd), abs_tol=1e-9)
        elif compilation == "Kaufman__2004" and not row["source_correction"].startswith(
            "Repaired column-shifted Sokoloff"
        ):
            if snapshot_path not in cache:
                cache[snapshot_path] = source_rows(snapshot_path)
            snapshot_row = int(row["source_snapshot_row"])
            printed = cache[snapshot_path][snapshot_row - 1]
            assert row["Value_raw"] == (printed.get(printed_value_column) or "")
            assert row["SD_raw"] == (printed.get(printed_sd_column) or "")
        elif compilation == "Karbowski__2007":
            snapshot_row = int(row["source_snapshot_row"])
            assert snapshot_row == int(source["source_snapshot_row"])
            cells = karb_snapshot[table]
            physical_row = snapshot_row + 2
            assert normalized_space(source["species_printed"]) == normalized_space(
                cells[f"A{physical_row}"]
            )
            value_column_letter = "C" if row["Measure"].startswith("Total_") else "B"
            lexemes = number_lexemes(cells[f"{value_column_letter}{physical_row}"])
            # The xlsx validates the numeric carrier and exact row. The journal PDF
            # is authoritative for display precision: S1 has three decimal places,
            # while S2-S23 have two.
            digits = 3 if table == "TableS1" else 2
            expected_value = f"{lexeme_float(lexemes[0]):.{digits}f}"
            expected_sd = (
                "" if row["Measure"].startswith("Total_") or len(lexemes) < 2
                else f"{lexeme_float(lexemes[1]):.{digits}f}"
            )
            assert row["Value_raw"] == (source.get(value_column) or "") == expected_value, (
                row["record_id"], row["Value_raw"], source.get(value_column), expected_value
            )
            assert row["SD_raw"] == (source.get(sd_column) or "") == expected_sd, (
                row["record_id"], row["SD_raw"], source.get(sd_column), expected_sd
            )
            karb_printed[(table, snapshot_row, row["Measure"])] = (
                row["Value_raw"], row["SD_raw"]
            )
        else:
            assert row["Value_raw"] == (source.get(value_column) or "")
            assert row["SD_raw"] == (source.get(sd_column) or "")

    # Sentinels cover zeros that are not recoverable from numeric cell values alone.
    assert karb_printed[("TableS1", 4, "CMRO2")] == ("0.060", "0.005")
    assert karb_printed[("TableS1", 4, "Total_O2_consumption")] == ("6.000", "")
    assert karb_printed[("TableS3", 5, "CMRgl")] == ("1.00", "0.10")
    assert karb_printed[("TableS9", 1, "CMRgl")][0] == "1.00"
    assert karb_printed[("TableS23", 9, "CMRgl")][1] == "0.00"


def validate_reconciliation(unfiltered, merged, dedupe, registry, wide):
    """Independently recompute compiler deduplication and final cell means."""
    canonical = {
        row["primary_reference_id"]: row["primary_reference_citation"]
        for row in registry
    }
    reports_by_key = defaultdict(list)
    for row in unfiltered:
        if row["include_in_primary_merge"] != "True":
            continue
        primary_ids = row["primary_reference_ids"].split("; ")
        assert len(primary_ids) == 1
        key = (
            row["Species"], row["Region"], row["Measure"], row["Units"],
            row["measure_class"], row["condition_group"], primary_ids[0],
            row["Compilation"],
        )
        reports_by_key[key].append(float(row["Value"]))

    study_reports = []
    for key, values in reports_by_key.items():
        (species, region, measure, units, measure_class, condition_group, primary_id,
         compilation) = key
        study_reports.append({
            "Species": species,
            "Region": region,
            "Measure": measure,
            "Units": units,
            "measure_class": measure_class,
            "condition_group": condition_group,
            "primary_reference_id": primary_id,
            "Compilation": compilation,
            "Value": mean(values),
        })

    reports_by_primary_cell = defaultdict(list)
    reporting_by_primary_cell = defaultdict(set)
    for index, row in enumerate(study_reports):
        key = (
            row["Species"], row["Region"], row["Measure"], row["Units"],
            row["measure_class"], row["condition_group"],
            row["primary_reference_id"],
        )
        reports_by_primary_cell[key].append(index)
        reporting_by_primary_cell[key].add(row["Compilation"])

    priority = {"Heiss_etal_2004": 0, "Kaufman__2004": 1, "Karbowski__2007": 2}
    dropped_indices = set()
    expected_dedupe = {}
    for key, indices in reports_by_primary_cell.items():
        compilations = {study_reports[index]["Compilation"] for index in indices}
        if len(compilations) < 2:
            continue
        kept = min(compilations, key=lambda name: priority.get(name, 99))
        dropped = sorted(compilations - {kept})
        for index in indices:
            if study_reports[index]["Compilation"] != kept:
                dropped_indices.add(index)
        values_by_compilation = {
            study_reports[index]["Compilation"]: study_reports[index]["Value"]
            for index in indices
        }
        kaufman = values_by_compilation.get("Kaufman__2004")
        karbowski = values_by_compilation.get("Karbowski__2007")
        expected_dedupe[key] = {
            "reported_by_compilations": "; ".join(sorted(compilations)),
            "kept_compilation": kept,
            "dropped_compilations": "; ".join(dropped),
            "Kaufman_value_standardized": None if kaufman is None else round3(kaufman),
            "Karbowski_value_standardized": None if karbowski is None else round3(karbowski),
            "absolute_difference": (
                None if kaufman is None or karbowski is None
                else round3(abs(karbowski - kaufman))
            ),
        }

    actual_dedupe = {
        (
            row["Species"], row["Region"], row["Measure"], row["Units"],
            row["measure_class"], row["condition_group"], row["primary_reference_id"],
        ): row
        for row in dedupe
    }
    assert set(actual_dedupe) == set(expected_dedupe)
    for key, expected in expected_dedupe.items():
        actual = actual_dedupe[key]
        assert actual["primary_reference_citation"] == canonical[key[6]]
        for field in (
            "reported_by_compilations", "kept_compilation", "dropped_compilations",
        ):
            assert actual[field] == expected[field]
        for field in (
            "Kaufman_value_standardized", "Karbowski_value_standardized",
            "absolute_difference",
        ):
            if expected[field] is None:
                assert actual[field] == ""
            else:
                assert math.isclose(float(actual[field]), expected[field], abs_tol=1e-12)

    retained = [
        row for index, row in enumerate(study_reports) if index not in dropped_indices
    ]
    cells = defaultdict(lambda: {"values": [], "ids": set(), "used": set(), "reported": set()})
    for row in retained:
        key = (
            row["Species"], row["Region"], row["Measure"], row["Units"],
            row["measure_class"],
        )
        cell = cells[key]
        cell["values"].append(row["Value"])
        cell["ids"].add(row["primary_reference_id"])
        cell["used"].add(row["Compilation"])
        primary_cell = (
            row["Species"], row["Region"], row["Measure"], row["Units"],
            row["measure_class"], row["condition_group"],
            row["primary_reference_id"],
        )
        cell["reported"] |= reporting_by_primary_cell[primary_cell]

    actual_merged = {
        (
            row["Species"], row["Region"], row["Measure"], row["Units"],
            row["measure_class"],
        ): row
        for row in merged
    }
    assert set(actual_merged) == set(cells)
    for key, cell in cells.items():
        actual = actual_merged[key]
        primary_ids = sorted(cell["ids"])
        expected_citations = " || ".join(canonical[primary_id] for primary_id in primary_ids)
        assert math.isclose(float(actual["Value"]), round3(mean(cell["values"])), abs_tol=1e-12)
        assert int(actual["n_studies"]) == int(actual["n_primary_references"]) == len(primary_ids)
        assert actual["Primary_reference_ids"] == "; ".join(primary_ids)
        assert actual["Primary_references"] == expected_citations
        assert actual["Compilations"] == actual["Compilations_reporting"] == "; ".join(
            sorted(cell["reported"])
        )
        assert actual["Compilations_used"] == "; ".join(sorted(cell["used"]))

    expected_wide = {
        (row["Species"], f'{row["Region"]}__{row["Measure"]}'): float(row["Value"])
        for row in merged
    }
    actual_wide = {}
    for row in wide:
        species = row["Species"]
        for column, value in row.items():
            if column == "Species" or value in ("", "NA"):
                continue
            actual_wide[(species, column)] = float(value)
    assert actual_wide == expected_wide


def check():
    unfiltered = read("cerebral_metabolic_rate_unfiltered.csv")
    merged = read("cerebral_metabolic_rate_long.csv")
    dedupe = read("cerebral_metabolic_rate_dedupe_report.csv")
    registry = read("cerebral_metabolic_rate_primary_references.csv")
    cited_registry = read("cerebral_metabolic_rate_cited_references.csv")
    links = read("cerebral_metabolic_rate_value_reference_links.csv")
    issues = read("cerebral_metabolic_rate_reference_resolution_issues.csv")
    arm_report = read("cerebral_metabolic_rate_arm_ambiguity_report.csv")
    wide = read("cerebral_metabolic_rate_wide.csv")
    shiny_path = BASE / "__ShinyApp/data/cerebral_metabolic_rate_long.csv"
    shiny_copy = source_rows(shiny_path) if shiny_path.exists() else None

    assert len(unfiltered) == 2161
    assert sum(row["include_in_primary_merge"] == "True" for row in unfiltered) == 1444
    assert len(merged) == 235
    assert len(dedupe) == 44
    assert len(registry) == 335
    assert len(cited_registry) == 339
    assert len(links) == 2361
    assert len(issues) == 5
    assert len(arm_report) == 77
    if shiny_copy is not None:
        assert shiny_copy == merged
    else:
        # Current main serves the canonical merge directly from GitHub.
        assert '"__merging_cerebral_metabolic_rate/cerebral_metabolic_rate_long.csv"' in (BASE / "__ShinyApp/app.R").read_text()
    assert {(row["compilation"], row["issue_type"]) for row in issues} == {
        ("Kaufman__2004", "unresolved_missing_bibliography"),
        ("Kaufman__2004", "secondary_source_without_primary_lineage"),
        ("Karbowski__2007", "secondary_source_without_primary_lineage"),
    }
    validate_raw_value_round_trip(unfiltered)
    validate_reconciliation(unfiltered, merged, dedupe, registry, wide)

    assert not any(float(row["Value"]) == 1977 for row in unfiltered)
    assert sum(bool(row["source_correction"]) for row in unfiltered) == 43
    expected_sokoloff = {
        "Kaufman__2004:TableA1:109:CMRgl": (84.5, 2.5, "Sokoloff"),
        "Kaufman__2004:TableA2:69:CMRgl": (79.0, 1.0, "Sokoloff"),
        "Kaufman__2004:TableA3:111:CMRgl": (104.0, 2.0, "Sokoloff"),
        "Kaufman__2004:TableA4:77:CMRgl": (61.0, 2.0, "Sokoloff"),
        "Kaufman__2004:TableA5:73:CMRgl": (36.0, 2.0, "Sokoloff"),
        "Kaufman__2004:TableA6:130:CMRgl": (124.4, 3.6, "Sokoloff"),
        "Kaufman__2004:TableA7:109:CMRgl": (112.0, 4.0, "Sokoloff"),
        "Kaufman__2004:TableA8:97:CMRgl": (110.0, 3.0, "Sokoloff"),
        "Kaufman__2004:TableA10:39:CMRgl": (163.0, 4.0, "Sokoloff"),
        "Kaufman__2004:TableA11:103:CMRgl": (113.0, 4.0, "Sokoloff"),
        "Kaufman__2004:TableA12:64:CMRgl": (124.0, 3.0, "PET"),
    }
    expected_sokoloff_snapshot = {
        "TableA1": (109, "84.5", "2.5"),
        "TableA2": (69, "79.0", "1.0"),
        "TableA3": (111, "104.0", "2.0"),
        "TableA4": (77, "61.0", "2.0"),
        "TableA5": (73, "36.0", "2.0"),
        "TableA6": (130, "124.4", "3.6"),
        "TableA7": (109, "", ""),
        "TableA8": (97, "110.0", "3.0"),
        "TableA10": (39, "", ""),
        "TableA11": (103, "", ""),
        "TableA12": (64, "", ""),
    }
    frozen_common = {
        "Species": "Rattus", "Reference": "(", "n": "", "Anesthesia": "",
        "Mode": "Sokoloff", "Glucose": "1977", "Glucose_SD": "10",
        "BloodFlow": "", "BloodFlow_SD": "",
    }
    for table, (source_row, oxygen, oxygen_sd) in expected_sokoloff_snapshot.items():
        frozen = source_rows(
            BASE / "Kaufman__2004" / f"Kaufman__2004_{table}_snapshot.csv"
        )[source_row - 1]
        expected = {**frozen_common, "Oxygen": oxygen, "Oxygen_SD": oxygen_sd}
        assert all((frozen.get(field) or "").strip() == value
                   for field, value in expected.items()), (table, source_row, frozen)
    expected_condition_repairs = {
        "Kaufman__2004:TableA7:101:CMRgl": (79.0, 9.7, 6, "moore_2000"),
        "Kaufman__2004:TableA10:5:CMRgl": (70.3, 12.2, 6, "schwartzman_1988"),
        "Kaufman__2004:TableA10:6:CMRgl": (79.0, 12.0, 3, "choki_1984"),
    }
    corrected = {row["record_id"]: row for row in unfiltered if row["source_correction"]}
    assert set(corrected) == (
        set(expected_sokoloff) | set(expected_condition_repairs)
        | set(KAUF_REPAIRED_PRINTED)
    )
    for record_id, (value, sd, mode) in expected_sokoloff.items():
        row = corrected[record_id]
        assert math.isclose(float(row["Value"]), value, abs_tol=1e-9)
        assert math.isclose(float(row["SD"]), sd, abs_tol=1e-9)
        assert float(row["n"]) == 10 and row["Mode"] == mode
        assert row["primary_reference_raw"] == "(Sokoloff et al., 1977)"
        assert row["primary_reference_ids"] == "sokoloff_1977"
        assert (row["Value_raw"], row["SD_raw"]) == KAUF_SOKOLOFF_PRINTED[record_id]
    for record_id, (value, sd, n, primary_id) in expected_condition_repairs.items():
        row = corrected[record_id]
        assert math.isclose(float(row["Value"]), value, abs_tol=1e-9)
        assert math.isclose(float(row["SD"]), sd, abs_tol=1e-9)
        assert int(float(row["n"])) == n
        assert row["conscious"] == "conscious" and row["Anesthesia_raw"] == "none"
        assert row["primary_reference_ids"] == primary_id
        assert row["source_correction"].startswith("Repaired OCR-shifted n/anesthesia")
    for record_id, (value_raw, sd_raw) in KAUF_REPAIRED_PRINTED.items():
        row = corrected[record_id]
        assert row["Value_raw"] == value_raw and row["SD_raw"] == sd_raw
        assert row["source_correction"].startswith(
            "Repaired PDF-extraction omitted/collapsed/misaligned"
        )
    assert not any(
        row["Table"] == "TableS11" and row["include_in_primary_merge"] == "True"
        for row in unfiltered
    )
    s11 = [row for row in unfiltered if row["Compilation"] == "Karbowski__2007"
           and row["Table"] == "TableS11"]
    assert len(s11) == 7
    assert all(not row["primary_reference_raw"] and int(float(row["n_areas"])) in {4, 6, 8}
               for row in s11)
    assert not any(
        row["include_in_primary_merge"] == "True"
        and row["source_granularity"] != "single_primary_reference"
        for row in unfiltered
    )
    assert not any(
        row["include_in_primary_merge"] == "True" and not row["primary_reference_ids"]
        for row in unfiltered
    )
    assert all(
        row["condition_group"] == "nonanesthetized_unspecified_arm"
        for row in unfiltered if row["include_in_primary_merge"] == "True"
    )
    quarantined_arms = [
        row for row in unfiltered
        if row["exclusion_reason"] == "ambiguous_within_primary_source_multiple_rows"
    ]
    assert len(quarantined_arms) == 157
    assert {row["Compilation"] for row in quarantined_arms} == {"Kaufman__2004"}
    assert all(
        row["include_in_primary_merge"] == "False"
        and row["arm_identity_status"] ==
        "ambiguous_multiple_rows_same_source_cell_condition_unit"
        and row["arm_ambiguity_group_id"]
        for row in quarantined_arms
    )
    quarantined_record_ids = {row["record_id"] for row in quarantined_arms}
    reported_record_ids = {
        record_id
        for row in arm_report
        for record_id in row["record_ids"].split("; ")
    }
    assert quarantined_record_ids == reported_record_ids
    assert sum(int(row["n_rows"]) for row in arm_report) == 157
    assert sum(int(row["n_distinct_standardized_values"]) > 1 for row in arm_report) == 75
    assert all(
        row["Compilation"] == "Kaufman__2004"
        and row["merge_action"] == "exclude_until_primary_study_arms_are_reconstructed"
        for row in arm_report
    )
    included_full_keys = [
        (
            row["Compilation"], row["Species"], row["Region"], row["Measure"],
            row["Units"], row["measure_class"], row["condition_group"],
            row["primary_reference_ids"],
        )
        for row in unfiltered if row["include_in_primary_merge"] == "True"
    ]
    assert len(included_full_keys) == len(set(included_full_keys))
    assert all(
        row["source_reference_levels"] == "primary"
        and row["primary_reference_ids"] == row["source_reference_ids"]
        for row in unfiltered if row["include_in_primary_merge"] == "True"
    )
    direct_secondary = [
        row for row in unfiltered
        if row["derivation_role"] == "reported_via_secondary_source"
    ]
    assert len(direct_secondary) == 25
    assert {row["source_reference_ids"] for row in direct_secondary} == {
        "dastur_1985", "clarke_1994", "sokoloff_1984", "madsen_1993"
    }
    assert {
        source_id: sum(row["source_reference_ids"] == source_id for row in direct_secondary)
        for source_id in {"dastur_1985", "clarke_1994", "sokoloff_1984", "madsen_1993"}
    } == {
        "dastur_1985": 3,
        "clarke_1994": 1,
        "sokoloff_1984": 19,
        "madsen_1993": 2,
    }
    assert all(
        row["source_reference_levels"] == "secondary"
        and not row["primary_reference_ids"]
        and row["include_in_primary_merge"] == "False"
        and row["exclusion_reason"] == "secondary_source_without_primary_lineage"
        for row in direct_secondary
    )
    kaufman_primary_species = {
        primary_id: {
            row["Species"] for row in unfiltered
            if row["Compilation"] == "Kaufman__2004"
            and row["primary_reference_ids"] == primary_id
        }
        for primary_id in ("kennedy_1978", "passero_1981")
    }
    assert kaufman_primary_species == {
        "kennedy_1978": {"Macaca mulatta"},
        "passero_1981": {"Oryctolagus cuniculus"},
    }
    assert sum(row["primary_reference_id"] == "kennedy_1978" for row in dedupe) == 3
    assert sum(row["primary_reference_id"] == "passero_1981" for row in dedupe) == 5
    karbowski = [row for row in unfiltered if row["Compilation"] == "Karbowski__2007"]
    karbowski_condition_overrides = [
        row for row in karbowski
        if row["condition_group"] != "nonanesthetized_unspecified_arm"
    ]
    assert len(karbowski_condition_overrides) == 35
    assert {
        source_id
        for row in karbowski_condition_overrides
        for source_id in row["source_reference_ids"].split("; ")
        if source_id in {
            "stingele_1996", "nakanishi_1997", "sahlin_1987", "meguro_1999",
            "haier_1992", "lydic_1991"
        }
    } == {
        "stingele_1996", "nakanishi_1997", "sahlin_1987", "meguro_1999",
        "haier_1992", "lydic_1991"
    }
    assert all(row["condition_evidence"] and "PDF p.8" not in row["condition_evidence"]
               for row in karbowski_condition_overrides)
    direct_condition_overrides = [
        row for row in karbowski_condition_overrides
        if row["derivation_role"] == "reported_via_secondary_compilation"
    ]
    assert len(direct_condition_overrides) == 22
    assert all(
        row["include_in_primary_merge"] == "False"
        and row["exclusion_reason"] ==
        "primary_source_condition_conflicts_with_compilation_claim"
        for row in direct_condition_overrides
    )
    assert sum(row["condition_group"] == "anesthetized" for row in direct_condition_overrides) == 15
    assert sum(row["condition_group"] == "awake_task_active" for row in direct_condition_overrides) == 4
    assert sum(row["condition_group"] == "condition_arm_unresolved"
               for row in direct_condition_overrides) == 3
    assert {
        row["record_id"] for row in direct_condition_overrides
        if row["condition_group"] == "condition_arm_unresolved"
    } == {
        "Karbowski__2007:TableS16:10:CMRgl",
        "Karbowski__2007:TableS9:4:CMRgl",
        "Karbowski__2007:TableS7:12:CMRgl",
    }
    assert all(
        "PMID 2013648" in row["condition_evidence"]
        for row in direct_condition_overrides
        if row["condition_group"] == "condition_arm_unresolved"
    )
    assert {
        row["record_id"] for row in direct_condition_overrides
        if row["condition_group"] == "awake_task_active"
    } == {
        "Karbowski__2007:TableS5:14:CMRgl",
        "Karbowski__2007:TableS7:21:CMRgl",
        "Karbowski__2007:TableS9:10:CMRgl",
        "Karbowski__2007:TableS10:11:CMRgl",
    }
    inherited_condition_overrides = [
        row for row in karbowski_condition_overrides
        if row["derivation_role"] in {"compiler_average", "derived_cross_area_summary"}
    ]
    assert len(inherited_condition_overrides) == 9
    assert all(row["condition_evidence"].startswith("Inherited component lineage:")
               for row in inherited_condition_overrides)
    assert not any(
        row["condition_group"] == "nonanesthetized_unspecified_arm"
        and set(row["source_reference_ids"].split("; "))
        & {
            "stingele_1996", "nakanishi_1997", "sahlin_1987", "meguro_1999",
            "haier_1992", "lydic_1991"
        }
        for row in karbowski
    )
    verified_direct_conditions = [
        row for row in karbowski
        if row["derivation_role"] == "reported_via_secondary_compilation"
        and row["source_reference_ids"] in {
            "passero_1981", "maquet_1992", "schwartzman_1986"
        }
    ]
    assert len(verified_direct_conditions) == 32
    assert {
        source_id: sum(row["source_reference_ids"] == source_id
                       for row in verified_direct_conditions)
        for source_id in {"passero_1981", "maquet_1992", "schwartzman_1986"}
    } == {"passero_1981": 17, "maquet_1992": 7, "schwartzman_1986": 8}
    assert {
        row["record_id"] for row in verified_direct_conditions
        if row["source_reference_ids"] == "passero_1981"
    } == {
        "Karbowski__2007:TableS17:8:CMRgl",
        "Karbowski__2007:TableS23:14:CMRgl",
        "Karbowski__2007:TableS22:23:CMRgl",
        "Karbowski__2007:TableS22:9:CMRgl",
        "Karbowski__2007:TableS16:8:CMRgl",
        "Karbowski__2007:TableS15:11:CMRgl",
        "Karbowski__2007:TableS15:24:CMRgl",
        "Karbowski__2007:TableS12:8:CMRgl",
        "Karbowski__2007:TableS21:9:CMRgl",
        "Karbowski__2007:TableS10:5:CMRgl",
        "Karbowski__2007:TableS8:7:CMRgl",
        "Karbowski__2007:TableS18:11:CMRgl",
        "Karbowski__2007:TableS20:8:CMRgl",
        "Karbowski__2007:TableS7:9:CMRgl",
        "Karbowski__2007:TableS13:10:CMRgl",
        "Karbowski__2007:TableS3:7:CMRgl",
        "Karbowski__2007:TableS2:7:CMRgl",
    }
    assert all(
        row["conscious"] == "conscious"
        and row["condition_group"] == "nonanesthetized_unspecified_arm"
        and row["condition_evidence"].startswith("Primary-source arm verified")
        for row in verified_direct_conditions
    )
    accepted_karbowski_conditions = [
        row for row in karbowski
        if row["condition_group"] == "nonanesthetized_unspecified_arm"
    ]
    assert all(row["conscious"] in {"not_reported", "conscious"}
               for row in accepted_karbowski_conditions)
    assert all(
        row["conscious"] != "conscious"
        or "Primary-source arm verified" in row["condition_evidence"]
        for row in accepted_karbowski_conditions
    )
    assert {
        (row["Measure"], row["Units_raw"])
        for row in karbowski
    } == {
        ("CMRgl", "umol/g/min"),
        ("CMRO2", "ml/g/min"),
        ("Total_glucose_utilization", "umol/min"),
        ("Total_O2_consumption", "ml/min"),
    }

    oxygen = {
        row["source_reference_ids"]: float(row["Value"])
        for row in unfiltered
        if row["Compilation"] == "Karbowski__2007"
        and row["Table"] == "TableS1" and row["Measure"] == "CMRO2"
    }
    assert math.isclose(oxygen["linde_1999"], 374.976, abs_tol=1e-9)
    assert math.isclose(oxygen["nemoto_1994"], 267.84, abs_tol=1e-9)
    assert math.isclose(oxygen["clarke_1994; madsen_1991b"], 156.24, abs_tol=1e-9)

    registry_ids = {row["primary_reference_id"] for row in registry}
    cited_registry_ids = {row["reference_id"] for row in cited_registry}
    assert all(row["reference_id"] in cited_registry_ids for row in links)
    assert all(row["reference_level"] == "primary" for row in registry)
    assert cited_registry_ids - registry_ids == {
        "dastur_1985", "clarke_1994", "sokoloff_1984", "madsen_1993"
    }
    assert {
        row["reference_id"]: (row["reference_level"], row["source_type"])
        for row in cited_registry if row["reference_level"] == "secondary"
    } == {
        "dastur_1985": ("secondary", "review"),
        "clarke_1994": ("secondary", "book_chapter"),
        "sokoloff_1984": ("secondary", "book"),
        "madsen_1993": ("secondary", "pooled_reanalysis"),
    }
    links_by_record = {}
    for link in links:
        links_by_record.setdefault(link["record_id"], []).append(link)
    unlinked = [row for row in unfiltered if row["record_id"] not in links_by_record]
    assert len(unlinked) == 3
    assert all(row["primary_reference_raw"] == "(Zimmer, 1975)" for row in unlinked)
    assert sum(
        row["reference_resolution_status"] == "resolved_transitive_component_lineage"
        for row in unfiltered
    ) == 80

    def source_ids(row):
        return row["source_reference_ids"].split("; ") if row["source_reference_ids"] else []

    for target in karbowski:
        if target["derivation_role"] == "compiler_average":
            components = [
                row for row in karbowski
                if row["Table"] == target["Table"]
                and row["Species"] == target["Species"]
                and row["Region"] == target["Region"]
                and row["Measure"] == target["Measure"]
                and row["derivation_role"] != "compiler_average"
            ]
        elif target["derivation_role"] == "derived_cross_area_summary":
            components = [
                row for row in karbowski
                if 3 <= int(row["Table"][6:]) <= 10
                and row["Species"] == target["Species"]
                and row["Measure"] == target["Measure"]
                and row["derivation_role"] != "compiler_average"
            ]
        else:
            continue
        expected = []
        for component in sorted(components,
                                key=lambda row: (int(row["Table"][6:]), int(row["source_row"]))):
            for source_id in source_ids(component):
                if source_id not in expected:
                    expected.append(source_id)
        assert source_ids(target) == expected
    for row in unfiltered:
        output_ids = source_ids(row)
        ordered_links = sorted(links_by_record.get(row["record_id"], []),
                               key=lambda link: int(link["reference_order"]))
        assert output_ids == [link["reference_id"] for link in ordered_links]

    registry_by_id = {row["primary_reference_id"]: row for row in registry}
    cited_registry_by_id = {row["reference_id"]: row for row in cited_registry}
    for link in links:
        cited = cited_registry_by_id[link["reference_id"]]
        assert link["reference_citation"] == cited["reference_citation"]
        assert link["reference_level"] == cited["reference_level"]
        assert link["source_type"] == cited["source_type"]
    for row in dedupe:
        assert row["primary_reference_citation"] == registry_by_id[
            row["primary_reference_id"]
        ]["primary_reference_citation"]
    cleaner_shared_citations = {
        "meguro_1999": "Brain 1999, 122:",
        "nemoto_1994": "1994, 6:",
        "passero_1981": "1981, 21:",
        "redies_1989": "1989, 256:",
        "stingele_1996": "1996, 271:",
    }
    for primary_id, fragment in cleaner_shared_citations.items():
        assert fragment in registry_by_id[primary_id]["primary_reference_citation"]
    for row in merged:
        primary_ids = row["Primary_reference_ids"].split("; ")
        assert int(row["n_primary_references"]) == len(primary_ids) == len(set(primary_ids))
        assert all(primary_id in registry_ids for primary_id in primary_ids)
        assert row["Primary_references"].split(" || ") == [
            registry_by_id[primary_id]["primary_reference_citation"]
            for primary_id in primary_ids
        ]

    kauf_catalog = read_catalog(
        BASE / "Kaufman__2004/reference_tables/Kaufman__2004_TablesA1-A14_references.csv"
    )
    karb_catalog = read_catalog(
        BASE / "Karbowski__2007/reference_tables/Karbowski__2007_TablesS1-S23_references.csv"
    )
    assert source_refs("Kaufman__2004/Kaufman__2004_TableA*.csv", "Reference") == set(kauf_catalog)
    assert source_refs("Karbowski__2007/Karbowski__2007_TableS*.csv", "reference", multi=True) == set(karb_catalog)
    catalog_rows = list(kauf_catalog.values()) + list(karb_catalog.values())
    assert all(row["reference_level"] in {"primary", "secondary", "unresolved"}
               for row in catalog_rows)
    assert all(row["source_type"] for row in catalog_rows)
    secondary_catalog_ids = {
        row["source_reference_id"] for row in catalog_rows
        if row["reference_level"] == "secondary"
    }
    assert secondary_catalog_ids == {
        "dastur_1985", "clarke_1994", "sokoloff_1984", "madsen_1993"
    }
    assert all(
        not row["primary_reference_id"]
        for row in catalog_rows if row["reference_level"] != "primary"
    )
    assert all(
        row["primary_reference_id"] == row["source_reference_id"]
        for row in catalog_rows if row["reference_level"] == "primary"
    )
    assert not any(primary_id.lower().endswith("na") or primary_id.startswith("anon")
                   for primary_id in registry_ids)

    print(
        f"validated: {len(unfiltered):,} provenance rows; "
        f"{sum(row['include_in_primary_merge'] == 'True' for row in unfiltered):,} "
        f"primary-pool rows; {len(merged):,} merged cells; "
        f"{len(registry):,} resolved primary works; {len(links):,} "
        f"value-reference links; {len(dedupe):,} dedupe decisions; "
        f"{len(arm_report):,} quarantined arm groups"
    )


def read_catalog(path):
    with path.open(newline="", encoding="utf-8-sig") as handle:
        rows = list(csv.DictReader(handle))
    assert len(rows) == len({row["ref_key"] for row in rows})
    return {row["ref_key"]: row for row in rows}


if __name__ == "__main__":
    check()
