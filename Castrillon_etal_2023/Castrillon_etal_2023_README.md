# Castrillon_etal_2023 — energetic costs of signalling (external deposit, not an Evo-M1 item)

Castrillon, G., Epp, S., Bose, A., Fraticelli, L., Hechler, A., Belenya, R., Ranft, A., Yakushev, I., Utz, L., Sundar, L., Rauschecker, J. P., Preibisch, C., Kurcyus, K., & Riedl, V. (2023). An energy costly architecture of neuromodulators for human brain evolution and cognition. *Science Advances, 9*(50), eadi7632. https://doi.org/10.1126/sciadv.adi7632

Folder created 2026-11-19 to give `analyses_metabol_rate_cortical/scripts/x1_castrillon2023_comparison.py` a durable input location (precedent: `Hansen_etal_2022/github_hansen_receptors`). PDF from the owner's library.

## github_energetic_costs/
Subset of https://github.com/NeuroenergeticsLab/energetic_costs at commit `2191ea4888ae0b26d2a2cc1903950f7fbb109f25` (2023-11-08; Zenodo DOI 10.5281/zenodo.10084430 is the time-stamped copy). Only the files the comparison uses were copied (manifest with sha256: `download_manifest.csv`):
- `data/gx_all-cohorts_roi_nsubj-47_degree-weighted.csv` — 335 HCP-MMP parcels × 5 datasets: degree of functional connectivity, CMRglc (µmol/100 g/min), energetic_costs (residual CMRglc | dFC), Yeo network; `..._vox_...csv` the voxel-level equivalent; Neurosynth PLS-score table.
- `data/external/Hansen2021/Hansen2021_19-pet-tracers_roi.csv` — Hansen et al. 2022 PET tracers per parcel (their copy).
- `data/external/AHBA/allgenes_stable_r0.2_glasser_360.csv` — AHBA, abagen/ENIGMA pipeline, Glasser 360 + 14 subcortical rows, 8,426 genes.
- `data/external/Wei2019/*.32k.chimp2humanF.smoothed15.shape.gii` — Wei et al. 2019 expansion on fs_LR 32k (cf. `Wei_etal_2019/` fsaverage originals).
- `data/external/BigBrainWarp/tpl-fs_LR_den-32k_desc-profiles.txt` — 50 equivolumetric BigBrain intensity surfaces × 64,984 vertices (Paquola et al. 2021) — also the route to GLI-like laminar profiles for the cortical repo.
- `data/external/brainSMASH/LeftParcelGeodesicDistmat.txt` — 180 × 180 left-hemisphere parcel geodesic distances used for their spatial null.
- `scripts/*.md`, `src/functions.py` — their notebooks (markdown export) and helper functions, for method reference.
Licence: repository carries no LICENSE file; the OpenNeuro dataset ds004513 holds the raw data. Treat as author-provided research code/data; cite the paper and Zenodo DOI.

## enigma_parcellations/
`glasser_360_conte69.csv` (fs_LR 32k vertex labels, L 1–180 / R 181–360) and `glasser_360_fsa5.csv` (fsaverage5) from https://github.com/MICA-MNI/ENIGMA (`enigmatoolbox/datasets/parcellations`, commit `b08974b55243060cbc1fad12c87048037446e8f7`), BSD-3 licence. Used to parcellate the fs_LR files above and to bridge Glasser parcels to Julich-Brain v3.1 on fsaverage5.

## Registry
No item is proposed: these are processed outputs of another group's pipeline and third-party atlas files, used as comparison inputs. If a row is wanted, register the ROI table as secondary (Data role "secondary (processed by Castrillon et al.)", Item number "GitHub ROI table") under the citation above.
