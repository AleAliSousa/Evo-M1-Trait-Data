# Conesa_etal_1991_Text

## Source → Snapshot

**Abstract 83: hearing in large rodents—groundhogs Marmota monax**

Publication PDF: `conesa_etal_1991.pdf`. Identifier from the read-only registry: `ARO%3A1991%3A83_Text`.

Existing constructed snapshot retained byte-for-byte; checked against PDF text.

## Data readable → Online database

Build `Conesa_etal_1991_Text.R` is self-locating and reads `Conesa_etal_1991_Text_snapshot.csv`; it does not embed or regenerate source values. Item name comes from the script filename; encoded public stem is resolved from `__ReadMe.xlsx`, Sheet1, by Item name. The registry workbook is not edited.

Outputs: `Conesa_etal_1991_Text.csv` (6 rows × 11 columns) and `__Public/comparative-data/ARO%3A1991%3A83_Text.tsv`. Definitions: `reference_tables/Conesa_etal_1991_Text_definitions.csv` (fixed 10-column schema). Publication context not part of the printed table lives in item-scoped `reference_tables/*_context.csv`, where present. Printed species names are retained; species harmonisation is deferred to collection-scoped keys and not hardcoded.

Six text-reported frequencies; four groundhogs; conditioned avoidance with water reward. Responses span 32 Hz–32 kHz; 60-dB SPL hearing range is 40 Hz–27.5 kHz; best hearing at two named frequencies, 2 and 4 kHz, not a continuous optimum range. ARO:1991:83 is a constructed local identifier, not a DOI. The scan does not print the year; 1991 remains registry attribution.

Data role: **primary**. Method: conditioned avoidance with water reward. Measure: Frequency.Hz.

## QA and current status

Independent Python rebuild/check passed; R execution pending. This is not FINISHED.

Independent Python rebuild from frozen CSV passed row/column preservation, numeric-source parsing, analysis CSV/public TSV agreement, 10-column definitions, full output-column coverage and item-scoped reference-key joins where applicable. Numeric QA reports and working publication renderings stay in session scratch, never in a public comparison folder. There is no pre-existing TSV for this item in the supplied public inventory, so no cross-source comparison was invented. Exact source verification applies to text, Table1 and Figure3C labels; Figures3A/B remain approximate digitizations with the limitations above.

Rscript is not installed in this environment; repository audit → dry-run → build → validate and clean-session R/Python agreement have **not** been executed. These are outstanding, not implied by the Python check. No registry workbook, collection key or merge was edited; proposed descriptive registry updates and species-key rows are supplied separately to the owner. Secondary rows must not enter a primary-data merge.
