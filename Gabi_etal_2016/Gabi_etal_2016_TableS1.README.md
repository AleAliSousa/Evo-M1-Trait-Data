# Gabi et al. 2016 — SI Table S1 (prefrontal share of cortical volume, WM cells and neurons)

**Built 2026-08-06**, once the SI Appendix (`pnas.201610178si.pdf`) was added to the folder.

## Source

Gabi, M., Neves, K., Masseron, C., Ribeiro, P. F. M., Ventura-Antunes, L., Torres, L., Mota, B.,
Kaas, J. H., & Herculano-Houzel, S. (2016). *No relative expansion of the number of prefrontal
neurons in primate and human evolution.* **PNAS 113(34):9617–9622.**
DOI **10.1073/pnas.1610178113**. Table S1 of the SI Appendix (`pnas.201610178si.pdf`, p. 2).

**Printed source → snapshot required.** `Gabi_etal_2016_TableS1_snapshot.xlsx` (sheet `TableS1`),
built by `Gabi_etal_2016_TableS1_extract_snapshot.py`. Word-coordinate extraction: the PNAS text
layer has dropped the space glyphs (`Homosapiens`, `Percentvolumeandnumber…`) and the header is
two-tier (`%V` on one baseline, `GM`/`WM` on the next).

| File | |
|---|---|
| `pnas.201610178si.pdf` | the printed source (2 pp.; Table S1 on p. 2) |
| `Gabi_etal_2016_TableS1_extract_snapshot.py` | capture script |
| `Gabi_etal_2016_TableS1_snapshot.xlsx` | **frozen source** — caption, two-tier header, 8 rows, footnote |
| `Gabi_etal_2016_TableS1.R` | reformat: snapshot → CSV + TSV |
| `Gabi_etal_2016_TableS1.csv` | analysis table, **8 species** |
| `__Public/comparative-data/10.1073%2Fpnas.1610178113_TableS1.tsv` | public TSV |

## Registry correction (2026-08-06)

The row was registered as `Item number = Table 1`. **The article has no main-text table** — Figures
1–6 only. Corrected to `Table S1`, so `Item name = Gabi_etal_2016_TableS1` and
`Item encoded = 10.1073%2Fpnas.1610178113_TableS1`. The stale `Gabi_etal_2016_Table1.*` scaffold
files have been removed.

## ⚠️ Every value is a PERCENTAGE, not a count

Four columns, all shares of a whole-cortex total:

| Column | Printed as | What it is | Range |
|---|---|---|---|
| `PrefrontalCortex_pct.VGM` | `% V_GM` | share of cortical **gray matter volume** | 6.6–13.5 |
| `PrefrontalCortex_pct.VWM` | `% V_WM` | share of subcortical **white matter volume** | 1.9–8.0 |
| `PrefrontalCortex_pct.OWM` | `% O_WM` | share of **other (non-neuronal) cells in the WM** | 2.8–14.4 |
| `PrefrontalCortex_pct.neurons` | `% neurons` | share of **all cortical neurons** | 4.2–16.2 |

`__HOWTO_build_a_dataset_file.md` §7 normally forbids transcribing percentages, because they are
recomputed downstream from the absolute values. **That rule does not bite here:** the absolute
prefrontal volumes and counts are not published anywhere in this paper's tables — Fig. 6 plots
them, no table gives them — so the share *is* the datum. Transcribed on that basis and tagged
`Measure = pct.cortex` throughout so nothing can mistake it for a count.

**To get an absolute prefrontal neuron number**, multiply `pct.neurons / 100` by that species'
whole-cortex neuron count from the cellcount merge. That is a derivation for the merge to make
explicitly, naming both sources — deliberately not baked in here.

`region` is constant `"prefrontal"`, and the paper's definition is **operational, not
cytoarchitectural**: cortex anterior to the corpus callosum.

## ⚠️ The human row is the same hemisphere as Ribeiro et al. 2013

Gabi's Methods state the human hemisphere was "previously analyzed by Ribeiro et al." — one
65-year-old female right hemisphere. **`Gabi_etal_2016_TableS1` and `Ribeiro_etal_2013_Table1` are
not two independent human samples.** This needs a `_keys/specimen_crosswalk` entry before both are
allowed to contribute a human value.

## Regional — never pooled with whole-cortex values

Same rule as `Jacobs_etal_2018` (M1) and `Ribeiro_etal_2013` (cortical regions): a regional
sub-trait, kept apart from `CerebralCortex_N.n`.

## Species names

Printed as abbreviated genus with no space (`C.apella`). Eight `Gabi2016` rows added to
`_keys/Stephan/species_key.csv`; all 8 resolve. `C.apella → Sapajus apella`, the house name already
used by HH 2015 and DosSantos 2020.

## Verification

- **8 species rows**, no blank cells (the extract script asserts both).
- Every share lies in (0, 100] — asserted in the `.R`.
- **Mean `% neurons` = 8.17%**, matching the paper's "~8% of cortical neurons".
- **Human = 7.8%, rank 3 of 8** — squarely mid-range, which is exactly the paper's finding of *no
  relative prefrontal expansion* in humans. The largest value is *P. cynocephalus* at 16.2%.
- **Re-run `Gabi_etal_2016_TableS1.R` in RStudio** to confirm it reproduces the committed CSV/TSV;
  they were written by an offline mirror of the script (no R in the authoring environment).

## Table S2 — not built

`Table S2` (same SI, p. 2) is "Slopes of allometric relationships for raw data and phylogenetically
independent contrasts": 14 regressions × {slope ± SE, r², P}, computed without the human data
point (n = 7). Regression statistics, not species trait values — not registered, not built.
