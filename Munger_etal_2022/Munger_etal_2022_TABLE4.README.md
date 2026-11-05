# Munger et al. 2022 — TABLE 4 (area 9 glia, astrocyte and GLUT1 vessel measures, by species)
Munger EL, Edler MK, Hopkins WD, Hof PR, Sherwood CC, Raghanti MA (2022). *Comparative analysis of astrocytes in the prefrontal cortex of primates: Insights into the evolution of human brain energetics.* J Comp Neurol. doi:10.1002/cne.25387.
Full title (`__ReadMe.xlsx`): **"TABLE 4 Descriptive statistics for all variables with the mean and standard deviation for each species"**

## Source -> Snapshot -> Data readable
- **Snapshot: `Munger_etal_2022_TABLE4_snapshot.csv`**, written by step 1 of `Munger_etal_2022_TABLE4.R` from p. 11 of the publisher PDF in this folder (born-digital; `pdftools::pdf_text`) **before any cleaning**. Owner decision, 04 Nov 2026, as for TABLE 1: the conversion lives in the build script and the snapshot is saved here.
- Laid out as printed: the caption row; the header row (`Variable` and the four species as printed); the 12 variable rows in printed order (label, then the four `mean ± SD (n)` cells exactly as printed); and the two table-note rows (`Note: ...`, `Abbreviation: WM, white matter.`).
- Everything is read from the text layer: caption, header cells, labels, cells and notes. Nothing is typed into the script. Anchors: the caption `TABLE 4 Descriptive statistics`, the header cell `Variable` and the note `Note: The number of individuals`.
- A printed cell that wraps onto two lines is still one cell, so the snapshot holds it in one cell:
  - labels that continue on a line starting with `(` (for example `(GFAPv, mm3)`) are joined with one space;
  - the four GLUT1 vessel-volume cells print `mean ±` on one line and `SD (n)` on the next, and are joined column by column.
- Text-layer quirks: the superscript in mm³/µm³ is a plain `3` followed by a stray space before `)`. The space is closed, so the snapshot reads `mm3)` and `μm3)`. `TABLE 4` is letter-spaced (`TA B L E 4`).
- **Frozen-file guard** as for TABLE 1: a re-run compares its extraction with the frozen snapshot byte for byte. If they differ, it writes `Munger_etal_2022_TABLE4_snapshot_NEW.csv` and stops; `keep_frozen_snapshot <- TRUE` builds from a deliberately hand-corrected frozen copy. Without the PDF in the folder, step 1 is skipped.
- **Step 2 reads the snapshot by position, never the PDF:** data rows are those with all four cells filled, and the note rows follow them. It splits each cell into mean, SD and n, and writes the long CSV and TSV.

## Output
`Munger_etal_2022_TABLE4.csv` / `__Public/comparative-data/10.1002%2Fcne.25387_TABLE4.tsv`: **long**, 48 rows = 12 printed variables x 4 species, in printed order. Columns: `species`, `species_as_published`, `variable_row`, `variable_printed`, `variable_code` (derived join key), `abbreviation_printed`, `region_printed` (`layer I` / `WM`), `unit_printed`, `value_printed`, `mean`, `sd`, `n`, `source`. Data dictionary, including one row per variable: `reference_tables/Munger_etal_2022_TABLE4_definitions.csv`.

Variables (Brodmann area 9, dorsolateral prefrontal cortex — **not M1**): total glia density (Gv) in layer I and the adjacent white matter; GFAP-ir astrocyte density (GFAPv), GFAPv/Gv ratio and GFAP-ir soma volume in layer I and WM; EAAT2-ir astrocyte density and soma volume in WM; GLUT1-ir vessel volume and area fraction in grey matter.

## Observation level
Species summaries: mean ± SD over n individuals (the individuals are listed in TABLE 1). n = 6 (*Macaca nemestrina*, *Papio anubis*, *Homo sapiens*) and 7 (*Pan troglodytes*), except n = 4 for the two chimpanzee EAAT2 rows.

## Checks
- Two PDF readers agree (build text layer vs pdfplumber word positions): 48 cells, mean, SD and n each, 0 mismatches. Rendered page compared by eye by the AI assistant.
- Snapshot vs page (4 Nov 2026, AI assistant; **not** a human check): the rendered Table 4 was read across, row by row, against the snapshot. The caption, header, all 12 rows (48 cells, including the two-line GLUT1 cells) and both note lines agree.
- **Human visual check of snapshot: pending** (`__ReadMe.xlsx` column AJ).
- Table 4 vs Table 1: every n is at most the Table 1 count for the species.
- Table 4 vs text (kept as printed, flagged): the Discussion (p. 12) gives the chimpanzee WM glia density as **287,469** per mm3; Table 4 prints **267,012** (difference 20,457). For humans the text says 120,833, the table 120,832.
- The GFAPv/Gv rows are means of per-animal ratios and cannot be recomputed exactly from the two density means (ratio of means: *Pan* layer I 0.063 vs printed 0.08). Informational only.
- Table checks (build HOWTO sec. 7a): none possible; the table prints no totals.

## Unit query
`GLUT1-ir vessel volume (mm3)`: values of 1.06e8 to 2.22e8 cannot be mm3 of vessel in area 9. Read as µm3 of vessel per mm3 of tissue they are 0.11 to 0.22 mm3/mm3, the same order as the printed area fraction (6–12%). Kept as printed and **not converted**; flagged in the definitions and in the app label (`mm3 as printed`). Ask the authors before using it quantitatively.

## Species
Binomials printed as such; mapped through `_keys/Hof/species_key.csv` (`source_publication = Munger_etal_2022`).

## App
- **Cell counts (histology)**: 7 variables (28 species means; SDs kept in the merge), through `__merging_cell_counts_histology` since 4 Nov 2026.
  - The variables are the glia and GFAP-ir astrocyte densities in layer I and the white matter, GFAPv/Gv in both, and the EAAT2-ir astrocyte density in the white matter.
  - Labels carry the counting method, e.g. `PFC_area9_L1_glia_density [stereology] (cells/mm3)`.
  - The term map is `standardized_term_by_reference/Munger_etal_2022_TABLE4_standardized_terms.csv`. The method and routing are set in `_keys/cell_count_methods/source_methods.csv` (`STEREO_OPTICAL_FRACTIONATOR`, proposed).
  - The chimpanzee and human white-matter glia text-vs-table differences are flagged there in `value_flags.csv`.
- **Supplementary sources**: the 3 astrocyte soma volumes (until the cell-morphology merge takes them) and the 2 GLUT1 vessel measures, through `__merging_supplementary/supplementary_sources.csv` (5 mapping rows; see that README, section "Munger et al. 2022").
- Both public TSVs are in the **Source tables** tab once `__ShinyApp/build_data.R` runs (Update_ShinyApp does this).

## Comparisons
None (founder item). Related: Falcone et al. 2019 interlaminar astrocytes (frontal cortex, 47 species) in `__merging_cell_morphology`; Munger's layer I GFAP-ir astrocytes are interlaminar astrocytes in area 9.

## Reader and provenance
Values read from the PDF text layer by the build script; none typed. Script written on 4 Nov 2026 by an AI assistant (Microsoft Copilot).
- **First version (no snapshot step):** the owner's R run on 4 Nov 2026 reproduced the Python mirror: the CSV byte for byte, the TSV at the same size.
- **Snapshot step: confirmed by R.** The owner ran this script on 4 Nov 2026 (08:43). It left the frozen snapshot unchanged, so R's extraction matched the Python mirror's (no `_snapshot_NEW.csv`). It rebuilt the CSV byte for byte and the TSV at the same size.

## Registry
- `Item encoded` is `10.1002%2Fcne.25387_TABLE4`; column A's trailing space after the DOI was fixed on 4 Nov 2026.
- Snapshot columns: `Snapshot (if filename is not Item name)` stays empty (standard name). `Snapshot filetype` is `csv`. `Human visual check of snapshot` is pending.

Pipeline: Source (born-digital PDF) -> Snapshot (R step 1; confirmed by R run 04 Nov 2026) -> Data readable OK (R run 04 Nov 2026) -> Species harmonized -> Online database -> App (Cell counts (histology); Supplementary sources)
