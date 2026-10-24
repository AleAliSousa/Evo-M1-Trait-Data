# Ricklefs 2010 — SI Appendix 4: Weibull mortality parameters (rate of actuarial aging)

Ricklefs, R. E. (2010). Life-history connections to rates of aging in terrestrial vertebrates. *Proceedings of the
National Academy of Sciences*, 107(22), 10314–10319. https://doi.org/10.1073/pnas.1005862107 (PMC2890449)

SI **APPENDIX 4** (SI pp. 5–17) gives the parameters of Weibull mortality functions, m_x = m0 + a·x^b, fitted to
survivorship, together with the rate of actuarial aging ω = a^(1/(b+1)). It has **487 printed population rows**:
230 mammal (zoo and wild), 206 bird and 51 reptile/amphibian (captive). For each row it gives b, a, m0, ω, the
number of reported deaths n, and the oldest age.

## Why this item exists
These are Ricklefs's own fits to International Species Information System (ISIS) zoo ages at death, plus a few
wild-population fits. They are **not in AnAge**, the Amniote database, PanTHERIA or Ernest. This is the
project's only cross-vertebrate table of ageing rates.

## Files
- `Ricklefs__2010_Appendix4_snapshot.csv`: **frozen snapshot**. Sections are stacked in printed order with a
  `section` column, the headers are as printed (ω is a Greek glyph with no text-layer character and is written "ω"),
  and values are as printed.
- `Ricklefs__2010_Appendix4.R`: the build. It writes:
  - `Ricklefs__2010_Appendix4.csv`: analysis CSV, 487 rows;
  - `__Public/comparative-data/10.1073%2Fpnas.1005862107_Appendix4.tsv`: public TSV;
  - `reference_tables/Ricklefs__2010_Appendix4_references.csv`: ISIS plus SI refs 4–6, citations verbatim from the
    SI reference list;
  - `reference_tables/Ricklefs__2010_Appendix4_table_checks.csv`: the ω check.
- `reference_tables/Ricklefs__2010_Appendix4_definitions.csv`: data dictionary.
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
- The row count was checked against an independent count of data lines in the plain-text layer: 487 = 487.
- The values were checked arithmetically with the ω check below.
- **The RA side-by-side check against SI pp. 5–17 is pending.**

## Cleaning steps
- "." and empty cells become NA.
- `Population` = the printed Status (mammals); otherwise "zoo", following the Birds and Reptiles/amphibians
  section notes ("All data are from captive populations").
- `Source_ref` follows the caption: ISIS for zoo rows; for wild rows, ref 4 (Ricklefs 1998), or ref 5
  (Lynch & Fagan 2009) for Note a, or ref 6 (Loison et al. 1999) for Note b.
- One m0 cell is printed "\*.2827" (*Myodes glareolus*). It is parsed as 0.2827 and the printed text is kept in
  `value_flags`.

## Observation level
**One row per printed population fit.** A species can have several rows (zoo and wild, several studies).
Pool or choose rows before any species-level use.

## Table checks
ω recomputed as a^(1/(b+1)) from the printed a and b matches the printed ω within 2% + 0.001 for **457 of 461**
rows that print all three. The 4 exceptions are recorded as errata:
- three wild Note-a rows (*Myodes glareolus*, *Sylvilagus floridanus*, *Apodemus flaveolus*), where the printed ω
  is 11.97–12.02× the recomputed value. This fits a fitted with age in months.
- *Chrysolophus pictus*, where a is printed as 0.00.

## Data role
**Both.**
- Zoo rows (431) are Ricklefs's own analyses of ISIS records: primary for ω, m0, a and b.
- Wild rows (56) take parameters from refs 4–6: secondary.

## Taxonomy and names
- Printed names are kept verbatim; no `species_key.csv` rows were added.
- Appendix 4 has many misspellings, so 24 of its 172 mammal binomials don't match AnAge as printed (e.g.
  "Macaca mulata", "Papio hyamadryas", "Didelphis vrginiana", "Rangifer tarandrus", "Rupricapra").
- The birds use the Sibley–Ahlquist orders.
- See `reference_tables/Ricklefs__2010_taxonomy_check.csv`. The clear misplacements are errata.

<!-- errata:begin -->
## Errata

Generated from `reference_tables/Ricklefs__2010_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| Ricklefs__2010-E001 | * | SI Appendix 4, Mammals, row "Rodentia Muridae Mustela ermina" | Rodentia \| Muridae | Rodentia \| Muridae | publication_error | Carnivora \| Mustelidae | proposed | Mustela is a mustelid carnivore. Placement checked against AnAge Build 15 (deMagalhães_etal_2024) and Appendix 6 of the same SI. Its order/family appear swapped with the Myodes glareolus row. |  |
| Ricklefs__2010-E002 | * | SI Appendix 4, Mammals, row "Carnivora Mustelidae Myodes glareolus wild ... *.2827 ... a" | Carnivora \| Mustelidae | Carnivora \| Mustelidae | publication_error | Rodentia \| Cricetidae | proposed | Myodes is a vole (AnAge: Rodentia Cricetidae); Appendix 6 prints it as Clethrionomys glareolus, Rodentia Muridae. Placement checked against AnAge Build 15 (deMagalhães_etal_2024) and Appendix 6 of the same SI. |  |
| Ricklefs__2010-E003 | * | SI Appendix 4, Mammals, row "Primates Lemuridae Mirouga leonina wild ... a" | Primates \| Lemuridae \| Mirouga | Primates \| Lemuridae \| Mirouga | publication_error | Carnivora \| Phocidae \| Mirounga | proposed | Mirounga leonina is the southern elephant seal; the row is printed inside the Lemuridae block and the genus is misspelt. Placement checked against AnAge Build 15 (deMagalhães_etal_2024) and Appendix 6 of the same SI. |  |
| Ricklefs__2010-E004 | * | SI Appendix 4, Mammals, row "Artiodactyla Cervidae Damaliscus dama zoo" | Cervidae \| Damaliscus dama | Cervidae \| Damaliscus dama | publication_ambiguity |  | proposed | Damaliscus is a bovid genus with no species "dama"; printed in Cervidae it most likely means Dama dama (fallow deer), but this cannot be confirmed from the SI. |  |
| Ricklefs__2010-E005 | Weibull_a | SI Appendix 4, Mammals, row "Myodes glareolus" (wild, Note a) | as printed | as printed | publication_ambiguity |  | proposed | Printed omega is 12.0x the value a^(1/(b+1)) computed from the printed a and b (reference_tables/Ricklefs__2010_Appendix4_table_checks.csv), as expected if a was fitted with age in months while omega is per year. All other 457 rows agree within 2%. | omega_per_y kept as printed; do not recompute omega from a for these rows |
| Ricklefs__2010-E006 | Weibull_a | SI Appendix 4, Mammals, row "Sylvilagus floridanus" (wild, Note a) | as printed | as printed | publication_ambiguity |  | proposed | Printed omega is 12.0x the value a^(1/(b+1)) computed from the printed a and b (reference_tables/Ricklefs__2010_Appendix4_table_checks.csv), as expected if a was fitted with age in months while omega is per year. All other 457 rows agree within 2%. | omega_per_y kept as printed; do not recompute omega from a for these rows |
| Ricklefs__2010-E007 | Weibull_a | SI Appendix 4, Mammals, row "Apodemus flaveolus" (wild, Note a) | as printed | as printed | publication_ambiguity |  | proposed | Printed omega is 12.0x the value a^(1/(b+1)) computed from the printed a and b (reference_tables/Ricklefs__2010_Appendix4_table_checks.csv), as expected if a was fitted with age in months while omega is per year. All other 457 rows agree within 2%. | omega_per_y kept as printed; do not recompute omega from a for these rows |
| Ricklefs__2010-E008 | Weibull_a | SI Appendix 4, Birds, row "Galliformes Phasianidae Chrysolophus pictus" | 0.00 | 0.00 | publication_ambiguity |  | proposed | The row is printed in a different number format and offset from the column (3.09 0.00 0.14 0.13 109.00 20.05); a is rounded to 0.00, so omega (0.13) cannot be recomputed. |  |

8 recorded, 8 open (proposed), 0 confirmed, 0 withdrawn.
<!-- errata:end -->
