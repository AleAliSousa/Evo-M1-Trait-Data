# InoueNakamura__1997_Table3

Source: https://doi.org/10.1111/1468-5884.00059 — Table 3, printed p.272.

Table3

Frozen source: `InoueNakamura__1997_Table3_snapshot.csv`. The reader preserves printed labels and raw numeric strings, parses numbers without treating blanks as zero, and writes 25 analysis rows plus the public TSV.

Circle=positive, X=negative, dash=no available data. a=infants; b=behaviour reported in a few individuals. *=present study. Self-directed behaviour is not itself a standardized mark-test result. Common names omitted from this constructed symbol transcription; taxon spelling and footnotes retained. Literature rows excluded from independent pooling.

Build: frozen source → analysis CSV → registry-coded public TSV. Numeric source cells, intervals, censoring, missingness and printed species labels are retained.

Source inspection: assistant checked; no human visual sign-off claimed.

Rebuild: `Rscript InoueNakamura__1997/InoueNakamura__1997_Table3.R`.


Build: frozen source → analysis CSV → registry-coded public TSV. Numeric source cells, intervals, censoring, missingness and printed species labels are retained.

Source inspection: assistant checked; no human visual sign-off claimed.

Rebuild: `Rscript InoueNakamura__1997/InoueNakamura__1997_Table3.R`.

## Snapshot layout audit (2026-11-27)

Compared against the EndNote source PDF at printed p. 272. Restored common
name plus scientific name in the printed first column, and the five primate
section rows. The shared R builder extracts the scientific label and skips
section rows for analysis. Source boldface and superscript styling cannot be
represented fully in CSV; asterisk and footnote letters remain in the cells.
Ran `Rscript InoueNakamura__1997/InoueNakamura__1997_Table3.R`; the 25-row
CSV retained SHA-256 `baa220185f812e5fa0e72524a672afafa899e414a007e44763a9b0d369810018`.
