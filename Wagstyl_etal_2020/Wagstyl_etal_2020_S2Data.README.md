# Wagstyl et al. 2020 — S2 Data: von Economo & Koskinas vs BigBrain total and layer thicknesses, 38 von Economo areas

**Citation (registry column A):** Wagstyl, K., Larocque, S., Cucurull, G., Lepage, C., Cohen, J. P., Bludau, S.,
Palomero-Gallagher, N., Lewis, L. B., Funck, T., Spitzer, H., Dickscheid, T., Fletcher, P. C., Romero, A., Zilles, K.,
Amunts, K., Bengio, Y., & Evans, A. C. (2020). BigBrain 3D atlas of cortical layers: Cortical and laminar thickness
gradients diverge in sensory and motor cortices. *PLoS Biology, 18*(4), e3000678. https://doi.org/10.1371/journal.pbio.3000678

**Item:** Item number `S2 Data`; Item name `Wagstyl_etal_2020_S2Data`; expected Item encoded
`10.1371%2Fjournal.pbio.3000678_S2Data` (public TSV `__Public/comparative-data/10.1371%2Fjournal.pbio.3000678_S2Data.tsv`).
Registry row: `Wagstyl_etal_2020_S2Data_registry_row.xlsx` (not yet pasted into `__ReadMe.xlsx` — see Status). Collection
token `Zilles` (BigBrain physical collection); Data role `both` (BigBrain rows primary; von Economo rows secondary).

## Files
| file | role |
|---|---|
| `12080526/pbio.3000678.s007.csv` | original PLOS download (owner, 2026-11-18), untouched; md5 `7af3d5dc6ec54bdbd88ad6e7f9cf44b3` |
| `Wagstyl_etal_2020_S2Data_snapshot.csv` | frozen source = byte-identical copy-rename of the download (same md5); never edited (HOWTO §0a invariant 1, form a) |
| `Wagstyl_etal_2020_S2Data.R` | build: reads only the snapshot → analysis CSV + public TSV; `table_checks` for `ve_sum` |
| `Wagstyl_etal_2020_S2Data.csv` | analysis CSV, 608 rows (38 areas × 16 source columns), long format |
| `reference_tables/Wagstyl_etal_2020_S2Data_definitions.csv` | data dictionary (10-column schema), 19 rows |
| `Wagstyl_etal_2020_S2Data_registry_row.xlsx` | registry row against the live Sheet1 header (A–AO) + HOW_TO_PASTE |

## What the data are
- **Source table (38 rows × 18 columns):** unnamed index (2–44 with gaps), `area_name`, `crown_min`, `ve_1`…`ve_6`,
  `ve_sum`, `bigbrain`, `area`, `bigbrain_layer_1`…`bigbrain_layer_6`. One row per von Economo & Koskinas area
  (FA, FB, FC, FCBm, FD, FDdelta, FDT, FE, FF, FG, FH, FJK, IA, IB, LA1, LA2, LC1, LC2, LC3, LD, OA, OB, OC, PA, PB,
  PC, PD, PE, PF, PG, PH, TA, TB, TC, TD, TE, TF, TG). No missing cells.
- **Species:** *Homo sapiens*; `species_as_published = 'human'` (see the S1 Data README for the key row and the
  spoke choice).
- **von Economo & Koskinas columns (`crown_min`, `ve_*`):** values from the 1925 histological atlas (paper refs 8 and
  64 — Scholtens et al. 2018's MRI von Economo–Koskinas atlas), brought onto BigBrain as a surface-based parcellation
  (Methods, *Surface-based parcellations*). "Von Economo reported thickness measurements from around 50 cortical areas"
  (Fig 3 legend); 38 are tabulated here — "the allocortex, including parts of the cingulate and entorhinal cortex that do
  not have 6 layers, were excluded for comparisons of laminar thickness with von Economo measurements" (Methods, *Masking*).
- **BigBrain columns (`bigbrain`, `bigbrain_layer_*`):** one post-mortem human brain, male, aged 65; total thickness
  pial–white, laminar thicknesses "between adjacent pairs of cortical surfaces" (Methods). **Hemisphere not stated for
  this file** — the file holds one BigBrain column per measure, whereas the paper reports left and right separately
  (Fig 4; Results r values per hemisphere). The area-weighted correlations computed from this file sit between the paper's
  left/right values (see Observations), consistent with hemisphere-pooled values, but this is inferred, not stated.
- **`area`:** the only statement is in the Fig 3B legend — "The size of each point is proportional to the area of the
  cortical region, and overall correlations were weighted according to these areas." Unit, surface (pial/mid/white) and
  hemisphere pooling are **not stated**; the column sums to 150,990. Kept as published (`measure = region_area`, `unit = not stated`).

## Column dictionary (meaning · unit · what the paper states)
| analysis rows (`dataset` / `measure` / `layer`) | source column | meaning | unit | paper statement / status |
|---|---|---|---|---|
| `vonEconomo_Koskinas` / `cortical_thickness_crown_min` / `total` | `crown_min` | von Economo & Koskinas total cortical thickness, lower bound ("min") — the word "crown" does not occur in the paper | mm | **Not stated.** Consistent with the paper's quoted von Economo ranges: "3.5 to 4.5 mm in von Economo (area FA)" → `crown_min` FA = 3.5; "1.8 to 2.3 mm, occipital area C [area OC]" → `crown_min` OC = 1.8. The atlas's gyral-crown vs wall distinction is the curator's reading of the column name, not a paper statement |
| `vonEconomo_Koskinas` / `layer_thickness` / `I`…`VI` | `ve_1`…`ve_6` | von Economo & Koskinas thickness of layers I–VI | mm | Fig 4: "von Economo's laminar thickness maps (coregistered with and visualized on the BigBrain)"; unit from the paper's text (all thicknesses in mm) |
| `vonEconomo_Koskinas` / `cortical_thickness_sum_of_layers` / `I-VI` | `ve_sum` | sum of `ve_1`…`ve_6` | mm | arithmetic verified: 38/38 exact (Table checks) |
| `BigBrain` / `cortical_thickness` / `total` | `bigbrain` | BigBrain regional cortical thickness (pial–white) of the coregistered von Economo area | mm | unit from the paper's text. Shrinkage: Methods give 1D factor 1.245 (ADNI linear scale factors 1.15/1.22/1.43) and say thickness analyses were done on the ADNI/MNI-transformed meshes — whether these tabulated values are the transformed ones is **not stated**; note FA = 2.86 mm here while the text says the precentral gyrus exceeds "4.5 mm (when adjusted for shrinkage in BigBrain)" (per-vertex maximum vs regional mean — not resolvable from the paper). Smoothing (3 mm FWHM) stated for figure maps only |
| `BigBrain` / `layer_thickness` / `I`…`VI` | `bigbrain_layer_1`…`6` | BigBrain thickness of layers I–VI (network segmentation, surfaces between adjacent layers) | mm | as above |
| `not stated` / `region_area` / — | `area` | area of the cortical region (weight in Fig 3B) | **not stated** | Fig 3B legend only |
| `source_row_index` | unnamed col 1 | pandas index 2…44 (0, 1, 14–17, 26 absent) | — | gaps presumably the excluded allocortical areas (curator inference) |

Analysis-CSV columns: `Species, species_as_published, specimen_or_cohort, source_row_index, area_as_published,
parcellation, dataset, layer, measure, value, unit, value_as_published, source_column, source_file, source_location,
data_role`. Long format: one row per area × source column (608). No unit conversion.

## Table checks
- `ve_sum` vs `ve_1 + … + ve_6`, compared in hundredths, tolerance 0.03 (half a unit per summed cell): **38 pass,
  0 mismatch** (actual Rscript run, 2026-11-18; `table_checks` data frame in the script).
- Not a check (no relation claimed by the paper): `bigbrain` (pial–white) vs the sum of `bigbrain_layer_1…6`.
  Differences (total − layer sum) range −0.76 mm (LC3) to +0.35 mm (LC1); 21/38 within ±0.1 mm. Total and layer
  thicknesses are measured between different surface pairs after independent smoothing, so equality is not expected.
  Values kept as published.

## Observations (informational; values unchanged)
- Area-weighted Pearson r from this file: `bigbrain` vs `crown_min` = 0.85 (paper, Fig 3B: left 0.86, right 0.86);
  `bigbrain` vs `ve_sum` = 0.75. So Fig 3B evidently used `crown_min` as the von Economo total — **not stated** in the paper.
- Area-weighted r per layer (`ve_i` vs `bigbrain_layer_i`): I 0.46, II 0.07, III 0.73, IV 0.79, V 0.64, VI 0.64; paper
  (Results): I 0.50/0.46, II 0.11/0.06, III 0.74/0.72, IV 0.80/0.76, V 0.66/0.66, VI 0.66/0.60 (left/right). Layers I, II, III, IV and VI lie at or between the two hemispheres' values; layer V (0.64) falls 0.02
  below both (0.66/0.66).

## Discrepancies and open points
1. **Supporting-information label vs content (publisher-side swap).** PLOS serves this file (`…s007.csv`, 3,357 B) as
   **S2 Data** ("S2 Data … https://doi.org/10.1371/journal.pbio.3000678.s007" on the article page; PMC: 3.3 KB CSV), but
   the paper's *Supporting information* captions read "S1 Data. Cortical and laminar thickness values for von Economo
   areas and corresponding BigBrain areas. (CSV)" and "S2 Data. Cortical thickness values for MRI data from Human
   Connectome Project and from corresponding BigBrain areas. (CSV)". This file's content matches the **S1 Data caption**;
   it is registered under the label PLOS attaches to the file (**S2 Data**, as the owner specified). Figs 4–6 cite
   "S1 Data" for the laminar data — by caption that is this table.
2. **Hemisphere** of the BigBrain values not stated (single column; paper reports left/right separately).
3. **`crown_min`** and **`area`** are not explained anywhere in the paper (see dictionary).
4. **Shrinkage status** of the tabulated BigBrain values not stated for the file.
5. **Unit of thickness** asserted as mm from the paper's text, not from the file header.

## Reader / provenance
- Source files downloaded by the owner into `12080526/` (2026-11-18). Snapshot copy-renamed with `cp -p` and verified by
  md5 (identical) by the AI assistant (Claude), 2026-11-18.
- Build `Wagstyl_etal_2020_S2Data.R` written and run (`LC_ALL=en_US.UTF-8 Rscript`, env `evom1-r`) by the AI assistant,
  2026-11-18. Fidelity check (Python): all 608 values match the source text verbatim and parse to the identical number in
  both the CSV and the public TSV (numeric column written as the published numeral, see the S1 Data README).
- Human visual check of snapshot: *Not applicable: tabulated and digital already* (HOWTO §2).
- Paper text read with pdfplumber (space-insensitive search); PLOS/PMC supporting-file labels checked on the article
  pages (2026-11-18).

## Status
- Built: snapshot, build R, analysis CSV (608 × 16), definitions, this README, registry row, public TSV
  (`10.1371%2Fjournal.pbio.3000678_S2Data.tsv`, written with the *expected* Item encoded; the script warns that the
  registry row is pending).
- **Owner to do:** paste `Wagstyl_etal_2020_S2Data_registry_row.xlsx` row 2 as values into the first empty Sheet1 row of
  `__ReadMe.xlsx`, run `_tools/file_list.R`, confirm J = `Wagstyl_etal_2020_S2Data` and K =
  `10.1371%2Fjournal.pbio.3000678_S2Data` (rename the TSV if K differs), then re-run the build so `build_dataset_item()`
  can validate `registry_row`.
