# Ebinger 1974 — Tables 3–4

## Source

Ebinger, P. (1974). *A cytoarchitectonic volumetric comparison of brains in wild
and domestic sheep*. **Z. Anat. Entwicklungsgesch. 144**, 267–302.
DOI **10.1007/BF00522811**. Registry item `Ebinger__1974_Tables3-4`.

Tables 3 and 4 contain the per-individual primary measurements: four wild sheep
(`M1`–`M4`) and six domestic sheep (`Sk1`–`Sk3`, `H1`–`H3`), with brain mass,
whole/pure-brain volume, and 21 regional/component volumes. Tables 5 onward are
percentages or group summaries derived from these values and are not duplicated.

## Pipeline

1. The printed tables are PDF pages 17–18 of
   `Ebinger-1974-A cytoarchitectonic.pdf`.
2. `Ebinger__1974_Table3_snapshot.csv` and
   `Ebinger__1974_Table4_snapshot.csv` preserve the separate printed grids,
   with measure rows and individual columns. The former combined snapshot was
   retired as `Ebinger__1974_Tables3-4_snapshot.csv.retired`.
3. `Ebinger__1974_Tables3-4.R` joins those snapshots by printed measure row,
   then pivots them to ten individual rows,
   converts brain mass from g to mg, and writes the analysis CSV plus
   `10.1007%2FBF00522811_Tables3-4.tsv`.
4. The comparison script checks all 260 printed cells against the existing
   Adobe-to-Excel export. The export's `J2879` artifact is explicitly read as
   the rendered `12879`; no other repair is applied.

The paper's names (`Ovis ammon musimon`, `Ovis ammon f. aries`) and breed/status
labels are preserved. Current taxonomy is deferred to the source-scoped key.

## Verification

- 10 individual rows, 26 numeric measurements each;
- 260/260 snapshot values match the existing Excel export after the one
  documented OCR glyph repair;
- rendered pages settle two easily misread cells: `Sk3` cerebellum = 12879 and
  `H2` cerebellum = 11008;
- species aggregation and wild/domestic contrasts are downstream operations,
  not performed in the source build.

## Snapshot layout audit (2026-11-27)

The previous snapshot joined the two printed tables and inserted a unit
column. Separated the grids into Table 3 (five columns) and Table 4 (seven
columns), with units derived from the captions in R. The earlier documented
human checks for the Sk3 and H2 cerebellum cells remain authoritative; the
OCR text layer differs at H2, so its 11008 value was preserved. Ran
`Rscript Ebinger__1974/Ebinger__1974_Tables3-4.R`; the derived CSV retained
SHA-256 `7dbc204ffe2b87b5ee13fb97d6242c886cabe877ea490950fae06ee188e60469`.
