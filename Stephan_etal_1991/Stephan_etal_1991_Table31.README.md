# Stephan_etal_1991_Table31 — prepared source-backed table, NOT FINISHED

## Source and frozen evidence

Stephan, H., Baron, G., & Frahm, H. D. (1991). Insectivora (Vol. 1). Springer. https://doi.org/10.1007/978-1-4613-9124-1

**Source / locus:** held `Stephan_etal_1991.pdf` (178-page chapter-10 tables/atlas extract starting at printed p.395; a second held tables PDF is byte-identical and is not independent evidence). This item is printed p.439 / PDF page 45: **Table 31. Volumes of cerebellar nuclei and ventral pons**

**Source format & legibility:** Scanned book page with an OCR text layer; print is sharp and every cell is legible at 200 dpi. The text layer omits all n=1 glyphs and all '-.-' missing-value glyphs in VPO, and garbles the S. minutus row; the image governs. Two n columns are printed (n for CER, n for the other measures).

`Stephan_etal_1991_Table31_snapshot.csv` freezes the published layout: caption, cross-references, header order, family rows, 10 printed taxon rows, printed decimal precision, printed taxon spellings/abbreviations, missing-value glyphs and footnotes. Running heads/page numbers are omitted, as in the Table13/16 snapshots. The snapshot is not an analysis dataframe.

**Reader provenance:** the values were read by an AI assistant (Microsoft Copilot), 2026-10-14, from page images rendered with pdftoppm at 200 dpi. The PDF text layer was used only as a locator; the page image governed every cell (the text layer drops many thin `1` glyphs in n columns and renders some `0` as `Q`). **HUMAN visual curation is pending: no human has checked any value, label or footnote of this item.** `Human_visual_curation` is set to PENDING in every row.

## Reproducible preparation and files

**Method:** `Stephan_etal_1991_Table31.R` reads the frozen snapshot by position, resolves the (repeated) header row, keeps printed taxon rows (asserting exactly 10), carries the printed family, parses n and measures as numeric, converts printed missing tokens (`-`, `-.-`, blank, parenthesized values) to NA while recording the printed token per row in `Missingness_note`, and attaches item-scoped provenance/gate text. The item settings in the script are labels and provenance only; it contains no measurement literals. It writes the analysis CSV and then writes the public TSV to `__Public/comparative-data/` only if `__ReadMe.xlsx` Sheet1 has exactly one row whose `Item name` equals the item (no guessed stem).

`Stephan_etal_1991_Table31.csv` is a **Python-computed preview** produced by a transformation that mirrors the R reader line for line and emulates R `utils::write.csv` (quoted header and strings, unquoted numbers with R's 15-significant-digit formatting, `NA` for missing). Consequently printed trailing zeros are not kept in the CSV (e.g. 0.770 → 0.77); the snapshot keeps the printed precision. Before use, the mirror's parsing logic was verified by regenerating the existing Table13 analysis preview byte-for-byte from its snapshot and context files (with the Python-csv serializer that the existing Table13/16 previews actually use — those previews are not in R write.csv format, so the serializer for this item was switched to the R write.csv emulation). R is not installed here: **the R script has NOT been run**; parse/clean-session execution and canonical audit/build/validation are pending.

Analysis columns: Reference, Source_row, Species_Stephan1991, Family_as_published, one `n_<ABBR>` column per measure (the table prints a separate n before each measure), `CER_author_reported_Vol.mm3`, `VPO_author_reported_Vol.mm3`, `TCN_author_reported_Vol.mm3`, `MCN_author_reported_Vol.mm3`, `ICN_author_reported_Vol.mm3`, `LCN_author_reported_Vol.mm3`, then provenance/gate columns named as in Table13/16. `reference_tables/Stephan_etal_1991_Table31_definitions.csv` uses the fixed ten-column schema and covers every analysis column plus `Method:observation_level` and `Method:units` rows.

**Units:** mm³ as printed (Table1 printed p.396: size in mm³ unless indicated otherwise; Table19 has no unit override). No conversion, no ×2.

**Observation level:** one row per printed historical taxon; values are author-reported per-taxon values over the printed n individuals (n=1 for most rows). Specimen identity and overlap with other Stephan tables are unresolved; rows are not independent new cohorts.

## Scientific interpretation and closed gates

**Abbreviations (as printed):** CER = cerebellum; VPO = ventral pons; TCN = total cerebellar nuclei; MCN = nucleus medialis cerebelli; ICN = nucleus interpositus cerebelli; LCN = nucleus lateralis cerebelli. Expansion locus: Table31 footnote printed p.439 / PDF45; Table1 printed pp.396–399 lists the same keys.

**Data role:** primary (provisional). Table31 is one of the book's own volumetric series (volumes Table31, indices Tables32–33); no caption or footnote attributes the values to earlier work. Overlap with earlier Stephan/Baron publications and with CER volumes elsewhere in the book cannot be excluded without the absent Methods/bibliography.

**Dependencies:** TCN (total cerebellar nuclei) is the dependent total of MCN + ICN + LCN; TCN is part of CER. VPO is a separate structure. CER is printed with a different n.

**Known limitations:** Methods pp.12–24 and the full bibliography are absent from the held extract, so the measurement estimator, shrinkage correction, normalization, averaging over n and the unilateral/bilateral scope of paired structures are unestablished. No ×2, no unit scaling, no rounding repair, no accepted-name substitution (printed historical names, including abbreviated ones, are kept). Accepted-taxonomy, anatomy, specimen, method and laterality gates are HOLD; `Primary_ingestion_eligible` and `Merge_eligible` are FALSE on every row. 

## Checks and release state

**QA (arithmetic, against printed values):**

- TCN = MCN + ICN + LCN (footnote: TCN = total cerebellar nuclei): 10 rows tested, 0 rows untestable (missing part/total), 0 outside rounding tolerance.
- Structural: 10 taxon rows parsed (assertion in R reader); all non-empty measure cells match the allowed token set; definitions cover every analysis column.

Printed values were NOT altered to resolve any mismatch; mismatches are documented here only.

**[TO CHECK] items:**

- [TO CHECK: human visual comparison of all 10 rows × 9 cells against printed p.439]
- [TO CHECK: VPO printed '-.-' for 8 of 10 species (kept as NA with token recorded)]
- [TO CHECK: CER may duplicate the CER column of the book's fundamental brain-part table (cross-table dependency)]

**Pending:** HUMAN visual curation of every cell against the page image; clean R execution of the exact item script; owner registration in `__ReadMe.xlsx` (proposal only, see registry_proposals.csv) and only then the public TSV; Stephan collection-scoped species key mapping; methods/laterality certification. Shared registry, keys, merges, `_tools`, `_skills` and `__Public` were not changed. No FINISHED state is claimed.
