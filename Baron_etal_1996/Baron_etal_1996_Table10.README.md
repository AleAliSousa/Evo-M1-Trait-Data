# Baron et al. 1996 — Table 10

## Source and scope

Baron, G., Stephan, H., & Frahm, H. D. (1996). *Comparative Neurobiology in
Chiroptera: Macromorphology, Brain Structures, Tables, and Atlases*. Birkhäuser.
ISBN **978-3-7643-5370-4**. Registry item `Baron_etal_1996_Table10`.

Table 10 prints species-level volumes (mm³) of the five fundamental brain parts
for 272 chiropteran rows: medulla oblongata, mesencephalon, cerebellum,
diencephalon, and telencephalon. The printed `n` is retained; seven rows have no
printed `n` and remain missing rather than being inferred.

## Reproducible pipeline

1. `baron_etal_1996 book Comparative Neurobiology.pdf`, PDF pages 56–63, is the
   printed source.
2. `Baron_etal_1996_extract_snapshots.py` reads the PDF text layer and writes
   `Baron_etal_1996_Table10_snapshot.csv`. Its small, literal OCR-repair table is
   documented in code and was checked against rendered page images.
3. `Baron_etal_1996_Table10.R` reads only the frozen snapshot and writes the
   local analysis CSV plus `ISBN%3A9783764353704_Table10.tsv` in `__Public`.

The source's species wording, abbreviations, addendum marker (§), and row order
are preserved in `Species_Baron1996`; current taxonomy is intentionally deferred
to the paper-scoped species crosswalk. All printed volumes are already in project
units (mm³), so no unit conversion is applied. Size indices in Tables 11–12 are
derived and are not transcribed.

## Checks

- exactly 272 rows, from *Eidolon helvum* through *Cheiromeles torquatus*;
- five non-missing volume fields on every row;
- the first and final table pages were visually checked, and every malformed
  numeric OCR token is listed explicitly in the extraction script;
- the Table 32 component-sum audit has a median absolute difference of 0.06 mm³
  from Table 10 telencephalon (rounding scale). Two much larger differences are
  visibly printed source inconsistencies, documented in the comparison report;
- merge wiring is deferred until the 272-row Baron1996 taxonomy crosswalk and
  overlap audit against earlier Stephan-collection bat sources are complete.
