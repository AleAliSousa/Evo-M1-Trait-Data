# One-table extraction status

The first PDF page is an interlibrary-loan cover sheet. PDF pages 2–6 correspond to printed pages 21–25. Each count below is a **printed record line**, identified by the leading sex/count notation (such as `1.0`, `0.1`, or `0.0.1`). Wrapped lines and parenthesized alternative ages are not counted again. Counts were checked against page images after an OCR-assisted count.

| Printed page | PDF page | Record lines | Main content |
| --- | ---: | ---: | --- |
| 21 | 2 | 22 | Monotremes; beginning of didelphid marsupials |
| 22 | 3 | 27 | Didelphid marsupials |
| 23 | 4 | 25 | Didelphids; monito del monte; Tasmanian wolf |
| 24 | 5 | 25 | Numbat and dasyurid marsupials |
| 25 | 6 | 21 | Dasyurids; beginning of bandicoots |
| **Total** | | **120** | **24 record lines per page** |

The full data section covers printed pages 21–199 (179 pages). The current extraction has 4,532 candidate rows, averaging 25.3 rows per data page. The remaining pages contain acknowledgments, an institution list, and references.

## One-table design

Use one source table with one row per **printed record line**, retaining group records such as `0.2` and `0.0.8` as one source row each. The main fields are:

`source_id`, page and row position, `record_kind`, printed order/family/taxon/common name and sex/count as read by OCR, full record text from each OCR engine, both age-column readings, year/month candidates with `age_candidate_basis`, visually checked primary age fields, `qa_flags`, and `review_status`.

The draft has 4,283 starts recognized by sex/count notation, 209 starts without it, and 40 starts inserted after page-image review. The 209 include both printed records lacking sex notation and OCR mistakes. There are 248 rows with no age-column text in the PDF's embedded OCR. A second OCR pass reads the page images independently. The two readings agree on a primary year/month pair for 2,580 rows; 583 pairs come only from the PDF text layer and 234 only from the image OCR. The remaining 1,135 rows have no numeric age candidate. Pages 97, 101, 105, and 107 have verified primary ages, and their OCR age candidates were cleared after direct visual transcription exposed row misalignment. These are extraction counts, not verified specimen counts.

The first five pages contain 120 visually counted record lines, matching the extraction counts. Their **primary ages** have also been checked against the page images and entered in the verified columns. Printed pages 97, 101, 105, and 107 have 30, 30, 27, and 26 image-checked row starts, taxon names, sex/count values, and primary ages. The other printed taxon names, record prose, and parenthesized alternative ages still need individual image review.

Review priorities are the 1,135 rows without a numeric age candidate (including the visually verified ages on pages 97, 101, 105, and 107), the 209 starts without recognized sex/count notation, and the rows where the two OCR taxon readings differ substantially. The two OCR passes count different numbers of starts on 70 of 179 data pages (largest difference: 10); page images must settle those differences. OCR agreement alone is not a visual check.

A permissive left-indent pass also yielded 55 unresolved possible additional row starts in `Weigl_2005_possible_missing_rows.csv`. Its output includes false positives from damaged headings and wrapped lines, so it is an image-review queue rather than part of the main record table. This is further evidence that 4,532 is a candidate count, not a verified complete census.

The independent image-OCR audit in `audit_secondary_starts.py` yields 34 possible missing starts after allowing for line-position offsets between OCR engines. The two QA queues overlap and include false positives. A page-boundary correction has added the top records on printed pages 97 and 107 under the preceding page's taxon. Other candidates still require image review.

The page-image count ledger (`Weigl_2005_visual_page_counts.csv`) confirms 30, 30, 27, and 26 printed records on pages 97, 101, 105, and 107. All four have matching table counts using their visual ledgers; taxon, sex/count, and primary age values are image-checked, while prose and alternative ages remain pending. The corrections inserted 40 real rows and removed 4 false OCR starts, for 36 net additions. Other pages may still be missing records where the embedded text layer breaks.

The one CSV also holds the second OCR reading, age candidates with their basis, `qa_flags`, and the first five pages' `age_years_verified`, `age_months_verified`, or `age_days_verified`. After checking each remaining row against the page image, add verified taxon, record prose, parenthesized age, and status fields in this same table. Do not promote OCR text to verified fields without checking the image.

Keep the full record text because it mixes birth or capture information, institutions, transfers, death or last-alive dates, and provenance in different patterns. Parse those into additional columns only when a rule is reliable. The printed age is the source value; a calculated age can be added later without replacing it.

The OCR layer can locate candidate rows, but its reading order sometimes detaches the age columns from the record and misreads names and digits. Page-image review is necessary for every completed row. Parenthesized ages are distinct annotations, and `0.2`/`0.0.8` entries are groups rather than automatically two or eight identified individuals.

## Existing digital comparison source

AnAge explicitly incorporates Weigl (2005). Its public build 15 download (`https://genomics.senescence.info/species/dataset.zip`, checked 21 October 2026) contains 1,349 mammal species rows. Weigl is the source of the maximum-longevity value (`Source=671`) for 841 of those rows, and the bibliography cites Weigl for 1,060 mammal entries. This is a useful species-level age and taxon cross-check. It is not a transcription of Weigl's individual record lines: the downloadable fields have one maximum-longevity value per species, without the per-record institution, sex/count, dates, or alternative ages. Do not merge those maxima into the source-record table as if they were printed rows. AnAge bibliography: `https://genomics.senescence.info/species/biblio.php`.

The local `Evo-M1-Trait-Data-restricted/unpublished_data/____Unpublished__TranslateAge/anage_data.txt` is the planned comparison copy. Per `REPO_BOUNDARY.md`, any comparison script and mismatch report belong under `restricted_checks/Weigl_2005/comparison/` in that private repository after the source table is reviewed. The public paper folder can then state the aggregate audit result.
