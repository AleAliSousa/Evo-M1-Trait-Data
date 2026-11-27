# Resolution of the 36 former “neither” registry rows — 2026-11-26

This is a row-by-row decision record for the 36 entries reported before this review. Row numbers refer to the original `__ReadMe.xlsx` Sheet1 positions; rows were cleared without shifting later row numbers. The current exact-path audit is `_checks/registry_file_balance_2026-11-26.csv`.

| Outcome | Original rows | Count |
|---|---|---:|
| CSV and public TSV completed | 318, 380, 381, 632, 815, 866, 1140, 1274, 1287, 1288, 1298 | 11 |
| Duplicate or obsolete placeholder merged into another row | 526, 529, 534, 633, 1297, 1299 | 6 |
| Documented non-build moved to `SOURCE_DISPOSITION` | 10, 120, 152, 254, 334, 400, 606, 696, 1060, 1131, 1235 | 11 |
| Built non-tabular tree asset | 575, 1242 | 2 |
| Active build or source-review task | 379, 420, 720, 881, 1156, 1228 | 6 |
| **Total** | | **36** |

## Completed table items

| Row | Item | Resolution |
|---:|---|---|
| 380–381 | González-Pardo et al. 2019 Tables 1–2 | Author accent verified from the PDF; folder, item readers, CSVs, and public TSVs now use the accented name. Both readers ran. |
| 632 | Kappeler & Pereira 2003 Appendix | R extraction from the author-supplied workbook now writes an item-named CSV and public TSV (1,181 source cells, 10 columns, matching parsed values). Multi-value/approximate cells and the date-formatted outlier remain unaltered; merge review still applies. |
| 815 | Melchionna et al. 2020, brain-shape DATA | Kept distinct from the other Melchionna 2020 paper; 123-row CSV/TSV pair built. Source units and specimen overlap remain merge-review questions. |
| 1274 | Wei et al. 2019 DK114 | Registry item descriptor corrected to match the existing reader and 114-row CSV; public TSV generated and matched. |
| 1298 | Collins et al. 2013 Table 1 | The former Wong auditory-paper row actually described Collins's visual-structure Table 1. Replaced it with one correctly cited Collins row; its 81-row CSV and public TSV were regenerated. The Wong auditory paper remains a different publication, with no item claimed here. |

## Merged or disposed entries

| Original rows | Resolution |
|---|---|
| 526, 529, 534, 1297 | Blank source-level placeholders removed; each paper already has separate built item rows. No paper was excluded. |
| 633 | Exact duplicate of the Kappeler Appendix row 632; removed. |
| 1299 | Duplicate erroneous Wong row; removed when the single Collins item was registered at 1298. |
| 10, 334, 606 | Anderson & Gallup 2015, Gallup 1977, and Jacobs & Williams 2001 are whole-source reviews without independent species data; folders moved to `_SOURCE_DISPOSITION`, with entries on the worksheet and source register. |
| 152 | Castrillon et al. 2023 processed comparison deposit has no selected Evo-M1 trait item; folder moved to `_SOURCE_DISPOSITION` and recorded in both decision logs. A specifically named secondary ROI product can be registered later if needed. |
| 400, 696, 1131 | Halley & Krubitzer 2019, Ketten 2012, and Smaers & Soligo 2013 were already whole-source skips under `_SOURCE_DISPOSITION` and in both decision logs; stale Sheet1 item rows removed. |
| 120 | Brodmann `Tabelle1` is a duplicate of the locally built Table1. The built item's citation, alternate ID, and public filename were corrected to the held 1913 *Verhandlungen* source; the separate *Anatomischer Anzeiger* paper identity remains distinct. The redundant row was moved to item-level disposition. |
| 254 | Dos Santos unpublished workbook row superseded by the built published Table 1; item-level disposition records the errata role. |
| 1060 | Schenker dissertation Table 3.1b retained as a source snapshot and item-level skip because the printed corrected volumes conflict with case factors; other Schenker builds stay active. |
| 1235 | Titova Table 4 is an ALE cluster-localization table, not an anatomical volume dataset; item-level skip, other Titova builds retained. |
| 575, 1242 | Isler and Upham are NEXUS tree assets; the audit reports `non_tabular` when their actual `.nex` file exists. Neither is expected to have a CSV/TSV trait table. |

## 2026-11-26 next-action pass

Four figure rows are now built: Frost & Masterton Figure 3 (18 primary opossum curve points), Norlén Figure 1 (92 plotted chimpanzee sugar-response points), and Westergaard & Hyatt Figures 1–2 (six behavior contrasts each, with one Figure 2 bar kept as NA). Each has a source snapshot, item reader/CSV, public TSV, separate replot script/PNG, and item README documenting the source comparison and approximation limits. Smith & Jungers Table 5 is also built as a source compilation (317 rows, 249 printed labels), with merge and page-image review explicitly pending. The figure replots are internal checks, not human signoff.

The original six source or measurement holds now have the following outcomes:

| Row | Item | Completed check and concrete remaining action |
|---:|---|---|
| 379 | González-Lagos 2010 | Appendix I built as a 43-reference bibliographic item: 14 exact cited-publication brain items verified, 3 misleading author-year candidates distinguished, 26 without exact brain item verified. Obtain the absent 493-species table or species-to-reference map for the separate trait task. |
| 420 | Hawrylycz 2012 | Castrillon 2023 directly cites the AHBA atlas and uses a distinct ENIGMA/Glasser matrix already held here; Castillo-Morales 2018 uses BioGPS/GEO/BrainSpan/Brawand sources. The Julich matrix is a separate analysis asset. Choose a specific derived comparative measure before a public trait item. |
| 720 | Krubitzer et al. 1995 | Source PDF matches an existing provisional Flatmap dataset. The article's approximate A/V extents and small auditory patches are scale checks, not independent SI/R/PV surface-area observations. Moved the Evo-M1 placeholder to source disposition. |
| 881 | Nunn et al. 2001 | Carnes 2011 cites the exact paper for estrous-overlap methodology, not group-count data; its group-count source pool includes distinct Nunn & Barton 2000. No unique 2001 species item was verified; moved to source disposition, retaining a conditional author/archive lead. |
| 1156 | Stensaas et al. 1974 | Owner added the source PDF; printed Tables 1–4 built as 21 aggregate/comparison rows. The 52 individual hemisphere values are not tabulated. |
| 1228 | Terborgh 1983 | Complete institutional VLeBooks reader inspected; Chapter 7 Tables 7.1–7.5 built as 150 primary-study measurements. Old World secondary comparison rows omitted. |

The current exact-path audit is 1,295 both, zero CSV-only, zero TSV-only, two non-tabular tree assets, one neither, across 1,298 populated Sheet1 registry rows. Workbook structural/public-list integrity passed. The earlier table below is the historical pre-pass plan, retained for traceability.

## Earlier eleven-row plan

| Row | Item | Current decision and next action |
|---:|---|---|
| 318 | Frost & Masterton Figure 3 | HOLD. The built ResultsText item already captures the reported summary thresholds. Compare Figure 3 with that item and upstream audiograms; digitize only distinct curve data, then add the required figure replot. |
| 379 | González-Lagos 2010 | HOLD. Original 493-species table absent. Obtain it or finish the Appendix I source-by-source coverage audit before selecting an item. |
| 420 | Hawrylycz 2012 | PLANNED. Derived Julich expression matrix is stored outside this public repository; define a named secondary regional matrix and sharing scope. |
| 720 | Krubitzer et al. 1995 | PLANNED. Primary monotreme maps held; define a defensible flatmap field-area measurement before figure extraction and replot. Do not infer area from linear scale bars. |
| 866 | Norlén et al. 2019 Figure 1 | HOLD. Verify that chimpanzee concentration-response points add observations beyond the built Table 1/Figures 2–3 and comparative compilation; if yes, digitize the figure and replot it. |
| 881 | Nunn et al. 2001 | HOLD. Requested group-composition database is not tabulated in the paper; identify the original database and exact overlap with built socioecological sources. |
| 1140 | Smith & Jungers 1997 Table 5 | HOLD. Resolve overlap with already built body-mass compilations before extracting a secondary copy. |
| 1156 | Stensaas et al. 1974 | HOLD. Acquire the paper PDF, then identify separable primary cases and overlap. |
| 1228 | Terborgh 1983 | HOLD. Acquire the book or tables, then identify species-level observations and overlap. |
| 1287–1288 | Westergaard & Hyatt Figures 1–2 | HOLD. The existing archived one-row text record is not figure data. Establish a primary-evidence gap in the chosen mirror compilation before digitizing either figure; each new figure item needs its own replot. |

Three more identical public-file registry pairs were found outside the original 36: rows 205/206 (AnAge 2009), 734/735 (Lassek & Rasmussen 1940), and 1321/1322 (Zilles 1989). Older provisional/citation-only rows 205, 734, and 1321 were cleared; completed rows 206, 735, and 1322 retain the source caveats. No data files were deleted.

The audit checks exact registry CSV/TSV paths and recognizes local NEXUS trees. It does not certify human source-image signoff or merge eligibility.
