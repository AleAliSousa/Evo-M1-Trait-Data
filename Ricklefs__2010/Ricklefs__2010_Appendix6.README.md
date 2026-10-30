# Ricklefs 2010 — SI Appendix 6: life-history variables (from AnAge)

Ricklefs, R. E. (2010). Life-history connections to rates of aging in terrestrial vertebrates. *Proceedings of the
National Academy of Sciences*, 107(22), 10314–10319. https://doi.org/10.1073/pnas.1005862107 (PMC2890449)

SI **APPENDIX 6** (SI pp. 19–29): "Life history variables for the species used in this analysis. Data are from the
AnAge database and references therein." It has **425 species rows**: 168 mammals, 206 birds and 51
reptiles/amphibians. The three sections print different columns:
- mammals: female maturity, adult/neonate/weaning mass, gestation, weaning, growth rate k, oldest;
- birds: female maturity, adult mass, egg mass, incubation, k, oldest;
- reptiles/amphibians: female maturity, adult mass, adult length, incubation, longevity.

## Why this item exists
This table is the source of the Amniote database's (`Myhrvold_etal_2015`) "Ricklefs, 2010b" cells: 3,287 records
over 620 species. It is also a **dated AnAge extract** (c. 2009–2010), so the old AnAge values Myhrvold et al.
inherited can be compared with the current build (`deMagalhães_etal_2024`, Build 15) without needing a historical
AnAge download.

## Files
- `Ricklefs__2010_Appendix6_snapshot.csv`: **frozen snapshot**. The three sections are stacked in printed order with a
  `section` column. Each section's headers are as printed; a header that two sections share is one column.
- `Ricklefs__2010_Appendix6.R`: the build. It writes:
  - `Ricklefs__2010_Appendix6.csv`: analysis CSV, 425 rows, one column per quantity across sections;
  - `__Public/comparative-data/10.1073%2Fpnas.1005862107_Appendix6.tsv`: public TSV;
  - `reference_tables/Ricklefs__2010_Appendix6_references.csv`: SI ref 7 (de Magalhães & Costa 2009), which is
    cited for the whole table.
- `reference_tables/Ricklefs__2010_Appendix6_definitions.csv`: data dictionary. It records which printed header
  feeds each analysis column.
- `ricklefs-2010-life-history-connections-to-rates-of-aging-in-terrestrial-vertebrates.pdf`: article PDF;
  `sapp.pdf`: Supporting Information (38 pp.). Both were downloaded in a browser by the owner on 2026-10-23 and kept unchanged.
- `Ricklefs__2010_SIAppendices_extract_snapshot.R`: writes both snapshots from the SI word boxes
  (`pdftools::pdf_data`). No values are stored in the script.
  - A row that prints all of its section's numeric columns (missing values print ".") is read in printed order.
  - A row with a cell left empty is placed by x position against that page's column right edges.
  - The script refuses to overwrite a snapshot that differs from a fresh extraction.
- `Ricklefs__2010_taxonomy_check.R` → `reference_tables/Ricklefs__2010_taxonomy_check.csv`: QA. It compares
  the printed Order/Family/binomial with AnAge Build 15 and with the other appendix.
- `reference_tables/Ricklefs__2010_errata.csv`: errata for both items (rendered below).

## Reader / provenance
The values were read from the SI text layer by the extract script, run by an AI assistant on 2026-10-23.
- The row count was checked against an independent count of data lines: 425 = 425.
- 410 of 425 printed binomials are identical to one in Appendix 4. The others differ by Appendix 4 misspellings.
- **The RA side-by-side check against SI pp. 19–29 is pending.**

## Cleaning steps
- "." and empty cells become NA.
- Section headers are mapped to shared analysis columns (`Female_maturity_d`, `Adult_mass_g`, …,
  `Max_longevity_y`).
- Units are as printed: d, g, m, y.
- The bird header "Growth rate k (d)" is a unit misprint for 1/d (erratum E009).
- Reptile masses partly come from length (SI Appendix 7).

## Data role
**Secondary**: a copy of AnAge (ref 7) as of the analysis. Do not merge it as primary data. Use it to trace and
date the Amniote "Ricklefs, 2010b" values and AnAge revisions.

## Species names
Printed names are kept verbatim (older taxonomy, e.g. *Clethrionomys glareolus*); no `species_key.csv` rows were added.

<!-- errata:begin -->
## Errata

Generated from `reference_tables/Ricklefs__2010_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| Ricklefs__2010-E009 | Growth_rate_k_per_d | SI Appendix 6, Birds, column header "Growth rate k (d)" | (d) | (d) | publication_error | (1/d) | proposed | Bird values are 0.023-0.52, i.e. rates; the mammal section prints the same quantity as "Growth rate k (1/d)" and AnAge growth rate is in 1/days. |  |

1 recorded, 1 open (proposed), 0 confirmed, 0 withdrawn.
<!-- errata:end -->
