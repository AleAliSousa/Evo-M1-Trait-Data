"""Focused checks for the provisional folder-owned registry experiment."""
import unittest
from unittest.mock import patch

import build_item_index_pilot as pilot


class SharedDefinitionsTest(unittest.TestCase):
    def setUp(self):
        self.record = {
            "item_id": "Kaufman__2004_TableA1",
            "definitions_file": "Kaufman__2004/reference_tables/Kaufman__2004_definitions.csv",
            "definitions_scope": "Kaufman__2004_TableA1..A14",
        }

    def test_shared_file_keeps_table_groups_separate(self):
        a1 = pilot.check_definitions_scope(self.record)
        a15 = pilot.check_definitions_scope({
            **self.record, "item_id": "Kaufman__2004_TableA15",
            "definitions_scope": "Kaufman__2004_TableA15",
        })
        self.assertIn("CMRgl_SD", {row["Code"] for row in a1})
        self.assertNotIn("weighting", {row["Code"] for row in a1})
        self.assertIn("weighting", {row["Code"] for row in a15})
        self.assertNotIn("CMRgl_SD", {row["Code"] for row in a15})

    def test_missing_scope_or_file_is_not_silently_accepted(self):
        with self.assertRaisesRegex(ValueError, "no definitions found"):
            pilot.check_definitions_scope({**self.record, "definitions_scope": "unknown"})
        with self.assertRaisesRegex(ValueError, "requires definitions_file"):
            pilot.check_definitions_scope({**self.record, "definitions_file": ""})


class WorkbookDriftTest(unittest.TestCase):
    def setUp(self):
        self.header = ["Item name", "Item encoded", pilot.PUBLIC_MATCH_FIELD,
                       "Item full original title"]
        self.row = ["Paper_Table1", "paper_Table1", "notfound", "Table 1"]
        self.record = {
            "item_id": "Paper_Table1", "visibility": "public",
            "public_tsv_path": "__Public/comparative-data/paper_Table1.tsv",
            "legacy_workbook_row": "2",
            "legacy:" + pilot.PUBLIC_MATCH_FIELD: "paper_Table1.tsv",
            "legacy:Item full original title": "Table 1",
        }

    def check(self, row):
        class Sheet:
            def iter_rows(self, values_only=False):
                return iter([self_header, row])
        self_header = self.header
        with patch("openpyxl.load_workbook", return_value={"Sheet1": Sheet()}):
            return pilot.compare_workbook([self.record])

    def test_volatile_status_is_reported_without_hiding_data_drift(self):
        _, _, _, differences = self.check(self.row)
        self.assertEqual(differences, [("Paper_Table1", "paper_Table1.tsv", "notfound")])
        with self.assertRaisesRegex(ValueError, "Item full original title"):
            self.check([*self.row[:3], "Changed title"])


if __name__ == "__main__":
    unittest.main()
