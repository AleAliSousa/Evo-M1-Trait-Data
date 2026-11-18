"""Offline checks for provider handoff and unsafe taxonomy-match rejection."""
import importlib.util
import sys
import unittest
from pathlib import Path
from unittest.mock import patch

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[1]


def module(name, path):
    spec = importlib.util.spec_from_file_location(name, ROOT / path)
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result


fallback = module('order_fallback', '_tools/update_order_fallbacks.py')
updater = module('navigation_updater', '_tools/update_navigation_taxonomy.py')


class TaxonomyHandoffTests(unittest.TestCase):
    def test_mdd_match_prevents_unnecessary_lower_priority_lookups(self):
        accepted = {'Order': 'Rodentia'}
        with patch.object(fallback, 'lookup_mdd', return_value=accepted), \
             patch.object(fallback, 'lookup_gbif') as gbif, \
             patch.object(fallback, 'lookup_itis') as itis:
            result, attempts, review = fallback.resolve_label('Oldmus example', {}, 'v2.5')
        self.assertEqual(result, accepted)
        self.assertIsNone(review)
        gbif.assert_not_called()
        itis.assert_not_called()

    def test_miss_and_service_error_continue_to_next_databases(self):
        accepted = {'Order': 'Primates'}
        with patch.object(fallback, 'lookup_mdd', return_value=None), \
             patch.object(fallback, 'lookup_gbif', side_effect=TimeoutError('outage')), \
             patch.object(fallback, 'lookup_itis', return_value=(None, [('Oldprimate', 'no_match', '')])), \
             patch.object(fallback, 'lookup_pbdb', return_value=(accepted, [('Oldprimate', 'matched', 'ref')])) as pbdb:
            result, attempts, review = fallback.resolve_label('Oldprimate', {}, 'v2.5')
        self.assertEqual(result, accepted)
        self.assertIn(('GBIF', 'Oldprimate', 'service_error', 'outage'), attempts)
        self.assertIsNone(review)
        pbdb.assert_called_once()

    def test_ncbi_failure_still_runs_downstream_ladder_and_rebuilds(self):
        with patch.object(updater, 'update_ncbi', side_effect=TimeoutError('NCBI outage')), \
             patch.object(updater, 'record_ncbi_error') as error_log, \
             patch.object(updater.subprocess, 'run') as run, \
             patch.object(updater.sys, 'argv', ['update_navigation_taxonomy.py']), \
             patch('builtins.print'):
            updater.main()
        paths = [call.args[0][1] for call in run.call_args_list]
        self.assertEqual(len(paths), 3)
        self.assertTrue(paths[1].endswith('update_order_fallbacks.py'))
        self.assertTrue(paths[0].endswith('build_species_taxonomy.py'))
        self.assertTrue(paths[2].endswith('build_species_taxonomy.py'))
        error_log.assert_called_once()

    def test_high_confidence_kingdom_match_is_not_an_order(self):
        response = {'usage': {'canonicalName': 'Animalia', 'rank': 'KINGDOM'},
            'classification': [{'rank': 'KINGDOM', 'name': 'Animalia'}],
            'diagnostics': {'matchType': 'HIGHERRANK', 'confidence': 99}}
        with patch.object(fallback, 'get_json', return_value=(response, 'url')):
            result, attempts = fallback.lookup_gbif('Misspelled animal')
        self.assertIsNone(result)

    def test_fuzzy_different_genus_is_not_silently_accepted(self):
        response = {'usage': {'canonicalName': 'Peleropus', 'rank': 'GENUS'},
            'classification': [{'rank': 'KINGDOM', 'name': 'Animalia'}, {'rank': 'ORDER', 'name': 'Coleoptera'}],
            'diagnostics': {'matchType': 'VARIANT', 'confidence': 85}}
        with patch.object(fallback, 'get_json', return_value=(response, 'url')):
            result, attempts = fallback.lookup_gbif('Peteropus gilliardi')
        self.assertIsNone(result)

    def test_full_species_can_disambiguate_a_genus_collision(self):
        response = {'usage': {'canonicalName': 'Ariadne ariadne', 'rank': 'SPECIES', 'key': 'example'},
            'classification': [{'rank': 'KINGDOM', 'name': 'Animalia'},
                {'rank': 'ORDER', 'name': 'Lepidoptera'}, {'rank': 'GENUS', 'name': 'Ariadne'}],
            'diagnostics': {'matchType': 'EXACT', 'confidence': 100}}
        with patch.object(fallback, 'get_json', return_value=(response, 'url')):
            result, attempts = fallback.lookup_gbif('Ariadne ariadne')
        self.assertEqual(result['Order'], 'Lepidoptera')

    def test_non_taxon_text_does_not_get_a_fabricated_order(self):
        with patch.object(fallback, 'lookup_mdd') as mdd:
            result, attempts, review = fallback.resolve_label('Neocortex', {}, 'v2.5')
        self.assertIsNone(result)
        self.assertEqual(review['Status'], 'non_taxon_label')
        mdd.assert_not_called()
        self.assertEqual(fallback.queries('L. chrysomelas'), [])
        self.assertEqual(fallback.label_status('NA'), 'unspecified_source_label')


if __name__ == '__main__':
    unittest.main()
