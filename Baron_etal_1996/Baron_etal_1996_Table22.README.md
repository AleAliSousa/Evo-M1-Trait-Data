# Baron et al. 1996 <e2><80><94> Table22

## Source and scope

Baron, G., Stephan, H., & Frahm, H. D. (1996). *Comparative Neurobiology in
Chiroptera: Macromorphology, Brain Structures, Tables, and Atlases*. Birkh<c3><a4>user.
ISBN **978-3-7643-5370-4**. Registry item `Baron_etal_1996_Table22`.

volumes of the auditory nuclei of the medulla oblongata.

Printed on PDF pages 110-114; 150 rows, matching the species count the book gives for
these structures in its own Table 1 key (PDF pp. 264-265). Columns carried:
`auditory_nuclei_mm3`, `cochlear_nuclei_mm3`, `nucleus_cochlearis_dorsalis_mm3`, `nucleus_cochlearis_ventralis_mm3`, `complexus_olivaris_superior_mm3`.

## Reproducible pipeline

1. `baron_etal_1996 book Comparative Neurobiology.pdf`, pages 110-114, is the printed source.
2. `Baron_etal_1996_extract_snapshots.R` reads the PDF **word coordinates**
   (`pdftools::pdf_data`) and writes `Baron_etal_1996_Table22_snapshot.csv`. The book
   sets several tables in a staircase in which a row's values sit a half-line
   above its species name, so line-based parsing is not reliable; species names
   are the non-numeric tokens, data columns are recovered by clustering the right
   edges of the numeric tokens, and values are attached to species by a per-page
   vertical offset chosen to make the assignment injective.
3. `Baron_etal_1996_Table22.R` reads only the frozen snapshot and writes this local
   CSV plus `ISBN%3A9783764353704_Table22.tsv` in `__Public`.

The source's species wording, abbreviations and row order are preserved in
`Species_Baron1996`; current taxonomy is deferred to the paper-scoped species
crosswalk. All printed values are already in project units, so no unit
conversion is applied. The corresponding size-index and average-size-index
tables (Table23-24) are derived and are deliberately not transcribed.

## Checks

- exactly 150 rows, from *Eidolon helvum* through *Cheiromeles torquatus*;
- 0 empty measurement cells (printed gaps in the source, not extraction losses);
- the extractor re-derives the frozen Table 10 and Table 32 snapshots on every
  run and stops unless every species string and every value matches exactly;
- OCR letterform repairs are explicit and listed in the extractor;
- merge wiring remains on the whole-source hold recorded in
  `Baron_etal_1996_overlap_taxonomy_audit.md`.

