# BallesterosYáñez_etal_2006_Figure3C

## Source → Snapshot

**Figure 3C. Total number of spines estimated by 3-D and 2-D analysis**

Publication PDF: `Ballesteros-Yan-2006-Density and morphology of.pdf`. Identifier from the read-only registry: `10.1016%2Fj.neuroscience.2005.11.038_Figure3C`.

Existing constructed CSV retained byte-for-byte. All six numeric labels independently matched against rendered Figure3C and Results on PDF p.4. This is label transcription, not bar-height digitization. Printed labels are counts despite the ×1000 axis.

## Data readable → Online database

Build `BallesterosYáñez_etal_2006_Figure3C.R` is self-locating and reads `BallesterosYáñez_etal_2006_Figure3C_snapshot.csv`; it does not embed or regenerate source values. Item name comes from the script filename; encoded public stem is resolved from `__ReadMe.xlsx`, Sheet1, by Item name. The registry workbook is not edited.

Outputs: `BallesterosYáñez_etal_2006_Figure3C.csv` (6 rows × 11 columns) and `__Public/comparative-data/10.1016%2Fj.neuroscience.2005.11.038_Figure3C.tsv`. Definitions: `reference_tables/BallesterosYáñez_etal_2006_Figure3C_definitions.csv` (fixed 10-column schema). Publication context not part of the printed table lives in item-scoped `reference_tables/*_context.csv`, where present. Printed species names are retained; species harmonisation is deferred to collection-scoped keys and not hardcoded.

Six exact printed labels, three regions × two dimensions; primary study-derived estimates of an average basal tree, not directly counted whole neurons. Labels already give total counts; only axis is scaled ×1000. Do not multiply labels again or pool the alternative 2-D/3-D estimates.

Data role: **primary**. Method: density profile multiplied by corresponding Sholl branch counts. Measure: Count.spines.

## QA and current status

Independent Python rebuild/check passed; R execution pending. This is not FINISHED.

Independent Python rebuild from frozen CSV passed row/column preservation, numeric-source parsing, analysis CSV/public TSV agreement, 10-column definitions, full output-column coverage and item-scoped reference-key joins where applicable. Numeric QA reports and working publication renderings stay in session scratch, never in a public comparison folder. There is no pre-existing TSV for this item in the supplied public inventory, so no cross-source comparison was invented. Exact source verification applies to text, Table1 and Figure3C labels; Figures3A/B remain approximate digitizations with the limitations above.

Rscript is not installed in this environment; repository audit → dry-run → build → validate and clean-session R/Python agreement have **not** been executed. These are outstanding, not implied by the Python check. No registry workbook, collection key or merge was edited; proposed descriptive registry updates and species-key rows are supplied separately to the owner. Secondary rows must not enter a primary-data merge.
