# de Magalhães & Costa 2009 — AnAge Build 11

de Magalhães, J. P., & Costa, J. (2009). A database of vertebrate longevity records and their relation to other life-history traits. *Journal of Evolutionary Biology*, 22(8), 1770–1774. DOI [10.1111/j.1420-9101.2009.01783.x](https://doi.org/10.1111/j.1420-9101.2009.01783.x).

## Source and version

The article describes AnAge but prints no species table. The owner has since
placed a historical `dataset/dataset.txt` beside `dataset/release.html` in
this folder. The release note identifies **AnAge Build 11, 7 May 2009** and
reports 4,122 entries. The supplied tab-delimited export contains **4,095
nonempty species rows**, each with 30 columns; the difference is **27 rows**.
The release note itself warns that live/export counts may drift. We preserve
the actual supplied export and do not add rows to force agreement with the
release count. It includes mammals and other taxa; none are filtered.

The prior README marked this paper citation-only under an owner decision of
2026-10-23 because no historical download was then present. The current user
request and newly present Build 11 files supersede that status. Build 15
remains a separate version in `deMagalhães_etal_2024`; do not pool the same
species' Build 11 and Build 15 values as independent observations.

## Item build

Item: `deMagalhães_Costa_2009_AnAgebuild2009` (the item name already cached in
the main registry's placeholder row 167). `dataset/dataset.txt` is the
digital-native source. A byte-identical frozen copy is
`deMagalhães_Costa_2009_AnAgebuild2009_snapshot.txt` (SHA-256
`c425f65e73071793fa2d28e17abf6bae05b78f9c1f25e719f3de98f6ca182aea`).
The reader touches only the frozen copy. The original download and release
note remain unchanged.

From the repository root, run:

```sh
Rscript --vanilla deMagalhães_Costa_2009/deMagalhães_Costa_2009_AnAgebuild2009.R
Rscript --vanilla deMagalhães_Costa_2009/deMagalhães_Costa_2009_AnAgebuild2009_reference_alignment.R
```

The first script writes a 4,095-row, 32-column analysis CSV and the
DOI-coded public TSV in `__Public/comparative-data/`. It retains all source
columns, renames headers to the established AnAge units, parses 17 numeric
columns, and adds `source_row` plus `scientific_name` (source Genus + Species).
It preserves the source spelling and taxonomic Order; there is no cross-build
HAGRID in this export and no name harmonisation. `Adult_weight_g` and
`Body_mass_g` remain separate measurements. The interbirth interval is in
days, as documented for AnAge. The output keeps `Source_ref` and `References`
verbatim. The item is **secondary**, because AnAge compiles primary reports.

The second script writes a 16,567-row occurrence bridge in
`reference_tables/`. `Source` refers to the maximum-longevity record; the
comma-separated `References` support the row overall, with no assignment to
individual trait columns. Numeric IDs and 17 prose-source occurrences are
preserved. The export uses 812 distinct numeric keys, but its historical
bibliography was not supplied. We did not import the Build 15 bibliography:
at least keys 450 and 553 point to post-2009 works in that later copy, so a
blind join would misidentify 2009 citations. The bridge remains join-ready
when a verified Build 11 bibliography is found. Definitions and the two
reference-column scopes are in `reference_tables/`.

## Registry and checks

The main `__ReadMe.xlsx` has a citation-only placeholder at row 167. Because
the main workbook is occupied, the completed build metadata are in
`__ReadMeAddON.xlsx` and in this folder's `_registry_row.xlsx`. When
consolidating, **update the existing master row by Item name**; do not append
a duplicate. The registry's `Item encoded` supplies the public TSV filename.
The source is digital-native, so a human PDF-to-snapshot visual check is not
applicable.

The R build completed on 2026-11-24: 4,095 unique source binomials, 30 source
columns, 17 numeric columns parsed without unexpected tokens, and matching
CSV/TSV row counts. The frozen copy's hash matches the original download.
The 27-row release/export difference and missing historical bibliography are
active provenance limits, not transcription errors. No merge was run.
