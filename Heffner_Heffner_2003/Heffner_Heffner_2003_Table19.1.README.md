# Heffner & Heffner (2003), Table 19.1

**Stage: BUILT (Python parity QA; clean R, owner registration and public TSV pending). Not FINISHED.**

## Source → snapshot

Heffner, H. E., & Heffner, R. S. (2003). *Audition*. In *Handbook of Research Methods in Experimental Psychology*, Chapter 19, pp. 413–440. The supplied cover (PDF page 1, library delivery cover sheet) confirms **ISBN 9780631226499**. Proposed registry override: `ISBN:9780631226499`; this is not authority for a public filename.

Only printed **Table 19.1, p. 422 (PDF page 11)** is built: “Sound localization acuity and use of binaural cues in mammals”. It contains 37 printed common-name rows and four columns: Species / Midline acuity / Binaural phase cue / Binaural intensity cue.

Source: `HeffnerHeffner2003.pdf`, retained unchanged. Local `HeffnerHeffner2003.source.txt` is the pre-existing pdftotext-layout source layer, also unchanged; it is not the frozen table snapshot. The shared source PDF is at:
https://alleninstitute.sharepoint.com/sites/MammalianM1/Shared%20Documents/General/Species/Evo-M1-Trait-Data/Heffner_Heffner_2003/HeffnerHeffner2003.pdf

**Reader and date:** AI assistant, 2026-10-10, via `Heffner_Heffner_2003_Table19.1_extract_snapshot.py`. The helper runs `pdftotext -layout` against the actual PDF, captures its table rows (no measurement literals in the helper), compares with the saved text layer if present, and writes the snapshot before analysis. It refuses to overwrite a differing frozen copy. AI visual verification compared all 37 × 4 printed data cells, caption, column order/headings and three footnotes with the rendered PDF page, plus the cover ISBN. No human sign-off or independent curated comparison is claimed.

`Heffner_Heffner_2003_Table19.1_snapshot.csv` is the frozen evidence: caption first, exact four printed headings next, 37 rows in print order, then the three exact table notes. UTF-8 preserves degree signs, em dashes, `*`/`**`, and the curly apostrophe in `Merriam’s kangaroo rat`. CSV flattens the typographic superscripts but retains their attached marks and meaning. Preserve printed **Harbor seal**, **African pigmy hedgehog**, **Black-tailed Prairie dog**, and every other original common name; do not silently respell them.

The table notes are retained verbatim:

- Dashes indicate no data.
- * Unable to use binaural intensity cue in the upper octaves of its hearing range.
- ** Localization tested with clicks. For all other animals, the stimulus was broadband noise.

## Snapshot → analysis

`Heffner_Heffner_2003_Table19.1.R` is self-locating (Rscript, source(), or active RStudio script), derives related names from its filename, and **reads the frozen snapshot**. It never defines table values inline. The analysis CSV has 37 rows and 16 explicitly defined columns; original tokens survive alongside numeric degrees and cue-use indicators. A degree mark is removed for numeric parsing, not converted to radians. Cue `yes` → 1, `no` → 0, dash → missing (empty CSV cell). `yes*` → 1 plus a separate upper-octave caveat flag and verbatim note: do not interpret this as an ability at all frequencies.

`click_stimulus_flag` applies to Sea lion and Merriam’s kangaroo rat; their stimulus is `clicks`, versus `broadband noise` for the other 35 rows. `intensity_upper_octaves_caveat_flag` applies to Indian elephant and Domestic goat. An absent mark means only that the table did not print that caveat; it is not proof of unrestricted frequency use. There are 10 missing phase-cue and 10 missing intensity-cue observations, not ten `no` values.

The ten-column dictionary is `reference_tables/Heffner_Heffner_2003_Table19.1_definitions.csv` (16 column definitions plus three `Method:*` notes). Observation level is a **published common-name taxon summary**, not individual animals; broad labels are not assumed to identify a unique scientific species. The table gives no per-row sample sizes, variability or named aggregation statistic. Chapter p. 420 describes minimum audible angle in a left/right discrimination about the midline and a standard 100-ms noise burst; this is contextual method information, **not a verified duration for every compiled study**. Method and observation notes remain outside the faithful snapshot.

**SECONDARY compilation.** Every analysis row is `data_role = secondary`. Keep this item for comparative provenance; do not merge as primary or double-count the earlier experiments. Table 19.1 prints no per-row citation keys, so no invented row-to-bibliography linkage or full-bibliography `references.csv` was created. Earlier source studies must be traced separately before any primary ingestion.

## Species / collection notes

All printed common names survive unchanged in `Species_HeffnerHeffner2003`. No inline common-name-to-binomial guesses or taxonomy edits were made. Proposed additions for the existing collection-scoped `_keys/General/species_key.csv` were supplied in the audit handoff, not applied. Where an existing exact common-name key supplied a unique candidate, that candidate is only a proposal, not confirmation of this chapter’s species identity; unmatched or ambiguous names remain unresolved. Owner collection/taxonomy review is still required.

## QA and reproducibility

Available checks on 2026-10-10:

- Direct PDF capture equals the supplied saved text-layer table; snapshot recreates byte-for-byte on helper rerun.
- AI visual side-by-side check of the actual printed page: 37 rows, four headings and three notes; no discrepancies observed.
- Python parity build from the frozen snapshot: 37 rows × 16 columns; all 148 original data tokens and row order retained; numeric angular degrees and flags checked against printed tokens. Exact ten-column dictionary, complete column coverage, no blank first/index column or all-empty analysis column.
- Original PDF and saved source text SHA-256 unchanged; no comparison directory, Office file, key, merge, root registry or public TSV modified.

**Rscript was unavailable when these files were built.** The CSV was generated with Python implementing the documented R transformations. This is not evidence that R executed, and the clean-R/build/validate tool-layer checks remain **PENDING**.

Extraction (Python 3.9+ and Poppler `pdftotext`, from any directory):

```sh
python Heffner_Heffner_2003_Table19.1_extract_snapshot.py
```

Pending clean-session analysis check (base R; this mode never exports a public TSV):

```sh
Rscript --vanilla Heffner_Heffner_2003_Table19.1.R --analysis-only
```

Compare the R output semantically with the Python CSV (numeric CSV spelling such as `10.0` versus `10` may differ without changing values). The frozen snapshot must remain unchanged.

## Owner registration → online database (pending)

There is **no current registry row** authorising this proposed Item name, `Heffner_Heffner_2003_Table19.1`. The parent handoff contains an owner-paste proposal built from the actual live headers, not a guessed schema. In the current live workbook, Item full original title is **M**, Item name is **J**, Item encoded is **K**, and public TSV match is **L**; A:AN includes Human visual curation at AH and blank AI:AN. Leave sequence B and generated E:L blank. A citation, C confirmed ISBN override, D `Table 19.1`, and descriptive fields are proposed; the workbook remains untouched.

1. Owner pastes the proposed row as values into the first empty Sheet1 row and runs `_tools/file_list.R` to generate Item name / Item encoded. Verify J equals the proposed Item name; K has no trailing underscore and is the sole authority for the public TSV stem.
2. With `readxl` available and current registry saved, run the R script without `--analysis-only`. It reads the current workbook by Item name, requires one valid row with `Data role = secondary`, and only then writes `__Public/comparative-data/<Item encoded>.tsv`. An unregistered item produces only the CSV and an explicit warning. No guessed ISBN-coded TSV or TSV inside the paper folder is permitted.
3. From the repository root, run the canonical audit/dry run/build/validate sequence after registration and export permissions are settled:

```r
source("_tools/dataset_builder/load_dataset_builder.R")
folder <- file.path(repo_root(), "Heffner_Heffner_2003")
audit_dataset_item(folder)
build_dataset_item(folder, "Heffner_Heffner_2003_Table19.1", dry_run = TRUE)
build_dataset_item(folder, "Heffner_Heffner_2003_Table19.1", dry_run = FALSE)
```

Registration, clean R, public TSV existence and registry-filename validation are not passed by this handoff. Do not mark FINISHED until those required checks succeed. No primary merge is appropriate for this compilation.
