# Lewitus_etal_2012_b_TableS3

Lewitus, E., Hof, P. R., & Sherwood, C. C. (2012). Phylogenetic comparison of neuron and glia densities in the primary visual cortex and hippocampus of carnivores and primates. Evolution, 66(8), 2551–2563. https://doi.org/10.1111/j.1558-5646.2012.01601.x

The untouched author XLS is frozen as `Lewitus_etal_2012_b_TableS3_snapshot.xls`; read sheet `S3`. The other sheets remain intact for audit. This item contains 11 species. The Evolution paper is distinct from the existing Brain Structure and Function paper, so it uses sequence `b`.

Methods (pp. 2555–2557): left hemispheres, Nissl histology, design-based stereology. The column headed HIPPOCAMPUS measures CA1–3 pyramidal regions, not the complete hippocampal formation. All subjects were adult except Pithecia pithecia and Trachypithecus francoisi. Fixation/embedding and unknown shrinkage vary across specimens. The digital values retain more digits than the printed main table.

V1 data are treated as reused/secondary to the earlier Lewitus study; preserve them for audit and covariates, but do not pool them as an independent replicate. CA1–3 data are primary. The earlier repository item already holds the non-primate V1 data and eight primate glial densities. Reported ratios are retained independently of densities. The R reader diagnoses discrepancies >0.01 in `table_checks`; these do not justify rewriting the published numbers.

Digital source: no transcription or human visual-check date applies. Headers, missing `--` values and source species spelling are preserved in the frozen XLS. Analysis values use cells/mm3 and unitless ratios. All 66 source measurement cells were compared to the analysis output, including missingness. Of 22 ratio checks, 19 are within 0.01 and 3 are not evaluable because CA1–3 data are missing. The identical V1 values for Dasyprocta leporina and Cynocephalus volans reproduce the earlier source; they are not independent new measurements. Stereological density is registered as its own measure family; it is not added to the current isotropic-fractionator cell-count merge.

Built by Codex on 2026-10-25. Rebuild with `Rscript Lewitus_etal_2012_b_TableS3.R` from any directory. The script reads only the frozen source and live registry; no source download or manual output editing is required. Species labels remain as published; any later harmonisation belongs in the collection-scoped species key.
