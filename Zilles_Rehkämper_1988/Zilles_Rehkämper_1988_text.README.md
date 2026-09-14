## Zilles_Rehkämper_1988_text

### Source

Zilles, K., & Rehkämper, G. (1988), *The brain, with special reference to the telencephalon*, in J. H. Schwartz (Ed.), **Orang-Utan Biology** (pp. 157–176), Oxford University Press. ISBN 9780195043716.

This item captures summary statistics reported in the chapter text rather than a printed table. The relevant passage reports a mean body weight of **54,000 g** and a fresh brain weight of **333 g**, followed by sex-specific body- and brain-weight summaries.

### Files

- `zilles_rehkamper_1988.pdf`: publication.
- `Zilles_Rehkämper_1988_text_snapshot.csv`: hand-transcribed, source-faithful snapshot of the textual summary statistics.
- `Zilles_Rehkämper_1988_text.R`: preparation script; reads only the snapshot.
- `Zilles_Rehkämper_1988_text.csv`: typed analysis-ready output written by the script.

### Snapshot organization

Each row represents one reported summary. The snapshot separates the components that were previously combined inside text cells:

- `Species`: taxon represented by the summary.
- `summary_group`: `male`, `female`, or `sex-balanced`.
- `measure`: `brain_weight` or `body_weight`.
- `unit`: grams.
- `reported_mean`: reported central value.
- `reported_plus_minus`: the reported value following ±, where supplied.
- `N`: sample size where explicitly supplied.
- `provenance_note`: distinguishes reported sex-specific means from reported species values and records transparent arithmetic relationships.

The paper does not label the ± values as SD or SE. The snapshot therefore uses the neutral column name `reported_plus_minus` and does not assign an uncertainty type.

### Relationship among reported values

The reported brain-weight species value can be reproduced from the two reported sex-specific means:

`(359 + 306) / 2 = 332.5 g`, rounded to **333 g**.

The reported body-weight species value is similarly reproduced as:

`(72,000 + 36,000) / 2 = 54,000 g`.

Accordingly, `sex-balanced` is used instead of `weighted averages of males and females`. “Weighted” would normally imply unequal weights, whereas these values are reproduced by giving the male and female summaries equal weight.

The publication does not specify the exact Table 12-1 records used to calculate the sex-specific brain-weight means. These textual summaries must therefore remain distinct from the individual literature records transcribed from Table 12-1.

### Preparation

The R script reads the organized CSV snapshot, cleans text fields, assigns numeric types to means, ± values, and sample sizes, and writes the local CSV plus the registry-coded TSV when the repository registry and shared output folder are available.

No values are recalculated or inferred by the script. Arithmetic relationships are documented in `provenance_note`, but the reported publication values remain the stored data.
