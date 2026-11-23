# Jones_etal_2009_PanTHERIA1-0WR05Aug2008.txt

Jones KE et al. (2009). *PanTHERIA: a species-level database of life history, ecology, and geography of extant and recently extinct mammals.* Ecology 90:2648.

## Snapshot

`PanTHERIA_1-0_WR05_Aug2008.txt` is the original published ASCII tab-delimited file and is treated directly as the frozen snapshot. It uses the Wilson and Reeder 2005 taxonomy. No duplicate snapshot is created.

- Data rows: 5416
- Columns: 55
- Missing-value sentinel: `-999`
- SHA-256: `a98aa97318850da15f683cce23128bc6bd8d582dc949d22f6ad2ec8e9d4f6df6`

## Build

`Jones_etal_2009_PanTHERIA1-0WR05Aug2008.txt.R` reads the original TXT without converting `-999` to `NA`, checks the published dimensions, writes `Jones_etal_2009_PanTHERIA1-0WR05Aug2008.txt.csv`, then looks up `Jones_etal_2009_PanTHERIA1-0WR05Aug2008.txt` in `__ReadMe.xlsx`. The encoded public `.txt` is copied byte-for-byte from the frozen source and verified by checksum.

The full variable definitions are provided in the accompanying publication metadata rather than duplicated or paraphrased here.

## Reference tables (added 2026-10-20)

`reference_tables/` holds the publication-side reference material for PanTHERIA, parsed from `metadata.htm` (Ecological Archives E090-184 metadata, ISO-8859-1 HTML) and from the two frozen data files. Nothing in the frozen sources or the existing data CSVs was changed; every table below is a report about the publication.

### Structural facts (from the metadata's own text)

- The `References` column (column 36) is a semicolon-separated list of reference index numbers given **once per species row**, not per variable or per value. Metadata Table 1: "References: Index numbers referring to sources of data for each species according to the list of references given in section F below."
- Each published value is a measure of central tendency over several raw data lines ("mean per species per variable for species with data = 3.3, n = 94729 data lines"). The raw data lines, which would tie a citation to a value, are **not published**: "the raw data are held in an Access database at The Zoological Society of London." A per-cell source attribution therefore cannot be derived from the publication; the finest published granularity is species x reference.
- The reference list has 3143 entries, numbered contiguously 1-3143.

### Files and scripts

All scripts are self-locating (`Rscript <script>.R` from any cwd, or Source in RStudio) and use the R environment of this repo (dplyr, readr, tidyr, xml2). Run order: references -> definitions -> consistency -> reference_tables_definitions. Every input problem is a `stop()`.

| Script | Output (reference_tables/) | Content |
|---|---|---|
| `Jones_etal_2009_references.R` | `Jones_etal_2009_references.csv` (3143 rows) | One row per reference number: `ref_number`, `citation` (verbatim, tags removed, entities decoded), heuristic `first_author`, `year`, `title`, `journal_or_publisher`, `volume` (bold in source), `pages`, `species_in_citation` (italics in source), `n_species_citing_WR05`, `n_species_citing_WR93`. Guards: numbers unique, numeric, contiguous 1..3143; every cited number has a row; citations >= 20 characters (one declared exception, below); year parsed for >= 99 % (actual 100 %). |
| same | `Jones_etal_2009_references_unparsed.csv` (1 row) | Entry 3018 is printed in the source as `Wiles, G. 1996.` only; kept verbatim, nothing invented. |
| same | `Jones_etal_2009_species_references.csv` (49144 rows: WR05 24623, WR93 24521) | Long table taxonomy x binomial x `ref_number` x `citation`, with `ref_token_as_printed`, `token_status`, and per-species `n_reference_numbers` == `n_citations_resolved` (asserted). |
| same | `Jones_etal_2009_species_reference_counts.csv` (10045 rows = 5416 + 4629) | Per species: `n_refs`, `n_variables_with_data` (cols 6-35), `n_variables_with_data_incl_derived` (cols 6-35, 37-55). |
| same | `Jones_etal_2009_species_data_without_references.csv` (0 rows) | Species with a source-variable value but `References = -999`: none in either file. |
| same | `Jones_etal_2009_References_malformed_tokens.csv` (38 rows) | Tokens in the `References` column that are not valid reference numbers: 24 distinct 8-digit tokens (18 occurrences in WR05, 20 in WR93) that are two 4-digit numbers fused by a missing `;` (e.g. `30483049`). Each decodes into exactly one pair of valid numbers; the pair is used in the long table flagged `decoded_from_fused_token`, and the token is kept as printed. A publication defect, reported not repaired. |
| `Jones_etal_2009_definitions.R` | `Jones_etal_2009_definitions.csv` (71 rows) | House definitions format. 55 column rows (taxonomy 5, Table 1 variables 30, `References` 1, derived 19) with Definition = the metadata's own text verbatim, Measure = Table 1 units, Stat = Table 2 central-tendency measure, Note = Table 1 data lines and NSpp MSW93/MSW05, Source Note = Table 2 GLM specification; plus 16 `method` rows transcribing the "Calculating measures of central tendency" section (4 paragraphs), the References statement, the -999 sentinel, the raw-data-lines statements, and the derived-variable paragraphs. Table 3 (EXT models) exists in the archive only as an image (`DPimages/Table3.jpg`, not in this folder). |
| `Jones_etal_2009_WR05_vs_WR93_consistency.R` | `Jones_etal_2009_WR05_vs_WR93_consistency.csv` (19454 rows), `..._references.csv` (231 rows), `..._summary.csv` (26 rows) | Cell-by-cell comparison for binomials spelled identically in both files; see numbers below. |
| `Jones_etal_2009_reference_tables_definitions.R` | `Jones_etal_2009_reference_tables_definitions.csv` (62 rows) | Column definitions for every CSV above (asserts one row per column of every non-definitions CSV in `reference_tables/`). |

### Reference coverage

- WR05: 5416 species rows; 4166 with references; 4165 with any source-variable value (cols 6-35); 4998 with any value including derived columns; 0 with source data but no references; 1 with references but no source data (*Cephalophus brookei*); mean 5.91 references per species with references.
- WR93: 4629 species rows; 4044 with references; 4044 with any source-variable value; 4569 with any value including derived columns; 0 with source data but no references; mean 6.06 references per species with references.
- 3114 distinct reference numbers are cited by at least one of the two files; 29 of the 3143 are cited by neither.
- Derived spatial columns (41-55) carry values for species with no references: the References column documents only the extracted (literature) variables.

### WR05 vs WR93 consistency (publication against itself)

- Binomials: 5416 (WR05), 4629 (WR93), 4080 spelled identically in both; 1336 only in WR05, 549 only in WR93.
- Requested set (30 source variables, cols 6-35, plus 4 EXT, cols 37-40; 34 columns): 138720 cells compared; 126998 numerically identical; 11114 differ with both sides non -999 (6662 of them within 1 %, 0 by a power of ten); 608 have -999 on exactly one side (271 present only in WR05, 337 only in WR93). By group: 11024 differing cells in source columns, 698 in EXT columns. Most differences are in GLM-consolidated variables (AdultBodyMass 2369, AdultHeadBodyLen 1283, LitterSize 1116, SexualMaturityAge 944, WeaningAge 837), consistent with the consolidation being run separately per taxonomy.
- Spatial columns (41-55, 15 columns, reported for completeness): 61200 cells compared, 7732 differ (6178 with both sides present).
- Formatting only (counted, not listed): 105027 cells print the sentinel as `-999` in one file and `-999.00` in the other; 23490 non-sentinel cells are numerically equal but formatted differently (e.g. `1` vs `1.00`).
- References lists: 3849 shared binomials have identical lists; 231 differ (116 with numbers only in WR05, 121 with numbers only in WR93).

### Other publication quirks recorded in the definitions file

- Table 1 prints `5-3_NeonatalBodyMass_g` and `21-1_PopulationDensity` for the data headers `5-3_NeonateBodyMass_g` and `21-1_PopulationDensity_n/km2`; Table 2 drops unit suffixes on several codes.
- The metadata header list prints `29-1_AET_Mean_mm` / `29-2_PET_Mean_mm`; the files and Class V.C use `30-1_` / `30-2_`.
- Class V.C says "23 additional variables" / "19 variables using data from other sources" but enumerates 4 + 15 = 19 items (numbering jumps from (41) to (46)); the files have exactly 19 derived columns (37-55).
- WR93 headers differ from WR05 for columns 1-5 (`MSW93_`), 20 (`14-1_InterBirthInterval_d`), 44 (`26-4_GR_MRLat_dd`) and 47 (`26-7_GR_MRLong_dd`); the comparison matches columns by position.

## Reference availability (`reference_tables/Jones_etal_2009_references_availability.csv`)

Working record of which of the 3,143 cited works we hold, one row per reference number checked, updated in
place on re-check; `Jones_etal_2009_references.csv` itself stays a verbatim transcription. Columns in
`…_references_availability_definitions.csv`; decision column `availability`. First rows: the 21 works cited
for *Sus scrofa* and *Mustela putorius*, checked against the EndNote library — 2 present with a PDF (1573
Kelt & Van Vuren 2001; 2986 Weckerly 1998), 2 author-year coincidences with different papers (645, 1113),
17 absent; online routes not yet searched.
