# Dickscheid et al. 2021 — BigBrain layer-wise cell-body densities (EBRAINS dataset series, 12 items)

**Series citation (registry column A):** Dickscheid, T., Bludau, S., Paquola, C., Schiffer, C., Upschulte, E., &
Amunts, K. (2021). *Layer-specific distributions of segmented cells in different cytoarchitectonic regions of BigBrain
iso cortex* [EBRAINS dataset series; Knowledge Graph project f06a2fd1-a9ca-42a3-b754-adaa025adb10; individual dataset
DOIs in column C]. EBRAINS. https://search.kg.ebrains.eu/instances/f06a2fd1-a9ca-42a3-b754-adaa025adb10

**Registry:** 12 rows, Data series `EBRAINS_BigBrain_layer_cell_density`, Item number = the area (`Area 44` …
`Area hOc5`), column C = the dataset DOI, Item name `Dickscheid_etal_2021_Area44` … `Dickscheid_etal_2021_AreahOc5`,
Item encoded `10.25493%2F<suffix>_Area<x>`; collection token `Zilles`; Data role `primary`. The rows are read
programmatically (by the series citation in column A); nothing here is retyped from them.

## What the data are — read this before using the values
- **Species / specimen:** *Homo sapiens*, **one brain**: the BigBrain (Amunts et al. 2013, Science 340:1472), a
  65-year-old male donor (KG subject `sub-20`, brain `B20`), formalin-fixed, paraffin-embedded, 7404 sections of 20 µm,
  silver-stained for cell bodies (modified Merker 1983), scanned at 1 µm. Every value is a within-brain patch mean, not a
  species mean (definitions row `Method:observation_level`).
- **Cell type: ALL segmented cell bodies = neurons + glia** (and anything else the silver stain and the segmenter pick
  up). Segmentation is automatic (Contour Proposal Networks, Upschulte et al. 2022, score threshold 0.9; code
  FZJ-INM1-BDA/celldetection), with no neuron/glia distinction and no stereological correction. Do not pool with
  neuron-only densities without a correction.
- **Sampling:** per area, 9–11 cortical image patches (1 µm scans, full cortical depth, near-orthogonal cutting angle)
  from 7–11 sections near the centre of the Julich-Brain probabilistic map of the area, chosen by a neuroanatomist;
  layers I–VI annotated manually (microdraw, 4-eye check).
- **Unit of density as published: `# detected cells / 0.1 mm³`** (y-axis label of the dataset's `stats.pdf` and
  `report.pdf`; siibra unit string `# detected cells / $0.1mm^3$`). Per patch and layer:
  `density = n_cells_in_layer / (Area_micron² × 20 µm × 1.931^(1/3) / 10⁶)` — in-plane area as measured, section
  thickness 20 µm multiplied by the cube root of the stated volumetric shrinkage factor 1.931. The layer value is the
  arithmetic mean over patches (a patch with 0 cells in a layer counts as 0). Multiply by 10 for cells per mm³.
- **Layer thickness:** `AvgThickness(micron)` of `layerinfo.txt`, mean over patches, **µm as measured in the section
  image (shrunken tissue), NOT shrinkage-corrected** — the dataset README says the factor is applied in the pdf
  reports, but the bars of every `stats.pdf` equal the uncorrected means exactly (see Table checks). ×1.2454
  (= 1.931^(1/3)) for a linear correction.
- **Layer coverage:** every item has layers I, II, III, IV, V, VI in every patch (layerinfo.txt always lists the six),
  plus the build's pooled `I-VI` row (per patch: all cells of I–VI / summed volume; thickness = summed layer
  thicknesses = cortical thickness). Cells with layer index 0 or 7 in `segments.txt` (outside I–VI) are not used.
  One patch (Area 4a, section 3196 patch 0001) has 0 segmented cells in layer IV (layer area 51 907 µm²); it enters
  the layer-IV mean as 0, as in the dataset's own `stats.pdf` (siibra drops that patch-layer instead, see QA).

## Per-item table (values from the built CSVs; density in # detected cells / 0.1 mm³, patch means)
| Item name | Item number | structure (KG) | dataset DOI | public TSV | sections / patches | density I/II/III/IV/V/VI | I–VI | cortical thickness µm (uncorr.) | cells counted |
|---|---|---|---|---|---|---|---|---|---|
| `Dickscheid_etal_2021_Area44` | Area 44 | Area 44 (IFG) | 10.25493/THE9-VQU | `10.25493%2FTHE9-VQU_Area44.tsv` | 8 / 10 | 30.5/76.4/53.2/64.7/51.4/48.7 | 51.6 | 3472 | 49129 |
| `Dickscheid_etal_2021_Area4a` | Area 4a | Area 4a (PreCG) | 10.25493/PV5Q-SFR | `10.25493%2FPV5Q-SFR_Area4a.tsv` | 9 / 9 | 30.5/79.5/50.3/49.9/45.8/43.8 | 47.1 | 3624 | 47734 |
| `Dickscheid_etal_2021_Area7P` | Area 7P | Area 7P (SPL) | 10.25493/35K1-BTX | `10.25493%2F35K1-BTX_Area7P.tsv` | 8 / 10 | 29.3/85.5/57.0/76.3/55.4/52.4 | 57.3 | 3021 | 48535 |
| `Dickscheid_etal_2021_AreaFG1` | Area FG1 | Area FG1 (FusG) | 10.25493/E1FY-2C4 | `10.25493%2FE1FY-2C4_AreaFG1.tsv` | 9 / 11 | 30.8/80.4/58.7/85.5/55.8/52.4 | 58.0 | 3406 | 57390 |
| `Dickscheid_etal_2021_AreaFG3` | Area FG3 | Area FG3 (FusG) | 10.25493/DA0M-GM | `10.25493%2FDA0M-GM_AreaFG3.tsv` | 9 / 10 | 33.3/80.8/59.4/93.5/59.2/55.4 | 60.1 | 3508 | 47540 |
| `Dickscheid_etal_2021_AreaFG4` | Area FG4 | Area FG4 (FusG) | 10.25493/YVWP-9AQ | `10.25493%2FYVWP-9AQ_AreaFG4.tsv` | 7 / 10 | 33.5/85.7/57.7/81.8/58.0/54.5 | 58.2 | 2948 | 41478 |
| `Dickscheid_etal_2021_AreaFp1` | Area Fp1 | Area Fp1 (FPole) | 10.25493/YFG8-3R7 | `10.25493%2FYFG8-3R7_AreaFp1.tsv` | 11 / 11 | 34.4/83.6/58.4/76.0/60.6/54.0 | 58.4 | 2612 | 48022 |
| `Dickscheid_etal_2021_AreahOc1` | Area hOc1 | Area hOc1 (V1, 17, CalcS) | 10.25493/EVPC-MVH | `10.25493%2FEVPC-MVH_AreahOc1.tsv` | 10 / 10 | 33.5/101.2/91.5/98.2/75.8/73.0 | 83.0 | 2572 | 56624 |
| `Dickscheid_etal_2021_AreahOc2` | Area hOc2 | Area hOc2 (V2, 18) | 10.25493/TMFG-6FQ | `10.25493%2FTMFG-6FQ_AreahOc2.tsv` | 10 / 11 | 28.9/91.2/69.6/99.5/66.0/57.0 | 66.2 | 2621 | 45578 |
| `Dickscheid_etal_2021_AreahOc3d` | Area hOc3d | Area hOc3d (Cuneus) | 10.25493/F781-V5J | `10.25493%2FF781-V5J_AreahOc3d.tsv` | 7 / 9 | 32.6/98.5/68.4/98.5/67.0/59.9 | 67.1 | 2919 | 42003 |
| `Dickscheid_etal_2021_AreahOc4d` | Area hOc4d | Area hOc4d (Cuneus) | 10.25493/ZXQX-JKP | `10.25493%2FZXQX-JKP_AreahOc4d.tsv` | 8 / 11 | 27.9/81.6/57.3/87.7/57.9/54.3 | 57.8 | 3057 | 53062 |
| `Dickscheid_etal_2021_AreahOc5` | Area hOc5 | Area hOc5 (LOC) | 10.25493/J4HZ-14X | `10.25493%2FJ4HZ-14X_AreahOc5.tsv` | 10 / 10 | 25.9/77.1/53.8/80.7/52.8/52.3 | 54.6 | 2484 | 35700 |

Totals: 122 patches, 572 795 cell bodies counted in layers I–VI.

## Source → Snapshot → Data readable
- **Source (born-digital, EBRAINS data-proxy bucket `p22717-hbp-d000061_BB-CorticalCellDistribution_pub`, one folder
  `<area_dir>/v1.0/` per dataset version).** Each dataset holds, per patch, image patches (nii.gz/png), layer polygons
  (json), segmentation masks (tif), `report.pdf`, and three text files — `info.txt` (ids), `layerinfo.txt` (area in
  µm² and average thickness in µm per layer), `segments.txt` (one row per cell: x, y, area, layer index, label) —
  and, per dataset, `README.md`, `DataDescriptor_*.pdf`, `stats.pdf` ("averaged report") and `report_all.pdf`.
  **There is no averaged table in any dataset: `stats.pdf` and `report.pdf` are figure-only bar charts** (no
  CSV/JSON/text table of layer means exists in the buckets; confirmed by a full listing, 2283 objects). The
  tabular data are the per-patch `layerinfo.txt` + `segments.txt`, which are also exactly what siibra's
  `LayerwiseCellDensity` feature reads.
- **Reader 1 — `Dickscheid_etal_2021_download.py`** (Python, environment `neuro-atlas`; run 2026-11-17 UTC by the AI
  assistant, Claude): reads the 12 registry rows, fetches each KG dataset-version record
  (`ebrains_downloads/kg_records/<uuid>.json`, untouched), maps it to its bucket folder through the KG files API,
  lists the 12 folders (2283 objects) and downloads, bytes untouched, the per-patch `info.txt`, `layerinfo.txt`,
  `segments.txt` and the dataset-level `README.md`, `stats.pdf`, `DataDescriptor_*.pdf` (402 files, 87.8 MB) into
  `ebrains_downloads/<area_dir>/v1.0/…`. `ebrains_downloads/download_manifest.csv` lists **every** bucket object
  (bucket md5/ETag, bytes, URL, section, patch) with `downloaded`, `sha256`, and `md5_matches_bucket` (402/402
  TRUE) for the downloaded ones; images, masks, polygons and per-patch pdfs are recorded there but not downloaded.
  It also writes `reference_tables/Dickscheid_etal_2021_datasets.csv` (Item name ↔ DOI, KG uuid, bucket folder,
  Julich-Brain area name from the KG record, sections, patches). All 12 KG DOIs equal registry column C.
- **Reader 2 — `Dickscheid_etal_2021_snapshot.py`** (one parameterised script, `--item <Item name>` or all):
  verifies each per-patch file against the manifest sha256 (re-downloading a missing one) and writes the constructed
  snapshot **`<Item name>_snapshot.csv`**: one row per patch × layer, `layerinfo.txt` values **as printed** (numeric
  strings copied verbatim), the count of `segments.txt` rows with that layer index, the patch totals, and the bucket
  paths of the two source files. 6 rows per patch; 54–66 rows per item (732 in all). Nothing is averaged or
  converted there. It refuses to overwrite a differing frozen copy (`--force`, then note it here). Snapshot type:
  constructed from born-digital files — `Human visual check of snapshot`: not applicable (no printed table; the
  per-patch files are text and copied untouched).
- **Reader 3 — `Dickscheid_etal_2021_stats_pdf_bars.py`:** reads the bar heights of each `stats.pdf` (vector pdf:
  filled rectangles; y axis calibrated from the tick labels, zero = bottom of the axes frame; x labels I…VI
  asserted) into `reference_tables/Dickscheid_etal_2021_stats_pdf_bars.csv` (144 rows). This is **QA only** — the
  published averaged figure made numeric — never a data source.
- **Build — `Dickscheid_etal_2021_build.R`** (one parameterised script, R 4.5.3, environment `evom1-r`;
  `Rscript Dickscheid_etal_2021_build.R [Item name]`): reads only the snapshot(s) and the two reference tables,
  computes the per-patch densities and the layer means/sds, the `I-VI` row, `n_patches`, `n_sections`, `n_cells`,
  and writes **`<Item name>.csv`** (long, 7 rows: Species, Species_Dickscheid2021, specimen, structure,
  structure_bucket, layer, cell_density, cell_density_sd, density_unit_as_published, layer_thickness,
  layer_thickness_sd, thickness_unit, n_patches, n_sections, n_cells, dataset_doi, kg_dataset_version) and the public
  TSV `__Public/comparative-data/<Item encoded>.tsv` (Item encoded looked up in `__ReadMe.xlsx` by Item name). Column
  meanings: `reference_tables/Dickscheid_etal_2021_definitions.csv` (one file for the series; `Reference` =
  `Dickscheid_etal_2021`). No thin per-item `.R` wrappers were needed: items are validated one by one with
  `validate_dataset_item()` (see below); `build_dataset_item()` would run only the first `.R` of the folder and is
  not used for this series. The `read_excel` call on the registry emits ~136 harmless "Expecting logical …" type
  warnings (sparse text columns AN/AO), as in every build script.

## Table checks (`table_checks` in the build; 144 checks = 12 items × 6 layers × {density, thickness})
Relation: the layer mean computed from `segments.txt`/`layerinfo.txt` must equal the bar of the dataset's own averaged
report `stats.pdf` (tolerance = pdf reading precision: 0.01 cells/0.1 mm³, 0.1 µm). Result of the R run of
2026-11-17: **143 pass, 1 mismatch** — `Dickscheid_etal_2021_Area4a`, density layer III: computed 50.323 vs 50.520
plotted (difference −0.197). Cause (traced through the per-patch `report.pdf` of section 3196 patch 0001, read the
same way): the pre-rendered report shows 49.47 cells/0.1 mm³ for layer III of that patch, the deposited
`segments.txt` gives 47.70 (1719 rows with layer index 3; ≈64 fewer than the report implies) — the deposited data
file and the pre-rendered figure disagree for this one patch-layer. The value is kept as computed from the deposited
data and not altered. All 72 thickness bars equal the **uncorrected** `AvgThickness` means (max |Δ| < 0.001 µm),
which is why `layer_thickness` is declared uncorrected despite the README's statement.

## QA against siibra (`siibra` 1.0.1a27, `siibra.features.get(Julich-Brain 3.0.3, "LayerwiseCellDensity")`, 2026-11-17)
siibra exposes exactly these 12 datasets (same bucket files) and computes per-patch densities with the same formula
(`features/tabular/layerwise_cell_density.py`). Comparison of its 731 patch × layer rows with the snapshot-derived
values: **731/731 identical** (counts, areas, densities; max |Δ| = 0.0). Area-level means: identical for 71/72
area × layer cells; the exception is Area 4a layer IV, where siibra's `counts.loc[layer]` raises `KeyError` for the
zero-count patch and silently drops it (mean 56.15 over 8 patches) whereas this build and `stats.pdf` include it as 0
(49.91 over 9 patches). siibra provides no averaged values itself (its `data` are per patch), so there is no
independent published mean beyond `stats.pdf`.

## Folder contents
```
Dickscheid_etal_2021/
  Dickscheid_etal_2021_download.py            reader 1: registry rows -> KG records -> bucket files + manifest + datasets table
  Dickscheid_etal_2021_snapshot.py            reader 2 (parameterised): per-patch files -> <Item name>_snapshot.csv (x12)
  Dickscheid_etal_2021_stats_pdf_bars.py      reader 3: stats.pdf bars -> reference_tables/..._stats_pdf_bars.csv (QA)
  Dickscheid_etal_2021_build.R                build (parameterised): snapshot -> <Item name>.csv (x12) + public TSVs (x12)
  Dickscheid_etal_2021.README.md              this file (series README)
  Dickscheid_etal_2021_<Area>_snapshot.csv    12 frozen snapshots (constructed, per patch x layer)
  Dickscheid_etal_2021_<Area>.csv             12 analysis CSVs (use these)
  reference_tables/Dickscheid_etal_2021_definitions.csv     data dictionary (series)
  reference_tables/Dickscheid_etal_2021_datasets.csv        Item name <-> DOI / KG uuid / bucket folder / area / n
  reference_tables/Dickscheid_etal_2021_stats_pdf_bars.csv  averaged-report figures read numerically (QA)
  ebrains_downloads/download_manifest.csv                   all 2283 bucket objects; sha256 of the 402 downloaded
  ebrains_downloads/kg_records/<uuid>.json                  12 KG dataset-version records
  ebrains_downloads/<area_dir>/v1.0/{README.md, stats.pdf, DataDescriptor_*.pdf, <section>/<patch>/{info,layerinfo,segments}.txt}
```
`ebrains_downloads/` is 86 MB (segments.txt files); it can be deleted and is restored by the snapshot script from the
manifest URLs with sha256 verification.

## Owner decisions / open points
- One parameterised snapshot script and one parameterised build serve all 12 items (brief); the house default is one
  `<Item>.R` per CSV. If per-item wrappers are wanted later, each would be a two-line `source()` of the build with
  `item_name` set from its own filename.
- One definitions file for the series with `Reference = Dickscheid_etal_2021`; the variable catalog derives `item`
  from `Reference`, so the 12 items appear under the series name there.
- `_keys/General/species_key.csv`: one row appended for `Dickscheid_etal_2021` (Homo sapiens, 9606; species from the
  KG specimen metadata, never printed in the data files).
- The dataset README's statement that the shrinkage factor is applied to the thicknesses in the pdf reports is not
  borne out by the figures; thicknesses are published here as measured (uncorrected) and labelled so.
- Area 4a patch 3196/0001, layer III: deposited `segments.txt` ≠ pre-rendered `report.pdf` (see Table checks).
- Registry `Progress stage` still reads "Registry row proposed; download pending" — owner to update after review.
- License of the source datasets: CC BY-NC-SA 4.0 (KG record `license_info`).
