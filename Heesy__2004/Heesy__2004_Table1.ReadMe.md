# Heesy (2004), Table 1

## Source
Heesy, C. P. (2004). On the relationship between orbit orientation and binocular visual field overlap in mammals. *The Anatomical Record Part A, 281A*, 1104-1110. https://doi.org/10.1002/ar.a.20116

## Item
Table 1: Orbit convergence and binocular visual field overlap.

## Data and provenance
- 27 mammalian taxa.
- Orbit-convergence observations are primary morphometric data reported by Heesy.
- Binocular visual-field values are secondary values assembled from the references printed in Table 1.
- Scientific names, common names, values, ranges, and citations are retained as printed.
- No taxonomic harmonisation has been applied.
- Printed visual-field ranges are represented as minimum and maximum values; the midpoint is an explicitly derived convenience field.
- Blank orbit-convergence SD values mean that no parenthetical SD was printed in Table 1.
- Visual-field citations resolve against `reference_tables/Heesy__2004_Table1_references.csv` (22/23; Table 1 cites Dunlop et al. (1998) but LITERATURE CITED prints only Dunlop et al. 1997 — kept as printed, flagged in that file's `note`).

## Files
- `Heesy__2004_Table1_snapshot.xlsx`: faithful table snapshot transcribed from the PDF.
- `Heesy__2004_Table1.R`: reproducible snapshot-to-CSV build script.
- `Heesy__2004_Table1.csv`: analysis-ready table.
- `reference_tables/Heesy__2004_Table1_definitions.csv`: field definitions and provenance.
- `reference_tables/Heesy__2004_Table1_references.csv`: item-scoped source lookup for `binocular_visual_field_reference` — one row per cited work (`ref_key`, `cited_in_column`, verbatim `citation`, `note`); binds to the analysis CSV by splitting multi-citations on `"; "` and joining on `ref_key`. A roadmap for primary ingestion (extracted 2026-09-02).
- `Heesy__2004_Table1_registry_row.xlsx`: paste-ready Sheet1 row for `__ReadMe.xlsx` (see its HOW_TO_PASTE sheet).
- Public TSV: moved to the repository-level `__Public/comparative-data/10.1002%2Far.a.20116_Table1.tsv` (2026-09-02). No comparison folder: founder item, and comparisons belong in the restricted repo (`REPO_BOUNDARY.md` §3).

## Review flag
The snapshot was transcribed from the printed table and should receive a second visual review against the PDF before registry status is set to Finished. The paper prints `Equus caballos`; it is preserved verbatim rather than silently corrected.
