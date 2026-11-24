# Naumann et al. 2016 — Table 2

Naumann et al., “Conserved size and periodicity of pyramidal patches in layer 2 of medial/caudal entorhinal cortex,” *JCN* 524:783–806, DOI 10.1002/cne.23865. This item is “Neuron Number/Calbindin Patch” on PDF page 17 (printed p. 799). Its five species rows come from the locally held `Naumann_etal_2016_fullText.xml`, checked against the exact PDF.

The source-order snapshot preserves the number of patches and brains and the printed neuron-per-patch `±` values. The table **does not define** the type of `±`; the analysis column is explicitly `plusminus_as_published`, not SD or SEM. The species key for this paper resolves common names while preserving those names in the CSV. The R reader writes five species summaries and a public TSV.

Run from the repository root: `Rscript --vanilla Naumann_etal_2016/Naumann_etal_2016_Table2_snapshot.R` then `Rscript --vanilla Naumann_etal_2016/Naumann_etal_2016_Table2.R`. The second script reads only its frozen snapshot. Codex checked the XML table and rendered PDF on 2026-11-24; human visual signoff remains pending. No figure-derived data were extracted.
