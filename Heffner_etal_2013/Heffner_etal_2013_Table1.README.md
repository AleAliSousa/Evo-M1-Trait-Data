# Heffner_etal_2013_Table1

## Source
Heffner, R. S., Koay, G., & Heffner, H. E. (2013). Hearing in American leaf-nosed bats. IV: the Common vampire bat, *Desmodus rotundus*. *Hearing Research*, 296, 42-50. doi:10.1016/j.heares.2012.09.011. Public copy: `Heffner_etal_2013/Heffner_etal_2013.pdf` (born-digital).

Registry Item **Table 1 (p. 48, PDF page 7)**.

## Why this item exists
The paper's comparative table: predicted (from functional interaural distance) vs observed high-frequency hearing limits for 9 laryngeal echolocators (8 bats + the bottlenose dolphin) and 3 non-echolocating fruit bats, with the excess in octaves. Only the *Desmodus rotundus* row is new data; the rest is compiled.

## Snapshot and extraction method
`Heffner_etal_2013_Table1_snapshot.csv` (transcribed 2026-10-27 from the born-digital PDF table) keeps the caption, column headers, group headers, bold group means, footnote marks and the footnote block in printed order. Re-checked value by value against a 220-dpi render on 2026-10-30: all 12 x 3 values and the 2 means match. One transcription correction made then: footnote l read 'log interaural distance in ms'; the print reads **µs** (text-layer artefact), fixed in the snapshot.

## Build
`Heffner_etal_2013_Table1.R` keeps only species rows (12), attaches the group header, keeps the printed common name, footnote mark and binomial (`species_as_published`), harmonises via `_keys/General/species_key.csv` (rows `source_publication = Heffner_etal_2013`; stops if none), parses the footnote text into `source_ref_keys` and flags rows primary (footnote d, 'Current report') or secondary.

Run clean 2026-10-30 with `LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 Rscript --vanilla Heffner_etal_2013/Heffner_etal_2013_Table1.R` (R 4.5.3, conda env `evom1-r`) from the repo root. Reader: an AI assistant (Claude) for A. de Sousa, 2026-10-30.

## Checks
Table checks (in the script, fatal): excess = log2(observed/predicted) for 12/12 rows within 0.002 octave; the two printed group means (0.700, −0.029) reproduce from the rows. Every `source_ref_keys` key exists in the references table.

## Secondary data / sources
Secondary: 11 of 12 rows cite another paper for the observed limit. `reference_tables/Heffner_etal_2013_Table1_references.csv` has one row per cited work (`ref_key` = author-year as printed in the footnote; `cited_in_column` names the footnote), with the bibliography entry (pp. 49-50; en dashes restored where the text layer encodes them as 'e'). Footnote l (column header) is the regression equation and cites nothing. Join: split `source_ref_keys` on '; ' and join on `ref_key`. These rows are a roadmap to primary ingestion (Dalland 1965; Koay et al. 1997, 1998, 2002, 2003; Long & Schnitzler 1975; Wenstrup 1984; Johnson 1967; Ljungblad et al. 1982; Heffner et al. 2003, 2006), not new data. Older companion files `_Table1_references_full.csv` and `_Table1_bibliography.csv` (2026-10-27) are kept unchanged.

## Data role
both: Desmodus rotundus row primary (footnote d 'Current report'); 11 rows secondary.

## Observation level
Species (one row per species).

## Units
kHz (limits), octaves (excess).

## Flags (kept as printed)
- Common Vampire Bat observed limit printed as 112.9 kHz here; the Abstract/Results give 113 kHz (rounding, same value).
- Dog-faced Fruit Bat is printed *Cynopterus brachyotis* (the 2014 alpaca paper spells it *brachiotis*).

## Files
| file | role |
|---|---|
| `Heffner_etal_2013_Table1_snapshot.csv` | constructed/frozen snapshot (read as text, never edited) |
| `Heffner_etal_2013_Table1.R` | snapshot -> analysis CSV + public TSV |
| `Heffner_etal_2013_Table1.csv` | analysis CSV |
| `reference_tables/Heffner_etal_2013_Table1_definitions.csv` | data dictionary |
| `reference_tables/Heffner_etal_2013_Table1_references.csv` | cited sources, join on ref_key |
| `Heffner_etal_2013_Table1_registry_row.xlsx` | registry row proposal (live 34-col Sheet1 header) |
| `__Public/comparative-data/10.1016%2Fj.heares.2012.09.011_Table1.tsv` | public TSV (repo-level) |

Human visual check of the snapshot: pending (record `DDMMYYYY_initials` in `__ReadMe.xlsx` column AH).
