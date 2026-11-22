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
| `resolve_reference_chains.py` (`_tools/dataset_builder/reference_chains/findings/`) | the repo's own reference lists (citation graph, paper level) | **R** (root unresolved: the citing paper prints an abbreviated / unresolvable citation → `publication_ambiguity`, *proposed*; or the repo list omits a printed entry → build-script fix + `repo_transcription_error`) | **M** (resolver match confirmations → matcher overrides), **K** (registry `Data role` gaps → `__ReadMe.xlsx`) |

### Rendering notes (render_errata.R, 2026-09-29)

* The item README may be `<Paper>_<Item>.README.md` **or** the older `<Paper>_<Item>.md`.
* Definitions files are edited **record by record**: only rows whose variable carries an erratum are re-serialised (minimal quoting), everything else stays byte-identical. A whole-file `read.csv`/`write.csv` round-trip is not used — several hand-written definitions files carry ragged rows, and on one of them `read.csv` silently promoted the variable column to row names.
* Folder names with accents are stored NFD on macOS; comparisons are normalisation-insensitive, but `Rscript` needs a UTF-8 locale (`LC_ALL=en_US.UTF-8`) — RStudio already has one.
* Accepted `variable` values are the `Code`/`variable` entries of the item's definitions file; for long-format items (Zilles Table 12-2) those are the structure rows.

## Where a corrected value comes from — worked example (Dos Santos et al. 2020)

*Status: an example, not yet a rule. Written 2026-11-22 from one paper; revise
it when further cases arise.*

The columns above say how to *record* a wrong print. They do not say where
the `proposed_value` may come from when the print cannot be trusted. This
section sets out how that was decided for Table 1 of Dos Santos et al. (2020),
so the next case can follow it or argue with it. The errata file
(`DosSantos_etal_2020/reference_tables/DosSantos_etal_2020_errata.csv`) has the
evidence for every row; `DosSantos_etal_2020/DosSantos_etal_2020.README.md`
has the paper-level account.

### Order of preference used

The published table stays the source of the item. A correction is looked for
in this order, and the first level that yields a value supplies it:

1. **A published table** — elsewhere in the same paper, or in the paper the
   value is re-reported from.
2. **Calculation from published numbers** — a sum of parts, a product or a
   ratio the paper itself defines. Where two published routes disagree, prefer
   the one built on the quantity that was **measured first**: in this paper
   microglia per mg and per neuron were measured and the microglia count was
   derived from them, so a density outranks the count.
3. **The authors' unpublished table** — the value is used and the unpublished
   table is **named as the source** in `evidence`, together with why levels 1
   and 2 failed.
4. **A figure** — read off a plot, with the calibration stated.

The levels are also evidence for one another. A correction that several of
them agree on is firmer than one resting on a single level, and `evidence`
lists every level that was checked, not only the one that supplied the value.

### How the fifteen rows fell out

| rows | cell | printed → proposed | supplied by | also agreeing |
|---|---|---|---|---|
| E001 | *Tragelaphus* whole-brain cells | 21 751 929 → 21,888,835,128 | 2: sum of the three parts in the same table | 1: neurons + other cells in Herculano-Houzel et al. 2015 Table 5 |
| E002 | *Procavia* cerebellar neurons | "488 3703 000" → 488,373,000 | 1: Herculano-Houzel et al. 2015 Table 2, the table re-reported | 2: whole brain minus the other parts; the row's own I/N |
| E003, E004, E006 | three microglia densities | 1.915 → 1915; 10 129 → 2123; 4710 → 2682 | 2: count / mass | 2 again: mass-weighted mean of the parts (E004, E006); clade mean in the paper's Table 5 (E003) |
| E005 | *Tragelaphus* hippocampus I/N | 3.946 → 1.034 | 2: I / N, the footnote's own definition | — |
| E009, E010 | *Petrodromus* microglia counts | 1217 665 → 1,649,430; 1067 062 → 824,704 | 2: density × mass, preferred over the printed count as the earlier measurement | the species' densities add up across structures where its counts do not; clade mean in the paper's Table 5 (E009) |
| E007, E008 | *Cebus*, *Papio* cortical cells | 3035 947 220 → 3,707,354,000; 4934 116 014 → 6,740,084,000 | 3: the authors' workbook, named | 4: two panels of Figure 5, within 0.4% |
| E011, E013 | *Otolemur* cortical cells; *Loxodonta* brain mass | no value proposed | — | recorded only: the miss is under 10% |
| E012, E014, E015 | *Elephantulus* rows; *Petrodromus* I/N | no value proposed | — | recorded only: no single wrong cell can be named |

Two rows went to level 3 because the first two levels gave nothing exact. No
published table carries that cortex sample: the cited source prints
percentages only, the earlier table of absolute numbers is a different
sample, and a search of every public table in the repo found the row's
numbers nowhere else. The table offers no second route to total cells. The
figure reading would have served, and at first it did; the workbook value
replaced it because a tabulated number is safer than a marker read off a plot.

### What was done with the data

* **The item stays verbatim.** CSV, snapshot and public TSV carry the print,
  including the wrong cells. Corrections are a layer on top.
* **A value is proposed only when the merge will use it.** The threshold in
  this case: the paper's own arithmetic fails by more than 10 % *and* the wrong
  cell can be identified. Smaller or unattributable failures get an errata row
  with `proposed_value` blank.
* **The merge substitutes in a guarded step** keyed to the errata ids
  (`__merging_cell_counts_isotropic_fractionator`, step 3.4e). It stops if the
  printed value it expects is no longer in the table, if the erratum's
  `proposed_value` differs from the one in the script, or if the erratum has
  been withdrawn. The same merge already corrected Jardim-Messeder et al. 2017
  and Herculano-Houzel et al. 2011 this way. Rendering 3 above still reads
  "flags only; no substitution": practice and text differ here, and one of
  them should be brought into line when this section is revised.
* **Checks sit where their inputs may sit.** The check of the paper against
  itself is public (`DosSantos_etal_2020/internal_checks/`). The comparison
  with the authors' unpublished table is in the restricted repo
  (`restricted_checks/_cross_table/DosSantos_2020_published_vs_authors_unpublished/`);
  public errata rows may say that it agrees but do not quote it.
* **Level 3 is the exception to "do not quote".** The two workbook numbers
  appear in the public errata file, labelled as unpublished and attributed.
  `_REPO_BOUNDARY.md` records that they crossed the boundary, so that such
  cases can be counted.

### Left open by one example

* Whether 10 % is the right threshold for other tables, or was only a
  convenient gap in this one.
* Whether a level-3 value needs the authors' consent before it is made
  public. It was not obtained here before the two values were used.
* Whether `issue_type = publication_ambiguity` should ever carry a
  `proposed_value` (E009 and E010 do, by curator decision), or whether such
  rows need a type of their own.
* Whether the supplying level deserves its own column (`value_source`) once
  more than one paper uses the scheme. For now it is written into `evidence`.

## Precedence

The errata file is the record of what we found and decided; the build `.R`
is the record of what we did to the data. When they disagree, the errata
file is wrong (fix it, or withdraw the row) — the CSV always follows the
build script.
