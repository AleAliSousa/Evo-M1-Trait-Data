# Weigl 2005 — longevity of mammals in captivity

**Source:** Weigl, R. (2005). *Longevity of mammals in captivity; from the living collections of the world*. Kleine Senckenberg-Reihe, 48. ISBN 9783510613793.

The repository PDF contains printed pages 21–210 and an interlibrary-loan cover sheet. It is an unchanged copy of `24514240_7903299210002761.pdf`, renamed `Weigl_2005_LongevityOfMammalsInCaptivity_pp21-210.pdf`. SHA-256: `0c2c1eaa09b0662b571e416467126c05d4da8de99ba819fe524a6d4858192262`. The 14,832,448-byte file is below GitHub's 100 MB file limit and is kept intact.

## Record table and age review

`Weigl__2005_Records_snapshot.csv` contains one row per printed record line on data pages 21–199: **4,552 rows across 179 pages**. Group entries remain one row. Every primary printed age has been checked against the page image; `age_review_level` is `image_checked` for all 4,552 rows in `Weigl__2005_Records.csv`. The normalized source age, including its unit and any `>` qualifier, is in `age_printed_verified`. Separate verified year, month, and day fields support numeric comparison. Four cetacean entries use non-year/month units: `1 week`, `weeks`, `days`, and `6 hours`. The two unit-only entries lack a printed numeral, so no numeric age is inferred for them. The user confirmed both omissions on 2026-10-23: `Weigl_2005_p119_r021` (*Physeter catodon*, p. 119, “weeks”) and `Weigl_2005_p120_r005` (*Pontoporia blainvillei*, p. 120, “days”). Their `qa_flags` record this confirmation.

The table also retains two OCR readings and their candidate fields. **Taxon names, record prose, and parenthesized alternative ages remain provisional OCR** except where a page ledger explicitly records a visual check. Thus the registered item remains labeled `OCR DRAFT` and is suitable for source comparison with review levels retained, not as a fully verified taxonomic or life-history dataset. The restricted AnAge/Myhrvold comparison has not been rerun against this completed age review.

### OCR disagreements and review scope

Both OCR readings yielded numeric primary-age pairs for 1,461 records but disagreed on the years or months. All 1,461 are among the 4,552 records whose **primary printed ages were checked against page images**; the verified age fields come from that image review, not from choosing one OCR reading. This does not resolve every OCR disagreement elsewhere in a record. The table flags 224 taxon-reading disagreements, of which 187 have no visually verified taxon label. Dates, institutions, prose, and parenthesized alternative ages also remain provisional unless an explicit page ledger says otherwise. `age_review_level = image_checked` describes the primary age only.

The source snapshot feeds `Weigl__2005_Records.R`, which builds the item CSV and `__Public/comparative-data/ISBN%3A9783510613793_Records.tsv`. Rebuild from the repository root with `Rscript Weigl_2005/Weigl__2005_Records.R`. The field dictionary is `reference_tables/Weigl__2005_Records_definitions.csv`.

## Extraction and evidence

The initial capture uses `extract_records.py` (PDF text), `secondary_ocr.cjs` (independent page-image OCR), and `compare_secondary_ocr.py`. Visual corrections and extraction scripts are preserved in `review/`. Age ledgers are applied by `review/apply_visual_age_checks.py`, `review/apply_visual_page_ledgers.py`, `review/apply_page026_visual_ledger.py`, and `review/apply_visual_ages_27-30.py`. The latter now reads the visual age ledgers through page 199. It also fills normalized printed-age text for earlier checked pages. The two age review queues are empty after the age review, so their generated CSVs were removed. `review/Weigl_2005_visual_page_counts.csv` retains the page-count audit. The source snapshot is the frozen reviewed capture for rebuilding the registered item. The main folder keeps the PDF, snapshot, generated item CSV, reader, README, and `reference_tables/` dictionary; `review/` holds the ledgers, scripts, preliminary OCR capture, and historical QA material.

The archived OCR start candidate files (`review/Weigl_2005_possible_missing_rows.csv` and `review/Weigl_2005_secondary_possible_missing_rows.csv`) are historical QA leads from the preliminary 4,532-row capture; their counts do not describe the reviewed table. Page-image reconciliation removed false starts and added printed records that OCR merged or missed.

The loan cover sheet requests pages 21–211, but the supplied scan ends at printed page 210. The record section itself ends at page 199.

## External comparisons

AnAge has 841 mammal maximum-longevity values directly sourced to Weigl (`Source_ref=671`). Myhrvold et al. (2015) includes 2,755 mammal sparse-table values attributed to Weigl. These are taxon-level comparison aids, not independent transcriptions of every printed record. The comparison scripts and outputs reside in the restricted repository under `restricted_checks/Weigl_2005/comparison/`, following `REPO_BOUNDARY.md`. No external value was copied into the source table.
