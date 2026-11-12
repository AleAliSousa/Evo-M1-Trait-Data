# Nykjær_etal_2017_Table2

**Item name** `Nykjær_etal_2017_Table2` · **Item number** `Table 2` · **Item encoded** pending
registration (expected `10.1002%2Fmds.26979_Table2`)

Nykjær, C. H., Brudek, T., Salvesen, L., & Pakkenberg, B. (2017). Changes in the cell population in brain white matter in multiple system atrophy. *Movement Disorders*, 32(7), 1074–1082. <https://doi.org/10.1002/mds.26979>

**Item full original title:** TABLE 2. *Estimate of total cell number* (p. 1078, PDF page 5).

## Folder name

The first author is printed **Nykjær** (æ). Following the repo's diacritic folders (`Møhl__1968`,
`Sjölin_etal_2022`) the folder keeps it, in Unicode NFC. The build script compares names in NFC
(via `stringi` when installed) so a decomposed file-system name still matches the registry. The
PDF keeps its original filename `Nykjaer-2017-Changes in the cell population in.pdf`.

## Source

Born-digital typeset PDF (Wiley), so the table is a *printed* table: a transcribed snapshot is the
frozen source. **Groups:** `Control` = **healthy control group** — 11 neurologically healthy subjects
(5 M / 6 F, 68 [60–75] y, Table 1 of the paper); `MSA` = 10 patients with multiple system atrophy.
The CSV keeps both printed groups; `is_healthy_control = 1` marks the Control rows.

Counts are **bilateral** (Nv × the uncorrected paraffin reference volume of one hemisphere × 2;
Methods p. 1076) for the whole cerebral white matter: subcortical white matter, corpus callosum,
internal and external capsules, anterior and posterior commissures. Paraffin, 40 µm sections,
modified Giemsa; mean shrinkage 36% (controls) — **not corrected** in the counts. White-matter
volumes and densities are not reported ("data not shown").

## Pipeline

```
Source (PDF p. 1078)
  -> Nykjær_etal_2017_Table2_snapshot.csv   FROZEN: transcription in the printed layout
  -> Nykjær_etal_2017_Table2.R              clean + reshape
  -> Nykjær_etal_2017_Table2.csv            8 rows = 4 cell types x 2 printed groups ("use this")
  -> __Public/comparative-data/<Item encoded>.tsv   (written once registered)
  -> reference_tables/Nykjær_etal_2017_Table2_definitions.csv
```

## Who read the values, when, and how it was checked

Transcribed by an **AI assistant (Claude) on 2026-11-11** from a 500-dpi render, typed into the frozen
CSV, then compared cell by cell with the PDF text layer (identical; the layer writes `×` as `3` and
`10⁹` as `109`) and with the staged extraction (all 4 control values present). Snapshot structure:
row 1 caption, rows 2–3 the two-level header (`Control` / `MSA` spanning `Total number`, `CV`, blank
padding under each spanner), rows 4–7 the cell types, row 8 the legend. `× 10⁹` is written `× 10^9`.
The `**` after two P values is kept; the table prints no footnote defining it.

## Table checks

Table 2 prints no totals or other self-checking relation, so the script has no `table_checks`.
Consistency with the Results text (p. 1078), not a table check: neurons + three glia types =
43.7 × 10⁹ = the printed "total white matter cells" of the controls; the glia sum 42.6 × 10⁹ vs the
printed 42.7 × 10⁹ and the control percentages (90.8 / 7.5 / 1.7%) agree within rounding of the
printed one-decimal means. The text also prints control ranges (e.g. oligodendrocytes 29.5–49.5 × 10⁹)
that are not built here.

## Data role

**Proposed: `primary`**. The paper states that the hemispheres "have been included in previous studies" (Methods p. 1075, refs 9, 16, 18, 19 = Sigaard et al.; Karlsen & Pakkenberg 2011, *Cereb Cortex*; Salvesen et al., *Neurobiol Dis*; Karlsen et al., *Neuroscience*, mediodorsal thalamus). Which control hemispheres overlap is not stated — check before pooling with `Karlsen_Pakkenberg_2011` items.

## Species names

The paper prints no binomial; the species is `human` (title/text), kept verbatim in
`species_as_published`. No `_keys/` file was edited. A proposed row (`human` → *Homo sapiens*,
NCBI 9606, collection General) is in `reference_tables/Nykjær_etal_2017_species_key_proposed.csv`; adopt it
into `_keys/General/species_key.csv` before this item enters a species-resolving merge. The
counting method should also be recorded in `_keys/cell_count_methods/source_methods.csv`
(proposed: `STEREO_DISECTOR`, target `cell_counts_histology`) — not done here (no `_keys/` edits).

## Registration

Not yet in `__ReadMe.xlsx`. The proposed Sheet1 row is `Nykjær_etal_2017_Table2_registry_row.xlsx` in this folder
(see its HOW_TO_PASTE sheet). Until the owner pastes it and runs `_tools/file_list.R`, the build
writes the CSV only and prints `not yet registered - TSV skipped`; once `Item encoded` resolves,
the same script writes `__Public/comparative-data/<Item encoded>.tsv`.

## Human visual check of snapshot

Pending. An AI assistant transcribed and checked the snapshot against the page images. A human
still needs to read a few rows **across** beside the page (including mid-table rows) and record
`DDMMYYYY_initials` in the `Human visual check of snapshot` column.
