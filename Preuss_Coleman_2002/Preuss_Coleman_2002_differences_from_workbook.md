# Preuss & Coleman 2002: where my reading of the paper differs from the workbook

Compared with `Evo_M1_Trait_Data_Preuss_Coleman_2002.xlsx` (tabs `PC02 Main Text` ... `PC02 Fig 11 Matrix`).
Written 5 Nov 2026 by the AI assistant (Copilot) for review; page numbers are journal pages (Cereb Cortex
12:671-691).

Scope: only places where my interpretation of the text or a figure gives a different state, taxon set or meaning
from the workbook. Rows I added that have no workbook counterpart, and formatting differences (for example
"Absent (light stratum)" coded as absent with a note), are not listed. Main Text Text_1, Text_2 and Text_4 and
Figs 1-4, 5, 6, 7, 8 and 9-10 read the same in both.

## 1. Main Text: Cat-301 and NPNF share compartments, not neurons

- **Workbook** (Text_3): *Homo sapiens*, "Cat-301/NPNF colocalization in 4A mesh bands", Present.
- **Paper**: Results (p. 675): the dark and light Cat-301 territories were "coincident with dark and light zones of
  NPNF immunoreactivity". But (p. 676) the authors saw "no unambiguously double-labeled neuronal elements in
  layer 4A"; double-labelled cells occurred only in other layers.
- **My reading**: the two markers occupy the same tissue compartments (the mesh bands), not the same neurons, so
  "colocalization" holds at the compartment level only. Coded as two rows: same compartments, present;
  double-labelled neuronal elements in 4A, absent.
- **In the build**: `Preuss_Coleman_2002_MainText` snapshot rows 20-21.

## 2. Fig 11: the genus states are inferred, not printed

- **Workbook** (`PC02 Fig 11 Matrix`): 13 genera x 7 columns of states (Lgn 4A, Co Band, Honeycomb, Mesh, Npnf,
  Cat301, Calbindin).
- **Paper**: under each genus the figure prints letters for "the kinds of data published" (a LGN projection to 4A,
  b CO-dense band, c calbindin level, d NPNF pattern, e Cat-301 pattern) and four annotation boxes from a MacClade
  parsimony reconstruction (legend p. 684, graphic p. 685). The states the software used are not printed.
- **My reading**: every per-genus state is an inference. I give one only where the genus's letter is printed,
  taken from the most specific box covering it (human, then hominoid or *Aotus*, then ancestral), and mark the
  basis as inferred. For every lettered cell this matches the workbook (its low / moderate / high = the printed
  sparse / increased / dense; its ? = no letter).
- **In the build**: `Preuss_Coleman_2002_Fig11Matrix` snapshot rows 6-18 (letters) and 22-35 (boxes); derived rows
  in the CSV.

## 3. Fig 11: the Honeycomb column comes from the text, not the figure

- **Workbook**: Honeycomb 1 for *Saimiri*, *Cebus*, *Callithrix*, *Ateles*, *Macaca* and *Cercopithecus*; 0 for
  *Aotus*, *Pongo*, *Pan* and *Homo*; ? for *Papio*, *Erythrocebus* and *Miopithecus*.
- **Paper**: the figure prints honeycomb only as the ancestral organization (root box). The Discussion (p. 684)
  supplies the rest: *Aotus* "lacks a honeycomb organization"; "the ape-human group" departs from the ancestral
  honeycomb-like organization; and the honeycomb is present "in the majority of New World and Old World monkeys",
  stated in general, not per genus.
- **My reading**: the 0s for *Aotus* and the hominoids are supported by the text. The 1s for individual monkey
  genera extend the general statement (plus their LGN and CO data); they are not stated genus by genus. I coded
  no per-genus honeycomb trait, only the ancestral-node row.
- **In the build**: Fig11Matrix snapshot row 22 (ancestral box). The Discussion statements are not yet coded.

## 4. Fig 11: the Mesh column for genera without NPNF or Cat-301 data

- **Workbook**: Mesh 1 for *Homo*; 0 for nine genera, including *Aotus*, *Cebus* and *Callithrix*; ? for *Papio*,
  *Erythrocebus* and *Miopithecus*.
- **Paper**: the meshwork is printed only in the Human specializations box. *Aotus* and *Cebus* (letters a, b) and
  *Callithrix* (a, b, c) have no published NPNF or Cat-301 pattern data (no d or e).
- **My reading**: "no mesh" follows from the reconstruction only for genera with d or e data (*Saimiri*, *Ateles*,
  *Macaca*, *Cercopithecus*, *Pongo*, *Pan*). For *Aotus*, *Cebus* and *Callithrix* the workbook's 0 has no data
  behind it; I left them blank. Mesh is coded for *Homo* only (present); the other genera are covered by the NPNF
  and Cat-301 pattern traits.
- **In the build**: Fig11Matrix snapshot row 32 (human meshwork) and the derived NPNF and Cat-301 pattern rows.
