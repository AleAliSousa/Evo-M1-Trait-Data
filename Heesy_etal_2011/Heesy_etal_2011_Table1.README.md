# Heesy_etal_2011_Table1 — Morphometric and ecological data (visual pathway and orbit convergence)

Heesy, C. P., Kamilar, J. M., & Willms, J. (2011). Retinogeniculostriate pathway components
scale with orbit convergence only in primates and not in other mammals. *Brain, Behavior and
Evolution*, 77(2), 105–115. https://doi.org/10.1159/000324860

## Relationship to Heesy (2004)
The repo already has `Heesy__2004_Table1` (27 taxa: orbit convergence + binocular visual-field
overlap only). This 2011 paper is a **different, larger, non-duplicate compilation** — 84 taxa
with entirely new variables not present in the 2004 table at all: activity pattern, body mass,
whole-brain volume, optic tract volume, LGN volume, and V1 volume (the retinogeniculostriate
pathway components this paper is about). A number of species overlap with the 2004 table (e.g.
*Felis catus*, *Pteropus poliocephalus*, *Dasyurus hallucatus*, reusing published convergence
values), but 8 of 84 rows carry a convergence value explicitly flagged in the source as newly
digitized for this study (`CONV_digitized_for_this_study = TRUE`), not carried over from 2004.

## What this item is
84 mammalian taxa (11 orders) with orbit convergence, activity pattern, body mass, and four
brain-volume measures (whole brain, optic tract, LGN, V1), each row citing its source(s) by a
numbered footnote code.

## Build method
Table 1 spans two pages (PDF pp. 4–5 of 11) with a per-row "Source" column and some rows missing
one or more of the volumetric measures. The PDF's text layer is already in natural row order
(unlike Felleman & Van Essen 1991's Table 3), so this was extracted by **character-position
column assignment**: each character's (x, y) position was mapped to the nearest printed column
header (Taxon/ACT/CONV/Body mass/Brain volume/Optic tract volume/LGN volume/V1 volume/Source),
rather than relying on the number of values printed per row (which varies, since several rows
omit one or more volumetric measures). Two extraction issues were caught and corrected:
- **Zero-width space artifacts**: the PDF embeds an invisible, zero-width space character after
  the last letter of several species names (e.g. after "telfairi" in *Echinops telfairi*), whose
  floating-point x-position occasionally sorted *before* that last letter, splitting it off with
  a spurious space. Fixed by dropping all space characters with zero rendered width before
  reassembling each column's text.
- **Superscript footnote markers**: CONV values for 8 species carry a smaller, raised digit "2"
  immediately after the main value (e.g. "41.0" + superscript "2"), per the printed footnote
  "2 Orbit convergence digitized for this study." Detected via font height (<4.5pt vs. ~5.2pt for
  the main digits) and vertical offset, and split into `CONV_digitized_for_this_study` rather
  than left concatenated into the numeric value (which would have silently produced "41.02").
- One row of page-running-header text ("108 Brain Behav Evol...Heesy/Kamilar/Willms") that fell
  inside the extraction's y-range was identified and dropped.

## Determining the source for any datapoint
`Source_codes` holds the row's numbered source code(s) exactly as printed (e.g. `"1, 3, 11"`).
These are a simple **numbered footnote list** (not a shorthand or alphabetical bibliography), so
no fuzzy matching was needed: `reference_tables/Heesy_etal_2011_Table1_references.csv` is a
direct transcription of the footnote's 32 short-form entries (`source_id` 1–32), e.g.
`11 = Frahm et al. [1984]`. These are short-form citations (author + year) as printed in the
footnote — the paper's own References section has the full bibliographic entries, not
reproduced here.

## Data role
**Both** — orbit convergence and the brain-volume measures are reported as morphometric
measurements compiled from multiple cited sources (mostly secondary, re-compiled from Stephan,
Frahm, and other published volumetric series); `CONV_digitized_for_this_study = TRUE` rows are
this paper's own primary measurement.

## Files
- `Heesy_etal_2011_Table1_snapshot.csv` — frozen transcription (84 rows), matching the printed
  table's column layout.
- `Heesy_etal_2011_Table1.csv` / public TSV — same content, published.
- `reference_tables/Heesy_etal_2011_Table1_references.csv` — the numbered source lookup.
