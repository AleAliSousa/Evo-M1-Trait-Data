# Hawrylycz_etal_2012 — Allen Human Brain Atlas (AHBA) microarray

Hawrylycz, M. J., Lein, E. S., Guillozet-Bongaarts, A. L., Shen, E. H., Ng, L., Miller, J. A., … Jones, A. R. (2012). An anatomically comprehensive atlas of the adult human brain transcriptome. *Nature, 489*, 391–399. https://doi.org/10.1038/nature11405

Folder created 2026-11-19. PDF copied from the owner's References.Data library. **No data downloaded yet** — the two access routes below need network approval and an owner decision on which parcellation to register.

## What the owner called "Allen Inst bulk RNA"
The AHBA is bulk microarray (Agilent 8×60K) from 6 adult donors (3,702 tissue samples; ~20,700 genes), not RNA-seq. (The Allen Institute also released RNA-seq on a subset of the same samples — 2 donors, 120 samples each; this is the only "bulk RNA-seq" at the regional level.) Castrillon et al. 2023 (dataset #4) used the microarray via the abagen pipeline as packaged in the ENIGMA toolbox (HCP-MMP1.0 parcels, 8,426 genes after donor-consistency filtering ≥ 0.2).

## Route A — ENIGMA toolbox precomputed matrices (fast; fixed parcellations)
`enigmatoolbox.datasets.fetch_ahba()` returns parcel × gene matrices (abagen defaults; parcellations: Desikan-Killiany 68, Schaefer 100–400, Glasser 360 (HCP-MMP1.0)). Files are downloaded by the function from the ENIGMA GitHub repository (raw.githubusercontent.com) — host must be allow-listed. `pip install enigmatoolbox` pulls VTK (hundreds of MB; the sub-agent's install hung for >90 min in the sandbox) — install from a wheel or only download the CSVs directly from the repository instead. Joins: Glasser 360 ↔ Wagstyl S1 (same HCP-MMP parcels); DK 68 ↔ Hansen 2022 scale033 (83 regions, DK-based) after a DK-scale check.

## Route B — abagen with Julich-Brain v3.1 (preferred for this project; slow)
`abagen.get_expression_data(atlas=JulichBrain_v31_MNI152_labelled_merged.nii.gz, atlas_info=<from the lut>)` with default settings (probe selection by differential stability, scaled-robust-sigmoid normalisation, mirrored samples, donor averaging). Needs the raw AHBA download (~4 GB; hosts human.brain-map.org / api.brain-map.org, allow-list required) and ~20–40 min compute. Output: 300-region × ~15,000-gene matrix joining c0 directly. Record abagen version and the full parameter set in `abagen_julich_v31/parameters.json`.

## Proposed Evo-M1 handling
Primary microarray is not a "paper table" → do not itemise it. Register one processed product as a secondary item (Data role "secondary (processed by abagen)"), e.g. **Hawrylycz_etal_2012_abagenJulichV31** (region × gene matrix, with gene list), and derive from it the cortical cell-type-marker summary item the analyses actually need (marker-score per area for the Jorstad subclasses), to be designed with the owner.
