# Baldwin et al. 2017, Table 3

Baldwin, M. K. L., Cooke, D. F., & Krubitzer, L. (2017). Intracortical microstimulation maps of motor, somatosensory, and posterior parietal cortex in tree shrews (*Tupaia belangeri*) reveal complex movement representations. *Cerebral Cortex*, 27, 1439–1456. [DOI](https://doi.org/10.1093/cercor/bhv329).

The open [PMC PDF](https://pmc.ncbi.nlm.nih.gov/articles/PMC6075024/pdf/bhv329.pdf) is frozen in this folder. Table 3 is printed on PDF page 5. The 10-case snapshot was manually transcribed in printed order and checked against the rendered page by Codex on 2026-11-23. Superscript `a` is represented as `ᵃ` and the source's `Unknown` text is retained. Its footnote says cases 14–14 and 14–20 lacked thorough movement recording. Complex-movement subcategories overlap and are not an exclusive partition; their displayed numbers must not be summed into the total complex column.

Run `Rscript --vanilla Baldwin_etal_2017/Baldwin_etal_2017_Table3.R` from repository root. The reader writes a 10-row analysis CSV and registry-coded public TSV, with source strings preserved beside parsed counts. It checks the 471 tested and 323 movement-eliciting site totals stated in the Results, and bounds each case's complex count by its movement count. It does not infer unrecorded movement types. The AddON registry entry is used while the main registry is occupied. Human visual signoff remains pending.

This is a table item, so no figure replot applies. Figure 6/7/11/12 map geometry and per-site thresholds still require separate figure digitization.
