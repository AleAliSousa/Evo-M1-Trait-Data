# DeCasien & Higham 2019 — reference key for the Brain Region Data compilation codes

DeCasien, A. R., & Higham, J. P. (2019). Primate mosaic brain evolution reflects selection on sensory
and cognitive specialization. *Nature Ecology & Evolution*, 3, 1483-1493. doi:10.1038/s41559-019-0969-0

A reference key resolving the numeric `References` codes used in the `References` column of the
sibling item `DeCasien_Higham_2019_BrainRegionDatamm3` (worksheet "Brain Region Data (mm3)" of
`41559_2019_969_MOESM3_ESM.xlsx`) to the bibliography entries they identify.

## What we built
The folder had an already-built CSV (18 rows) and a working `.R` script, but no public TSV, README, or
definitions file. Now completed to convention:

- **Source:** the article's own bibliography, extracted from `DeCasien-2019-Primate mosaic brain
  evolution r.pdf`. This item has no separate frozen-source file of its own — the citations are
  extracted directly from the article PDF, cross-checked against the reference codes actually cited in
  the supplementary spreadsheet.
- **Build:** `DeCasien_Higham_2019_referencesbraindata.R` reads the `References` column of the
  supplementary spreadsheet's "Brain Region Data (mm3)" sheet, expands any printed ranges (e.g.
  "51-52") into individual reference numbers, extracts the numbered bibliography from the article PDF,
  and writes one row per distinct reference number actually cited (deduplicated, sorted ascending):
  - `DeCasien_Higham_2019_referencesbraindata.csv` (18 rows)
  - `__Public/comparative-data/10.1038%2Fs41559-019-0969-0_referencesbraindata.tsv` (public,
    DOI-encoded, added now — matches the registry's `Item encoded`)
- **Definitions:** `reference_tables/DeCasien_Higham_2019_referencesbraindata_definitions.csv` (added
  now).

## Data role
**Secondary (reference/lookup table).** Not merge-worthy data in itself — it exists to resolve the
`References` column of `DeCasien_Higham_2019_BrainRegionDatamm3`, per the house rule that per-row
source citations should be extracted item-scoped and join-ready rather than left as bare numbers.

## Scope note
This resolves only the reference numbers cited by the `References` column of `BrainRegionDatamm3`. It
does not cover the separate replacement-note codes (A-F) documented by the sibling item
`DeCasien_Higham_2019_BrainRegionDataNotes`, which is an unrelated lettered-code lookup for a different
purpose (data-quality/replacement flags, not source citations).

## Checks
- 18 rows, one per distinct reference number cited in the "Brain Region Data (mm3)" sheet's
  `References` column (build script errors if any cited number cannot be matched in the extracted
  bibliography).
- Citation text transcribed from the article's own numbered bibliography (pages 9-11 of the PDF).

## Extraction / build record
The CSV and R script were already in place and working (the R script itself documents a prior
locale/encoding fix for a non-ASCII citation, ref. 59). The public TSV, this README, and the definitions
file were added by Microsoft Copilot (AI assistant) on 2026-09-25, reproducing the R script's tab-write
step in Python (no R runtime available in this container) directly from the existing, already-built
CSV. No values were re-transcribed or changed.
