# Hevner_etal_1995_Figure31

**Item name** `Hevner_etal_1995_Figure31` · **Item number** `Fig. 31` · **Item encoded** `10.1016%2F0306-4522(94)00514-6_Figure31` (derived; the registry is the authority) — NOT yet registered in `__ReadMe.xlsx`; registry row to paste: `Hevner_etal_1995_Figure31_registry_row.xlsx`.

Hevner, R. F., Liu, S., & Wong-Riley, M. T. T. (1995). A metabolic map of cytochrome oxidase in the rat brain: histochemical, densitometric and biochemical studies. *Neuroscience*, 65(2), 313-342. <https://doi.org/10.1016/0306-4522(94)00514-6>

**Item full original title:** Fig. 31. CO activity in the whole rat brain, and in eight large regions of gray matter and three white matter areas. A and B show CO activity content (by tissue wet weight) and CO specific activity, respectively, as determined by biochemical assays of tissue homogenates (n = 6 for whole brains; n = 3 for corpus callosum; n = 4 for visual cortex and trigeminal nerve; n = 5 for all other regions). C shows the optical density of CO histochemical staining, as determined densitometrically through a 625 µm aperture in the same large regions of brain (n = 4 for visual cortex; n = 6 for all other regions). … All data shown as mean ± S.E.M. N.D., not determined. (p. 336)

## Source

PDF in this folder: `Hevner-1995-A metabolic map of cytochrome oxid.pdf` (30 pages; journal pp. 313-342; PDF page = journal page − 312). A scanned
Elsevier article with an OCR text layer that is legible for words but garbles ± (`___`, `_+`, `-I-`) and some digits; every number used here was
checked against a 300-dpi (text) or 600-dpi (figures) render of the page image.

**DOI note.** The first page prints the PII `0306-4522(94)00514-1`; CrossRef resolves that string to nothing (404, checked 2026-11-18) and resolves this article to `10.1016/0306-4522(94)00514-6` (title, volume 65, pp. 313-342, 1995 confirmed). The registry row therefore uses `…00514-6`; expected Item encoded `10.1016%2F0306-4522(94)00514-6_<locus>`. The owner should confirm the DOI when pasting.

**Quantitative content of the paper (complete inventory).** The paper prints **no table**. Quantitative data exist in three places only:
(1) **Fig. 31, p. 336** — bars with S.E.M. for whole brain + 8 gray-matter + 3 white-matter regions in three measures (A CO activity content, B CO
specific activity, C optical density at 625 µm aperture), plus scatter panels D/E of C against A and B (the same numbers, not digitised separately);
(2) **Fig. 32, p. 338** — bars with S.E.M. for the optical density of 11 neuron types (2 µm aperture); (3) **numbers in running text** (pp. 313, 314,
335-341): whole-brain assays (brain weight, protein, activity content, specific activity, turnover number), the two regional maxima, gray/white ratio
statements, r² of five regressions, the CA3/CA1 and mesencephalic-V/dentate comparisons, sample sizes, and a few values cited from other work.
Items: `Hevner_etal_1995_Figure31`, `Hevner_etal_1995_Figure32`, `Hevner_etal_1995_Text`.

**Laminar values: none are quantified.** The Results state that "smaller brain structures (such as neurons or cortical layers) … were studied by
histochemistry and densitometry only" (p. 335), and the only densitometry on small structures is the perikaryal series of Fig. 32. No cortical
layer is given an optical density, activity or ratio anywhere in the paper. The laminar content is **ordinal only** (Results p. 335 "Cerebral cortex",
Fig. 29 legend p. 332, Discussion p. 341):

| cortical area (as printed) | ordinal laminar statement | where |
|---|---|---|
| most areas, e.g. forelimb/hindlimb sensorimotor cortex | layers III-IV darkest | p. 335; Figs 7-9, 14-16, 29 |
| forelimb/hindlimb sensorimotor cortex | layer IV granular zones slightly darker than dysgranular/agranular zones | p. 335; Fig. 29 legend p. 332 |
| primary somatosensory (barrel) cortex | barrels (layer IV) dark, septa lighter | p. 335; Figs 3, 10, 13-16 |
| entorhinal cortex | darkest in layer II; layer V in the ventral medial portion | p. 335; Figs 2, 3, 10, 18-21 |
| lateral entorhinal cortex | layer II cell islands dark, interstices less reactive | p. 335, p. 339; Figs 1, 2, 20 |
| cortex in general (CO vs 2-DG concordance) | layers III and IV high by both methods | p. 341 |
| area-level ordinal ranking | highest: hindlimb/forelimb sensorimotor, primary somatosensory, primary visual (monocular and binocular), primary auditory; moderate: piriform; relatively low: parietal area 2, occipital area 2, temporal area 3; retrosplenial relatively dark; cingulate moderate | pp. 334-335 |

These are a roadmap for a possible future constructed ordinal table; **no numbers were invented for them** and no such item was built.

## Pipeline

```
Source (PDF page 24 = journal p. 336, rendered at 600 dpi)
  -> Hevner_etal_1995_Figure31_snapshot.R   digitises the bars and writes the frozen CONSTRUCTED snapshot
  -> Hevner_etal_1995_Figure31_snapshot.csv   FROZEN: 36 rows x 21 cols (12 positions x 3 panels, incl. the printed N.D.)
  -> Hevner_etal_1995_Figure31.R   clean + table checks
  -> Hevner_etal_1995_Figure31.csv   35 rows x 23 cols  ("use this"; long: one row per bar)
  -> __Public/comparative-data/10.1016%2F0306-4522(94)00514-6_Figure31.tsv   (written by the build once the item is registered)
  -> reference_tables/Hevner_etal_1995_Figure31_definitions.csv
  -> internal_checks/Hevner_etal_1995_Text_internal_check.R   cross-item check against the Text item (see Table checks)
```

## Who read the values, when, and how it was checked

**Constructed snapshot from a figure** (HOWTO *When there is no table*). Values were **digitised programmatically** by `Hevner_etal_1995_Figure31_snapshot.R` (written by an AI assistant, Claude, 2026-11-18): the page is rendered at 600 dpi with `pdftools` (poppler); the three plot frames, the inner tick marks of both y axes, each bar's top edge (first row with ≥ 80 % dark coverage across the bar) and each S.E.M. cap (centre of the cap line) are detected from the binarised image; pixel rows are converted to values by a linear fit to **all interior ticks** (A: 25-175 by 25; B: 250-1750 by 250; C: 0.005-0.05 by 0.005), interpolated between the left and right axes at the bar's x position to absorb the ≈ 7 px left-right scan skew. **Calibration:** 1 px = 0.225 mU/mg tissue (A), 2.51 mU/mg protein (B), 0.000069 OD (C); tick-fit residual ≤ 0.63 (A), ≤ 7.5 (B), ≤ 0.0002 (C) units. **Legibility:** bars and caps are sharp black on white at 600 dpi; the only non-bar position is the printed `N.D.` (whole brain, panel C). The region labels, tick labels, legend n and the four text-printed values are the only literals typed in the script. The whole digitisation was **cross-checked with an independent implementation** (pypdfium2 render + numpy, in this session): every bar agreed within one pixel (A ≤ 0.3, B ≤ 2, C ≤ 0.0001 units).

The build script reads the frozen snapshot and contains no table values. It was run with `Rscript` (conda env `evom1-r`, R 4.5.3, `LC_ALL=en_US.UTF-8`)
from a clean session on 2026-11-18. The run stopped, as expected for an unregistered item, at the registry lookup ("Expected one registered item row")
after writing the analysis CSV; the public TSV is written once the registry row is pasted and `_tools/file_list.R` has run.

### Digitised vs printed

Four bars of this figure also have **values printed in the RESULTS text**; they sit in the snapshot's `mean_printed_in_text` / `dispersion_printed_in_text` columns (`value_source` says so) and **take precedence** over the digitised number:

| bar | digitised mean ± S.E.M. | printed (page) | note |
|---|---|---|---|
| A whole brain | 158.0 ± 5.1 | 158 ± 12 (p. 335, mean ± S.D.) | S.D./√6 = 4.9 ✓ |
| A cerebellar cortex | 157.8 ± 15.9 | 157 ± 17 (p. 336, mean ± S.E.M.) | ✓ |
| B whole brain | 1767 ± 31 | 1760 ± 100 (p. 335, mean ± S.D.) | S.D./√6 = 41; plotted bar ≈ 1767-1771 (the bar top sits 8.5 px above the 1750 minor tick): figure vs text differ by ≈ 0.5 % |
| B visual cortex | 1770 ± 132 | 1760 ± 150 (p. 336, mean ± S.E.M.) | S.E.M. cap 7 px short of 150 |

Panels D and E replot C against A and B and carry the printed r² = 0.929 / 0.946 (Text item rows 30-31); they were not digitised.

## Table checks

Result of an actual R run (2026-11-18): **11 pass, 2 mismatch, 0 not evaluable**, of 13 checks (own snapshot only).

| check | basis | observed | printed | difference | tolerance | status |
|---|---|---|---|---|---|---|
| `anchor_A_whole_brain_mean` | digitised vs p. 335 '158' | 158.0 | 158 | 0 | 1.0 | pass |
| `anchor_A_whole_brain_sem` | digitised S.E.M. vs printed S.D. 12/√6 | 5.1 | 4.90 | 0.20 | 1.0 | pass |
| `anchor_A_cerebellar_cortex_mean` | digitised vs p. 336 '157' | 157.8 | 157 | 0.8 | 1.0 | pass |
| `anchor_A_cerebellar_cortex_sem` | digitised vs printed 17 | 15.9 | 17 | −1.1 | 1.5 | pass |
| `anchor_B_whole_brain_mean` | digitised vs p. 335 '1760' | 1767 | 1760 | 7 | 15 | pass |
| `anchor_B_whole_brain_sem` | digitised S.E.M. vs printed S.D. 100/√6 | 31 | 40.8 | −9.8 | 10 | pass |
| `anchor_B_visual_cortex_mean` | digitised vs p. 336 '1760' | 1770 | 1760 | 10 | 15 | pass |
| `anchor_B_visual_cortex_sem` | digitised vs printed 150 | 132 | 150 | −18 | 15 | **mismatch** (kept as digitised; printed value takes precedence) |
| `highest_A_is_cerebellar_cortex` | rank of cerebellar cortex among 11 regions (p. 336) | 1 | 1 | 0 | 0 | pass |
| `highest_B_is_visual_cortex` | rank of visual cortex among 11 regions (p. 336) | 1 | 1 | 0 | 0 | pass |
| `gray_white_ratio_A` | mean gray / mean white vs 'about 10- to 12-fold' (midpoint 11) | 10.69 | 11 | −0.31 | 1 | pass |
| `gray_white_ratio_B` | mean gray / mean white vs 'about eight- to 10-fold' (midpoint 9) | 8.83 | 9 | −0.17 | 1 | pass |
| `gray_white_ratio_C` | mean gray / mean white vs 'about four to five times' (midpoint 4.5) | 3.85 | 4.5 | −0.65 | 0.5 | **mismatch** (authors' basis for the ratio not stated) |

Cross-item: `internal_checks/Hevner_etal_1995_Text_internal_check.csv` (13 pass, 3 mismatch of 16; the same three discrepancies).

## Data role

**primary**: all values are this paper's own measurements (biochemical assays and densitometry). Observation level: **group mean across animals per region** (n = 3-6); gray-matter regions did not differ significantly from one another in any measure (p. 337), white-matter regions neither; every gray-white pairwise comparison P < 0.001. Not a species mean.

## Units

Kept as printed. 1 U = 1 µmol cytochrome c oxidized/min, so mU/mg tissue (wet weight) = U/g tissue; mU/mg protein; optical density in arbitrary, background-subtracted units (625 µm aperture, ×4 objective). `sd` = sem × √n is derived.

## Species names

The paper prints no binomial: EXPERIMENTAL PROCEDURES p. 314 names "21 adult albino rats" (histochemistry: male Sprague-Dawley, 300-400 g;
biochemistry: male and female Sprague-Dawley and Munich-Wistar, 220-440 g; the biochemistry animals had received intrarenal diltiazem in a separate
study, "normal blood pressures were maintained"). `species_as_published` carries "albino rat"; `Species` = Rattus norvegicus through four rows
(`albino rat`, `Sprague-Dawley rat`, `Munich-Wistar rat`, `rat` → NCBI taxid 10116, `source_publication = Hevner_etal_1995`) appended to
`_keys/General/species_key.csv` on 2026-11-18; the build stops if the key filter returns no rows.

## Human visual check of snapshot

Pending human RA. The AI-assistant reading and checks are described above. A person still needs to lay the snapshot beside the page (for a figure
item: compare each digitised mean with the bar against the axis, and the four/two text-printed anchors), and record `DDMMYYYY_initials` in the
`Human visual check of snapshot` column.

## Public completion and replot (2026-11-26)

The item is now present in the live registry. Running `LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 Rscript --vanilla Hevner_etal_1995/Hevner_etal_1995_Figure31.R` wrote its 35-row public TSV under the registered encoded name. The same two source-versus-extraction checks described above remain mismatches; no values were changed to force agreement.

Run `LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 Rscript --vanilla Hevner_etal_1995/Hevner_etal_1995_Figure31_replot.R` to regenerate `Hevner_etal_1995_Figure31_replot.png` directly from the analysis CSV. The base-R plot keeps the published A/B/C order, 12 regional positions, axis units and scales, and the digitised S.E.M. bars. Panel C retains whole brain as N.D. Panels D/E are omitted because they repeat the regional measurements as scatterplots and were not separately extracted. The replot was inspected against PDF page 24: the three bar profiles, gray/white separation, and source order agree. This automated visual comparison is not human signoff.

<!-- errata:begin -->
<!-- errata:end -->
