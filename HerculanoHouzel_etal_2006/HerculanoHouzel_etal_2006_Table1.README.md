# HerculanoHouzel_etal_2006_Table1

Table 1 | Comparative cellular composition of the brains of six rodent species. Source: `Herculano-Houzel-2006-Cellular scaling rul.pdf`, PDF page 2, DOI in `__ReadMe.xlsx`.

## Build

The six species rows provide body mass and brain mass in g and total cells and total neurons (printed ×10^6), as mean ± SD (the table's own footnote: "Values are mean ± SD"). The printed Variation summary row stays in the snapshot and is omitted from the analysis CSV. Values on each side of ± are separated, and counts are converted to absolute numbers. `Number` is the number of individuals per species, from the paper's Methods (Animals paragraph), which also prints the binomial behind each vernacular name.

From the paper folder, run:

```sh
Rscript HerculanoHouzel_etal_2006_Table1_snapshot.R
Rscript HerculanoHouzel_etal_2006_Table1.R
```

The snapshot script captures the table from the frozen PMC full text (`fulltext.html`) and refuses to overwrite a differing frozen snapshot. It was run once for this build. On subsequent runs, run only `Rscript HerculanoHouzel_etal_2006_Table1.R`. The R script reads only its item snapshot for measurements and writes `HerculanoHouzel_etal_2006_Table1.csv` and the DOI-coded public TSV. The item definitions are in `reference_tables/`.

## Interpretation and checks

- The snapshot was cross-checked cell-for-cell against the publisher PDF (35 of 35 cells agree; the only rendering difference is the ± glyph, U+2AFE in the PDF text layer vs U+00B1 in PMC).
- The agouti total-neurons value (856.74 ×10^6) is printed **without an SD** in both the PDF and the PMC rendering. The SD cell is left empty in the build; no value was invented.
- The paper prints three binomials misspelled — "Mesocrycetus auratus", "Dasyprocta primnolopha", "Hydrochoerus hydrochoeris". The build uses the accepted names as in Herculano-Houzel et al. (2015) and the HerculanoHouzel species key (Mesocricetus auratus, Dasyprocta prymnolopha, Hydrochoerus hydrochaeris); the printed vernacular names are retained in `Common name`.
- Herculano-Houzel et al. (2011) recalculated these six species' averages from their dissected structures without re-measuring: body masses are identical, but its whole-brain masses and cell totals (structure sums) are systematically a few percent below this paper's printed direct whole-brain totals (e.g. mouse brain mass 0.402 vs the printed 0.416 g). This build takes the 2006 values exactly as printed; how the two are reconciled is a merge-wiring decision, not a build decision.
- The snapshot was checked by the assistant against the PDF text and layout; human visual signoff remains pending in the registry. These are source measurements, not a normal-versus-condition contrast. No merge is performed by this build.
