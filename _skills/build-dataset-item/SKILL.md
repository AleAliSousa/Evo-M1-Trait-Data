---
name: build-dataset-item
description: Build, snapshot, and register one dataset item (a paper's table) in the Evo-M1-Trait-Data repo. Use to build a dataset item, add a new paper folder, add a source/table, make a snapshot, or run the audit/build/validate tool layer in _tools/dataset_builder/. Triggers on "build a dataset item", "new paper folder", "add a source", "add a table", "snapshot", "frozen source", "public TSV", "__ReadMe.xlsx registry", "Item encoded", "Item name".
---

# Build Dataset Item

Turn one paper's table into a registered dataset item: frozen source → analysis
CSV → public TSV → definitions → README → registry row. This file is the lean
entry point; the two references carry every procedural detail and should be
read (not re-derived) whenever a step below needs more than a sentence:

- `references/__HOWTO_make_a_snapshot.md` — what a snapshot is, fidelity
  checklist, extraction methods (download / scrape / tabulapdf / Adobe export
  / manual)
- `references/__HOWTO_build_a_dataset_file.md` — the full 11-section pipeline:
  folder layout, reformat script pattern, units, species harmonisation,
  comparison/QA, definitions schema, primary/secondary flagging, merges

The repo copies under `_skills/build-dataset-item/references/` are canonical;
when the repo is mounted, read those — an installed bundle may lag behind them.

## Tool layer

```r
source("_tools/dataset_builder/load_dataset_builder.R")
root <- repo_root()

audit_dataset_item(item_dir)                                   # 1. pre-build audit
build_dataset_item(item_dir, item_name, dry_run = TRUE)         # 2. dry run
build_dataset_item(item_dir, item_name, dry_run = FALSE)        # 3. build + validate
```

## Workflow

1. **Audit** — `audit_dataset_item(item_dir)`. Confirms the 4-file convention
   (snapshot / CSV / README / definitions) before you touch the build script,
   and flags any `.tsv` sitting inside the paper folder — other than a
   `*_snapshot.tsv` frozen source — as an orphan (public TSVs belong in
   `__Public/comparative-data/`, never in the paper folder).
2. **Snapshot** — transcribe only printed/scanned sources; a born-digital
   download is copy-renamed untouched (house rule below). Follow
   `__HOWTO_make_a_snapshot.md`: freeze the table exactly as printed *before*
   any cleaning — headers, footnote marks, `n.a.`/blank cells, row order, all
   preserved.
3. **Build** — write/extend `<Folder>_Table<N>.R` per §3 of the build HOWTO:
   read the frozen source, clean, convert to project units, keep the printed
   species name, write the analysis CSV, look up `Item encoded` in
   `__ReadMe.xlsx` by `Item name` and write the public TSV to
   `__Public/comparative-data/`.
4. **Validate** — `build_dataset_item(..., dry_run = FALSE)` calls
   `validate_dataset_item()` automatically and checks all 7 invariants
   (csv / tsv / readme / definitions / frozen_source / registry_row /
   tsv_name_match, with a trailing-underscore guard on the last one).
5. **Register** — set `Item number` (col D) and the descriptive columns in
   `__ReadMe.xlsx`; set `Data role` (primary/secondary/both) per §9 of the
   build HOWTO. Never hand-edit columns E–M (Item name/encoded formulas).

## House rules (live only here)

- **Species keys are collection-scoped, not global.** Each collection/lineage
  keeps its own `_keys/<Collection>/species_key.csv` (`Stephan`, `Allman`,
  `HerculanoHouzel`, `Ashwell`, …), with rows keyed by paper token within that
  file. Add your paper's variant-name rows to the key for **the collection
  your paper belongs to** — don't create a new key file, and don't assume a
  single repo-wide key.
- **Column C can override the DOI the Item-name formula resolves to.** When
  col C (a DOI/figshare/ISBN override cell) is empty, the formula falls back
  to the citation's own DOI — which is not always the code the built TSV and
  its downstream consumers actually use. Book chapters especially can have
  both a chapter DOI and a wanted ISBN/alternate code: check col C before
  trusting the resolved `Item encoded`, and if you clear or set it, verify the
  TSV filename and every consumer that cites it still match.
- **Never look up a registry row by position — always by `Item name`.** Row
  numbers shift every time a row is inserted; a cached row index silently
  points at the wrong item after the next registry edit. `validate_dataset_item()`
  and `build_dataset_item()` both resolve by name for this reason — do the
  same in any ad-hoc script.
- **Digital-native sources skip the transcription, never the suffix.** If
  the source is a journal-supplied CSV/XLSX/TSV you can download and script
  directly, the untouched download *is* the frozen copy: copy-rename it to
  `<Paper>_<locus>_snapshot.<original ext>`, bytes untouched — never
  open-and-resave or convert; a re-save risks silent drift (type coercion,
  re-encoding). Transcribe only printed/scanned/OCR sources. In every case
  the snapshot is **evidence, not product**: choose the capture that
  minimizes transformation from the publication, and standardize downstream
  in the build script (`references/__HOWTO_make_a_snapshot.md`,
  §"Choosing the format").
- **Check disk state before building — `__ReadMe.xlsx` is edited concurrently.**
  Excel and an assistant session can both have the workbook open; whoever
  saves last wins silently, and columns can shift between edits (a flag set
  in one pass has been lost this way before). Before running a build or
  editing the registry: close Excel if you're about to ask for a workbook
  edit, and re-read the current file (don't reuse a value read earlier in the
  session) before trusting `Item encoded`, `Item number`, or any flag column.
