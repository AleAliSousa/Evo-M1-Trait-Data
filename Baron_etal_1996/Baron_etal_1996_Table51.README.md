# Baron et al. 1996 <e2><80><94> Table51

## Source and scope

Baron, G., Stephan, H., & Frahm, H. D. (1996). *Comparative Neurobiology in
Chiroptera: Macromorphology, Brain Structures, Tables, and Atlases*. Birkh<c3><a4>user.
ISBN **978-3-7643-5370-4**. Registry item `Baron_etal_1996_Table51`.

Pirlot's volume data for six species that Tables 10 and 32 do not cover, reprinted in the book as two stacked blocks. Secondary. Paleocortex and amygdala are pooled here, whereas Table 32 separates them.

Printed on PDF pages 166; 6 rows, matching the species count the book gives for
these structures in its own Table 1 key (PDF pp. 264-265). Columns carried:
`body_weight_g`, `brain_weight_mg`, `medulla_oblongata_mm3`, `mesencephalon_mm3`, `cerebellum_mm3`, `diencephalon_mm3`, `telencephalon_mm3`, `main_olfactory_bulb_mm3`, `paleocortex_plus_amygdala_mm3`, `septum_mm3`, `striatum_mm3`, `hippocampus_mm3`, `schizocortex_mm3`, `neocortex_mm3`.

## Reproducible pipeline

1. `baron_etal_1996 book Comparative Neurobiology.pdf`, pages 166, is the printed source.
2. `Baron_etal_1996_extract_snapshots.R` reads the PDF **word coordinates**
   (`pdftools::pdf_data`) and writes `Baron_etal_1996_Table51_snapshot.csv`. The book
   sets several tables in a staircase in which a row's values sit a half-line
   above its species name, so line-based parsing is not reliable; species names
   are the non-numeric tokens, data columns are recovered by clustering the right
   edges of the numeric tokens, and values are attached to species by a per-page
   vertical offset chosen to make the assignment injective.
3. `Baron_etal_1996_Table51.R` reads only the frozen snapshot and writes this local
   CSV plus `ISBN%3A9783764353704_Table51.tsv` in `__Public`.

The source's species wording, abbreviations and row order are preserved in
`Species_Baron1996`; current taxonomy is deferred to the paper-scoped species
crosswalk. All printed values are already in project units, so no unit
conversion is applied. The corresponding size-index and average-size-index
tables (Table52) are derived and are deliberately not transcribed.

## Checks

- exactly 6 rows, from *Penthetor lucasi (PTN)* through *Thyroptera tricolor (THY)*;
- 0 empty measurement cells (printed gaps in the source, not extraction losses);
- the extractor re-derives the frozen Table 10 and Table 32 snapshots on every
  run and stops unless every species string and every value matches exactly;
- OCR letterform repairs are explicit and listed in the extractor;
- merge wiring remains on the whole-source hold recorded in
  `Baron_etal_1996_overlap_taxonomy_audit.md`.

