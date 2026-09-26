# Baron et al. 1996 — Table 5

## Source and scope

Baron, G., Stephan, H., & Frahm, H. D. (1996). *Comparative Neurobiology in
Chiroptera: Macromorphology, Brain Structures, Tables, and Atlases*. Birkhäuser.
ISBN **978-3-7643-5370-4**. Registry item `Baron_etal_1996_Table5`.

Table 5 prints average body weight (BoW, g) and brain weight (BrW, mg) for
342 chiropteran species/subspecies across PDF pages 22-32 (printed pp.
284-294) — the single largest species block in the book, larger even than
Tables 10/32 (272 rows) and Table 2 (303 rows). Per the registry's own
recommendation, this was treated as the highest-priority untranscribed Baron
table, feeding `__merging_brain_mass`.

## Table structure: why only the first line per species is built

Unlike Tables 2/10/32, a species in Table 5 can span **1 to 4 printed
lines**. The table's own notes (reproduced at the end, p. 294) explain:

> "If there is more than one line for a species, the first line includes the
> pairs of body and brain weights used to establish the standards. The
> other lines include either single values..., or separate data on males,
> females and median inter sexes in cases of sex differences, or the
> combined data from the preceding lines used to establish the standards,
> and/or data from the literature which more strongly deviate and were
> therefore not included in the standards. The standards are bold-faced."

So **only the first (bold-faced/standard) line per species was
transcribed**. Sub-lines starting with `males`, `females`, `median inter
sexes`, or `presumed males/females` — and bare-numeric continuation lines
with no species name at all (additional literature-comparison values) — are
recognized and skipped. This directly follows the registry's own caution:
"Check the multi-line sex rows are not double-counted." Where a `*)` marker
appears on the species name, the footnote clarifies that the standard value
itself is already the median of the male/female values (for statistically
significant sex differences), so the first line is the correct single
figure to carry forward in every case, not an average that needs correcting.

## Column structure and the parsing rule

Each species' first line has up to 7 fields, several independently
optional: `BoW, [CV_BoW], BrW, [CV_BrW], [n_BoW, n_BrW | n], Source`. Single-
specimen (n=1) rows omit both CV columns entirely (variability can't be
computed from one specimen), and some rows collapse `n_BoW`/`n_BrW` into a
single shared value while others print them separately even when equal.
`Baron_etal_1996_Table5_extract.py` resolves this with a small type-based
state machine: CV values are always printed with exactly one decimal place
and BrW is never printed with a decimal point in this table, so "does the
next token have a decimal point" reliably distinguishes a CV column from
BrW itself at each position, and the number of remaining tokens before the
line's final `Source` token (1, 2, or 3) determines whether `n` was shared,
separate, or entirely absent.

## What was excluded

- **Sex-differentiated sub-lines** (males/females/median inter sexes) —
  supporting detail for the same standard value already captured.
- **Bare-numeric literature-comparison continuation lines** with no leading
  species name — alternate/deviating values explicitly not used to
  establish the table's own standards.
- One species, ***Mosia nigrescens*** (§), is printed with a footnote
  marker but **no weight data at all** — kept as a row with blank
  measurement fields (not dropped), since the source's own species count
  (342) includes it.

## Data role and the Source column

`Source` = `S` (Heinz Stephan's own collection, in cooperation with named
collectors world-wide) for **309 of 342 rows**; the remaining **32 rows**
carry a numbered literature-citation code (sometimes comma-joined with `S`,
e.g. `10,12,S`), keyed to the table's own numbered reference list:

> 1: M. Weber (1896); 2: Dubois (1897); 3: Ziehen (1899); 4: Draseke (1903d);
> 5: Welcker und Brandt (1903); 6: Warncke (1908); 7: Kolmer (1910);
> 8: Waterlot (1912); 9: Mangold-Wirz (1966); 10: collection Paul Pirlot in
> Pirlot and Stephan (1970); 11: collection P. Pirlot in Stephan and Pirlot
> (1970a, b); 12: collection P. Pirlot in Pirlot and Pottier (1977);
> 13: RTF Bernard et al. (1988).

Per the registry's own recommendation, this `Source` column is preserved
exactly so downstream merges can separate the primary Stephan-collection
rows from the secondary literature-compiled rows at the row level, rather
than treating the whole item as uniformly primary.

## Reproducible pipeline

1. `baron_etal_1996 book Comparative Neurobiology.pdf`, PDF pages 22-32, is
   the printed source.
2. `Baron_etal_1996_Table5_extract.py` reads the PDF text layer and writes
   `Baron_etal_1996_Table5_snapshot.csv`. Its OCR-repair step and full
   line-classification logic are documented in code.
3. `Baron_etal_1996_Table5.R` reads only the frozen snapshot and writes the
   local analysis CSV plus `ISBN%3A9783764353704_Table5.tsv` in `__Public`.

## Snapshot vs. analysis CSV: section headers and indentation preserved for readability

Following a request to make the frozen snapshot read more like the printed
page, `Baron_etal_1996_Table5_snapshot.csv`:

- keeps the source's own printed family/subfamily ALL-CAPS section headings
  (`PTEROPODIDAE`, `PTEROPODINAE (cont.)`, `MORMOOPIDAE`, etc. — 50 heading
  rows) as their own rows, flagged `is_header = TRUE` with all measurement
  fields blank, interleaved in their original printed position;
- indents `species_printed` to mirror the printed page's own three-level
  visual hierarchy — family headings flush left, subfamily headings with a
  2-space indent, species rows with a 4-space indent — the same nesting the
  book itself uses (bold family names, plain subfamily names, inset italic
  species);
- leads with `species_printed` rather than a row-number column, so the
  indentation/hierarchy is the first thing visible when skimming the file;
  `species_row` is still included (last column) for reference.

This makes the snapshot skimmable by eye and shows the taxonomic groupings
exactly as printed, rather than requiring a separate species-to-family
lookup. The analysis CSV/TSV and public TSV remain species-data-only and
unindented — `Baron_etal_1996_Table5.R` drops the header rows, trims the
hierarchy-indent whitespace from `species_printed`, renumbers `species_row`
1-342 over species rows alone, and restores the original column order
(`species_row, source_pdf_page, species_printed, ...`), so downstream
consumers see the same shape as before.

## OCR corrections: image-verified fixes vs. artifacts left as printed

As with Table 2, this scanned 1996 source has scattered letterform OCR
errors in species names. Two categories were handled differently:

- **18 corrections were applied**, each individually confirmed against a
  rendered page image — either Table 5's own page, or (for species shared
  with Table 2) that item's already image-verified spelling from the
  sibling build: `Pteropus alec to`→`alecto`, `Pteropus maerotis`→`macrotis`,
  `Pteropus neohibernieus`→`neohibernicus`, `Pteropus polioeephalus`→
  `poliocephalus`, `Pteropus seapulatus`→`scapulatus`, `Pteropus
  temmineki`→`temmincki`, `Mieropteropus`→`Micropteropus`,
  `Seotonyeteris`→`Scotonycteris`, `Casinyeteris`→`Casinycteris`, `Chi ron
  ax`→`Chironax`, `Nycteris macro tis`→`macrotis`, `Megaderma spasm
  a`→`spasma`, `Sturn ira ludovici`/`tildae`→`Sturnira`, `Tadarida leu co
  stigma`→`leucostigma`, `Ametrida centuria`→`centurio`, `Miniopterus
  infiatus`→`inflatus`, and `D. moluee.`→`D. molucc.` (×2, Dobsonia
  moluccensis abbreviated). These are listed explicitly in
  `Baron_etal_1996_Table5_extract.py`'s `NAME_FIXES`.
- **Other cosmetic letterform/spacing artifacts were left as printed**
  (not individually image-checked), consistent with this repo's existing
  convention and Table 2's own README.
- One numeric-context fix was applied: a source-key token OCR'd as `1O,S`
  (letter O for zero) was corrected to `10,S` to match the citation-key
  format used identically elsewhere on the same page.

### A page-wide "S" ↔ "5" OCR confusion (PDF p. 23, printed p. 285)

One page has a systematic OCR confusion between the letter `S` (Stephan
collection) and the digit `5` (citation-key index for Welcker und Brandt,
1903) — confirmed beyond doubt by the page's own column header being
misread as `50urce` instead of `Source`. Every row on this page whose
`Source` was extracted as a bare `5` or a comma-joined value ending in `,5`
(21 rows: the *Pteropus lylei* through *Casinycteris argynnis* block) was
re-verified against a high-resolution render of the printed page — every
single one is printed as `S`, including *Pteropus vampyrus*, which reads
`1,S`, not `1,5`. This fix (`fix_source_s_for_5` in the extraction script)
is scoped to this one page only: two rows elsewhere in the table
(*Barbastella barbastellus* → `4,5`, *Plecotus auritus* → `3,5`, both on
printed p. 293) were separately confirmed by image to be genuine
citation-index `5` values, since that page's header shows no such
corruption — they were left unchanged.

### Cross-check against a user-supplied Excel export of the full PDF

The user separately exported the entire source PDF to Excel (one sheet per
page, via a different conversion pipeline than this build's `pdftotext`-based
extraction) and asked that it be checked against this item. That export's
per-page layout is considerably less structured for this table (species,
sex-difference sub-lines, and even unrelated adjacent cells are frequently
merged into single Excel cells), so it was not usable as a row-by-row
replacement source — but a bulk species-name comparison between it and this
build's 342-row list surfaced the OCR discrepancies above, all of which were
then independently confirmed against the rendered page images (not simply
taken on the Excel export's authority) before being applied.

### A note on encoding

The section-sign footnote marker (§) is stored as proper UTF-8 in every
file here. If it ever displays as mojibake (e.g. "Â§" or similar) when
opened directly in Excel, that is Excel defaulting to a non-UTF-8 codepage
on open rather than a defect in the file; both the snapshot and the analysis
CSV/TSV in this build are written with a UTF-8 byte-order mark specifically
so Excel detects and opens them as UTF-8 automatically.

## Checks

- exactly 342 rows, from *Eidolon helvum* through *Cheiromeles torquatus*,
  matching the table's own stated "342 species and/or subspecies" exactly;
- per-page row counts were verified programmatically against the extraction
  script's own assertions (first/last species, total count);
- no row was found with an unresolvable/ambiguous trailing-token pattern
  (the parser's issue-detection raised zero unhandled cases across all 11
  data pages);
- merge wiring remains on hold for the same whole-source gate already
  recorded for Tables 10/32/13/16/19/22/25/28/30/2/35.

## Extraction / build record

Transcribed from the article PDF's text layer (with the OCR-repair steps
documented above) by Microsoft Copilot (AI assistant) on 2026-09-25. The
CSV, R script, public TSV, README, and definitions file were all built in
this pass. No prior build existed for this item.
