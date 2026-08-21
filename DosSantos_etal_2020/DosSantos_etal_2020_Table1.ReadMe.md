# Dos Santos et al. (2020) — Table 1 (PUBLISHED, main PDF)

Dos Santos, S. E., et al. (2020). Similar Microglial Cell Densities across Brain Structures and
Mammalian Species. *J Neurosci* 40(24), 4622-4643. https://doi.org/10.1523/JNEUROSCI.2339-19.2020

## ⚠ Status — superseded by the authors' unpublished data (do NOT use for cell numbers)

The published Table 1 (main PDF) contains **transcription/typographical errors in several cell-count
values**, some physically impossible (neurons or microglia exceeding the total cell count of the same
structure). The clearest example is *Tragelaphus strepsiceros* whole-brain total cells
(`Br_C` = 21,751,929), which is ~1000× too small — the authors' value is 21,751,929,128 (the published
figure dropped its last three digits, which is why its neurons and microglia exceed it).

The authors supplied an updated **unpublished** spreadsheet
(`2020-PublishedDataMammalsMicroglia - cópia.xlsx`; received 22 Mar 2024 via Orlin S. Todorov from the
authors' team, Alex Tikky). Independent checks show the unpublished data is internally consistent and
agrees with older publications (e.g. Herculano-Houzel et al. 2015).

**We therefore use `DosSantos_etal_2020_unpublished` — not this published Table 1 — in the merged
cell-counts dataset** (`__merging_cellcounts/cellcounts_compiled.R`, where this item is commented out).
This file is retained only as a faithful **snapshot** of the published table, for the audit trail.

- Check script: `DosSantos_etal_2020_Table1_check.R` — moved to the private repo Evo-M1-Trait-Data-restricted, `restricted_checks/_cross_table/DosSantos_2020_published_vs_authors_unpublished/` (it reads the authors' unpublished spreadsheet, so it cannot be public)
- Comparison report: `DosSantos_etal_2020_comparison_report.csv` (every species × structure × measure)
- Narrative summary: `DosSantos_etal_2020_comparison_summary.md`

## Pipeline (how this snapshot/CSV was made)

**Source.** Read into R from the online PDF: https://www.jneurosci.org/content/jneuro/40/24/4622.full.pdf
Table 1 (specimen data) spans three pages.

**Snapshot.** Table 1 read as several matrices (one per page) with the `tabulizer` package and formatted
into a faithful copy → `DosSantos_etal_2020_Table1_snapshot.csv`.

**Data readable.** Removed spaces inside numbers and made numeric; emptied `NA`s and removed `*`; pivoted
to reorganise by `Structure` → `DosSantos_etal_2020_Table1.csv` (reference snapshot only — see Status above).

**Online database.** TSV copy named with DOI added to https://github.com/r03ert0/comparative-data
(`10.1523%2FJNEUROSCI.2339-19.2020%0A_Table1.tsv`).
