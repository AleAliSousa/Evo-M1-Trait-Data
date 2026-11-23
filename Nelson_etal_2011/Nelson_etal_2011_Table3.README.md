# Nelson et al. 2011, Table 3

Nelson, E. L., Emery, M. S., Babcock, S. M., Novak, M. F. S. X., Suomi, S. J., & Novak, M. A. (2011). Head orientation and handedness trajectory in rhesus monkey infants (*Macaca mulatta*). *Developmental Psychobiology*, 53(3), 246–255. DOI: [10.1002/dev.20517](https://doi.org/10.1002/dev.20517).

## Source and scope

The exact local PDF is `Nelson-2011-Head orientation and handedness tr.pdf`. Table 3, printed page 252 / PDF page 7, gives laterality indices for 16 named rhesus infants (eight male, eight female) in hand-to-face, reaching, and coordinated bimanual tube tasks. `Nelson_etal_2011_Table3_snapshot.csv` retains the printed table's subject order, sex blocks, three task columns, two-decimal indices and note. Codex transcribed the PDF text layer, normalized its broken minus glyph to `−`, and inspected the rendered page on 2026-11-23. Human visual signoff remains pending.

The item reader reshapes the table to 48 individual-by-task rows while preserving the original LI strings. Positive LI means right bias and negative means left bias, as the source note states. The tube-task observations are relevant to Püschel et al. 2026; the other two tasks are retained but should not be pooled with tube LI. The tasks were measured at different developmental ages; a single shared age is not added to these rows.

From the repository root, run:

```sh
Rscript --vanilla Nelson_etal_2011/Nelson_etal_2011_Table3.R
```

The script reads only its frozen snapshot, writes the 48-row local CSV and DOI-coded public TSV, and uses `__ReadMeAddON.xlsx` while the main registry is occupied. Checks require 16 unique subjects, numeric LI within −1 to 1, and three retained task series. The table has no independent printed total to recompute. It is not figure-derived, so a replot is not applicable.
