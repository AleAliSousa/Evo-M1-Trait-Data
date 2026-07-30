# Lyamin et al. (2008) — Table 1

**Source paper.** Lyamin, O. I., Manger, P. R., Ridgway, S. H., Mukhametov, L. M., & Siegel, J. M. (2008). Cetacean sleep: an unusual form of mammalian sleep. *Neuroscience & Biobehavioral Reviews*, 32(8), 1451–1484.

**Table.** Table 1: comparative sleep parameters across cetacean species.

## Files in this folder

| file | what it is |
| --- | --- |
| `Lyamin_etal_2008_Table1_snapshot.csv` | frozen, faithful copy of Table 1 as printed |
| `Lyamin_etal_2008_Table1.csv` | cleaned, analysis-ready data |
| `Lyamin_etal_2008_Table1.R` | script that turns the snapshot into the clean CSV |
| `Lyamin_etal_2008_Table1.ReadMe.md` | this file |

## Snapshot

**Method.** Manual entry from the printed table in the *Neurosci Biobehav Rev* PDF. Preserve values, units and reference markers exactly as printed.

**Columns kept, as in the paper.** Species / Common name / Body mass (kg) / Brain mass (g) / Total sleep time (h/day) / Unihemispheric SWS (%) / Bilateral SWS (%) / REM sleep (%) / Method / Reference.

## Why this table for the database

Extends Siegel (2022)'s discussion of cetacean sleep with concrete per-species numbers. Cetacean sleep is the paradigmatic case for Siegel's "REM is thermoregulatory" argument, because unihemispheric SWS in cetaceans may not cool the brainstem — Siegel's proposed reason cetaceans do not need REM warming. Data are also relevant to Rattenborg's frigatebird story (extension of unihemispheric sleep to marine mammals) and to the consciousness threads from Week 12 (what is the "unconscious" hemisphere doing).

## Cleaning applied (in `.R`)

- Column names → snake_case.
- Numeric columns coerced to numeric (strip units and thin-space thousands separators).
- Common name lowercased.
- Method and Reference kept as character strings.

## Notes

- Some cetacean species show no measurable REM sleep. Preserve zeros/`NA` as printed; do not conflate.
- Species names may need updating for NCBI taxonomic consistency at the repo level.
- Table 1 may span multiple printed pages; confirm all species rows have been captured.
