# Preuss, Qi & Kaas 1999: where my reading of the paper differs from the workbook

Compared with `Evo_M1_Trait_Data_Preuss_etal_1999.xlsx` (tabs `P99 Main Text`, `P99 Fig 1` ... `P99 Fig 6`).
Written 5 Nov 2026 by the AI assistant (Copilot) for review; page numbers are journal pages (PNAS 96:11601-11606).

Scope: only places where my interpretation of the text or a figure gives a different state, taxon set or meaning
from the workbook. Rows I added that have no workbook counterpart, and formatting differences (for example
"Macaca spp." vs the printed genus *Macaca*), are not listed. Fig 2, Fig 3 and Fig 4 read the same in both.

## 1. Main Text: the CO pattern is shared by apes and humans, not human-specific

- **Workbook** (Text_1): *Homo sapiens*, "Human-specific CO compartment pattern in V1", Present.
- **Paper**: Results (p. 11603): both apes and humans "lack a dark-staining layer 4A band" and have "a band of
  moderate staining in layer 4B", which is "not typically present in monkeys". Discussion (p. 11605): chimpanzees
  "and probably also orangutans" have the human-like condition.
- **My reading**: the CO difference separates hominoids from monkeys; it is not a human specialisation. Coded per
  taxon: CO-dense 4A band absent and 4B CO band present for *Homo*, *Pan* and *Pongo*; the reverse for the monkeys.
- **In the build**: `Preuss_etal_1999_MainText` snapshot rows 1-11 (traits `L4A_CO_dense_band`, `L4B_CO_band`).

## 2. Main Text: "none of the other species" covers every nonhuman taxon examined

- **Workbook** (Text_3 to Text_5): absence of the layer 4A mesh listed for *Pan*, *Pongo* and *Macaca* only.
- **Paper**: Results (p. 11604): the NPNF mesh was seen "in all of our human cases and in none of the other
  species we examined"; Methods (p. 11602) list NPNF staining in *Pan*, *Pongo*, *Macaca*, *Cercopithecus*,
  *Saimiri* and *Ateles*. For MAP 2, human layer 4A "differed from that of apes and monkeys" (p. 11604).
- **My reading**: the statements apply to every nonhuman taxon stained, so the mesh is also absent in vervets
  (*Cercopithecus aethiops*), squirrel monkeys and spider monkeys. The MAP 2 "absent" rows are read from that
  contrast; dense MAP 2 staining was obtained in only two ape cases, species not stated.
- **In the build**: Main Text snapshot rows 28-33 (NPNF) and 37-42 (MAP 2).

## 3. Fig 1: a literature model, not an observation of a species

- **Workbook** (`P99 Fig 1`): "Macaque / Anthropoid Monkeys", "Honeycomb architecture (CO/MAP2/NPNF)", Present.
- **Paper**: legend (p. 11602): the honeycomb model "as derived from studies of macaques and other monkeys"; the
  Introduction (p. 11601) says Fig. 1 summarises earlier work (refs 14-18).
- **My reading**: the figure is a schematic of published findings, so it states no observed species state. Kept as
  six model elements under the printed group "macaques and other monkeys", with no accepted species and data role
  secondary.
- **In the build**: `Preuss_etal_1999_Fig1` snapshot rows 1-6.

## 4. Fig 5: no "light band" state is printed for MAP 2

- **Workbook** (`P99 Fig 5`): *Macaca*, "Light band with vertical dendrites"; *Pan*, "Light band".
- **Paper**: the legend (p. 11604) describes only the human pattern: a "patchy, mesh-like pattern is apparent in
  layer 4A of humans". The light band crossed by vertically oriented dendrites is the NPNF description for monkeys
  and apes (Results p. 11604; Figs 3A-C, 4A-B) and the Fig. 1 model. For MAP 2 the Results say only that human
  layer 4A "differed from that of apes and monkeys".
- **My reading**: the workbook states are carried over from the NPNF results and the model, not read from Fig. 5.
  Coded MAP 2 mesh absent for *Macaca* and *Pan* (from the Results contrast) and nothing about a light band.
- **In the build**: `Preuss_etal_1999_Fig5` snapshot rows 1-2.

## 5. Fig 6: where the CO change sits on the tree, and what it says about 4B

- **Workbook** (`P99 Fig 6`): "Hominoids", "CO-dense 4A band", Loss.
- **Paper**: the annotation "Loss of CO-dense 4A band; increased CO activity in 4B" has two arrows, one at the
  node where *Hylobates* branches off and one at the node where *Pongo* branches off. *Hylobates* and *Gorilla*
  carry a "?". Discussion (p. 11605): there are no CO data for gibbons or gorillas, so it is open whether the change
  "evolved before or after the lineage leading to gibbons separated".
- **My reading**: the loss is shown for the great apes and humans, with its position before or after the gibbon
  split left open; it is not asserted for all hominoids. The same annotation also records increased CO activity in
  4B, which the workbook leaves out. Coded *Pongo*, *Pan* and *Homo* as 4A band absent and 4B band present
  (inferred from the tree), and *Hylobates* and *Gorilla* as uncertain.
- **In the build**: `Preuss_etal_1999_Fig6` snapshot rows 3 and 5 (the "?" labels) and 10-11 (the annotation).
