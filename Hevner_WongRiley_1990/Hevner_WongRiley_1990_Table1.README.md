# Hevner_WongRiley_1990_Table1

**2026-11-26 public completion.** The item now has an exact row in the main `__ReadMe.xlsx` registry. Running `LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 Rscript --vanilla Hevner_WongRiley_1990/Hevner_WongRiley_1990_Table1.R` wrote `__Public/comparative-data/10.1523%2FJNEUROSCI.10-04-01331.1990_Table1.tsv`. Earlier “not registered” or “public TSV pending” statements below describe the initial build date. Human source review remains as separately recorded.


**Item name** `Hevner_WongRiley_1990_Table1` · **Item number** `Table 1` · **Item encoded** `10.1523%2FJNEUROSCI.10-04-01331.1990_Table1` (derived; the registry is the authority — see the name mismatch below) — NOT yet registered as an item in `__ReadMe.xlsx`; registry row to paste: `Hevner_WongRiley_1990_Table1_registry_row.xlsx`.

Hevner, R. F., & Wong-Riley, M. T. T. (1990). Regulation of cytochrome oxidase protein levels by functional activity in the macaque monkey visual system. *The Journal of Neuroscience*, 10(4), 1331-1340. <https://doi.org/10.1523/JNEUROSCI.10-04-01331.1990>

**Item full original title:** Table 1. Optical densitometry of CO histochemical and immunohistochemical staining in normal and experimental striate cortex, p. 1337.

## Source

PDF in this folder: `Hevner-1990-Regulation of cytochrome oxidase p.pdf` (scanned journal pages with an OCR text layer). DOI verified against CrossRef on 2026-11-18 (`10.1523/jneurosci.10-04-01331.1990`: The Journal of Neuroscience 10(4): 1331-1340, 1990-04-01, authors Hevner RF, Wong-Riley MT) and against the running head of the PDF ("The Journal of Neuroscience, April 1990, 10(4): 1331-1340").

## Folder-name / registry-name mismatch (needs owner decision)

The registry formula for a two-author paper yields the publication name **`Hevner_WongRiley_1990`** — and `__ReadMe.xlsx` already carries a citation-only placeholder row for this paper with `Publication name = Hevner_WongRiley_1990`, `Item name = Hevner_WongRiley_1990_` (no Item number, trailing underscore, `Item encoded = 10.1523%2FJNEUROSCI.10-04-01331.1990_`, public-TSV match `notfound`). The folder the owner created is **`Hevner_WongRiley_1990`**, and per instructions it was not renamed; every file in it is named from the folder (`Hevner_WongRiley_1990_Table1*`, `Hevner_WongRiley_1990_Text*`), and `_keys/General/species_key.csv` rows use `source_publication = Hevner_WongRiley_1990`.

Consequence: once the registry row is pasted, column J will read `Hevner_WongRiley_1990_Table1`, which does **not** equal the build script's self-derived `item_name` (`Hevner_WongRiley_1990_Table1`), so the registry lookup in the build script will keep stopping. The registry is the authority; the owner must choose one of
(a) rename the folder and its files (and the `source_publication` key rows) to `Hevner_WongRiley_1990`, or
(b) keep `Hevner_WongRiley_1990` and make the registry name match (outside this build's remit).
Nothing was renamed here. (Other publication names currently without a folder: `Hardus_etal_2008`, `Heffner_Heffner_2010_a`, `Heffner_etal_2001_b`, `Koay_etal_1998_a`, `Lewitus_etal_2012_a`, `Püschel_etal_2026`, `Smaers_etal_2011_a`, `Young_etal_2013_a`.)

## What quantitative CO content the paper has, and what was captured

| locus | content | captured? |
|---|---|---|
| **Table 1** (p. 1337) | relative optical density (mean ± SD) of CO histochemical and CO immunohistochemical staining: normal layers 2-3 puff vs interpuff; TTX layer 4C dark vs light ocular dominance column | **yes — `Hevner_WongRiley_1990_Table1`** (8 cells) |
| RESULTS "Densitometric analyses" (pp. 1335, 1337) | the same contrasts as percentages: puffs 32 % (histo) / 19 % (immuno) darker than interpuffs; light columns 20 % (histo) / 21 % (immuno) decreased vs dark columns; p < 0.001 | **yes — `Hevner_WongRiley_1990_Text`** (4 values; cross-checked against Table 1, 4/4 pass) |
| Figures 2-6 | photomicrographs only (retina, LGN, striate cortex; Nissl, histochemistry, immunohistochemistry, preimmune controls); no bar charts, no axes | nothing to digitise — no Figure item |
| LGN laminae (RESULTS p. 1333; Fig. 3) | ordinal only: normal LGN laminae all darkly reactive, superior-medial lamina 6 and lamina 3 relatively dark; TTX: laminae 2, 3, 5 pale in the LGN ipsilateral to the treated eye (1, 4, 6 contralateral), effects stronger ipsilateral than contralateral. **No numbers printed** — Table 1 covers striate cortex only, not the LGN | not captured; possible future constructed ORDINAL table (see below) |
| Striate cortex layers (RESULTS pp. 1334-1335) | ordinal only: puffs in layers 2-3; layer 4A beaded/reticulated; TTX decreases "most prominent in layer 4C, but were also visible in layers 2, 3, 4A, 5, and 6"; layers 1 and 6 sometimes more intensely stained immunohistochemically than histochemically (not consistent) | not captured (no numbers) |
| METHODS (pp. 1331-1332) | n = 7 normal *Macaca fascicularis*, 3 TTX-treated (2 *M. radiata*, 1 *M. fascicularis*); TTX 19 µg in 10 µl, twice weekly, 3-4 weeks; densitometry apertures 70 µm (30-µm sections, normal) and 150 µm (20-µm sections, TTX); 25 regions of each type per section | recorded as metadata (CSV columns `n_animals`, `n_readings`; definitions `Method:*` rows) |
| DISCUSSION (p. 1339) | CO degradation half-life "approximately 7-10 d in vivo at least in the rat liver (Ip et al., 1974)" — cited, not CO in the visual system | not captured (cited value, off-topic) |

**Laminar caveat for our use (CO as a layer-resolved metabolic proxy).** Table 1 is *not* a laminar CO profile. The control block normalises each section to interpuff = 1.00 *within layers 2-3*; the TTX block normalises to dark column = 1.00 *within layer 4C*. The two blocks are therefore not comparable with each other, and no between-layer CO value is printed anywhere in the paper. The only CONTROL quantity is the puff/interpuff ratio in layers 2-3 (1.32 by activity, 1.19 by protein). A between-layer CO profile for macaque V1 must come from another source.

**Possible future constructed ordinal table (not built; no numbers invented).** If the project wants the paper's qualitative laminar statements on record, a `Hevner_WongRiley_1990_Ordinal` item could encode, per structure x condition x stain method, the printed ordinal descriptors (e.g. LGN lamina 6 superior-medial "darkest"; TTX LGN laminae 2/3/5 "relatively pale"; V1 layer 4C "most prominent" decrease, layers 2/3/4A/5/6 "also visible"), each with its page and sentence. Decision left to the owner.

**Relation to other items:** `Hevner_WongRiley_1990_Text` (same paper; the percentages restating these ratios). Companion CO item in the repo: `WongRiley_etal_1993` (same laboratory). Metabolic-rate items it will be paired with: `Kennedy_etal_1978_Table` (macaque CMRglc), `Sokoloff_etal_1977_Table3` (rat).

## Pipeline

```
Source (PDF page 7, Table 1 at p. 1337 upper right)
  -> Hevner_WongRiley_1990_Table1_snapshot.R   writes the frozen snapshot (hand-typed printed-layout block)
  -> Hevner_WongRiley_1990_Table1_snapshot.csv   FROZEN: 10 rows x 3 cols
  -> Hevner_WongRiley_1990_Table1.R   clean + parse + table checks
  -> Hevner_WongRiley_1990_Table1.csv   8 rows x 25 cols  ("use this")
  -> __Public/comparative-data/10.1523%2FJNEUROSCI.10-04-01331.1990_Table1.tsv   (written by the build once the item is registered under a matching Item name)
  -> reference_tables/Hevner_WongRiley_1990_Table1_definitions.csv
  -> internal_checks/Hevner_WongRiley_1990_Text_internal_check.R / .csv   (cross-item check, Text vs Table 1)
```

## Who read the values, when, and how it was checked

**Hand transcription** (HOWTO method 5) by an AI assistant (Claude) on 2026-11-18 from a 200-dpi render of PDF page 7 (`pypdfium2` via the pdf-explore helpers), checked cell by cell against a zoomed crop of the table region (x 850-1600, y 180-780 px of the render), typed as a verbatim printed-layout block into `Hevner_WongRiley_1990_Table1_snapshot.R` (freezes, refuses to overwrite a differing copy). The PDF's OCR text layer reads the words but prints the ± signs as `*`, `f`, `k`, `+` and interleaves the two value columns ("Interpuff 1.00 * 0.05 / Puff 1.32 f 0.04 / ... 1.00 * 0.04 / 1.19 * 0.04"); it was used only to cross-read words, never values. All four value rows were read along the row (label -> histochemistry -> immunohistochemistry) against the crop; both header tiers and the footnote were read from the same crop.

The build script `Hevner_WongRiley_1990_Table1.R` reads the frozen file and contains no table values. It was run with `Rscript` (conda env `evom1-r`, `LC_ALL=en_US.UTF-8` — under a C locale R truncates ± and µ on write) from a clean session on 2026-11-18. The run stopped, as expected for an unregistered item, at the registry lookup ("Expected one registered item row for Hevner_WongRiley_1990_Table1") after writing the analysis CSV; the public TSV is written once the registry row is pasted, `file_list.R` has run, and the Item-name mismatch above is resolved. (The 50+ warnings printed by that run are readxl's "Expecting logical in AN/AO" type guesses on the registry's Data-series columns, not from this item.)

### Structure of the snapshot and of the analysis CSV

* One snapshot row per printed row: caption; header tier 1 (row-label header on three printed lines, kept with line breaks; the spanning header "Relative optical density (mean ± SD)" over columns 2-3); header tier 2 ("Histochemistry", "Immunohisto-chemistry" with its printed line-break hyphen); section heading "Normal layer 2 and 3"; Interpuff; Puff; section heading "TTX-treated (4 week) layer 4C"; Dark column; Light column; footnote (one paragraph, one cell). No footnote glyphs are printed on cells.
* The analysis CSV is **long**: one row per printed cell (region x stain method = 8 rows), ordered as the page is read. `cell_as_printed` keeps the cell verbatim; `mean_printed` / `dispersion_printed` keep the printed lexemes; `CO_relOD` is the parsed relative optical density. `condition` = **control** (normal animals) / **TTX** flags the control rows that are of primary interest. `stain_method` / `stain_target` separate CO histochemistry (enzymatic activity) from CO immunohistochemistry (protein amount). `normalisation_reference` marks the two compartments that are 1.00 by construction.
* **Observation level: printed group means per compartment x stain method**, pooled over animals and sections (the number of sections per group is not printed). Not species means.

### Conditions printed

* **control** — "Normal layer 2 and 3": puff and interpuff regions of normal striate cortex (7 *Macaca fascicularis*), tangential 30-µm sections, 70-µm-diameter apertures, 25 regions of each type per section; normalised to interpuff = 1.00. Histochemistry: puff 1.32 ± 0.04; immunohistochemistry: puff 1.19 ± 0.04.
* **TTX** — "TTX-treated (4 week) layer 4C": dark (untreated-eye) and light (TTX-eye) ocular dominance columns in layer 4C of 3 TTX-treated animals (2 *M. radiata*, 1 *M. fascicularis*; monocular intravitreal TTX, left eye, 19 µg in 10 µl, twice a week for 3 or 4 weeks), tangential 20-µm sections, 150-µm-diameter apertures; normalised to dark column = 1.00. Histochemistry: light 0.80 ± 0.02; immunohistochemistry: light 0.79 ± 0.08.
* Dispersion is SD (spanning header). Footnote: all puff/interpuff and dark-/light-column differences within a section significant (p < 0.001, Student's t test, 2-tailed); "Optical density may not be linearly proportional to CO activity or amount."

### Animals and tissue (METHODS, pp. 1331-1332)

"Seven normal (*Macaca fascicularis*) and 3 TTX-treated (2 *M. radiata*, 1 *M. fascicularis*) adult male and female monkeys". Normal brains came from animals used in an unrelated study. Euthanasia under Na pentobarbital (65 mg/kg i.p.), exsanguination; immersion fixation in 4 % paraformaldehyde (one animal perfusion-fixed, poorer immunostaining); freezing-microtome sections 20-30 µm (cortex); all striate cortex samples from the opercular surface; tangential blocks flattened before freezing. CO histochemistry per Wong-Riley (1979); CO immunohistochemistry per Hevner & Wong-Riley (1989a) with rabbit anti-calf-brain-CO IgG (reacts mainly with subunit IV).

## Table checks

In-script (own snapshot only), result of an actual R run (2026-11-18): **4 pass, 0 mismatch, 0 not evaluable** of 4.

| check | basis | observed | printed | difference | tolerance | status |
|---|---|---|---|---|---|---|
| `reference_interpuff_histochemistry` | footnote: readings normalised to yield interpuff / dark-column densities of 1.00 | 1.00 | 1.00 | 0 | 0 | pass |
| `reference_interpuff_immunohistochemistry` | same | 1.00 | 1.00 | 0 | 0 | pass |
| `reference_dark_column_histochemistry` | same | 1.00 | 1.00 | 0 | 0 | pass |
| `reference_dark_column_immunohistochemistry` | same | 1.00 | 1.00 | 0 | 0 | pass |

Cross-item check (HOWTO 7b) of the RESULTS percentages against these ratios: `internal_checks/Hevner_WongRiley_1990_Text_internal_check.csv` — **4 pass, 0 mismatch** (32, 19, 20, 21 % exactly). See the Text README.

## Data role

**primary**: all values are this paper's own measurements.

## Species names

The table prints no species. `species_as_published` is set per condition from METHODS p. 1331: "Macaca fascicularis" for the control rows; the constructed pooled label "TTX-treated macaques (2 M. radiata, 1 M. fascicularis)" for the TTX rows (the table reports one pooled value per region for the three animals of two species). Four variant rows (`Macaca fascicularis` -> Macaca fascicularis, taxid 9541; `M. fascicularis` -> Macaca fascicularis; `M. radiata` -> Macaca radiata, taxid 9548; the pooled TTX label -> genus-level anchor `Macaca sp.`, taxid 9539, basis `lump`, precedent Garey__2006 / Kay_etal_2026) were appended to `_keys/General/species_key.csv` on 2026-11-18 with `source_publication = Hevner_WongRiley_1990`; the build script resolves `Species` through them and stops if the key filter returns no rows.

## Units

Relative optical density, dimensionless, normalised to 1.00 within each section (footnote). No conversion. Not a calibrated CO activity or CO amount.

## Human visual check of snapshot

Pending human RA. The AI-assistant reading and checks are described above. A person still needs to lay the snapshot beside p. 1337, read the four value rows **across** (label, histochemistry, immunohistochemistry), confirm the two header tiers, and record `DDMMYYYY_initials` in the `Human visual check of snapshot` column.

<!-- errata:begin -->
<!-- errata:end -->
