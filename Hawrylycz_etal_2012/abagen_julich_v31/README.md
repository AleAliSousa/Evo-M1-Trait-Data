# abagen_julich_v31 — AHBA microarray parcellated to Julich-Brain v3.1 (derived, processed data; not a published table)

Run 2026-11-19 by the lead agent. abagen 0.1.3 (pandas 1.5.3, numpy 1.26.4; abagen 0.1.3 requires pandas < 2), python 3.11, conda env `abagen`.
Source: Allen Human Brain Atlas normalized microarray, 6 donors (9861, 10021, 12876, 14380, 15496, 15697; 1 female, ages 24–57), downloaded with `abagen.fetch_microarray` from https://human.brain-map.org/api/v2/well_known_file_download/ (Allen terms of use: https://alleninstitute.org/legal/terms-use/). Raw download (~1.7 GB) not kept here; re-fetchable.

## Atlas
`JulichBrain_v31_MNI152_hemisplit.nii.gz` — built from the two hemisphere label volumes of Julich-Brain v3.1 (MNI152 1 mm; EBRAINS; copies in analyses_metabol_rate_cortical/data_raw/anatomical_atlases/JulichBrain_v31/): left hemisphere keeps labels 1–207, right hemisphere = label + 207 → 414 hemisphere-specific regions (no L/R voxel overlap). `julich_v31_hemisplit_atlas_info.csv` (id, label, hemisphere, structure) gives abagen the structure class used for sample matching: cortex 284 (incl. 7 GapMaps and piriform/entorhinal allocortex), subcortex/brainstem 122, cerebellum 8 (cerebellar nuclei). Class assignment is by region-name keywords; owner review welcome.

## Parameters (`parameters.json`)
{
"atlas": "ahba/JulichBrain_v31_MNI152_hemisplit.nii.gz",
"atlas_info": "ahba/julich_v31_hemisplit_atlas_info.csv",
"donors": "all",
"lr_mirror": "bidirectional",
"missing": "centroids",
"tolerance": 2,
"sample_norm": "srs",
"gene_norm": "srs",
"norm_matched": true,
"norm_structures": false,
"region_agg": "donors",
"agg_metric": "mean",
"ibf_threshold": 0.5,
"probe_selection": "diff_stability",
"donor_probes": "aggregate",
"corrected_mni": true,
"reannotated": true,
"return_counts": true,
"return_donors": false,
"return_report": true
}
i.e. abagen defaults plus: bidirectional L/R mirroring of samples, tolerance 2 mm, empty regions filled from the nearest donor sample centroid (`missing='centroids'`), scaled-robust-sigmoid normalisation of samples and genes within donor, donor-mean aggregation. Probe reannotation Arnatkeviciute 2019; intensity filter 50 %; differential-stability probe selection → 15,633 genes. Full auto-generated methods text: `abagen_methods_report.txt`.

## Files
| file | content |
|---|---|
| `abagen_julich_v31_expression.csv` | Stored outside this GitHub repository at `~/Library/CloudStorage/OneDrive-AllenInstitute/Analysis_region_celltype_human/abagen_julich_v31/`; 414 regions (row index = atlas id) × 15,633 genes; values are donor-averaged, SRS-normalised expression in [0, 1] (sha256 `3c3104697fce6dc82ed0b2b060834558e5c1245efa90091e6f1357ceda0325ac`). Set `AHBA_JULICH_V31_DIR` to a different local directory when running the cortical c6 analysis elsewhere. |
| `abagen_julich_v31_sample_counts.csv` | samples assigned per region × donor (after mirroring); total 4604 |
| `regions_without_own_samples.csv` | 31 hemisphere-regions (19 cortical: 8v2, IFJ2, IFS3, Ia1, Ia3, Id9, MFG1, Op1, Op10, Op7, PirT, hIP7, hOc5, hOc6 on one or both sides; 12 subcortical) whose values come from the nearest centroid sample — **treat as imputed; drop for strict analyses** |
| `julich_v31_hemisplit_atlas_info.csv`, `JulichBrain_v31_MNI152_hemisplit.nii.gz` | atlas used |
| `run_abagen_julich.py`, `parameters.json`, `abagen_methods_report.txt` | provenance |

## Checks
Left/right profiles of the same region: median Pearson r 0.86 across 142 cortical pairs (low values coincide with centroid-filled sides). hOc1 (V1) shows the expected granular-layer/PV signature: RORB 0.93 vs cortical median 0.71, PVALB 0.82 vs 0.66.

## Registry proposal
One secondary row under the Hawrylycz 2012 citation: Item number "abagen Julich v3.1", Data role "secondary (processed by abagen 0.1.3)", Material type "microarray (Agilent) bulk tissue", Taxon Homo sapiens, n = 6 donors, Source URL = AHBA download API; Collection = Allen Institute. No item CSV in the Evo-M1 item sense is proposed for the full matrix; the analysis-ready derivative (cell-type marker scores per Julich area) is to be designed with the owner and would become the item.
