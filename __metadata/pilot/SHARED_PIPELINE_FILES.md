# Shared pilot file registry

`shared_pipeline_files.csv` registers the files used or created by the active
ten-paper run outside the paper folders. It uses the same file-level schema as
each paper folder's `pipeline_files.csv`. `shared_pipeline_dependencies.csv`
records confirmed input relationships by stable file ID. The paper-folder
registries own their local sources, builders, public TSVs, and supporting
metadata; shared IDs do not duplicate those file rows.

The active `run_pilot.R` path builds a metadata catalog, validates folder
resources, prepares qualification reports, emits the assertion audit, makes
source choices, and runs checks. The shared registry covers its scripts,
configuration, generated CSVs and SQLite databases, and explanatory
documentation. It also registers the live `__ReadMe.xlsx`, the prebuilt
`__measurements/measurements.sqlite` input, that inventory's builder and
three configuration files, plus the non-merge project keys and curation
tables catalogued for this pilot. `producer_id` points to the script that
creates a generated output; a blank producer means the file is authored or
maintained, not silently generated. `authority_status` describes the file's
role in the workflow, not approval of every claim it contains.

The dependency table uses `reads` for direct inputs, `validates_against` for
files whose cells or keys are checked by the assertion audit, and
`derives_from` for content derived from the in-memory qualified point table
in the same R build. It does not claim that two CSVs from one script read one
another. The full inventory builder scans every public TSV in the repository,
beyond this ten-paper pilot; its per-item TSV dependencies are not enumerated
here. Paper-local field routes remain in `field_routes.csv`; the combined file
registry checks their active file IDs, while `catalog.sqlite` retains the
field-to-file joins.

The current seven-step run uses `build_pilot.R --qualification-only`, which
stops before the legacy merge audits. Therefore the existing
`__measurements/pilot_metadata/pilot_metadata.sqlite`,
`behavior_preference_audit.csv`, `mixed_team_audit.csv`,
`primary_preference_audit.csv`, and `selection_examples.csv` are excluded from
the active file registry. They are outputs of a different path and must not
be read as current pilot results. Stray `pilot_sources_*.sqlite` files in
`pilot_single_pipeline` are interrupted temporary build files, not pipeline
resources. `.gitignore` is repository plumbing and is likewise excluded.
Generated SQLite files are ignored by Git but remain registered and are
recreated by the R builders.

The one-time `register_pipeline_files.py` migration helper and the artifact
derivation preview script, CSV, and Markdown report are registered as
`ancillary`. They document and test the transition from the old artifact
catalog but are not inputs to the seven-step pilot. The definition row-type
builder and CSV are also ancillary migration aids. The definition schema and
folder-omission audits are active documentation for this file contract.
`shared_pipeline_exclusions.csv` lists the few physical files that the
combined-registry coverage scan deliberately omits, with a reason for each.
