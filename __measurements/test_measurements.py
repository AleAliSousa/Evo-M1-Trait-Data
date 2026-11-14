"""Small semantic fixtures: IDs, source roles, method filters and conversion aliases."""
import csv,sqlite3,tempfile,unittest
from pathlib import Path
import openpyxl
from build_measurements import build, role_of, standardize, brain_basis, run_local
class StageTest(unittest.TestCase):
 def test_uncertainty_and_units(self):
  self.assertEqual(role_of("primary","secondary"),"review")
  self.assertEqual(role_of("both","both"),"review")
  self.assertEqual(brain_basis("mass_unspecified","mass"),"unresolved")
  self.assertEqual(standardize(2,"g","brain_mass"),(2000,"mg"))
  self.assertEqual(standardize(2,"g","volume"),(None,""))
 def test_identity_and_filters(self):
  with tempfile.TemporaryDirectory() as t:
   root=Path(t);public=root/'__Public/comparative-data';public.mkdir(parents=True);out=root/'out'
   w=openpyxl.Workbook();s=w.active;s.title='Sheet1';s.append(['Item encoded','Item name','Publication name','Data role (primary/secondary/both)']);s.append(['animal','Herberstein_etal_2022_Observations','Herberstein_etal_2022','primary']);w.save(root/'__ReadMe.xlsx')
   fields=['species','brain size','brain size - units','brain size - method','original brain size - units','Brain_Mass.mg','Brain_Volume_original.mm3']
   rows=[['A a','0.001','kg','brain weighed','g','1000',''],['B b','0.002072','kg','skull filling','ml','2072','2000'],['C c','0.003','kg','','g','3000','']]
   def source(rs):
    with (public/'animal.tsv').open('w') as f:w=csv.writer(f,delimiter='\t');w.writerow(fields);w.writerows(rs)
   source(rows);build(root,out);db=sqlite3.connect(out/'measurements.sqlite')
   self.assertEqual(db.execute("SELECT COUNT(*) FROM points WHERE active=1 AND column_name='Brain_Mass.mg'").fetchone()[0],0)
   self.assertEqual(db.execute("SELECT COUNT(*) FROM points WHERE active=1 AND data_role='primary'").fetchone()[0],0)
   self.assertEqual(db.execute('SELECT COUNT(*) FROM direct_brain_weights').fetchone()[0],1)
   self.assertEqual(db.execute('SELECT COUNT(*) FROM combined_brain_weights').fetchone()[0],2)
   self.assertEqual(db.execute('SELECT COUNT(*) FROM endocranial_volumes').fetchone()[0],1)
   self.assertEqual(db.execute('SELECT COUNT(*) FROM report_relations').fetchone()[0],1)
   self.assertEqual(db.execute("SELECT standard_value FROM points WHERE active=1 AND species='B b' AND column_name='brain size'").fetchone()[0],2072)
   before=db.execute('SELECT number,point_id FROM points WHERE active=1 ORDER BY number').fetchall();db.close()
   source(list(reversed(rows)));build(root,out);db=sqlite3.connect(out/'measurements.sqlite')
   self.assertEqual(before,db.execute('SELECT number,point_id FROM points WHERE active=1 ORDER BY number').fetchall());db.close()
   run_local(root,out,resume=True);db=sqlite3.connect(out/'measurements.sqlite')
   self.assertEqual(before,db.execute('SELECT number,point_id FROM points WHERE active=1 ORDER BY number').fetchall())
   self.assertEqual(db.execute('SELECT COUNT(*) FROM report_relations').fetchone()[0],1);db.close()
if __name__=='__main__':unittest.main()
