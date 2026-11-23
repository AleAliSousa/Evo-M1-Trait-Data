# Baldwin et al. 2017, Table 2

Baldwin, M. K. L., Cooke, D. F., & Krubitzer, L. (2017). Intracortical microstimulation maps of motor, somatosensory, and posterior parietal cortex in tree shrews (*Tupaia belangeri*) reveal complex movement representations. *Cerebral Cortex*, 27(2), 1439–1456. DOI: [10.1093/cercor/bhv329](https://doi.org/10.1093/cercor/bhv329).

## Source and scope

Table 2, “Case overview,” was transcribed from the [structured table on the PMC article page](https://pmc.ncbi.nlm.nih.gov/articles/PMC6075024/) and checked against the [author-hosted article PDF](https://krubitzer.faculty.ucdavis.edu/wp-content/uploads/sites/208/2017/11/2017-Intracortical-Microstim-Maps-of-Motor-S1-and-PPC-in-Tree-Shrews.pdf) on 2026-11-23. The PMC eFetch response explicitly says the publisher does not allow downloading this article’s full text in XML form; Europe PMC’s fullTextXML endpoint also failed. The frozen `Baldwin_etal_2017_Table2_snapshot.csv` therefore preserves the rendered table: ten tree-shrew cases, 16 case-by-stimulation-duration rows and three published duration-total rows. It retains the six area columns, row total, fractions, source order, blank repeated case labels, and note. The article’s Methods identify all cases as adult female *Tupaia belangeri*.

The reader turns each responsive/tested pair into separate numeric counts, retaining published fractions, case, duration, area and total-row status. The output has 133 rows (19 source rows × seven printed area/total columns). Printed total rows and columns are flagged so they are not counted as independent observations. This table measures the frequency of movement-evoking ICMS sites, not cortical surface area, full map shape, or stimulation thresholds. The originally listed ICMS-map figures remain a separate extraction task.

## Printed total checks

The reader recomputes each row's six area sums against its printed total. Five of 38 numerator/denominator comparisons differ: 14–34 at 500 ms (responsive 16 versus printed 15), 14–88 at 50 and 800 ms (tested 42 versus printed 52 in each row), 14–124 at 500 ms (responsive 26 versus printed 25), and the 500-ms published aggregate (responsive 324 versus printed 323). All cells remain as printed. These are source-table inconsistencies, not extraction corrections; use the six area cells for area-specific analysis and do not infer a corrected published total.

## Build

From the repository root, run:

```sh
Rscript --vanilla Baldwin_etal_2017/Baldwin_etal_2017_Table2.R
```

The script reads only its own snapshot for measurements, writes the local CSV and DOI-coded public TSV, and looks up its name in `__ReadMe.xlsx` with `__ReadMeAddON.xlsx` as the temporary fallback. Definitions are in `reference_tables`. Codex compared the snapshot with the rendered source table on 2026-11-23; human visual signoff remains pending. Table 2 is tabulated, so the figure-replot rule does not apply to this item.
