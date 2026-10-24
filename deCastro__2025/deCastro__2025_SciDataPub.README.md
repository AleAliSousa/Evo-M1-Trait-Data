# deCastro__2025_SciDataPub — FmrBT: field metabolic rate, body mass and ambient temperature

de Castro, F. (2025). FmrBT: A comprehensive data set of field metabolic rates, body mass and
ambient temperature. *Scientific Data*, 12(1), 1589. https://doi.org/10.1038/s41597-025-05868-y

## What this item is
4,637 field metabolic rate (FMR) records compiled from the published literature, covering more
than 700 species across mammals, birds, reptiles, fish, invertebrates, and unicellular
organisms, each with body mass, ambient temperature (where reported), endotherm/ectotherm
status, and a per-record source reference. 4,369 ectotherm records and 268 endotherm records.

## Source — digital-native, not transcribed
`FieldMR_SciDataPub.xls` (in this folder) is the paper's own supplementary data workbook, with
two sheets: `Alldata` (the 4,637-row data table used here) and `DOI` (192 references with DOIs,
used to resolve the `Reference` column — see below). Kept untouched as the frozen source per
house convention for digital-native sources — no derived snapshot is made; the build script
reads this file directly.

## Determining the reference for any datapoint
Each row's `Reference` column holds a shorthand citation (e.g. `"Anava 2002"`,
`"Adrian, O.; Kaiser, S. ... Hennessy, M. B. 2008"`). The workbook's own `DOI` sheet gives 192
references as `(FirstAuthor, Year, Title, Journal, DOI)`. These were matched by taking the
`Reference` string's leading surname and trailing year and looking that up against the DOI
sheet's `(FirstAuthor, Year)` pair — exact match first, then a conservative fuzzy pass (allowing
hyphen/spacing/diacritic differences in the surname, e.g. "CerezoValverde" → "Cerezo-Valverde",
and lettered-year suffixes like "1984 a"/"1984 b").

`reference_tables/deCastro__2025_SciDataPub_references.csv` is the resulting lookup (`ref_key` →
matched author/year/full citation+DOI, one row per unique shorthand code, 192 keys). **169 of 192
unique keys (4,173 of 4,637 rows, 90%) resolve.** The remaining 23 keys (464 rows, 10%) are
either genuinely absent from the workbook's own 192-entry DOI sheet (it is evidently a curated
subset, not a complete bibliography of every citation in `Reference` — e.g. several 1970s–80s
ichthyology papers cited nowhere in the DOI sheet) or could not be matched with confidence —
kept as `NOT FOUND`/unresolved rather than guessed.

## Column rename
The source workbook's `Mass_g` column is renamed to `BodyMass_g` in the built CSV (and nowhere
else does this column's original name matter) so that `__merging_body_ecology`'s auto-harvester —
which matches source headers against a `body.?mass` pattern — picks it up as a new body-mass
source without special-casing. All other column names are kept as printed in the workbook.

## Data role
**Primary** — this is the paper's own compiled dataset (per-record provenance tracked via
`Reference`), the paper's stated contribution.

## Files
- `FieldMR_SciDataPub.xls` — the untouched source workbook (frozen; both sheets used).
- `deCastro__2025_SciDataPub.csv` / public TSV — the `Alldata` sheet, column names unchanged,
  published.
- `reference_tables/deCastro__2025_SciDataPub_references.csv` — the reference-key lookup
  described above.
