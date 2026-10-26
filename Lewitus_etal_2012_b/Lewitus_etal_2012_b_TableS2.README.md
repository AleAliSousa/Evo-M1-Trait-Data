# Lewitus_etal_2012_b_TableS2

Lewitus, E., Hof, P. R., & Sherwood, C. C. (2012). Phylogenetic comparison of neuron and glia densities in the primary visual cortex and hippocampus of carnivores and primates. Evolution, 66(8), 2551–2563. https://doi.org/10.1111/j.1558-5646.2012.01601.x

Reads the untouched XLS, sheet S2. Retains all 71 species rows with brain mass. This supplement includes species without density estimates, so its row count differs from Table 2 and Table S3. Original volume numbers are retained alongside converted mm3 values. Brain g becomes mg, body kg becomes g, gestation remains days.

The supplement title labels layer volumes mm3, but Figure 4's legend explicitly identifies StrGr, StrMol and CrbGc as μm3. The R conversion uses this explicit legend: divide by 10^9. This source discrepancy is recorded in the errata file. The Methods specify left hemispheres for density sampling, but do not unambiguously establish whether all supplementary layer volumes are one-sided or bilateral. Accordingly these volumes remain available in the source database with a laterality flag and are excluded from the bilateral volume merge. Brain weights are recorded in the study; body mass and gestation are attributed to Jones et al. (2009).

No transcription check applies to the untouched digital source. The reader checks unique species and preserves missing `--` cells. No printed arithmetic total is available for a table-sum check.

Built by Codex on 2026-10-25. Rebuild with `Rscript Lewitus_etal_2012_b_TableS2.R` from any directory. The script reads only the frozen source and live registry; no source download or manual output editing is required. Species labels remain as published; any later harmonisation belongs in the collection-scoped species key.

<!-- errata:begin -->
## Errata

Generated from `reference_tables/Lewitus_etal_2012_b_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| Lewitus_etal_2012_b-E001 | DG_granular_layer_volume_mm3 | Supplemental Table 2 caption versus Figure 4 legend p.2558 | mm3 (caption); μm3 (Figure 4) |  | publication_ambiguity |  | confirmed | Figure 4 explicitly labels all three layers in μm3. Build retains original numbers and divides by 1e9 for mm3; laterality unresolved. | Confirmed source inconsistency; no silent correction. |
| Lewitus_etal_2012_b-E002 | DG_molecular_layer_volume_mm3 | Supplemental Table 2 caption versus Figure 4 legend p.2558 | mm3 (caption); μm3 (Figure 4) |  | publication_ambiguity |  | confirmed | Figure 4 explicitly labels all three layers in μm3. Build retains original numbers and divides by 1e9 for mm3; laterality unresolved. | Confirmed source inconsistency; no silent correction. |
| Lewitus_etal_2012_b-E003 | cerebellar_granular_layer_volume_mm3 | Supplemental Table 2 caption versus Figure 4 legend p.2558 | mm3 (caption); μm3 (Figure 4) |  | publication_ambiguity |  | confirmed | Figure 4 explicitly labels all three layers in μm3. Build retains original numbers and divides by 1e9 for mm3; laterality unresolved. | Confirmed source inconsistency; no silent correction. |

3 recorded, 0 open (proposed), 3 confirmed, 0 withdrawn.
<!-- errata:end -->
