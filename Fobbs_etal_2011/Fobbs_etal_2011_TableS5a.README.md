# Fobbs et al. 2011 — Comparative brain sections catalog, cyclostomes through mammals

Fobbs, A. J., Jr., & Johnson, J. I. (2011). Brain collections at the National Museum of Health and Medicine. *Annals of the New York Academy of Sciences*, 1225 Suppl 1(S1), E20-E29. doi:10.1111/j.1749-6632.2011.06036.x

Supplementary **Fobbs_etal_2011_TableS5a** — the largest of the seven catalogs: specimen number, species/common name, material, stain, plane, section thickness, and slide/section counts, grouped by collection (e.g. CYCLOSTOMES).

## What we built
The folder had the legacy Word supplement, a built snapshot/CSV/R script, but no README or definitions
(none of the seven Fobbs supplementary tables had either).

- **Frozen source (printed/legacy, snapshot required):** `nyas_6036_sm_table5a.doc` is a legacy journal Word
  document (not a structured, machine-readable export), so a frozen snapshot is required per
  `__HOWTO_build_a_dataset_file.md` §0a invariant 1. `Fobbs_etal_2011_TableS5a_snapshot.py` converts it
  losslessly into `Fobbs_etal_2011_TableS5a_snapshot.xlsx` (sheet `TableS5a`); the snapshot is **not** rebuilt on every
  run (the `.R` script only reads it) so the already-audited snapshot is protected
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

**Update 2026-11-12 (script now reproduces the committed files).** The correction above was first a hand
patch. `Fobbs_etal_2011_TableS5a.R` now carries it as an explicit `species_fix` table keyed on the exact
printed string (6 strings, 10 rows; the script stops if a key does not match the expected number of rows), so a rerun
reproduces the committed CSV and public TSV byte-for-byte (checked in a temporary mini-repo against
`git show HEAD:` of both files; every other column, row and the other six Fobbs items are unchanged).
What the 10 rows (`source_row` 87, 90–95, 98, 197, 296) show:

| printed `species` | `species` now | `continuation_note` |
|---|---|---|
| `Chelhydra serpentina (6 day)` (×3), `(1 day)` (×1), `(3 day)` (×3) | `Chelydra serpentina` | `(6 day)`, `(1 day)`, `(3 day)` |
| `Sternotherus odoratus-9 cm.` | `Sternotherus odoratus` | `(9 cm.)` |
| `A. mississippiensis-25cm` | `Alligator mississippiensis` | `(25cm)` |
| `Columba livia 1 day` | `Columba livia` | `(1 day)` |

The qualifier text is the printed text (punctuation normalised into parentheses); no numeric value, specimen
number or other column was touched. Two corrections go beyond splitting the qualifier and are the curators'
choices, recorded here (typo / abbreviation, not a change of value):
- **Genus typo `Chelhydra` → `Chelydra`** is made only on the 7 snapping-turtle rows that carry a qualifier. The
  typo is in the *source*: the 4 snapping-turtle rows without a qualifier (`source_row` 86, 88, 89, 96) still print
  the source spelling `Chelhydra serpentina` in the CSV/TSV, so the file is inconsistent within the species.
  **needs_owner:** correct those 4 rows too (then the committed CSV/TSV change and downstream keys need a look),
  or keep the source spelling everywhere?
- **`A. mississippiensis` → `Alligator mississippiensis`** expands the abbreviation to the full binomial printed on
  the 12 neighbouring American Alligator rows.

## Table checks
None: the catalog prints no totals or other relation that can be recomputed from its cells (nothing to check).
No cross-item check (`internal_checks/`) applies.

## Snapshot script
`Fobbs_etal_2011_TableS5a_snapshot.py` stays in Python: it needs LibreOffice (`soffice`) to convert the legacy
`.doc` to `.docx`, which cannot be run or verified in the agent sandbox; the owner can run it locally.
A possible R port (soffice call + officer/xml2 + openxlsx) is left for after the owner confirms `soffice` works locally.
