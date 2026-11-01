"""Faithful transcription of Table 3 and of the abstract summary into the two FROZEN SNAPSHOTS.

This script writes snapshots only. The analysis layer (the CSVs, and the public TSVs once the
items are registered) is built from those snapshots by Wiafe__2019_Table3.R and
Wiafe__2019_GroupSizes.R -- one writer per file.
"""
import csv
from pathlib import Path
P=Path(__file__).resolve().parent
names=[('Olive Baboon','Papio anubis'),('Patas Monkey','Erythrocebus patas'),('Green Monkey','Chlorocebus sabaeus'),('White-thighed Colobus','Colobus vellerosus')]
# Original zeros and range strings retained, including zeros for unobserved colobus.
values=[[(16.8,2.3,'7–30'),(17.1,3.4,'4–38'),(7.8,1.1,'1–19'),(6.8,1.1,'3–15')],[(26.7,4.6,'14–35'),(13.1,3.2,'3–34'),(9.5,1.4,'1–19'),(2.7,.6,'1–5')],[(14.5,4.7,'3–25'),(12.9,2.3,'6–25'),(9.5,1.4,'3–18'),(1.7,.3,'1–2')],[(0,0,'0'),(6,0,'0'),(0,0,'0'),(0,0,'0')]]
def write(name,rows):
 with (P/name).open('w',newline='') as f:
  w=csv.DictWriter(f,list(rows[0]));w.writeheader();w.writerows(rows)
def write_grid(name,grid):
 with (P/name).open('w',newline='') as f:
  csv.writer(f).writerows(grid)
# FROZEN SOURCE = Table 3 in its printed grid: the two-level header (sector band over Mean/SE/Range),
# one row per species in printed order, 12 value columns left to right exactly as laid out. A
# reviewer puts this beside printed p.13528 and matches cell for cell; the long form below is the
# ANALYSIS layer. Keeping the printed shape is what makes a one-row or one-column slip visible.
sectors=['Eastern','Southern','Western','Northern']
grid=[['Name of species']+[s if i==0 else '' for s in sectors for i in range(3)],
      ['']+['Mean','SE','Range']*len(sectors)]
# The printed header casing alternates: Eastern/Southern/Western use lower-case "mean", Northern "Mean".
grid[1]=['','Mean','SE','Range','mean','SE','Range','mean','SE','Range','Mean','SE','Range']
for (common,sp),vv in zip(names,values):
 row=[common]
 for mean,se,ran in vv:
  row+=[mean,se,ran]
 grid.append(row)
write_grid('Wiafe__2019_Table3_snapshot.csv',grid)
# FROZEN SOURCE for the overall means is the Abstract sentence itself: these numbers are printed
# in prose, not tabulated, so the snapshot is a constructed one carrying the verbatim wording. Note
# the colobus value is printed as the WORD "six", which the analysis layer below turns into 6.
abstract_rows=[
 dict(source_location='Abstract, printed p. 13523 (PDF page 3)',common_name_as_printed='Olive Baboon',scientific_name_as_printed='Papio anubis',mean_group_size_as_printed='10.8',SE_as_printed='1.1',range_as_printed='1-38',verbatim_passage='The mean group sizes were: Olive Baboon 10.8 (SE=1.1, range=1-38), Patas Monkey 12.2 (SE=3.3, range=1-35), and Green Monkey 10.0 (SE=1.9, range=1-25).'),
 dict(source_location='Abstract, printed p. 13523 (PDF page 3)',common_name_as_printed='Patas Monkey',scientific_name_as_printed='Erythrocebus patas',mean_group_size_as_printed='12.2',SE_as_printed='3.3',range_as_printed='1-35',verbatim_passage='The mean group sizes were: Olive Baboon 10.8 (SE=1.1, range=1-38), Patas Monkey 12.2 (SE=3.3, range=1-35), and Green Monkey 10.0 (SE=1.9, range=1-25).'),
 dict(source_location='Abstract, printed p. 13523 (PDF page 3)',common_name_as_printed='Green Monkey',scientific_name_as_printed='Chlorocebus sabaeus',mean_group_size_as_printed='10.0',SE_as_printed='1.9',range_as_printed='1-25',verbatim_passage='The mean group sizes were: Olive Baboon 10.8 (SE=1.1, range=1-38), Patas Monkey 12.2 (SE=3.3, range=1-35), and Green Monkey 10.0 (SE=1.9, range=1-25).'),
 dict(source_location='Abstract, printed p. 13523 (PDF page 3)',common_name_as_printed='White-thighed Colobus',scientific_name_as_printed='Colobus vellerosus',mean_group_size_as_printed='six',SE_as_printed='',range_as_printed='',verbatim_passage='Only one group of White-thighed Colobus with a group size of six was encountered.'),
]
write('Wiafe__2019_GroupSizes_snapshot.csv',abstract_rows)
