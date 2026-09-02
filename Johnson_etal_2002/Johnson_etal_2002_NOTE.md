# Johnson et al. 2002 — deferred (decimal-glyph extraction hazard)

Johnson VE, Deaner RO, van Schaik CP (2002). *Bayesian analysis of rank data with application to
primate intelligence experiments.* JASA 97(457):8–17. doi:10.1198/016214502753479185.
Registry item `Johnson_etal_2002_Table1` ("Rankings of 24 primate genera across 30 procedures").

## Why deferred (2026-08-31)
The PDF's text layer corrupts the fractional tie ranks: printed "6.5" extracts as "605",
"2.5" as "205", "1.5" as "105", "8.5" as "805" (decimal glyph rendered as a spurious "0").
A trustworthy build therefore needs full image-based transcription of the 24×30 matrix, cell by
cell — not done in this pass.

## Do this first
**`Deaner_etal_2006_Table1` is BUILT** (same Deaner/Johnson/van Schaik meta-analytic lineage,
described in its registry note as "largely overlaps Johnson et al. (2002) Table 1"). Decide
whether Johnson 2002 adds anything the 2006 table lacks before spending the transcription effort;
if built later, cross-validate every cell against Deaner 2006 (the overlap makes most
corruptions detectable automatically: 605→6.5 etc.), and treat the two items as NON-independent.
