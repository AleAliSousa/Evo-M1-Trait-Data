# Dooley_etal_2012_ResultsText

## Source → Snapshot

**Results text: maximum observed visual acuity of Monodelphis domestica**

Publication PDF: `Dooley-2012-Visual acuity in the short-tailed.pdf`. Identifier from the read-only registry: `10.1016%2Fj.neuroscience.2012.07.065_ResultsText`.

Existing constructed snapshot retained byte-for-byte; checked against PDF text.

## Data readable → Online database

Build `Dooley_etal_2012_ResultsText.R` is self-locating and reads `Dooley_etal_2012_ResultsText_snapshot.csv`; it does not embed or regenerate source values. Item name comes from the script filename; encoded public stem is resolved from `__ReadMe.xlsx`, Sheet1, by Item name. The registry workbook is not edited.

Outputs: `Dooley_etal_2012_ResultsText.csv` (1 rows × 18 columns) and `__Public/comparative-data/10.1016%2Fj.neuroscience.2012.07.065_ResultsText.tsv`. Definitions: `reference_tables/Dooley_etal_2012_ResultsText_definitions.csv` (fixed 10-column schema). Publication context not part of the printed table lives in item-scoped `reference_tables/*_context.csv`, where present. Printed species names are retained; species harmonisation is deferred to collection-scoped keys and not hardcoded.

Mean maximum acuity 0.585 cpd, SEM 0.019, individual maxima 0.55–0.65 cpd; 6 animals, 3 males and 3 females, 84–109 g. OPT staircase, video-corrected eye-to-stimulus viewing distance. Results p.4 exact endpoint rather than Discussion rounded 0.58. Table1 is stimulus methodology, not an acuity item.

Data role: **primary**. Method: optokinetic head tracking; staircase; video-corrected viewing distance. Measure: Acuity.cpd.

## QA and current status

Independent Python rebuild/check passed; R execution pending. This is not FINISHED.

Independent Python rebuild from frozen CSV passed row/column preservation, numeric-source parsing, analysis CSV/public TSV agreement, 10-column definitions, full output-column coverage and item-scoped reference-key joins where applicable. Numeric QA reports and working publication renderings stay in session scratch, never in a public comparison folder. There is no pre-existing TSV for this item in the supplied public inventory, so no cross-source comparison was invented. Exact source verification applies to text, Table1 and Figure3C labels; Figures3A/B remain approximate digitizations with the limitations above.

Rscript is not installed in this environment; repository audit → dry-run → build → validate and clean-session R/Python agreement have **not** been executed. These are outstanding, not implied by the Python check. No registry workbook, collection key or merge was edited; proposed descriptive registry updates and species-key rows are supplied separately to the owner. Secondary rows must not enter a primary-data merge.
