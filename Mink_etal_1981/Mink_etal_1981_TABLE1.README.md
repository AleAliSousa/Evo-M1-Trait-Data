# Mink_etal_1981_TABLE1

**Item name** `Mink_etal_1981_TABLE1` · **Item number** `TABLE 1` ·
**Item encoded** `10.1152%2Fajpregu.1981.241.3.R203_TABLE1`

Mink, J. W., Blumenschine, R. J., & Adams, D. B. (1981). Ratio of central nervous system to
body metabolism in vertebrates: its constancy and functional basis. *American Journal of
Physiology* 241(3), R203–R212. <https://doi.org/10.1152/ajpregu.1981.241.3.R203>

**Item full original title:** TABLE 1. *Ratios of CNS metabolism to resting body metabolism*
(pp. R208–R209).

## Source

A 1981 scanned journal page. TABLE 1 is printed **sideways across two pages** (R208 carries
30 animal rows, R209 the remaining 12 plus the whole footnote block). The PDF's text layer is
OCR and is **not usable**: it drops the Animal column entirely and garbles digits (it reads
sheep's body metabolic rate as `0.350` where the page prints `0.370`, and `1970` for the year
of reference 11 where the page prints `1978`). Everything here was therefore read from the
page images.

## Pipeline

```
Source (scanned PDF pp. 7-8)
  -> Mink_etal_1981_TABLE1_extract_snapshot.R   writes the frozen snapshot
  -> Mink_etal_1981_TABLE1_snapshot.xlsx        FROZEN: 72 rows x 13 cols, sheet "TABLE1"
  -> Mink_etal_1981_TABLE1.R                    clean + parse + table checks
  -> Mink_etal_1981_TABLE1.csv                  42 rows x 32 cols  ("use this")
  -> __Public/comparative-data/10.1152%2Fajpregu.1981.241.3.R203_TABLE1.tsv
  -> reference_tables/Mink_etal_1981_TABLE1_definitions.csv
  -> reference_tables/Mink_etal_1981_TABLE1_references.csv   (ref_key -> citation)
```

Build order: **`Mink_etal_1981_REFERENCES.R` must be run first** — the TABLE 1 build reads
`Mink_etal_1981_REFERENCES.csv` to resolve the printed citation keys.

## Who read the values, when, and how it was checked

Transcribed by an **AI assistant (Claude) on 2026-10-31** from 500-dpi renders of PDF pages 7
and 8, read column group by column group at 2–5× zoom, with the page rotated upright. The
printed layout is written out verbatim inside `Mink_etal_1981_TABLE1_extract_snapshot.R`, which
freezes it to the `.xlsx` and **refuses to overwrite a frozen copy that differs**. The build
script reads that frozen file and contains no table values.

Three independent checks were applied to the transcription:

1. **Row-count identity.** The Animal column of page R208 carries 37 text lines; 7 of those are
   the second line of a wrapped species name, leaving 30 species, and page R209 carries 12.
   30 + 12 = **42**, which is exactly the "42 vertebrate species" the RESULTS section states.
   The class breakdown — 3 fishes, 3 amphibians, 2 reptiles (8 cold-blooded) and 6 birds,
   28 mammals (34 warm-blooded) — reproduces the paper's own "eight cold-blooded" and
   "34 warm-blooded" counts.
2. **The table's own arithmetic** (see *Table checks*), which is what caught the three
   publication slips recorded as errata.
3. **Cross-read against the OCR text layer** where it was legible, to catch a digit read twice
   the same wrong way. Where the two disagreed, the page image was re-read at 5× zoom and the
   image reading was taken; those are listed under *Ambiguous or obscured cells*.

### Structure of the snapshot

* **One snapshot row per printed row.** The printed table has **no blank or section rows**:
  every vertical gap in the Animal column is occupied by the second printed line of a
  neighbouring cell. 42 data rows, in printed order, rows 5–46 of the sheet.
* A cell printed on two lines is **one cell holding a real newline**, so the row grid still
  matches the page line for line in Excel. This affects the wrapped species names, the two
  Body₂ ranges, and the 14 rows where column E prints two metabolic-rate values.
* **Superscript footnote markers are written `^<letter>`** (`0.014^j`). Reference numbers in
  parentheses are kept as printed (`0.045 (56)`).
* **Column order and the two printed spanning headers are preserved, with blank padding.**
  Column **H carries no spanner on the page** — the "Metabolic Rate" rule stops after G and the
  "Metabolism, cm³ O₂/min" rule begins at I. That blank is reproduced, not repaired; footnote e
  makes H's unit unambiguous (H = E × A/100, so cm³ O₂/min).
* Rows 47–72 are the printed footnote block (the lead-in sentence plus footnotes a–y).

### Ambiguous or obscured cells

The publisher's **"Downloaded from ajpregu.physiology.org on July 13, 2009" watermark is
overprinted along column H on both pages.** The blue glyphs were removed by channel difference
(blue minus red) before reading, which cleared most of it. Three cells remain partly covered by
the watermark's *black* glyphs and could not be read from the pixels alone:

| row | cell | recorded | how it was resolved |
|---|---|---|---|
| 1 Goldfish | H | `0.042` | footnote e gives 0.44 × 9.52/100 = 0.0419 → 0.042; OCR text layer also reads 0.042 |
| 12 Bat | H | `1.04` | footnote e gives 3.7 × 28.0/100 = 1.036 → 1.04; OCR agrees |
| 13 Sparrow | H | `1.6` | footnote e gives 5.88 × 27/100 = 1.588 → 1.6; OCR agrees |

These three are flagged in the `note` column of the analysis CSV. **No other cell in the table
was ambiguous** after the watermark was suppressed.

One further ambiguity is a property of the publication, not the scan: the Trout row prints its
spinal cord weight as `0.312 (1)`, and footnote **l** is defined but attached to no row anywhere
in the table. See errata `Mink_etal_1981-E001`.

## Table checks

TABLE 1 states its own arithmetic in footnotes e–i, so the build script re-runs all five
relations into a `table_checks` data frame (§7a of the build HOWTO):

| relation | footnote |
|---|---|
| `H = E × A/100` | e |
| `I = F × B/100` | f |
| `J = G × C/100` | g |
| `K = I + J` | h |
| `metabolic ratio = K/H` | i |

Where column E prints two values, the **bottom** one is used, as footnote b directs.

**Tolerance rule.** Half a unit in the last *significant* printed digit of each input,
propagated through the product or the sum, plus half a unit in the last significant printed
digit of the printed result. Significant digits are read from the printed string, so `34,000`
carries a half-unit of 500 and `0.042` a half-unit of 0.0005. This is the rounding the printed
cells can explain and nothing more.

**Result of an actual R run (2026-10-31): 206 pass, 3 mismatch, 1 not evaluable, of 210 checks.**

| check | row | observed | printed | difference | tolerance |
|---|---|---|---|---|---|
| `brain_metabolism_24` | Rabbit, *Oryctolagus* sp | 0.52580 | 0.524 | +0.00179 | 0.00101 |
| `spinal_metabolism_35` | Human, *Homo sapiens* | 0.3267 | 0.37 | −0.0433 | 0.0204 |
| `cns_metabolism_36` | Dolphin, *Tursiops truncatus* | 37.27 | 37.2 | +0.07 | 0.06 |

All three are the paper's own arithmetic, not transcription: every printed cell involved was
re-read at 5× zoom from the page render and confirmed. They are recorded as errata E002–E004
and **the printed values are kept** in the snapshot, the CSV and the TSV.

The one *not evaluable* check is the Elephant spinal-metabolism relation, whose inputs (C and G)
print `NA`; footnote y says J was instead estimated from the spinal-cord-to-brain metabolic
ratio of other large mammals.

## Per-row source citations

Every value in columns A–G carries either a printed reference number or a footnote letter.
The analysis CSV keeps those keys verbatim in seven `ref_keys_*` columns (multi-citations would
be separated by `"; "`); `printed_footnote_marks` carries the superscript letters as
`<printed column>:<letter>`.

`reference_tables/Mink_etal_1981_TABLE1_references.csv` maps `ref_key` → `citation`, one row per
individual reference number this item cites, with `cited_in_column` listing every `ref_keys_*`
column — and any `printed_footnote_marks:<letter>` footnote — the key appears in. To bind:
split a `ref_keys_*` cell on `"; "` and join on `ref_key`.

**54 distinct printed reference keys are cited by TABLE 1. All 54 resolve** against the paper's
printed reference list (item `Mink_etal_1981_REFERENCES`, 92 entries); **none is unresolved and
no key has a year mismatch.** The other 38 entries of the bibliography are cited elsewhere in
the paper and are deliberately absent from this item-scoped lookup.

## Data role

**Proposed: `secondary`** (the registry cell is currently blank — see
`Mink_etal_1981_TABLE1_registry_row.xlsx` and `_checks/registry_pending.csv`).

Every value in TABLE 1 is either taken from one of the 92 cited sources or computed by the
authors from such values using the paper's own equations. Columns A, B and D are wholly cited;
column C is cited on 26 of 42 rows and footnoted on the other 16; columns F and G carry a
reference number on only 5 and 3 rows respectively, the rest being predictions from the paper's
Eqs. 1, 3 and 4; and H, I, J, K and the metabolic ratio are arithmetic on those columns.

The one primary component: footnotes **j, m, n** ("Based on direct observation of *Carassius
auratus* / *Rana catesbiana* / *Squalus acanthias*") cite no source and are therefore the
authors' own observations — a cord-to-brain weight percentage, applied to a cited brain weight,
supplying column C for the Goldfish, Bullfrog and Shark rows. That is the only reason `both`
would be arguable; it is three cells out of 42, and even they rest on a cited brain weight, so
`secondary` is the proposal. **This item is a roadmap to 92 primary sources, not a source.**

> **Do not merge the compiled columns as new measurements**, and do not merge columns F or G at
> all for the 37 and 39 rows where they are model predictions rather than determinations.

## Species names

The printed taxon is preserved verbatim in `species_as_published` (invariant 3). **No species
harmonisation has been applied and no rows have been added to any
`_keys/<Collection>/species_key.csv`** — this paper has none yet. 19 of 42 rows are genus-level
(`Bufo sp`, `Chrysemys sp`, `Sorex sp`, `Hirundo sp`, `Desmodus sp`, `Rattus sp`, `Columba sp`,
`Corvus sp`, `Cavia sp`, `Citellus sp`, `Didelphis sp`, `Oryctolagus sp`, `Pongo sp`, `Pan sp`,
`Phoca sp`, `Ovis sp`, `Camelus sp`, `Bos sp`, `Elephas sp`) and several printed names are 1981 usages or misprints that are not
current binomials (`Arctomys marmota`, `Citellus sp`, `Macaca rhesus`, `Felis domestica`,
`Rana catesbiana`, `Alligator mississipiensis`, `Gallus domesticus`, `Canis familiaris`).

A proposed mapping is in **`reference_tables/Mink_etal_1981_species_key_proposed.csv`**
(the 7-column `_keys/General/species_key.csv` schema, `source_publication = Mink_etal_1981`,
`collection = General`). All 42 accepted names and NCBI taxids were verified against NCBI
Taxonomy by `esearch`/`esummary` on 2026-10-31; 41 resolved directly, and `Citellus` has no NCBI
node at all and is proposed as *Spermophilus* on curator judgement, flagged `our_judgment` and
marked NEEDS CURATOR CONFIRMATION. **Adopt it into `_keys/General/species_key.csv` before this
item enters any species-resolving merge.**

## Human visual check of snapshot

Not yet recorded in `__ReadMe.xlsx`. The transcription and the three checks above were done by
an AI assistant; a human still needs to lay the snapshot beside pages R208–R209 and read a few
rows **across**, including some from the middle of the table, and record `DDMMYYYY_initials` in
the `Human visual check of snapshot` column.

<!-- errata:begin -->
## Errata

Generated from `reference_tables/Mink_etal_1981_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| Mink_etal_1981-E001 | spinal_cord_weight.g | TABLE 1 p. R208, row 4 'Trout, Salvelinus fontinalis', column C Spinal | 0.312 (1) |  | publication_ambiguity |  | proposed | Footnote l of TABLE 1 ('Based on direct observation of Perca flavescens. Spinal cord weight was found to be 67% of brain weight.', p. R209) is defined but carries no superscript marker on any row of the printed table; every other footnote letter j-y is attached to a cell. The Trout row is the only one whose printed cord/brain ratio matches footnote l: 0.312/0.466 = 67.0%. The cell prints '(1)', which is also a valid reference number (1 = ANTHONY, R. Anatomie comparee du cerveau, 1928). Cannot be adjudicated from the paper: '(1)' may be reference 1 or a typeset superscript l. | Value kept exactly as printed in the CSV and the snapshot; the printed key '1' is carried in ref_keys_spinal_cord_weight and resolves to reference 1. |
| Mink_etal_1981-E002 | brain_metabolism.cm3O2.min | TABLE 1 p. R208, row 24 'Rabbit, Oryctolagus sp', column I Brain | 0.524 |  | publication_error | 0.5258 | proposed | Footnote f of TABLE 1 defines I = F x B/100. The same row prints F = 5.39 and B = 9.755 (61), giving 5.39 x 9.755/100 = 0.52580. The printed 0.524 differs by 0.0018, outside the 0.0010 that rounding of the printed inputs and output can explain. The row's own downstream cells follow the PRINTED I, not the recomputed one (K = 0.524 + 0.0959 = 0.620 as printed; ratio 0.620/17.4 = 0.0356 as printed), so the slip is confined to column I. | Detected by the item's own table_checks (check brain_metabolism_24). CSV keeps the printed value. |
| Mink_etal_1981-E003 | spinal_metabolism.cm3O2.min | TABLE 1 p. R209, row 35 'Human, Homo sapiens', column J Spinal | 0.37 |  | publication_error | 0.327 | proposed | Footnote g of TABLE 1 defines J = G x C/100. The same row prints G = 1.1 and C = 29.7 (52), giving 1.1 x 29.7/100 = 0.3267. The printed 0.37 differs by 0.043, twice the 0.020 that rounding of the printed inputs and output can explain. All three printed cells were re-read at 5x zoom from the 500-dpi page render and are unambiguous. Downstream cells are insensitive to the difference (K = 42 at 2 significant digits either way). | Detected by the item's own table_checks (check spinal_metabolism_35). CSV keeps the printed value. |
| Mink_etal_1981-E004 | cns_metabolism.cm3O2.min | TABLE 1 p. R209, row 36 'Dolphin, Tursiops truncatus', column K CNS | 37.2 |  | publication_error | 37.3 | proposed | Footnote h of TABLE 1 defines K = I + J. The same row prints I = 36.94 and J = 0.33, giving 37.27, which at the three significant digits printed rounds to 37.3; 37.2 is the truncation. Difference 0.07 against a 0.06 rounding allowance. Marginal, last-digit only; the printed metabolic ratio 0.048 is unaffected (37.2/770 = 0.0483, 37.3/770 = 0.0484). | Detected by the item's own table_checks (check cns_metabolism_36). CSV keeps the printed value. |

4 recorded, 4 open (proposed), 0 confirmed, 0 withdrawn.
<!-- errata:end -->
