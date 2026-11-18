# Hevner_etal_1995_Text

**Item name** `Hevner_etal_1995_Text` · **Item number** `data from text` · **Item encoded** `10.1016%2F0306-4522(94)00514-6_Text` (derived; the registry is the authority) — NOT yet registered in `__ReadMe.xlsx`; registry row to paste: `Hevner_etal_1995_Text_registry_row.xlsx`.

Hevner, R. F., Liu, S., & Wong-Riley, M. T. T. (1995). A metabolic map of cytochrome oxidase in the rat brain: histochemical, densitometric and biochemical studies. *Neuroscience*, 65(2), 313-342. <https://doi.org/10.1016/0306-4522(94)00514-6>

**Item full original title:** Numeric values printed in the running text: Abstract (p. 313), EXPERIMENTAL PROCEDURES (p. 314), RESULTS (pp. 335-338) and DISCUSSION (pp. 339-341).

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
Source (PDF pages 1, 2, 23-29 = journal pp. 313, 314, 335-341)
  -> Hevner_etal_1995_Text_snapshot.R   writes the frozen CONSTRUCTED snapshot (hand-typed printed-layout block)
  -> Hevner_etal_1995_Text_snapshot.csv   FROZEN: 49 rows x 12 cols (header + 48 printed values)
  -> Hevner_etal_1995_Text.R   parse + classify + table checks
  -> Hevner_etal_1995_Text.csv   48 rows x 26 cols  ("use this")
  -> __Public/comparative-data/10.1016%2F0306-4522(94)00514-6_Text.tsv   (written by the build once the item is registered)
  -> reference_tables/Hevner_etal_1995_Text_definitions.csv
  -> internal_checks/Hevner_etal_1995_Text_internal_check.R / .csv   cross-item check against Figure31 / Figure32
```

## Who read the values, when, and how it was checked

**Hand transcription** (HOWTO method 5) by an AI assistant (Claude) on 2026-11-18. The whole Results and Discussion (and the Abstract and Experimental Procedures) were read from the text layer; every sentence carrying a number was then re-read on a 300-dpi render of the page image to restore ± and confirm each digit (the OCR layer prints `1.69 ___ 0.14`, `158+ 12`, `0.495 ___ 0.017`, `157 -I- 17`, `1760 _+ 150`, etc.). The values were typed as a verbatim printed-layout block into `Hevner_etal_1995_Text_snapshot.R` (freezes, refuses to overwrite a differing copy).

The build script reads the frozen snapshot and contains no table values. It was run with `Rscript` (conda env `evom1-r`, R 4.5.3, `LC_ALL=en_US.UTF-8`)
from a clean session on 2026-11-18. The run stopped, as expected for an unregistered item, at the registry lookup ("Expected one registered item row")
after writing the analysis CSV; the public TSV is written once the registry row is pasted and `_tools/file_list.R` has run.

### Constructed snapshot

One row per printed value, with page, section, the sentence quoted, the value lexeme and dispersion as printed, units, the quantity, the structure/subjects named, the n stated *in that sentence* and the printed reference number when the paper cites the value. A sentence with two values gives two rows; a printed range ("eight- to 12-fold", "300-400 g") is one row, parsed to `value_low`/`value_high` by the build. Restatements are kept (`value_status = restatement`, `restates_text_row`).

**What was captured (48 rows):** whole-brain assays p. 335 (brain weight 1.69 ± 0.14 g S.D., protein 89.9 ± 6.4 mg/g ≈ 9 %, activity content 158 ± 12 mU/mg tissue, specific activity 1760 ± 100 mU/mg protein, turnover 479 s⁻¹, cited cytochrome aa₃ 5.5 nmol/g); regional maxima p. 336 (cerebellar cortex 157 ± 17; visual cortex 1760 ± 150); gray/white ratio statements (8-12, 10-12, 8-10, 4-5 fold and their restatements); r² = 0.929 / 0.946 (OD vs biochemistry) and 0.32 / 0.30 / 0.27 (Sokoloff 1977 2-DG vs CO, 7 regions); cellular values p. 337 (CA3 0.495 ± 0.017, CA1 0.357 ± 0.005, mesencephalic V 78 % above dentate, "nearly two-fold" range); sample descriptors p. 314/335 (21 rats = 7 + 14; weights 300-400 g / 220-440 g; n = 6/4 regional, 5 cellular, 6 whole brains, 8 dissected; 11 regions; 11 neuron types; 7 regions in the regression); cited values (2-DG gray/white ≈ 3-fold and 3.5-/4-fold gray-matter range, Sokoloff 1977 ref 30; Darriet 1986 ≈ 10-fold, ref 7; 40-60 % of ATP for ion pumping, ref 10); the authors' aperture-area approximation (≈ 10-fold).

**Deliberately not rows** (method parameters, listed in the definitions `Method:excluded_numbers`): aperture diameters 625 / 2 / 200 µm, section thickness 30 µm, sampling and reading counts, objectives, doses, buffer and homogenate concentrations, storage temperature, scale bars, P thresholds, grant numbers. One cross-species statement has no number and could not be a row: "Levels of CO activity in rat brain … are several-fold higher than in human brain" (p. 340, refs 16, 18).

## Table checks

Result of an actual R run (2026-11-18): in-script **12 pass, 0 mismatch, 0 not evaluable** of 12; cross-item (`internal_checks/`) **13 pass, 3 mismatch** of 16.

| check | basis | observed | printed | difference | tolerance | status |
|---|---|---|---|---|---|---|
| `protein_percent` | 89.9 mg/g = 8.99 % vs 'about 9%' | 8.99 | 9 | −0.01 | 0.5 | pass |
| `specific_activity_from_content` | 158 / 89.9 × 1000 vs 1760 mU/mg protein | 1757.5 | 1760 | −2.5 | 15 | pass |
| `turnover_number` | 158 µmol/min/g ÷ 5.5 nmol aa₃/g ÷ 60 vs 479 s⁻¹ | 478.8 | 479 | −0.2 | 6 | pass |
| `n_sum` | 7 + 14 vs 21 | 21 | 21 | 0 | 0 | pass |
| `n_biochem_split` | 6 + 8 vs 14 | 14 | 14 | 0 | 0 | pass |
| `restatement_range_4/29/43/46` | ranges restate row 1 (8-12 fold) | — | — | 0 | 0 | 4 × pass |
| `restatement_three_fold`, `restatement_two_fold`, `restatement_n6` | rows 45/33/15 vs 3/2/13 | — | — | 0 | 0 | 3 × pass |

Cross-item (text vs digitised bars): 13 pass; mismatches are the visual-cortex S.E.M. (150 printed vs 132 digitised), the 78 % statement (76.7 % from the bars) and the OD gray/white "four to five times" (3.85 by mean-of-means). Printed values take precedence; nothing was altered.

## Data role

**both**: this paper's own values are `data_role = primary`; values cited from refs 3, 7, 10 and 30 (and the restatement of the cited 3-fold) are `secondary` — do not merge them as Hevner 1995 data. The CO/2-DG regressions (rows 38-40) are this paper's result computed on cited glucose data. The whole-brain weight (row 16, 1.69 ± 0.14 g S.D., n = 6, adult albino rats of mixed sex and strain after intrarenal diltiazem) is a usable **Brain_Mass.mg = 1690** but note the animals' origin.

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

<!-- errata:begin -->
<!-- errata:end -->
