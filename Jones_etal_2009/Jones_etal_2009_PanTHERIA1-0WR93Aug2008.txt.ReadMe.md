# Jones_etal_2009_PanTHERIA1-0WR93Aug2008.txt

Jones KE et al. (2009). *PanTHERIA: a species-level database of life history, ecology, and geography of extant and recently extinct mammals.* Ecology 90:2648.

## Snapshot

`PanTHERIA_1-0_WR93_Aug2008.txt` is the original published ASCII tab-delimited file and is treated directly as the frozen snapshot. It uses the Wilson and Reeder 1993 taxonomy. No duplicate snapshot is created.

- Data rows: 4629
- Columns: 55
- Missing-value sentinel: `-999`
- SHA-256: `dd98b18a4b9254420a5a24548df3ca23e873be6fadb1db9f00d9fa0661478796`

## Build

`Jones_etal_2009_PanTHERIA1-0WR93Aug2008.txt.R` reads the original TXT without converting `-999` to `NA`, checks the published dimensions, writes `Jones_etal_2009_PanTHERIA1-0WR93Aug2008.txt.csv`, then looks up `Jones_etal_2009_PanTHERIA1-0WR93Aug2008.txt` in `__ReadMe.xlsx`. The encoded public `.txt` is copied byte-for-byte from the frozen source and verified by checksum.

The full variable definitions are provided in the accompanying publication metadata rather than duplicated or paraphrased here.

## Reference tables (added 2026-10-20)

The reference-side tables for both taxonomy versions live in `reference_tables/` and are documented in full in `Jones_etal_2009_PanTHERIA1-0WR05Aug2008.txt.ReadMe.md` (section "Reference tables"). For this file: 4629 species rows, 4044 with references (24521 species x reference rows in `Jones_etal_2009_species_references.csv`, `taxonomy = WR93`), 0 species with source data but no references, 20 fused reference tokens (missing `;`) quarantined in `Jones_etal_2009_References_malformed_tokens.csv`. The `References` column is per species, not per value; the raw data lines are unpublished. WR05 vs WR93 comparison for the 4080 shared binomials: 138720 source+EXT cells compared, 126998 identical, 11114 differ with both sides present, 608 with -999 on one side; 231 shared binomials have differing References lists. Scripts: `Jones_etal_2009_references.R`, `Jones_etal_2009_definitions.R`, `Jones_etal_2009_WR05_vs_WR93_consistency.R`, `Jones_etal_2009_reference_tables_definitions.R` (run with `Rscript`, any cwd).
