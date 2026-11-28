# Caves et al. (2018) — Table S1

**Source paper.** Caves, E. M., Brandley, N. C., & Johnsen, S. (2018). Visual acuity and the evolution of signals. *Trends in Ecology & Evolution*, 33(5), 358–372.

**Table.** Supplementary Table S1: *"Acuity and eye size across species from Figure I (Box 1) in order of decreasing acuity from highest to lowest."*

## Files in this folder

| file | what it is |
| --- | --- |
| `mmc1.docx` | publisher supplement containing Tables S1–S3 |
| `Caves_etal_2018_TableS1_snapshot.csv` | Table S1 transcribed in its source row/column layout |
| `Caves_etal_2018_TableS1.csv` | cleaned, analysis-ready data ("use this") |
| `Caves_etal_2018_TableS1.R` | script that turns the snapshot into the clean CSV |
| `Caves_etal_2018_TableS1.README.md` | this file |

## Pipeline

`Source → Snapshot → Data readable → (Species notes) → Online database`

## Snapshot

**Method and source check.** The snapshot was manually entered from the authors' supplementary Word table, previously recorded as `Caves (2018) raw data (entire).docx`. The supplied `mmc1.docx` contains the same Table S1 as its first table. Its 41 rows (header plus 40 species) each have four cells, with no merged cells. All 164 snapshot cells match the displayed Word text in the same row and column after trimming ten trailing Word-cell spaces; 154 cells match exactly without trimming. Citation field codes are not part of the displayed cell text. The caption and post-table Method definition remain in the DOCX rather than in the CSV table grid. The source DOCX SHA-256 is `4345b93a8a7de225e481e15c1341329e815c38c8cf3d6125be01ba6ae55d5e16`. This assistant comparison does not mark independent human visual signoff.

**Rebuild check (2026-11-27).** `Rscript Caves_etal_2018/Caves_etal_2018_TableS1.R` completed; the analysis CSV SHA-256 remained `39af8b6e816cd004b9bc61a0b95f20c8d3129b28e5eb6599b085b190dbaadcce`. No snapshot or R-reader edit was needed.

**Columns kept, exactly as in the paper.**
- `Common Name`
- `Latin Name`
- `Citation[Acuity, eye size]` — reference numbers as printed (e.g. `[1,2]`, `[30–32]`, `[6,11,12]`)
- `Method`

**Row order.** As published — species are ordered by decreasing visual acuity (row 1 = highest acuity, row 40 = lowest). The order is meaningful; it corresponds to the ranking implicit in Figure I of Box 1.

**What was NOT included in the snapshot.**
- Numerical acuity values (cpd) and eye diameters — these are in *Figure I of Box 1* in the main paper, not in Table S1 itself.
- Interpretive notes or verification flags — those belong (if anywhere) in this ReadMe or as inline comments in the `.R` script, not baked into the snapshot.

## Cleaning applied (in `.R`)

- Column names → snake_case (`common_name`, `latin_name`, `citations`, `method`).
- Added `acuity_rank` (1 = highest acuity as published) so the meaningful row order is preserved even if downstream code re-sorts.
- Common names lowercased and parenthetical clade notes stripped (e.g. `"Dust lice (Psocoptera)"` → `"dust lice"`).
- `"Peak retinal cell density"` normalised to `"Peak RGC"` (used everywhere else for the same technique).
- Citation column kept as a character string. The Caves header states "first citation = acuity, second = eye size," but rows with one or three citations don't fit that scheme unambiguously, so no auto-split is applied here. Any split is a downstream analytical choice.

## Notes for the database

- 40 species. 33 have camera-type eyes, 6 have compound eyes, 1 (great scallop) has mirror-type eyes.
- The five "Method" values used are: `Behavior`, `Peak RGC`, `VEP`, `Interommatidial angle`, `Acceptance angle`. `Peak RGC` = peak retinal ganglion cell density. `VEP` = visually evoked potential.
- Citation ranges printed with an en-dash (e.g. `[30–32]`) are preserved verbatim in the snapshot; if downstream code needs to enumerate the individual references, expand these in the analysis script.
- Some species names may need updating for NCBI taxonomic consistency (e.g. `Parus carolinensis` is now `Poecile carolinensis`). Species-name standardisation is deferred to a repo-level step, not this table.

## Public export

The public TSV `__Public/comparative-data/10.1016%2Fj.tree.2018.03.001_TableS1.tsv`
is present (DOI-encoded name `10.1016%2Fj.tree.2018.03.001_TableS1`).

- **Maintainer follow-up:** add the matching row to `__ReadMe.xlsx` (`Item name = Caves_etal_2018_TableS1`; `Item encoded = 10.1016%2Fj.tree.2018.03.001_TableS1`) so a future re-run of `Caves_etal_2018_TableS1.R` regenerates the TSV in place instead of warning and skipping.
