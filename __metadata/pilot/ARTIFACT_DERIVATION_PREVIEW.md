# Artifact catalog derivation preview

This report compares `artifacts.csv` with the new per-folder and shared file
registries by stable ID and exact path. The preview does not modify the
legacy catalog or its field routes.

Matched 267 paper/public artifact rows and 21 shared/global rows.
Legacy shared/global rows absent from the new active file registry: brain-mass-merge, behaviour-observations, behaviour-selected.

| Legacy field or candidate derivation | Paper/public exact | Shared/global exact |
| --- | ---: | ---: |
| `id_exact` | 267/267 | 21/24 |
| `path_exact` | 267/267 | 21/24 |
| `storage_zone_from_path_exact` | 264/267 | 0/0 |
| `registration_from_item_exact` | 267/267 | 21/21 |
| `owner_item_direct_exact` | 266/267 | 21/21 |
| `artifact_kind_direct_exact` | 115/267 | 0/21 |
| `authority_stage_direct_exact` | 137/267 | 15/21 |
| `granularity_direct_exact` | 19/267 | 15/21 |
| `producer_direct_exact` | 96/267 | 19/21 |
| `note_exact` | 146/267 | 0/21 |

## Migration interpretation

`artifact_id`, `path`, and `storage_zone` can be derived losslessly for
paper/public artifacts when the counts above are exact. `registration_status`
can be derived by joining the live pilot item public TSV paths, independent
of `file_role`. `owner_item` should be compared with the new `item_id`; a
difference may reflect a newly explicit relationship rather than an error.
The current owner-item exception is `kaufman-reference-lookup`: the old catalog assigns
Kaufman's shared A1–A14 citation lookup to A3 alone; the new file registry
correctly leaves its single-owner field blank.

Do not silently equate `artifact_kind` with `file_role`, `authority_stage`
with `authority_status`, `granularity` with `record_grain`, or the legacy
free-text `producer` with `producer_id`. These fields have different
vocabularies or purposes. Use an explicit translation, retain a small
exception overlay, or update catalog consumers to query the new names.
The `note` is editorial text and may legitimately differ; keep a chosen
single source of truth instead of copying both versions.
Even `(file_role, content_role)` leaves 2 ambiguous artifact-kind
groups affecting 8 rows. `(stage, authority_status, file_role)`
leaves 3 ambiguous authority-stage groups affecting 38 rows.
`(record_grain, content_role)` leaves 6 ambiguous legacy-grain
groups affecting 81 rows. These are real distinctions in the old
vocabulary, not values that a direct rename can recover.

The shared/global artifacts present in `shared_pipeline_files.csv` can be
derived there. The three missing `__merging_*` outputs are intentionally
excluded from the active no-merge registry and remain legacy audit rows.
Paper/public rows can come from the ten `pipeline_files.csv` files.
Once field routes are checked against the derived IDs, `artifacts.csv` can become
a generated compatibility export rather than a hand-maintained registry.
