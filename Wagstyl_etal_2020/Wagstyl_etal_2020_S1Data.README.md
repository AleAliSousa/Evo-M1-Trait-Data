# Wagstyl et al. 2020 — S1 Data: regional cortical thickness, HCP MRI vs BigBrain, 180 HCP-MMP1.0 parcels

**Citation (registry column A):** Wagstyl, K., Larocque, S., Cucurull, G., Lepage, C., Cohen, J. P., Bludau, S.,
Palomero-Gallagher, N., Lewis, L. B., Funck, T., Spitzer, H., Dickscheid, T., Fletcher, P. C., Romero, A., Zilles, K.,
Amunts, K., Bengio, Y., & Evans, A. C. (2020). BigBrain 3D atlas of cortical layers: Cortical and laminar thickness
gradients diverge in sensory and motor cortices. *PLoS Biology, 18*(4), e3000678. https://doi.org/10.1371/journal.pbio.3000678

**Item:** Item number `S1 Data`; Item name `Wagstyl_etal_2020_S1Data`; expected Item encoded
`10.1371%2Fjournal.pbio.3000678_S1Data` (public TSV `__Public/comparative-data/10.1371%2Fjournal.pbio.3000678_S1Data.tsv`).
Registry row: `Wagstyl_etal_2020_S1Data_registry_row.xlsx` (not yet pasted into `__ReadMe.xlsx` — see Status). Collection
token `Zilles` (BigBrain physical collection); Data role `primary`.

## Files
| file | role |
|---|---|
| `12080526/pbio.3000678.s006.csv` | original PLOS download (owner, 2026-11-18), untouched; md5 `47b18d88e4b3d01e90921664abe3d27d` |
| `Wagstyl_etal_2020_S1Data_snapshot.csv` | frozen source = byte-identical copy-rename of the download (same md5); never edited (HOWTO §0a invariant 1, form a) |
| `Wagstyl_etal_2020_S1Data.R` | build: reads only the snapshot → analysis CSV + public TSV; no values in the script |
| `Wagstyl_etal_2020_S1Data.csv` | analysis CSV, 720 rows (180 parcels × 4 source columns), long format |
| `reference_tables/Wagstyl_etal_2020_S1Data_definitions.csv` | data dictionary (10-column schema), 17 rows |
| `Wagstyl_etal_2020_S1Data_registry_row.xlsx` | registry row against the live Sheet1 header (A–AO) + HOW_TO_PASTE |

## What the data are
- **Source table (180 rows × 6 columns):** unnamed index (0–179), `ROIs`, `HCP_left`, `HCP_right`, `BB_left`, `BB_right`.
  One row per HCP-MMP1.0 parcel (Glasser et al. 2016, paper ref. 33; the 180 parcels of one hemisphere, applied to both
  hemispheres). No missing cells, no duplicate labels.
- **Species:** *Homo sapiens*. The file prints no species; `species_as_published = 'human'`, the word the paper uses
  (Materials and methods: "postmortem human brain (male, aged 65)"). Key row added to `_keys/Stephan/species_key.csv`
  (`source_publication = Wagstyl_etal_2020`, variant `human`, basis `our_judgment`). Note: the Dickscheid_etal_2021
  BigBrain rows sit in `_keys/General`; the Stephan spoke was chosen here because the registry Collection is `Zilles`
  (DUSSELDORF_HIRNFORSCHUNG group) — owner may align the two.
- **BigBrain (`BB_left`, `BB_right`):** one post-mortem human brain, male, aged 65 (Amunts et al. 2013, ref. 16),
  20-µm cell-body-stained reconstruction; cortical thickness "calculated between pial and white cortical surfaces"
  (Methods, *Cortical thickness, layer thickness*), surfaces from the 1D-convolutional-network layer segmentation.
  Regional value per parcel: the statistic (presumably per-vertex mean) is **not stated**.
- **HCP (`HCP_left`, `HCP_right`):** "MRI cortical thickness data from the Human Connectome Project [33]" (Fig 3
  legend). The **n of the HCP cohort and the statistic are not stated** in the paper; ref. 33 is Glasser et al. 2016,
  Nature 536:171–178.
- **Hemisphere:** explicit in the source column names (`_left`, `_right`).

## Column dictionary (meaning · unit · what the paper states)
| analysis column | source column | meaning | unit | paper statement / status |
|---|---|---|---|---|
| `parcel_as_published` | `ROIs` | HCP-MMP1.0 parcel label, verbatim | — | Methods, *Surface-based parcellations*: "Glasser: [33]" coregistered to BigBrain by multimodal surface matching [65,66] |
| `thickness_mm` (dataset `HCP_MRI`) | `HCP_left`, `HCP_right` | regional MRI cortical thickness, HCP cohort, by hemisphere | mm | unit: the file header has none; every thickness in the paper is in mm (Fig 3 legend "1.8 mm … 4.5 mm"); the values (1.8–3.6) are consistent with mm. Cohort n / statistic: **not stated** |
| `thickness_mm` (dataset `BigBrain`) | `BB_left`, `BB_right` | regional BigBrain cortical thickness (pial–white), by hemisphere | mm | as above. **Shrinkage:** Methods (*Shrinkage estimate*) give a 3D factor 1.931 → 1D 1.245, linear ADNI scale factors 1.15/1.22/1.43 (mean 1.26), and state "we transformed the mesh surfaces into MNI space based on the ADNI template. Subsequent thickness analyses were carried out on the transformed meshes" — whether *these tabulated* values are from the transformed meshes is **not stated for the file**. **Smoothing:** 3 mm FWHM is stated for the figure maps only; for the table **not stated**. Medial wall and anterior-temporal cut vertices masked |
| `source_row_index` | unnamed col 1 | 0-based pandas index | — | join key to the snapshot |
| `value_as_published` | same as value | numeral verbatim (character) | — | — |

Analysis-CSV columns: `Species, species_as_published, specimen_or_cohort, source_row_index, parcel_as_published,
parcellation, dataset, hemisphere, measure, thickness_mm, value_as_published, source_column, source_file,
source_location, data_role`. Long format: one row per parcel × dataset × hemisphere. No unit conversion.

## Discrepancies and open points
1. **Supporting-information label vs content (publisher-side swap).** PLOS serves this file (`…s006.csv`, 14,740 B) as
   **S1 Data** and `…s007.csv` (3,357 B) as **S2 Data** (PLOS article page: "S2 Data … https://doi.org/10.1371/journal.pbio.3000678.s007";
   PMC lists S1 Data as a 14.4 KB CSV and S2 Data as 3.3 KB). But the paper's *Supporting information* section
   captions them the other way round: "S1 Data. Cortical and laminar thickness values for von Economo areas and
   corresponding BigBrain areas. (CSV)" and "S2 Data. Cortical thickness values for MRI data from Human Connectome
   Project and from corresponding BigBrain areas. (CSV)". This file's content (HCP vs BigBrain, 180 parcels) matches the
   **S2 Data caption**; it is registered here under the label PLOS attaches to the file (**S1 Data**, as the owner
   specified). Figure legends follow the captions: Fig 3 cites "S1 Data, S2 Data"; Figs 4–6 cite "S1 Data" (the laminar
   table). Users searching by caption should read `Wagstyl_etal_2020_S2Data` for the von Economo laminar table.
2. **Correlations not reproduced exactly.** Pearson r(HCP, BigBrain) from this file: left 0.50, right 0.62 (unweighted,
   180 parcels); the paper reports "left hemisphere: r = 0.62, right hemisphere: r = 0.75" (Results). The paper's Fig 3B
   correlations were area-weighted; this file has no area column, so the weighting (or any masking) cannot be
   reproduced. Reported for information; values kept as published.
3. **Unit of thickness** is asserted as mm from the paper's text, not from the file header.

## Table checks
None: the table prints no totals or other checkable relation (HOWTO §7a).

## Reader / provenance
- Source files downloaded by the owner into `12080526/` (2026-11-18). Snapshot copy-renamed with `cp -p` and verified by
  md5 (identical) by the AI assistant (Claude), 2026-11-18.
- Build `Wagstyl_etal_2020_S1Data.R` written and run (`LC_ALL=en_US.UTF-8 Rscript`, env `evom1-r`) by the AI assistant,
  2026-11-18. Fidelity check (Python): all 720 values match the source text verbatim and parse to the identical double in
  both the CSV and the public TSV. Note on writing: readr/`write.table` shorten the 17-significant-digit numerals of this
  file (27/720 would change in the last digit), so the script writes the numeric column as the published numeral
  (`out_write`), after asserting `as.numeric(published) == numeric`.
- Human visual check of snapshot: *Not applicable: tabulated and digital already* (HOWTO §2).
- Paper text read with pdfplumber (text layer lacks spaces; searched space-insensitively); PLOS/PMC supporting-file
  labels checked on the article pages (2026-11-18).

## Status
- Built: snapshot, build R, analysis CSV (720 × 15), definitions, this README, registry row, public TSV
  (`10.1371%2Fjournal.pbio.3000678_S1Data.tsv`, written with the *expected* Item encoded because the registry row is not
  yet in `__ReadMe.xlsx`; the script warns about this).
- **Owner to do:** paste `Wagstyl_etal_2020_S1Data_registry_row.xlsx` row 2 as values into the first empty Sheet1 row of
  `__ReadMe.xlsx`, run `_tools/file_list.R`, confirm J = `Wagstyl_etal_2020_S1Data` and K =
  `10.1371%2Fjournal.pbio.3000678_S1Data` (rename the TSV if K differs), then re-run the build so
  `build_dataset_item()` can validate `registry_row` (the only invariant that cannot pass before the paste).
