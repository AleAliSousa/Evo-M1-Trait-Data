# Giannaris_Rosene_2012_Table5

Giannaris & Rosene (2012), *Journal of Comparative Neurology* 520:3492–3508, DOI 10.1002/cne.23101. PDF page 9, printed p. 3500; Estimated Total Number of Neurons in Area 17 and Laminar Zones.

The frozen snapshot preserves 26 source-order subjects and the printed summary rows. The reader keeps individual records only, with sex and age. The individual rows in Tables 4 and 5 pair by `subject`, yielding measured V1 volume and neuron number for Figure 7. The hemisphere side is not printed in either table; it is given in the paper's Table 1. Do not treat the printed means as additional animals. Table 4 units are mm³; Table 5 counts are absolute neurons.

Layout edit: restored the printed table caption and spanning measurement heading above the
column labels. The R reader skips these source rows; the 26-row analysis CSV rebuilt byte for
byte with the command below. Registry lookup now uses the current `__ReadMe.xlsx` entry.

Run from repo root: `Rscript --vanilla Giannaris_Rosene_2012/Giannaris_Rosene_2012_Table5.R`. The script reads only its frozen CSV and writes the analysis CSV and DOI-coded public TSV. The Table 5 reader checks each printed total against the three laminar counts. Snapshot compared with PDF text and page layout by AI on 2026-11-24; human visual signoff remains pending. No figure-derived dataset or replot was created.
