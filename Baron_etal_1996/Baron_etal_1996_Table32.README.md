# Baron et al. 1996 — Table 32

## Source and scope

Same book and ISBN as Table 10. Registry item `Baron_etal_1996_Table32`.
Table 32 prints volumes (mm³) of eight telencephalic components for the same 272
chiropteran rows: main olfactory bulb, paleocortex, striatum, septum, amygdala,
hippocampus, schizocortex, and neocortex.

## Reproducible pipeline

1. The printed source is PDF pages 138–145 of
   `baron_etal_1996 book Comparative Neurobiology.pdf`.
2. `Baron_etal_1996_Table32_snapshot.R` (R port, 2026-11-12, of the retired `Baron_etal_1996_Table32_snapshot.py.retired`; run in a temp dir it regenerates the frozen snapshot byte-for-byte) writes the frozen
   `Baron_etal_1996_Table32_snapshot.csv`; literal OCR repairs are recorded in
   the script.
3. `Baron_etal_1996_Table32.R` reads that snapshot and the Table 10 snapshot.
   It uses the common 1–272 row sequence to carry Table 10's stable within-book
   species string while retaining Table 32's own printed abbreviation in
   `Species_printed_Table32`. It writes the local CSV and
   `ISBN%3A9783764353704_Table32.tsv`.

The table refers readers to Table 33 for numbers of individuals; no `n` is
invented here. All measures are already in mm³. Tables 33–34 contain derived
size indices and are intentionally excluded.

## Checks

- exactly 272 rows and eight non-missing volumes per row;
- the Table 10 and Table 32 row-number sequences are identical;
- `comparison/Baron_etal_1996_Table32_compare_to_Table10.R` sums the eight
  components and compares them with Table 10 telencephalon. Median absolute
  difference is 0.06 mm³. Two source inconsistencies exceed 1.5 mm³: *Anoura
  caudifer* (−1.86) and *Vampyrops brachycephalus* (+23.71); rendered pages
  confirm the transcribed values, so they are flagged rather than silently fixed;
- the shared Baron1996 taxonomy/overlap audit is complete and finds zero current core overlap;
  merge wiring remains on hold for seven historical taxon concepts and the required within-source
  species averaging.

## Source-layout correction (2026-11-27)

The snapshot now follows printed Table 32 across PDF pp. 138–145,
with the caption, source-order species and taxonomic headings, repeated
page headers, and page breaks. `is_header`, `source_pdf_page`, and
`species_row` are derived by `_read_baron_multpage.R`. The abbreviation
definitions at the bottom of the last page are represented by their heading
only. `Rscript --vanilla Baron_etal_1996_Table32.R` reproduced the prior
272-row analysis CSV cell for cell; `Rscript --vanilla
Baron_etal_1996_Table32_snapshot.R` passed the source-grid regression.
This is an assistant layout check, not human visual signoff.
