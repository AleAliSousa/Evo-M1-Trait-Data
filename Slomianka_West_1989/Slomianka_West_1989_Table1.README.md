# Slomianka_West_1989_Table1

Slomianka, L., & West, M. J. (1989). Comparative quantitative study of the hippocampal region of two closely related species of wild mice: Interspecific and intraspecific variations in volumes of hippocampal components. Journal of Comparative Neurology, 280, 544–552. https://doi.org/10.1002/cne.902800405

Table 1 (p.549) contains 17 components for three groups of six adult males: A. flavicollis from Aarhus, and A. sylvaticus from Copenhagen and Montpelier. Results p.547 explicitly state that the reported data are from the left hemisphere. Methods pp.545–546 describe sulfide perfusion, frozen horizontal 30-μm sections and Timm staining. Body means/SDs are from Methods, not inserted into the published-table snapshot.

The analysis table has 51 group–structure records. R1/R2 ratios and their SEs remain in the frozen table as derived comparisons; they are not additional specimen observations. Overlapping composites are retained. Five component identities are checked per group with rounding-based tolerances; discrepancies are flagged, not corrected. Left volumes have not been doubled or pooled with whole/bilateral volumes. Layer boundaries and population provenance require explicit mapping before any aggregate volume merge.

AI visual comparison against the PDF was performed on 2026-10-26. Human RA verification remains pending; this is not recorded as a human check.

Rebuild with `Rscript Slomianka_West_1989_Table1.R` from any directory. The frozen source is read locally; the live registry supplies the encoded public TSV name. Published taxon labels are retained. No new global species key or unsupported bilateral conversion is introduced.

<!-- errata:begin -->
## Errata

Generated from `reference_tables/Slomianka_West_1989_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| Slomianka_West_1989-E001 | volume_mean_mm3 | Table 1 p.549; A. flavicollis DK, combined hilus and mossy fiber zone | 2.13 |  | publication_ambiguity |  | confirmed | Hilus 1.14 + mossy fiber zone 0.97 = 2.11, outside 0.015 rounding tolerance. | Source retained; no inferred correction or replacement. |
| Slomianka_West_1989-E002 | volume_mean_mm3 | Table 1 p.549; A. sylvaticus DK, combined hilus and mossy fiber zone | 1.55 |  | publication_ambiguity |  | confirmed | Hilus 0.65 + mossy fiber zone 0.84 = 1.49, outside 0.015 rounding tolerance. | Source retained; no inferred correction or replacement. |
| Slomianka_West_1989-E003 | volume_mean_mm3 | Table 1 p.549; A. sylvaticus F, Ammon’s Horn and area dentata | 20.22 |  | publication_ambiguity |  | confirmed | Ammon 14.22 + area dentata 6.16 = 20.38, outside 0.015 rounding tolerance. | Source retained; no inferred correction or replacement. |

3 recorded, 0 open (proposed), 3 confirmed, 0 withdrawn.
<!-- errata:end -->
