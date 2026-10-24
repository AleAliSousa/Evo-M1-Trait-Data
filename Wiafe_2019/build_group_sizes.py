"""Faithful transcription of Table 3 and the separately reported abstract summary."""
import csv
from pathlib import Path
P=Path(__file__).resolve().parent
names=[('Olive Baboon','Papio anubis'),('Patas Monkey','Erythrocebus patas'),('Green Monkey','Chlorocebus sabaeus'),('White-thighed Colobus','Colobus vellerosus')]
# Original zeros and range strings retained, including zeros for unobserved colobus.
values=[[(16.8,2.3,'7–30'),(17.1,3.4,'4–38'),(7.8,1.1,'1–19'),(6.8,1.1,'3–15')],[(26.7,4.6,'14–35'),(13.1,3.2,'3–34'),(9.5,1.4,'1–19'),(2.7,.6,'1–5')],[(14.5,4.7,'3–25'),(12.9,2.3,'6–25'),(9.5,1.4,'3–18'),(1.7,.3,'1–2')],[(0,0,'0'),(6,0,'0'),(0,0,'0'),(0,0,'0')]]
def write(name,rows):
 with (P/name).open('w',newline='') as f:
  w=csv.DictWriter(f,list(rows[0]));w.writeheader();w.writerows(rows)
snapshot=[]
for (common,sp),vv in zip(names,values):
 for sector,(mean,se,ran) in zip(['Eastern','Southern','Western','Northern'],vv):
  snapshot.append(dict(common_name_printed=common,Species=sp,sector=sector,group_size_mean=mean,group_size_SE=se,range_printed=ran,source_location='Table 3; printed p.13528; PDF page 8'))
write('Wiafe_2019_Table3_snapshot.csv',snapshot)
# A separate reported overall summary; not a reconstructed average of sectors.
summary=[]
for (common,sp),v in zip(names,[(10.8,1.1,1,38),(12.2,3.3,1,35),(10.0,1.9,1,25),(6,'',6,6)]):
 mean,se,lo,hi=v
 summary.append(dict(Species=sp,group_size_reported=mean,group_size_SE=se,range_min=lo,range_max=hi,statistic='single observed group' if sp=='Colobus vellerosus' else 'reported overall mean',population='Mole National Park, Ghana',setting='wild',age_scope='Individuals observed; no adult-only restriction stated',source_location='Abstract; printed p.13523; PDF page 3',source_doi='10.11609/jott.4026.11.5.13523-13530',role='primary',quality_flag='Overall summary retained as reported; not reproducible exactly from rounded sector means and Table1 group counts; do not pool sector rows again' if sp!='Colobus vellerosus' else 'One observed group; table zeros for absent sectors are not zero-sized social groups'))
write('Wiafe_2019_GroupSizes_snapshot.csv',summary)
write('Wiafe_2019_GroupSizes.csv',summary)
write('reference_tables/Wiafe_2019_GroupSizes_definitions.csv',[dict(Code='group_size_reported',Definition='Reported overall number of individuals per observed primate group in Mole National Park, Ghana (Wiafe 2019 abstract). Means for three species and a single observed group for Colobus vellerosus. Ten-minute observations from line transects; no adult-only restriction stated. Source-specific wild population data; not a species-wide mean. Sector-specific data and reported uncertainties are preserved separately. Overall means are not reconstructed from Table 3.',role='primary')])
