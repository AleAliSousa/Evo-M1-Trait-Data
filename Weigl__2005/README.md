# Weigl 2005 — longevity of mammals in captivity

**Source:** Weigl, R. (2005). *Longevity of mammals in captivity; from the living collections of the world*. Kleine Senckenberg-Reihe, 48. ISBN 9783510613793.

The PDF contains printed pages 21–210 and an interlibrary-loan cover sheet. It is an unchanged copy of `24514240_7903299210002761.pdf`, renamed `Weigl_2005_LongevityOfMammalsInCaptivity_pp21-210.pdf`. SHA-256: `0c2c1eaa09b0662b571e416467126c05d4da8de99ba819fe524a6d4858192262`.

## Folder layout

- The top level holds the source PDF, the registered `Weigl__2005_Records` reader, CSV and frozen snapshot, its registry-row workbook, and this README.
- `reference_tables/` holds the registered item's column definitions.
- `review/` holds the working extraction, page-image age ledgers, review plan, audit tables, and extraction scripts. The ledgers and scripts are retained as evidence for the transcription; the review table is not a second registered item.

## Review and registered-item status

The latest working table is `review/Weigl_2005_records_OCR_draft.csv`. It contains 4,552 unique printed record lines from pages 21–199. Each primary age has been checked against a page image. Four ages are stored as printed text outside the year/month/day fields (`1 week`, `weeks`, `days`, and `6 hours`); the `weeks` and `days` cells have no printed number. Taxon labels, prose, and alternative ages remain provisional except where a page ledger explicitly records a check. See `review/Weigl_2005_extraction_plan.md` and `review/Weigl_2005_visual_page_counts.csv` for the review history.

The registered `Weigl__2005_Records_snapshot.csv` and `Weigl__2005_Records.csv` still contain the earlier 4,532-row extraction. The reader `Weigl__2005_Records.R` builds the registered CSV and coded public TSV from that frozen snapshot, and its row-count check expects 4,532. The newer 4,552-row working review has **not** been promoted into the registered item. The registry labels the public item `OCR DRAFT`; do not treat its candidate ages or taxon spellings as fully verified. No species summary or merge wiring has been added.

The review scripts are in `review/` and use paths relative to this folder. The original capture stages were `extract_records.py` → `secondary_ocr.cjs` → `compare_secondary_ocr.py` → `apply_visual_age_checks.py` → `apply_visual_page_ledgers.py` → `apply_page026_visual_ledger.py` → `apply_visual_ages_27-30.py`. Later page-image review and row reconciliation are preserved in the working table and ledgers; the script chain alone is not a complete rebuild of the 4,552-row table. The OCR step needs `pdftoppm`, `tesseract.js`, and the [official English Tesseract model](https://github.com/tesseract-ocr/tessdata_fast/blob/main/eng.traineddata); `LANG_DIR` points to the model directory and `OCR_OUT_DIR` to the temporary OCR output. Earlier possible-missing-row queues and the extraction audit remain in `review/` as historical QA evidence. Running extraction scripts individually can replace the working table.

## Lifespan dataset cross-check

Myhrvold et al. (2015) and AnAge provide comparison values for Weigl taxa, but neither is a transcription of all individual record lines. A provisional exact-binomial comparison found 1,407 Weigl taxa with a Myhrvold Weigl-attributed sparse value and 677 with a direct-source AnAge maximum. These are name overlaps, not value agreements or independent validations. The comparison script, tables, and review notes are in the restricted repository's `restricted_checks/Weigl_2005/comparison/`, following `REPO_BOUNDARY.md`. No outside value has been copied into the Weigl source table.
