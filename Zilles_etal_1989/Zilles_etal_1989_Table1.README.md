# Zilles_etal_1989_Table1

## Status — built in AddON registry on 2026-11-23

Frozen source, R reader, analysis CSV, definitions, AddON registry row and canonical registry-named public TSV are present. The main registry remains occupied; human visual signoff and merge review remain pending.

## Source → snapshot

Zilles, K., Armstrong, E., Moser, K. H., Schleicher, A., & Stephan, H. (1989). Gyrification in the Cerebral Cortex of Primates. Brain, Behavior and Evolution, 34(3), 143–150. https://doi.org/10.1159/000116500

Locus: **Table1 p.144 (PDF page2), with rightmost GIL confirmed in facing-page margin p.145 (PDF page3)**. Source PDF already exists in this publication folder and is unchanged. The snapshot retains caption, published headers, original units, ordered rows, printed mean ± SD / footnote keys, and meaningful blanks. Two-panel Table1 for Zilles keeps both panels; row grouping remains in the frozen source. Reader: **AI assistant GitHub Copilot on 2026-10-10; manual printed-layout transcription into the frozen CSV after pdftoppm visual reading, checked against the rendered source cells; OCR was used only as a locator, not as numerical authority.**

## Snapshot → data readable

Run `Zilles_etal_1989_Table1.R` in a clean R session. It reads `Zilles_etal_1989_Table1_snapshot.csv`, writes `Zilles_etal_1989_Table1.csv`, and looks up Item encoded by exact Item name in a fresh Sheet1 read of the main registry or `__ReadMeAddON.xlsx`. It writes the canonical public TSV under repo-level `__Public/comparative-data/`. Public TSV naming is registry-derived.

Method: Serial20-μm histological sections; cresyl violet; approximately40 equidistant sections/brain; digitized contours; GI=sum complete contours/sum outer contours.

Units: Body g; brain mg (source g×1000); neopallium mm3 (source cm3×1000); dimensionless right/left GI.

Provenance and limitations: Table1 p.144;56 nonhuman rows, not species means. Size metrics mostly secondary[20]; GI primary. Facing p.145 margin resolves GIL. No human row borrowed from narrative.

Observation level: see `Method:observation_level` in `reference_tables/Zilles_etal_1989_Table1_definitions.csv`. Biological sample size is distinct from numbers of medullas, traced neurons or measurements. Scientific/common names as published are retained; owner-reviewed collection-scoped mappings are still required.

Data role: **both**. Row/measure role columns gate secondary data. Per-source citations, when reused values occur, are item-scoped in `reference_tables/Zilles_etal_1989_Table1_references.csv`; join using the preserved key (not a complete bibliography).

## QA and online database

Visually read and checked against source PDF on 2026-10-10. No preexisting curated comparison was supplied, so no claim of an independent 0-mismatch audit is made and no public comparison folder is created. Expected analysis rows: **56**. Definitions have the fixed10-column schema. AddON registry encoded stem: `10.1159%2F000116500_Table1`. The canonical public TSV is now in `__Public/comparative-data/`.

Pending: transfer the AddON row to the main registry when available; collection-scoped species mapping and specimen/source overlap review before merge. Secondary rows/columns must not enter primary merges. No merge script was changed. This is a table item, so no figure replot applies.

### Execution evidence (2026-11-23)

`Rscript --vanilla Zilles_etal_1989_Table1.README.R` ran from repository root and wrote 56 analysis rows plus a public TSV using the AddON registry code. The R reader retained source row/measure roles and unit conversions. The frozen snapshot had a prior source-side AI visual check on 2026-10-10; human visual signoff remains pending.
