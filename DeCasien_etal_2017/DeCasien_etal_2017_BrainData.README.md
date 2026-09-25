# DeCasien, Williams & Higham 2017 — Brain Data (supplementary workbook)

DeCasien, A. R., Williams, S. A., & Higham, J. P. (2017). Primate brain size is predicted by diet
but not sociality. *Nature Ecology & Evolution*, 1, 0112. doi:10.1038/s41559-017-0112

Supplementary workbook `41559_2017_BFs415590170112_MOESM250_ESM.xls`, worksheet **"Brain Data"**:
a species/specimen-level compilation of brain volume, brain mass, body mass, and sample metadata
across primates, **838 rows**.

## What we built
The folder had only the raw supplementary workbook, an already-built CSV, and an already-working
`.R` script (no README, no definitions). Now documented to convention:

- **Frozen source (digital-native, no snapshot):** `41559_2017_BFs415590170112_MOESM250_ESM.xls`
  (worksheet "Brain Data") is a journal-supplied, machine-readable workbook — it **is** the frozen
  source, kept verbatim (see `__HOWTO_build_a_dataset_file.md` §0a invariant 1).
- **Reformat:** `DeCasien_etal_2017_BrainData.R` reads the worksheet directly by its 16 expected
  column headers (hard-checked against a literal list — the script aborts if the workbook's headers
  ever change), keeps only rows with a non-blank `KEY` (the workbook's own taxon identifier — this
  drops empty formatting rows only), parses the numeric columns, and writes:
  - `DeCasien_etal_2017_BrainData.csv` (analysis-ready, 838 rows × 16 columns)
  - `__Public/comparative-data/10.1038%2Fs41559-017-0112_BrainData.tsv` (public, DOI-encoded, already
    present — matches the registry's `Item encoded`)
- **Definitions:** `reference_tables/DeCasien_etal_2017_BrainData_definitions.csv` (added now).
- The script also hard-checks the row count (838) and the two in-use `Reference` codes (47, 48) on
  every run, so a silently-changed source workbook would fail loudly rather than build wrong data.

## Data role
**Secondary (compilation).** Every brain/body value is drawn from one of two named compilations —
Boddy et al. (2012) and Isler et al. (2008) — via the `Reference` column (47/48). The per-row
`Source` column additionally names the underlying primary literature the compilation itself drew
from (e.g. "Spitzka 1903", "Sherwood"), but those primary citations are not republished by DeCasien
et al. 2017 in a form this build could transcribe.

## Species names
`KEY` (Genus_species, underscore-joined) is the workbook's own taxon identifier and is present on
every row; `Genus`/`Species` are additionally split out where the workbook itself provided them
(blank on 169 rows where only `KEY` carries the taxon). No project `species_key.csv` harmonisation
was applied — this is a large secondary compilation already using its own consistent naming, not a
printed table needing transcription-driven name cleanup.

## Quality caveats (from the source)
- 691 of 838 rows are attributed to Reference 47 (Boddy et al. 2012) and 147 to Reference 48 (Isler
  et al. 2008) — see the sibling `DeCasien_etal_2017_referencesbraindata` item for the resolved
  citations (note the workbook's internal numbering, 47/48, differs from the article's own
  bibliography numbering, 48/49, for the same two works).
- Most numeric columns are sparse by design (e.g. `BV SD` populated on only 11 rows, `BM SD`/`Body
  SD` on 35) — this reflects what the compilation itself reports, not an extraction gap.
- `Genus`/`Species` are blank on 169 rows; `KEY` still carries the taxon on every row.

## Checks
- Analysis CSV = 838 rows (workbook's own row count, hard-checked in the R script itself), no
  accidental empty columns.
- Reference codes hard-checked as exactly `{47, 48}` on every run.
- No independent curated copy exists to audit against (first-party compilation, digital-native
  source) — no `comparison/` step applies (§7).

## Extraction / build record
The frozen workbook, reformat script, CSV, and public TSV were already in place and working. This
README and the definitions file were added by Microsoft Copilot (AI assistant) on 2026-09-25,
reading the existing `.R` script and the source workbook/CSV to document the pipeline. No values
were re-transcribed or changed.
