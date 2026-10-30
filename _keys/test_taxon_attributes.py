"""Regression checks for orthogonal species identity and temporal grade.
Run with a pandas-enabled Python; Rscript checks the R mirror when available.
"""
import csv
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest
from resolve_species import resolve_species

ROOT = Path(__file__).resolve().parent


class TaxonAttributes(unittest.TestCase):
    def test_grades_share_taxid_without_losing_concepts(self):
        labels = ['EH', 'MH', 'Early Archaic Homo sapiens', 'Homo sapiens', 'Homo sapiens']
        papers = ['Kochiyama_etal_2018', 'Kochiyama_etal_2018', 'Weaver__2001',
                  'Kochiyama_etal_2018', 'unknown_paper']
        r = resolve_species(labels, papers).fillna('')
        self.assertEqual(r.ncbi_taxid.tolist(), ['9606'] * 5)
        self.assertEqual(r.temporal_grade.tolist(), ['early', 'living', 'archaic', 'early', ''])
        self.assertEqual(r.taxon_name.tolist(), ['Homo sapiens'] * 5)
        self.assertEqual(r.accepted_name.iloc[0], 'Homo sapiens (early)')
        self.assertEqual(r.ncbi_mapping_basis.iloc[2], 'source_hypothesis')
        if shutil.which('Rscript'):
            with tempfile.TemporaryDirectory() as td:
                inp, out = Path(td)/'in.csv', Path(td)/'out.csv'
                with inp.open('w', newline='') as f:
                    w = csv.writer(f); w.writerow(['label', 'paper']); w.writerows(zip(labels, papers))
                script = ('source(commandArgs(TRUE)[1]); x <- read.csv(commandArgs(TRUE)[2]); '
                          'write.csv(resolve_species(x$label,x$paper),commandArgs(TRUE)[3],row.names=FALSE,na="")')
                env = dict(os.environ, LANG='en_US.UTF-8', LC_ALL='en_US.UTF-8')
                subprocess.run(['Rscript', '-e', script, str(ROOT/'resolve_species.R'), str(inp), str(out)],
                               check=True, env=env)
                with out.open() as f: rr = list(csv.DictReader(f))
                for col in ['accepted_name', 'taxon_name', 'ncbi_taxid', 'ncbi_name', 'ncbi_rank', 'ncbi_mapping_basis', 'temporal_grade']:
                    self.assertEqual(r[col].tolist(), [x[col] for x in rr], col)

    def test_rank_and_redirect_corrections(self):
        r = resolve_species(['Cebus sp.', 'Cercartetus nanus', 'Phalanger maculatus',
                             'Phocoena phocoena', 'Homo neanderthalensis'])
        self.assertEqual(r.ncbi_taxid.tolist(), ['9513', '3369760', '175810', '9742', '63221'])
        self.assertEqual(r.ncbi_rank.iloc[0], 'genus')
        self.assertEqual(r.ncbi_rank.iloc[4], 'subspecies')
        self.assertEqual(r.taxon_name.iloc[4], 'Homo neanderthalensis')

    def test_hub_spoke_agreement(self):
        subprocess.run([shutil.which('python3'), str(ROOT/'sync_ncbi_taxids.py')], check=True)
        with (ROOT/'species_reference.csv').open() as f:
            hub = {r['accepted_name']: r['ncbi_taxid'] for r in csv.DictReader(f)}
        for p in ROOT.glob('*/species_key.csv'):
            with p.open() as f:
                for r in csv.DictReader(f):
                    self.assertEqual(r['ncbi_taxid'] or 'NA', hub[r['accepted_name']], str(p))

    def test_fossil_merge_attributes(self):
        p = ROOT.parent/'__merging_fossil_brain_glucose/fossil_brain_glucose_long.csv'
        with p.open() as f: rows = list(csv.DictReader(f))
        human = [r for r in rows if r['taxon_name'] == 'Homo sapiens']
        self.assertTrue(human)
        self.assertEqual({r['ncbi_taxid'] for r in human}, {'9606'})
        self.assertEqual({r['temporal_grade'] for r in human}, {'early','recent','modern_reference'})
        self.assertTrue(all(r['temporal_grade'] == r['sapiens_grade'] for r in human))
        self.assertTrue(any(r['Specimen'] == 'Mladeč 1' and r['temporal_grade'] == 'early' for r in rows))


if __name__ == '__main__':
    unittest.main()
