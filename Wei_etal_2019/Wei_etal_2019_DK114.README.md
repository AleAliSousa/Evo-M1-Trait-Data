# Wei et al. 2019 DK114 regional expansion table

The source is the authors' `dutchconnectomelab_download/chimp2humanDK114.csv`,
from the public archive named in `download_manifest.csv`. The item snapshot
is a byte copy of the repository's source CSV. Git normalized the original
archive's Windows line endings to Unix: restoring CRLF line endings yields
the manifest's SHA-256 `ed73926bd84cfea4ea0ea39aefc6fb77e0f6a37bd5b3101a6a49ab61cb7eb8b1`.
No numeric content was changed.

From the repo root, run `Rscript Wei_etal_2019/Wei_etal_2019_DK114_snapshot.R`
to check the frozen source, then
`Rscript Wei_etal_2019/Wei_etal_2019_DK114.R` to rebuild the 114-row
analysis CSV. The CSV retains parcel order, author network labels, and the
exact deposited expansion decimal strings alongside numeric ratios. The
measure is a human-to-chimpanzee cortical expansion value, not a measurement
of one species; the single `Species` field is deliberately blank. The paper's
Methods state 29 adult chimpanzees and 50 adult humans were analyzed.

The source CSV, DOI paper, checksum, and output columns were checked on
2026-11-26. No human visual signoff is claimed. A proposed main-registry row
is in `Wei_etal_2019_DK114_registry_row.xlsx`; the public TSV awaits owner
registration. The separate Julich table in `derived_julich_v31/` is a later
regional aggregation and is not part of this source item.

**2026-11-26 completion:** The main-registry descriptor now matches `DK114`.
Running `Rscript --vanilla Wei_etal_2019/Wei_etal_2019_DK114.R` wrote
`__Public/comparative-data/10.1038%2Fs41467-019-12764-8_DK114.tsv`; all
114 parsed rows match the local CSV. Human source signoff remains pending.
