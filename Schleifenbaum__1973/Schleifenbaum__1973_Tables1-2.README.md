# Schleifenbaum 1973 — Tables 1–2

## Source

Schleifenbaum, C. (1973). *Untersuchungen zur postnatalen Ontogenese des Gehirns
von Großpudeln und Wölfen*. **Z. Anat. Entwicklungsgesch. 141**, 179–205.
DOI **10.1007/BF00519885**. Registry item
`Schleifenbaum__1973_Tables1-2`.

Table 1 supplies sex, age, net body mass (`NKG`, g), and brain mass (`HG`, g)
for 33 individuals: 18 standard poodles and 15 wolves. Asterisks mark the 13
brains selected for serial-section measurement. Table 2 reports fresh-brain-
corrected absolute volumes for those 13 columns; individual 10 is printed as
all dashes, leaving 12 complete regional profiles. Table 3 is relative
composition derived from Table 2 and is not duplicated.

## Pipeline

1. The printed sources are PDF pages 3–4. Table 2 is rotated 90° in the PDF and
   was checked in the correct orientation.
2. `Schleifenbaum__1973_Tables1-2_extract_snapshot.R` writes two frozen CSVs:
   Table 1 in printed row order and Table 2 in its printed structure-as-rows
   layout. German decimal commas, asterisks, parentheses, and dashes survive in
   the snapshots.
3. `Schleifenbaum__1973_Tables1-2.R` joins on individual number, converts brain
   mass g → mg, preserves body mass in g and volumes in mm³, and writes the
   33-row analysis CSV plus `10.1007%2FBF00519885_Tables1-2.tsv`.

`Großpudel` and `Wölfe` remain as the source labels; separate `Species` values
provide `Canis lupus familiaris` and `Canis lupus`. The parenthesized, uncertain
body/brain values for wolf 10 are retained and flagged, not discarded.

## Checks and caveat

- 33 Table 1 individuals; 13 asterisked/sectioned; 12 complete Table 2 volume
  profiles because no values are printed for individual 10;
- 16 Table 2 measures, including whole-brain volume;
- the pre-existing `comparison/Schleifenbaum Canis brain region volumes.xlsx`
  is an 18 KB all-zero file rather than a valid workbook, so it cannot provide
  an independent comparison and has not been used or altered;
- merge wiring is deferred until the developmental-age policy is explicit:
  neonatal and juvenile brains must not be silently pooled with adult species
  means.
