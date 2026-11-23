# Dunbar__1992_Table1

Dunbar RIM (1992). *Neocortex size as a constraint on group size in primates.* Journal of Human Evolution 22:469-493.

## Source -> snapshot

`Dunbar__1992_Table1_snapshot.csv` is a transcription of Table 1, "Data for main variables (generic means)," printed across journal pages 474-475. Dashes are represented as blank cells and read as `NA` by the build script.

The methods text says that 38 genera were used. In the supplied copy, 37 table rows could be read and transcribed. The paper later states that orang-utan data were unavailable for neocortex size, so no `Pongo` row was invented.

## Definitions

- `N`: neocortex volume, mm3.
- `H`: hindbrain volume, defined by the footnote as medulla + cerebellum + mesencephalon + diencephalon.
- `Total`: total brain volume, mm3.
- `C_R`: neocortex ratio = neocortex volume / (total brain volume - neocortex volume).
- `N_C`: Jerison's (1973) extra cortical neurons index.
- Group-size and ecological columns are generic means as printed.

Brain volumes and body weights are attributed in the table notes to Stephan et al. (1981) and Harvey et al. (1986), respectively. Other behavioral/ecological sources are retained in the paper's table footnotes and methods.

## Build

The R script checks for 37 unique genus rows, converts measurement fields to numeric, appends the source identifier, writes the local CSV, and writes the encoded public TSV via `__ReadMe.xlsx`.
