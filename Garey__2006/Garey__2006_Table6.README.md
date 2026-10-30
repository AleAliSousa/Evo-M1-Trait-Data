# Garey 2006 (Brodmann 1909 translation) — Table 6 — thickness of layer I (mm) and ratio to total thickness

Garey LJ (2006). *Brodmann's Localisation in the Cerebral Cortex* (3rd ed.; translation of K. Brodmann 1909, *Vergleichende Lokalisationslehre der Grosshirnrinde*). Springer. ISBN 978-0-387-26917-7 (catalogued under alt id `ISBN:9780387269177`). First English edition: Smith-Gordon, London, 1994.

Registry (`__ReadMe.xlsx`): Item name **`Garey__2006_Table6`**, encoded `ISBN%3A9780387269177_Table6`
(after the registry row `Garey__2006_registry_rows.xlsx` is pasted and `_tools/file_list.R` is run).

## Why this folder is not called Brodmann
This is the English translation and is credited to its translator/editor, like any book. The values are
**Brodmann's 1909 numbers**, so data role is **secondary** (source: Brodmann 1909 German original). It is
**not** Brodmann 1913 (`Brodmann__1913`, a different paper with different tables). Use it to cross-check
the harder-to-read German scans; where the German tables are transcribed, supersede into them. Never
average the translation with its own source.

## What the data are
40 rows: areas 4, 6, 17, 28 x 10 columns (Monkey is split into Macaque and Marmoset as printed). Each thickness carries a printed ratio `(1:n)`; the snapshot keeps the two printed lines per area, the analysis CSV joins them. Header carries footnote 12), whose text was not found in the extracted translation. The printed table page is rotated 90 degrees.
Printed p. 79 of the 2006 Springer edition (the PDF in this folder, `Garey__2006_Brodmann_Localisation_in_the_Cerebral_Cortex.pdf`).

## Source -> Snapshot -> Data
PDF text layer (born-digital) checked against the page -> `Garey__2006_Table6_snapshot.csv` (as printed, ranges and
`-` kept as text) -> `Garey__2006_Table6.R` -> `Garey__2006_Table6.csv` (+ public TSV once the registry row exists).
Species are resolved through `_keys/General/species_key.csv` (`source_publication == Garey__2006`); printed
names are kept in `species_as_published`. The translator's *Glossary of Species Names* (printed pp. 281-282)
gives the modern equivalents used. Genus-level (`sp.`) where the table does not say which species.

## Open points
- Human visual check of the snapshot against the PDF page is pending.
- `Prosimian` in Table 6 (German *Halbaffe*, confirmed on the German scan) is mapped to the black lemur, the prosimian Brodmann illustrates throughout (Lemur macaco).
