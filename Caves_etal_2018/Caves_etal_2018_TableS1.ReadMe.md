# Caves et al. (2018) — Table S1

**Source paper.** Caves, E. M., Brandley, N. C., & Johnsen, S. (2018). Visual acuity and the evolution of signals. *Trends in Ecology & Evolution*, 33(5), 358–372.

**Table.** Supplementary Table S1: *"Acuity and eye size across species from Figure I (Box 1) in order of decreasing acuity from highest to lowest."*

## Files in this folder

| file | what it is |
| --- | --- |
| `Caves_etal_2018_TableS1_snapshot.csv` | frozen, faithful copy of Table S1 as printed |
| `Caves_etal_2018_TableS1.csv` | cleaned, analysis-ready data ("use this") |
| `Caves_etal_2018_TableS1.R` | script that turns the snapshot into the clean CSV |
| `Caves_etal_2018_TableS1.ReadMe.md` | this file |

## Pipeline

`Source → Snapshot → Data readable → (Species notes) → Online database`

## Snapshot

**Method.** Manual entry from the supplementary raw-data Word document supplied by the authors (`Caves (2018) raw data (entire).docx`). The Word file embeds Mendeley `ADDIN CSL_CITATION` blocks in every cell of the citation column; these were stripped so only the final formatted reference codes (e.g. `[1,2]`) remain. All other content preserved as printed.

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
- The four "Method" values used are: `Behavior`, `Peak RGC`, `VEP`, `Interommatidial angle`, `Acceptance angle`. `Peak RGC` = peak retinal ganglion cell density. `VEP` = visually evoked potential.
- Citation ranges printed with an en-dash (e.g. `[30–32]`) are preserved verbatim in the snapshot; if downstream code needs to enumerate the individual references, expand these in the analysis script.
- Some species names may need updating for NCBI taxonomic consistency (e.g. `Parus carolinensis` is now `Poecile carolinensis`). Species-name standardisation is deferred to a repo-level step, not this table.

## To do before final submission

- Add a row for this table to `__ReadMe.xlsx` (`Item name = Caves_etal_2018_TableS1`; `Item encoded = <DOI-encoded code>`) so the R script can write the public TSV.
