# West_Gundersen_1990_Table2

West, M. J., & Gundersen, H. J. G. (1990). Unbiased stereological estimation of the number of neurons in the human hippocampus. Journal of Comparative Neurology, 296, 1–22. https://doi.org/10.1002/cne.902960102

Table 2 (p.16) is transcribed completely, including all individual sampling values, printed mean/SD/CV and biological-variance entries. The analysis output contains 25 donor–region records (five donors × five layers); summaries remain in the snapshot and are checked against individuals, not counted again as subjects. Printed Nv and N use factors of 10^6, converted to cells/mm3 and cells. V is the neuron-containing reference-layer volume, not the complete volume of the named anatomical field.

Methods: optical disector estimates and Cavalieri volumes in 70-μm Giemsa-stained glycol-methacrylate sections. One hippocampus per donor; Figure 1 depicts the left, but the cohort side is not stated unambiguously. No tissue-volume correction was made (p.19), so these remain processed-tissue reference volumes. CA3–2 is combined, HATA is separate from the counted subdivisions, and subiculum/prosubiculum boundaries follow the detailed definitions. These counts are stereological, distinct from isotropic-fractionator estimates.

The footnote interchanges N and Nv in one descriptive sentence; column headings and the equation establish the interpretation. No silent source correction. Arithmetic mean checks use original units and printed rounding.

AI visual comparison against the PDF was performed on 2026-10-26. Human RA verification remains pending; this is not recorded as a human check.

Rebuild with `Rscript West_Gundersen_1990_Table2.R` from any directory. The frozen source is read locally; the live registry supplies the encoded public TSV name. Published taxon labels are retained. No new global species key or unsupported bilateral conversion is introduced.

<!-- errata:begin -->
## Errata

Generated from `reference_tables/West_Gundersen_1990_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| West_Gundersen_1990-E001 | neuronal_density_cells_mm3 | Table 2 p.16, N/Nv definitions in footnote | N = number of neuronal nuclei per mm³; Nv = total number of neurons |  | publication_ambiguity |  | confirmed | The descriptive footnote interchanges symbols; column units and N = V × Nv establish Nv=density and N=count. Source numbers retained. | Source retained; no inferred correction or replacement. |

1 recorded, 0 open (proposed), 1 confirmed, 0 withdrawn.
<!-- errata:end -->
