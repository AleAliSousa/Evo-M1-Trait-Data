# Baron et al. 1996 — Table 2

## Source and scope

Baron, G., Stephan, H., & Frahm, H. D. (1996). *Comparative Neurobiology in
Chiroptera: Macromorphology, Brain Structures, Tables, and Atlases*. Birkhäuser.
ISBN **978-3-7643-5370-4**. Registry item `Baron_etal_1996_Table2`.

Table 2 prints five linear brain measures (in mm) for 303 chiropteran
species/subspecies rows across PDF pages 4-11 (printed pp. 266-273): brain
length (BL), hemisphere length (HL), hemisphere width (HW), hemisphere height
(HH), and corpus callosum length (CCL). BL/HL/HW/HH share one sample-size
column (`n`); CCL has its own independent sample-size column (`n2`), since
corpus callosum measurements were not always taken on the same specimens.

## Reproducible pipeline

1. `baron_etal_1996 book Comparative Neurobiology.pdf`, PDF pages 4-11, is the
   printed source.
2. `Baron_etal_1996_Table2_extract.py` reads the PDF text layer for 7 of the
   8 pages and writes `Baron_etal_1996_Table2_snapshot.csv`. Its OCR-repair
   table and cell-fix list are documented in code.
3. `Baron_etal_1996_Table2.R` reads only the frozen snapshot and writes the
   local analysis CSV plus `ISBN%3A9783764353704_Table2.tsv` in `__Public`.

### Why this table needed a new parser (not just an extension of Baron_etal_1996_extract_snapshots.py)

Tables 10 and 32 are one-species-per-line with a single, uniform set of
trailing numeric columns. Table 2's extracted text is not one-row-per-line
(many species are crammed onto a single "line" by the PDF text layer), and
each row independently may be missing its leading `n`, its `HH` value, its
trailing `n2`, and/or its `CCL` value — any subset of these four optional
slots can be dashed out in the print. `Baron_etal_1996_Table2_extract.py`
handles this with a global name/number-run regex over each page's cleaned
text, followed by a small state machine that assigns tokens to
`n, BL, HL, HW, HH, n2, CCL` in strict column order, typing each token as
`INT` (no decimal point — always an `n` value) or `FLOAT` (always a
measurement) to disambiguate which slots are present.

### Known source-extraction issues and how they were resolved

- **PDF page 7 (printed p. 269) has no extractable text layer** — a pure
  scanned image in this otherwise well-OCR'd book (confirmed: the PDF page
  contains embedded images with no `jbig2dec` support in this environment,
  and `pypdf` returns an empty string for it). All 39 rows on that page were
  hand-transcribed directly from the rendered page image (`Hipposideros
  bicolor gentilis` through `Mimon crenulatum`) and are hard-coded in the
  extraction script's `PAGE269_ROWS`.
- **OCR digit/letter confusions** in numeric tokens (`l`/`I` for `1`,
  `o`/`O` for `0`, e.g. `2l.l` → `21.1`, `lO.7` → `10.7`) are repaired
  token-by-token, restricted to tokens that are otherwise pure digit/letter
  candidates for a number.
- **Three species names had an italic "m" OCR'd as digits mid-word**
  (`bilobatul11` → `bilobatum`, `trinitatul11` → `trinitatum`, `l11orio` →
  `morio`), which without repair broke the row boundary and silently
  dropped the whole row (a name with an embedded digit cannot match the
  name pattern, and the parser has no way to anchor the following numbers
  to a species). Repaired via an explicit literal-replacement table in code,
  the same style as the LINE_REPAIRS/NAME_REPAIRS dictionaries in
  `Baron_etal_1996_extract_snapshots.py`.
- **8 single-specimen (n=1) rows had both their `n`/`n2` integer tokens
  silently dropped by the text extraction** — not represented by any
  garbled remnant, so no regex could catch them. These were surfaced by a
  structural consistency check (a `CCL` value with no accompanying `n2` is
  never legitimate in this table — the print convention always dashes out
  `n2` and `CCL` together when missing) and individually confirmed against
  the rendered page images before being corrected: `Pteropus hypomelanus`
  (n2), `Cyttarops alecto`, `Choeroniscus minor`, `Sphaeronycteris
  toxophyllum`, `Kerivoula papillosa`, `Kerivoula pellucida`, `Kerivoula
  phalaena` (whose name was also truncated to "a" by the same underlying
  issue and is corrected alongside), and `Phoniscus atrox` (n and n2 for the
  latter seven). All eight fixes are listed explicitly in
  `Baron_etal_1996_Table2_extract.py`'s `CELL_FIXES`/`NAME_FIXES`.
- Beyond the above, no exhaustive re-transcription of all 303 rows against
  the page images was performed; cosmetic OCR spelling artifacts in species
  names that do not affect column alignment (e.g. stray spaces like
  "macro tis", letter swaps like "Anoltra" for *Anoura*) were left as printed,
  consistent with this repo's existing convention of preserving printed
  wording and fixing only what breaks structure or is individually confirmed.

## Checks

- exactly 303 rows, from *Eidolon helvum* through *Cheiromeles torquatus* —
  the same first/last species as the already-built Tables 10 and 32, and
  matching the registry's own row-count expectation (303) exactly;
- per-printed-page row counts were independently verified against the
  rendered page images for all 8 pages (266: 37, 267: 37, 268: 41, 269: 39,
  270: 40, 271: 37, 272: 43, 273: 29 — sums to 303);
- no row has a `CCL` value without an accompanying `n2` (the print
  convention's own internal consistency rule), after the 8 documented fixes;
- the 272-row Table 10/32 taxonomy/overlap audit does not yet cover Table 2's
  additional subspecies-level rows; merge wiring remains on hold for the
  same whole-source gate already recorded for Tables 10/32/13/16/19/22/25/28/30.
