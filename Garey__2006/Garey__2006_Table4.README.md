# Garey 2006 (Brodmann 1909 translation) — Table 4 — body and brain weight and cortical thickness (areas 4 and 7)

Garey LJ (2006). *Brodmann's Localisation in the Cerebral Cortex* (3rd ed.; translation of K. Brodmann 1909, *Vergleichende Lokalisationslehre der Grosshirnrinde*). Springer. ISBN 978-0-387-26917-7 (catalogued under alt id `ISBN:9780387269177`). First English edition: Smith-Gordon, London, 1994.

Registry (`__ReadMe.xlsx`): Item name **`Garey__2006_Table4`**, encoded `ISBN%3A9780387269177_Table4`
(after the registry row `Garey__2006_Table4_registry_row.xlsx` is pasted and `_tools/file_list.R` is run).

## Why this folder is not called Brodmann
This is the English translation and is credited to its translator/editor, like any book. The values are
**Brodmann's 1909 numbers**, so data role is **secondary** (source: Brodmann 1909 German original). It is
**not** Brodmann 1913 (`Brodmann__1913`, a different paper with different tables). Use it to cross-check
the harder-to-read German scans; where the German tables are transcribed, supersede into them. Never
average the translation with its own source.

## What the data are
13 rows, one per species: body weight : brain weight (g) and cortical thickness (mm) for areas 4 and 7,
grouped by order as printed. The translation text uses it to argue thickness tracks body/brain size
more than taxonomic position. Printed p. 62 (same page as Table 3; the Guenon, Lemur, Flying fox, Hedgehog,
Rabbit, Ground squirrel and Kangaroo thicknesses repeat Table 3's values). Kangaroo area 4 prints
`2.8 (3.1)`; the bracket is kept in `CorticalThickness_area4_alt.mm`. Bat area 7 is `-` (blank). The snapshot keeps the translator's
endnote mark `Primates (*74)`; the script strips it. Endnote *74 (translator's, not Brodmann's): Brodmann wrote "Affen" (monkeys) here; they do not form an order, and nor do the prosimians. The mark is absent from the German original. Endnotes *69/*76 doubt which kangaroo species Brodmann meant (German *Bergkänguruh*), as in the species key.

## Source -> Snapshot -> Data
PDF text layer (born-digital) checked against the page -> `Garey__2006_Table4_snapshot.csv` (as printed, ranges and
`-` kept as text) -> `Garey__2006_Table4.R` -> `Garey__2006_Table4.csv` (+ public TSV once the registry row exists).
Species are resolved through `_keys/General/species_key.csv` (`source_publication == Garey__2006`); printed
names are kept in `species_as_published`. The translator's *Glossary of Species Names* (printed pp. 281-282)
gives the modern equivalents used. Genus-level (`sp.`) where the table does not say which species.

## Open points
- Human visual check of the snapshot against the PDF page is pending.
- 'Bat' is order-level (Chiroptera sp.); no species printed.
