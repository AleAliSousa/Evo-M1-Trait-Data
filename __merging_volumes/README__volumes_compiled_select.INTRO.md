> This block is hand-written (`README__volumes_compiled_select.INTRO.md`) and is spliced into the
> generated README on every run. Everything below it is regenerated — edit this file, not that one.

## What this is

A third sibling to `volumes_compiled.R` (the full collection) and `volumes_compiled_DeCasien.R`
(the DeCasien subset): a merge of a **hand-chosen** set of tables, treated as **one evolving
dataset**, where the most recent measurement of each species x structure supersedes the older ones
— *except* where a value has been flagged as one that must not be used, however recent it is.

Three files make it work, and only these three should ever need editing:

| File | What it controls |
|---|---|
| `volumes_compiled_select.R` → `select_datasets` | which tables are in, what team each belongs to, and the year used for recency |
| `volumes_select_value_flags.csv` | which individual values are vetoed, reviewed, or explicitly kept |
| `README__volumes_compiled_select.INTRO.md` | this prose |

Everything else — the merge, the audit CSVs, and the rest of this README — is regenerated.

## The value-flag registry

`volumes_select_value_flags.csv` has seven columns:

| Column | Meaning |
|---|---|
| `Source` | item name. Exact, or `*` for all, or a trailing-`*` prefix match (`Stephan_etal_1981_Table*`) |
| `Species` | resolved (accepted) species name, or `*` / blank for all |
| `Variable` | standardized term, or `*` / blank for all, or a prefix match (`Area_striata_*`) |
| `flag` | short tag that groups the entry in this README (`secondary_compilation`, `derived_residual`, `unverifiable`, `taxonomy_lump`, …) |
| `action` | `skip` = never use this value, however recent · `review` = use it but list it here · `keep` = explicitly un-skip, to carve an exception out of a broader `skip` row |
| `reason` | prose. This is what gets printed in the "why" blocks below, so write it for a reader |
| `evidence` | where the decision is documented (a findings file, a registry column, a paper) |

The **most specific** matching row wins (`Source` beats `Species` beats `Variable`); among equally
specific rows, the one **last in the file** wins. A `skip` is applied *before* the recency pick, so
the next-most-recent unflagged value takes over — and if nothing else covers the cell, the variable
simply drops out of the merge and says so below.

## Decisions baked into version 1 of the selection

- **Smaers et al. 2017 is in, but six of its eight columns are vetoed.** It is the newest table, so
  on recency alone it would supersede everything it touches — but `crosspub_Smaers2017_FINDINGS.md`
  and the `Flags pre-addressed` column of `__ReadMe.xlsx` establish that it is a compilation.
  `primary_visual` is Frahm et al. 1984's area striata (value-matched exact), `prefrontal` is Smaers
  et al. 2011 Suppl. Table 2, `other_association` is a derived residual. Only `frontal_motor`
  survives, flagged `review` because it was never published anywhere it can be checked.
  Its numbers are printed as mm³ but are cm³ — the reshape multiplies by 1000.
- **de Sousa 2010 is Table 1 only.** Supplementary Table 2 carries a known value error (neocortex
  mis-copied from Stephan 1981 for 17 strepsirrhine/tarsier species; 13 of them exceed brain volume).
  Add it to `select_datasets` with a `skip` row on its neocortex column if you need its bilateral
  V1/LGN means.
- **de Sousa 2010's left-only V1 and LGN are not doubled.** Step 7 turns one-side volumes into
  both-sides ones, but `bilateral_stems_exclude` holds these two back, because the paper's own
  Supplementary Table 2 has the real bilateral means. Remove them from that vector to let the 2x
  estimate through (it would be flagged, never silent).
- **Same-year ties go to the earlier row in `select_datasets`.** MacLeod 2003 Table 1 (Yerkes) and
  Table 2 (Hirnforschung) are different samples of the same year; Table 1 is listed first, so it
  wins for the nine species in both. Set `tie_rule <- "mean"` to average them instead — every tie is
  listed below either way.
- **Body and brain mass stay pinned to Stephan 1981 Tables I–III**, as in `volumes_compiled.R`; set
  `mass_rule <- "recent"` to treat them like any other variable.
- **Species names resolve exactly as in the full merge** (curated overrides beat NCBI, source-aware).
  Unlike `volumes_compiled.R` this script never rewrites `volumes_species_ids_cache.csv`, and a name
  the cache has not seen is a warning rather than a hard stop.

## Running it

    Rscript volumes_compiled_select.R          # or open in RStudio and Source

Needs the full repo (it reads `__ReadMe.xlsx`, `__Public/comparative-data/` and `_keys/`), plus
`tidyverse` and `readxl`. `taxizedb` is optional — without it the committed NCBI cache is used.
`_verify_volumes_compiled_select.py` is an offline mirror of the same logic for checking the
resolution on a machine without R; `volumes_compiled_select.R` is authoritative.
