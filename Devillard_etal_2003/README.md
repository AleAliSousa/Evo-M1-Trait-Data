# Devillard et al. 2003: feral cat study-colony size

Devillard, S., Say, L. & Pontier, D. (2003). Dispersal pattern of domestic cats
(Felis catus) in a promiscuous urban population: do females disperse or die?
Journal of Animal Ecology 72:203–211.
https://doi.org/10.1046/j.1365-2656.2003.00692.x

Extracted 2026-10-23 from the publisher's full-text Methods, subsection
"monitored population":
https://besjournals.onlinelibrary.wiley.com/doi/10.1046/j.1365-2656.2003.00692.x
The publisher reports 70 feral cats in a Lyon hospital park and explicitly
characterizes the colony as a single stable social group. Both statements were
checked in the full text. The source snapshot and clean CSV retain the statistic,
setting, age-scope uncertainty and source location. No PDF was available through
the command-line download; the full text was readable through the web tool.
Not found in the local EndNote metadata search.

This is primary study-population reporting by the authors, not a species mean.
The colony is provisioned and annual density varies. It must remain separate
from natural wildcat group sizes, household housing numbers and adult-only means.
A source-specific colony label makes the context visible. It also illustrates
why Zhu's "Solitary" category for Felis catus must not erase population variation.

## Snapshot provenance — repaired 2026-10-31

Until 2026-10-31 `Devillard_etal_2003_ColonySize_snapshot.csv` was a byte-identical copy of the
analysis CSV (md5 `b798e51941205ac1adf63c9648b60775`) — a cleaned table with project columns, not
the published text as printed. There was nothing a reviewer could check against the paper.

It is now a **constructed snapshot** built by `build_colony_size.py` directly from
`Devillard-2003-Dispersal pattern of domestic c.pdf`: one row carrying the printed wording
(`70 feral cats`, `a large stable social group characterized by a dominance hierarchy`) plus the
three verbatim Methods sentences and their locator (Materials and methods, first paragraph,
printed p. 204). The script asserts each passage appears verbatim in the PDF and fails if it does
not, so the snapshot cannot drift from the source.

`Devillard_etal_2003_ColonySize.csv` is unchanged and remains the analysis layer — built since 2026-10-31 by `Devillard_etal_2003_ColonySize.R`, which reads the constructed snapshot, parses the printed `70 feral cats` and stops if that wording changes. `build_colony_size.py` writes the snapshot only. The item is unregistered, so the script writes the CSV and reports that the public TSV is skipped until a registry row exists.
