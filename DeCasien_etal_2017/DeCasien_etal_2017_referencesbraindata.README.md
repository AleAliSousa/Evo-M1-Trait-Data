# DeCasien, Williams & Higham 2017 — reference key for the Brain Data compilation codes

DeCasien, A. R., Williams, S. A., & Higham, J. P. (2017). Primate brain size is predicted by diet
but not sociality. *Nature Ecology & Evolution*, 1, 0112. doi:10.1038/s41559-017-0112

A small, hand-built reference key resolving the two numeric `Reference` codes (47, 48) used by the
`Reference` column of the sibling item `DeCasien_etal_2017_BrainData` (worksheet "Brain Data" of
`41559_2017_BFs415590170112_MOESM250_ESM.xls`) to the compilation sources they identify.

## What we built
The folder had only an already-built CSV and a working `.R` script (no README, no definitions). Now
documented to convention:

- **Source:** the article's own bibliography, `DeCasien-2017-Primate brain size i.pdf`. This item
  has no separate frozen-source file of its own — it is a small hand-built lookup, sourced by the
  build script directly from the two matching bibliography entries.
- **Build:** `DeCasien_etal_2017_referencesbraindata.R` hard-codes the two resolved citations as an
  explicit table (not extracted at run time), records **both** numbering schemes — the workbook's
  internal `ref_number` (47/48, as printed in Brain Data's `Reference` column) and the article's own
  bibliography `article_ref_number` (48/49) for the same two works — and writes:
  - `DeCasien_etal_2017_referencesbraindata.csv` (2 rows)
  - `__Public/comparative-data/10.1038%2Fs41559-017-0112_referencesbraindata.tsv` (public,
    DOI-encoded, already present — matches the registry's `Item encoded`)
- **Definitions:** `reference_tables/DeCasien_etal_2017_referencesbraindata_definitions.csv` (added
  now).

## Data role
**Secondary (reference/lookup table).** Not merge-worthy data in itself — it exists to resolve the
`Reference` column of `DeCasien_etal_2017_BrainData`, per the house rule that per-row source
citations should be extracted item-scoped and join-ready rather than left as bare numbers.

## Scope note
This resolves only the **two compilation-level** references (Boddy et al. 2012; Isler et al. 2008)
that `BrainData`'s `Reference` column cites. `BrainData`'s own `Source` column additionally names the
underlying **primary** literature for each measurement (e.g. "Spitzka 1903", "Sherwood") — those are
not resolved here, since DeCasien et al. 2017 do not republish full citations for them.

## Checks
- 2 rows, `ref_number` hard-checked as exactly `{47, 48}` in the build script.
- Citation text transcribed verbatim from the article's own bibliography.

## Extraction / build record
The CSV and public TSV were already in place and working. This README and the definitions file were
added by Microsoft Copilot (AI assistant) on 2026-09-25, reading the existing `.R` script and source
PDF bibliography to document the pipeline. No values were re-transcribed or changed.
