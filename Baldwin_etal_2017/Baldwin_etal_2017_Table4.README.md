# Baldwin et al. 2017, Table 4

Baldwin, M. K. L., Cooke, D. F., & Krubitzer, L. (2017). Intracortical microstimulation maps of motor, somatosensory, and posterior parietal cortex in tree shrews (*Tupaia belangeri*) reveal complex movement representations. *Cerebral Cortex*, 27, 1439–1456. [DOI](https://doi.org/10.1093/cercor/bhv329).

The open [PMC PDF](https://pmc.ncbi.nlm.nih.gov/articles/PMC6075024/pdf/bhv329.pdf) is frozen in this folder. Table 4 is printed on PDF page 13. Its 10 cases, six cortical-area columns and printed Average row were manually transcribed into a wide frozen snapshot and checked against the rendered page by Codex on 2026-11-23. `nm` means thresholds were not measured; `n/a` is a distinct printed value and is not recoded as `nm`. Values are mean long-train ICMS thresholds in μA, with site n. The printed Average row is a source summary, not an eleventh case.

Run `Rscript --vanilla Baldwin_etal_2017/Baldwin_etal_2017_Table4.R` from repository root. The reader reshapes the snapshot into 66 case/summary × area records, retaining the printed strings and adding numerical values only where printed. It writes the analysis CSV and registry-coded public TSV. Site n sums across cases agree with all six printed N totals (45, 36, 95, 25, 56, 13). The printed across-case threshold averages are retained as published; they are not recomputed from rounded case means. The AddON registry entry is used while the main registry is occupied. Human visual signoff remains pending.

This is a table item, so no figure replot applies. The area means complement the map figures but do not provide map geometry or per-site threshold values.
