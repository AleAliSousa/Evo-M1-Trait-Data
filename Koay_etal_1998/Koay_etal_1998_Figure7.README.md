# Koay, Heffner & Heffner (1998) — Figure 7

**Source paper.** Koay, G., Heffner, R. S., & Heffner, H. E. (1998). Hearing in a megachiropteran fruit bat (*Rousettus aegyptiacus*). *Journal of Comparative Psychology*, 112(4), 371–382. https://doi.org/10.1037/0735-7036.112.4.371

**The item is a figure, not a table.** Figure 7 (journal p. 380) plots the **low-frequency hearing limit** against the **high-frequency hearing limit** — both the frequencies audible at 60 dB SPL, kHz, both axes logarithmic — for **58 species of mammals**. The caption prints no species names; it says *"(See Figure 6 caption for the key to species.)"*, so the species, the medium and the audiogram reference for every point come from the Figure 6 caption on p. 379.

## ⚠️ This is digitised (pixel-measured) data, not a transcribed printed table

The underlying numbers appear nowhere in the paper. Values here carry an estimated **±1 % on the high-frequency (x) axis and ±3 % on the low-frequency (y) axis**, and **54 of the 58 plotted points resolve to a distinct marker** — points **8/57**, **14/19/54** and **17/44** are printed as merged blobs that cannot be separated at this resolution, so both (or all three) members of each group take the blob's centre and are flagged in `shared_marker_with`. Do not treat this file as equivalent in precision to a transcribed table.

## Method

1. Rendered page index 10 (journal p. 380) of `koay_etal_1998.pdf` at **300 dpi**. The page is a scan whose embedded image is 1238 × 1650 px — about **150 dpi natively** — so the render upsamples it 2×; one native pixel is two rendered pixels, which is why the error estimates below are quoted conservatively.
2. Located the axis frame as the longest dark column (y axis) and row (x axis).
3. Calibrated both axes **from the printed tick marks only** — every major and minor log tick detected by its ink run beside the axis, then a least-squares fit of pixel against log₁₀(value). Residuals: **2.8 px on x (0.003 decade) and 2.9 px on y (0.009 decade)**.
4. Measured each marker centre: distance-transform peak then ink centroid for filled circles and triangles; a ring template (bright 7×7 core, dark radius-7.5 ring) for the five open bat circles; bounding-box centre for the open marine triangles.
5. Assigned each printed label to its marker by reading the figure; that assignment is the one human step and is recorded as the seed pixels in `Koay_etal_1998_Figure7_extract_snapshot.py`. Every reported coordinate is re-measured by that script at run time.

**Anchors.** The paper states that at 60 dB SPL the Egyptian fruit bat hears **2.25–64 kHz** (pp. 371, 376); this digitisation reads point Ra at **2.26 and 63.4 kHz**. Point Ef (*Eptesicus fuscus*, Koay et al. 1997) reads **3.70 kHz** against the 3.7 kHz low-frequency limit the companion 1998 *Hearing Research* paper quotes for that species.

## Files in this folder

| file | what it is |
| --- | --- |
| `koay_etal_1998.pdf` | the publication (scan) |
| `Koay_etal_1998_Figure7_extract_snapshot.py` | the digitiser: renders the page and measures every coordinate; refuses to overwrite a differing snapshot without `--force` |
| `Koay_etal_1998_Figure7_snapshot.csv` | **frozen digitisation** of all 58 points: marker as printed, value as read on each axis, pixel coordinates, read method, merged-marker flag |
| `Koay_etal_1998_Figure7.R` | canonical reformat: snapshot + caption key + crosswalk → CSV + public TSV |
| `Koay_etal_1998_Figure7.csv` | analysis-ready data, one row per plotted point (58 rows) |
| `reference_tables/…_caption_key.csv` | the Figure 6 caption's species key restricted to the 58 Figure-7 points, with the **Figure 7** marker |
| `reference_tables/…_species_crosswalk.csv` | printed misprints/older names → corrected binomials (9 of the figure's points) |
| `reference_tables/…_references.csv` | the 49 printed audiogram-reference keys resolved to full citations |
| `reference_tables/…_definitions.csv` | data dictionary (10-col schema) |

Public TSV: `__Public/comparative-data/10.1037%2F0735-7036.112.4.371_Figure7.tsv`.

## Data role: both

Point **Ra** (*Rousettus aegyptiacus*) is this paper's own audiogram — the caption prints "present report". The other 57 points replot audiograms from the studies named in the caption, so they are secondary; `audiogram_source` keeps the printed key and `reference_tables/Koay_etal_1998_Figure7_references.csv` resolves it (join `audiogram_source` → `ref_key`). **48 of the 49 printed keys resolve to an entry in the paper's own reference list; "Markl & Ehret, 1973" (point 42, house mouse) is cited in the caption but has no entry in the printed reference list** — recorded verbatim in the references CSV `note`, not corrected.

## Markers: read from Figure 7, not inherited from Figure 6

The caption's groups are open circles = bats, filled triangles = subterranean, open triangles = marine, and neither triangle group entered the regression lines (`excluded_from_correlation`). Point **51 (sea lion in air, *Zalophus californianus*)** prints as a **filled circle in Figure 6** but as an **open triangle in Figure 7** — verified on the page image — so in Figure 7 it is grouped with the marine mammals and excluded from the regressions. Point **61 (beluga)**, which the Figure 6 caption marks "Figure 7 only", is present here.

## Comparison with the older Bath digitisation

The Bath team digitised this figure in 2021 (`hearing data.xlsx`, sheet "Koay 1998 extract", Fig-7 block, in the restricted repo). Against that pass this digitisation agrees on the **high-frequency axis to within 2.8 %** (median -0.3 %) but reads the **low-frequency axis higher for 57 of the 58 points, by up to 24 %** (median +8.5 %), the gap growing with the plotted value — the signature of a wrong decade length in that pass's y calibration. The published anchors above (Rousettus 2.25 kHz, *Eptesicus* 3.7 kHz, both read correctly here, 14 % and 16 % low in the Bath pass respectively) decide it, so **this build uses its own digitisation and the Bath Figure-7 block was not used**. The Figure 6 item is unaffected: its y axis is the high-frequency limit, where the two passes agree.

## Notes for the database

- The compilation's *published* audiogram-limit values route to the individual papers in `…_references.csv` (Route-A candidates), not to this item; use the primary source first and the digitised value only as a fallback.
- `species_key.csv` token: `Koay_etal_1998` (collection key rows are keyed by folder name).
