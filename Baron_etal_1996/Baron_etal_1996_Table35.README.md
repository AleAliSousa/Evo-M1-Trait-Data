# Baron et al. 1996 — Table 35

## Source and scope

Baron, G., Stephan, H., & Frahm, H. D. (1996). *Comparative Neurobiology in
Chiroptera: Macromorphology, Brain Structures, Tables, and Atlases*. Birkhäuser.
ISBN **978-3-7643-5370-4**. Registry item `Baron_etal_1996_Table35`.

Table 35 prints, for 68 chiropteran species/subspecies across PDF pages
156-158 (printed pp. 418-420): accessory olfactory bulb (AOB) volume (mm³),
a size index relative to the average of the four Tenrecinae, and AOB as a
percentage of the combined olfactory-bulb complex (BOL = MOB + AOB). Per the
registry's own recommendation, **only the Volume column was built**: "Build
the volume column only. AOB is not separated in Table 32, whose BOL is the
whole olfactory bulb complex, so this is the only route to an MOB/AOB split
for bats." The Index and % columns are derived allometric quantities, not
primary measurements, consistent with how this source's other derived-index
tables (11/12, 33/34) are excluded from the built dataset elsewhere.

## Why this was transcribed from page images, not the text layer

Unlike the rest of this source (which has a clean, mostly row-aligned PDF
text layer), Table 35's extracted text is **column-scrambled**: the PDF
reader emits all 30 species names for a page as one contiguous block, then
all of that page's `n` values as a separate block, then all `Volume` values,
then all `Index` values, then all `%` values - each block internally
preserving row order, but with no reliable automatic way to distinguish a
genuinely blank cell (this table dashes out fewer values than Table 2, but
some genus-header groupings interrupt the per-page `n` sequence) from a
block boundary. Given the table is a fraction of the size of Table 2 (68
rows vs. 303, across only 3 pages), the reliable path was to render each
page and transcribe species/n/Volume directly, rather than risk silent
misalignment from a column-recombination script.

## What was excluded

- **Index and AOB/BOL % columns** - derived, not transcribed (see above).
- **Family/subfamily/order average rows** at the end of the printed table
  (`MICROCHIROPTERA (AvCS)`, `PHYLLOSTOMIDAE`, `Micronycteris`, etc., with
  their own N/Index/% columns) - these are aggregate summary statistics
  over the species rows above them, not additional per-species data, and are
  not part of this item.

## Reproducible pipeline

1. `baron_etal_1996 book Comparative Neurobiology.pdf`, PDF pages 156-158,
   is the printed source; all three pages were rendered to images and
   read directly (species, n, and Volume only).
2. `Baron_etal_1996_Table35_snapshot.csv` is the frozen transcription result.
3. `Baron_etal_1996_Table35.R` reads only the frozen snapshot and writes the
   local analysis CSV plus `ISBN%3A9783764353704_Table35.tsv` in `__Public`.

## Checks

- exactly 68 rows, from *Pteronotus gymnonotus* through *Miniopterus
  tristis*, matching the per-page species counts visually verified against
  all three rendered page images (p. 418: 30, p. 419: 29, p. 420: 9);
- a printed `Volume` of `0.000` (5 species: *Pteronotus personatus*,
  *Mormoops megalophylla*, *Choeroniscus minor*, *Rhinophylla pumilio*, and
  *Brachyphylla cavernarum*) is retained as printed - a real "no separable
  AOB" finding, not a missing value;
- merge wiring remains on hold for the same whole-source gate already
  recorded for Tables 10/32/13/16/19/22/25/28/30/2.

## Extraction / build record

Transcribed directly from the article PDF's rendered page images (pp.
418-420) by Microsoft Copilot (AI assistant) on 2026-09-25. The CSV, R
script, public TSV, README, and definitions file were all built in this
pass. No prior build existed for this item.
