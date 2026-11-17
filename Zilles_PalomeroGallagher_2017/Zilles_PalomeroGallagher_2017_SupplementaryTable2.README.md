# Zilles & Palomero-Gallagher 2017 — Supplementary Table 2 (human cortical receptor densities by stratum)

Zilles K, Palomero-Gallagher N (2017). *Multiple Transmitter Receptors in Regions and Layers of the Human
Cerebral Cortex.* Front. Neuroanat. 11:78. doi:10.3389/fnana.2017.00078.

Registry (`__ReadMe.xlsx`): Item name **`Zilles_PalomeroGallagher_2017_SupplementaryTable2`** (owner-registered row,
Item number "Supplementary Table 2"), encoded `10.3389%2Ffnana.2017.00078_SupplementaryTable2`.
The build brief named this item `..._TableS2`; the registry row already existed under
`..._SupplementaryTable2`, and the registry is the authority, so every file here uses that name.

## ⚠️ Single-species (human) reference — not comparative across species
Quantitative in vitro receptor autoradiography in **3 post-mortem human brains** (Materials and Methods:
"Brains of three donors ... age range: 72–77 years; 2 males, 1 female"; post-mortem delay 8–18 h).
One species only; it contributes human regional data points (notably **primary motor cortex, area 4**)
to the comparative dataset. The Supplementary Tables 3–6 are discriminant-analysis / Wilcoxon p-value
tables (derived statistics, cf. build HOWTO §7) and are deliberately **not built**. Supplementary Table 1
(incubation conditions) is a methods table and is kept as a small reference CSV (below), not as an item.

## What the data are
**15 receptors × 44 cortical areas × 4 strata = 2640 rows** (long format). Per area, receptor and
stratum: mean receptor density in **fmol/mg protein** (`density_fmol_mg_protein`), its **SD** (`sd`) and the
printed **CV** (`cv`). Receptors (plain names, printed block order): AMPA, NMDA, kainate, GABAA, GABAA/BZ,
GABAB, M1, M2, M3, alpha4beta2, alpha1, alpha2, 5-HT1A, 5-HT2, D1. Areas: 1, 2, 3a, 3b, V1, V2d, V2v, V3A,
V3d, V3v, V4v, FG1, FG2, 37B, 37L, 37M, 41, 42, 20, 21, 22, 36, 38, 5L, 5M, PGa, PGp, PFt, PFm, 24, 32, 23,
31, 4, 6, 8, 9, 10L, 10M, 11, 44, 45, 46, 47 (printed order kept in `printed_order`).

**Strata** (Materials and Methods): supragranular = layers I–III, granular = layer IV, infragranular =
layers V–VI; **`all_layers`** is the density averaged over the whole cortical depth (printed "all layers").
Areas 4 and 6 have no clearly recognisable layer IV; the authors "tentatively defined layer IV of areas 4
and 6 as stripe with a thickness of 3% of the total cortical depth below the lower border of layer III",
so granular values ARE printed for 4 and 6. Only **area 24** prints `--` for the granular stratum (15
receptors × 1 stratum = 15 blank cells, kept blank; absent in print is not zero).

**Flags from the printed highlighting** (caption: "Primary sensory areas are highlighted in yellow, the
primary motor cortex in grey"): the snapshot script reads the fill rectangles behind each row, so
`is_primary_sensory` = yellow rows (**3b, V1, 41** in all 15 blocks) and `is_M1` = grey rows (**area 4**
in all 15 blocks). The colours were recovered from the PDF, not inferred from area identity;
`highlight_as_printed` keeps the raw colour.

## Source → Snapshot → Data readable  (printed PDF → generated snapshot)
Source: Frontiers supplementary file `supplementary_downloads/Table_2.pdf` (24 pages, text layer; download
URL, bytes and sha256 in `supplementary_downloads/download_manifest.csv`, downloaded 2026-11-15).

- **Reader**: `Zilles_PalomeroGallagher_2017_SupplementaryTable2_snapshot.py` (Python, pdfplumber; environment `neuro-atlas`), run
  2026-11-15 by the AI assistant (Claude). It pulls every printed row from the text layer with an
  anchored regular expression (`Region mean (SD) CV` × 4 strata) and the highlight colour from the page
  fill rectangles; no table value is typed in the script. It asserts 15 blocks × 44 areas, identical area
  order in every block, and refuses to overwrite a differing frozen copy unless run with `--force`.
  *Why Python and not R/pdftools:* pdftools exposes the text layer only; the highlighting that carries the
  primary-sensory / M1 meaning is a fill rectangle and is only reachable with pdfplumber.
- **Snapshot**: `Zilles_PalomeroGallagher_2017_SupplementaryTable2_snapshot.csv` — 660 rows (one per printed area row, 15 receptor
  blocks × 44 areas), printed layout kept: `page, receptor_block, receptor (as printed), Region,
  supragranular, (SD), CV, granular, (SD), CV, infragranular, (SD), CV, all layers, (SD), CV, highlight`.
  SD kept in parentheses, `--` kept as printed, receptor block labels kept exactly as the text layer
  renders them (e.g. `kaina te`, `GABA ᴀ`, `α₄β ₂`).
- **Build**: `Zilles_PalomeroGallagher_2017_SupplementaryTable2.R` (reads the snapshot only) → **`Zilles_PalomeroGallagher_2017_SupplementaryTable2.csv`** (use
  this) + public TSV `__Public/comparative-data/10.3389%2Ffnana.2017.00078_SupplementaryTable2.tsv`.
  Cleaning done there: positional read; parentheses stripped; `--` → blank; receptor block label → plain
  receptor name by block order, guarded by a glyph-normalised comparison of the printed label; reshape
  to long (one row per area × receptor × stratum); flags from `highlight`. Column meanings:
  `reference_tables/Zilles_PalomeroGallagher_2017_SupplementaryTable2_definitions.csv`.

Units: **fmol/mg protein** kept (source unit; a receptor-density measure class, no conversion).

## QA — independent transcription (Hansen et al. 2022)
Cross-checked 2026-11-15 against the independent transcription by Hansen et al. (2022) in
`Hansen_etal_2022/github_hansen_receptors/data/autoradiography/ReceptData*.npy` (44 areas ×
15 receptors; `RegionNames.npy` order = this table's printed order, `ReceptorNames.npy` order = printed
block order):
- all layers (`ReceptData.npy`): **660 / 660 exact matches**, 0 mismatches
- supragranular (`ReceptData_S.npy`): 660 / 660; infragranular (`ReceptData_I.npy`): 660 / 660
- granular (`ReceptData_G.npy`): **645 / 645** printed values match; the 15 area-24 cells that the PDF
  prints as `--` are stored as 0 in Hansen's array — kept blank here (the PDF is authoritative; a dash is
  not a zero).
No discrepancy remained, so no PDF page had to be re-read for a value. The comparison was run in the
build session (not kept as a comparison folder: house rule — no comparison folders in the public repo).

## Table checks (HOWTO §7a)
The caption prints SD and "variation coefficients (VC)" side by side, so the build script checks the
implied relation **CV = SD / mean** to the last printed decimal (tolerance 0.001 plus what rounding of
the printed integer mean and SD can explain) and leaves the result in `table_checks`. Result from the R
run of 2026-11-15: **1191 pass, 1434 mismatch, 15 not evaluable** (area 24 granular). Mismatches occur in
every receptor and every stratum (e.g. M1 153 of 175, kainate 135, GABAA/BZ 133; fewest for D1, 42) and
are large (median |difference| 0.22; max 1.23 for alpha4beta2 area 20 granular: printed 0.001 vs SD/mean
1.229). The printed CV is therefore **not** the CV of the printed mean and SD; what it is computed over
is not stated in the paper or the supplement. All values are kept exactly as printed; `cv` is carried as
`info` and should not be used as SD/mean. With 1434 mismatches the individual rows are not listed here —
re-run the build script and inspect `table_checks[table_checks$status == "mismatch", ]`.

## Related reference tables
- `reference_tables/Zilles_PalomeroGallagher_2017_SupplementaryTable1_incubation_conditions.csv` — the
  ligand, ligand concentration (nM), displacer and displacer concentration (µM), pharmacological class,
  incubation buffer and timing per receptor, transcribed by the AI assistant on 2026-11-15 from
  `supplementary_downloads/Table_1.pdf` (text layer, checked visually against both pages). Kept as
  printed, including the supplement's "(ionotropic, excitatory)" label for M3 (M3 is metabotropic);
  "*" = substance only present in the main incubation buffer.
- `_keys/General/species_key.csv` — row added for `Zilles_PalomeroGallagher_2017` (Homo sapiens, 9606).

## Owner notes
- Registry row 'Supplementary Table 2' exists; `Zilles_PalomeroGallagher_2017_SupplementaryTable2_registry_row.xlsx` carries
  the descriptive columns (O→AM) to paste as values into that row (do not add a new row).
- Area labels mix Brodmann numbers and Julich-Brain names; the Julich-Brain mapping used for the
  metabolic analyses lives in the analysis repo (`metadata/anatomy/s1e_zilles2017_julich_area_map.csv`),
  not here.
- Supplementary Tables 3–6 (p-values) are not built (derived statistics).

Pipeline: Source → Snapshot ✅ (generated, 2026-11-15) → Data readable ✅ → definitions ✅ → README ✅ →
public TSV ✅ (item was already registered) · single-species human reference (M1 = area 4, grey rows).
