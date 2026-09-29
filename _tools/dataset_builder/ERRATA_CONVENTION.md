# Errata convention — one source, three renderings

An **erratum** is a recorded discrepancy about a value in a paper folder: our
transcription differs from the print, the print itself is wrong or ambiguous,
or two publications disagree about the same measurement and we have not
settled which is right. The convention exists so that such a finding is
**obvious wherever the value is used, and changeable when the finding itself
turns out to be wrong** — without anyone editing a README, a definitions file
or a public CSV by hand.

## The one source

```
<Paper>/reference_tables/<Paper>_errata.csv
```

One file per paper folder, one row per discrepancy. Rows are **never
deleted**: a mistaken erratum is *withdrawn* (with a reason) and stays in the
file, so the history is visible and every rendering updates itself.

| column | required | contents |
|---|---|---|
| `errata_id` | yes | `<Paper>-E001`, `-E002`, … unique within the file |
| `item` | yes | the registry item the cell belongs to (`Heffner__1998_Table1`) |
| `variable` | yes | the column in the item's CSV (`low_frequency_limit_Hz`); `*` when the whole row/item is meant |
| `locator` | yes | where in the print: table/figure/page and row label as printed (`Table 1, p. 262, row "Mallard duck"`) |
| `printed_value` | yes | what the publication prints, verbatim (`<125`); `n/a` for cross-source disagreements |
| `repo_value_before` | yes | what our CSV carried when the row was raised (`""` for blank) |
| `issue_type` | yes | `repo_transcription_error` · `publication_error` · `publication_ambiguity` · `cross_source_disagreement` · `unresolved_discrepancy` |
| `proposed_value` | no | the value we believe is right, or blank |
| `evidence` | yes | what decided it: PDF page read, an independent primary source with its locator, arithmetic |
| `status` | yes | `proposed` · `confirmed` · `withdrawn` |
| `status_reason` | when withdrawn | why the erratum was wrong |
| `raised_by` | yes | pipeline or person and date, e.g. `sensory_data_refs_check 2026-09-29` |
| `date_raised` | yes | ISO date |
| `date_resolved` | no | ISO date when status left `proposed` |
| `note` | no | anything else a reader needs |

`issue_type` decides what happens to the data:

* **`repo_transcription_error`** — our CSV was wrong. The fix is made in the
  item's **build `.R`** (and the frozen snapshot re-taken), never by hand in
  the CSV; the errata row records the fix (`repo_value_before` → the print).
  The public value therefore *does* change, through the pipeline, and the row
  is the changelog entry.
* **`publication_error` / `publication_ambiguity`** — the print is wrong or
  unclear. The CSV **keeps the printed value** (it mirrors the publication);
  the erratum is the correction layer. Merges read it and carry
  `errata_id` / `errata_status` beside the value so an analysis can exclude
  or substitute by rule (`proposed_value`), never by editing.
* **`cross_source_disagreement`** — two publications print different figures
  for the same measurement and neither is known to be wrong. Recorded on the
  paper whose value is *not* the primary measurement (or on both), so a
  merge can see that the cell is contested.
* **`unresolved_discrepancy`** — raised by an audit, not yet checked against
  the PDF. Should not stay in this state; a review queue exists to clear it.

## The three renderings (all generated — never hand-edited)

Run `render_errata(paper_dir)` (in `_tools/dataset_builder/render_errata.R`,
loaded by `load_dataset_builder.R`) after every change to the errata file.
It is idempotent.

1. **README** — each item README (`<Paper>_<Item>.README.md`, or
   `<Paper>.README.md`) gains an `## Errata` block between
   `<!-- errata:begin -->` and `<!-- errata:end -->`, one table row per
   erratum for that item, withdrawn rows struck through with the reason.
   The block is replaced wholesale on each render, so text inside the markers
   is never edited by hand.
2. **`definitions.csv`** — the affected variable's note column (`notes` or
   `Note`) is prefixed `ERRATA <id> (<status>, <issue_type>): <one line> | `.
   Existing `ERRATA …| ` prefixes are stripped first, so re-rendering after a
   withdrawal removes the notice.
3. **Merges** — `__merging_*` scripts read every `*_errata.csv` under the repo
   and join on `(item, variable, locator/species)` to add `errata_id` and
   `errata_status` columns to their long tables. Flags only; no substitution.

`validate_dataset_item()` treats a malformed errata file as a failed
invariant (`errata_file_valid`); a folder without one passes (`SKIP`).

## Where errata come from

The `*_refs_check` audit pipelines (`Evo-M1-Trait-Data-restricted/other_checks`,
`restricted_checks`) each end with `10_review_queue.R`, which writes
`audit_out/findings/REVIEW_QUEUE.csv`: one row per cell the audit could not
confirm, with the paper folder, the PDF in it, the locator, both values and
an empty `resolution`. Working the queue means opening the page and turning
each row into an errata row (or a build-script fix plus an errata row), or
marking it `workbook_error` / `not_an_error` in the queue. The skill
`evom1-errata-convention` carries helpers for the queue → errata step and a
repo-wide checker.

### Which queue can become errata

What the queue letter means depends on what the audited dataset *is*:

| pipeline | audited dataset is… | queues that feed errata | queues that never do |
|---|---|---|---|
| `sensory_data_refs_check` | an unpublished workbook | **A** (repo transcription vs PDF), **B** (indexed papers disagree) | **C** — workbook errors are reported to the curator and replaced, not recorded on a paper |
| `stephan_primates_refs_check` | a compilation CSV | **B** (structure-key conflict → `publication_ambiguity` on the source paper) | **C** — compilation errors go to the corrected copy |
| `DeCasien … BrainRegion_refs_check` | itself a published supplement | **P** (supplement disagrees with the source it cites → errata on `DeCasien_Higham_2019`, status *proposed*; the CSV keeps the printed value) | **A** (audit self-checks), **G** (coverage gaps) |

### Rendering notes (render_errata.R, 2026-09-29)

* The item README may be `<Paper>_<Item>.README.md` **or** the older `<Paper>_<Item>.md`.
* Definitions files are edited **record by record**: only rows whose variable carries an erratum are re-serialised (minimal quoting), everything else stays byte-identical. A whole-file `read.csv`/`write.csv` round-trip is not used — several hand-written definitions files carry ragged rows, and on one of them `read.csv` silently promoted the variable column to row names.
* Folder names with accents are stored NFD on macOS; comparisons are normalisation-insensitive, but `Rscript` needs a UTF-8 locale (`LC_ALL=en_US.UTF-8`) — RStudio already has one.
* Accepted `variable` values are the `Code`/`variable` entries of the item's definitions file; for long-format items (Zilles Table 12-2) those are the structure rows.

## Precedence

The errata file is the record of what we found and decided; the build `.R`
is the record of what we did to the data. When they disagree, the errata
file is wrong (fix it, or withdraw the row) — the CSV always follows the
build script.
