# Taniguchi et al. (2022) — reported findings

**Source paper.** Taniguchi, M., Iwahashi, M., Oka, Y., Tiong, S. Y. X., & Sato, M. (2022).
Fezf2-positive fork cell-like neurons in the mouse insular cortex. *PLoS ONE*, 17(9), e0274170.
https://doi.org/10.1371/journal.pone.0274170

**What is being transcribed.** Not a printed data table. The paper's own Table 1 is a summary of
*other* people's reports on molecules expressed in VENs and fork cells — a roadmap, not data, and
per the repo rule it is not ingested. The paper's actual findings are in the text and figures, so
the snapshot records those, one row per observation, each carrying the figure or section it comes
from.

## Files in this folder

| file | what it is |
| --- | --- |
| `Taniguchi_etal_2022_Findings_snapshot.csv` | **populated** — nine reported observations, each with its figure reference |
| `Taniguchi_etal_2022_Findings.csv` | cleaned, analysis-ready ("use this") |
| `Taniguchi_etal_2022_Findings.R` | script that turns the snapshot into the clean CSV |
| `Taniguchi_etal_2022_Findings.ReadMe.md` | this file |

## Pipeline

`Source → Snapshot → Data readable → (Species notes) → Online database`

## Snapshot

**Method.** Entered from the full text and figure legends of the open-access article. Detail strings
are the authors' own wording, lightly trimmed. **Every row carries `Figure_or_section`** — this
follows the `Heffner_etal_2020` precedent in `__merging_sensory`, where only the values the paper
states in its own text were admitted because its comparative figure printed no per-point reference.

**Nine rows, three of them negative.** The negatives matter as much as the positives here and are
recorded as `Present = FALSE` rather than left blank: no bipolar VEN morphology, no VMAT2 in cortex,
no GABRQ in cortex. A blank would read as "not looked for".

**Not in the snapshot.**
- The paper's Table 1 (literature summary of VEN/fork cell markers). Roadmap, not data. It is the
  list of primaries someone should build if we ever want the marker literature itself: Allman et al.
  2010, Stimpson et al. 2011, Dijkstra et al. 2018, Yang et al. 2019, Cobos & Seeley 2015, Hodge et
  al. 2020.
- Methods parameters — antibody dilutions, probe primers, section thicknesses. Method description,
  not comparative data.

## Cleaning applied (in `.R`)

- Column names → snake_case; `Present` to logical.
- `identification_basis` derived per row: `morphology` for the two morphological features,
  `marker` for the expression rows. **This is the column the whole folder exists to justify.**
- `region_sampled` mapped onto the controlled set, with `GI` / `DI` / `AI` retained in
  `region_printed` because the insular subdivisions are exactly what the paper is distinguishing.
- Rows sourced to the Allen Mouse Brain Atlas rather than the authors' own histology are marked
  `data_role = "secondary"`. ADRA1A, VMAT2 and GABRQ are database lookups, not measurements made in
  this study, and they should not be treated as this paper's primary evidence.

## Notes for the database

**Why a negative result is worth a folder.** Because it fixes the coding rule for every VEN source
that follows. A `VEN_present` boolean would put mouse and chimpanzee in the same bucket or in
opposite buckets depending entirely on which criterion you used, and neither answer would be right:
mouse has **no bipolar VEN morphology** but **does** have fork-cell-like neurons carrying Fezf2, with
NMB and GRP present in the same region. Banovac et al. (2021) argue the identification of these cells
in non-primates should rest on dendritic and axonal morphology or on specific marker combinations,
not on morphology alone — and this paper is the worked example of why. So the term needs
`VEN_identification_basis` alongside it, never blank.

**Where it sits in the argument.** This is the bottom end of a 25-year retreat. Nimchinsky et al.
(1999) called VENs "a neuronal morphologic type unique to humans and great apes"; they were then
reported in elephants (Hakeem et al. 2009), cetaceans (Butti et al. 2009), macaque anterior insula
(Evrard et al. 2012), and artiodactyls and perissodactyls (Raghanti et al. 2015, who conclude they
are "not unique to highly encephalized or socially complex species"). This paper finds the molecular
and partial morphological signature in a mouse. **Every proposed structural signature of human or
great-ape distinctiveness in this literature has been found further down the tree**, which is the
same shape as Herculano-Houzel's result that the human brain is a linearly scaled-up primate brain.

**Why it belongs in this project and not a different one.** `Bauernfeind_etal_2013` already gives
insular cortex volumes by subregion, fully built. The repo measures the region and has no cell-type
data inside it. And the insula is the one cortical region where the comparative anatomy touches the
machine-consciousness reading directly: Dehaene and Naccache's stated reason for doubting Claude is
that it lacks "a body occupying a specific location in space, and capable of emitting pleasure or
pain signals", and the insula is where those signals become cortical. Seth's embodiment argument is,
anatomically, an argument about this region.

**n = 1 species, and it is *Mus musculus*.** Flag it. High value for setting the coding rule and for
the argument, no value in any regression.

## Public export

Not generated yet. Add the `__ReadMe.xlsx` row (`Item name = Taniguchi_etal_2022_Findings`,
`Item encoded` derived from DOI `10.1371/journal.pone.0274170`) and re-run the `.R`.
