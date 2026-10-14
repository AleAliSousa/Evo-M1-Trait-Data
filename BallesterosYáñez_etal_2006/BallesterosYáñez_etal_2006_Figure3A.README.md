# BallesterosYáñez_etal_2006_Figure3A

## Source → Snapshot

**Figure 3A. Sholl analysis of basal dendritic trees in 2-D and 3-D**

Publication PDF: `Ballesteros-Yan-2006-Density and morphology of.pdf`. Identifier from the read-only registry: `10.1016%2Fj.neuroscience.2005.11.038_Figure3A`.

Pre-existing constructed digitized CSV retained byte-for-byte. Original digitizer and click/calibration record were not supplied; do not claim exact source numbers. Checked visually against PDF p.4, Figure3A on 2026-10-10: linear axes, distance ticks 25–150 µm, ordinate 0–30 intersections, marker/legend correspondence (open=3-D, filled=2-D). Point estimates are approximate, nominal visual tolerance 1 intersection; no unreported SEM digitized.

## Data readable → Online database

Build `BallesterosYáñez_etal_2006_Figure3A.R` is self-locating and reads `BallesterosYáñez_etal_2006_Figure3A_snapshot.csv`; it does not embed or regenerate source values. Item name comes from the script filename; encoded public stem is resolved from `__ReadMe.xlsx`, Sheet1, by Item name. The registry workbook is not edited.

Outputs: `BallesterosYáñez_etal_2006_Figure3A.csv` (36 rows × 13 columns) and `__Public/comparative-data/10.1016%2Fj.neuroscience.2005.11.038_Figure3A.tsv`. Definitions: `reference_tables/BallesterosYáñez_etal_2006_Figure3A_definitions.csv` (fixed 10-column schema). Publication context not part of the printed table lives in item-scoped `reference_tables/*_context.csv`, where present. Printed species names are retained; species harmonisation is deferred to collection-scoped keys and not hardcoded.

36 approximate plotted mean intersections, six distances × three regions × two methods; not raw author-supplied numeric values. Existing digitizer/calibration not recorded; source visually checked on 2026-10-10. 2-D/3-D are alternative analyses of the same cells, not independent datasets.

Data role: **primary**. Method: 2-D concentric-circle Sholl and 3-D Neurolucida spheres, 25 µm steps. Measure: Count.intersections.

## QA and current status

Independent Python rebuild/check passed; R execution pending. This is not FINISHED.

Independent Python rebuild from frozen CSV passed row/column preservation, numeric-source parsing, analysis CSV/public TSV agreement, 10-column definitions, full output-column coverage and item-scoped reference-key joins where applicable. Numeric QA reports and working publication renderings stay in session scratch, never in a public comparison folder. There is no pre-existing TSV for this item in the supplied public inventory, so no cross-source comparison was invented. Exact source verification applies to text, Table1 and Figure3C labels; Figures3A/B remain approximate digitizations with the limitations above.

Rscript is not installed in this environment; repository audit → dry-run → build → validate and clean-session R/Python agreement have **not** been executed. These are outstanding, not implied by the Python check. No registry workbook, collection key or merge was edited; proposed descriptive registry updates and species-key rows are supplied separately to the owner. Secondary rows must not enter a primary-data merge.
