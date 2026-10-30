# West_Schwerdtfeger_1985_TableII

West, M. J., & Schwerdtfeger, W. K. (1985). An allometric study of hippocampal components: A comparative study of the brains of the European hedgehog (Erinaceus europaeus), the tree shrew (Tupaia glis), and the marmoset monkey (Callithrix jacchus). Brain, Behavior and Evolution, 27, 93–105. https://doi.org/10.1159/000118723

Table II (p.99) retains 13 components for four hedgehogs (52 specimen–component records). Printed means remain in the snapshot and as explicitly repeated audit metadata. These are standardized volumes, not raw tissue volumes. Methods p.97 describes normalization by each individual’s telencephalic volume; the table footnote instead says the mean telencephalic volume of the four animals. This discrepancy prevents a justified inverse transformation. The published values are retained.

Timm histology after 0.1% Na₂S perfusion, horizontal 30-μm sections; every twentieth section was measured. The same hedgehog material appears in West et al. (1984). Region totals overlap and CA1/CA3 exclude SEL. No hemisphere doubling. Reader checks all 13 printed group means; discrepancies remain visible.

The reader also checks the printed total hippocampus, area dentata, fascia dentata, molecular layer and Ammon’s horn against their component sums within each specimen. Tolerances propagate 0.01-mm³ input rounding. Mismatches remain as published and are listed in errata.

AI source comparison performed on 2026-10-26. Human RA verification remains pending.

Rebuild with `Rscript West_Schwerdtfeger_1985_TableII.R` from any directory. The frozen source is read locally and the registry supplies the encoded public TSV name. Published taxon labels remain unchanged apart from explicitly described formatting. No global species key or unsupported hemisphere conversion is introduced. Source records enter the database and variable catalog; aggregate merge inputs are unchanged pending source/specimen and anatomical mapping.

<!-- errata:begin -->
## Errata

Generated from `reference_tables/West_Schwerdtfeger_1985_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| West_Schwerdtfeger_1985-E001 | standardized_volume_mm3 | Methods p.97 vs Table II footnote p.99 | individual telencephalic volume / mean telencephalic volume |  | publication_ambiguity |  | confirmed | Methods normalize by each individual telencephalic volume; footnote instead says mean of the four specimens. No inverse transformation applied. | Published values retained; no inferred correction. |
| West_Schwerdtfeger_1985-E002 | printed_group_mean_mm3 | Table II p.99; Total hippocampus | 191.98 |  | publication_ambiguity |  | confirmed | Mean of four printed individual standardized values = 191.93 mm³. Difference exceeds 0.01-mm³ rounding tolerance; source visually checked. | Published values retained; no inferred correction. |
| West_Schwerdtfeger_1985-E003 | printed_group_mean_mm3 | Table II p.99; Subiculum (without SEL) | 26.72 |  | publication_ambiguity |  | confirmed | Mean of four printed individual standardized values = 25.22 mm³. Difference exceeds 0.01-mm³ rounding tolerance; source visually checked. | Published values retained; no inferred correction. |
| West_Schwerdtfeger_1985-E004 | standardized_volume_mm3 | TableII; H9 total hippocampus | 157.3 |  | publication_ambiguity |  | confirmed | Components sum to 157.36 mm³ versus printed composite 157.3 mm³. Difference exceeds 0.025 rounding tolerance. Table visually checked. | Source values retained; no correction inferred. |
| West_Schwerdtfeger_1985-E005 | standardized_volume_mm3 | TableII; H11 total hippocampus | 204.72 |  | publication_ambiguity |  | confirmed | Components sum to 198.72 mm³ versus printed composite 204.72 mm³. Difference exceeds 0.025 rounding tolerance. Table visually checked. | Source values retained; no correction inferred. |
| West_Schwerdtfeger_1985-E006 | standardized_volume_mm3 | TableII; H11 molecular layer | 35.2 |  | publication_ambiguity |  | confirmed | Components sum to 36.32 mm³ versus printed composite 35.2 mm³. Difference exceeds 0.015 rounding tolerance. Table visually checked. | Source values retained; no correction inferred. |
| West_Schwerdtfeger_1985-E007 | standardized_volume_mm3 | TableII; H15 total hippocampus | 204.9 |  | publication_ambiguity |  | confirmed | Components sum to 204.98 mm³ versus printed composite 204.9 mm³. Difference exceeds 0.025 rounding tolerance. Table visually checked. | Source values retained; no correction inferred. |
| West_Schwerdtfeger_1985-E008 | standardized_volume_mm3 | TableII; H15 molecular layer | 40.44 |  | publication_ambiguity |  | confirmed | Components sum to 39.32 mm³ versus printed composite 40.44 mm³. Difference exceeds 0.015 rounding tolerance. Table visually checked. | Source values retained; no correction inferred. |

8 recorded, 0 open (proposed), 8 confirmed, 0 withdrawn.
<!-- errata:end -->
