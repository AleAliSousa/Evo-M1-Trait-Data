# Lukas_CluttonBrock_2013_ReferencesforSupplementaryTable

Lukas, D., & Clutton-Brock, T. H. (2013). The evolution of social monogamy in mammals. *Science*,
341(6145), 526–530. https://doi.org/10.1126/science.1238677

## What this item is
The bibliography ("References for Supplementary Table") backing the per-species
`Reference_code` column of `Lukas_CluttonBrock_2013_SupplementaryData`. 479 entries, transcribed
from `lukas.sm.pdf` pages 85–107 (PDF page index; the heading appears at the top of that range).

## Build method
The source list is **alphabetically ordered by author surname, not numbered** — unlike the
numbered bibliographies built for Felleman & Van Essen 1991 and Zhu et al. 2023. Entries were
split from the page text by detecting citation-start boundaries (a capitalized surname + initial
immediately following the period that ends the previous entry), then each entry's first-author
surname and year were extracted to support matching against the data item's shorthand
`Reference_code` keys (see that item's README). Two inconsistent in-text year formats were
both handled: most entries use "(YYYY)." but at least one ("Nowak, R. M., 1999...") uses a bare
", YYYY." — both are recognized.

## Columns
See `reference_tables/Lukas_CluttonBrock_2013_ReferencesforSupplementaryTable_definitions.csv`.
`ref_id` is an id assigned during this build for cross-referencing — it is not printed in the
source.

## Data role
**Primary** — the paper's own reference list, transcribed verbatim.

## Files
- `Lukas_CluttonBrock_2013_ReferencesforSupplementaryTable_snapshot.csv` — frozen, verbatim
  parse (479 rows).
- `Lukas_CluttonBrock_2013_ReferencesforSupplementaryTable.csv` / public TSV — identical content,
  published.
