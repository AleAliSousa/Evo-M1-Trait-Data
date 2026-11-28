# Table and matrix snapshot layout audit

Started 2026-11-27. Scope: files named `*_snapshot.{csv,tsv,xlsx,xls,docx,doc}`
whose names do not identify figures or prose. The initial inventory contains
1,039 files in 495 paper folders (696 CSV, 267 XLSX, 61 TSV, 7 DOCX, 6 XLS,
2 DOC). This is a name-based inventory, not 1,039 source-verified items; some
files may need recategorization. Existing user changes throughout the repository
were left untouched.

The current 1,036-file path list and review status is in
`table_snapshot_layout_inventory.csv`; the count fell by one when the duplicate
normalized de Sousa 2013 CSV snapshot was removed, and by one more when two
Stephan 1987 flat CSV snapshots were replaced by one XLSX snapshot for Table 2
(Table 1 already had an XLSX). It fell by one more when the split Herculano-Houzel
2013 Table 1-b snapshot was replaced by one complete Table 1 source-layout
snapshot shared by its two R readers. `pending_source_comparison`
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
