# Felleman_VanEssen_1991_Table3 — Matrix of connections in visual cortex

Felleman, D. J., & Van Essen, D. C. (1991). Distributed hierarchical processing in the primate
cerebral cortex. *Cerebral Cortex*, 1(1), 1–47. https://doi.org/10.1093/cercor/1.1.1

## What this item is
Table 3 is a 35(from) × 32(to) symbol matrix recording, for every pair of macaque visual
cortical areas, whether an interareal anatomical connection has been reported, tested and
found absent, or left untested. Three row labels (PIT, CIT, STP) are historical/umbrella area
names kept as sources but with no matching destination column (superseded by their
subdivisions PITd/PITv/PITd, CITd/CITv, STPp/STPa as targets) — this row/column asymmetry is
a genuine feature of the printed table, preserved as-is.

## Why this build took two passes
The registry's own recommendation for this item flagged it as "all symbols... the snapshot
should keep the symbols, but then the next step needs to be converted into a readable data
type." A first attempt worked from a scanned photocopy PDF (`Felleman_VanEssen_1991.pdf`) and
tried to localize each of the matrix's 1,120 cells by detecting the table's printed gridlines
in the rendered bitmap. That failed: the gridlines in that scan are thin, inconsistently
printed, and not evenly spaced (confirmed by cross-validating gridline-based cell boundaries
against independent pixel-classification of cell contents — the two methods disagreed on
roughly half of a test row). No cell-boundary detection method tried recovered the true grid
reliably from that file.

The owner then supplied a second, much larger file, `Felleman-1991-Distributed hierarchical
process.pdf` (15.1 MB, an Oxford Academic typeset PDF of the full article rather than a
scanned photocopy of just this paper). Its rendered bitmap has the same inherent gridline
faintness as the original scan (the 1991 foldout table itself has thin internal rules — this
is a property of the print, not of scan quality), so pixel-based gridline detection still
failed on it. **The decisive difference is that this PDF carries a real embedded text layer**:
every printed character — including the matrix's "+", ".", "?", "N", "R" symbols — has an
exact, sub-pixel character bounding box recoverable via `pypdfium2`'s `get_charbox()`, rather
than needing to be read off a bitmap.

## Reconstruction method
1. **Row positions**: the 35 row labels (`From: V1, V2, ..., 46`) are real text, evenly spaced
   at exactly 12.0 PDF points apart — read directly, no ambiguity.
2. **Column positions**: the 32 column labels are also real text, split across four header
   lines (one per OCCIPITAL/TEMPORAL/PARIETAL/FRONTAL anatomical group, matching how the
   PDF's content stream draws the table group-by-group). Extracted and concatenated into one
   32-column x-position table; spacing is a uniform ~12.3 pt within each anatomical group,
   with a wider ~25 pt margin at each of the 3 group boundaries (PIT|CIT, CIT|next-4, STP|
   next) — confirmed consistent across the full header line.
3. **"+", "?", "N"+"R" (→ "NR"/"NR?") characters**: 285 of these symbols are themselves real
   text characters with exact positions; each was assigned to its nearest row/column center.
   A small number of "NR"/"NR?" tokens (3-character strings) had a systematic rightward
   centroid offset relative to a true cell center (because a 3-character token's midpoint
   sits right of a single "+" glyph's midpoint) — corrected for the 3 cases where this
   pushed a token's nearest-column match to the wrong column (confirmed against the rendered
   page image in each case).
4. **Diagonal cells**: the paper's own caption states shaded diagonal boxes are intrinsic
   circuitry, excluded from the tabulated pathways — so every cell where `from_area ==
   to_area` (32 of them) is set to the diagonal marker by construction, not by reading the
   shading pattern.
5. **"." (dot, tested-absent) vs. blank (not tested)**: dots are drawn as small vector
   shapes, not text characters, so they don't appear in the text layer. For every cell not
   already assigned a text symbol, pixel darkness was measured inside a tight window centered
   on that cell's now-precisely-known (row, column) coordinate — reliable specifically because
   the coordinates themselves came from the text layer, not from gridline detection. A
   darkness-fraction histogram cleanly separated three populations: blank (~0), dot (~0.04–
   0.25), and — surprisingly — a third cluster at ~0.30–0.42 matching confirmed "+" cells
   exactly. That third cluster (15 cells, concentrated in rows V4 and MSTd, plus 2 more found
   by a systematic blob-size sweep of all 35 rows: V1→STPa and MSTd→MT) turned out to be real
   "+" symbols that the text layer simply failed to capture for those specific glyphs —
   recovered via this pixel cross-check rather than lost. Every reclassification was confirmed
   by a direct visual crop of that exact cell against the rendered page.
6. **Large vs. small "+" (evidence tier)**: the paper's own caption states large "+" = pathway
   reported in ≥1 full-length manuscript, small "+" = reported only in an abstract or
   unpublished study. This distinction is captured by this PDF's font metrics: the 269 "+"
   characters recovered from the text layer have a clearly bimodal character-box height
   (~4.3–4.4 pt for small vs. ~5.9–6.2 pt for large), split at a threshold of 5.0 pt
   (222 large, 47 small). The 17 "+" symbols recovered only via the pixel cross-check (step 5)
   have no font-size information and are coded `evidence_tier = "unresolved"` rather than
   guessed.

## Validation
- All 1,120 (row, column) cells accounted for exactly once; every row has exactly 32 cells.
- Spot-checked numerous individual cells (including two where my own earlier manual reading
  of the table, before this method was adopted, had gotten the symbol or position wrong) by
  cropping the exact rendered pixel region for that cell and viewing it directly — all matched
  the final reconstruction, including a non-obvious case (V2→FEF = "?") that contradicted an
  earlier manual read.
- `connection_code`, `is_diagonal_intrinsic`, and `evidence_tier` counts cross-checked in the
  R build script (`stopifnot`).

## Files
- `Felleman_VanEssen_1991_Table3_snapshot.csv` — frozen, verbatim symbol matrix (35×32 wide
  format, one row per `From` area), exactly as printed (including blanks).
- `Felleman_VanEssen_1991_Table3.csv` / public TSV — long format (1,120 rows), one row per
  (from_area, to_area) pair, with the recoded columns described in
  `reference_tables/Felleman_VanEssen_1991_Table3_definitions.csv`.

## Data role
**Primary** — this is the paper's own reported connectivity matrix, reconstructed from the
publisher's typeset PDF rather than re-derived or compiled from another source.

## Known limitation
`evidence_tier` is `"unresolved"` for 17 of 286 reported connections (1.5% of all 1,120
cells) where the manuscript-vs-abstract-only distinction could not be read from the PDF's
font metrics. These 17 connections are coded as present (`connection_code = 1`); only their
evidence tier is undetermined.
