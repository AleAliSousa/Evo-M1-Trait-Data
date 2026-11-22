# Dos Santos et al. (2020) — Table 1 (published, main PDF)

Dos Santos, S. E., et al. (2020). Similar Microglial Cell Densities across Brain Structures and
Mammalian Species. *J Neurosci* 40(24), 4622-4643. https://doi.org/10.1523/JNEUROSCI.2339-19.2020

## Status — used in the cell-counts merge, with errata

This item is the Dos Santos et al. (2020) source for `__merging_cell_counts_isotropic_fractionator`.
The CSV, the snapshot and the public TSV carry the table **as printed**.

Table 1 prints a small number of wrong values, some physically impossible (*Tragelaphus strepsiceros*
whole-brain cells below its own neuron count; *Procavia capensis* cerebellar neurons above its total
cells). They were found by checking the paper against itself (`internal_checks/`), are recorded in
`reference_tables/DosSantos_etal_2020_errata.csv`, and ten of them are corrected in the merge by a
guarded step (3.4e). The errata table, the check and its result are described in the folder note
[`DosSantos_etal_2020.README.md`](DosSantos_etal_2020.README.md).

What the columns are (Table 1 footnote a, p. 4627; see `reference_tables/DosSantos_etal_2020_Table1_definitions.csv`):

- **Structure mass, C, N, N/mg** — values published previously, re-reported. In the merge the primary
  tables outrank this item for these measures.
- **I/mg, I/N** — measured in this study, on the samples available.
- **I** — derived in the table as (I/N) × N.
- Rows marked `*` are from a single specimen; rows marked `**` have no totals (some cortical sites only).

## Pipeline (how this snapshot/CSV was made)

**Source.** Read into R from the online PDF: https://www.jneurosci.org/content/jneuro/40/24/4622.full.pdf
Table 1 (specimen data) spans three pages (pp. 4625–4627).

**Snapshot.** Table 1 read as several matrices (one per page) with the `tabulizer` package and formatted
into a faithful copy → `DosSantos_etal_2020_Table1_snapshot.csv`. The cells behind every erratum were
read again on the PDF page (2026-11-21); the snapshot matches the print in each.

**Data readable.** Removed spaces inside numbers and made numeric; emptied `NA`s and removed `*`; pivoted
to reorganise by `Structure` → `DosSantos_etal_2020_Table1.csv`.

**Online database.** TSV copy named with DOI added to https://github.com/r03ert0/comparative-data
(`10.1523%2FJNEUROSCI.2339-19.2020%0A_Table1.tsv`).
