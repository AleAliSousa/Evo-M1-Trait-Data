# Dooley_etal_2012_DiscussionText

## Source → Snapshot

**Discussion text: literature acuity comparisons in marsupials and rodents**

Publication PDF: `Dooley-2012-Visual acuity in the short-tailed.pdf`. Identifier from the read-only registry: `10.1016%2Fj.neuroscience.2012.07.065_DiscussionText`.

New constructed prose capture extracted from actual PDF Discussion pp.4–5 by Python regular-expression captures on 2026-10-10; publication prose order, printed values, common/species names, units, methods, citation keys and activity retained. No Figure5 values used. Primary present-study opossum result excluded to avoid duplicating ResultsText. Bibliography entries transcribed only for the six cited works, PDF pp.6–7.

## Data readable → Online database

Build `Dooley_etal_2012_DiscussionText.R` is self-locating and reads `Dooley_etal_2012_DiscussionText_snapshot.csv`; it does not embed or regenerate source values. Item name comes from the script filename; encoded public stem is resolved from `__ReadMe.xlsx`, Sheet1, by Item name. The registry workbook is not edited.

Outputs: `Dooley_etal_2012_DiscussionText.csv` (8 rows × 8 columns) and `__Public/comparative-data/10.1016%2Fj.neuroscience.2012.07.065_DiscussionText.tsv`. Definitions: `reference_tables/Dooley_etal_2012_DiscussionText_definitions.csv` (fixed 10-column schema). Publication context not part of the printed table lives in item-scoped `reference_tables/*_context.csv`, where present. Printed species names are retained; species harmonisation is deferred to collection-scoped keys and not hardcoded.

Eight cited acuity values across seven printed taxa/common names, method recorded per value. Didelphis retains separate retinal ganglion-density and cortical-potential estimates. Printed common names are not silently replaced by binomials. Only six cited works in item-scoped bibliography; prose Picaco-Diniz versus bibliography Picanço-Diniz retained and documented. Rounded present-study opossum value excluded as duplicate of ResultsText.

Data role: **secondary**. Method: literature compilation: two-choice discrimination, Mitchell jumping task, RGC density, cortical potentials, OPT. Measure: Acuity.cpd.

## QA and current status

Independent Python rebuild/check passed; R execution pending. This is not FINISHED.

Independent Python rebuild from frozen CSV passed row/column preservation, numeric-source parsing, analysis CSV/public TSV agreement, 10-column definitions, full output-column coverage and item-scoped reference-key joins where applicable. Numeric QA reports and working publication renderings stay in session scratch, never in a public comparison folder. There is no pre-existing TSV for this item in the supplied public inventory, so no cross-source comparison was invented. Exact source verification applies to text, Table1 and Figure3C labels; Figures3A/B remain approximate digitizations with the limitations above.

Rscript is not installed in this environment; repository audit → dry-run → build → validate and clean-session R/Python agreement have **not** been executed. These are outstanding, not implied by the Python check. No registry workbook, collection key or merge was edited; proposed descriptive registry updates and species-key rows are supplied separately to the owner. Secondary rows must not enter a primary-data merge.
