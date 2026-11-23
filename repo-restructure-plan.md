# Evo-M1-Trait-Data — restructure plan (draft, not scheduled)

Michael's idea, 2026-11-18: separate everything **pre-snapshot** from
**post-snapshot**; source files separate from scripts and outputs.
This is a plan only — no moves yet.

## The principle

The repo's chain of provenance has four stages. The restructure makes the
stages visible in the layout instead of mixing all four in one folder:

1. **Sources** — the material exactly as published (publisher PDF, full-text
   XML, supplementary bundles, downloaded data files). Frozen, never edited.
2. **Snapshots** — the published table frozen as data (`<Item>_snapshot.*`),
   one per item, made before any cleaning. Frozen.
3. **Scripts** — the snapshot-makers (`<Item>_snapshot.R`) and the item
   builders (`<Item>.R`). These are the only things that *run*.
4. **Outputs** — analysis CSVs, definitions, references, errata, READMEs, and
   the public TSVs. Regenerable from stages 1–3 (public TSVs already live
   apart, in `__Public/comparative-data/`).

Stages 1–2 are "pre-snapshot side" (immutable evidence); stages 3–4 are the
"post-snapshot side" (working material). Nothing in stages 1–2 is ever
rewritten by a script — that rule already exists; the layout would enforce it
at a glance.

## Where today's files go

Worked example — Beatty_Laughlin_2006, the folder that prompted this:

| File today | Stage | Destination |
|---|---|---|
| Publisher PDF | 1 source | sources |
| `fulltext.xml` | 1 source | sources |
| `12868_2005_221_MOESM1_ESM.png`, `...MOESM2_ESM.png` | 1 source (supplementary bundle) | sources |
| `supplementaryFiles.zip` | 1 source | sources |
| `Beatty_Laughlin_2006_Table1_snapshot.csv` | 2 snapshot | snapshots |
| `Beatty_Laughlin_2006_Table1_snapshot.R` | 3 script | scripts |
| `Beatty_Laughlin_2006_Table1.R` | 3 script | scripts |
| `Beatty_Laughlin_2006_Table1.csv` | 4 output | outputs (or stays item-level, see decisions) |
| `reference_tables/*_definitions.csv` | 4 output | reference_tables (unchanged) |
| `*.README.md` / `*.README.md` | 4 documentation | stays with the item |

The same mapping applies repo-wide: Michael-supplied paper PDFs (Kruska,
Röhrs) and the Dryad/publisher downloads (Gonzalez-Voyer CSV, Baker XLSX) are
stage 1; every `<Item>_snapshot.*` is stage 2; every `.R` is stage 3; every
analysis CSV is stage 4. Born-digital items (Baker, Gonzalez-Voyer) have no
stage 2 — their stage-1 file *is* what the script reads, which the registry
already records.

## Two ways to lay it out

### Option A — split inside each paper folder (recommended)

```
Beatty_Laughlin_2006/
  sources/            publisher PDF, fulltext.xml, MOESM PNGs, zip
  snapshots/          Beatty_Laughlin_2006_Table1_snapshot.csv
  scripts/            Beatty_Laughlin_2006_Table1_snapshot.R
                      Beatty_Laughlin_2006_Table1.R
  reference_tables/   definitions (unchanged)
  Beatty_Laughlin_2006_Table1.csv      (output, item level)
  Beatty_Laughlin_2006.README.md
  Beatty_Laughlin_2006_Table1.README.md
```

Pros: the publication stays one self-contained unit; registry item names,
the "one folder per publication" convention, and per-item provenance are
untouched; migration can go folder by folder. Cons: the pre/post split is
repeated ~500 times rather than visible once at repo level.

### Option B — split at repo level

```
_sources/<Paper>/…      all frozen source material
_snapshots/<Paper>/…    all snapshots
<Paper>/…               scripts, outputs, documentation only
```

Pros: the split is unmistakable; frozen material can be made read-only in
one place. Cons: every script's path logic changes (snapshot lookup,
registry walk-up); `_tools/dataset_builder` validation/audit expects the
current layout and would need rework; `_skills` docs rewritten; ~500 folders
move at once; the paper folder stops being self-contained, so a reader can
no longer see a dataset's full provenance in one place.

## What has to change either way

- **Script path logic.** Item scripts self-locate from their own filename
  and walk up to `__ReadMe.xlsx`; snapshot and source paths are relative to
  the paper folder. Under Option A only the subfolder prefixes change.
- **`_tools/dataset_builder`** (load/validate/audit) — its invariants look
  for the snapshot, CSV, definitions and frozen source in the current
  places; paths must be updated to match the chosen layout.
- **`_skills/build-dataset-item`** — the HOWTOs describe the current layout;
  update after the move, not before.
- **Registry (`__ReadMe.xlsx`)** — records the snapshot *filename*, not a
  path, so Option A needs no registry edits. (Another point for A.)
- **Unaffected:** the public TSVs (`__Public/comparative-data/`), the
  `__merging_*` builders (they harvest the TSVs), and both Shiny apps (they
  read the merge outputs and `__ShinyApp` data, not the paper folders).
- **Git history:** use `git mv` (or upload-with-history-preserving moves) so
  file history follows the files.

## Migration sketch (when the time comes)

1. Pick Option A or B; freeze the naming of the subfolders.
2. Update `_tools/dataset_builder` + `_skills` to the new layout first, on a
   branch.
3. Move one pilot folder (Beatty is a good pilot: it has every file kind),
   re-run its snapshot and item scripts, and confirm the analysis CSV and
   public TSV come out byte-identical.
4. Script the remaining folders folder-by-folder, validating each item
   (`validate_dataset_item`) as it moves; commit per folder or in small
   batches, as with the November rebuild.
5. Final sweep: repo-wide check that no script references an old path, and
   every item validates under the new layout.

## Decisions still open

- Option A vs Option B.
- Do analysis CSVs get their own `outputs/` subfolder, or stay at item
  level? (They are the item's headline product; keeping them visible has
  value.)
- Do the snapshot scripts live with the scripts, or with the snapshots they
  produce? (They are code, but they belong to the pre-snapshot stage.)
- Are READMEs/errata documentation that stays with the item, or outputs?
  (Recommendation: stays — they describe the item, they aren't generated
  data. Errata renderings are generated, but the errata CSV is curated.)
- Folder names: `sources/` + `snapshots/` + `scripts/`, or house-style
  names matching the existing underscore conventions?

*Draft prepared 2026-11-18 (Buddy) from Michael's outline; nothing in the
repo has been changed.*
