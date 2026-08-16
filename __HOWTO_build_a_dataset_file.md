# How to build a dataset file (frozen source → CSV → TSV)

A guide for research apprentices **and** for Claude/AI assistants working in this dataset.
It picks up where **`__HOWTO_make_a_snapshot.md`** leaves off (that one covers only the
snapshot) and carries a single paper's table all the way to the shared database and the
cross-paper merge. The terse 11-step list on the `Pipeline` sheet of `__ReadMe.xlsx` is the
ancestor of this document; this is the expanded, authoritative version.

---

## 0. The pipeline at a glance

```
Source (PDF / journal Excel / Adobe export)
  → frozen source   faithful copy that cleaning is reproducible from:
                      digital-native → the untouched download itself (no derived snapshot)
                      printed/scanned → a hand-verified ..._snapshot.xlsx | .csv
  → reformat (R)    clean + type + convert units               (..._Table<N>.R)
  → analysis CSV    one tidy row per species (or individual)   (..._Table<N>.csv)
  → public TSV      DOI/PMID-named, in __Public/comparative-data/   ← REQUIRED either way
  → comparison      QA: frozen source ↔ curated data, 0 mismatches  (comparison/..._compare_to_*.R)
  → definitions     data dictionary, one row per variable      (reference_tables/..._definitions.csv)
  → README          source, steps, checks                      (..._Table<N>.README.md)
  → merge           added to __merging_volumes / __merging_cellcounts (if PRIMARY)
```

**One golden rule (inherited from the snapshot guide):** freeze the source *before* any cleaning;
every change after that happens in the `.R` script, never silently in the frozen copy. What counts as
the frozen copy depends on the source: for a **digital-native** source (a journal-supplied CSV/XLSX)
the untouched download *is* the frozen copy — keep it verbatim and script from it directly; only a
**printed/scanned** source needs a separate hand-made `_snapshot` (see §0a invariant 1 and §2).
**The public TSV (invariant 2) is required either way** — it is what gets databased, merged, and read
by the Shiny app, and it does not depend on whether a snapshot exists.

---

## 0a. What is fixed vs. what is flexible

This dataset has grown two script styles: the **Stephan/Düsseldorf volumes lineage** (Stephan,
Baron, Frahm, Matano, de Sousa, Zilles, Bauernfeind — positional reads, `Species_<Paper>`,
comparison scripts) and the **cell-count lineage** (Herculano-Houzel, Burish, Dos Santos,
Jardim-Messeder, Kverková, Avelino-de-Souza — header-based reads, in-script species harmonisation,
PDF/Excel extraction). **Both are valid.** The aim is not to force every script into one template,
but to guarantee a small set of **hard invariants** the merges depend on, while leaving the rest to
the curator's judgement and the shape of the source table.

**Hard invariants (must hold — the merge/registry/catalog break otherwise):**

1. A **frozen source exists** and all cleaning is reproducible from it (golden rule). This is
   satisfied one of two ways depending on the source:
   - **Digital-native source** (a journal-supplied CSV/XLSX you can download and script directly):
     the **untouched download itself is the frozen copy** — keep it in the folder verbatim and never
     edit it. **Do not make a derived `_snapshot`**; a re-save only duplicates the file and can
     introduce drift (type coercion, re-encoding). The `.R` reads the original download. Record the
     download filename as the source in the README and the registry's `Snapshot` / `Data readable`
     columns (as Burger SD1 already does: `gyz043_suppl_Supplement_Data.csv`).
   - **Printed / scanned / OCR / Adobe-export source** (the source is a *picture* of the table, not
     the data): a **`_snapshot` is required** — the hand-verified faithful capture is the only frozen,
     auditable copy, and it may be hand-made or built by an `*_extract.R`/scrape saved as a hardcopy.

   The dividing line is *"is the source already the machine-readable data, or a picture of it?"* — not
   the file format. When in doubt (e.g. a messy multi-tier XLSX), a snapshot never hurts.
2. The build writes **both** a local analysis CSV **and** a DOI/PMID-coded TSV into
   `__Public/comparative-data/`, with the code looked up from `__ReadMe.xlsx` (`Sheet1`,
   `Item encoded` matched on `Item name`). *(§4)*
3. The **journal's own species name is preserved** verbatim in the data (whether kept as
   `Species_<Paper>` or recorded alongside a harmonised name — see §5). Never overwrite it silently.
4. **Project units** in the analysis CSV (volume mm³, body g, brain mg), with the conversion shown
   in a comment. *(§6)*
5. A **`definitions.csv`** with the fixed 10-column schema. *(§8)*
6. The **`Data role`** (primary/secondary/both) is set in `__ReadMe.xlsx`, and only primary data is
   merged. *(§9)*

**Allowed variation (curator's choice — pick what fits the table):**

- **How the snapshot is read.** Positional (`col_names = FALSE`, skip header rows, name by position)
  is the most robust for messy multi-tier headers and is preferred for the volumes lineage; a plain
  header read (`read_excel`/`read.csv` with real headers) is fine for clean tables. The invariant is
  reproducibility from the frozen snapshot, *not* the read method.
- **Where the snapshot comes from.** A hand-built `_snapshot.xlsx`, or an `*_extract.R` / scrape that
  builds the snapshot from a PDF (`tabulapdf`) or HTML (`rvest`) and saves it before cleaning. A
  combined extract-then-clean script is acceptable **provided it writes the snapshot hardcopy first**.
- **Where species harmonisation happens.** Centrally via `_keys/Stephan/species_key.csv` (volumes
  default) **or** by sourcing that same key inside the per-paper script (the Bush pattern) — as long
  as the printed name is preserved (invariant 3) and the key file stays the single source of truth.
- **Granularity** (per-species vs per-individual), **comparison step** (required only when a curated
  source exists to audit against — see §7), and the exact **missing-value token list / encoding
  handling** (§6) are all table-dependent.

When in doubt: copy the closest model folder (volumes → `Stephan_etal_1982`; cell counts → see the
cell-count lineage and `__merging_cellcounts/README__merging.md`), and keep the six invariants.

---

## 1. Folder layout & file naming

One folder per publication; one set of files per **table** built. `<Folder>` is `Author_etal_YYYY`
(or `Author1_Author2_YYYY`); `<N>` is the printed table number (set it **exactly as printed** —
`Table1`, `Table 12-2`, `SupplementaryTable1`).

```
<Folder>/
  <rawfile>.pdf                              the publication (keep it)
  <rawfile>.xlsx                             Adobe "Export PDF → Excel" of the paper (provenance)
  <Folder>_Table<N>_snapshot.xlsx            the snapshot (sheet "Table<N>")
  <Folder>_Table<N>.R                        reformat: snapshot → CSV (+ TSV)
  <Folder>_Table<N>.csv                      analysis-ready data ("use this")
  <Folder>_Table<N>.README.md                source + steps + checks
  reference_tables/
    <Folder>_Table<N>_definitions.csv        data dictionary
  comparison/
    <Source>.csv                             the curated/working table, audited only
    <Folder>_Table<N>_compare_to_<Source>_csv.R   QA script
    <Folder>_Table<N>_comparison_report_from_R.csv     (+ _mismatches_from_R.csv)
```

The model folders to copy: **`Stephan_etal_1982`** (hierarchy in one species column),
**`Frahm_etal_1982`** (flat species list), **`Stephan_etal_1981`** (wide master table).

---

## 2. Frozen source — snapshot only when the source is printed/scanned — see `__HOWTO_make_a_snapshot.md`

**First decide which case you are in (§0a invariant 1).** If the source is **digital-native** (a
journal CSV/XLSX), skip this section: keep the download verbatim and point the `.R` at it — there is
no snapshot to make. The steps below apply to **printed/scanned/OCR** sources, where the snapshot is
the frozen copy.

Reproduce the **specific printed table**, in its **original units and layout**: keep the caption,
column headers, footnote markers/superscripts, `n.a.`/`—`/blank cells, grouping rows and row order.
Don't impose a template — a species-as-rows table, a structure-as-rows single-specimen table
(e.g. Zilles 1988), and a per-individual table (e.g. Bauernfeind 2013) each look different. Get the
values from the curated `comparison/*.csv` when one exists (cleaner than OCR), but lay them out to
match the PDF so the snapshot can be eyeballed against the page. If the only clean source is an
Adobe export, write a small `*_extract.R` that builds the snapshot from it, so the
source→snapshot step is reproducible rather than hand-typed (see `Smaers_etal_2011`).

---

## 3. Reformat (`<Folder>_Table<N>.R`): snapshot → analysis CSV

The reformat does **all** the cleaning the snapshot deliberately left undone. Its input is the
**frozen snapshot** — either read it directly, or, if the script also *builds* the snapshot from a
PDF/HTML source, **write the snapshot hardcopy first and then clean from it** (the extract and the
clean may live in one script, e.g. `Burish_etal_2010`, `Smaers_etal_2011_..._extract.R`, or in two).
What matters is that the cleaning is reproducible from a saved snapshot, not silently from the source.

Reading method is the curator's choice (see §0a): **positional** (`col_names = FALSE`) is preferred
for multi-tier/footnote-heavy headers; a plain header read is fine for clean tables. Pattern for the
positional case (copy an existing `.R`):

1. Read the snapshot by **position** (`col_names = FALSE`), skip the header rows, name columns.
2. **Keep the data rows** — filter to rows that carry a numeric measure; this automatically drops
   caption/group/family/Mean/footnote rows.
3. **Clean names** → R-friendly (`Body weight (1)` → `Body_weight`).
4. **Superscripts / parentheticals** → split out: a name superscript becomes `former_name_ref` +
   `former_name`; an `n` printed as "(2)" becomes its own `n` column; method markers become a note.
5. **Convert to project units** (see §6) and document the conversion in a comment + the definitions.
6. Keep the **journal species name** as `Species_<Paper>` (do not re-name species here — §5).
7. Write the CSV, then the DOI/PMID-named TSV (§4).

Granularity: usually **one row per species**. Some tables are **per-individual** (Bauernfeind 2011/
2013, Smaers 2011, MacLeod 2003) — keep them per-individual here and aggregate to species means in
the comparison/merge step, not in the reformat.

---

## 4. The public TSV + the registry (`__ReadMe.xlsx`)

Every built table gets a copy in **`__Public/comparative-data/`**, named by its **Item encoded**
(a URL-safe DOI/PMID/ISBN + table), e.g. `PMID%3A7161483_Table1.tsv`,
`10.1016%2Fj.jhevol.2012.12.003_Table1.tsv`. The reformat looks this up:

```
filecodes    <- read_excel(".../__ReadMe.xlsx", sheet = "Sheet1")
item_encoded <- filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]
write.table(df, paste0(tsv_dir, item_encoded, ".tsv"), sep = "\t", row.names = FALSE)
```

In `__ReadMe.xlsx` **Sheet1**, one row per table:
- **You set** `Item number` (col D) — *exactly as printed* — and the descriptive columns
  (Source type, Team, Main Trait(s), Data role, Flags, Note). These are safe to edit.
- **Never edit cols E–M** (`end`, Publication name, authors, year, DOI, **Item name**,
  **Item encoded**, auto-generated public TSV lookup) — they are **formulas** that build Item
  name/encoded from the other
  cells. Editing them by hand (or letting openpyxl rewrite the workbook) strips the cached values
  the pipeline reads. If you must set a flag programmatically, edit the target cells at the XML
  level so the formulas survive (see how the Smaers 2017 flag was set).
- If the shared `__Public` folder isn't mounted, the reformat writes the TSV locally and warns —
  copy it over later.

---

## 5. Species names (answering the `Pipeline`-sheet question)

**Invariant:** the **journal's printed species name must survive** into the data — keep it as
`Species_<Paper>` (e.g. `Species_Stephan1982`), or keep it in its own column next to a harmonised
name. Never overwrite the printed name silently.

**Where harmonisation happens is flexible, but the key is the single source of truth.** The accepted
names live in **`_keys/Stephan/species_key.csv`** — columns `accepted_name, source_publication,
variant_name`: one row per (paper token × the name that paper printed) → the accepted name. Add your
paper's rows there (token = e.g. `Stephan1982`). Then either:

- **apply it centrally** (the volumes-merge default — the per-paper CSV carries only `Species_<Paper>`
  and the merge resolves names); **or**
- **source the same key inside the per-paper script** and add a harmonised column (the `Bush_Allman`
  pattern: `lk <- setNames(key$accepted_name, tolower(key$variant_name))`), *keeping* the printed
  name as well.

What is **not** allowed is hand-coding species fixes that bypass the key (e.g. an inline
`common→binomial` map or one-off spelling correction baked into a single script) — put every mapping
in `species_key.csv` so it is visible, reusable, and consistent across papers.

> **Pipeline-sheet question — "should the match column be renamed?"** Yes. Use one explicit
> canonical key everywhere (suggest **`Species`** = the accepted scientific binomial used in
> `species_key.csv`, and keep each paper's printed name only as `Species_<Paper>`). A more unique
> name (`Species_accepted`) is fine, but pick one and use it as the join key in every merge.

Record the table-legend / text notes and any corrections (typos, misidentifications, combined
species) as their own columns or in `species_key.csv`, with the reason — don't overwrite silently.

---

## 6. House rules: units, hemispheres, encoding

**Units — convert to the project standard in the reformat (keep originals in the snapshot):**

| quantity | project unit | typical conversion |
|---|---|---|
| structure volume | **mm³** | cm³ (cc) × 1000 |
| body weight | **g** | kg × 1000 |
| brain weight | **mg** | g × 1000 |

**Hemispheres.** The merge unit is the **combined (left + right)** whole-structure volume. If a
paper reports one hemisphere ×2 or a both-sides total, use it directly; if it reports **left and
right separately**, keep both columns and also compute `*_total = left + right`. Tag single-side
columns with the side (`_L` / `_R`, Barger-style) so it's never ambiguous (see Bauernfeind 2013,
Smaers 2011). Individual hemispheres stay in the source CSV/TSV but only the combined value is merged.

**Encoding & parsing gotchas (recommended defaults, adapt per source).** **Strip thousands-separator
commas** before parsing numbers (`"6,400"` → 6400) — do this every time. Treat
`""`, `-`, `–`, `—`, `n.a.`, `__`, `e` (a dash mangled by OCR) as missing; `readr::parse_number(...,
na = ...)` makes this easy. The fullest token set in use is
`c("", "-", "–", "—", "NA", "n.a.", "__", "e")` (Bauernfeind) — prefer it, but a shorter set is fine
when the source has no en/em-dashes or OCR artefacts. Read CSVs with a **latin1 fallback** *when
Mac-Roman bytes appear* (a real but occasional problem — currently only a couple of comparison
scripts need it); it is a fix to reach for on a parse error, not a mandatory wrapper on every read.

---

## 7. Comparison / QA (`comparison/`)

**When a curated/independent copy of the table exists** (a project CSV, or a TSV prepared elsewhere),
write a comparison script that audits the snapshot against it and **requires 0 value mismatches** on
the shared measured columns. This is the strongest QA we have, so add it whenever such a source
exists — but it is **not possible for every table** (many cell-count tables have no second copy to
audit against), and its absence is not a defect when there is genuinely nothing to compare to. Two
flavours:

- **vs the project's curated CSV** (Stephan-series papers): match each snapshot row to one CSV row
  by **the paper name OR the canonical name, resolving each CSV row once** (no phantom duplicates).
- **vs a TSV that pre-existed in `__Public`** (prepared elsewhere, e.g. Smaers 2011): match by the
  shared key and compare — this also catches corruption in the old file (Smaers 2011 Suppl. Table 2
  had values rounded/decimal-dropped; the audit found 19/26 mismatches and we regenerated it).

`csv_only` / `snapshot_only` rows are **expected, not errors** — they flag provenance issues, e.g.
*Pongo* values from Zilles & Rehkämper 1988 leaking into pre-1988 tables, or *Rattus/Spalax* from
Frahm 1997. Record them; don't "fix" the snapshot to match.

**Size indices / percentages / ratios are NOT transcribed** — they are derived (allometric/relative)
and recomputed downstream from the pooled volumes + body weights. Snapshot the volumes only.

---

## 8. Definitions (`reference_tables/<Folder>_Table<N>_definitions.csv`)

The data dictionary — **one row per measured variable**. Schema (10 columns, fixed):

```
Code, Definition, Structure, Measure, Stat, role, taxon, Reference, Note, Source Note
```

- `Code` = the analysis-CSV column (or, for long tables, the structure).
- `Structure` = the **canonical** structure name (match `_keys/anatomy_reference.csv` where possible
  — this is what lets the catalog/merge pool across papers).
- `Measure` = `Vol.mm3`, `Mass.g`, `Mass.mg`, `pct.*`, `size.index`, … (drives the measure class).
- `role` = `primary` / `secondary` / `info` / `note` / `method`; `taxon` = the species coverage.
- `Reference` = the Item name. Add a `Method:*` row for the size-index method / unit conversions.

Info/metadata columns (Species, code, n, source) have an empty `Measure` so they aren't counted as
variables. `_keys/build_variable_catalog.R` reads every `*_definitions.csv` into the variable catalog.

**Naming & location.** Canonical is `reference_tables/<Folder>_Table<N>_definitions.csv` (one per
built table). Two legacy variants still exist in the tree and are tolerated but being migrated:
bare `<Folder>_definitions.csv` (no table number) and definitions files at the folder top level
rather than under `reference_tables/`. The catalog globs `*_definitions.csv` so both still load — but
**don't create new ones in the legacy form**, and if a folder has *both* a numbered and a bare file
(e.g. `deSousa_etal_2010`, `Stephan_etal_1987`), that is a half-finished rename: keep the
table-numbered one under `reference_tables/` and delete the stray. (The 7–8 column files under
`__Archive_*` are an older schema and out of scope.)

---

## 9. Primary vs secondary — flag it, don't double-count

Many tables **re-use earlier data under new labels** and should **not** be merged as if new.

- **The flag** is the **`Data role`** column in `__ReadMe.xlsx` (`primary` / `secondary` / `both`).
  Set `secondary` (or `both` for a mix), and name the primary source in `Source type` / a `Flags`
  cell (e.g. Smaers 2017 primary-visual = "de Sousa 2010 = Frahm 1984 area striata").
- **Confirm by value** when you suspect re-use: `__merging_volumes/crosspub_value_match.R` matches a
  paper's values against every source, label- and unit-agnostic — **identical values = same data**.
  (It proved Smaers 2017 "primary visual" = Frahm 1984's area striata, exact.)
- A secondary table is still **fully built** (snapshot → comparison → TSV) for provenance, but it is
  **excluded from the merge** (not added to the merge's `item_name`). For a `both` table, merge only
  its primary columns.

---

## 10. Merge — one folder per data type (`__merging_*`)

Merges are kept **one per data type** — never mix measure classes in a single merged table.
Current and planned merge folders, each following the same `standardized_term` + compile pattern
(with its own teams and resolution rule):

- **`__merging_cellcounts/`** — optical-fractionator neuron/cell counts (Herculano-Houzel, Kverkova, …).
- **`__merging_volumes/`** — histologically-derived structure volumes (Stephan collection + Bush, …).
- **`__merging_cerebral_metabolic_rate/`** — brain cerebral metabolic rate (CMRgl/CMRO2/CBF;
  Kaufman, Karbowski, Heiss). Compilation-aware resolution (dedupes primary studies shared
  between the Kaufman & Karbowski compilations). Whole-body/basal MR is a separate measure class.
- **more in progress** — and others as new data
  types are added. Build each by copying an existing merge folder's structure and re-pointing it at
  the relevant primary tables; the per-paper build (this guide) is shared by all of them.

To add a **primary** table to a merge: create
`standardized_term_by_reference/<Item name>_standardized_terms.csv`
(`Original_Term, Reference, Standardized_Term`; the standardized term is `Species`, `Body_Mass.g`,
or `<CanonicalStructure>_Vol.mm3`), add the table to the compile script's `item_name` with its
**team**, re-run `standardized_term.R` then the compile. Resolution rule (volumes): within the
Stephan/Düsseldorf collection, the **most recent** measurement supersedes (flag big deviations);
across independent teams (Bush, de Sousa, MacLeod, …) the values are **averaged**; body/brain weight
keeps the Stephan 1981 reference. (Full detail in `__merging_volumes/README__merging.md`.)

### Conflict-resolution priority (when two sources report the same species × structure)

*(Migrated from the former `Conflicts` sheet of `__ReadMe.xlsx`.)* Put the supporting metadata in each
table's `definitions`, and resolve conflicting values by **preferring sources in this order**:

1. **Revised value** — a paper/datum the team *explicitly* states supersedes an earlier one
   (improved). Keep the revision; **flag** the worse value and cite the revision in the metadata,
   then filter the worse one out.
2. **Best-sampled method/lab** — the method and/or lab with the **highest number of mammalian
   species** represented (*any* mammals, not just the focal taxa). *(May need a manual call.)*
3. **Most species** — the paper with the highest number of mammalian species represented.
4. **Most recent** — the paper with the most recent publication date.

How this maps onto the merges: **within one collection/lab** (e.g. the Stephan group), "revised
supersedes" reduces to taking the **most recent** measurement (rules 1 + 4, with a deviation flag);
**across independent labs/specimens** prefer the better-sampled source (rules 2–3) or **average**
when they are genuinely independent. Each data type's `__merging_*/README__merging.md` records how it
applies this rubric.

---

## 11. "Done" checklist (one table)

- [ ] frozen source in place — digital-native: original download kept verbatim (no derived snapshot);
      printed/scanned: `_snapshot` frozen + reads like the PDF (caption, headers, footnotes, units, row order kept)
- [ ] cleaning reproducible from the frozen source; names cleaned; units converted + documented
- [ ] analysis CSV = right number of rows (species/individuals)
- [ ] **DOI/PMID TSV in `__Public/comparative-data/`**; `Item number` set in `__ReadMe.xlsx` *(invariant)*
- [ ] printed species name preserved; rows added to `species_key.csv`
- [ ] comparison = **0 value mismatches** *(when a curated source exists)*; `csv_only`/`snapshot_only` explained
- [ ] `definitions.csv` complete (10 cols; canonical Structure + Measure; role/taxon)
- [ ] README written
- [ ] `Data role` set (primary/secondary/both); if secondary, **not** merged
- [ ] if primary: standardized-terms file added + merge re-run

---

## Known wrinkles (don't copy these)

A few habits in older scripts work but aren't ideal — prefer the better form when you touch a script:

- **Paths.** Some scripts `setwd()` to a hardcoded absolute path (and a couple still point at a
  Windows `C:/Users/...` path). Prefer deriving the location from the script itself
  (`rstudioapi::getActiveDocumentContext()` when interactive, else a relative path) so the build runs
  on any machine and when `__Public` is unmounted.
- **No shared helper.** The `num()`/`parse_number` helper, the `__ReadMe.xlsx` lookup, and the
  CSV+TSV save block are copy-pasted into every script and have drifted. If you find yourself copying
  them again, that's fine for now — but the obvious refactor is a single sourced
  `_keys/build_helpers.R`; flag it rather than inventing a new variant.
- **Stub scripts.** A few `.R` files only set up paths and document intent without producing the
  clean CSV/TSV (e.g. some `Bush_Allman` tables). A script isn't "done" until it actually writes the
  CSV **and** the public TSV (invariant 2).

## Where these instructions live

Keep the **narrative how-to in Markdown** (this file + `__HOWTO_make_a_snapshot.md`): it's
version-controlled, diff-able, linkable, and readable outside Excel. The old `Pipeline` and
`Conflicts` sheets of `__ReadMe.xlsx` (terse method notes) have been **removed** — this file
supersedes them: the pipeline is §0–§9 above, and the `Conflicts` priority rubric is §10's
"Conflict-resolution priority". `__ReadMe.xlsx` now holds only what a spreadsheet does best — the
per-table **registry** (`Sheet1`: Item number, codes, Data role, progress columns) and the
**`AUTO_Public_TSV_FileList`** generated by `_tools/__file_list.R` from
`__Public/comparative-data/*.tsv`. So the method lives in one canonical place (Markdown), the
directory remains the sole source of truth, and the spreadsheet stays a tracker rather than a
second manually maintained list.
