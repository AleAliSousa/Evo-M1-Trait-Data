# Reference-chain resolution (C → B → A)

Script: `_tools/dataset_builder/resolve_reference_chains.py` (Python 3, pandas, networkx, openpyxl).

```bash
# once: the macOS system python3 has no pandas
python3 -m pip install --user -r _tools/dataset_builder/reference_chains/requirements.txt

python3 _tools/dataset_builder/resolve_reference_chains.py   # any cwd; repo root is found from the script's location
```

It builds a paper-level citation graph — `Secondary_Ref` cites `Target_Ref` for data — and resolves
every link to its terminal (root empirical) reference. Nodes use the folder-name convention
(`Surname__Year`, `A_B_Year`, `A_etal_Year`). It reads, never writes, the paper folders.

**Edge sources**: every paper's `*reference*.csv` list (12 schemas normalised); the `reprints` /
`derives_from` rows of `_keys/source_relationships.csv` (`direction = none` rows are siblings of a
common primary and give no edge); the citing table's own `reference_level` (Kaufman 2004,
Karbowski 2007). **Node role**: `__ReadMe.xlsx` → `Data role (primary/secondary/both)`; a
self-citation ("present report") marks the paper primary.

**Caveat** — paper-level only: C → B → A says C cites B for data and B cites A, not that a given cell
travelled that path. Cell-level provenance is the job of the `*_refs_check` pipelines.

## Outputs

`out/` (regenerated every run):

| file | content |
|---|---|
| `citation_edges.csv` | one row per (Secondary_Ref, Target_Ref): `Resolution_Level`, `match_status`, evidence |
| `root_resolution.csv` | per link: `Primary_Ref_Terminal`, in-repo roots, n external roots, deepest path, `root_status` |
| `terminal_lookup.csv` | per intermediate node: every terminal root with hop count and path |
| `node_table.csv` | per node: in_repo, registry role, degrees, node class |
| `review_queue_all_priorities.csv` | P1/P2/P3 incl. the ~20k external roots trusted as primary (P3) |
| `run_summary.json` | counts, cycles, skipped files |

`Resolution_Level`: `Intermediate` (target in repo and cites further) · `Terminal` (target in repo,
primary) · `Terminal_unverified` (target in repo but role secondary/blank, or declared secondary by
the citing table) · `Terminal_external` (identified, not in repo; primary status unchecked) ·
`Orphan` (unparseable, abbreviated without bibliography entry, p.c., in prep.) · `Ambiguous`
(several repo folders) · `Cycle`.

## Review queue → errata

`findings/REVIEW_QUEUE.csv` uses the `*_refs_check` schema (`row_id`, `queue`, `paper_folder`, `pdf`,
`item`, `variable`, `locator`, …, `queue_key`, `resolution`, `resolved_to`, `resolution_evidence`,
`resolution_date`), so `queue_to_errata_rows()` / `append_errata()` / `render_errata()` (skill
`evom1-errata-convention`) work on it unchanged. P3 rows are not queued.

| queue | means | worked by | errata? |
|---|---|---|---|
| **R** | root unresolved: orphan, ambiguous, cycle, cited source declared secondary | open the citing paper's reference list | **yes** — PDF prints an unresolvable/abbreviated citation → `publication_ambiguity` (status *proposed*); the PDF has the entry but the repo list lacks it → fix the item's build `.R`, `repo_transcription_error_fixed` (errata row is the changelog) |
| **M** | repo match by surname+year or title only | confirm the folder | never — `match_confirmed` / `match_rejected` with `resolved_to = <folder or external key>`; the next run applies it as a matcher override |
| **K** | chain ends at a repo item with blank/secondary registry role | set `Data role` in `__ReadMe.xlsx` | never — `registry_updated` |

Decisions go in `findings/REVIEW_QUEUE_resolutions.csv` (`queue_key, resolution, resolved_to,
evidence, date`), joined back on every run. Vocabulary: `repo_transcription_error_fixed`,
`publication_ambiguity`, `publication_error`, `match_confirmed`, `match_rejected`,
`registry_updated`, `relationship_declared` (cycle: add/repair a `_keys/source_relationships.csv`
row), `not_an_error`, `deferred`. An unknown value, a duplicated key or a malformed match key stops
the run. Resolutions whose row has disappeared (fixed upstream) are written to
`REVIEW_QUEUE_resolutions_stale.csv`.

`queue_key` = `queue | paper_folder | reference file | ref_key | Target_Ref`. A match override is keyed
on the middle three, so it survives the target changing.

Rule kept from the errata convention: evidence names the page; reporting, not repairing — the
queue changes no value anywhere.
