# Zhu_etal_2023_SupplementaryReferences

Zhu, P., Liu, W., Zhang, X., Li, M., Liu, G., Yu, Y., Li, Z., Li, X., Du, J., Wang, X., Grueter,
C. C., Li, M., & Zhou, X. (2023). Correlated evolution of social organization and lifespan in
mammals. *Nat Commun*, 14(1), 372. https://doi.org/10.1038/s41467-023-35869-7

## What this item is
The numbered bibliography (88 references) that `Zhu_etal_2023_SupplementaryData1` and
`Zhu_etal_2023_SupplementaryData3` cite per-species, per-value, via their own
`Supplementary_References_codes` column. The source PDF (`41467_2023_35869_MOESM1_ESM.pdf`,
p. 32) states explicitly: "Supplementary References — References of Supplementary Data 1 and
Supplementary Data 3 (separate files)" — i.e. this is the reference lookup table for exactly
those two data items, built alongside them for that purpose.

## Build method
Extracted from the PDF's embedded text layer (pages 32–36, `pypdfium2`), which is clean,
digital-native text (not a scan). Entries are strictly sequentially numbered 1–88 in the
source; the 88 entries were split by matching each expected sequential number in turn (rather
than a generic "digit + period" regex, which false-matches volume/page numbers embedded inside
citations, e.g. "Ecology 99, 2626 (2018)."). Every one of the 974 + 94 = 1,068 per-species
reference codes cited across the two data tables falls in the range 1–88 and resolves to an
entry here — confirmed by cross-checking the maximum cited code (88) against the number of
parsed entries (88) with no gaps.

## Columns
See `reference_tables/Zhu_etal_2023_SupplementaryReferences_definitions.csv`.

## Data role
**Primary** — the paper's own reference list, extracted verbatim.

## Files
- `Zhu_etal_2023_SupplementaryReferences_snapshot.csv` — frozen, verbatim parse (88 rows).
- `Zhu_etal_2023_SupplementaryReferences.csv` / public TSV — identical content, published.
