# Stephan_etal_1991_Table71 — prepared source-backed table, NOT FINISHED

## Source and frozen evidence

Stephan, H., Baron, G., & Frahm, H. D. (1991). Insectivora (Vol. 1). Springer. https://doi.org/10.1007/978-1-4613-9124-1

**Source / locus:** held `Stephan_etal_1991.pdf` (178-page chapter-10 tables/atlas extract starting at printed p.395). This item is printed pp.493–494 / PDF pages 99–100: **Table 71. Area measurements of commissures and chiasma opticum in mm2** (running head "Midsagittal Fiber Complexes").

**Source format & legibility:** Scanned book page with an OCR text layer; print is sharp and every cell is legible at 300 dpi. The text layer is **not** reliable for this table and was rejected wherever it disagreed with the page image: it drops almost every thin `1` glyph in the n column (only n = 2, 3 and 4 survived), renders `0.038` as `0.Q38` and `0.015` as `0.Q15`, mangles `S. fumeus`/`N. fodiens` into `S·fumeus`/`N·fodiens`, and loses both printed `-.-` cells. Every value in the snapshot was read from the rendered page image.

`Stephan_etal_1991_Table71_snapshot.csv` freezes the published layout: caption, the two cross-references (Tables 72 and 73), the `n CCA COA CHO` header, the `Table 71 (cont.)` break and its repeated header, family rows, 43 printed taxon rows in printed order, printed decimal precision, printed taxon spellings/abbreviations, the two printed `-.-` cells, and the footnote block (`Number of individuals = n`; CCA/CHO/COA expansions in printed order). Running heads and page numbers are omitted, as in the Table13/16/61/68 snapshots. The caption's superscript 2 is written `mm2` (as the registry's `Item full original title` prints it). The snapshot is not an analysis dataframe.

**Reader provenance:** the values were read by an AI assistant (Claude, Anthropic), 2026-10-31, from page images rendered with `pdftools::pdf_convert` at 300 dpi and inspected zoomed, block by block. The PDF text layer was used only as a locator. **HUMAN visual curation is pending: no human has checked any value, label or footnote of this item.** `Human_visual_curation` is set to PENDING in every row.

## Reproducible preparation and files

**Method:** `Stephan_etal_1991_Table71.R` is the folder's shared item reader (identical body to `Stephan_etal_1991_Table68.R`) with Table 71 item settings, plus one item-specific addition: collection-scoped species resolution. It reads the frozen snapshot by position, resolves the two repeated header rows and asserts they agree, keeps printed taxon rows (asserting exactly 43), carries the printed family and the printed/PDF page per row, parses n and the three area measures as numeric, converts the printed `-.-` token to NA while recording it per row in `Missingness_note`, and attaches item-scoped provenance/gate text. The item settings in the script are labels and provenance only; it contains no measurement literals. It writes the analysis CSV and then the public TSV to `__Public/comparative-data/` only if `__ReadMe.xlsx` Sheet1 has exactly one row whose `Item name` equals the item (no guessed stem).

**Species resolution (new for this item).** Unlike Table68, this reader resolves the printed historical taxon label to an accepted binomial through the collection key `_keys/Stephan/species_key.csv`, filtered on `source_publication == "Stephan_etal_1991"` (43 rows, seeded for this item). The build **stops** if that filter returns no rows and **stops** if any printed label is unresolved; the printed label is kept verbatim in `Species_Stephan1991`. Six printed names resolve to a different accepted binomial — `Oryzorictes talpoides` → *Oryzorictes hova*, `Microgale dobsoni` → *Nesogale dobsoni*, `M. talazaci` → *Nesogale talazaci*, `Limnogale mergulus` → *Microgale mergulus*, `S. megalura` → *Suncus megalura*, `Echinosorex gymnurus` → *Echinosorex gymnura* — on the key's own recorded basis; nothing is decided in this script.

| file | role |
|---|---|
| `Stephan_etal_1991_Table71_snapshot.csv` | frozen source, printed layout |
| `Stephan_etal_1991_Table71.R` | reads the snapshot, writes CSV + public TSV |
| `Stephan_etal_1991_Table71.csv` | analysis rows (43 × 35) |
| `reference_tables/Stephan_etal_1991_Table71_definitions.csv` | data dictionary (10-column schema) |
| `__Public/comparative-data/10.1007%2F978-1-4613-9124-1_Table71.tsv` | public copy |

Analysis columns: Reference, Source_row, Species_Stephan1991, **Species**, Family_as_published, n, `CCA_author_reported_Area.mm2`, `COA_author_reported_Area.mm2`, `CHO_author_reported_Area.mm2`, Source_printed_page, Source_PDF_page, then the provenance/gate columns named as in Table61/68 (with `Source_volume_unit` replaced by `Source_area_unit`, whose value is written as the ASCII string `mm2 (printed with a superscript 2 in the Table 71 caption)`). Everything this reader writes is ASCII on purpose: the folder's shared reader writes with `fileEncoding = "UTF-8"`, which under a C locale degrades a literal `mm²`/`mm³` to the text `<U+00B2>`/`<U+00B3>` in every row — a latent defect the sibling items (Table61, Table68 and the rest, which do store a literal `mm³`) still have, and which this item sidesteps rather than fixes.

**Units:** mm2 as printed in the caption. These are **areas**, not volumes: they must never be pooled with a `*_Vol.mm3` column. No conversion, no ×2, no rounding repair.

**Observation level:** one row per printed historical taxon; the value is the author-reported per-taxon value over the printed n individuals (n = 1 for 40 taxa; *Atelerix algirus* n = 2, *Hemiechinus auritus* n = 3, *Crocidura flavescens* n = 4). Specimen identity and overlap with other Stephan tables are unresolved; rows are not independent new cohorts.

## Scientific interpretation and closed gates

**Abbreviations (as printed, p.494):** CCA = corpus callosum area; CHO = chiasma opticum; COA = commissura anterior. All three are midsagittal sectional areas of midline structures, so the unilateral/bilateral question that gates the volume tables does not arise here.

**Data role:** primary (provisional). The caption carries no "based on data given by …" attribution (contrast Table 68, which is Bauchot 1979b), so these are author-reported measurements of this book's own material. `Primary_ingestion_eligible` and `Merge_eligible` remain FALSE pending method certification and human curation.

**Dependencies:** Table 72 (size indices in species) and Table 73 (average size indices in supraspecific taxonomic units) are derived from these areas; this table is their area source. There is no within-table arithmetic relation.

**Known limitations:** Methods pp.12–24 and the full bibliography are absent from the held extract, so the measurement estimator (planimetry on midsagittal sections is presumed but not stated here), shrinkage correction, normalization and averaging over n are unestablished. Anatomy, specimen and method gates are HOLD; the laterality gate is N/A for midsagittal areas; the accepted-taxon gate is RESOLVED through the collection key.

## Table checks

The table prints no totals, no percentages and no other internal arithmetic relation, and areas of three unrelated midline structures are not additive — so there is no self-check to run and none was invented. No `table_checks` frame is produced. Structural assertions instead: the two printed header rows must agree, exactly 43 taxon rows must parse, every measure cell must match the allowed printed-token set, and every printed taxon must resolve in the collection species key (all four hold on the recorded run).

## Checks and release state

- 43 taxon rows parsed; 35 analysis columns; definitions cover every column.
- 2 printed `-.-` cells (CHO for *Scalopus aquaticus* and *Cryptotis parva*) → NA, token recorded per row in `Missingness_note`.
- All 43 printed labels resolved against `_keys/Stephan/species_key.csv`.
- R script run clean with `Rscript --vanilla` on 2026-10-31; CSV and public TSV written.

Printed values were NOT altered. No erratum is raised: no discrepancy with the printed page was found.

**[TO CHECK] items:**

- [TO CHECK: human visual comparison of all 43 rows × 4 cells against printed pp.493–494]
- [TO CHECK: whether CCA here is consistent with the corpus callosum area used elsewhere in the collection]

**Pending:** HUMAN visual curation of every cell against the page image; owner paste of `Stephan_etal_1991_Table71_registry_row.xlsx` into `__ReadMe.xlsx` Sheet1; method/estimator certification. Shared keys, merges, `_tools`, `_skills` were not changed (the species key already carried the 43 rows for this item). No FINISHED state is claimed.
