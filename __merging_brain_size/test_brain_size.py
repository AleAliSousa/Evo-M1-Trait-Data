import math
import unittest
import build_brain_size as b


def report(i, value, quantity="mass_g", team="A", source="one.tsv", role="primary", n=None):
    return b.candidate("fixture", i, {"Species": "Test species"}, value, quantity,
                       "fixture basis", source, team, role, n=n)


class BrainSizeTests(unittest.TestCase):
    def test_native_values_and_inverse(self):
        self.assertEqual(b.pair(100, "volume_ml"), (103.60000000000001, 100))
        self.assertAlmostEqual(b.pair(103.6, "mass_g")[1], 100)
        self.assertGreater(b.pair(1e-10, "volume_ml")[0], 0)
        with self.assertRaises(ValueError):
            b.pair(100, "unknown")

    def test_sample_weighted_mean_uses_both_methods(self):
        rr = [report(1, 10, n=2), report(2, 100, "volume_ml", team="B", n=8)]
        out = b.pool(rr)
        self.assertAlmostEqual(out[0]["Value"], (2 * 10 + 8 * 103.6) / 10)
        self.assertTrue(all(r["included"] for r in rr))
        self.assertEqual(out[0]["contributor_ids"], out[1]["contributor_ids"])
        self.assertAlmostEqual(out[0]["Value"], out[1]["Value"] * b.DENSITY)

    def test_unknown_n_is_report_weight_not_animal_count(self):
        rr = [report(1, 10), report(2, 30)]
        out = b.pool(rr)
        self.assertEqual(out[0]["Value"], 20)
        self.assertEqual(out[0]["reports_with_unknown_n"], 2)
        self.assertTrue(all(r["sample_size"] == "" for r in rr))

    def test_same_collection_representations_and_relays_count_once(self):
        rr = [report(1, 103.6), report(2, 100, "volume_ml"),
              report(3, 103.6, source="relay.tsv", role="secondary", n=100)]
        out = b.pool(rr)
        self.assertEqual(sum(r["included"] for r in rr), 1)
        self.assertEqual(out[0]["Value"], 103.6)
        self.assertTrue(all(r["exclusion_reason"] for r in rr[1:]))

    def test_secondary_fallback_and_primary_preference(self):
        rr = [report(1, 10), report(2, 999, team="B", role="secondary")]
        self.assertEqual(b.pool(rr)[0]["Value"], 10)
        rr = [report(1, 10, role="secondary"), report(2, 30, team="B", role="secondary")]
        self.assertEqual(b.pool(rr)[0]["Value"], 20)

    def test_unspecified_taxa_are_auditable(self):
        r = report(1, 10)
        r["Species"] = "Test sp."
        self.assertEqual(b.pool([r]), [])
        self.assertIn("taxon", r["exclusion_reason"])

    def test_upstream_reprint_veto_is_preserved(self):
        r = report(1, 999)
        r["exclusion_reason"] = "ECV merge reprint exclusion: Isler"
        self.assertEqual(b.pool([r]), [])
        self.assertFalse(r["included"])

    def test_documented_sample_sizes_match_binomials(self):
        rows = b.read("__merging_brain_mass/brain_mass_unfiltered.csv")
        ns = b.mass_sample_sizes(rows)
        matched = [r for r in rows if (r["Source"], r["Species"], r["column"], b.number(r["raw_value"])) in ns]
        self.assertGreater(len(matched), 200)
        self.assertEqual(ns[("10.1093%2Fjmammal%2Fgyz043_SupplementaryDataSD1.tsv",
                             "Microgale cowani", "Mean_brain_mass_g", 0.42)][0], 1)
        self.assertEqual(ns[("10.1038%2Fs41559-017-0112_BrainData.tsv",
                             "Allenopithecus nigroviridis", "Brain Mass", 61.19674101333334)][0], 3)

    def test_built_outputs_have_identical_contributors_and_reproduce_values(self):
        rows = b.read("__merging_brain_size/brain_size_long.csv")
        audit = b.read("__merging_brain_size/brain_size_contributions.csv")
        groups = {}
        for r in audit:
            if r["included"] == "True":
                groups.setdefault(r["Species"], []).append(r)
            else:
                self.assertTrue(r["exclusion_reason"])
        for i in range(0, len(rows), 2):
            m, v = rows[i:i+2]
            self.assertEqual(m["Species"], v["Species"])
            self.assertEqual(m["contributor_ids"], v["contributor_ids"])
            self.assertTrue(math.isclose(float(m["Value"]), float(v["Value"]) * b.DENSITY, rel_tol=1e-12))
            rr = groups[m["Species"]]
            self.assertAlmostEqual(sum(float(r["final_weight"]) for r in rr), 1)
            self.assertTrue(math.isclose(float(m["Value"]),
                sum(float(r["mass_g"]) * float(r["final_weight"]) for r in rr), rel_tol=1e-12))
        aliases = {r["variant"]: r["canonical"] for r in b.read("_keys/species_display_aliases.csv")}
        blocked = b.blocked_labels()
        self.assertTrue(set(groups).isdisjoint(blocked))
        original = {aliases.get(r["Species"], r["Species"]) for r in b.read("__merging_brain_mass/brain_mass_long.csv")
                    if r["Measure"] == "Brain mass (measured or estimated from volume)"
                    and r["Species"] not in blocked
                    and not b.re.search(r"\b(?:sp|spp)\.?\b| and | / ", r["Species"])}
        self.assertTrue(original <= set(groups))


if __name__ == "__main__":
    unittest.main()
