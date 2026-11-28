# Table and matrix snapshot layout audit

Started 2026-11-27. Scope: files named `*_snapshot.{csv,tsv,xlsx,xls,docx,doc}`
whose names do not identify figures or prose. The initial inventory contains
1,039 files in 495 paper folders (696 CSV, 267 XLSX, 61 TSV, 7 DOCX, 6 XLS,
2 DOC). This is a name-based inventory, not 1,039 source-verified items; some
files may need recategorization. Existing user changes throughout the repository
were left untouched.

The current 1,023-file path list and review status is in
`table_snapshot_layout_inventory.csv`; the count fell by one when the duplicate
normalized de Sousa 2013 CSV snapshot was removed, and by one more when two
Stephan 1987 flat CSV snapshots were replaced by one XLSX snapshot for Table 2
(Table 1 already had an XLSX). It fell by one more when the split Herculano-Houzel
2013 Table 1-b snapshot was replaced by one complete Table 1 source-layout
snapshot shared by its two R readers. It fell by twelve when joined Dickscheid
2021 area snapshots were retired in favor of direct reads from the frozen
publisher files. `pending_source_comparison`
means unreviewed, not conforming.

## Corrected and checked against sources

| Item | Source comparison | Change | Rebuild check |
| --- | --- | --- | --- |
| `Jacobs_etal_2015_Table4` | PDF p. 2868, printed species columns and parameter rows | Reoriented CSV snapshot; moved transpose and ± split to R; added source footnotes | Analysis CSV unchanged cell for cell |
| `Jung_etal_2022_TableS1` | `sciadv.abn0954_sm.pdf`, Table S1 | Reoriented XLSX; put citations below measurements; moved scientific-name annotations to item lookup; transposed in R | Analysis CSV and public TSV unchanged |
| `deSousa_etal_2013_Table1` | `desousa_etal_2013.pdf`, Table 1, PDF p. 5 | Replaced normalized XLSX with eight-column printed table; removed duplicate normalized CSV snapshot; kept legacy higher-precision values in a separately documented item lookup, checked against printed rounding in R | Analysis CSV unchanged cell for cell |
| `Frahm_etal_1997_Table1` | `Frahm1997.pdf`, printed Tables 1 and 2 on PDF p. 3 | Rebuilt the XLSX with separate source-layout sheets, including all specimen, mean, and SD rows; reader now joins printed group means by label | Analysis CSV, public TSV, and canonical volume merge rebuilt. Prior reader shifted most structure values by column position. Restricted DeCasien comparison not run because its repository was unavailable locally. |
| `Frahm_etal_1984_Table1` | `frahm_etal_1984.pdf`, Table 1 on PDF p. 3 | Restored printed source order, group rows, header tiers, footnotes, and ASW before ASG; R reader does reordering and name joins | 44-row analysis CSV unchanged cell for cell |
| `Frahm_etal_1998_Table1` | `frahm_etal_1998.pdf`, Table 1 on PDF p. 2 | Restored six printed columns, five species blocks, sample-size labels, units and notes; R reader handles names and analysis order | 27-row analysis CSV unchanged cell for cell |
| `Baron_etal_1990_Table1` | `baron_etal_1990.pdf`, Table 1 on PDF p. 4 | Restored two parallel panels, group headings, printed species labels, volume, percentage, and index columns; R reader gathers panels | 78-row analysis CSV unchanged cell for cell |
| `Stephan_etal_1987_Table1` and `Table2` | `stephan_etal_1987_VII_scan.PDF`, Tables 1 and 2 on PDF pp. 3–4 | Replaced merged, sorted XLSX and two flat CSV snapshots with separate printed-layout XLSX files; restored five volume and five index columns and group heading rows | 89-row Table 1 and 45-row Table 2 analysis CSVs unchanged cell for cell |
| `Stephan_etal_1984_Table1` | `Stephan_etal_1984.pdf`, Table 1 on PDF pp. 2–3 | Restored the two-page, eleven-column printed matrix, all 89 species rows, group headings, and footnote markers; OCR-assisted context transcription remains for human review | All 53 used CGL values and sample sizes checked; 53-row analysis CSV unchanged cell for cell |
| `Lyamin_etal_2008_Table2` | Snapshot and R already preserved printed orientation from 2026-09-17 | Corrected stale README claiming the snapshot was transposed | No data rebuild needed |
| `Frahm_etal_1984_Table2` | `frahm_etal_1984.pdf`, Table 2 on PDF p. 4 | Restored tiered headers, source taxonomic sections, 44 species, nine mean rows with their n columns, and footnote; reader selects rows by item lookup | 44-row analysis CSV rebuilt; one corrected value, *Tupaia glis* ASG:CGL 13.1 → 18.1, from the printed table |
| `Baron_etal_1987_Table1` | `baron_etal_1987_VI_scan.pdf`, Tables 1–2 on PDF pp. 2–3 | Split merged snapshot into two printed-layout sheets and placed volume and index blocks in printed positions; index values remain untranscribed | 89-row analysis CSV unchanged cell for cell |
| `Baron_etal_1988_Table1` | `baron_etal_1988_scan.pdf`, Tables 1–2 on PDF pp. 4–5 | Split sorted snapshot into two source-order sheets, restored VM before VI, group breaks, index block positions, and locomotory codes; index values remain untranscribed | 76-row analysis CSV unchanged cell for cell |
| `deSousa_etal_2010_Table1` | `deSousa_etal_2010.pdf`, Table 1 on PDF p. 3 | Existing nine-column source layout confirmed; repaired two dangling XLSX drawing relationships without changing cell contents | Both sheets identical cell for cell with pre-repair workbook; R reader ran without output differences |
| `Baron_etal_1983_Table1` | `baron_etal_1983.pdf`, Table 1 on PDF pp. 3–5 | Existing eight-column layout, species/group order, means, and notes confirmed | No data rebuild needed |
| `Frahm_etal_1982_Table2` | `frahm_stephan_1982.pdf`, Table 2 on PDF p. 6 | Existing species row and seven-column order, group breaks, numbered header, and note confirmed | No data rebuild needed |
| `Barger_etal_2012_Table3` | `Barger-2012-Neuronal populations.pdf`, Table 3 on PDF p. 9 | Restored caption, printed species headers and ninth post hoc comparison column; R selects the seven species columns and maps nucleus labels | Seven-row analysis CSV unchanged cell for cell |
| `Barks_etal_2014_TABLE1` and `TABLE2` | `Barks-2014-Brain organization o.pdf`, adjacent Tables 1–2 on PDF p. 2 | Table 1 caption and four-character printed subject codes restored; empty fifth column removed from Table 2 | 36-row and 26-row analysis CSVs unchanged |
| `Bauernfeind_etal_2013_Table2` and `Table3` | `bauernfeind_etal_2013.pdf`, Tables 2–3 on PDF pp. 9–10 | Restored printed captions and right-insula / left-right heading tiers; R skips these source rows | 15-row and 60-row analysis CSVs unchanged cell for cell |
| `HerculanoHouzel_etal_2013_Table1-a` and `Table1-b` | `Herculano-Houzel-2013-Distribution of neur.pdf`, single printed Table 1 on PDF p. 3 | Combined the 18 area rows, Total row and seven group-summary rows into one ten-column source-layout snapshot; removed split Table1-b snapshot; both R readers select their own rows | 18-area and seven-group analysis CSVs unchanged cell for cell |
| `Gabi_etal_2016_TableS1` | `pnas.201610178si.pdf`, Table S1 on PDF p. 2 | Restored single printed header row and species spacing; updated extraction script and R reader | Eight-row analysis CSV unchanged cell for cell |

## Most recent 18-item batch: conforming snapshots

The following ten snapshots already preserve their printed spatial layout and
were left unchanged after comparison with source pages: `Barger_etal_2012_Table1`
(PDF p. 4), `Barger_etal_2014_Table1` (p. 3), `Bauernfeind_etal_2013_Table1`
(p. 4), `Changizi_Shimojo_2005_Table1`–`Table5` (PDF pp. 2–5), and
`Frahm_Zilles_1994_Table1`–`Table2` (PDF pp. 6–7). The Frahm Table 1 workbook
contains separate source-layout sheets for both printed tables because its R
reader joins them; Table 2 also has its own single-table snapshot. Details are
in the inventory. This batch reviewed 18 item snapshots in total, corrected
eight item layouts and removed one redundant split file. The inventory now has
1,002 files still pending source comparison.

These are assistant checks; `Human visual check of snapshot` signoff was not set.

## Confirmed departures needing source reconstruction

The six curated-layout XLSX departures in this priority batch have been rebuilt.
The OCR-assisted context cells in Stephan 1984 need human visual review; its
analysis CGL cells and row selection were checked programmatically and against
the rendered source pages.

Baron 1987 and 1988 now conform in spatial layout, but their printed index
values remain an explicit transcription backlog. The reconstructed volume cells
were carried from the former snapshots; source-by-source value verification is
separate from this layout audit.

## Audit method for the remainder

For each table/matrix item, place the snapshot beside the source at its stated
locus. Check orientation, number and order of rows/columns, multi-tier headers,
group breaks, meaningful blanks, footnote keys, units, and captions. A snapshot
and analysis CSV having identical cells is a triage signal, not proof of an
error: several printed tables are already rectangular. Born-digital supplements
may legitimately be byte-identical frozen copies. Fix only when the source
layout is established, then update the R reader and item README, run it, and
compare analysis output before accepting any downstream change.

The initial README search found explicit transposition admissions only for
Jung S1 (corrected) and Lyamin Table 2 (already corrected but README stale).
Seventeen CSV snapshots have cell content identical to their analysis CSVs;
these require source comparison, not automatic rewriting. Most of the 1,036
current files remain to be individually source-checked. Do not mark this audit complete
from the name or metadata scan alone.

## Next 100-item batch (2026-11-27)

Audited 100 further table/matrix snapshots and marked them `source_layout_existing`
in `table_snapshot_layout_inventory.csv`:

- **56 EBRAINS receptor fingerprint TSVs** in `PalomeroGallagher_etal_2018`:
  each snapshot's SHA-256 and byte count match its source-download manifest;
  all retain four columns and their original receptor row order (824 data rows
  total). The series README records an earlier independent download comparison.
- **21 XLSX table items**: every worksheet, cell position, and cell value matches
  the local source workbook, as do sheet names and merged ranges. These are Baker 2025 SupplementaryData1; Baldoni
  2025 TableS1; Chen–Wiens 2020 SupplementaryData3; Clipperton-Allen 2019
  Tables S1–S2; Dupont 2026 Tables S2–S3; Franco 2000 Table1; Garcia–Ravignani
  2020 sp1; Herberstein 2022 Observations; Hrvoj-Mihic 2026 SD1–SD2;
  Kamilar–Cooper 2013 S2; ManyPrimates 2022 speciespredictors; Martin 2017
  MammalianVocalisationData; Nunn–Samson 2018 SupplementaryTable1; Pagel
  2026 SupplementaryData2; Palomero-Gallagher–Zilles 2018 TableS3; Sherwood
  2020 SupplementaryTables 1–2; and Sjölin 2022 SupplementaryData. Franco's
  transcription was also compared to the printed PDF Table 1: species group
  breaks and paired-eye blank cells retain their printed positions.
- **23 Karbowski 2007 Tables S1–S23**: compared their 23 worksheet layouts
  with the printed supplement PDF. All 398 species/group row labels occur in
  source order (S23's two section labels differ only by a trailing colon), and
  the first measurement in each of 393 populated rows matches the printed
  value. Captions, three/four-column headers, summary rows, and subdivision
  breaks retain their printed layout. All 23 item workbooks have identical
  worksheet cells to the aggregate 23-sheet snapshot. Their XLSX packages
  differ in custom document properties, so the Karbowski README's former
  “byte-identical” description was corrected to “cell-identical.”

No data-layout correction or R rebuild was needed in this batch. The inventory
now has **902** snapshots pending source comparison. This remains an assistant
source check, not human visual signoff; the EBRAINS live URLs were not
re-downloaded during this pass. Figure and text snapshots were excluded.

## Next 501 table/matrix snapshots (2026-11-27)

The inventory moved from 902 to **401 pending source comparisons** during this batch: 501 newly assessed. The current project-wide inventory is 463 `source_layout_existing`, 69 corrected/repaired statuses, 103 `confirmed_layout_departure_pending_reconstruction`, and 401 pending, totaling 1,036 table/matrix snapshot files. These are assistant source checks, not human visual signoff. Figures and text snapshots were excluded. `table_snapshot_layout_batch500_triage.csv` is an automated 500-candidate triage sheet with updated statuses, **not** the list of 501 completed audits; use the inventory as the authoritative ledger.

Corrections in this batch restored source geometry while moving analysis transformations into R:

- Andelin Table 4, Bianchi Tables 1–2, Awbrey Table 1, and all 16 Stephan 1981 group-column XLSX snapshots;
- Hohmann 1991 Tables 3–11, including stacked statistic rows and separate species panels; Glendenning–Masterton 1998 Table 4 with vertically stacked A/B panels; MacLean 2014 Tables S1–S7 with direct DOCX cell grids;
- Erbaba 2025 Table 1, Bush–Allman 2004b Table 2, Bjugn–Gundersen 1993 Table 2, Hakeem 2005 Table 2, Smaers 2011 Supplementary Tables 1–2, Tan–Li 1999 Table 1, Hopkins 2011 Table 2, Gautier 1988 Table 12.3, and Zhu 2023 Supplementary Data 1 and 3.

Each corrected R script was run. The derived CSV/TSV data stayed the same where the change was only spatial. Source-row identifiers were updated where they are meant to identify physical snapshot rows. The Hakeem six data rows were already present; its correction restored the printed caption, heading and numeric display punctuation. The two Zhu snapshots now retain the source worksheet title rows and their R readers skip them. The Smaers snapshot extractors now emit the two printed header tiers.

Sources used for the conforming checks include exact bytes or exact worksheet/DOCX cell grids for publisher supplements, plus local PDF table text and rendered pages for printed tables. Numeric row matching in the triage sheet was used only to locate source candidates, not as proof of layout conformity. The audit notes for each item are in `table_snapshot_layout_inventory.csv`.

**Unresolved confirmed departures:** 103 project-wide are listed with a specific note in the inventory. Larger reconstruction cohorts include Armstrong 1979, Baron 1996, Dickscheid 2021, Stephan 1970, Barbeito Andrés 2019, Nudo 1995, Smaers 2017, Zilles 2011, and several individual printed tables with flattened grouped headers. These are confirmed nonconformities, not completed corrections. Rebuild their source grids, update each R reader and item README, and compare regenerated analysis outputs. Do not classify any as conforming merely because their values match the source. Another 401 still need source comparison.

## Continued source-layout edits (2026-11-27)

Corrected 28 further confirmed departures after the 501-item audit: Baldwin 2017 Tables 2–4; Garey 2006 Tables 4 and 6; Matano 1992 Tables 1–4; Laska 2003 Table 1; de Rooij 2016 Tables 2–3; Giannaris–Rosene 2012 Tables 4–5; Pontzer 2014 Table S1; Gatome 2010 Tables 1–4; Barger 2012 Table 4.1; Castillo-Morales 2016 Table 1; Chivers 1984 Table 24.1; Elston 2005 Table 3; Hardus 2008/2009 Table 4.2; Schenker 2010 Tables 2–3; Morrogh-Bernard 2008 Table 8.3; and Lewitus 2012 Table 4. The individual item READMEs describe each change and give its rebuild command. These edits restore printed captions, section rows, grouped header tiers, notes, and in Baldwin Table 4 the threshold/sample-size rows in their printed orientation. Extraction scripts for de Rooij Table 2 and Pontzer Table S1 were also updated and regenerated to cell-identical corrected snapshots.

All 28 item readers were run. Analysis data were identical to the previous versions, apart from physical `source_row` identifiers where source rows were added. The Laska shared reader now supports skipping source context rows. Gatome Table 1's apparent count mismatch and de Rooij Table 3's large WMH values are printed in the PDFs and were preserved. Castillo-Morales Table 1 has a printed “non-neocortex” heading over the first volume column although its Nr values are consistent with that column being total brain volume; the header and numbers were preserved and the ambiguity documented. No clear transcription error meeting the user's correction criteria was found in this group.

The current inventory totals 1,036 table/matrix snapshots: 463 `source_layout_existing`, 97 corrected/repaired, 75 `confirmed_layout_departure_pending_reconstruction`, and 401 `pending_source_comparison`. The automated triage sheet's statuses were refreshed; its numeric match statistics are candidate-location aids, not human visual signoff. The independent human source comparison remains separate and is not claimed by these edits. Continue with the 75 confirmed departures, especially individual printed tables with flattened headers, then audit the 401 pending snapshots.

## Further layout corrections and source checks (2026-11-27)

Corrected 29 more confirmed departures: Campos–Welker 1976 Table 1; Latimer 1956 Table 2; Peruffo 2019
Table 2; Seelke 2016 Table 2; Heffner 2004 Table 1; Morrogh-Bernard 2008
Table 8.6; O'Kusky–Colonnier 1982 Table 3; Kastelein 2010 Table I;
Plavcan–van Schaik 1997 Table 1; Posada–Colell 2007 Table I; Heffner and
Heffner 1992 and 2010 Table 1; Herculano-Houzel 2015 and 2016 tables;
Shoshani 2006 Table 1; Elston 2006 Table 1; Falcone 2019 Table 2; and all
three Smaers 2017 Table S1 snapshots (two active XLSX, one archived CSV);
Zilles 2011 Supplementary Tables S1–S3; and all six Barbeito Andrés 2019
CSV/TSV snapshots across the volume, cell-number, and cell-density items.
Each item README records the source-layout change and rebuild command.
Readers were run and the analysis tables compared to prior output. Numeric
analysis values were unchanged. Physical source-row identifiers moved where
caption/header rows were restored. Posada's printed `Self-direct` label
replaced an erroneous `Self-directed` transcription. Falcone's PDF prints
`Cercocebus kandti`; that label was restored in the snapshot, while R
explicitly retains the prior `Cercopithecus kandti` analysis label pending
any separate taxonomic review. The Heffner 1992/2004 filename case was
corrected in the inventory and triage sheet.
All three Smaers snapshots now reproduce the complete publisher Table S1
grid (source rows 9–42, columns A–AI): 222 nonempty cells match at identical
relative coordinates. Their R readers select the appropriate source block;
the two active and one archived analysis CSVs match prior outputs.
The Zilles XLS snapshots now preserve source cell coordinates, internal blank
rows, and header line breaks; source text matches at the same coordinates,
with only negligible floating-point serialization differences. Their three
readers rebuilt 1,363, 119, and 152 specimen rows identically.
The Barbeito snapshots now preserve all 69 × 16 source worksheet cells,
including 23 formulas. Every source cell matches in all six snapshots. The
four analysis readers (three items and combined tidy) rebuild the same rows
and substantive numeric values; maximum floating-point serialization change
is 1.14e-13.

Seven snapshots were classified as source-conforming after
recheck: Mota–Herculano-Houzel 2015 Table S1 and Rilling–Insel 1999 Table 1
matched their publisher worksheet cell grids; Nudo 1995 Tables 1–5 retain
the printed columns, grouped headers, row order and captions. Wrapping text
inside one header cell is not a spatial-layout departure.

Inventory now totals 1,036 table/matrix snapshots: **470** source-layout
existing, **126** corrected/repaired, **41** confirmed departures requiring
reconstruction, and **399** pending source comparison. This is assistant
source/layout checking; independent human source comparison remains separate.
Continue with the 41 confirmed departures and 399 pending snapshots. The
triage sheet is a candidate locator, not proof of layout conformity.

## Stephan 1970 continuation (2026-11-27)

Restored the printed orientation of all six Stephan, Bauchot & Andy (1970)
table snapshots and both aggregate snapshots. The six scanned pages show
captions, numbered measurement columns and species rows, with A/B insectivore
sections in Tables 1 and 4. The aggregate snapshots now concatenate three
separate printed tables each; `_read_printed_table.R` derives the analysis
`group` and numeric columns. All six per-table readers and the aggregate reader
ran, and their analysis CSV cells matched the pre-layout outputs. The source
footnotes are condensed in the snapshots and described in the item README.
This is assistant layout checking, not independent human signoff.

Inventory after this batch: 1,036 snapshots, with 470 source-layout existing,
134 corrected/repaired, 33 confirmed departures still requiring reconstruction,
and 399 pending source comparison.

## Next source-layout checks (2026-11-27)

Powell 2017 Dataset 1 had omitted the publisher worksheet's title row. Its
snapshot is now a complete copy of the local supplementary workbook, and R
skips that row. The rebuilt 289-row analysis CSV is cell-identical to its
previous output. Barger 2007 Table 1 now puts each printed species group on
the first specimen row, restores the caption and two-tier measurement header,
and moves group propagation to R. Its 12-row analysis CSV is also unchanged.

Three workbook snapshots were confirmed source-shaped by full coordinate
comparison: Granatosky 2018 Table S1 (9,451 nonempty cells), Seymour 2015
Table S1 (780), and Seymour 2019 supplementary data (1,511). The latter
materializes 188 publisher formulas as cached numbers; all occupied cell
positions remain the same. Differences in numeric serialization are below
1e-12. The figure-derived Demirci 2023 `Fig.1` workbook was removed from
this table/matrix inventory because figures are outside this audit's scope.

Current inventory: **1,035** table/matrix snapshots — 473 source-layout
existing, 136 corrected/repaired, 33 confirmed departures, 393 pending
source comparison. The 500-candidate triage sheet now has 499 rows after
excluding the figure and is not a completion ledger. Independent human source
comparison is separate.

## Next 500 request: source-layout continuation (2026-11-27)

There were only **426 unresolved** table/matrix snapshots at the start of this
request, so 500 further in-scope checks were not available. This pass resolved
**38** of those 426: **20 corrected** and **18 found source-conforming**.
The inventory and 499-row candidate triage sheet were synchronized. The triage
sheet remains a locator rather than evidence of completed comparison.

The corrected snapshots are Baron 1996 Tables 36, 39, 42 and 45; Burish 2010
Table 1; Walker 2006 Table 8; Seelke 2014 Table 5; Chugani 1987 Table 1;
Jacobs 2008 Table 1; Lewitus 2012 Table 1; Heffner 1998 Table 1; Catania
1999 Table 1; Collins 2013 Table 1; Heffner 2008, 2013, 2015 and 2016
tables; West–Schwerdtfeger 1985 Tables I and II; and Meyer 1981 Table II. Captions, nested
headers, continuation headers, notes, and original
parallel panels were restored where the PDF showed them. The Heffner 2008
printed row order and three columns, Heffner 2013 four columns, and Heffner
2015 four columns now reside in their snapshots; their derived fields,
sorting, and joins occur in R. The related R readers were run. Apart from the
Table 36 correction described below and Jacobs' physical `Source_row` shift
after restoring the caption, rebuilt analysis CSV values and rows matched the
pre-layout outputs.

Baron Table 36 also had a shifted interpretation of four printed measurement
headings. The snapshot, R reader, definitions, public TSV, variable catalogs,
and source manifests now use the printed BOL, TOT−BOL, ALLO−BOL, and PAL+SCH
positions. The obvious OCR split `Natalus mexican us 2;8` was corrected from
the rendered PDF to species `Natalus mexicanus` and CING `2.8`. This is a
substantive data correction, not merely a presentation change.

The 18 source-conforming checks were Bouilleret 2000 Table 2; Karbowski 2007
Tables S1–S23 aggregate workbook (all 23 sheets matched their source-grid
counterparts); Noda 2002 Tables 2 and 3; Buchsbaum 1989 Table I; Korbo 1999
Table 1; Sherwood 2006 Table 2; Nakanishi 1997 Table II; Gilboe–Betz 1973
Tables 1–3; Elia 1992 Tables 1 and 3; Sahlin 1987 Tables IV–VII; and Meyer
1981 Table I. Meyer 1981 Table II had joined columns from two facing source
pages; its snapshot now keeps the two page blocks, and R joins them.

Current inventory: **1,035** table/matrix snapshots — **491** source-layout
existing, **156** corrected/repaired, **29** confirmed departures requiring
reconstruction, and **359** pending source comparison. Thus **388** remain
unresolved. These are assistant source/layout checks; independent human source
comparison and signoff remain separate. Continue with the 29 confirmed
departures and 359 pending comparisons. Do not classify candidate row matches
alone as spatial-layout proof.

## Next 388 request: partial continuation (2026-11-27)

The request began with 388 unresolved inventory entries (29 confirmed layout
 departures and 359 pending comparisons). This pass resolved **43** of them:
**16 corrected source layouts**, **20 source-conforming layouts**, and **7
source-conforming workbooks repaired**.
The inventory now has 1,035 unique existing paths: 511 `source_layout_existing`,
161 `corrected_source_checked`, 8 `corrected_source_layout`, 2
`corrected_source_layout_context_omitted`, 8 `source_layout_existing_repaired`,
24 `confirmed_layout_departure_pending_reconstruction`, and 321
`pending_source_comparison`. Thus **345 of the requested 388 remain unresolved**.
The inventory is the authoritative status ledger; the older batch500 triage CSV
contains only its original candidate subset and is not a complete audit list.

Corrected layouts this pass: Baron 1996 Tables 28, 30, 48, 51; Terhune and
Ronald 1972 and 1975 Table 1; Thomas 1988 Table I; Flydal 2001 Table 2;
Hopkins 2003 Table 1; Kaufman 2004 Table A15; Reep and O'Shea 1990 Tables
1, 3, 4; Zilles and Rehkämper 1988 Table 12-1; Jacobs 1997 Tables 1 and 2.
Each relevant R reader was run. The analysis CSVs were cell-identical to their
pre-layout versions except Jacobs Table 1's two `Age_years` values: M69.1 and
M69.2 are both 69 years old per the printed footnote, rather than 69.1 and
69.2 years. The corresponding public TSV was regenerated. Kaufman A15's 284
source rows were matched uniquely against the PDF text layer; the printed
source order differs from the prior sorted analysis order, which now occurs in
R. Reep Table 4's inconsistent printed Mean of 4.23 mm was retained as printed
and is already documented in its README.

Source-conforming checks: Sokoloff 1977 Tables 3–4; Poulsen 1997 Tables 1–2;
Slomianka 2013 Tables 2 and 4; Elia 1997 Table 8; Holliday 1971 Table I;
Holliday et al. 1967 Tables II–III; Iwaniuk et al. 2001 Tables 1–4;
Sønderby et al. 2021 Supplementary Tables 5–8; Zilles and Rehkämper 1988
Tables 12-2 and 12-3. These retained the printed/source workbook grids. The
four Sønderby snapshots' worksheet, shared-string, style, and workbook parts
matched the archived publisher workbook exactly; package metadata alone
varied. Captions absent from some Iwaniuk worksheets were recorded in the
inventory, while their tabular spatial layout stayed source-shaped.

The Kerney 2017 Online Resources 1–2, Opie 2013 Data S1, and Weisbecker 2013
Table S1 snapshots had the same cell grids as local source workbooks but
package metadata drifted. They were copied from the local originals, and
SHA-256 now matches the recorded source hashes. Three Wegiel 2014 table
workbooks had incorrect `A1` OOXML dimensions and dangling drawing links;
only those package fields were repaired. Their worksheet cells and styles
were unchanged, full 29×9/43×6/36×7 grids open again, and all three R readers
reproduced the prior analysis CSVs.

Independent human source comparison/signoff remains separate and was not set.
Next focus: the 24 confirmed departures (Armstrong 1979; Baron 1996 Tables 2,
5, 8, 10, 13, 16, 19, 22, 25, 32, 35; Dickscheid 2021 twelve area snapshots)
and 321 pending comparisons. Do not classify numeric text matches alone as
spatial-layout proof.

### Baron 1996 multi-page continuation (2026-11-27)

A further **eight** confirmed departures were corrected after the 43-item
summary above: Baron 1996 Tables 8, 10, 13, 16, 19, 22, 25, and 32. Their
snapshots now keep the printed source-order measurement grids, taxonomic
heading rows, repeated page headers and page breaks. The shared
`_read_baron_multpage.R` infers page number and heading flags and supplies
analysis metadata. The source abbreviation definitions are not transcribed;
their headings remain in the grids and each README records the omission.
All eight readers rebuilt analysis CSVs cell-identically, and all eight
snapshot extraction scripts passed source-grid regression without rewriting
the frozen snapshots.

The present request has resolved **51 of 388** inventory entries. Current
1,035-file inventory: 511 `source_layout_existing`, 161
`corrected_source_checked`, 8 `corrected_source_layout`, 10
`corrected_source_layout_context_omitted`, 8 `source_layout_existing_repaired`,
16 confirmed departures still requiring reconstruction, and 321 pending
source comparison. **337 remain unresolved.** The 16 confirmed cases are
Armstrong 1979 (one aggregate), Baron 1996 Tables 2, 5 and 35, and the
12 Dickscheid 2021 area snapshots. Independent human visual signoff remains
separate.

### Further source-grid checks (2026-11-27)

An additional **26** of the requested entries were resolved after the
51-item tally above. Three existing snapshots were checked against printed
sources: Maslow and Harlow 1932 Tables 1–2 and Nilsson and Siesjö 1976 Table
III. Caspar 2022 Table 1 retains the printed 12 columns, 38 species in source
order and merged genus-total cells; Kaskan 2005 Supplementary Table 1 retains
its printed columns, full citation caption and 30-species order. Caspar's R
reader now propagates merged genus values by genus, with unchanged output.
Burger 2019 Supplementary Data SD1's entire 1,553 × 14 snapshot grid matches
the local journal CSV; its README's mistaken claim that the legacy snapshot
was removed was corrected. Wilman 2014 MamFuncDat's 5,404 × 26 grid matches
the local source TXT cell for cell.

Seven more layout departures were corrected: Lewitus 2014 Table S1 and
Schniter/Peñaherrera-Aguirre 2026 data now freeze exact copies of their local
publisher/Zenodo workbooks; the R readers select and clean from those copies.
Johansen 2024 Table 2 now includes its printed two-tier header, caption and
closing note; Lázaro 2021 Tables 1–2 now keep response section rows rather
than repeating response labels on every measurement row, and Table 2 retains
its two page continuations. Baron 1996 Table 35 now includes all five printed
columns, taxonomic headings, page continuations and the N/NN summary block;
its R reader selects the 68 source Volume rows. Wimberly 2021 MammalGait's
blank source header was restored in the snapshot, with naming moved to R.
All affected analysis CSVs rebuilt cell-identically. The Lázaro extraction
scripts regenerated their corrected grids in a temporary folder.

Twelve name-inventory entries were classified outside this table/matrix
scope: eight citation/prose snapshots, two constructed figure/text summaries,
and two internal registry/taxonomy state files. This classification does not
claim source-layout conformance for them.

**Current tally:** 77 of the requested 388 entries resolved this turn;
311 remain unresolved (15 known layout departures, 296 pending source
comparison). The 1,035-file inventory contains 518 `source_layout_existing`,
168 `corrected_source_checked`, 8 `corrected_source_layout`, 10
`corrected_source_layout_context_omitted`, 8
`source_layout_existing_repaired`, 8 `excluded_text_snapshot`, 2
`excluded_figure_text_snapshot`, and 2 `excluded_internal_snapshot`.
The 15 confirmed departures are Armstrong 1979, Baron 1996 Tables 2 and 5,
and 12 Dickscheid 2021 area snapshots. Human source comparison remains an
independent check and was not marked as completed here.

### Dickscheid source-file correction (2026-11-27)

The 12 Dickscheid 2021 area snapshots were derived joins of three separate
per-patch born-digital tables: `info.txt`, `layerinfo.txt`, and `segments.txt`.
They were retired, and their generator was renamed
`Dickscheid_etal_2021_snapshot.py.retired`. The R build now verifies each
source file against its manifest bucket MD5, reads the original 122 patch
directories, counts segment rows and joins the layer values in R. All 12
seven-row analysis CSVs were byte-identical to the prior builds. The
pre-existing Area 4a layer-III discrepancy against a plotted bar remains
documented in the series README; it is a disagreement in the deposited
source and figure, not introduced by this layout change.

**Latest tally:** 89 of the requested 388 entries resolved; **299 remain**
unresolved (3 confirmed departures: Armstrong 1979 and Baron 1996 Tables 2
and 5; 296 pending source comparison). The current inventory lists 1,023
existing files, with no missing or duplicate paths. Its status counts are
518 `source_layout_existing`, 168 `corrected_source_checked`, 8
`corrected_source_layout`, 10 `corrected_source_layout_context_omitted`,
8 `source_layout_existing_repaired`, 8 `excluded_text_snapshot`, 2
`excluded_figure_text_snapshot`, 2 `excluded_internal_snapshot`, 3
confirmed departures, and 296 pending comparisons. Human source signoff was
not marked completed.

### Final checks in this pass

Lázaro 2021 Table 3 was compared with its landscape PDF p. 11 and restored
to the printed 12-column grid with measure section rows and age-stage header
groups. Its R reader rebuilt the nine-row analysis CSV cell-identically;
the published Gugny percentage inconsistency remains as printed. Stevens
2014 Data S1 was verified byte-identical to the original local CSV at the
source-manifest path. The Benson-Amram 2016 Dataset S1 workbook and three
Lewitus 2012b XLS snapshots have SHA-256 mismatches against their source
manifests; their worksheet layouts remain pending original-workbook
comparison, and no changes were made to those snapshots.

**Current result:** 91 of the requested 388 entries resolved; **297 remain**
(3 confirmed departures and 294 pending source comparison). The 1,023-file
inventory contains 519 `source_layout_existing`, 169
`corrected_source_checked`, 8 `corrected_source_layout`, 10
`corrected_source_layout_context_omitted`, 8
`source_layout_existing_repaired`, 8 `excluded_text_snapshot`, 2
`excluded_figure_text_snapshot`, 2 `excluded_internal_snapshot`, 3
confirmed departures, and 294 pending comparisons.

### XML and printed table follow-up

Both Ziege 2016 Table 1 and Population snapshots reproduce all 19 rows and
seven columns of the article's JATS XML Table 1 at the same positions,
including the section bands and coordinate colspan. Phillips 2007 Table 2
matches all 19 × 13 JATS cells. Iwaniuk 1999 Table 1 retains its 25 species
and eight printed columns in source order. Three prose-derived snapshots
(Modlinska/Stryjek colony, Norbury den census, Wiafe group sizes) were
classified outside the table/matrix scope. Wiafe Table 3 was rechecked
against the printed page and remains source-shaped; it had already been
counted as resolved before this follow-up.

Sherwood 2005 Table 1 had alphabetized the 47 printed species. Its snapshot
now has the printed order and two-tier Mean/SD header; R sorts the analysis
rows. Species-keyed analysis cells are unchanged. Two analysis rows changed
position because the old order was not strictly alphabetical.

**Latest count:** 99 of the requested 388 entries resolved; **289 remain**
(3 confirmed departures and 286 pending source comparisons). Current
1,023-file inventory: 523 `source_layout_existing`, 170
`corrected_source_checked`, 8 `corrected_source_layout`, 10
`corrected_source_layout_context_omitted`, 8
`source_layout_existing_repaired`, 11 `excluded_text_snapshot`, 2
`excluded_figure_text_snapshot`, 2 `excluded_internal_snapshot`, 3
confirmed departures, and 286 pending comparisons.

## Next 100 table/matrix snapshots (2026-11-27)

The next 100 alphabetical candidates were worked through. **98 are resolved**
for this assistant layout audit; **two remain pending original-supplement
comparison**. This is not the separate human source signoff. The inventory now
contains 1,033 active snapshot paths (the count changed when an aggregate
Armstrong snapshot was replaced by nine table snapshots), with no missing or
duplicate paths. Across the project, 191 snapshots remain pending source
comparison and no confirmed layout departures remain in the ledger.

Major source-grid corrections in this group:

- Armstrong 1979 Tables 1–9: replaced one normalized 18-column snapshot with
  nine separate source-oriented table grids; the R reader now combines them.
  All four analysis CSVs were byte-identical after rebuilding.
- Baron 1996 Tables 2 and 5: restored printed eight-column grids, continuation
  and taxonomic rows, and supporting rows where present. Row/page and analysis
  selection information moved into item lookups and R. Both analysis CSVs
  were byte-identical after rebuilding.
- Barks 2014 unpublished values via DeCasien: restored the complete publisher
  MOESM3 workbook as the snapshot; R now selects the 33 relevant rows and joins
  specimen metadata. Analysis values match the prior CSV; floating-point text
  serialization differs slightly.
- Clancy 2001 Table 1: restored the printed 20-column species matrix and
  moved the gather step to R; the 855-row analysis CSV was byte-identical.
- Felleman and Van Essen 1991 Tables 2 and 5: restored side-by-side printed
  grids and moved analysis mappings to R/lookups. Table 2's analysis CSV was
  byte-identical. For Table 5, 23 previously blank `Levels crossed` cells
  were filled from the printed source; its facing-page reference panels remain
  an explicitly documented omission.
- Heffner and Masterton 1983 Table I: restored the 11-column grid with paired
  common/scientific-name rows; its analysis CSV was byte-identical.

Other items in the group were checked against local publisher workbooks,
DOCX tables, PDF tables, or source-text grids and marked in the inventory.
The revised item READMEs record source comparisons and rebuild commands.

The two pending items are:

1. `BensonAmram_etal_2016_DatasetS1_snapshot.xlsx`: the local workbook is a
   501-row, 26-column source-like grid, but its SHA-256
   `11e8720ad256fcaab406a7448fa22bc46dbe447e2d5353d610f0d317a1bffab0`
   differs from the item manifest's
   `c88bfc1f50fcb595fd6b95ea4531eeeacb75176b552b08d64d290a3b6b51683c`.
   The [publisher supplement](https://pmc.ncbi.nlm.nih.gov/articles/PMC4780594/)
   is linked on the article page, but the download timed out twice during this
   pass. Retrieve `pnas.1505913113.sd01.xlsx`, compare sheets/cell coordinates,
   and resolve the manifest discrepancy. The README and manifest note no longer
   assert byte identity without evidence.
2. `Caves_etal_2018_TableS1_snapshot.csv`: the reported source is the authors'
   `Caves (2018) raw data (entire).docx`. It was not found in the repository or
   searched local reference folders. Obtain that DOCX and compare the complete
   four-column table and row order. The README now marks the claimed faithful
   transcription as unverified in this pass.

Neither pending snapshot nor its analysis output was modified. The inventory
and automated triage sheet record the specific next action for each.

### Caves supplement supplied (2026-11-27)

The newly added `Caves_etal_2018/mmc1.docx` contains Table S1 as its first
Word table. Its 41 × 4 cell grid has no merges. All 164 cells match the existing
snapshot at the same coordinates after trimming ten trailing spaces in Word
cells; the full 40-species source order is retained. The caption and Method
definition are outside the table and remain in the source DOCX. No snapshot
or R-reader change was needed. `Rscript Caves_etal_2018/Caves_etal_2018_TableS1.R`
rebuilt the analysis CSV with its prior SHA-256 unchanged. The item README,
inventory and triage sheet now mark this assistant source-layout check as
complete. **99 of the 100 candidates are resolved; only Benson-Amram Dataset
S1 remains pending.** Project-wide pending source comparisons: **190**.

### Benson-Amram supplement supplied (2026-11-27)

The supplied `pnas.1505913113.sd01.xlsx` contains the same `table s1 revised`
501 × 26 worksheet grid as the prior snapshot. Every workbook and worksheet
ZIP member matched; only three custom XML item identifiers differed. The
snapshot was replaced with an exact copy of the supplied workbook and the
manifest SHA-256 corrected to
`0d4f5aa6e38f144173d519a4d2c6a5a6a9f8b9d7d7a9fc721f2c3f4b77edafb1`.
The R reader rebuilt its 495-row analysis CSV with the prior byte hash and
left the registered public TSV unchanged. The inventory and triage sheet now
mark the source layout as checked and package provenance repaired.

The separately supplied `pnas.201505913si.pdf` states that Dataset S1 is an
XLSX. Its Table S1 family totals agree with the workbook on species, trials
and tested individuals, but report 15 successful Felidae individuals and 49
successful individuals overall; the trial-level workbook has 14 and 48.
The PDF aggregate was corrected to 14 and 48 in confirmed erratum
`BensonAmram_etal_2016-E003`, using the digital trial-level workbook as the
authority. No trial response was changed. This printed-summary error is
separate from snapshot layout.

**The requested 100-candidate batch is now resolved for assistant snapshot
layout checking.** Project-wide, 189 active snapshots remain pending source
comparison. Independent human source signoff remains separate.
