# Lyamin et al. (2008) — Table 2

**Source paper.** Lyamin, O. I., Manger, P. R., Ridgway, S. H., Mukhametov, L. M., & Siegel, J. M. (2008). Cetacean sleep: an unusual form of mammalian sleep. *Neuroscience & Biobehavioral Reviews*, 32(8), 1451–1484.

**Table.** Table 2 ("Characteristic of sleep in Cetaceans", p. 1455): quantitative sleep parameters across four cetacean species.

Note: this folder uses Table 2 (the quantitative sleep parameters table), not Table 1 (which is a table of muscle-jerk counts in cetaceans and is less database-useful). If both are wanted, a separate `Lyamin_etal_2008_Table1` folder can be added.

## Files in this folder

| file | what it is |
| --- | --- |
| `Lyamin_etal_2008_Table2_snapshot.csv` | frozen, faithful copy of Table 2 as printed (see reorientation note below) |
| `Lyamin_etal_2008_Table2.csv` | cleaned, analysis-ready data |
| `Lyamin_etal_2008_Table2.R` | script that turns the snapshot into the clean CSV |
| `Lyamin_etal_2008_Table2.ReadMe.md` | this file |

## Snapshot

**Method.** Manual entry from the printed Table 2 on p. 1455 of the paper.

**Reorientation.** In the printed paper, Table 2 places species as **columns** and parameters as **rows** — sensible for a four-species comparison in a review article, but not machine-friendly. For the database, the snapshot has been reoriented to species-as-rows with parameters-as-columns. All values, units and species assignments are preserved exactly; only the axis of the table has been transposed.

**Columns kept, one per printed row of Table 2.**

- Species (Latin binomial)
- Common name
- Number of animals
- Sex
- Age
- Total SWS (% of 24-h)
- SWS left hemisphere (% of 24-h)
- SWS right hemisphere (% of 24-h)
- Low amplitude USWS (% of TST)
- High amplitude USWS (% of TST)
- Asymmetrical SWS (% of TST)
- Low amplitude bilateral SWS (% of TST)
- High amplitude bilateral SWS (% of TST)
- Reference (from the footnote of each column of the printed table)

## Why this table for the database

Direct empirical anchor for Siegel (2022)'s discussion of cetacean sleep. Cetaceans are the paradigmatic case for Siegel's "REM sleep is thermoregulatory" argument, since they have essentially no REM but sleep continuously via unihemispheric slow waves. Table 2 is the cleanest per-species quantification of that architecture in the literature.

## Cleaning applied (in `.R`)

- Column names → snake_case.
- Common name lowercased.
- Numeric columns are already numeric; character columns (Sex, Age, Reference) preserved.

## Notes

- Total SWS in all four species is less than the sum of left- and right-hemisphere SWS because of overlap between USWS and bilateral SWS episodes; the paper flags this in its footnote *e*, which is preserved in the ReadMe.
- No REM sleep column: the paper argues cetaceans have essentially no REM sleep in the classical form (see main text §3.2). This absence is itself the point.
- Species names may need updating for NCBI taxonomic consistency at the repo level.
