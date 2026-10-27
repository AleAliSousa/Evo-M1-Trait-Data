# West_Schwerdtfeger_1985_TableIII

West, M. J., & Schwerdtfeger, W. K. (1985). An allometric study of hippocampal components: A comparative study of the brains of the European hedgehog (Erinaceus europaeus), the tree shrew (Tupaia glis), and the marmoset monkey (Callithrix jacchus). Brain, Behavior and Evolution, 27, 93–105. https://doi.org/10.1159/000118723

Table III spans pp.100–101. The snapshot joins the continuation horizontally and preserves every published column: hedgehog means, hypothetical reference volumes, individual standardized volumes and size indices, and mean size indices. Analysis contains 52 current-study specimen–component records (four animals × 13 components). Reference predictions and repeated hedgehog/group summaries remain metadata and must not be pooled as specimens.

Volumes are standardized by reference/individual brain mass (Methods p.97); SI =100 × standardized/reference volume. The reader checks SI arithmetic using 0.6 tolerance for integer SI and two-decimal volume rounding. No inverse normalization or bilateral conversion. Total hippocampus excludes pre-/supracommissural portions and the alveus/fimbria/fornix system (p.101). SEL is combined across Ammon’s horn and subiculum.

The reader also checks the printed total hippocampus, area dentata, fascia dentata, molecular layer and Ammon’s horn against their component sums within each specimen. Tolerances propagate 0.01-mm³ input rounding. Mismatches remain as published and are listed in errata.

AI source comparison performed on 2026-10-26. Human RA verification remains pending.

Rebuild with `Rscript West_Schwerdtfeger_1985_TableIII.R` from any directory. The frozen source is read locally and the registry supplies the encoded public TSV name. Published taxon labels remain unchanged apart from explicitly described formatting. No global species key or unsupported hemisphere conversion is introduced. Source records enter the database and variable catalog; aggregate merge inputs are unchanged pending source/specimen and anatomical mapping.

<!-- errata:begin -->
## Errata

Generated from `reference_tables/West_Schwerdtfeger_1985_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| West_Schwerdtfeger_1985-E009 | standardized_volume_mm3 | TableIII; T2 molecular layer | 26.45 |  | publication_ambiguity |  | confirmed | Components sum to 26.87 mm³ versus printed composite 26.45 mm³. Difference exceeds 0.015 rounding tolerance. Table visually checked. | Source values retained; no correction inferred. |

1 recorded, 0 open (proposed), 1 confirmed, 0 withdrawn.
<!-- errata:end -->
