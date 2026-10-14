# Stephan_etal_1991_Table40 — prepared source-backed table, NOT FINISHED

## Source and frozen evidence

Stephan, H., Baron, G., & Frahm, H. D. (1991). Insectivora (Vol. 1). Springer. https://doi.org/10.1007/978-1-4613-9124-1

**Source / locus:** held `Stephan_etal_1991.pdf` (178-page chapter-10 tables/atlas extract starting at printed p.395; a second held tables PDF is byte-identical and is not independent evidence). This item is printed p.448–449 / PDF page 54–55: **Table 40. Volumes of some periventricular and septal structures**

**Source format & legibility:** Scanned book pages with an OCR text layer; print is sharp and every cell is legible at 200 dpi. The text layer drops many n=1 glyphs and all '-'/'-.-' missing glyphs, reads SFB as 'SPB', 'Scalopus' as 'Sealopus' and one '0' as 'Q'; the image governs. Snapshot entered directly from the page images. Five n/value column pairs; table continues on p.449 with a repeated header.

`Stephan_etal_1991_Table40_snapshot.csv` freezes the published layout: caption, cross-references, header order, family rows, 38 printed taxon rows, printed decimal precision, printed taxon spellings/abbreviations, missing-value glyphs and footnotes. Running heads/page numbers are omitted, as in the Table13/16 snapshots. The snapshot is not an analysis dataframe.

**Reader provenance:** the values were read by an AI assistant (Microsoft Copilot), 2026-10-14, from page images rendered with pdftoppm at 200 dpi. The PDF text layer was used only as a locator; the page image governed every cell (the text layer drops many thin `1` glyphs in n columns and renders some `0` as `Q`). **HUMAN visual curation is pending: no human has checked any value, label or footnote of this item.** `Human_visual_curation` is set to PENDING in every row.

## Reproducible preparation and files

**Method:** `Stephan_etal_1991_Table40.R` reads the frozen snapshot by position, resolves the (repeated) header row, keeps printed taxon rows (asserting exactly 38), carries the printed family, parses n and measures as numeric, converts printed missing tokens (`-`, `-.-`, blank, parenthesized values) to NA while recording the printed token per row in `Missingness_note`, and attaches item-scoped provenance/gate text. The item settings in the script are labels and provenance only; it contains no measurement literals. It writes the analysis CSV and then writes the public TSV to `__Public/comparative-data/` only if `__ReadMe.xlsx` Sheet1 has exactly one row whose `Item name` equals the item (no guessed stem).

`Stephan_etal_1991_Table40.csv` is a **Python-computed preview** produced by a transformation that mirrors the R reader line for line and emulates R `utils::write.csv` (quoted header and strings, unquoted numbers with R's 15-significant-digit formatting, `NA` for missing). Consequently printed trailing zeros are not kept in the CSV (e.g. 0.770 → 0.77); the snapshot keeps the printed precision. Before use, the mirror's parsing logic was verified by regenerating the existing Table13 analysis preview byte-for-byte from its snapshot and context files (with the Python-csv serializer that the existing Table13/16 previews actually use — those previews are not in R write.csv format, so the serializer for this item was switched to the R write.csv emulation). R is not installed here: **the R script has NOT been run**; parse/clean-session execution and canonical audit/build/validation are pending.

Analysis columns: Reference, Source_row, Species_Stephan1991, Family_as_published, one `n_<ABBR>` column per measure (the table prints a separate n before each measure), `SET_author_reported_Vol.mm3`, `SFB_author_reported_Vol.mm3`, `HAM_author_reported_Vol.mm3`, `EPI_author_reported_Vol.mm3`, `SCB_author_reported_Vol.mm3`, then provenance/gate columns named as in Table13/16. `reference_tables/Stephan_etal_1991_Table40_definitions.csv` uses the fixed ten-column schema and covers every analysis column plus `Method:observation_level` and `Method:units` rows.

**Units:** mm³ as printed (Table1 printed p.396: size in mm³ unless indicated otherwise; Table19 has no unit override). No conversion, no ×2.

**Observation level:** one row per printed historical taxon; values are author-reported per-taxon values over the printed n individuals (n=1 for most rows). Specimen identity and overlap with other Stephan tables are unresolved; rows are not independent new cohorts.

## Scientific interpretation and closed gates

**Abbreviations (as printed):** SET = nucleus triangularis septi; SFB = corpus subfornicale; HAM = nucleus medialis habenulae; EPI = epiphysis cerebri, corpus pineale; SCB = corpus subcommissuralis. Expansion locus: Table40 footnote printed p.449 / PDF55; Table1 printed pp.396–399 lists the same keys.

**Data role:** primary (provisional). Table40 is one of the book's own volumetric series (volumes Table40, indices Tables41–42); no caption or footnote attributes the values to earlier work. Overlap with earlier Stephan/Baron publications cannot be excluded without the absent Methods/bibliography.

**Dependencies:** The five structures are separate, non-nested measures, each with its own printed n; no totals.

**Known limitations:** Methods pp.12–24 and the full bibliography are absent from the held extract, so the measurement estimator, shrinkage correction, normalization, averaging over n and the unilateral/bilateral scope of paired structures are unestablished. No ×2, no unit scaling, no rounding repair, no accepted-name substitution (printed historical names, including abbreviated ones, are kept). Accepted-taxonomy, anatomy, specimen, method and laterality gates are HOLD; `Primary_ingestion_eligible` and `Merge_eligible` are FALSE on every row.  [TO CHECK: the Table13 README reports (Table5 printed p.409 footnote c) that the Hylomys suillus composition brain was a juvenile; not re-verified for this item.]

## Checks and release state

**QA (arithmetic, against printed values):**

- The table prints no totals or composites that could be checked arithmetically (five independent structures).
- Structural: 38 taxon rows parsed (assertion in R reader); all non-empty measure cells match the allowed token set; definitions cover every analysis column.

Printed values were NOT altered to resolve any mismatch; mismatches are documented here only.

**[TO CHECK] items:**

- [TO CHECK: human visual comparison of all 38 rows × 10 cells against printed pp.448–449]
- [TO CHECK: Echinosorex gymnurus EPI printed as '0' (n=1): kept as zero; whether this means absent/not measurable is not stated]
- [TO CHECK: C. stuhlmanni SCB printed '(0.0)' in parentheses (n=6): converted to NA, meaning of parentheses not explained in the held extract]
- [TO CHECK: SFB n=5 for Galemys and Talpa europaea; n=10 for Sorex araneus SFB and EPI; C. russula EPI n=5 — differing n between columns of one row]

**Pending:** HUMAN visual curation of every cell against the page image; clean R execution of the exact item script; owner registration in `__ReadMe.xlsx` (proposal only, see registry_proposals.csv) and only then the public TSV; Stephan collection-scoped species key mapping; methods/laterality certification. Shared registry, keys, merges, `_tools`, `_skills` and `__Public` were not changed. No FINISHED state is claimed.
