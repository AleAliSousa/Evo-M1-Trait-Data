## Isler et al. 2008 - TableS1

Isler K, Kirk EC, Miller JMA, Albrecht GA, Gelvin BR, Martin RD (2008). *Endocranial volumes of primate species: scaling analyses using a comprehensive and reliable data set.* Journal of Human Evolution 55:967-978. DOI: 10.1016/j.jhevol.2008.08.004.

### Source -> Snapshot

`Isler_etal_2008_TableS1_snapshot.csv` is the frozen source used to reproduce the attached public TSV. It was originally saved as a tab-delimited `.tsv` snapshot; per house convention, local working files are CSV and only the copy under `__Public/comparative-data/` is tab-delimited, so the snapshot was losslessly re-delimited to comma-separated CSV (verified by round-tripping every field back through the original tab-delimited bytes) and the stale `.tsv` snapshot removed. Content, blank cells, quoting, Unicode, and printed numeric precision are unchanged -- only the delimiter and file extension changed.

- Data rows after the first nonblank header line: 3813
- Maximum delimited fields observed: 22
- SHA-256 (current `_snapshot.csv`): `2882663c351d68f4556a3cd30461b5084145b7cdc951baef37ce8e171d8dee9c`

### Build

`Isler_etal_2008_TableS1.R` copies the frozen bytes to `Isler_etal_2008_TableS1.csv` (local working copy, CSV), then looks up `Isler_etal_2008_TableS1` in `__ReadMe.xlsx`, reformats the CSV to tab-delimited (quoting fields only where RFC4180 requires it), and writes the DOI-coded `.tsv` file to `__Public/comparative-data/`. The script verifies byte identity of the local CSV copy after each write. It does not harmonise taxonomy or replace blanks with `NA`.

### Expected public name

`10.1016%2Fj.jhevol.2008.08.004_TableS1.tsv`
