# EndNote gap search — September 2026

One-off search for papers in the EndNote library that carry species-level
comparative data but are not yet in the Evo-M1 merge.

| File | Role |
|---|---|
| `gap_scan.py` | lists EndNote papers in the data-bearing groups that are not in the merge (DOI match, then first author + year) |
| `score_gaps.py` | ranks those papers by how likely they carry species-level trait data, from EndNote's extracted text |
| `inspect_tables.py` | for one reference id, prints table captions and lines that look like species data rows |

Status: finished. The scripts read the EndNote database directly;
`inspect_tables.py` hard-codes a database path from an old session and will not
run as-is. Already excluded from `_run_all_scripts_v3.py`; the sweep skips `_archive/`.
Moved here from `_checks/` on 2026-11-11.
