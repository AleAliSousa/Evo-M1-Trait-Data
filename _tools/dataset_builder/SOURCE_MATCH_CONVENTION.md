# Source → variable match for secondary-data items

Tool: `_tools/dataset_builder/source_match.R` (base R, no packages).
Scope: any item whose table carries values compiled from other papers and keys them to a
reference list — by letter (Kaskan `ref` a–t), number (DeCasien `References` `24,51-52`,
Stephan 1991 `Reference_keys` `8; 40`), or author-year (Heesy, Ruf & Geiser, Mooney).

The paper gives the key *per row* (or per cell). It usually does **not** say which variable
each source supports. This tool produces that list — one row per (data row, variable,
individual reference) — as a **preliminary** attribution for checking, and a ref × variable
summary with the species each pair covers. It changes no value anywhere (reporting, not
repairing).

## How the repo already does it (survey, Oct 2026)

| layout | count | notes |
|---|---|---|
| `reference_tables/<Item>_references.csv` with `ref_key, cited_in_column, citation, note` | 20 | the documented form (`__HOWTO_build_a_dataset_file.md` §8: "item-scoped and join-ready") |
| top-level built item `<Paper>_References.csv` / `_referencesbraindata.csv` with `ref_number, citation` (or `ref, table_heading_citation, full_reference`) | 6 | Kaskan, Iwaniuk, DeCasien ×2, Lewitus; what the restricted `*_refs_check` pipelines consume (C2) |
| ad hoc (`ref_number, short, full_citation`; `source_number, citation`; paper-level lists) | ~8 | Seymour, Veilleux, Boyer, Baker, Jung, MedinaGonzález |

Where the key sits in the data table: a **row-level** column (Kaskan `ref`, DeCasien
`References`, Stephan `Reference_keys`, Ruf `references`) in 17 items; **variable-specific**
columns (Iwaniuk `Depth_Ref`/`Length_Ref`, Seymour `Body_mass_ref`, Veilleux `src_VA`…,
Heesy `binocular_visual_field_reference`) in 5; **caption/text only** in 2 (Elston Table 6,
Fritsches Fig. 2). Nothing joined the two layers back together before this tool; Kaskan's
`TableS1.R` merges the citation string into every row (one-off), Lewitus has a per-item
rollup hard-wired to its supplement.

`cited_in_column` was being used with two meanings — the column that *holds the key*
(most files) and the data column the reference *supports* (Lyamin footnote `e`). The second
meaning now has its own file (below); `cited_in_column` means the former.

## The convention

All files sit in the paper folder's `reference_tables/`; `<Item>` is the item CSV name.

### 1. `<Item>_references.csv` — the reference list (input, hand-transcribed)

`ref_key | cited_in_column | citation | note`

- `ref_key` — the printed key **verbatim**: `a`, `24`, `10a`, `Dunlop et al. (1998)`,
  `ref. 30`. One row per **individual** key; a printed range `51-52` is two rows (C2).
  Unique.
- `cited_in_column` — the column of `<Item>.csv` that holds the key (exact name), or
  `caption` / `text` when the key is not in a cell.
- `citation` — the full bibliographic entry. Leave empty only when the paper prints none
  (Stephan 1991 Table 5 "no full entry invented"); the tool flags it
  `reference_without_citation` but still matches the key.
- `note` — free text. A footnote letter that is not a citation (Lyamin `e`) belongs here
  with an empty `citation`, and is reported `reference_never_cited` — that is correct.

Legacy column names are accepted (`ref`, `ref_number`, `source_number` → `ref_key`;
`full_reference`, `full_citation` → `citation`); the console line says
`legacy columns ref/full_reference` when it had to. New files use the canonical names.
Top-level `<Paper>_References.csv` built items stay where they are (the restricted pipelines
read them); the driver maps them in `SM_LEGACY_REFS`.

### 2. `<Item>_reference_columns.csv` — which key column attributes which variables (curated)

`key_column | applies_to | separator | note`

- `key_column` — a column of `<Item>.csv` holding keys.
- `applies_to` — `*` (every data column of the row) or a `; `-separated list of data
  columns. This is the fact the paper left implicit; declaring it is the curator's call.
- `separator` — only when the printed cells use one the parser does not infer (rare).

**Optional.** Without it the tool auto-detects key columns (from `cited_in_column`, then
from names matching `ref|reference|source_ref_key|src_|_ref$`…, dropping columns whose
values are the item name) and guesses scope: a single key column → `*`
(`row_level_default`); `Depth_Ref` → `Depth` (`stem_match`, stem ≥ 3 characters, generic
stems `source`/`ref`/`key` never used); otherwise `unresolved_key_scope`. The guess is
written to `<Item>_reference_columns_proposed.csv` with a `basis` column. **Review it,
rename to `_reference_columns.csv`, edit `applies_to`.** The proposed file is never read
back; once a declaration exists every attribution carries `match_basis = declared`.

### 3. Outputs (regenerated on every run; do not hand-edit)

| file | grain | columns |
|---|---|---|
| `<Item>_source_match.csv` | (row, variable, individual ref_key) | `item, row_id, species, key_column, key_cell_as_printed, n_keys_in_cell, ref_key, citation, variable, value, match_basis, status` |
| `<Item>_source_match_summary.csv` | (ref_key, variable) | `item, ref_key, citation, variable, key_column, n_rows, n_species, species, n_rows_shared_key, match_basis, status` |
| `<Item>_source_match_issues.csv` | one row per thing the join could not settle | `item, issue, key_column, ref_key, row_id, species, variable, detail` |
| `_checks/source_match_index.csv` | one row per item (driver) | status and counts per item |

`row_id` is `Row_ID` when the item has one, else `r001…`; `species` is the first of
`species / Species / species_sci / Species_Name / species_as_published / taxon /
taxon_as_published`, NA for a results table with no species rows. A cell is *empty* (not
attributed) when it is `NA`, blank, `-`, `—`, `–`, `.` or `?`. Data columns are all columns
except the key columns, the species column and provenance/metadata names
(`source`, `note`, `Row_ID`, `source_*`, `*_as_published`, `full_reference`, …).

Vocabularies:

- `status` (match rows): `matched` · `matched_shared_key` (the cell cites ≥ 2 keys — the
  paper does not say which supports this value) · `matched_citation_missing` ·
  `key_not_in_references`.
- `match_basis`: `declared` · `row_level_default` · `stem_match`.
- `issue`: `key_not_in_references` (a cited key with no reference row — fix the references
  file) · `reference_never_cited` (listed, never used by this item — expected when the list
  covers the whole paper, e.g. Iwaniuk 45 of 69) · `reference_without_citation` ·
  `value_without_key` (a filled cell in a row with no key: the paper's own data, or a gap) ·
  `key_without_values` · `residual_text_in_key_cell` (text in the key cell that is not a
  key: `this study`, `Figure 3 caption`, `unpublished data`) · `unresolved_key_scope`.
- driver `status`: `OK` · `REVIEW` (unknown keys or unresolved scope) · `DECLARE` (no key
  column detectable — write the declaration; also primary-data tables whose "reference" is
  the item itself) · `NOT_ITEM_SCOPED` (a paper-level `<Paper>_references.csv` with no
  `<Paper>.csv` item — split it per item or map it in `SM_LEGACY_REFS`) · `ERROR`.

### 4. What fails and what reports

Fails (`stop()`): missing item or references file; no key / citation column; duplicated
`ref_key` with differing citations; an unexpanded range in `ref_key`; a declared column that
does not exist; `strict = TRUE` with unknown keys or unresolved scope. Everything else is a
row in the issues file — a disagreement between the table and its reference list is a
**finding about that item**, recorded, never silently dropped. All CSVs are written UTF-8
with BOM and the bytes are verified on read-back (C6).

### 5. Workflow

From R (RStudio or Rscript), with the working directory anywhere inside the repo:

```r
source("_tools/dataset_builder/load_dataset_builder.R")   # house entry point; also loads source_match.R
root <- repo_root()                                        # walks up to __ReadMe.xlsx

# one item -- writes the three CSVs (+ *_reference_columns_proposed.csv) into its reference_tables/
r <- build_source_match(file.path(root, "Kaskan_etal_2005"), "Kaskan_etal_2005_TableS1",
                        refs_file = file.path(root, "Kaskan_etal_2005/Kaskan_etal_2005_References.csv"))
r$summary; r$issues

# dry run first: everything goes to a scratch folder, nothing in the repo changes
idx <- source_match_all(root, out_dir = file.path(tempdir(), "source_match"), write_repo = FALSE)
idx[idx$status != "OK", c("item", "status", "message")]

# write mode: outputs into each paper's reference_tables/, index to _checks/source_match_index.csv
idx <- source_match_all(root)
```

`source_match_all()` is idempotent: it only writes the four `*_source_match*` /
`*_reference_columns_proposed.csv` files per item and the index, overwriting its own earlier
outputs; it never touches `<Item>.csv`, `<Item>_references.csv` or a curated
`<Item>_reference_columns.csv`. Restrict to some papers with `papers = c("Kaskan_etal_2005", …)`.
Items that need a hand step are listed in the index: `DECLARE` / `REVIEW` → edit the proposed
file, rename it `<Item>_reference_columns.csv`, rerun; `NOT_ITEM_SCOPED` → split the
paper-level list per item or add a row to `SM_LEGACY_REFS`.

Put the `build_source_match()` call at the end of the item's build `.R` (after the CSV is
written) so the match is regenerated with the item; `source_match_all()` is the repo-wide
check. It belongs in the **unrestricted** repo: it reads only the public item and its
reference list and writes derived tables next to them; the restricted `*_refs_check`
pipelines can read `<Item>_source_match.csv` as their `source_per_cell` baseline instead of
re-deriving it (same one-row-per-individual-key contract).

### 6. Worked examples

- **Kaskan_etal_2005_TableS1** (letter keys, row-level `ref`): 30 rows × 11 area columns,
  20 references → 208 attributions, 149 ref × variable pairs, 0 issues. Krubitzer & Kaas
  (1993) (`a`) supports V1, V2, visual_other, SI_3b, SII … for *Aotus trivirgatus* and
  *Callithrix jacchus*; rows citing `e,f` are `matched_shared_key`.
- **Veilleux_Kirk_2014_SupplementalTable1** (four `src_*` columns): auto-detection cannot
  scope them → `DECLARE`. With `src_VA → visual_acuity_cdeg`, `src_AD_BM →
  eye_axial_diameter_mm; body_mass_kg_VK; Body_mass.g`, `src_D_AP → diet; activity_pattern`,
  `src_MRS → max_running_speed_kph` declared: 731 attributions, 213 pairs.
- **DeCasien_Higham_2019_BrainRegionDatamm3**: `24,51-52` → keys 24, 51, 52, each attributed
  to every filled region column of the row, `n_keys_in_cell = 3`.
