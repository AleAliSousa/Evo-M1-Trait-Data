# Table and matrix snapshot layout audit

Started 2026-11-27. Scope: files named `*_snapshot.{csv,tsv,xlsx,xls,docx,doc}`
whose names do not identify figures or prose. The initial inventory contains
1,039 files in 495 paper folders (696 CSV, 267 XLSX, 61 TSV, 7 DOCX, 6 XLS,
2 DOC). This is a name-based inventory, not 1,039 source-verified items; some
files may need recategorization. Existing user changes throughout the repository
were left untouched.

The current 1,038-file path list and review status is in
`table_snapshot_layout_inventory.csv`; the count fell by one when the duplicate
normalized de Sousa 2013 CSV snapshot was removed. `pending_source_comparison`
means unreviewed, not conforming.

## Corrected and checked against sources

| Item | Source comparison | Change | Rebuild check |
| --- | --- | --- | --- |
| `Jacobs_etal_2015_Table4` | PDF p. 2868, printed species columns and parameter rows | Reoriented CSV snapshot; moved transpose and ± split to R; added source footnotes | Analysis CSV unchanged cell for cell |
| `Jung_etal_2022_TableS1` | `sciadv.abn0954_sm.pdf`, Table S1 | Reoriented XLSX; put citations below measurements; moved scientific-name annotations to item lookup; transposed in R | Analysis CSV and public TSV unchanged |
| `deSousa_etal_2013_Table1` | `desousa_etal_2013.pdf`, Table 1, PDF p. 5 | Replaced normalized XLSX with eight-column printed table; removed duplicate normalized CSV snapshot; kept legacy higher-precision values in a separately documented item lookup, checked against printed rounding in R | Analysis CSV unchanged cell for cell |
| `Lyamin_etal_2008_Table2` | Snapshot and R already preserved printed orientation from 2026-09-17 | Corrected stale README claiming the snapshot was transposed | No data rebuild needed |

These are assistant checks; `Human visual check of snapshot` signoff was not set.

## Confirmed departures needing source reconstruction

Six XLSX snapshots explicitly say their measurements were taken from a curated
comparison CSV. Their first rows use cleaned structure names and a publication
caption assembled for the snapshot, rather than the printed table headings and
arrangement. Reconstruct each from the original PDF before modifying its reader:

| Item | Immediate next action |
| --- | --- |
| `Baron_etal_1990_Table1` | Transcribe the scanned printed Table 1, including its actual species/structure arrangement; compare to the current 78-row, two-column curated snapshot. |
| `Frahm_etal_1984_Table1` | Rebuild the printed area-striata table from the PDF, preserving grouping and source columns; map the seven cleaned columns in R. |
| `Frahm_etal_1997_Table1` | **High priority:** PDF p. 3 (printed p. 211) shows Table 1 with eight specimen rows per species and two group mean/SD rows, plus a separate Table 2 below. The current snapshot has only two species rows and combines structure values from both tables. Rebuild Table 1 as printed and separate Table 2 data in the reader/item plan. |
| `Frahm_etal_1998_Table1` | Rebuild from the printed MT table; current XLSX has curated structure and body/brain fields. |
| `Stephan_etal_1984_Table1` | Rebuild from the printed LGN table; current XLSX uses curated `code`, `Species`, `n`, and normalized mm³ header. |
| `Stephan_etal_1987_Table1` | Rebuild the printed amygdala table; inspect the parallel CSV snapshot before retaining or removing it. |

`deSousa_etal_2010_Table1_snapshot.xlsx` also has a stale README sentence
claiming curated-CSV origin, but its `Table 1` sheet is a 38-row, nine-column
printed-layout transcription with specimen rows. Do not group it with the six
normalized snapshots without a source comparison. `openpyxl` cannot load that
workbook because of a dangling drawing relationship, while `readxl` can read
its table; preserve it until a repair can be checked against the PDF.

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
these require source comparison, not automatic rewriting. Most of the 1,039
files remain to be individually source-checked. Do not mark this audit complete
from the name or metadata scan alone.
