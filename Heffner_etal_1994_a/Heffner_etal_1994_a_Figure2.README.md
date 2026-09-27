# Heffner_etal_1994_a_Figure2

## Source
Heffner, R. S., Heffner, H. E., Contos, C., & Kearns, D. (1994). Hearing in
prairie dogs: transition between surface and subterranean rodents. *Hearing
Research*, 73, 185-189. doi:10.1016/0378-5955(94)90233-x

Registry Item **Figure 2**, printed p. 187 (audiogram of a white-tailed
prairie dog). Public copy: `Heffner_etal_1994_a/Heffner_etal_1994_a.pdf`.
Folder-disambiguation note: this DOI is shared with no other folder in this
drive; the `_a` suffix distinguishes this 1994 Heffner short paper from the
`_b` (hooded rat) and `_c` (chinchilla localization) 1994 papers, which are
unrelated studies published the same year.

## Why this item exists
This short paper reports behavioral audiograms for one white-tailed prairie
dog (*Cynomys leucurus*) and four black-tailed prairie dogs (*C.
ludovicianus*), comparing surface-dwelling rodents' hearing to that of
subterranean specialists. The white-tailed animal's audiogram (Fig. 2) is the
companion/priority-1 item for this folder: SensoryData_compiled uses its best
sensitivity (24 dB) and best frequency (8 kHz) values. The companion
black-tailed data (Fig. 1, 4 individuals) is registered separately as
`Heffner_etal_1994_a_Figure1` (row 502, built alongside this item because the
values are stated in the same Results paragraph).

## Pipeline
Although the registry item is nominally "Figure 2", the house rule of
preferring printed text over digitizing a figure applies here: the Results
text (p. 187) restates the figure's two headline values verbatim ("the
white-tailed prairie dog's lowest threshold (at 8 kHz) is only 24 dB SPL. Its
hearing range at 60 dB SPL extends from 44 Hz to 26 kHz."), so the full
audiogram curve was **not** digitized -- only these text-stated summary
values were transcribed.

| file | role |
|---|---|
| `Heffner_etal_1994_a_Figure2_snapshot.csv` | frozen source, values as printed in the Results text |
| `Heffner_etal_1994_a_Figure2.R` | reads the snapshot, writes CSV + public TSV |
| `Heffner_etal_1994_a_Figure2.csv` | tidy analysis row |
| `reference_tables/Heffner_etal_1994_a_Figure2_definitions.csv` | data dictionary |

## Data role
Single row, primary (this paper's own new measurement for *C. leucurus*).

## Observation level
One individual white-tailed prairie dog; testing did not extend below 32 Hz
for this animal (unlike the black-tailed individuals, which were tested down
to 4 Hz).

## Units
Sensitivity/threshold in dB SPL (re 20 uN/m^2 as printed); frequency in Hz/kHz
as printed for each field.

## Verification
Source PDF has an imperfect OCR text layer (scanned reprint with character
substitution errors, e.g. "b4dor'icianus" for "ludovicianus"). All numeric
values used here (24 dB, 8 kHz, 44 Hz, 26 kHz, 32 Hz) were cross-checked
against a 250-dpi render of PDF page 3 (printed p. 187) and confirmed to
match the printed text exactly.
