# Koay, Kearns, Heffner & Heffner (1998) — Figure 9

**Source paper.** Koay, G., Kearns, D., Heffner, H. E., & Heffner, R. S. (1998). Passive sound-localization ability of the big brown bat (*Eptesicus fuscus*). *Hearing Research*, 119, 37–48. https://doi.org/10.1016/s0378-5955(98)00037-9

**The item is a figure, not a table.** Figure 9 (journal p. 46) plots **sound-localization threshold** (degrees, log y) against the **width of the field of best vision** (degrees, log x — defined in the caption as the region with ganglion-cell densities at least 75 % of maximum) for the **23 species keyed in the caption**, plus the paper's own **big brown bat**, labelled in words. Neither variable is tabulated anywhere in the paper.

## ⚠️ Most points are numbers, not markers

**18 of the 24 points are drawn as the caption's key number set at the data position**; only 6 carry a filled disc with a leader to its number. A numeral's bounding-box centre is a weaker estimate of a data position than a marker centre, and where numerals abut the typesetter has nudged them apart. Affected labels are flagged in the snapshot and in the CSV `note`:

- **"2019" (labels 20 ferret, 19 least weasel)** and **"1411" (14 spiny mouse, 11 hamster)** are printed as single strings;
- **23 (cow)** abuts **5 (chipmunk)**;
- labels **15/7** and **9/16** are two *touching discs* each — measured separately, but not independently resolved.

## Method

1. Embedded figure image (xref 36, 2949 × 2425 px) read directly from the PDF.
2. Axes calibrated on the printed tick marks by least squares against log₁₀(value); residuals < 25 px (0.025 decade) on both axes.
3. Discs: centroid of the ink at the **nearest** distance-transform peak to the seed (a global peak would collapse the two touching discs onto one centre). Numerals: bounding-box centre of the label's one or two digit glyphs; a glyph merged with neighbouring ink contributes to the x span but not the y centre.
4. Each label was assigned to its glyph or disc by reading the figure; that assignment is the one human step, recorded as the seed pixels in `Koay_etal_1998_b_Figure9_extract_snapshot.py`.

## Checks

Against **Heffner et al. (1994) Table 1** — the source the caption points to, built here as `Heffner_etal_1994_c_Table1` — the eight shared species agree closely:

| species | Figure 9 | Heffner et al. 1994 |
| --- | --- | --- |
| wild Norway rat | 12.6° | 12.8° |
| chinchilla | 17.1° | 15.6° |
| spiny mouse | 18.8° | 19.0° |
| wood rat | 18.6° | 19.0° |
| grasshopper mouse | 19.0° | 19.3° |
| gerbil | 26.1° | 27.0° |
| groundhog | 27.0° | 27.8° |
| naked mole rat | 61.5° | 63.0° |

Seven are within 3.3 %; the chinchilla is +9.6 %. That table carries no ferret value. The **big brown bat** disc reads **147.7° / 13.7°** against the paper's own **139° / 14°** (Results text).

### One disagreement inside the paper — label 20 (ferret)

Label 20's numeral puts the ferret at about **11.6°**. **Figure 8 of this same paper puts it at 7.9°**, and Heffner & Heffner (1992a) Table 1 gives **8.5°**. The numeral "20" is printed hard against "19" (least weasel, ~12°), so the most likely explanation is that the typesetter placed the pair together rather than at label 20's own position. The value is kept as read and flagged `unresolved` in the `note`; no erratum is filed, because the discrepancy is as likely to be a limit of reading a crowded numeral as an error in the figure.

## Files in this folder

| file | what it is |
| --- | --- |
| `Koay_etal_1998_b_Figure9_extract_snapshot.py` | the digitiser; measures every coordinate at run time |
| `Koay_etal_1998_b_Figure9_snapshot.csv` | **frozen digitisation**: 24 points, both axes as read, pixel coordinates, how each point is drawn, per-point caveats |
| `Koay_etal_1998_b_Figure9.R` | snapshot + caption key → CSV + public TSV |
| `Koay_etal_1998_b_Figure9.csv` | analysis-ready, one row per point (24 rows) |
| `reference_tables/…_caption_key.csv` | the caption's numbered species key, verbatim (23 entries + the big brown bat) |
| `reference_tables/…_references.csv` | the two sources the figure cites |
| `reference_tables/…_definitions.csv` | data dictionary (10-col schema) |

Public TSV: `__Public/comparative-data/10.1016%2Fs0378-5955(98)00037-9_Figure9.tsv`.

## Data role

Registered **secondary**, which holds for the 23 keyed species. The big brown bat point is this paper's own, so the item is strictly **both**; the proposed registry row says so and `data_role` carries it per row. Note also that the caption cites a source only for the localization thresholds — **the width-of-field-of-best-vision values are plotted with no source given at all**, so for those 23 species this figure is their only trace in the paper.
