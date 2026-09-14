## Zilles_Rehkämper_1988_Table12-1

### Source

PDF: `zilles_rehkamper_1988.pdf` (in this folder). Chapter: Zilles, K., & Rehkämper, G. (1988), *The brain, with special reference to the telencephalon*, in J. H. Schwartz (Ed.), **Orang-Utan Biology** (pp. 157–176), Oxford University Press. ISBN 9780195043716.

**Table 12-1, “Brain and Body Weights from Literature,”** is printed across pages 168–169. It compiles published orang-utan body weights and brain weights and identifies sex and, where printed, the origin of the datum.

### Files

- `zilles_rehkamper_1988.pdf`: publication.
- `zilles_rehkamper_1988.xlsx`: raw whole-chapter PDF-to-Excel export retained for provenance.
- `Zilles_Rehkämper_1988_Table12-1_snapshot.xlsx`: journal-faithful transcription of Table 12-1, including its continuation, blank cells, notes, and sex-code footnote.
- `Zilles_Rehkämper_1988_Table12-1.R`: preparation script. Reads only the snapshot.
- `Zilles_Rehkämper_1988_Table12-1.csv`: analysis-ready output created by the R script.

### Snapshot layout

Sheet `Table12-1` contains the caption in row 1 and the five printed columns in row 2: Author, Sex, Body Weight (g), Brain Weight (g), and Origin of the Data. Each subsequent row represents a printed observation. Blank body-weight, brain-weight, and origin cells are retained as blank, rather than inferred. The final row preserves the printed definitions `M = male; F = female; j = juvenile.`

Repeated blank Author cells preserve the visual grouping used in the publication. The R script fills those cells downward so that each output record retains the associated literature source.

### Preparation

The script:

1. skips the caption row;
2. removes the final sex-code footnote;
3. fills grouped author labels downward;
4. parses body and brain weights as numeric grams;
5. retains missing printed values as `NA`; and
6. writes one row per usable printed observation for `Pongo sp.`

No mean is calculated from the table by this script. The chapter text separately states that the compiled sources yield a mean body weight of **54,000 g** and a fresh brain weight of **333 g**. Those textual summary values should be represented as source-text claims, not silently recomputed from incomplete table pairs.

### Provenance caution

The chapter explicitly notes uncertainty about whether the literature brain weights are fresh weights. The snapshot therefore preserves the printed values and labels without reclassifying individual observations as fresh brain weights. Likewise, rows lacking body weight or brain weight remain incomplete rather than being imputed.
