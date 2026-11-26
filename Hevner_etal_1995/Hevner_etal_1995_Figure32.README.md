# Hevner_etal_1995_Figure32

**Item name** `Hevner_etal_1995_Figure32` · **Item number** `Fig. 32` · **Item encoded** `10.1016%2F0306-4522(94)00514-6_Figure32` (derived; the registry is the authority) — NOT yet registered in `__ReadMe.xlsx`; registry row to paste: `Hevner_etal_1995_Figure32_registry_row.xlsx`.

Hevner, R. F., Liu, S., & Wong-Riley, M. T. T. (1995). A metabolic map of cytochrome oxidase in the rat brain: histochemical, densitometric and biochemical studies. *Neuroscience*, 65(2), 313-342. <https://doi.org/10.1016/0306-4522(94)00514-6>

**Item full original title:** Fig. 32. Optical density (OD) of CO histochemical staining in different neuron types in the rat brain (n = 5 rats). The optical density was determined densitometrically through a 2 µm aperture. Significant differences (P < 0.05, one-factor ANOVA with least significant difference test) were found on all pairwise comparisons between cell types, except for the following: … (p. 338)

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
Source (PDF page 26 = journal p. 338, rendered at 600 dpi)
  -> Hevner_etal_1995_Figure32_snapshot.R   digitises the bars and writes the frozen CONSTRUCTED snapshot
  -> Hevner_etal_1995_Figure32_snapshot.csv   FROZEN: 11 rows x 19 cols
  -> Hevner_etal_1995_Figure32.R   clean + table checks
  -> Hevner_etal_1995_Figure32.csv   11 rows x 23 cols  ("use this")
  -> __Public/comparative-data/10.1016%2F0306-4522(94)00514-6_Figure32.tsv   (written by the build once the item is registered)
  -> reference_tables/Hevner_etal_1995_Figure32_definitions.csv
  -> internal_checks/Hevner_etal_1995_Text_internal_check.R   cross-item check against the Text item
```

## Who read the values, when, and how it was checked

**Constructed snapshot from a figure.** Horizontal bars digitised programmatically by `Hevner_etal_1995_Figure32_snapshot.R` (AI assistant, Claude, 2026-11-18): 600-dpi `pdftools` render; plot frame, inner tick marks of the bottom and top x axes (0.1-0.6 by 0.1), each bar's right edge (last column with ≥ 80 % dark coverage) and S.E.M. cap centre detected from the binarised image; linear fit to the six interior ticks interpolated between the two axes at the bar's y position. **Calibration:** 1 px = 0.00043 OD; tick-fit residual ≤ 0.0019 OD (the 0.3 tick sits ≈ 4 px off the regular spacing). **Legibility:** sharp bars and caps; all 11 bars and caps detected. The cell-type labels, tick labels, legend n and the two text-printed anchors (CA3, CA1) are the only literals in the script. Cross-checked with an independent pypdfium2/numpy digitisation: all 11 bars within one pixel.

The build script reads the frozen snapshot and contains no table values. It was run with `Rscript` (conda env `evom1-r`, R 4.5.3, `LC_ALL=en_US.UTF-8`)
from a clean session on 2026-11-18. The run stopped, as expected for an unregistered item, at the registry lookup ("Expected one registered item row")
after writing the analysis CSV; the public TSV is written once the registry row is pasted and `_tools/file_list.R` has run.

### Digitised vs printed

| bar | digitised mean ± S.E.M. | printed (p. 337, mean ± S.E.M.) |
|---|---|---|
| CA3 hippocampal pyramid | 0.4951 ± 0.0167 | 0.495 ± 0.017 |
| CA1 hippocampal pyramid | 0.3564 ± 0.0050 | 0.357 ± 0.005 |

The printed values take precedence (`mean_printed_in_text`). The legend lists the 11 pairwise comparisons that were **not** significant; all others were (P < 0.05, ANOVA/LSD). These were not encoded as data.

## Table checks

Result of an actual R run (2026-11-18): **6 pass, 1 mismatch, 0 not evaluable**, of 7 checks.

| check | basis | observed | printed | difference | tolerance | status |
|---|---|---|---|---|---|---|
| `anchor_CA3_mean` | digitised vs p. 337 '0.495' | 0.4951 | 0.495 | 0.0001 | 0.0015 | pass |
| `anchor_CA3_sem` | digitised vs printed 0.017 | 0.0167 | 0.017 | −0.0003 | 0.0025 | pass |
| `anchor_CA1_mean` | digitised vs p. 337 '0.357' | 0.3564 | 0.357 | −0.0006 | 0.0015 | pass |
| `anchor_CA1_sem` | digitised vs printed 0.005 | 0.0050 | 0.005 | 0 | 0.0025 | pass |
| `mesV_vs_dentate_percent` | 100 × (mes. V / dentate − 1) vs p. 337 '78% higher' | 76.67 | 78 | −1.33 | 1.0 | **mismatch** (marginal; unrounded means in the paper) |
| `bars_descend_as_printed` | adjacent pairs out of descending order | 0 | 0 | 0 | 0 | pass |
| `range_almost_two_fold` | max/min vs Abstract 'nearly a two-fold range' | 1.77 | 2 | −0.23 | 0.3 | pass |

## Data role

**primary**: this paper's own densitometry. Observation level: group mean across 5 animals per cell type (5 sections per animal); not a species mean. Note the cell types are perikaryal readings (2 µm aperture) and are **not** comparable in absolute value with the 625 µm regional optical densities of Fig. 31C (different aperture, different magnification, neuropil excluded).

## Units

Optical density, arbitrary background-subtracted units, as printed. `sd` = sem × √5 derived.

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

The item is now present in the live registry. Running `LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 Rscript --vanilla Hevner_etal_1995/Hevner_etal_1995_Figure32.R` wrote its 11-row public TSV under the registered encoded name. The marginal 76.67% versus 78% text comparison noted above remains a mismatch; no data were adjusted.

Run `LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 Rscript --vanilla Hevner_etal_1995/Hevner_etal_1995_Figure32_replot.R` to regenerate `Hevner_etal_1995_Figure32_replot.png` directly from the analysis CSV. The base-R plot keeps the published horizontal-bar order, optical-density axis scale and units, and the digitised S.E.M. bars. No plotted data are omitted. The replot was inspected against PDF page 26 and matches the descending shape and the longer S.E.M. bar on CA3. This automated visual comparison is not human signoff.

<!-- errata:begin -->
<!-- errata:end -->
