# Caspar et al. 2018, Table 4

Caspar, K. R., Mader, L., Pallasdies, F., Lindenmeier, M., & Begall, S. (2018). Captive gibbons (Hylobatidae) use different referential cues in an object-choice task: Insights into lesser ape cognition and manual laterality. *PeerJ*, 6, e5348. DOI: [10.7717/peerj.5348](https://doi.org/10.7717/peerj.5348).

## Source and scope

The source is the locally available open-access `Caspar-2018-Captive gibbons (Hylobatidae) use.pdf`, Table 4 on printed/PDF page 15, also available at [PeerJ](https://peerj.com/articles/5348/). `Caspar_etal_2018_Table4_snapshot.csv` is a manually transcribed published-table view, prepared by Codex on 2026-11-23. It retains table order, the separate tube-task and object-choice-task blocks, the 29 individual rows (18 and 11), subject labels, abbreviated species, handedness indices, counts, z-scores, two-sided p-value strings, preference categories, and the abbreviation footnote. Underscores in `HI_TT` and `I_OCT` render the source's subscripted index labels in plain CSV; Unicode minus and superscript exponents retain the printed signs. The table's “Inserti-ons” header is retained as printed/line-broken.

The paper's table footnote expands six abbreviated species; those mappings are entered under `_keys/General/species_key.csv`. Subjects appearing in both tasks remain separate individual-by-task observations. The OCT block has no bouts or insertions, so these cells are blank in the analysis file. Some z-scores and p-values are identical across different printed subjects; they are retained without correction. The printed “‘Juvenile’” subject label is not treated as a named specimen outside this item.

## Build

From the repository root:

```sh
Rscript --vanilla Caspar_etal_2018/Caspar_etal_2018_Table4.R
```

The command produced the 29-row local CSV and DOI-coded public TSV on 2026-11-23. The reader uses only its own frozen snapshot for scientific values and expands species using the paper-specific General species key. It preserves the original p strings and converts their superscript notation to numeric values without rounding. `Item encoded` is looked up by `Item name`, preferring `__ReadMe.xlsx` and falling back to `__ReadMeAddON.xlsx` while the main workbook is occupied. Definitions describe every output column. Checks require 18 tube rows, 11 OCT rows, numeric handedness indices within −1 to 1, valid numeric p-values, and distinct task-plus-subject combinations. The source table has no independent total to recompute.

Codex inspected the PDF page beside the snapshot on 2026-11-23. Human visual signoff remains pending; AI review is not a human signature. No figure-derived dataset is made here, so a figure replot is not applicable.
