# Johnson_etal_2002_Table1

Johnson, V. E., Deaner, R. O., & van Schaik, C. P. (2002). Bayesian analysis of rank data with
application to primate intelligence experiments. *Journal of the American Statistical Association*,
97(457), 8–17. https://doi.org/10.1198/016214502753479185
Local PDF: `Johnson-2002-Bayesian analysis of.pdf` (Table 1 on PDF p. 3 = journal p. 9, printed rotated).

**Table 1. Studies Included in the Meta-Analysis of Primate Intelligence** — 24 primate genera ×
30 procedures in nine paradigms; 113 filled cells. Each entry is the rank of the genus within that
procedure (1 = best; x.5 = tie). Registry: `Item name` Johnson_etal_2002_Table1, `Item encoded`
`10.1198%2F016214502753479185_Table1` (existing Sheet1 row; looked up by name).

## Files

| file | role |
|---|---|
| `Johnson_etal_2002_Table1_snapshot.xlsx` (sheet `Table1`) | frozen transcription in printed layout: caption, merged paradigm header, Procedure/Genus header rows, genus rows in printed order with the printed blank separators between the five groups, the full NOTE |
| `Johnson_etal_2002_Table1.R` | reads the snapshot positionally → long CSV + public TSV |
| `Johnson_etal_2002_Table1.csv` | analysis data, 113 rows (genus × procedure) |
| `__Public/comparative-data/10.1198%2F016214502753479185_Table1.tsv` | public copy |
| `reference_tables/Johnson_etal_2002_Table1_definitions.csv` | data dictionary |
| `reference_tables/Johnson_etal_2002_Table1_references.csv` | 44 rows: original study/studies behind each procedure (NOTE key → verbatim bibliography entry) |
| `Johnson_etal_2002_Table1_registry_row.xlsx` | proposed descriptive-column update for the existing registry row |

## Reader and transcription (provenance)

Transcribed by an AI assistant (Claude Science session, 2026-10-28). The PDF text layer is unreliable
for this table: every fractional tie rank extracts with the decimal glyph as "0" ("1.5" → "105",
"2.5" → "205", "6.5" → "605", "8.5" → "805"; see `Johnson_etal_2002_NOTE.md`). Procedure:

1. Word bounding boxes from the text layer were used **only to locate** cells: each number was assigned
   to the genus row and procedure column whose printed label centre it sits on (113 cells, no
   collisions, no cell further than 4 pt from its row label or 6 pt from its column header).
2. The table page was rendered at 220 dpi, rotated upright, and every row was read against the image
   (all 113 cells; positions and values).
3. All 26 fractional cells (`x05` in the text layer) were rendered individually at 500 dpi and read:
   every one prints as x.5 (1.5 ×8, 2.5 ×10, 6.5 ×6, 8.5 ×2 = 26). No integer cell was misread as
   fractional or vice versa (10 and 11 are printed integers).
4. Independent cross-check: the 113 cells equal `Deaner_etal_2006_Table1` cell-for-cell
   (0 differences, 0 cells present in one only) — a separate transcription of the same matrix.

## Build steps (R)

Positional read (`col_names = FALSE`); paradigm header carried across its merged cells; blank
printed separator rows → `taxonomic_group_note` (great apes / Hylobates "not so categorized" / Old
World monkeys / New World monkeys / Prosimians, from the NOTE); wide → long, blank (untested) cells
dropped; genus → `taxon_harmonised` via `_keys/General/species_key.csv` filtered on
`source_publication = Johnson_etal_2002` (stops if the filter returns zero rows or a genus is
unkeyed); `procedure_ref_key` = procedure number. Ranks are unitless; no conversion.
Ran clean with `Rscript --vanilla` in env `evom1-r` (R 4.5.3), 2026-10-28.

## Data role: both — and NOT independent of Deaner et al. 2006

The rank coding is the authors' own ordinal summary (first published here); the performance data
behind each rank come from the original studies listed in the NOTE (one to five works per
procedure, 40 distinct works) → **secondary** for the underlying observations. The registry row
currently says `primary`; the proposed row says `both` (owner decision). `Deaner_etal_2006_Table1`
re-publishes the identical matrix: never pool or count the two items as independent evidence.

## Source tracing

`reference_tables/Johnson_etal_2002_Table1_references.csv`: `ref_key` = procedure number as printed
in the NOTE, `cited_in_column = procedure`, `citation` = bibliography entry (pp. 16–17) verbatim;
join `procedure_ref_key` → `ref_key` (one-to-many). Verbatim discrepancies recorded, not corrected:
the NOTE spells "Reisen, Greenberg, Granston, and Fantz (1953)" while the bibliography prints
"Riesen, A. H."; repeated-author entries print a rule (———) for the authors, kept as "———".
Stevens (1965), an unpublished dissertation, supplies procedures 12, 13 and 20.

## Table checks

None: a rank matrix has no printed totals (HOWTO §7a). The script asserts 113 cells, ranks ≥ 1
and integer-or-half values only.
