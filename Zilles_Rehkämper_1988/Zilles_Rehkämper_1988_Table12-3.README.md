## Zilles_Rehkämper_1988_Table12-3

### Source

PDF: `zilles_rehkamper_1988.pdf` (in this folder). Chapter: Zilles, K., & Rehkämper, G. (1988), *The brain, with special reference to the telencephalon*, in J. H. Schwartz (Ed.), **Orang-Utan Biology** (pp. 157–176), Oxford University Press. ISBN 9780195043716.

**Table 12-3, “Indices of Brain Structure Size in Pongo and Other Hominoidea,”** is printed on page 172. It reports progression indices for 12 brain structures across Pongo, Gorilla, Pan, Hylobates, and Homo, together with the slope and y-intercept used for each structure.

### Files

- `zilles_rehkamper_1988.pdf`: publication.
- `zilles_rehkamper_1988.xlsx`: raw whole-chapter PDF-to-Excel export retained for provenance.
- `Zilles_Rehkämper_1988_Table12-3_snapshot.xlsx`: journal-faithful transcription of Table 12-3, including caption, header, 12 structure rows, and footnote.
- `Zilles_Rehkämper_1988_Table12-3.R`: preparation script. Reads only the snapshot.
- `Zilles_Rehkämper_1988_Table12-3.csv`: long-format analysis-ready output created by the R script.

### Snapshot layout

Sheet `Table12-3` contains the caption in row 1, the eight printed columns in row 2, the 12 structure rows in rows 3–14, and the printed methodological footnote in row 15. The table orientation is retained: structures are rows and genera are columns.

### Preparation

The R script removes the footnote row, parses the printed numeric values, and pivots the five genus columns to long format. The output contains 60 rows, one for each structure-by-genus combination, with columns:

- `Genus`
- `structure`
- `slope`
- `y_intercept`
- `progression_index`

The slope and y-intercept are repeated across genera because they define the structure-specific reference regression used for each reported index.

### Interpretation and provenance caution

These are **derived progression indices**, not measured brain volumes. The table footnote states that indices are based on a regression line through corresponding Tenrecinae data; slopes and y-intercepts are from Stephan et al. (1987a), and data for genera other than Pongo are from Stephan et al. (1981). The chapter states that the Pongo indices were calculated from the Pongo measurements and literature-based species means described in the surrounding text.

Table 12-3 should therefore remain separate from the primary fresh-volume extraction in Table 12-2. It is useful as a faithful record of the published derived results, but downstream analyses can recompute indices from documented source values when reproducibility requires it.
