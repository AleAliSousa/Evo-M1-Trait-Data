# Hayssen_VanTienhoven_1993 — Asdell's Patterns of Mammalian Reproduction

Hayssen, V., van Tienhoven, A., & van Tienhoven, A. (1993). *Asdell's Patterns of Mammalian Reproduction:
A Compendium of Species-Specific Data.* Cornell University Press. (PDF used: the 2019 Cornell University Press
electronic reissue of the 1993 edition; 1,035 PDF pages; OCR text layer present.)

## Why this folder exists

Asdell's is the common root under the life-history compilations audited in
`Evo-M1-Trait-Data-restricted/other_checks/pantheria_refs_check`: PanTHERIA (Jones et al. 2009) cites it for
2,101 of 5,416 species (its second most-cited work, ref 1297), AnAge (de Magalhães et al. 2024) cites it on 1,035
species (BIBLIOID 00455), and of the 2,621 PanTHERIA cells that agree exactly with AnAge, 2,397 are on species
where both cite a common work — 969 species through this book. Unlike those compilations, **Asdell's cites per
value**: every data line in a species account ends with the number(s) of the reference(s) in its own Literature
Cited (printed pp. 705–990, ~12,000 numbered entries with letter suffixes). Transcribing it converts
compilation-level agreement into traceable provenance.

## Files

- `pdf_by_order/` — the book split into 23 PDF slices (front matter, one per order, Literature Cited,
  appendices + indexes), cut on the "Order …" heading page of each chapter. The whole-book PDF (56,083,653 bytes = 56.1 MB,
  SHA-256 `37a310449c8e6a48f317a9c6279baaa15a38eb156ab3732a905bad30bf6f594f`) is **not** stored in this repository; it stays in the
  OneDrive copy of this folder's owner. Every slice carries its own SHA-256 in the slice map.
- `Hayssen_VanTienhoven_1993_pdf_slices.csv` — slice map: file, section, TOC printed page, printed pages detected
  from page headers, PDF page range in the whole book, page count, size, SHA-256, first line of the slice.
- `Hayssen_VanTienhoven_1993_contents.csv` — the book's table of contents (order / family → printed page) with an
  estimated whole-book PDF page.

PDF page = printed page + 11 for most of the book; the offset is smaller in the first 60 pages because the scan
contains duplicate copies of several chapter-opening pages (PDF 16/17, 58/59, 64/65). Use the slice map, not a
constant offset, to locate a printed page.

## How the species accounts are organised (for the transcription)

Within each family the data are grouped under topic headings — NEONATAL MASS, LITTER SIZE, SEXUAL MATURITY,
CYCLE LENGTH, GESTATION, LACTATION, INTERLITTER INTERVAL, SEASONALITY (and others) — and each line is
`<species or continuation> <value and qualifiers> <reference number(s)>`, e.g. printed p. 51
`Choloepus didactylus 423 d; r361-622; n14; yg dies 2940`, where `r` = range, `n` = sample size, `yg` = young,
and the trailing `2940` is the Literature Cited number. Abbreviations are defined on printed p. 5
(front-matter slice). Multi-value species continue on indented lines without repeating the name.

## Transcription plan (step 1 done — see "Reference table" below; steps 2–3 not yet started)

1. `Hayssen_VanTienhoven_1993_references.R` → `reference_tables/Hayssen_VanTienhoven_1993_references.csv`:
   one row per reference number from the Literature Cited slice (numbers with letter suffixes such as `3625a`
   are separate rows), parsed from the text layer with every unparsed line kept verbatim (convention C2).
2. Per-order long table `Hayssen_VanTienhoven_1993_<Order>.csv`: species as printed, family, topic, value as
   printed, parsed numeric value/unit/range/n where the grammar allows, qualifiers verbatim, reference numbers,
   printed page, PDF slice + page. Start with the topics that map onto PanTHERIA's in-depth variables
   (neonatal mass, litter size, gestation, lactation/weaning, interlitter interval, sexual maturity) and the
   orders with Evo-M1 brain data (Primates, Chiroptera, Carnivora, Rodentia, Insectivora, Artiodactyla).
3. Register each per-order table in `__ReadMe.xlsx` as its own item (`build-dataset-item` conventions) and add
   the folder to the `pantheria_refs_check` source specs; the species-level `cited_by_pantheria_for_species`
   test then becomes a value-level test.

## Registry

Not yet in `__ReadMe.xlsx`; add a row for the paper when the first table is built.

## Reference table

Built by `Hayssen_VanTienhoven_1993_references.R` (Rscript, pdftools word boxes -> per-column lines -> sequence-constrained entry grammar) from `pdf_by_order/Hayssen_VanTienhoven_1993_21_LiteratureCited.pdf` (SHA-256 verified against the slice map; all 286 slice pages processed). Run date 2026-10-20.

### Counts (printed by the script)

- `reference_tables/Hayssen_VanTienhoven_1993_references.csv`: **12814 rows** = one per reference number; 12136 bare numbers (1..12139), 671 letter-suffixed inserts (e.g. 3625a), 7 subscript-suffixed inserts (printed 5424₁/5424₂/5405b₁, written `5424_1`/`5424_2`/`5405b_1`), 1 insert printed out of sequence and kept as printed (`1924a` between 1294 and 1295, printed p. 735; cited as 1924a in Insectivora).
- parse_status: parsed 11635, partial 1125, verbatim_only 54 (of which 15 are the book's own `not used` placeholders).
- Page check: headers parsed on 283 pages, declared on 3 (slice p. 1 title page; p. 73 printed page `777` OCR'd `Ill`; p. 279 header last `118*1` unreadable). Header-expected base numbers 12139; found 12136; **residual missing 3: 1744, 5418, 11166** — all three are absent from the printed book (page images of printed pp. 746, 832, 966 checked: 1743→1745, 5417→5419, 11165→11167). Zero entries outside their page's header range (asserted).
- OCR-damaged number tokens resolved: 18 (quoted verbatim in `number_note`): 10 by gap fill (e.g. `25%.`→2596, `115184.`→11984, `121 Albignac`→122), 7 subscript inserts, 1 damaged suffixed token(s) (`115>91a.`→11991a).
- `Hayssen_VanTienhoven_1993_references_unparsed.csv`: 0 rows (0 lines before the first entry; 0 numeric-start author-like lines folded into the preceding entry).
- `Hayssen_VanTienhoven_1993_core_journals.csv`: 169 Appendix 2 records (169 with an abbreviation); 6820 of 11635 parsed journal strings match a core abbreviation exactly.
- Coverage check (order slices 01–20, trailing right-aligned number runs + parenthesised lists in the familial prose): 48937 tokens, **10417 distinct numbers cited; 10388 have a row, 29 do not** (`Hayssen_VanTienhoven_1993_cited_numbers_not_in_bibliography.csv`; 3 of them cited ≥ 3 times). 10388 of 12814 reference rows are hit at least once. Appendix 1: 400 distinct numbers, 400 in the table, 0 not.

### Grammar

`<number><suffix>. <Authors>. <Year>. <Title>. <Journal>. <Volume>:<Pages>.` for articles; `<number>. <Authors>. <Year>. <Title>. <book, pages, editors, publisher, place>.` for books/chapters (→ `partial`); `<number>. not used` for reserved numbers (→ `verbatim_only`). Suffix = letter (inserted entry; can be printed before its base when alphabetical order requires: 781a precedes 781) or a printed subscript digit. Entry starts are accepted only when the number fits the sequence (bare: last bare + 1..40; letter: on the current base or opening a new base with `a`), so continuation lines beginning with a year (`1974. Observations …`) or a volume (`178.`) are never mistaken for entries; year-like tokens additionally need author-like text after them. A second pass fills single-number gaps with the one author-like line whose number token was OCR-damaged.

### OCR failure modes and handling

- Two-column pages: `pdf_text` interleaves the columns; the script uses `pdf_data` word boxes, finds the gutter per page (widest uncovered x-run in 200–450 pt) and reads each column separately.
- Running header: `<printed page> <first>.-<last>.`; dash dropped (`1236. 1276.`) or fused (`1598.1639b.`) handled by token extraction; three pages declared (see counts).
- Number tokens: digit→symbol (`25%.`, `50%.`), inserted characters (`587)8.`, `115184.`, `115>99.`), dropped period (`121 Albignac`), junk characters inside a suffixed number (`115>91a.`), a missing period (`11455a Ward`), subscript digits read as `,` or fused (`5424,.`, `54242.`, `5405b,.`, `3990,.` for 3900₁) — all resolved by sequence position and recorded in `number_note`. `1924a.` on printed p. 735 is NOT an OCR error: the book prints that number between 1294 and 1295 and cites it as 1924a; it is kept as printed and declared (`PRINTED_OUT_OF_SEQUENCE`).
- End-of-line hyphen rendered as `¬` (U+00AC): replaced by `-` and the next line joined without a space.
- Letter confusions inside citations (`.1 Mamm`, `Omithorhynchus`, `Fluszpferde`, `liber` for `über`, `Hire` for `Ihre`) are left verbatim in `citation`; `journal_or_publisher` is therefore as-OCR'd and the core-journal match rate above is a lower bound.
- Three printed gaps (1744, 5418, 11166) are the book's own; they are listed in the page-check file, not silenced.

### Coverage-check caveats

The 29 cited-but-absent tokens are of two kinds: (i) value tokens the trailing-number rule cannot distinguish from reference numbers (`10g`, `13d`, `5f` — a unit letter after a small number); (ii) suffixed numbers the species accounts cite but the bibliography never lists (4271b, 1127a, 11741a, 11957c). Kind (ii) is a finding about the book; it will be re-examined when the species accounts are transcribed. Columns beyond the specified set: `number_note`, `n_lines`, `column` (provenance of the number resolution and of the OCR block).


## Reference availability (`reference_tables/Hayssen_VanTienhoven_1993_references_availability.csv`)

The references table transcribes the book and never changes; whether we *have* a cited work is working
state and lives in this sidecar, one row per reference number checked, updated in place on re-check
(the same pattern as `REVIEW_QUEUE_resolutions.csv` in the refs_check pipelines and the per-paper errata
files). Columns are defined in `…_references_availability_definitions.csv`; the decision column is
`availability` (`available_endnote_pdf`, `available_evom1`, `available_online`, `in_endnote_review`,
`not_in_endnote`, `unavailable`, `not_needed`). First rows: the 57 works cited in the *Sus scrofa* and
*Mustela putorius* accounts, checked against the EndNote library — 1 present with a PDF (8220, Panepinto
et al. 1978), 56 absent; online routes not yet searched.
