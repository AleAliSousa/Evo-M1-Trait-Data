## Isler et al. 2008 - TableS3

Isler K, Kirk EC, Miller JMA, Albrecht GA, Gelvin BR, Martin RD (2008). *Endocranial volumes of primate species: scaling analyses using a comprehensive and reliable data set.* Journal of Human Evolution 55:967-978. DOI: 10.1016/j.jhevol.2008.08.004.

### Source -> Snapshot

`Isler_etal_2008_TableS3_snapshot.csv` is the frozen source used to reproduce the attached public TSV. It was originally saved as a tab-delimited `.tsv` snapshot; per house convention, local working files are CSV and only the copy under `__Public/comparative-data/` is tab-delimited, so the snapshot was losslessly re-delimited to comma-separated CSV (verified by round-tripping every field back through the original tab-delimited bytes) and the stale `.tsv` snapshot removed. Content, blank cells, quoting, Unicode, and printed numeric precision are unchanged -- only the delimiter and file extension changed, with one exception: a single entirely-blank trailing row (every field empty, one field short of the table's 12-column width) was dropped during the re-delimiting pass -- it carried no data and its presence only created ragged-row ambiguity for CSV/TSV parsers.

- Data rows after the first nonblank header line: 45 (46 before dropping the blank trailing row)
- Maximum delimited fields observed: 12
- SHA-256 (current `_snapshot.csv`): `7f93fa17d5cc289f8b9b453cc511ec1c94031d1fab69d8080cad91ca477c9621`

### Build

`Isler_etal_2008_TableS3.R` copies the frozen bytes to `Isler_etal_2008_TableS3.csv` (local working copy, CSV), then looks up `Isler_etal_2008_TableS3` in `__ReadMe.xlsx`, reformats the CSV to tab-delimited (quoting fields only where RFC4180 requires it), and writes the DOI-coded `.tsv` file to `__Public/comparative-data/`. The script verifies byte identity of the local CSV copy after each write. It does not harmonise taxonomy or replace blanks with `NA`.

### Expected public name

`10.1016%2Fj.jhevol.2008.08.004_TableS3.tsv`
