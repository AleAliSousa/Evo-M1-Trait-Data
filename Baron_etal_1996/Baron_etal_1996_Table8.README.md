# Baron et al. 1996 <e2><80><94> Table8

## Source and scope

Baron, G., Stephan, H., & Frahm, H. D. (1996). *Comparative Neurobiology in
Chiroptera: Macromorphology, Brain Structures, Tables, and Atlases*. Birkh<c3><a4>user.
ISBN **978-3-7643-5370-4**. Registry item `Baron_etal_1996_Table8`.

volumes of net brain (NET), ventricles (VENT) and rests (REST). Only the mm3 columns are printed measurements; the percentage columns are the book's own derivation against the standard brain volume and are carried for reference.

Printed on PDF pages 46-53; 272 rows, matching the species count the book gives for
these structures in its own Table 1 key (PDF pp. 264-265). Columns carried:
`n`, `net_brain_mm3`, `net_brain_pct_of_standard`, `ventricles_mm3`, `ventricles_pct_of_standard`, `rests_mm3`, `rests_pct_of_standard`.

## Reproducible pipeline

1. `baron_etal_1996 book Comparative Neurobiology.pdf`, pages 46-53, is the printed source.
2. `Baron_etal_1996_extract_snapshots.R` reads the PDF **word coordinates**
   (`pdftools::pdf_data`) and writes `Baron_etal_1996_Table8_snapshot.csv`. The book
   sets several tables in a staircase in which a row's values sit a half-line
   above its species name, so line-based parsing is not reliable; species names
   are the non-numeric tokens, data columns are recovered by clustering the right
   edges of the numeric tokens, and values are attached to species by a per-page
   vertical offset chosen to make the assignment injective.
3. `Baron_etal_1996_Table8.R` reads only the frozen snapshot and writes this local
   CSV plus `ISBN%3A9783764353704_Table8.tsv` in `__Public`.

The source's species wording, abbreviations and row order are preserved in
`Species_Baron1996`; current taxonomy is deferred to the paper-scoped species
crosswalk. All printed values are already in project units, so no unit
conversion is applied. The corresponding size-index and average-size-index
tables (Table9) are derived and are deliberately not transcribed.

## Checks

- exactly 272 rows, from *Eidolon helvum* through *Cheiromeles torquatus*;
- 7 empty measurement cells (printed gaps in the source, not extraction losses);
- the extractor re-derives the frozen Table 10 and Table 32 snapshots on every
  run and stops unless every species string and every value matches exactly;
- OCR letterform repairs are explicit and listed in the extractor;
- merge wiring remains on the whole-source hold recorded in
  `Baron_etal_1996_overlap_taxonomy_audit.md`.


<!-- errata:begin -->
## Errata

Generated from `reference_tables/Baron_etal_1996_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| Baron_etal_1996-E001 | * | Table 8 p.47 (PDF page 47), row 'Nyctimene albiventer' | NET 779.1 mm3; VENT 8.8 mm3; REST 8.5 mm3 | NET 3; VENT 3; REST 3 | repo_transcription_error | net_brain_mm3=779.1; ventricles_mm3=8.8; rests_mm3=8.5 | confirmed | Printed row on PDF page 47 (pdftotext -layout). The superscript '3' of the page header 'mm3' was attached by the coordinate extractor to the first species row of the page; the printed % columns (NET 97.8%) are consistent with the printed mm3 values, not with 3. | Fixed in Baron_etal_1996_Table8_snapshot.csv (the frozen transcription) and in Baron_etal_1996_extract_snapshots.R, which now drops header-line numerals; first row of each page 47-53 was affected. Found because Total_brain_net_volume_Vol.mm3 = 3 mm3 for these bats in __merging_volumes. |
| Baron_etal_1996-E002 | * | Table 8 p.48 (PDF page 48), row 'Nycteris arge' | NET 331.0 mm3; VENT 1.0 mm3; REST 3.0 mm3 | NET 3; VENT 3; REST 3 | repo_transcription_error | net_brain_mm3=331.0; ventricles_mm3=1.0; rests_mm3=3.0 | confirmed | Printed row on PDF page 48 (pdftotext -layout). The superscript '3' of the page header 'mm3' was attached by the coordinate extractor to the first species row of the page; the printed % columns (NET 98.8%) are consistent with the printed mm3 values, not with 3. | Fixed in Baron_etal_1996_Table8_snapshot.csv (the frozen transcription) and in Baron_etal_1996_extract_snapshots.R, which now drops header-line numerals; first row of each page 47-53 was affected. Found because Total_brain_net_volume_Vol.mm3 = 3 mm3 for these bats in __merging_volumes. |
| Baron_etal_1996-E003 | * | Table 8 p.49 (PDF page 49), row 'Hipposideros halophyllus' | NET 142.4 mm3; VENT 1.6 mm3; REST 2.8 mm3 | NET 3; VENT 3; REST 3 | repo_transcription_error | net_brain_mm3=142.4; ventricles_mm3=1.6; rests_mm3=2.8 | confirmed | Printed row on PDF page 49 (pdftotext -layout). The superscript '3' of the page header 'mm3' was attached by the coordinate extractor to the first species row of the page; the printed % columns (NET 97.0%) are consistent with the printed mm3 values, not with 3. | Fixed in Baron_etal_1996_Table8_snapshot.csv (the frozen transcription) and in Baron_etal_1996_extract_snapshots.R, which now drops header-line numerals; first row of each page 47-53 was affected. Found because Total_brain_net_volume_Vol.mm3 = 3 mm3 for these bats in __merging_volumes. |
| Baron_etal_1996-E004 | * | Table 8 p.50 (PDF page 50), row 'Glossophaga longirostris' | NET 414.3 mm3; VENT 2.2 mm3; REST 3.4 mm3 | NET 3; VENT 3; REST 3 | repo_transcription_error | net_brain_mm3=414.3; ventricles_mm3=2.2; rests_mm3=3.4 | confirmed | Printed row on PDF page 50 (pdftotext -layout). The superscript '3' of the page header 'mm3' was attached by the coordinate extractor to the first species row of the page; the printed % columns (NET 98.7%) are consistent with the printed mm3 values, not with 3. | Fixed in Baron_etal_1996_Table8_snapshot.csv (the frozen transcription) and in Baron_etal_1996_extract_snapshots.R, which now drops header-line numerals; first row of each page 47-53 was affected. Found because Total_brain_net_volume_Vol.mm3 = 3 mm3 for these bats in __merging_volumes. |
| Baron_etal_1996-E005 | * | Table 8 p.51 (PDF page 51), row 'Desmodus rotundus' | NET 944.4 mm3; VENT 8.8 mm3; REST 11.1 mm3 | NET 3; VENT 3; REST 3 | repo_transcription_error | net_brain_mm3=944.4; ventricles_mm3=8.8; rests_mm3=11.1 | confirmed | Printed row on PDF page 51 (pdftotext -layout). The superscript '3' of the page header 'mm3' was attached by the coordinate extractor to the first species row of the page; the printed % columns (NET 97.9%) are consistent with the printed mm3 values, not with 3. | Fixed in Baron_etal_1996_Table8_snapshot.csv (the frozen transcription) and in Baron_etal_1996_extract_snapshots.R, which now drops header-line numerals; first row of each page 47-53 was affected. Found because Total_brain_net_volume_Vol.mm3 = 3 mm3 for these bats in __merging_volumes. |
| Baron_etal_1996-E006 | * | Table 8 p.52 (PDF page 52), row 'Tylonyeteris paehypus' | NET 75.5 mm3; VENT 0.4 mm3; REST 1.4 mm3 | NET 3; VENT 3; REST 3 | repo_transcription_error | net_brain_mm3=75.5; ventricles_mm3=0.4; rests_mm3=1.4 | confirmed | Printed row on PDF page 52 (pdftotext -layout). The superscript '3' of the page header 'mm3' was attached by the coordinate extractor to the first species row of the page; the printed % columns (NET 97.8%) are consistent with the printed mm3 values, not with 3. | Fixed in Baron_etal_1996_Table8_snapshot.csv (the frozen transcription) and in Baron_etal_1996_extract_snapshots.R, which now drops header-line numerals; first row of each page 47-53 was affected. Found because Total_brain_net_volume_Vol.mm3 = 3 mm3 for these bats in __merging_volumes. |
| Baron_etal_1996-E007 | * | Table 8 p.53 (PDF page 53), row 'Tadarida aegyptiaca' | NET 369.6 mm3; VENT 4.7 mm3; REST 5.1 mm3 | NET 3; VENT 3; REST 3 | repo_transcription_error | net_brain_mm3=369.6; ventricles_mm3=4.7; rests_mm3=5.1 | confirmed | Printed row on PDF page 53 (pdftotext -layout). The superscript '3' of the page header 'mm3' was attached by the coordinate extractor to the first species row of the page; the printed % columns (NET 97.4%) are consistent with the printed mm3 values, not with 3. | Fixed in Baron_etal_1996_Table8_snapshot.csv (the frozen transcription) and in Baron_etal_1996_extract_snapshots.R, which now drops header-line numerals; first row of each page 47-53 was affected. Found because Total_brain_net_volume_Vol.mm3 = 3 mm3 for these bats in __merging_volumes. |

7 recorded, 0 open (proposed), 7 confirmed, 0 withdrawn.
<!-- errata:end -->
