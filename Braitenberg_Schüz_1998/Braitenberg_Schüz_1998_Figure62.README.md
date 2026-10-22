# Braitenberg_Schüz_1998_Figure62 — built in R; human visual check pending

Braitenberg, V., & Schüz, A. (1998). *Cortex: Statistics and geometry of neuronal connectivity* (2nd ed.). Springer. DOI: [10.1007/978-3-662-03733-1](https://doi.org/10.1007/978-3-662-03733-1).

**Item:** Fig. 62, book p. 133 (PDF p. 131), Chapter 26 "Cortico-Cortical Connections".

**Caption as printed:** Fig. 62. Frequency distribution of the distances spanned by the cortico-cortical connections illustrated in Figs. 60 and 61. Only homolateral connections are shown. The longest cortico-cortical fibres found in this study are about 7 mm. There is an indication of a second peak in the histogram whose significance is obscure. (Greilich, 1984)

**Axes as printed:** x = "distance from injection site", mm, 0–10 with a tick at every millimetre; y = "number of neurons", a single labelled tick (100), axis starting at 0 on the x-axis line.

## Source and legibility

- Source PDF: `Braitenberg-1998-Cortex_ Statistics and Geomet.pdf`, SHA-256 `6a47a11f3a81d6bf18f6211f5c75701e2cfa4a4d3121102e4c885a711e07e6e8`. Springer eBook PDF (2012, 243 pages) built from page scans: text pages are 600-dpi bilevel images with an OCR text layer (the OCR layer has errors, e.g. "Schiiz", "Tlibingen"); Fig. 62 is a separate embedded 553 × 389 px, 150-ppi greyscale image (PDF object 1143). Bars, ticks and labels are clearly legible.
- What the data are (book pp. 130 and 132): Greilich's 1984 Tübingen thesis. Twenty-one mouse brains, each with a horseradish peroxidase (HRP) injection restricted to about 1 mm² of the dorsal cortex; retrogradely labelled cells lay mostly in discrete patches. The histogram gives the distances between the labelled cells and the injection site, which range from less than 1 to 7 mm. The preface thanks Greilich for letting the authors use unpublished thesis material.

## Frozen snapshot (pixel readings)

`Braitenberg_Schüz_1998_Figure62_snapshot.csv` has one row per drawn 0.1-mm bar slot from 0.2 to 7.0 mm (68 rows). No bars are drawn below 0.2 mm or beyond 7.0 mm, although the axis runs to 10 mm. Each row keeps the bar's left and right edge positions (px), the interior columns sampled and the centre row of the bar's top line (px). The 6.7–6.8 mm slot shows no bar distinguishable from the axis line; it is left blank and read as 0.

`reference_tables/Braitenberg_Schüz_1998_Figure62_calibration.csv` holds the 11 x-tick positions, the x-axis line fit (y = 351.3637 − 0.006519·x), the y-axis position and the centre of the single y tick labelled 100 (row 299.66). It also records a shear in the reproduction: bar edges and the y axis lean right by 0.0124 px per row, so edges and interior columns were read on a shear-corrected copy.

Digitization: Microsoft Copilot AI assistant, 22 October 2026 (America/Los_Angeles). Each bar's top line was read automatically as an intensity centroid in shear-corrected interior columns; the seven tiny bars at 6.3–7.0 mm (1.8–4.8 px tall) were read from the rows just above the axis line. `reference_tables/Braitenberg_Schüz_1998_Figure62_digitization_check.png` overlays every reading in red on the figure (3× enlargement; blue = calibration ticks, green = fitted axis line). **This is AI digitization, not human visual curation.** The registry's "Human visual check of snapshot" stays blank until a person compares the check image or the snapshot with the printed figure.

## R transformation and analysis CSV

`Braitenberg_Schüz_1998_Figure62.R` reads the snapshot and the calibration, fits the x calibration through the printed ticks, converts bar heights to neurons (100 neurons = 51.476 px between the axis line and the 100 tick) and writes `Braitenberg_Schüz_1998_Figure62.csv`: 68 rows with bin start, end and midpoint, `count_digitized` (0.1), `count_rounded`, height in px and provenance columns. No count is typed in anywhere.

Checks in R: contiguous 0.1-mm bins; every drawn edge within 0.03 mm of its bin label; non-negative heights; tallest bar at 2.0–2.1 mm; first bar at 0.2 mm and last at 7.0 mm (caption: longest fibres about 7 mm); second peak between 3.4 and 3.8 mm (caption: indication of a second peak).

The CSV was first prepared by a Python implementation of the same steps, from the same frozen inputs and with the same rounding, because Rscript was not available to the AI reader. **R was run on 22 October 2026** (outputs written at about 12:04 PDT). It regenerated this CSV and wrote the public TSV `__Public/comparative-data/10.1007%2F978-3-662-03733-1_Figure62.tsv` under the registry's Item encoded (owner decision of 16 October 2026).

## Digitized results

- 68 bins; about 18,480 labelled neurons in total.
- Tallest bar 2.0–2.1 mm (about 680 neurons); second peak 3.6–3.7 mm (about 404).
- Mean distance 2.74 mm (bin midpoints); median in the 2.5–2.6 mm bin.
- Uncertainty: about ±0.5 px per bar top (about ±1 neuron) plus about ±1% in scale from the single y tick. The tiny tail bars (10 neurons or fewer) are the least certain.

## Relationship to Zhang_Sejnowski_2000

Zhang & Sejnowski (2000) cite this figure (their ref. 30, figure 62) for a mouse average white-matter fibre length of L ≈ 3 mm (their Sect. 5, beside Figure 3, and Sect. 8, an independent estimate of p). The book prints no mean; the digitized mean of 2.74 mm is consistent with their reading. The quantity differs from an axon length: these are distances between labelled cell bodies and the injection site for homolateral projections, not path lengths through the white matter. See `reference_tables/Braitenberg_Schüz_1998_Figure62_source_crosswalk.csv`.

## Data role and merge note

Primary: the first publication of Greilich's unpublished thesis data (book reference list, p. 231; see `reference_tables/Braitenberg_Schüz_1998_Figure62_references.csv`). Not wired into any merge. This is one pooled distribution over 21 injections, not a species trait; do not merge the mean distance as a white-matter axon length.

## Still to do

Human visual check of the digitization.
