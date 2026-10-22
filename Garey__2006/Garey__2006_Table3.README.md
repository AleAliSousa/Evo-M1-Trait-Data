# Garey 2006 (Brodmann 1909 translation) — Table 3 — thickness of homologous cortical areas (mm)

Garey LJ (2006). *Brodmann's Localisation in the Cerebral Cortex* (3rd ed.; translation of K. Brodmann 1909, *Vergleichende Lokalisationslehre der Grosshirnrinde*). Springer. ISBN 978-0-387-26917-7 (catalogued under alt id `ISBN:9780387269177`). First English edition: Smith-Gordon, London, 1994.

Registry (`__ReadMe.xlsx`): Item name **`Garey__2006_Table3`**, encoded `ISBN%3A9780387269177_Table3`
(after the registry row `Garey__2006_registry_rows.xlsx` is pasted and `_tools/file_list.R` is run).

## Why this folder is not called Brodmann
This is the English translation and is credited to its translator/editor, like any book. The values are
**Brodmann's 1909 numbers**, so data role is **secondary** (source: Brodmann 1909 German original). It is
**not** Brodmann 1913 (`Brodmann__1913`, a different paper with different tables). Use it to cross-check
the harder-to-read German scans; where the German tables are transcribed, supersede into them. Never
average the translation with its own source.

## What the data are
60 rows: Brodmann areas 4, 6, 7, 17, 28, 29 x 10 species. 'Man' prints ranges for some areas (footnote 2); one range also for flying fox area 29, rabbit area 29 and kangaroo area 4. `-` = not given (kangaroo area 6). The `Guenon` column is Table 3's name for the monkey; Table 6 splits it into macaque and marmoset.
Printed p. 62 of the 2006 Springer edition (the PDF in this folder, `Garey__2006_Brodmann_Localisation_in_the_Cerebral_Cortex.pdf`).

## Source -> Snapshot -> Data
PDF text layer (born-digital) checked against the page -> `Garey__2006_Table3_snapshot.csv` (as printed, ranges and
`-` kept as text) -> `Garey__2006_Table3.R` -> `Garey__2006_Table3.csv` (+ public TSV once the registry row exists).
Species are resolved through `_keys/General/species_key.csv` (`source_publication == Garey__2006`); printed
names are kept in `species_as_published`. The translator's *Glossary of Species Names* (printed pp. 281-282)
gives the modern equivalents used. Genus-level (`sp.`) where the table does not say which species.

## Open points
- Human visual check of the snapshot against the PDF page is pending.
- `Prosimian` in Table 6 is mapped to the black lemur used in Table 3 (assumption).
