# Plan: standardize the species column to `Species` across the repo

## STATUS — executed 2026-06-28

**Merge-level standardization DONE + verified (no R needed):**
- `Species_<token>` eliminated repo-wide → `Species` (102 files, 197 replacements): data headers,
  20 term maps, both merge scripts' reshapes, token build scripts + their QA scripts/reference CSVs.
- 23 remaining merge-input TSVs renamed `species`/`Species name` → `Species` (incl. cell-count
  AvelinodeSouza 2025 + DosSantos 2020). All term-map species rows now `Original_Term = Species`.
- Both merge scripts: reshape column refs → `Species`, plus a new **up-front normalizer** in
  `paper_long` (`species`/`Species name` → `Species` on read) so the merge stays correct even if a
  paper is regenerated with a lowercase header before its build script is updated.
- Verified: every merge-input TSV resolves to a `Species` column; all 37 volume papers resolve
  `spcol == Species`; 0 `Species_<token>` left; no duplicate `Species` columns; braces balanced.

**Remaining (durability + repo-wide):**
- **Lowercase-paper build scripts** (~18: Stephan 1970/1984/1987, Frahm 1997/1998, deSousa 2013,
  MacLeod, Bush×2, Smaers, Ashwell, Semendeferi×2, Sherwood 2005, Barger, + DeCasien primaries, +
  cell-count AvelinodeSouza/DosSantos) still emit `species`/`Species name`. Harmless to the merge now
  (normalizer), but to make regenerated files emit `Species` each needs its output-column assignment
  (and that paper's QA script + reference CSV + clean CSV) updated — bespoke per script. Recommend a
  careful per-paper pass with an R run between batches.
- **10 common-name tables**: add binomial `Species` + `common_name` per the recorded resolution
  policy (awaiting the mapping). `NA.tsv` is orphaned — investigate separately.

---

**Original proposal below (for reference).**

## The standard

1. **`Species` (capital)** is the canonical **binomial** species column in every output TSV/CSV.
   It is the most common header already, so it's the default. Renaming to merge-specific names
   happens only at compile time via each paper's term map (the `../__merging_cellcounts` pattern).
2. Retire the per-paper `Species_<token>` convention (`Species_Stephan1981`, `Species_deSousa2010`,
   …) and the one-off `Species name` (AvelinodeSouza, DosSantos 2020) → all become `Species`.
3. **Common-name-only tables** (a column called `Species`/`species` that actually holds common
   names, e.g. Changizi 2001 Figure3 = `star-nosed mole`, `hedgehog`): **add** a real binomial
   `Species` column, and **keep the common names** under a renamed column **`common_name`** (for
   archival). Never overload `Species` with common names.

Snapshots stay frozen — they're the archival raw input and are already clean (`Species` or
`species name`). All the "gotchas" (`Species_former_synonym`, `species_abbrev`, the shared
Bauernfeind token) are **added downstream by the build scripts**, not present in the snapshots, so
they're handled at the build-script/merge layer and don't complicate this.

## Verified against the snapshots you cited

- **Baron 1983** snapshot: column is `species name`; `Species_former_synonym` is added by the build
  script. ✔ downstream-only.
- **Bauernfeind T1/T2/T3** snapshots: `Species`. ✔ already compliant at source.
- **AvelinodeSouza** snapshot: no species column; `Species name` is created downstream. ✔
- **Changizi 2001 Figure3** snapshot: `Species` holds common names. ✔ → needs binomial `Species`
  added + source column → `common_name`.

## Inventory (what changes)

### Volume merge papers (the active work)
- **16 source TSVs + ~16 clean CSVs**: species column → `Species`
  (15 currently `Species_<token>`; Sherwood 2004 currently capital `Species`, already fine).
- **20 per-reference term maps** (`standardized_term_by_reference/*_standardized_terms.csv`):
  species row `Original_Term` → `Species`.
- **~16 build scripts** (`<Paper>/<Paper>_Table*.R`): emit `Species` instead of `Species_<token>`.
- **~15 QA scripts + their reference CSVs** (`<Paper>/comparison/…`): match by column name, so script
  and reference CSV change together.
- **2 merge scripts**: in `volumes_compiled.R` **and** `volumes_compiled_DeCasien.R`, the Zilles,
  Bauernfeind, and Sherwood-2004 reshapes reference the old names directly — update to `Species`.
  (The generic path already detects the column robustly.)
- READMEs + `reference_tables/*_definitions.csv`: cosmetic mentions.
- Net: **119 code/doc files + 16 TSVs + 20 term maps** reference the old names (grep below).

### Cell-count merge papers
Mostly already `Species`. Only the two `Species name` sources need the rename
(**AvelinodeSouza 2025**, **DosSantos 2020 unpublished/Table1**) + their term-map rows. cellcounts'
own code already keys on `Species`, so no merge-logic change.

### Common-name-only tables (repo-wide): 10 found
Need a binomial `Species` added + source column → `common_name`:

```
10.1007%2Fs004220000205_Figure3.tsv         (Changizi 2001 Figure3)      col 'Species'
10.1006%2Fjhev.1996.0005_Table1.tsv                                       col 'Species'
10.1371%2Fjournal.pbio.1002000_TableS1.tsv                                col 'Species'
10.1016%2Fj.cub.2017.01.020_TableS1part1.tsv (Smaers 2017)                col 'species'
10.1016%2Fj.cub.2017.01.020_TableS1part2.tsv (Smaers 2017)                col 'species'
10.1093%2Fjmammal%2Fgyz043_SupplementaryDataSD1.tsv                       col 'species'
10.1002%2F…_TABLE2.tsv  (AJPA 2001)                                       col 'species'
10.1093%2Foso%2F9780198568742.003.0006_Table6.1.tsv                       col 'Common Name'
10.6084%2Fm9.figshare.c.3899422.v1_Dataset1.tsv                          col 'Species Name'
NA.tsv  (orphaned; unrelated to the rename — flag separately)
```

Regenerate the full file list any time:
```bash
grep -rIl --exclude-dir=.git -E "Species_(Stephan|Frahm|Baron|Matano|Zilles|deSousa|Bauernfeind)" . \
  | grep -vE "\.(Rhistory)$|fuse_hidden"
```

## Common-name → binomial resolution rule (your policy)

When a table only has common names, fill the new binomial `Species` by this priority:

1. **In a collection/team** → use the same binomial that other papers in that collection/team use
   for the same animal (consistency within a collection wins).
2. **Standalone, no binomial stated in the paper** →
   a. use the **`Genus sp.`** form if the common name maps cleanly to a single genus; else
   b. use the **most common research-model species** for that animal.
3. **Always record the basis + a note** for every filled value.

Implementation: a reviewable `common_name_to_species.csv` (columns: `Reference`, `common_name`,
`Species`, `basis` = `collection_match` / `genus_sp` / `research_model`, `note`). I draft proposals
per table by this rule; you sign off before they're applied. The original common names are preserved
in the `common_name` column regardless. (None of the 10 common-name tables are in the volume merge,
so this doesn't block the volume work.)

## Execution order (recommended)

1. **Volume papers** (active): build scripts → `Species`; regenerate TSV/CSV; term maps → `Species`;
   update the 3 reshapes in both merge scripts; update QA scripts + reference CSVs.
2. **Cell-count papers**: rename the two `Species name` sources + term rows.
3. **Common-name tables**: add binomial `Species` + `common_name` (after the mapping decision).

## What I can do here vs. needs R

- **Here (no R):** edit build scripts, term maps, merge reshapes, QA scripts, and reference
  CSV/README/definitions; statically verify no `Species_<token>` remains and the reshapes/term maps
  are consistent. I can also write a one-shot `_standardize_species_colname.R` that renames the
  column in the already-generated TSV/CSV as a bridge.
- **You (in R):** `Rscript standardized_term.R`, then re-run the updated build scripts to regenerate
  the TSV/CSV, then `volumes_compiled.R` / `…_DeCasien.R`; confirm species counts unchanged + QA passes.

## Recommendation

Start with the **volume papers at the build-script layer** (durable, and it's the active pipeline),
in one batch; you regenerate; then cell-counts and the common-name tables. Say go and I'll begin with
the volume build scripts + term maps + the two merge reshapes.
