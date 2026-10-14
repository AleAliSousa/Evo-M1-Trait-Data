# BallesterosYáñez_etal_2006_Figure3B

## Source → Snapshot

**Figure 3B. Spine density along basal dendrites**

Publication PDF: `Ballesteros-Yan-2006-Density and morphology of.pdf`. Identifier from the read-only registry: `10.1016%2Fj.neuroscience.2005.11.038_Figure3B`.

Pre-existing constructed digitized CSV checked against PDF p.4, Figure3B on 2026-10-10. Existing estimates retained; original digitizer/calibration is unknown. Corrected two demonstrable omissions/errors before building: V2L/TeA false zero at 150 µm removed (series ends at 140 µm); M2 point at 170 µm added as 11.8 spines per 10 µm. New point was independently clicked from pdftoppm render (1650×2200), crop x490:y735:x1190:y1040 enlarged 2×; linear calibration y=557 at 0, y=16 at 25; M2 marker y=301 gives (557−301)×25/(557−16), rounded to one decimal. Nominal visual tolerance 1 spine per 10 µm. Original snapshot hash b9f287be449ffdfe652fb50fcf5278177f5d5950712eda5e5c455a4badea873a and correction record are kept in session audit evidence; no comparison/check folder published.

## Data readable → Online database

Build `BallesterosYáñez_etal_2006_Figure3B.R` is self-locating and reads `BallesterosYáñez_etal_2006_Figure3B_snapshot.csv`; it does not embed or regenerate source values. Item name comes from the script filename; encoded public stem is resolved from `__ReadMe.xlsx`, Sheet1, by Item name. The registry workbook is not edited.

Outputs: `BallesterosYáñez_etal_2006_Figure3B.csv` (48 rows × 13 columns) and `__Public/comparative-data/10.1016%2Fj.neuroscience.2005.11.038_Figure3B.tsv`. Definitions: `reference_tables/BallesterosYáñez_etal_2006_Figure3B_definitions.csv` (fixed 10-column schema). Publication context not part of the printed table lives in item-scoped `reference_tables/*_context.csv`, where present. Printed species names are retained; species harmonisation is deferred to collection-scoped keys and not hardcoded.

48 approximate plotted points; density is number per 10 µm, not per µm. PDF Figure3B verified: V2L/TeA terminates at 140 µm, so erroneous snapshot 0 at 150 µm replaced with blank; omitted M2 marker at 170 µm added by linear pixel calibration (11.8 per 10 µm). Blank/unplotted values are not zeros. Prior digitizer not recorded; existing other estimates retained as approximate.

Data role: **primary**. Method: high-power basal dendrite reconstruction; spines per 10 µm; no correction factor. Measure: Density.spines_per_10um.

## QA and current status

Independent Python rebuild/check passed; R execution pending. This is not FINISHED.

Independent Python rebuild from frozen CSV passed row/column preservation, numeric-source parsing, analysis CSV/public TSV agreement, 10-column definitions, full output-column coverage and item-scoped reference-key joins where applicable. Numeric QA reports and working publication renderings stay in session scratch, never in a public comparison folder. There is no pre-existing TSV for this item in the supplied public inventory, so no cross-source comparison was invented. Exact source verification applies to text, Table1 and Figure3C labels; Figures3A/B remain approximate digitizations with the limitations above.

Rscript is not installed in this environment; repository audit → dry-run → build → validate and clean-session R/Python agreement have **not** been executed. These are outstanding, not implied by the Python check. No registry workbook, collection key or merge was edited; proposed descriptive registry updates and species-key rows are supplied separately to the owner. Secondary rows must not enter a primary-data merge.
