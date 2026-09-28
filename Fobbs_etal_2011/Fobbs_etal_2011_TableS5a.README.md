# Fobbs et al. 2011 — Comparative brain sections catalog, cyclostomes through mammals

Fobbs, A. J., Jr., & Johnson, J. I. (2011). Brain collections at the National Museum of Health and Medicine. *Annals of the New York Academy of Sciences*, 1225 Suppl 1(S1), E20-E29. doi:10.1111/j.1749-6632.2011.06036.x

Supplementary **Fobbs_etal_2011_TableS5a** — the largest of the seven catalogs: specimen number, species/common name, material, stain, plane, section thickness, and slide/section counts, grouped by collection (e.g. CYCLOSTOMES).

## What we built
The folder had the legacy Word supplement, a built snapshot/CSV/R script, but no README or definitions
(none of the seven Fobbs supplementary tables had either).

- **Frozen source (printed/legacy, snapshot required):** `nyas_6036_sm_table5a.doc` is a legacy journal Word
  document (not a structured, machine-readable export), so a frozen snapshot is required per
  `__HOWTO_build_a_dataset_file.md` §0a invariant 1. `Fobbs_etal_2011_build_snapshot.py` converts it
  losslessly into `Fobbs_etal_2011_TableS5a_snapshot.xlsx` (sheet `TableS5a`); the snapshot is **not** rebuilt on every
  run (`rebuild_snapshot = FALSE` in the `.R` script) so the already-audited snapshot is protected
  from silent drift.
- **Reformat:** `Fobbs_etal_2011_TableS5a.R` reads the frozen snapshot by position, hard-checks the expected column
  count, assigns house-dialect column names, drops rows that are wholly blank or are printed
  section-label rows rather than specimen records, and adds a build-only `source_row` sequence
  column. Writes:
  - `Fobbs_etal_2011_TableS5a.csv` (analysis-ready, 739 catalog records)
  - `__Public/comparative-data/10.1111%2Fj.1749-6632.2011.06036.x_TableS5a.tsv` (public,
    DOI-encoded, already present — matches the registry's `Item encoded`)
- **Definitions:** `reference_tables/Fobbs_etal_2011_TableS5a_definitions.csv` (added now).

## Data role
**Primary.** This is the museum's own specimen/collection catalog (not a compiled secondary
dataset) — animal numbers, sectioning details, and slide/section counts as recorded by the
collection itself.

## Species / taxonomic scope
This is a multi-taxon museum catalog, not a single-species table: species/common names vary row by
row (see the `Structure`-less `info` columns in the definitions file for the printed name fields).
Historical nomenclature and specimen wording are preserved verbatim; no taxonomy modernization or
project `species_key.csv` mapping was applied, consistent with the build script's own stated intent
("source wording and historical nomenclature are preserved; taxonomy is not modernized").

## Checks
- Analysis CSV = 739 catalog records (printed section-label and wholly-blank rows removed by the
  build, not by this documentation pass).
- No independent curated copy exists to audit against (first-party museum catalog) — no
  `comparison/` step applies (§7).

## Extraction / build record
The snapshot, reformat script, CSV, and public TSV were already in place and working. This README
and the definitions file were added by Microsoft Copilot (AI assistant) on 2026-09-25, reading the
existing `.R` script and CSV to document the pipeline. No values were re-transcribed or changed.

## Post-build correction (Phase-1 species-metadata fix)
An audit found 10 rows (specimen_number 81, 84–89, 92, 191, 287) where an age or body-size
qualifier was baked directly into the printed `species` cell (e.g. `Chelhydra serpentina (6 day)`,
`Sternotherus odoratus-9 cm.`, `A. mississippiensis-25cm`, `Columba livia 1 day`), plus one
misspelled genus (`Chelhydra` for `Chelydra`). These strings were propagating verbatim into
`_keys/specimen_crosswalk/specimen_crosswalk.csv`'s `resolved_taxon`/`published_taxon`, where they
surfaced as fake species in downstream taxon filters.

Microsoft Copilot (AI assistant) hand-patched `Fobbs_etal_2011_TableS5a.csv` and the mirrored
`__Public/comparative-data/10.1111%2Fj.1749-6632.2011.06036.x_TableS5a.tsv` on 2026-09-27: `species`
was reduced to the bare, correctly spelled binomial for these 10 rows, and the original qualifier
was moved verbatim into `continuation_note` (the same column already used elsewhere in this file
for printed age/size annotations, e.g. the `Gallus domesticus (10 day embry.)` rows). The matching
`specimen_crosswalk.csv` rows for these specimens were corrected the same way, appending an
explanatory note rather than deleting the original printed-value record.

This was a targeted, hand-applied correction, not a script change: `Fobbs_etal_2011_TableS5a.R`
only splits a continuation note when it was printed on its own row in the source document, so it
would not have caught these in-cell suffixes on a rerun. If the frozen snapshot is ever rebuilt or
the CSV regenerated from `Fobbs_etal_2011_TableS5a.R`, this same set of 10 rows will need the fix
reapplied.
