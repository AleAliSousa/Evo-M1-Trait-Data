# Van Essen & Drury 1997 — Table 1 (Visible Man cortical surfaces) + text V1

Van Essen DC, Drury HA (1997). *Structural and functional analyses of human cerebral cortex using a
surface-based atlas.* J Neurosci 17(18):7079–7102. doi:10.1523/JNEUROSCI.17-18-07079.1997.

Registry (`__ReadMe.xlsx`): row currently named **`VanEssen_etal_1997_Table1`**, encoded
`10.1523%2FJNEUROSCI.17-18-07079.1997_Table1`.

## ⚠ Registry fixes pending (owner, one Excel sitting)
The row's citation carries a reference-manager artifact author "New Collective, A." — the paper has
exactly **two authors** (verified against the PDF in this folder, title page). Rename the row to
`VanEssen_Drury_1997_Table1` (matches the products here) and fix the citation. The encoded key is
DOI-based and does not change. Until the rename, `file_list.R` will not match this item and the .R
script's registry lookup warns and skips the TSV (the TSV was written offline, see below).
Also set Progress stage / Snapshot cells.

## What the data are
Cortical surface areas of **one human individual** — the Visible Man (Visible Human Project, NLM;
digital atlas from 1 mm section images of a single adult male cadaver). Per hemisphere: total
neocortex (L 766 / R 803 cm²), frontal, temporal, parietal, occipital, limbic lobes, and
sulcal/gyral totals (Table 1); plus **V1** (L 26 / R 22 cm²) from the Results text ("average-sized
V1", Rademacher et al. 1993 architectonic extents mapped onto the atlas). 18 rows.
Areas are tile-area sums on the 3-D reconstructions, **not** flat-map areas; the authors call
their total a likely slight underestimate. Values are **per hemisphere** (no doubling needed).

## Source → Snapshot → Data readable
Table 1 transcribed verbatim (`"766 (100)"` strings) to sheet `Table1` of
`VanEssen_Drury_1997_Table1_snapshot.xlsx`; the two text V1 values with their quoted comparison
ranges (Stensaas et al. 1974; Filiminoff 1932) on sheet `text_V1`.
`VanEssen_Drury_1997_Table1.R` → `VanEssen_Drury_1997_Table1.csv` (**use this**): value/percent
split, structures renamed to standard terms. Columns in
`reference_tables/VanEssen_Drury_1997_Table1_definitions.csv`.
Built offline 2026-08-31 (Python mirror; no R in sandbox) — **re-run the .R in RStudio after the
registry rename to confirm** (expect byte-identical CSV/TSV).

## Merge note — NOT yet wired
Candidate for `__merging_cortical_areas` (human whole-neocortex + lobes + V1, n=1 digital-atlas
specimen). Roadmap: chase the paper's cited Filiminoff 1932 / Stensaas et al. 1974 human V1
primaries as their own sources; those ranges are provenance context here, not data rows.
Sulcal/gyral totals and the derived gyrification discussion (GI 3.3 vs Zilles et al. 1988's 2.55)
are provenance only.

Pipeline: Source ✅ → Snapshot ✅ → Data readable ✅ → Registry rename ⬜ → R rerun ⬜ → Merge ⬜
