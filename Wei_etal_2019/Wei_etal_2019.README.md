# Wei_etal_2019 — chimpanzee-to-human cortical expansion

Wei, Y., de Lange, S. C., Scholtens, L. H., Watanabe, K., Ardesch, D. J., Jansen, P. R., Savage, J. E., Li, L., Preuss, T. M., Rilling, J. K., Posthuma, D., & van den Heuvel, M. P. (2019). Genetic mapping and evolutionary analysis of human-expanded cognitive networks. *Nature Communications, 10*, 4839. https://doi.org/10.1038/s41467-019-12764-8

Folder created 2026-11-19 (lead agent, after the data-discovery sub-agent located the deposit). PDF copied from the owner's References.Data library.

## Deposit
Repository: Dutch Connectome Lab website, section "Data of our study" (https://www.dutchconnectomelab.nl/ → Downloads), file `Wei_et_al_2019_NatureComms.zip` (1,058,067 bytes, sha256 `f9505a3c538a248e60a4fbf9ad3c7117dc8b17d7910005368b3e5f1064922848`). No README or licence file is inside the zip; the site states no licence — treat as "available on request terms of the authors" until confirmed. Download manifest: `dutchconnectomelab_download/download_manifest.csv`.

Contents:
| file | what | format |
|---|---|---|
| `chimp2humanDK114.csv` | **region-level table**: 114 Desikan-Killiany subdivisions (Cammoun 2012 scale-114 names, e.g. `ctx-lh-bankssts_1`), resting-state network assignment (`RSN`: DMN, VentralAttention, Visual, Limbic, DorsalAttention, Somatomotor, FrontalParietal), `Expansion` (human/chimpanzee surface-area ratio; range 0.89–4.05) | CSV, 114 rows |
| `lh/rh.chimp2humanF.smoothed15.mgh` | vertex-wise expansion map on FreeSurfer fsaverage (163,842 vertices per hemisphere; 0 = medial wall/unmapped; smoothed 15 mm FWHM per file name) | FreeSurfer MGH |

Cohort (paper Methods): 29 adult chimpanzees and 50 adult humans, in vivo T1; surface-to-surface mapping of cortical regions; regional expansion is human relative to chimpanzee. Exact definition of the vertex-wise quantity ("chimp2humanF") is not documented in the zip — see the paper's Methods ("Cortical expansion") before using absolute values; ratios between regions are safe.

## Items
- **Wei_etal_2019_DK114** is built from the deposited 114-row CSV. See `Wei_etal_2019_DK114.README.md` for commands, line-ending provenance, and the pending owner registry row. The paper DOI is the item DOI; the archive URL goes in the Source URL column.
- `derived_julich_v31/wei2019_expansion_julich_v31.csv` — **derived, not a published table**: vertex-wise map averaged within Julich-Brain v3.1 fsaverage labels (146 regions × L/R/B rows; `expansion_mean`, `expansion_rel_cortex` = mean / vertex-weighted cortical mean 3.368; vertices with value 0 excluded; CA2/CA3 and two unnamed label values have no coverage). Produced by the lead agent with the c0 helper logic (direct label averaging on fsaverage; no resampling needed). This is the file the cortical repo consumes (copied to `analyses_metabol_rate_cortical/data_intermediate/`). Registry: record as secondary/derived if registered at all.

## Use in the project
Castrillon et al. 2023 (Sci Adv) dataset #2. Serves as the cortical-expansion covariate for the cortical metabolic-rate analyses (c0 Julich areas join directly; Heiss-1985 groups via the Zilles→Julich crosswalk).
