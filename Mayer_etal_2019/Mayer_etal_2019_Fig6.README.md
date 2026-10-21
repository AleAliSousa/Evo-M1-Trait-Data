# Mayer et al. 2019 — Figure 6A and Results text

Mayer, A., Baldwin, M. K. L., Cooke, D. F., Lima, B. R., Padberg, J., Lewenfus, G., França, J. G., & Krubitzer, L. (2019). The multiple representations of complex digit movements in primary motor cortex form the building blocks for complex grip types in capuchin monkeys. *Journal of Neuroscience, 39*(34), 6684–6695. https://doi.org/10.1523/JNEUROSCI.0556-19.2019

## Item and provenance

`Mayer_etal_2019_Fig6` contains the **hand/digit representation within M1**, not the area of all M1. The values below were independently transcribed from the Results text on PDF page 8, under “Characterization of hand and foot movements.” The authors measured areas from ICMS maps using a Voronoi tessellation and an Adobe Illustrator script. The paper calls the animals *Sapajus* spp. (formerly *Cebus*); it does not establish a species assignment for each case.

The Results text prints 19.3 mm² for case 15-01 and 8.1 mm² for cases 15-03 and 15-04. Case 15-02 has no exact area printed in the text or a labeled table, so it is excluded. Figure 6A is a visual summary, not a source of numeric data for this item. The Kaskan workbook was used only to locate the paper and relevant passage.

The nearby workbook rows 153–160 are figure-derived estimates of **all M1**. They are excluded from this item because `Kind of data` is not `data`; they belong in the Flatmap review queue. Case 15-03 lacked digit 5 in the right hand, as noted in the source.

## Files

- `Mayer_etal_2019_Fig6_pdf_transcription.csv`: values read directly from Results text, with PDF page and section.
- `Mayer_etal_2019_Fig6.csv`: one row per case with an explicitly printed number. The `hand_representation_area_mm2` column must remain distinct from `M1_Surface_Area.mm2` in the cortical-area merge.
- `Mayer_etal_2019_Fig6.R`: reproducible copy from the PDF transcription to the data CSV.
- `reference_tables/Mayer_etal_2019_Fig6_definitions.csv`: field meanings.

The article PDF was located in the local EndNote library and copied here as `Mayer_etal_2019.pdf`. No public TSV or cortical-area merge entry has been created; the hand-representation area needs a distinct standardized term.
