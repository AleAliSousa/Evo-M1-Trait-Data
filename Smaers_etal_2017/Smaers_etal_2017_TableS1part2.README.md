# Smaers_etal_2017_TableS1part2

## Source

PDF: `Smaers-2017-Exceptional Evolutio.pdf`; supplement `mmc1.pdf` (publisher Excel
`Smaers_mmc1.xlsx`, sheet "Table 1"; also the standalone file `cortical surfaces Brodmann 1909 in
Smears et al 2017.xlsx`). Paper: Smaers, J. B., Gómez-Robles, A., Parks, A. N., & Sherwood, C. C.
(2017). *Exceptional Evolutionary Expansion of Prefrontal Cortex in Great Apes and Humans.* Curr
Biol 27(5), 714–720. https://doi.org/10.1016/j.cub.2017.01.020

This is **part 2 of 2** of supplemental **Table S1** — the **"Brodmann data" surface-area block**:
4 cortical regions (primary visual, prefrontal, other cortical association areas, frontal motor),
**surface area in mm²**, 10 primate species. (Part 1 = the Smaers volume block; see
`Smaers_etal_2017_TableS1part1.README.md`.)

## Files

| Path | Role |
|---|---|
| `Smaers_etal_2017_TableS1part2_pdf_transcription.csv` | Direct transcription of the Brodmann surface-area block in `mmc1.pdf`, PDF page 4. All 37 populated values were checked against that page. |
| `Smaers_etal_2017_TableS1part2_snapshot.xlsx` | Older publisher-spreadsheet snapshot, retained for history; not a build input. |
| `Smaers_etal_2017_TableS1part2.R` | Reformat → `Smaers_etal_2017_TableS1part2.csv` (+ DOI-named TSV). Reads only the PDF transcription. |
| `reference_tables/Smaers_etal_2017_TableS1part2_definitions.csv` | Data dictionary (10-col schema; `Measure = surface area`). |
| `comparison/Brodmann_surface_1909.csv` | Independent formatted surface-area table (from `cortical surfaces Brodmann 1909 in Smears et al 2017.xlsx`), audited only. |
| `comparison/Smaers_etal_2017_TableS1part2_compare_to_Brodmann_csv.R` | QA: snapshot vs `Brodmann_surface_1909.csv`. |
| `__Public/comparative-data/10.1016%2Fj.cub.2017.01.020_TableS1part2surfacearea.tsv` | Shared public copy. |

## Provenance

Surface areas are from **Brodmann (1909) [S3]** (granular/agranular cytoarchitectonic criteria),
reproduced in Smaers 2017 Table S1. Only **9 of 10** species carry all four regions; *Saimiri
sciureus* has primary visual only (printed blank elsewhere — kept blank).

## Reformat → CSV

The R reads the PDF transcription, underscores
the species name, adds `source = "Smaers_etal_2017"`, and writes the CSV plus a DOI-named TSV. (R is
not in the build sandbox; the committed CSV/TSV were produced by a Python mirror of this exact logic
and will be regenerated when you run the R.)

Output columns: `species, primary_visual_surface, prefrontal_surface, other_association_surface,
frontal_motor_surface, source`.

## Checking → `comparison/`

The earlier snapshot (built from `Smaers_mmc1.xlsx`) matched by species to `Brodmann_surface_1909.csv` (built
from the *independent* publisher file `cortical surfaces Brodmann 1909 in Smears et al 2017.xlsx`).
A clean match across the two independent digitisations confirms the transcription. **Verified: 10
matched, 0 value mismatches, no snapshot-only / csv-only species.**
