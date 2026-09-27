# Cross-source consistency audit: Zilles, Fobbs, Frahm, Bush-Allman registration

## Row counts (computed from specimen_crosswalk.csv on disk)

- Baseline before this project: 390 rows
- Final: 3123 rows (net +2733)
- Rows mentioning Frahm (any column): 15
- Rows mentioning Bush (any column): 1
- Rows with source_publication = Zilles_etal_2011: 415
- Rows with source_publication = Fobbs_etal_2011: 2303

## Duplicate scan (final)

Exact-duplicate rows remaining (canonical_specimen + item_reference + printed_name + note, all four matching): 0

An earlier pass in this project mistakenly collapsed 10 Fobbs TableS5a row-pairs as
"exact duplicates" using a dedup key that omitted the `note` column. Those 10 pairs
are deliberate: the same catalog accession (e.g. specimen_number 696) printed on two
different TableS5a source rows, one of which (HC-696) is a verified taxon_conflict
record (ELASMOBRANCHS vs MAMMALS clade heading for the same accession). All 10 rows
were restored from git history (commit ce01c9a) and are counted as 0 exact duplicates
above, confirmed against the `note` column.

## New taxon concepts

1 new taxon concept(s) added: ['Colobus badius (s.l.)']

## New collection groups

['JOHNSON_MSU', 'MEYER_PHIPPS_JHU', 'CROSBY_UMICH']

## Sources

- _keys/specimen_crosswalk/specimen_crosswalk.csv
- _keys/specimen_crosswalk/taxon_concept_registry.csv
- _keys/collection_registry.csv
- Per-source provenance audits: zilles_provenance_audit.csv, fobbs_provenance_audit.csv,
  frahm_provenance_audit.csv (restricted), bush_allman_afip_provenance_audit.csv (restricted)
