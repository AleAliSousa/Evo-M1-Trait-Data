# Stephan_etal_1991_Table61 — prepared source-backed table, NOT FINISHED

## Source and frozen evidence

Stephan, H., Baron, G., & Frahm, H. D. (1991). Insectivora (Vol. 1). Springer. https://doi.org/10.1007/978-1-4613-9124-1

**Source / locus:** held `Stephan_etal_1991.pdf` (178-page chapter-10 tables/atlas extract starting at printed p.395; a second held tables PDF is byte-identical and is not independent evidence). This item is printed p.481–482 / PDF page 87–88: **Table 61. Volumes of neocortical components**

**Source format & legibility:** Scanned book pages with an OCR text layer; print is sharp and every cell is legible at 200 dpi. The text layer drops many n glyphs, reads NG as 'NO' and NG2-6 as 'N02-6' on p.482 and misplaces some labels; the image governs. 'C . stuhlmanni' is printed with a stray space and is normalized to 'C. stuhlmanni'. Table continues on p.482 with a repeated header.

`Stephan_etal_1991_Table61_snapshot.csv` freezes the published layout: caption, cross-references, header order, family rows, 50 printed taxon rows, printed decimal precision, printed taxon spellings/abbreviations, missing-value glyphs and footnotes. Running heads/page numbers are omitted, as in the Table13/16 snapshots. The snapshot is not an analysis dataframe.

**Reader provenance:** the values were read by an AI assistant (Microsoft Copilot), 2026-10-14, from page images rendered with pdftoppm at 200 dpi. The PDF text layer was used only as a locator; the page image governed every cell (the text layer drops many thin `1` glyphs in n columns and renders some `0` as `Q`). **HUMAN visual curation is pending: no human has checked any value, label or footnote of this item.** `Human_visual_curation` is set to PENDING in every row.

## Reproducible preparation and files

**Method:** `Stephan_etal_1991_Table61.R` reads the frozen snapshot by position, resolves the (repeated) header row, keeps printed taxon rows (asserting exactly 50), carries the printed family, parses n and measures as numeric, converts printed missing tokens (`-`, `-.-`, blank, parenthesized values) to NA while recording the printed token per row in `Missingness_note`, and attaches item-scoped provenance/gate text. The item settings in the script are labels and provenance only; it contains no measurement literals. It writes the analysis CSV and then writes the public TSV to `__Public/comparative-data/` only if `__ReadMe.xlsx` Sheet1 has exactly one row whose `Item name` equals the item (no guessed stem).

`Stephan_etal_1991_Table61.csv` is a **Python-computed preview** produced by a transformation that mirrors the R reader line for line and emulates R `utils::write.csv` (quoted header and strings, unquoted numbers with R's 15-significant-digit formatting, `NA` for missing). Consequently printed trailing zeros are not kept in the CSV (e.g. 0.770 → 0.77); the snapshot keeps the printed precision. Before use, the mirror's parsing logic was verified by regenerating the existing Table13 analysis preview byte-for-byte from its snapshot and context files (with the Python-csv serializer that the existing Table13/16 previews actually use — those previews are not in R write.csv format, so the serializer for this item was switched to the R write.csv emulation). R is not installed here: **the R script has NOT been run**; parse/clean-session execution and canonical audit/build/validation are pending.

Analysis columns: Reference, Source_row, Species_Stephan1991, Family_as_published, one `n_<ABBR>` column per measure (the table prints a separate n before each measure), `NEO_author_reported_Vol.mm3`, `NW_author_reported_Vol.mm3`, `NG_author_reported_Vol.mm3`, `NG1_author_reported_Vol.mm3`, `NG2_6_author_reported_Vol.mm3`, then provenance/gate columns named as in Table13/16. `reference_tables/Stephan_etal_1991_Table61_definitions.csv` uses the fixed ten-column schema and covers every analysis column plus `Method:observation_level` and `Method:units` rows.

**Units:** mm³ as printed (Table1 printed p.396: size in mm³ unless indicated otherwise; Table19 has no unit override). No conversion, no ×2.

**Observation level:** one row per printed historical taxon; values are author-reported per-taxon values over the printed n individuals (n=1 for most rows). Specimen identity and overlap with other Stephan tables are unresolved; rows are not independent new cohorts.

## Scientific interpretation and closed gates

**Abbreviations (as printed):** NEO = total neocortex; NW = neocortical white matter; NG = neocortical grey matter; NG1 = molecular layer of neocortical grey matter; NG2-6 = cell layers 2-6 of neocortical grey matter. Expansion locus: Table61 footnote printed p.482 / PDF88; Table1 printed pp.396–399 lists the same keys.

**Data role:** primary (provisional). Table61 is one of the book's own volumetric series (volumes Table61, indices Tables62–63); no caption or footnote attributes the values to earlier work. Overlap with earlier Stephan/Baron publications cannot be excluded without the absent Methods/bibliography.

**Dependencies:** NEO (own n) equals NW + NG and NG equals NG1 + NG2-6 within rounding (nested part/whole totals). NEO corresponds to Table43 NEO.

**Known limitations:** Methods pp.12–24 and the full bibliography are absent from the held extract, so the measurement estimator, shrinkage correction, normalization, averaging over n and the unilateral/bilateral scope of paired structures are unestablished. No ×2, no unit scaling, no rounding repair, no accepted-name substitution (printed historical names, including abbreviated ones, are kept). Accepted-taxonomy, anatomy, specimen, method and laterality gates are HOLD; `Primary_ingestion_eligible` and `Merge_eligible` are FALSE on every row.  [TO CHECK: the Table13 README reports (Table5 printed p.409 footnote c) that the Hylomys suillus composition brain was a juvenile; not re-verified for this item.]

## Checks and release state

**QA (arithmetic, against printed values):**

- NEO = NW + NG (inferred; NEO printed with its own n): 50 rows tested, 0 rows untestable (missing part/total), 0 outside rounding tolerance.
- NG = NG1 + NG2-6 (inferred from abbreviations): 50 rows tested, 0 rows untestable (missing part/total), 0 outside rounding tolerance.
- Cross-table check (not a printed total in this table): NEO (identity) vs Table43 NEO for 44 exactly matching taxon labels; 1 outside rounding tolerance. Mismatches (printed values kept): C. stuhlmanni: Table43 NEO 128.6 vs sum 128.3 (diff +0.3)
- Structural: 50 taxon rows parsed (assertion in R reader); all non-empty measure cells match the allowed token set; definitions cover every analysis column.

Printed values were NOT altered to resolve any mismatch; mismatches are documented here only.

**[TO CHECK] items:**

- [TO CHECK: human visual comparison of all 50 rows × 7 cells against printed pp.481–482]
- [TO CHECK: label 'C . stuhlmanni' printed with a stray space, normalized]
- [TO CHECK: analysis code NG2_6 replaces printed NG2-6]
- [TO CHECK: C. stuhlmanni NEO printed 128.3 here (= NW + NG = 128.31) but 128.6 in Table43 p.453 (both re-read on the page images); printed values kept, source inconsistency not resolved]

**Pending:** HUMAN visual curation of every cell against the page image; clean R execution of the exact item script; owner registration in `__ReadMe.xlsx` (proposal only, see registry_proposals.csv) and only then the public TSV; Stephan collection-scoped species key mapping; methods/laterality certification. Shared registry, keys, merges, `_tools`, `_skills` and `__Public` were not changed. No FINISHED state is claimed.
