# Data sources: Wei et al. 2019 expansion maps and Allen Human Brain Atlas (2026-11-19)

Prepared by the lead agent after the data-discovery sub-agent located the Wei deposit and then stalled on a package install (stopped; nothing it wrote reached Evo-M1). Nothing in `__ReadMe.xlsx` was edited.

## 1. Wei et al. 2019 — chimpanzee→human cortical expansion (Castrillon dataset #2)
- Paper: Nat Commun 10:4839, DOI 10.1038/s41467-019-12764-8 (open access). Data-availability statement points to the HCP (human MRI) and the National Chimpanzee Brain Resource (chimpanzee MRI); the **expansion maps themselves are on the Dutch Connectome Lab site** (https://www.dutchconnectomelab.nl/, "Data of our study": `Wei_et_al_2019_NatureComms.zip`, 1,058,067 B, sha256 `f9505a3c538a248e60a4fbf9ad3c7117dc8b17d7910005368b3e5f1064922848`). Host `www.dutchconnectomelab.nl` was approved for the sandbox; download verified twice (identical checksum).
- Licence: none stated on the site or in the zip → treat as author-provided research data; cite the paper and the site.
- Contents: `chimp2humanDK114.csv` — **a published region-level table** (114 DK-scale-114 regions, RSN label, expansion ratio 0.89–4.05); `lh/rh.chimp2humanF.smoothed15.mgh` — vertex-wise fsaverage maps (163,842 vertices/hemisphere, 15 mm smoothing, 0 = medial wall).
- Downloaded to `Evo-M1-Trait-Data/Wei_etal_2019/dutchconnectomelab_download/` with `download_manifest.csv`; paper PDF copied from References.Data; `Wei_etal_2019_README.md` written.
- **Derived table** (not a published table): `Wei_etal_2019/derived_julich_v31/wei2019_expansion_julich_v31.csv` — vertex means within Julich-Brain v3.1 fsaverage labels, 146 regions × L/R/B; cortex vertex-weighted mean 3.368; lowest Area 5Ci 1.83, 3a 1.87, 4p 1.94; highest MFG1 9.14, MFG5 8.39, IFS1 7.14 — the sensorimotor-low / prefrontal-high gradient of the paper. Also copied to `analyses_metabol_rate_cortical/data_intermediate/`.
- Proposed registry row: citation above; Item number "DK114 table"; Item = Wei_etal_2019_DK114 (snapshot = byte copy of the CSV); Source URL = the zip URL; Material type "in vivo MRI (T1), surface-based"; Taxon "Homo sapiens; Pan troglodytes (ratio)"; Measure "cortical surface-area expansion ratio human/chimpanzee"; Data role primary; n = 30 humans / 29 chimpanzees. A second, optional row for the derived Julich table as secondary/derived. **Not built yet** — the deposit has no DOI of its own; owner to confirm the registration convention for website deposits before the item is built.
- Comparable alternatives already reachable via neuromaps (OSF): `hill2010` and `xu2020` evolutionary-expansion maps — both macaque→human, not chimpanzee; documented for completeness, not substitutes.

## 2. Allen Human Brain Atlas microarray (Hawrylycz et al. 2012; Castrillon dataset #4)
- Paper: Nature 489:391, DOI 10.1038/nature11405; PDF copied from References.Data into `Evo-M1-Trait-Data/Hawrylycz_etal_2012/`; README written. **No data obtained yet.**
- The owner's "Allen Inst bulk RNA" = bulk microarray, 6 donors, 3,702 samples (an RNA-seq subset exists for 2 donors). Castrillon used the abagen-processed, ENIGMA-packaged HCP-MMP1.0 matrix (8,426 genes).
- Route A (fast, fixed parcellations): ENIGMA toolbox `fetch_ahba()` CSVs (DK-68, Schaefer, Glasser-360) hosted on GitHub raw — needs `raw.githubusercontent.com` approval; avoid `pip install enigmatoolbox` in the sandbox (VTK dependency; the sub-agent's install hung >90 min) and fetch the CSVs directly.
- Route B (project-preferred): abagen on the Julich-Brain v3.1 MNI152 merged label volume already in the cortical repo → 300 regions × genes joining c0 directly. Needs `human.brain-map.org` / `api.brain-map.org` approval, ~4 GB download, 20–40 min compute; record abagen version + parameters.
- Evo-M1 handling: do not itemise the raw microarray; register the processed region × gene matrix as a secondary item (`Hawrylycz_etal_2012_abagenJulichV31`) and design a cortical cell-type-marker summary item with the owner.

## 3. Deviations
- Sub-agent stopped after no progress for 90 min; its downloads were redone by the lead (checksums identical), its report was not produced; this document replaces it.
- No abagen/ENIGMA installation or download attempted by the lead; routes documented only.
- The conda env `ahba` created by the sub-agent may be half-installed; safe to delete.
