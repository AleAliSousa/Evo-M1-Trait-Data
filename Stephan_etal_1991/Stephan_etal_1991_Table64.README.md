# Stephan_etal_1991_Table64 — prepared source-backed table, NOT FINISHED

## Source and frozen evidence

Stephan, H., Baron, G., & Frahm, H. D. (1991). Insectivora (Vol. 1). Springer. https://doi.org/10.1007/978-1-4613-9124-1

**Source / locus:** held `Stephan_etal_1991.pdf` (178-page chapter-10 tables/atlas extract starting at printed p.395; a second held tables PDF is byte-identical and is not independent evidence). This item is printed p.486 / PDF page 92: **Table 64. Volumes of neocortical grey (NG), area striata grey (ASG), percentage of ASG relative to NG, and size indices of ASG related to the average of the four Tenrecinae (AvTn = 100)**

**Source format & legibility:** Scanned book page with an OCR text layer; print is sharp and every cell is legible at 200 dpi. The text layer reads ASG as 'ASO' and NG as 'NO' and splits 'Hemicentetes'; the image governs. Stacked two-line column headers (e.g. 'NG' over 'mm3', 'ASG' over 'NG' as a fraction) are encoded as single header cells 'NG mm3', 'ASG mm3', 'ASG/NG', 'ASG Index'. The printed regression slope/intercept (printed beside the Index column, the intercept on the Tenrecidae line) are kept as separate rows above Tenrecidae. Subfamily headings (Tenrecinae etc.) and the printed 'Average values' block are kept in the snapshot; the reader stops at 'Average values' so only the 10 species rows enter the analysis CSV.

`Stephan_etal_1991_Table64_snapshot.csv` freezes the published layout: caption, cross-references, header order, family rows, 10 printed taxon rows, printed decimal precision, printed taxon spellings/abbreviations, missing-value glyphs and footnotes. Running heads/page numbers are omitted, as in the Table13/16 snapshots. The snapshot is not an analysis dataframe.

**Reader provenance:** the values were read by an AI assistant (Microsoft Copilot), 2026-10-14, from page images rendered with pdftoppm at 200 dpi. The PDF text layer was used only as a locator; the page image governed every cell (the text layer drops many thin `1` glyphs in n columns and renders some `0` as `Q`). **HUMAN visual curation is pending: no human has checked any value, label or footnote of this item.** `Human_visual_curation` is set to PENDING in every row.

## Reproducible preparation and files

**Method:** `Stephan_etal_1991_Table64.R` reads the frozen snapshot by position, resolves the (repeated) header row, keeps printed taxon rows (asserting exactly 10), carries the printed family, parses n and measures as numeric, converts printed missing tokens (`-`, `-.-`, blank, parenthesized values) to NA while recording the printed token per row in `Missingness_note`, and attaches item-scoped provenance/gate text. The item settings in the script are labels and provenance only; it contains no measurement literals. It writes the analysis CSV and then writes the public TSV to `__Public/comparative-data/` only if `__ReadMe.xlsx` Sheet1 has exactly one row whose `Item name` equals the item (no guessed stem).

`Stephan_etal_1991_Table64.csv` is a **Python-computed preview** produced by a transformation that mirrors the R reader line for line and emulates R `utils::write.csv` (quoted header and strings, unquoted numbers with R's 15-significant-digit formatting, `NA` for missing). Consequently printed trailing zeros are not kept in the CSV (e.g. 0.770 → 0.77); the snapshot keeps the printed precision. Before use, the mirror's parsing logic was verified by regenerating the existing Table13 analysis preview byte-for-byte from its snapshot and context files (with the Python-csv serializer that the existing Table13/16 previews actually use — those previews are not in R write.csv format, so the serializer for this item was switched to the R write.csv emulation). R is not installed here: **the R script has NOT been run**; parse/clean-session execution and canonical audit/build/validation are pending.

Analysis columns: Reference, Source_row, Species_Stephan1991, Family_as_published, no n column (the table prints none; No n column is printed in this table (N in the printed average block is a number of species, not individuals). Nothing imputed or borrowed.), `NG_author_reported_Vol.mm3`, `ASG_author_estimated_Vol.mm3`, `ASG_NG_author_reported_pct`, `ASG_author_reported_index_AvTn100`, then provenance/gate columns named as in Table13/16. `reference_tables/Stephan_etal_1991_Table64_definitions.csv` uses the fixed ten-column schema and covers every analysis column plus `Method:observation_level` and `Method:units` rows.

**Units:** As printed: mm³ for NG and ASG; percent for ASG/NG; size index (AvTn = 100) for ASG Index. No conversion.

**Observation level:** one row per printed historical taxon; values are author-reported per-taxon values over the printed n individuals (this table prints no n; see Table10). Specimen identity and overlap with other Stephan tables are unresolved; rows are not independent new cohorts.

## Scientific interpretation and closed gates

**Abbreviations (as printed):** NG mm3 = total neocortex grey matter; ASG mm3 = area striata grey matter; ASG/NG = area striata grey matter as percentage of neocortical grey matter; ASG Index = size index of area striata grey matter (AvTn = 100). Expansion locus: Table64 footnote printed p.486 / PDF92; Table1 printed pp.396–399 lists the same keys.

**Data role:** derived (provisional). ASG is not measured but estimated by the authors from GLD volumes via a primate regression (caption); ASG/NG and the index are computed from it. NG is the book's own neocortical grey volume (cf. Table61).

**Dependencies:** ASG is estimated from Table37 GLD (log GLD = -0.8801 + 0.8476 × log ASG, primate relationship); ASG/NG and ASG Index are derived from ASG. NG corresponds to Table61 NG. No column is an independent observation except NG (itself a dependent part of NEO).

**Known limitations:** Methods pp.12–24 and the full bibliography are absent from the held extract, so the measurement estimator, shrinkage correction, normalization, averaging over n and the unilateral/bilateral scope of paired structures are unestablished. No ×2, no unit scaling, no rounding repair, no accepted-name substitution (printed historical names, including abbreviated ones, are kept). Accepted-taxonomy, anatomy, specimen, method and laterality gates are HOLD; `Primary_ingestion_eligible` and `Merge_eligible` are FALSE on every row. ASG is a model-based estimate, not a measurement. The printed average rows (AvIS, subfamily averages, AvIF) are kept in the snapshot but excluded from the analysis CSV.

## Checks and release state

**QA (arithmetic, against printed values):**

- The table prints no additive totals; ratio, estimate-formula and printed-average checks were run instead.
- ASG/NG = 100 × ASG / NG (caption: percentage of ASG relative to NG): 10 rows tested, 0 outside rounding tolerance.
- ASG vs estimate from Table37 GLD via printed formula log GLD = -0.8801 + 0.8476 × log ASG: 10 rows tested, 0 outside rounding tolerance (±0.005 + 0.15%).
- Printed averages (Insectivora AvIS, 4 subfamilies, AvIF; excluded from the analysis rows) recomputed as simple means of the printed species values: 0 mismatches.
- ASG Index not recomputed: requires the body-weight allometry (slope .55, y-intercept -.054) and body weights not printed in this table.
- Structural: 10 taxon rows parsed (assertion in R reader); all non-empty measure cells match the allowed token set; definitions cover every analysis column.

Printed values were NOT altered to resolve any mismatch; mismatches are documented here only.

**[TO CHECK] items:**

- [TO CHECK: human visual comparison of all 10 species rows × 4 cells and the average block against printed p.486]
- [TO CHECK: encoding of stacked headers and of the slope/intercept lines in the snapshot]
- [TO CHECK: ASG Index not recomputable from this table (needs body weights)]
- [TO CHECK: NG printed with 2 decimals here vs 1 decimal in Table61 (e.g. 70.77 vs 70.7)]

**Pending:** HUMAN visual curation of every cell against the page image; clean R execution of the exact item script; owner registration in `__ReadMe.xlsx` (proposal only, see registry_proposals.csv) and only then the public TSV; Stephan collection-scoped species key mapping; methods/laterality certification. Shared registry, keys, merges, `_tools`, `_skills` and `__Public` were not changed. No FINISHED state is claimed.
