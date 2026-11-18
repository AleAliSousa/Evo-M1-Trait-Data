# Palomero-Gallagher N & Zilles K (2018–2022) — EBRAINS receptor-density fingerprint series

**Series:** `EBRAINS_receptor_densities_Juelich` — 56 registered items (one per EBRAINS dataset DOI) in this folder.
Citation (registry column A, identical for all 56 rows): Palomero-Gallagher, N., & Zilles, K. (2018). *Quantitative receptor
data for human, non-human primate, and rodent brains* [EBRAINS dataset series; Knowledge Graph project
77aeb65e-9ff1-46b2-9f58-e11b2a0687d2; individual dataset DOIs in column C]. EBRAINS.
https://search.kg.ebrains.eu/instances/77aeb65e-9ff1-46b2-9f58-e11b2a0687d2

> This folder also holds the unrelated item `PalomeroGallagher_etal_2018_TableS3` (Palomero-Gallagher & Zilles 2018,
> *Cortex*, Table S3 — GLI per specimen) with its own snapshot / script / README / definitions. Everything described here
> belongs to the EBRAINS series; nothing of the TableS3 item was touched.

## What the data are
Each dataset is the Jülich (INM-1) quantitative *in vitro* receptor-autoradiography **fingerprint** of one brain structure:
mean density and SD (fmol/mg protein) of 10–17 transmitter-receptor binding sites, averaged over the hemispheres/brains of
the dataset. The datasets also deposit laminar **profiles** (`*_pr_*.tsv`, 128 files over the series) and autoradiograph
images (`*_ar_*`); these are *recorded* in `ebrains_downloads/laminar_profiles_present.csv` / the manifest but not ingested.

**Laminar profiles — downloaded, NOT yet built as items (pending, 2026-11-18).** The 128 `*_pr_*.tsv` files listed in
`laminar_profiles_present.csv` (8 human areas: 3b, 4p, 7A, 44d, 45, 47, PFm, hOc1 × 16 receptors) were downloaded untouched to
`ebrains_downloads/profiles/` with `ebrains_downloads/profiles_manifest.csv` (item_name, file, local_file, receptor_from_url,
url, bytes, sha256, downloaded, note). Each file is 4 columns (`cortical depth (value)` 0–100 %, 0 = pial surface; `receptor
density (value)` fmol/mg) × 101 equidistant samples; the EBRAINS folder name is `*_pr_examples/<receptor>/`, i.e. one example
profile per receptor (one brain/section), not the dataset mean. One source anomaly: the 3b `M3/` subfolder holds a file named
`3b_pr_M2.tsv` that is byte-identical (sha256) to the `M2/` file, so the 3b M3 profile is effectively missing; it is kept as
`3b_pr_examples_M3__3b_pr_M2.tsv` (bytes untouched, name disambiguated). Profile items (snapshot → CSV → TSV → definitions)
are pending an owner decision on item granularity (per area, or per area × receptor). The analysis-repo prototype
`scripts/s1e_4_laminar_prototype.R` reads these files in place and verifies them against the manifest.

**Species per dataset — as stated in the dataset's own KG specimen metadata, never assumed:**
- *Homo sapiens* — 41 datasets (dataset titles say `[human]`); post-mortem brains, unfixed frozen sections; 2–6 brains per dataset (see table).
- *Macaca fascicularis* — 5 datasets (titles say `[macaque]`; 3 adult males, left hemispheres, ages 6–8 y). **Not** *M. mulatta*.
- *Rattus norvegicus*, strain Wistar — 10 datasets (titles say `[rat]`; 5 males each).

Collection / method note: all datasets come from the Zilles / Palomero-Gallagher receptor-autoradiography programme (INM-1,
Forschungszentrum Jülich; human brains from the Zilles collection, *ex vivo* preparation per the KG records). Sample size per
dataset is **not** in the TSV; it is taken from the KG dataset-version record (specimen overview) and carried as `n_brains`;
per-subject sex / age / hemisphere are in `reference_tables/PalomeroGallagher_etal_2018_dataset_metadata.csv`.

## Files (4-file convention, parameterised over the series)
| file | role |
|---|---|
| `PalomeroGallagher_etal_2018_snapshot.py` | ONE snapshot script (conda env `neuro-atlas`). Reads the series rows from `__ReadMe.xlsx` (by header, by Item name), resolves each DOI's KG record → file repository → the single `*_fp*.tsv`, downloads it **once** to `ebrains_downloads/raw/<bucket>/<path>` and copy-renames it, bytes untouched, to `<Item name>_snapshot.tsv`. Refuses to overwrite a differing snapshot unless `--force`. Also writes `ebrains_downloads/download_manifest.csv`, `ebrains_downloads/laminar_profiles_present.csv`, `ebrains_downloads/kg_records/*.json` and `reference_tables/PalomeroGallagher_etal_2018_dataset_metadata.csv`. |
| `<Item name>_snapshot.tsv` (×56) | frozen source = the untouched EBRAINS fingerprint TSV (4 columns: `receptor label (<abbr>)`, `density (mean)`, `density (sd)`, `density (unit)`). sha256 of every snapshot == manifest. |
| `PalomeroGallagher_etal_2018_build.R` | ONE build script (R env `evom1-r`). Loops over the series rows; for each item reads only the snapshot (+ the metadata reference table + `_keys/General/species_key.csv`) and writes `<Item name>.csv` and `__Public/comparative-data/<Item encoded>.tsv`. `Rscript PalomeroGallagher_etal_2018_build.R [ITEM_NAME ...]` builds all or the named items. |
| `<Item name>.csv` (×56) | long analysis table, one row = dataset × receptor (columns below). |
| `__Public/comparative-data/<Item encoded>.tsv` (×56) | public copy of the same table, named `<DOI url-encoded>_<ItemNumber>.tsv` from the registry. |
| `reference_tables/PalomeroGallagher_etal_2018_definitions.csv` | ONE definitions file (house schema) for all 56 items. |
| `reference_tables/PalomeroGallagher_etal_2018_dataset_metadata.csv` | per-item KG metadata (species, strain, n subjects, sexes, ages, hemispheres, title, version, studied region, fingerprint URL) the build joins on. |
| `ebrains_downloads/download_manifest.csv` | item_name, doi, kg_uuid, bucket, file, url, bytes, sha256, downloaded (+ kg_registry_uuid, kg_record_type, version_label, snapshot, n_laminar_profile_tsv, n_autoradiograph_files, n_files). |

**No per-item wrapper scripts were generated.** `validate_dataset_item()` takes explicit file paths, so each item is validated by
passing its CSV / public TSV / snapshot with this shared README and definitions file (see *QA*). `build_dataset_item()` runs only
the *first* `.R` found in a folder and is therefore not usable for a multi-item folder — run the build script directly.

## Analysis-CSV columns
`Species` (accepted, via `_keys/General/species_key.csv` rows with `source_publication = PalomeroGallagher_etal_2018`),
`Species_as_published` (KG specimen species), `species_label_dataset_title` (human/macaque/rat), `strain_as_published`,
`structure`, `structure_part`, `structure_as_published`, `structure_abbreviation`, `parcellation_atlas`,
`kg_studied_brain_region`, `dataset_version`, `receptor`, `receptor_as_published`, `density_fmol_mg_protein`, `sd`,
`unit_as_published`, `n_brains`, `dataset_doi`, `dataset_version_doi`, `kg_dataset_version`, `kg_record_registry`,
`dataset_title`, `item_name`. Definitions: `reference_tables/PalomeroGallagher_etal_2018_definitions.csv`.

Receptor names are harmonised to the `Zilles_PalomeroGallagher_2017_SupplementaryTable2` vocabulary: `BZ` → `GABAA/BZ`;
`mGluR2_3` / `mGlu2/3` → `mGluR2/3` (extra receptor, kept); `A1` (adenosine A1, the six IFS/IFJ datasets) kept as printed;
AMPA, kainate, NMDA, GABAA, GABAB, M1, M2, M3, alpha4beta2, alpha1, alpha2, 5-HT1A, 5-HT2, D1 unchanged. The printed label
survives in `receptor_as_published`. Unit kept (fmol/mg protein; no conversion).

## Source-fidelity notes
- **Concept-DOI items (12, Item number ending `2022`):** the registered DOI (column C) and the uuid in the N.B. column resolve to a
  *version-less* Dataset record (DataCite year 2022) that lists versions v1 and v2. The snapshot is the fingerprint TSV of the
  **highest version (v2)**; `dataset_version_doi` / `kg_dataset_version` give that version's own DOI / uuid, `kg_record_registry` the
  registered concept uuid, and `all_versions` in the metadata table lists both. The v1 files (5 receptors) are not ingested here.
- **Blank SD:** the source TSV leaves `density (sd)` empty for **alpha2** in the five IPL datasets (Area PF, PFcm, PFop, PGa, PGp);
  the mean is kept and `sd` is blank for those five rows.
- **Header variants:** the six rat hippocampal TSVs quote every field; the six IFS/IFJ TSVs are named `<area>_fp.tsv` (no date).
  All 56 have the same four columns; none differs in layout.
- `parcellation_atlas` is blank where the KG record names no atlas (human Areas 46, 47, 9, hOc2 d/v, globus pallidus, putamen,
  thalamic nuclei; rat Oc areas).

## QA (run 2026-11-16)
- 56/56 snapshot sha256 == `download_manifest.csv`; 56/56 snapshots byte-identical to an independent download of the same URLs.
- 56/56 items: CSV rows == snapshot data rows == public TSV rows (824 rows in total; 634 human, 70 macaque, 120 rat).
- 28 items have a counterpart in `Zilles_PalomeroGallagher_2017_EBRAINSFingerprints.csv` (siibra fetch, matched on KG
  version uuid × receptor label): 425 shared rows, **425 identical means, 425 identical SDs, 0 mismatches**; source URLs identical.
  Items without a siibra counterpart (28): the structures without a Julich-Brain 3.0 map in siibra (Areas 46, 47, 9, IFS1-4, IFJ1-2,
  globus pallidus, putamen, thalamic nuclei) and all macaque and rat datasets.
- `audit_dataset_item()` on the folder: snapshot / csv / readme / definitions PASS, orphan_tsv 0 (PASS).
- `validate_dataset_item()` for each of the 56 items (own CSV, public TSV, snapshot; shared README + definitions): csv, tsv, readme,
  definitions, frozen_source, registry_row, tsv_name_match, no_trailing_underscore = PASS for 56/56; errata_file_valid = SKIP (no errata file).
- Build re-run from a clean session reproduces the CSVs byte-for-byte.

## Owner notes
- Registry column L (*Public TSV match*) still reads `notfound` for these rows until `_tools/file_list.R` is re-run.
- The N.B. column calls every uuid a "KG dataset-version"; for the 12 `2022` items it is in fact the concept (Dataset) record.
- The Stephan key already carries `PalomeroGallagher_etal_2018` rows for the TableS3 item (common names → binomials, incl.
  macaque → *Macaca fascicularis*); the six rows added to `_keys/General/species_key.csv` for this series are consistent with them.

## Per-item table
| Item name | DOI | structure | species | n brains (KG) | n receptors | version | fingerprint file (bucket/path) | laminar profile TSVs |
|---|---|---|---|---|---|---|---|---|
| PalomeroGallagher_etal_2018_Area3bv1.0 | 10.25493/TZBY-96W | Area 3b | Homo sapiens | 5 | 16 | v1 | `p22717-hbp-d000045_receptors-human-3b_pub/v1.0/3b_fp_20180321.tsv` | 16 |
| PalomeroGallagher_etal_2018_Area45v1.0 | 10.25493/QFSY-YWC | Area 45 | Homo sapiens | 3 | 15 | v1 | `p22717-hbp-d000045_receptors-human-45_pub/v1.0/45_fp_20171202.tsv` | 16 |
| PalomeroGallagher_etal_2018_Area46v1.0 | 10.25493/JHA2-ACG | Area 46 | Homo sapiens | 5 | 16 | v1 | `p22717-hbp-d000045_receptors-human-46_pub/v1.0/46_fp_20180405.tsv` | 0 |
| PalomeroGallagher_etal_2018_Area47v1.0 | 10.25493/4M1R-KCP | Area 47 | Homo sapiens | 3 | 15 | v1 | `p22717-hbp-d000045_receptors-human-47_pub/v1.0/47_fp_20171202.tsv` | 16 |
| PalomeroGallagher_etal_2018_Area4pv1.0 | 10.25493/J5JR-YH0 | Area 4p | Homo sapiens | 3 | 15 | v1 | `p22717-hbp-d000045_receptors-human-4p_pub/v1.0/4p_fp_20171202.tsv` | 32 |
| PalomeroGallagher_etal_2018_Area7Av1.0 | 10.25493/DQJ7-KC8 | Area 7A | Homo sapiens | 5 | 16 | v1 | `p22717-hbp-d000045_receptors-human-7A_pub/v1.0/7A_fp_20180321.tsv` | 16 |
| PalomeroGallagher_etal_2018_Area9v1.0 | 10.25493/97BA-87Y | Area 9 | Homo sapiens | 5 | 16 | v1 | `p22717-hbp-d000045_receptors-human-9_pub/v1.0/9_fp_20180405.tsv` | 0 |
| PalomeroGallagher_etal_2018_AreaFG1v1.0 | 10.25493/QN6K-CHN | Area FG1 | Homo sapiens | 6 | 15 | v1 | `p22717-hbp-d000045_receptors-human-FG1_pub/v1.0/FG1_fp_20180321.tsv` | 0 |
| PalomeroGallagher_etal_2018_AreaFG2v1.0 | 10.25493/VFCW-HXZ | Area FG2 | Homo sapiens | 6 | 15 | v1 | `p22717-hbp-d000045_receptors-human-FG2_pub/v1.0/FG2_fp_20180321.tsv` | 0 |
| PalomeroGallagher_etal_2018_AreaPFv1.0 | 10.25493/VSFY-EYF | Area PF | Homo sapiens | 5 | 16 | v1 | `p22717-hbp-d000045_receptors-human-PF_pub/v1.0/PF_fp_20180405.tsv` | 0 |
| PalomeroGallagher_etal_2018_AreaPFcmv1.0 | 10.25493/5QDP-ARH | Area PFcm | Homo sapiens | 5 | 16 | v1 | `p22717-hbp-d000045_receptors-human-PFcm_pub/v1.0/PFcm_fp_20180405.tsv` | 0 |
| PalomeroGallagher_etal_2018_AreaPFmv1.0 | 10.25493/FS3T-2R8 | Area PFm | Homo sapiens | 3 | 15 | v1 | `p22717-hbp-d000045_receptors-human-PFm_pub/v1.0/PFm_fp_20171202.tsv` | 32 |
| PalomeroGallagher_etal_2018_AreaPFopv1.0 | 10.25493/9G1P-02S | Area PFop | Homo sapiens | 5 | 16 | v1 | `p22717-hbp-d000045_receptors-human-PFop_pub/v1.0/PFop_fp_20180405.tsv` | 0 |
| PalomeroGallagher_etal_2018_AreaPFtv1.0 | 10.25493/E7PM-FDC | Area PFt | Homo sapiens | 5 | 16 | v1 | `p22717-hbp-d000045_receptors-human-PFt_pub/v1.0/PFt_fp_20180405.tsv` | 0 |
| PalomeroGallagher_etal_2018_AreaPGav1.0 | 10.25493/62W8-RYF | Area PGa | Homo sapiens | 5 | 16 | v1 | `p22717-hbp-d000045_receptors-human-PGa_pub/v1.0/PGa_fp_20180405.tsv` | 0 |
| PalomeroGallagher_etal_2018_AreaPGpv1.0 | 10.25493/X71T-HZ | Area PGp | Homo sapiens | 5 | 16 | v1 | `p22717-hbp-d000045_receptors-human-PGp_pub/v1.0/PGp_fp_20180405.tsv` | 0 |
| PalomeroGallagher_etal_2018_AreaTE1.0v1.0 | 10.25493/AHX0-9PU | Area TE 1.0 | Homo sapiens | 5 | 16 | v1 | `p22717-hbp-d000045_receptors-human-TE1_0_pub/v1.0/TE1_0_fp_20180405.tsv` | 0 |
| PalomeroGallagher_etal_2018_AreaTE2.1v1.0 | 10.25493/C279-428 | Area TE 2.1 | Homo sapiens | 5 | 16 | v1 | `p22717-hbp-d000045_receptors-human-TE2_1_pub/v1.0/TE2_1_fp_20180405.tsv` | 0 |
| PalomeroGallagher_etal_2018_AreahOc1v1.0 | 10.25493/P8SD-JMH | Area hOc1 | Homo sapiens | 3 | 15 | v1 | `p22717-hbp-d000045_receptors-human-hOc1_pub/v1.0/hOc1_fp_20171202.tsv` | 16 |
| PalomeroGallagher_etal_2018_Areaifj1v1 | 10.25493/JS85-VQD | Area ifj1 | Homo sapiens | 4 | 17 | v1 | `p22717-hbp-d000045_receptors-human-ifj1_pub/v1.0/ifj1_fp/ifj1_fp.tsv` | 0 |
| PalomeroGallagher_etal_2018_Areaifj2v1 | 10.25493/VN1A-Q2R | Area ifj2 | Homo sapiens | 4 | 17 | v1 | `p22717-hbp-d000045_receptors-human-ifj2_pub/v1.0/ifj2_fp/ifj2_fp.tsv` | 0 |
| PalomeroGallagher_etal_2018_Areaifs1v1 | 10.25493/SHG2-7RS | Area ifs1 | Homo sapiens | 4 | 17 | v1 | `p22717-hbp-d000045_receptors-human-ifs1_pub/v1.0/ifs1_fp/ifs1_fp.tsv` | 0 |
| PalomeroGallagher_etal_2018_Areaifs2v1 | 10.25493/14M7-QJR | Area ifs2 | Homo sapiens | 4 | 17 | v1 | `p22717-hbp-d000045_receptors-human-ifs2_pub/v1.0/ifs2_fp/ifs2_fp.tsv` | 0 |
| PalomeroGallagher_etal_2018_Areaifs3v1 | 10.25493/Z5JN-J28 | Area ifs3 | Homo sapiens | 4 | 17 | v1 | `p22717-hbp-d000045_receptors-human-ifs3_pub/v1.0/ifs3_fp/ifs3_fp.tsv` | 0 |
| PalomeroGallagher_etal_2018_Areaifs4v1 | 10.25493/YF9R-J87 | Area ifs4 | Homo sapiens | 4 | 17 | v1 | `p22717-hbp-d000045_receptors-human-ifs4_pub/v1.0/ifs4_fp/ifs4_fp.tsv` | 0 |
| PalomeroGallagher_etal_2018_CA12022 | 10.25493/FKE3-Y2 | CA1 | Homo sapiens | 3 | 14 | v2 | `p22717-hbp-d000045_receptors-human-CA1_pub/v2.0/CA1_fp_20200214.tsv` | 0 |
| PalomeroGallagher_etal_2018_CA22022 | 10.25493/Q9BJ-3TW | CA2 | Homo sapiens | 3 | 14 | v2 | `p22717-hbp-d000045_receptors-human-CA2_pub/v2.0/CA2_fp_20200214.tsv` | 0 |
| PalomeroGallagher_etal_2018_CA32022 | 10.25493/N8JZ-MEB | CA3 | Homo sapiens | 3 | 14 | v2 | `p22717-hbp-d000045_receptors-human-CA3_pub/v2.0/CA3_fp_20200214.tsv` | 0 |
| PalomeroGallagher_etal_2018_DG2022 | 10.25493/6AZK-A41 | DG | Homo sapiens | 3 | 14 | v2 | `p22717-hbp-d000045_receptors-human-DG_pub/v2.0/DG_fp_20200214.tsv` | 0 |
| PalomeroGallagher_etal_2018_GlobusPallidusv1.0 | 10.25493/TPRG-5VH | Globus Pallidus | Homo sapiens | 2 | 15 | v1 | `p22717-hbp-d000045_receptors-human-GP_pub/v1.0/GP_fp_20180405.tsv` | 0 |
| PalomeroGallagher_etal_2018_Putamenv1.0 | 10.25493/4GZ1-SHH | Putamen | Homo sapiens | 2 | 15 | v1 | `p22717-hbp-d000045_receptors-human-Pu_pub/v1.0/Pu_fp_20180405.tsv` | 0 |
| PalomeroGallagher_etal_2018_dorsalpartofArea44v1.0 | 10.25493/YQCR-1DQ | Area 44 — dorsal part | Homo sapiens | 3 | 15 | v1 | `p22717-hbp-d000045_receptors-human-44d_pub/v1.0/44d_fp_20171202.tsv` | 16 |
| PalomeroGallagher_etal_2018_dorsalpartofAreahOc2v1.0 | 10.25493/ZJ7E-KXZ | Area hOc2 — dorsal part | Homo sapiens | 3 | 15 | v1 | `p22717-hbp-d000045_receptors-human-hOc2d_pub/v1.0/hOc2d_fp_20200214.tsv` | 0 |
| PalomeroGallagher_etal_2018_dorsalpartofAreahOc3v1.0 | 10.25493/4ETW-9XB | Area hOc3 — dorsal part | Homo sapiens | 3 | 15 | v1 | `p22717-hbp-d000045_receptors-human-hOc3d_pub/v1.0/hOc3d_fp_20200214.tsv` | 0 |
| PalomeroGallagher_etal_2018_mediodorsalpartofThalamicNucleusv1.0 | 10.25493/GKY8-NZR | Thalamic Nucleus — mediodorsal part | Homo sapiens | 2 | 15 | v1 | `p22717-hbp-d000045_receptors-human-ThMD_pub/v1.0/ThMD_fp_20180405.tsv` | 0 |
| PalomeroGallagher_etal_2018_stratumcellulareofCA2022 | 10.25493/3JDA-N1T | CA — stratum cellulare | Homo sapiens | 3 | 14 | v2 | `p22717-hbp-d000045_receptors-human-CAcell_pub/v2.0/CAcell_fp_20200214.tsv` | 0 |
| PalomeroGallagher_etal_2018_stratummoleculareofCA2022 | 10.25493/73AM-FBH | CA — stratum moleculare | Homo sapiens | 3 | 14 | v2 | `p22717-hbp-d000045_receptors-human-CAmol_pub/v2.0/CAmol_fp_20200214.tsv` | 0 |
| PalomeroGallagher_etal_2018_anteriorThalamicnucleusv1.0 | 10.25493/KKTT-1TK | anterior Thalamic nucleus | Homo sapiens | 2 | 15 | v1 | `p22717-hbp-d000045_receptors-human-ThA_pub/v1.0/ThA_fp_20180405.tsv` | 0 |
| PalomeroGallagher_etal_2018_ventralpartofArea44v1.0 | 10.25493/P82M-PVM | Area 44 — ventral part | Homo sapiens | 5 | 16 | v1 | `p22717-hbp-d000045_receptors-human-44v_pub/v1.0/44v_fp_20180405.tsv` | 0 |
| PalomeroGallagher_etal_2018_ventralpartofAreahOc2v1.0 | 10.25493/2E5C-PVM | Area hOc2 — ventral part | Homo sapiens | 3 | 15 | v1 | `p22717-hbp-d000045_receptors-human-hOc2v_pub/v1.0/hOc2v_fp_20200214.tsv` | 0 |
| PalomeroGallagher_etal_2018_ventralpartofAreahOc3v1.0 | 10.25493/TBMX-BZ9 | Area hOc3 — ventral part | Homo sapiens | 3 | 15 | v1 | `p22717-hbp-d000045_receptors-human-hOc3v_pub/v1.0/hOc3v_fp_20200214.tsv` | 0 |
| PalomeroGallagher_etal_2018_macaqueAreaV1v1.0 | 10.25493/T6BJ-TSN | Area V1 | Macaca fascicularis | 3 | 14 | v1 | `p22717-hbp-d000045_receptors-macaque-V1_pub/v1.0/V1_fp_20200214.tsv` | 0 |
| PalomeroGallagher_etal_2018_macaquedorsalpartofAreaV2v1.0 | 10.25493/V0SB-M50 | Area V2 — dorsal part | Macaca fascicularis | 3 | 14 | v1 | `p22717-hbp-d000045_receptors-macaque-V2d_pub/v1.0/V2d_fp_20200214.tsv` | 0 |
| PalomeroGallagher_etal_2018_macaquedorsalpartofAreaV3v1.0 | 10.25493/KA52-JAJ | Area V3 — dorsal part | Macaca fascicularis | 3 | 14 | v1 | `p22717-hbp-d000045_receptors-macaque-V3d_pub/v1.0/V3d_fp_20200214.tsv` | 0 |
| PalomeroGallagher_etal_2018_macaqueventralpartofAreaV2v1.0 | 10.25493/85KF-JMZ | Area V2 — ventral part | Macaca fascicularis | 3 | 14 | v1 | `p22717-hbp-d000045_receptors-macaque-V2v_pub/v1.0/V2v_fp_20200214.tsv` | 0 |
| PalomeroGallagher_etal_2018_macaqueventralpartofAreaV3v1.0 | 10.25493/3Q4Z-540 | Area V3 — ventral part | Macaca fascicularis | 3 | 14 | v1 | `p22717-hbp-d000045_receptors-macaque-V3v_pub/v1.0/V3v_fp_20200214.tsv` | 0 |
| PalomeroGallagher_etal_2018_ratAreaOc1Bv1.0 | 10.25493/1DB6-YXW | Area Oc1B | Rattus norvegicus | 5 | 15 | v1 | `p22717-hbp-d000045_receptors-rat-Oc1B_pub/v1.0/Oc1B_fp_20200214.tsv` | 0 |
| PalomeroGallagher_etal_2018_ratAreaOc1Mv1.0 | 10.25493/2AYK-4JG | Area Oc1M | Rattus norvegicus | 5 | 15 | v1 | `p22717-hbp-d000045_receptors-rat-Oc1M_pub/v1.0/Oc1M_fp_20200214.tsv` | 0 |
| PalomeroGallagher_etal_2018_ratAreaOc2Lv1.0 | 10.25493/Z4RW-7DN | Area Oc2L | Rattus norvegicus | 5 | 15 | v1 | `p22717-hbp-d000045_receptors-rat-Oc2L_pub/v1.0/Oc2L_fp_20200214.tsv` | 0 |
| PalomeroGallagher_etal_2018_ratAreaOc2Mv1.0 | 10.25493/FDHF-AWY | Area Oc2M | Rattus norvegicus | 5 | 15 | v1 | `p22717-hbp-d000045_receptors-rat-Oc2M_pub/v1.0/Oc2M_fp_20200214.tsv` | 0 |
| PalomeroGallagher_etal_2018_ratCA,stratumcellulare2022 | 10.25493/SH70-PDF | CA — stratum cellulare | Rattus norvegicus | 5 | 10 | v2 | `p22717-hbp-d000045_receptors-rat-CAcell_pub/v2.0/CAcell_fp_20200217.tsv` | 0 |
| PalomeroGallagher_etal_2018_ratCA,stratummoleculare2022 | 10.25493/NTFW-94S | CA — stratum moleculare | Rattus norvegicus | 5 | 10 | v2 | `p22717-hbp-d000045_receptors-rat-CAmol_pub/v2.0/CAmol_fp_20200217.tsv` | 0 |
| PalomeroGallagher_etal_2018_ratCA12022 | 10.25493/A9DQ-TXC | CA1 | Rattus norvegicus | 5 | 10 | v2 | `p22717-hbp-d000045_receptors-rat-CA1_pub/v2.0/CA1_fp_20200217.tsv` | 0 |
| PalomeroGallagher_etal_2018_ratCA22022 | 10.25493/K39H-MT1 | CA2 | Rattus norvegicus | 5 | 10 | v2 | `p22717-hbp-d000045_receptors-rat-CA2_pub/v2.0/CA2_fp_20200217.tsv` | 0 |
| PalomeroGallagher_etal_2018_ratCA32022 | 10.25493/7D5Z-N2R | CA3 | Rattus norvegicus | 5 | 10 | v2 | `p22717-hbp-d000045_receptors-rat-CA3_pub/v2.0/CA3_fp_20200217.tsv` | 0 |
| PalomeroGallagher_etal_2018_ratDG2022 | 10.25493/MA1X-V5G | DG | Rattus norvegicus | 5 | 10 | v2 | `p22717-hbp-d000045_receptors-rat-DG_pub/v2.0/DG_fp_20200217.tsv` | 0 |
