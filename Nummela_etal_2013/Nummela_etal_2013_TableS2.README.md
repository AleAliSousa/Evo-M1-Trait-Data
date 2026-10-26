# Nummela_etal_2013_TableS2

Nummela, S., Pihlström, H., Puolamäki, K., Fortelius, M., Hemilä, S., & Reuter, T. (2013). Exploring the mammalian sensory space: co-operations and trade-offs among senses. Journal of Comparative Physiology A, 199, 1077–1092. https://doi.org/10.1007/s00359-013-0846-2

Supplement Table S2 (pp.5–10): all 119 species and all 14 printed columns, including order headings, source keys and residuals. The frozen snapshot follows the original order. Body kg becomes g; anatomical lengths and areas retain mm/mm². These are species-level organ dimensions, not sensory performance thresholds.

Provenance is recorded per sensory measure. Source 19 means this study (primary); combinations including 19 are mixed; other sources are secondary. Body mass, habitat and diet all cite Nowak (1999). Comma-separated source keys join the item references after splitting; the source combinations are never collapsed to one citation. Residuals are retained as derived metadata. Table S1/S3 transforms or combines these measurements and is not an independent primary dataset.

Species estimates generally average 1–3 adult museum specimens, with sex often unavailable (Methods p.1081). Cribriform areas were measured from endocranial casts and tympanic areas from the bony sulcus tympanicus. Eye measurements are entirely secondary in this table.

The item belongs in the source database/catalog for sensory anatomy. It is not inserted into the current perception-threshold merge as if anatomical area were acuity. There are no printed additive totals to validate. Checks cover the 119 unique taxa and every reference-key join.

AI visual comparison against the PDF was performed on 2026-10-26. Human RA verification remains pending; this is not recorded as a human check.

Rebuild with `Rscript Nummela_etal_2013_TableS2.R` from any directory. The frozen source is read locally; the live registry supplies the encoded public TSV name. Published taxon labels are retained. No new global species key or unsupported bilateral conversion is introduced.

<!-- errata:begin -->
## Errata

Generated from `reference_tables/Nummela_etal_2013_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| Nummela_etal_2013-E001 | habitat | Table S2 p.10; Galago senegalensis | A |  | publication_ambiguity |  | confirmed | A is absent from the caption legend (Ae, Aq, Ar, F, T). Keep A rather than silently recoding to Ar. | Source retained; no inferred correction or replacement. |

1 recorded, 0 open (proposed), 1 confirmed, 0 withdrawn.
<!-- errata:end -->
