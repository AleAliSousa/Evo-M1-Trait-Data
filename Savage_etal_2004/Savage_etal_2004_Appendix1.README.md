# Savage et al. 2004 — Appendix 1: mammalian basal metabolic rate and body mass

Savage, V. M., Gillooly, J. F., Woodruff, W. H., West, G. B., Allen, A. P., Enquist, B. J., & Brown, J. H. (2004).
The predominance of quarter-power scaling in biology. *Functional Ecology*, 18(2), 257–282.
https://doi.org/10.1111/j.0269-8463.2004.00856.x

Appendix 1 (printed pp. 268–281) lists **1,006 literature BMR measurements** (body mass g, BMR W, source) for
**626 mammal species** in 21 orders, including monotremes, marsupials and bats. Each species' average (the
back-transformed mean of the logarithms) is printed on that species' first row. Appendix 2 (p. 282) is the
52 log-mass bins derived from these averages. It is not built here.

## Why this item exists
`BC mammals - Savage et al., 2004` is the body-mass source behind ~3,200 Amniote-database (`Myhrvold_etal_2015`)
cells. All of them are `adult_body_mass_g`, which is the mass of the BMR animals. This item makes those masses
traceable to the printed row and to the original source (Heusner 1991, Lovegrove 2000/2003, White & Seymour 2003 …).
It also adds a species-level mammalian BMR table.

## Files
- `Savage-2004-The predominance of quarter-power.pdf`: the journal PDF, born-digital with a text layer, taken from
  the owner's EndNote library (SHA-256 `cfc3fea83e82fb48080be629b6acae654846cc00f811fb279a5eb971d2cd955c`).
- `Savage_etal_2004_Appendix1_extract_snapshot.R`: builds the frozen snapshot from the PDF **word boxes**
  (`pdftools::pdf_data`). No values are typed or stored in the script.
  - The rotated margin footer ("© 2004 British Ecological Society, Functional Ecology, 18, 257–282") interleaves with
    the last rows of every page in plain text extraction. It is removed by glyph height: the footer is 7 pt and the
    table body 6 pt.
  - Rows are rebuilt by baseline, and cells by x position against each page's own header. Wrapped reference lines
    are appended to the row above.
  - The script refuses to overwrite an existing snapshot that differs from a fresh extraction.
- `Savage_etal_2004_Appendix1_snapshot.csv`: **frozen snapshot**, values exactly as printed ("·" decimal, spaced
  thousands, row order, printed column headers).
- `Savage_etal_2004_Appendix1.R`: the build. It reads the snapshot and the PDF bibliography and writes:
  - `Savage_etal_2004_Appendix1.csv`: analysis CSV, 1,006 rows;
  - `__Public/comparative-data/10.1111%2Fj.0269-8463.2004.00856.x_Appendix1.tsv`: public TSV;
  - `reference_tables/Savage_etal_2004_Appendix1_references.csv`: 13 cited works, citation verbatim from the
    printed bibliography (pp. 265–267, two-column reading order rebuilt from word boxes);
  - `reference_tables/Savage_etal_2004_Appendix1_table_checks.csv`: the species-average check below.
- `reference_tables/Savage_etal_2004_Appendix1_definitions.csv`: data dictionary.
- `reference_tables/Savage_etal_2004_errata.csv`: errata (rendered below).

## Reader / provenance
The values were read from the PDF text layer by `Savage_etal_2004_Appendix1_extract_snapshot.R`, run by an AI
assistant on 2026-10-23. They were checked by the arithmetic table check below and by the stated species count
(Methods p. 259: "values for 626 species"; the extraction finds exactly 626 species-average rows). **An RA
side-by-side check of the snapshot against the PDF pages is still pending**: record it in the last
`__ReadMe.xlsx` column when done.

## Cleaning steps
- Numbers: "34 779·3" becomes 34779.3. Mass is in g (project unit) and BMR in W, both as printed; no conversion.
- The one multi-source cell ("White & Seymour (2003), Rogerson (1968)") is rewritten with the house "; " separator.
- `species_block` numbers the printed species groups, and `is_species_avg_row` marks the row carrying the average.

## Observation level
**One row per literature measurement.** For species-level work use only the rows where `is_species_avg_row == TRUE`
(626) and their `Species_avg_*` columns. Do not re-average the rows. Join measurements to their species average by
`species_block`, not by name.

## Table checks
The species averages are recomputed from the printed rows (exp of the mean log):
- mass: **626/626** round to the printed 1-decimal value (max |Δ| 0.05 g);
- BMR: **626/626** within 0.001 W (max |Δ| 0.0008 W). The per-row BMRs are themselves printed to 3 dp, so a
  recomputed mean can drift by up to one unit in the last place. 41 multi-row species fall between 0.0005 and 0.001.
- every printed species group carries a single species name.

## Data role
**Secondary (compilation)** of Heusner (1991), Lovegrove (2000, 2003), White & Seymour (2003) and a few original
studies, de-duplicated by the authors. Source counts: White & Seymour (2003) 547 rows, Lovegrove (2000) 171,
Heusner (1991) 156, Lovegrove (2003) 67, Hart (1971) 36, McNab (1969) 21, others ≤ 3.

## Species names
The printed binomials are kept verbatim as `Species_Savage2004`. No `species_key.csv` rows were added, consistent with
the other life-history compilations.

<!-- errata:begin -->
## Errata

Generated from `reference_tables/Savage_etal_2004_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| Savage_etal_2004-E001 | Family | Appendix 1, p. 268, row "Artiodactyla Canidae Cervus elaphus 67 000 112·430" | Canidae | Canidae | publication_error | Cervidae | proposed | Printed family Canidae under order Artiodactyla for Cervus elaphus (red deer, a cervid); the next row (Alces alces) opens Cervidae. Taxonomic, not arithmetic: left proposed. | CSV keeps the printed family; Order/Species are correct. |
| Savage_etal_2004-E002 | * | Appendix 1, p. 273, row "Peramelemorphia Peroryctidae Perameles gunnii 695 1·902" (second Perameles gunnii block) | Peroryctidae \| Perameles gunnii \| 695 \| 1·902 | Peroryctidae \| Perameles gunnii \| 695 \| 1·902 | publication_ambiguity |  | proposed | Perameles gunnii is printed twice on p. 273 with different values and its own species average each time: under Peramelidae (837 g, 2·343 W) and under Peroryctidae (695 g, 1·902 W). Perameles is not a peroryctid genus; the second row is either a misnamed peroryctid or a duplicate White & Seymour (2003) record. Check White & Seymour 2003 appendix. | Analyses keyed by species name will see two species averages for Perameles gunnii; use species_block to keep them apart. |

2 recorded, 2 open (proposed), 0 confirmed, 0 withdrawn.
<!-- errata:end -->
