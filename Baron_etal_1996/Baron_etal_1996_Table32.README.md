# Baron et al. 1996 — Table 32

## Source and scope

Same book and ISBN as Table 10. Registry item `Baron_etal_1996_Table32`.
Table 32 prints volumes (mm³) of eight telencephalic components for the same 272
chiropteran rows: main olfactory bulb, paleocortex, striatum, septum, amygdala,
hippocampus, schizocortex, and neocortex.

## Reproducible pipeline

1. The printed source is PDF pages 138–145 of
   `baron_etal_1996 book Comparative Neurobiology.pdf`.
2. `Baron_etal_1996_extract_snapshots.py` writes the frozen
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
- merge wiring is deferred pending the same Baron1996 taxonomy/overlap audit as
  Table 10.
