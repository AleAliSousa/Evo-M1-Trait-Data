# Filiminoff_1932_Tablep70

## Source
Filimonoff, I. N. (1932). Über die Variabilität der Großhirnrindenstruktur. Mitteilung II. Regio occipitalis beim
erwachsenen Menschen. *Journal für Psychologie und Neurologie*, 44, 1–96. (Byline prints **I. N. FILIMONOFF**; the
folder name and Van Essen & Drury 1997 spell it *Filiminoff* — kept for the folder/Item name so the registry formula
resolves to this folder.)

Scan: `Filiminoff_1932.pdf` (98 PDF pages = order slip + printed pp. 1–96 + plates; PDF page = printed page + 1).

## Item
Unnumbered table under **IV. 1. „Die Flächenausdehnung der Regio occipitalis und ihrer Hauptfelder“**, printed p. 70
(PDF p. 71). Registry `Item number` = `Table p70` (a locator, since the table has no number). 13 hemispheres from 9
adult brains: surface area (mm², one hemisphere) of the Regio occipitalis (R. occ.) and of Areas 17, 18, 19, each
with its % of the occipital region. Ar 1 d./s. print only Area 17 (other cells `—`).

The paper's only other table (pp. 93–94, „Tabelle … wo nur Durchschnittsgrößen zusammengestellt sind“) lists
means only; its area means are reproduced exactly by this item (checks below) and were not built separately.

## Page audit (how the item was found)
The OCR text layer is unusable (e.g. „Oherflikheninha!t“). All 98 pages were rendered at 150 dpi; candidate pages
(numbers + mm², „Oberflächeninhalt“, „Schwankungskoeffizient“) were inspected: p. 11–12 literature values (Brodmann,
Tramer, v. Economo & Koskinas, Putnam, Popoff — other authors, not ingested), pp. 35–70 per-case protocols (area of
Calcarina, Sulc. PO, and Area 17 sometimes repeated in prose), p. 70 the case table, p. 71 ranges/means/shrinkage
correction, pp. 93–94 the means table.

## Pipeline
| file | role |
|---|---|
| `Filiminoff_1932_Tablep70_snapshot.xlsx` | frozen source, printed layout (German headings, row/column order, `—` cells, units only in the first row, merged Area headers) — hand-transcribed from 500-dpi renders; every cell checked against the image |
| `reference_tables/Filiminoff_1932_Tablep70_cases.csv` | constructed: verbatim case headers (pp. 35–70) → group, age, inferred sex, Hirngewicht, hemisphere |
| `Filiminoff_1932_Tablep70.R` | reads the snapshot + cases, writes CSV + public TSV |
| `Filiminoff_1932_Tablep70.csv` | long: 13 hemispheres × 4 structures = 52 rows (46 with values) |
| `reference_tables/Filiminoff_1932_Tablep70_definitions.csv` | data dictionary |
| `reference_tables/Filiminoff_1932_errata.csv` | 3 proposed publication errata |
| `Filiminoff_1932_Tablep70_registry_row.xlsx` | registry row to paste (owner) |
| `__Public/comparative-data/JPsycholNeurol%3A44%3A1-96_Tablep70.tsv` | public TSV |

## Data role
**primary** — the author's own serial-section measurements (Moscow Brain Institute material, 1927–1928). No per-row
citations, so no `_references.csv` is needed.

## Species / cases
Table prints no species; `species_as_published = "Menschen"` (title) → *Homo sapiens* via `_keys/General/species_key.csv`
(row added for `Filiminoff_1932`). Case headers print group, age, cause of death and Hirngewicht; **sex is not printed** —
`sex_inferred` follows the German noun (Russin = female; Russe/Jude/Burjat/Chinese = male). Left-hemisphere protocols
print only „Linke Hemisphäre desselben Gehirns“ and inherit the right-hemisphere header values. Three brains
(Ar 18, A kit 1, A kit 2) plus Ar 1 (Area 17 only) contribute both hemispheres.

## Units
Printed mm² per hemisphere, **not shrinkage-corrected** → `area_cm2 = mm² / 100`. The author's shrinkage coefficient
1.2 (p. 71: total coefficient 1.4, sagittal component already included via 25 µm section thickness) is applied only in
`area_cm2_shrinkage_corrected`; it reproduces the printed corrected range (Area 17: 2650–3452 mm²) and corrected means
(R. occ. 12588, Area 18 4738, Area 19 4668 mm²).

## Table checks (actual R run, 2026-10-28)
- R. occ. = Area 17 + 18 + 19: 11/11 rows exact (2 rows not evaluable, dashes).
- Percentages (tolerance 0.06 pp): 31/33 pass; mismatches A kit 1 s. Area 17 (computed 24.54 vs printed 24,4) and
  Area 18 (38.50 vs 38,6) — printed row sums to 100,0; kept as printed, errata E001/E002.
- Text p. 71 means/range: R. occ. mean 10490 (11), Area 17 mean 2613 (13), Area 18 3948, Area 19 3890,
  Area 17 min 2208 (Ar 18 s.) / max 2877 (A kit 1 d.) — all exact.
- p. 71 prints the corrected Area 17 mean as 3036 mm²; 2613 × 1.2 = 3136 (E003, probable misprint).

## Comparison with Van Essen & Drury (1997)
`VanEssen_Drury_1997_ResultsTextCitedV1Ranges` cites „22–29 cm²“ for human V1 in one hemisphere from this paper.
This table's Area 17 range is **2208–2877 mm² = 22.08–28.77 cm²**, i.e. 22–29 cm² when rounded: **agreement** — Van
Essen & Drury used the uncorrected values (shrinkage-corrected 26.50–34.52 cm² would not match). The primary
case-level values now supersede that secondary range. No comparison folder is created (REPO_BOUNDARY.md).

## Registry
No Sheet1 row exists yet. `Item encoded` is derived with the house formula from col C override
`JPsycholNeurol:44:1-96` (no DOI for this 1932 journal; pattern as `Biophysics:36:909-913`) + `_` + compacted Item number
→ `JPsycholNeurol%3A44%3A1-96_Tablep70`. Until the owner pastes the row, the script derives it from the registry_row.xlsx
and warns.

<!-- errata:begin -->
## Errata

Generated from `reference_tables/Filiminoff_1932_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| Filiminoff_1932-E001 | pct_of_regio_occipitalis | Table p. 70, row 'A kit 1 s.', Area 17 percent | = 24,4 | 24.4 | publication_ambiguity | 24.5 | proposed | Arithmetic: 100 x 2689 / 10958 = 24.54 (printed mm2 values verified; 17+18+19 = 10958 exactly). Printed row percents 24,4 + 38,6 + 37,0 sum to 100,0, suggesting rounding adjusted by the author. | CSV keeps printed 24.4 |
| Filiminoff_1932-E002 | pct_of_regio_occipitalis | Table p. 70, row 'A kit 1 s.', Area 18 percent | = 38,6 | 38.6 | publication_ambiguity | 38.5 | proposed | Arithmetic: 100 x 4219 / 10958 = 38.50; see E001 (row percents forced to 100,0). | CSV keeps printed 38.6 |
| Filiminoff_1932-E003 | area_cm2_shrinkage_corrected | Text p. 71: 'Durchschnittsgröße der A. striata beträgt 2613 mm² (mit der Korrektur 3036 mm²)' | 3036 mm² |  | publication_error | 3136 mm² | proposed | 2613 x 1.2 = 3135.6; the same factor reproduces every other corrected figure on p. 71 (12588, 2650, 3452, 4184, 5338, 4738, 3210, 5875, 4668). Read from 500-dpi render of p. 71. | Prose value, not a CSV cell; per-case corrected values are derived x1.2 in the build |

3 recorded, 3 open (proposed), 0 confirmed, 0 withdrawn.
<!-- errata:end -->
