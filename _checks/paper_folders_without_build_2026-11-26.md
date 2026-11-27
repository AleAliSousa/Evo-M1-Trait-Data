# Paper folders with source files but no item build — 2026-11-26

**Historical snapshot, superseded later on 2026-11-26.** Krubitzer et al. 1995 and Nunn et al. 2001 have since moved to `_SOURCE_DISPOSITION/`; Krubitzer's matching Flatmap project already has provisional measurements. Westergaard & Hyatt Figures 1–2 have since been built. For current exact registry/file counts and source decisions, use `registry_file_balance_2026-11-26.md` and `three_unbuilt_sources_2026-11-26.md`.

Current top-level folder scan after source triage. A folder counts here when it has a top-level PDF/document/spreadsheet/archive/image source but no top-level analysis CSV or item R reader. Snapshots, source audits, reference tables, and nested derived data do not count as an item build. This inventory does not mean every remaining source should be built.

**Six folders** meet that definition after the Chapelain, Cordain, and Hopkins
builds and removal of byte-identical Harlow and Phillips source duplicates.
**Two** have main-registry HOLD rows, and **four** have none. Eighteen prior whole-source
skips or out-of-scope papers were moved into `_SOURCE_DISPOSITION/`; McIlwain
1956 was added there after this triage.

| Folder | Registry items | Status / next action |
|---|---|---|
| `GonzálezLagos_etal_2010` | — | Article data not deposited; a later descendant dataset is built separately. |
| `Hawrylycz_etal_2012` | — | Processed expression matrix exists outside this repo; no registered paper item here. |
| `Jacobs_Williams_2001` | — | Source review found no separable species-trait rows; source retrieval remains open. |
| `Krubitzer_etal_1995` | — | Source only; future flatmap digitization would be a separate item. |
| `Nunn_etal_2001` | Nunn_etal_2001_NoDatasetItem | Registered HOLD; resolve source and measurement overlap first. |
| `Westergaard_Hyatt_1994` | Westergaard_Hyatt_1994_Figure1; Westergaard_Hyatt_1994_Figure2 | Two registered figures on HOLD until a specific measurement gap is shown. |

Source filenames and staging matches are in `paper_folders_without_build_2026-11-26.csv`.
The new Chapelain (Tables 4–6), Hopkins (Tables 1–2), and Cordain (Tables 2–3)
items have analysis CSVs and proposed registry rows. The Harlow source was an
identical PDF copy of the already built `Harlow_etal_1932` paper. The Phillips
source was an identical copy of the already built `Phillips_Sherwood_2007_a`
paper. Both redundant folders were removed after SHA-256 comparison.

Nunn and Westergaard remain registered **HOLD** entries rather than queued
builds. The González-Lagos source lacks the underlying dataset; Hawrylycz's
processed expression matrix is held outside this repository; Jacobs & Williams
has an active source/measurement gap; and Krubitzer needs a separate measured
flatmap item. These are active source or scope decisions, not automatic
recommendations to extract a table from each PDF.
