# Phillips & Hopkins 2007, Table 1

Phillips, K. A., & Hopkins, W. D. (2007). Exploring the relationship between cerebellar asymmetry and handedness in chimpanzees (*Pan troglodytes*) and capuchins (*Cebus apella*). *Neuropsychologia*, 45(10), 2333–2339. [doi:10.1016/j.neuropsychologia.2007.02.010](https://doi.org/10.1016/j.neuropsychologia.2007.02.010).

## Source and scope

The source is [PMC's open structured HTML article, Table 1](https://pmc.ncbi.nlm.nih.gov/articles/PMC1951511/). The frozen CSV snapshot transcribes the HTML table directly, retaining its headers, group breaks, 16 chimpanzee rows and 11 capuchin rows in source order, original printed strings and all six columns. No PDF was needed for extraction. The table reports subject-level mean handedness index (MHI) for the coordinated bimanual TUBE task, right/non-right group, whole cerebellar volume in cc, and anterior/posterior cerebellar asymmetry quotients. The HTML and snapshot were checked side by side by Codex on 2026-11-23; human visual signoff remains pending.

The paper's method defines MHI as the mean of each individual's hand-use indices across TUBE trials. It is the source statistic relevant to Püschel's handedness compilation. Source taxon labels are *Pan troglodytes* and *Cebus apella*; the analysis uses *Pan troglodytes* and the collection's established *Sapajus apella* synonym mapping, while keeping the printed Capuchins group label. This paper's individual MHI must not be double-counted with the same subjects in other publications without an overlap check.

As a transcription cross-check, absolute MHI values reproduce the article text's species summaries after rounding: chimpanzee mean 0.35, SD 0.29; capuchin mean 0.75, SD 0.27.

## Build

From the repository root, run:

```sh
Rscript --vanilla Phillips_Hopkins_2007/Phillips_Hopkins_2007_Table1.R
```

The reader uses only its own frozen snapshot for measurements, writes the 27-row analysis CSV and DOI-coded public TSV, and looks up its registry identity in `__ReadMeAddON.xlsx` while `__ReadMe.xlsx` is occupied. It checks source row count, group boundaries, subject uniqueness, numeric fields, and MHI range. The table prints no independent total for a within-table arithmetic check. This is a table item, so figure replotting does not apply.
