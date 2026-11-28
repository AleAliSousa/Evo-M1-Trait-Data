# Baron et al. 1996 <e2><80><94> Table36

## Source and scope

Baron, G., Stephan, H., & Frahm, H. D. (1996). *Comparative Neurobiology in
Chiroptera: Macromorphology, Brain Structures, Tables, and Atlases*. Birkh<c3><a4>user.
ISBN **978-3-7643-5370-4**. Registry item `Baron_etal_1996_Table36`.

Schneider's (1957b) cortical surface-area measurements, reprinted in the book. Secondary: not a Frankfurt-collection measurement.

Printed on PDF pages 159; 14 rows, matching the species count the book gives for
these structures in its own Table 1 key (PDF pp. 264-265). Columns carried:
`total_cortex_mm2`, `olfactory_bulb_mm2`, `total_minus_bulb_mm2`, `neocortex_mm2`, `allocortex_mm2`, `allocortex_minus_bulb_mm2`, `paleocortex_plus_schizocortex_mm2`, `hippocampus_mm2`, `cingulate_mm2`.

## Reproducible pipeline

1. `baron_etal_1996 book Comparative Neurobiology.pdf`, pages 159, is the printed source.
2. `Baron_etal_1996_Table36_snapshot.R` reads the PDF **word coordinates**
   (`pdftools::pdf_data`) and writes `Baron_etal_1996_Table36_snapshot.csv`. The book
   sets several tables in a staircase in which a row's values sit a half-line
   above its species name, so line-based parsing is not reliable; species names
   are the non-numeric tokens, data columns are recovered by clustering the right
   edges of the numeric tokens, and values are attached to species by a per-page
   vertical offset chosen to make the assignment injective.
3. `Baron_etal_1996_Table36.R` reads only the frozen snapshot and writes this local
   CSV plus `ISBN%3A9783764353704_Table36.tsv` in `__Public`.

The source's species wording, abbreviations and row order are preserved in
`Species_Baron1996`; current taxonomy is deferred to the paper-scoped species
crosswalk. All printed values are already in project units, so no unit
conversion is applied. The corresponding size-index and average-size-index
tables (Table37-38) are derived and are deliberately not transcribed.

## Checks

- exactly 14 rows, from *Pteropus giganteus* through *Miniopterus schreib.*;
- no empty measurement cells after correction of the printed `Natalus mexicanus`
  cingulate value (2.8); the PDF text layer had attached `2;8` to the name;
- the extractor re-derives the frozen Table 10 and Table 32 snapshots on every
  run and stops unless every species string and every value matches exactly;
- OCR letterform repairs are explicit and listed in the extractor;
- merge wiring remains on the whole-source hold recorded in
  `Baron_etal_1996_overlap_taxonomy_audit.md`.

## Source-layout and data correction (2026-11-27)

Compared printed Table 36 on PDF page 159. The snapshot now has its printed
caption, two-tier column headings and 14 species rows, without extractor
metadata columns. The old flattened column names shifted four meanings:
printed `BOL` had been called `TOT_minus_BOL`, printed `TOT minus BOL` had been
called `ALLO_minus_BOL`, printed `ALLO minus BOL` had been called
`PAL_plus_BOL`, and printed `PAL plus SCH` had been called `SCH`. The R output
and variable definitions now use the correct printed meanings. The clearly
visible final `Natalus mexicanus` value is 2.8, not a blank; its name was
also repaired. Run `Rscript Baron_etal_1996/Baron_etal_1996_Table36_snapshot.R`
then `Rscript Baron_etal_1996/Baron_etal_1996_Table36.R` from the repository
root. Both ran successfully. This is an assistant source check, not independent
human signoff.

