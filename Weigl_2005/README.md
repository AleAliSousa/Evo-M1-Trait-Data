# Weigl 2005 — longevity of mammals in captivity

**Source:** Weigl, R. (2005). *Longevity of mammals in captivity; from the living collections of the world*. Kleine Senckenberg-Reihe, 48. ISBN 9783510613793.

The repository PDF contains printed pages 21–210 (190 printed pages) and an interlibrary-loan cover sheet. It is an unchanged copy of `24514240_7903299210002761.pdf`, renamed to `Weigl_2005_LongevityOfMammalsInCaptivity_pp21-210.pdf` for identification. SHA-256: `0c2c1eaa09b0662b571e416467126c05d4da8de99ba819fe524a6d4858192262`.

`Weigl_2005_records_OCR_draft.csv` is one table of 4,532 candidate source records from the complete data section (printed pages 21–199). It contains the PDF's embedded text reading and an independent OCR reading of page images. Primary ages on printed pages 21–25, 97, 101, 105, and 107 (233 rows) have been checked visually; other fields and pages still require image review. It is **not** an analysis-ready dataset. No species summaries or public TSV have been built. See `Weigl_2005_extraction_plan.md` for the field design and review status.

The reproducible sequence is `extract_records.py` → `secondary_ocr.cjs` → `compare_secondary_ocr.py` → `apply_visual_age_checks.py` → `apply_visual_page_ledgers.py`. The second step needs `pdftoppm`, `tesseract.js`, and the [official English Tesseract model](https://github.com/tesseract-ocr/tessdata_fast/blob/main/eng.traineddata); set `LANG_DIR` to the directory holding `eng.traineddata` and `OCR_OUT_DIR` to the temporary OCR output folder. The page-count audit is `Weigl_2005_extraction_audit.csv`.

`Weigl_2005_possible_missing_rows.csv` is a separate QA queue, not additional accepted records. A more permissive left-indent search found 55 unresolved possible starts beyond the main table; some are visibly damaged headings or wrapped text. They require page-image review before adding any record to the main CSV.

`audit_secondary_starts.py` checks the independent image OCR for record-like lines that are distant from a source-table start. It currently writes 34 further candidates to `Weigl_2005_secondary_possible_missing_rows.csv`. These are another QA queue, not accepted records; page-position differences between OCR engines mean some are already represented in the table.

`Weigl_2005_visual_page_counts.csv` records pages whose printed record-line count has been checked against the image. Printed pages 97, 101, 105, and 107 now have all 30, 30, 27, and 26 rows respectively, with taxon, sex/count, and primary age checked; their visual ledgers and `apply_visual_page_ledgers.py` preserve the corrections.

The loan cover sheet requests pages 21–211, but the supplied scan ends on printed page 210. The PDF is 14,832,448 bytes, below GitHub's 100 MB per-file limit, so it is kept intact. The printed page range and source hash make it possible to identify and verify the scan without split-file assembly.

## Lifespan dataset cross-check

Myhrvold et al. (2015) includes 2,755 mammal sparse-table values attributed to Weigl (2,291 taxon keys), making it a useful digitization aid. Its consolidated mammal maximum-longevity field cites Weigl in 934 rows. A provisional exact-binomial comparison of this OCR draft links 1,385 names to those Myhrvold Weigl-attributed values; it also links 767 names to AnAge, 723 to PanTHERIA, and 71 to Lewitus et al. (2014) lifespan values. These are name overlaps, not value agreements or independent validations. The comparison script, table, and review notes are in the restricted repository's `restricted_checks/Weigl_2005/comparison/`, following `REPO_BOUNDARY.md`. No outside value has been copied into the Weigl source table.
