# HerculanoHouzel_etal_2007_Table1

Table 1 | Comparative cellular composition of the brain of the tree shrew and six primate species. Source: `HerculanoHouzel_etal_2007.pdf`, PDF page 2 (journal p.3563), DOI in `__ReadMe.xlsx`.

## Build

This build (2026-11-23) supersedes the folder's 2026-10-21 build, whose snapshot was **constructed by eye** from a 2.2× render because the PDF's text layer is scrambled. The paper is in PubMed Central (PMC1805542), so the snapshot is now captured programmatically from the PMC full text (Method 2 of `__HOWTO_make_a_snapshot.md`), to the standard of the 2026-11 HH2015-primaries programme. The item was already registered (Sheet1 row 439) and its registry row was completed, not created, in this round.

The seven species rows provide body mass and brain mass in g and total neurons and total non-neurons (printed ×10^6), as mean ± SD (the table's own footnote: "Values are mean ± SD. n.a., not available."). The printed Variation summary row stays in the snapshot and is omitted from the analysis CSV; the item script recomputes its four ratios from the parsed means as a capture check. Values on each side of ± are separated, counts are converted to absolute numbers, and "n.a." (squirrel monkey body mass) stays empty. `Number` is the number of individuals per species and the binomials are the ones the paper's Methods (Animals paragraph) attach to the same animals. The tree shrew's order is Scandentia; the other six are Primata.

From the paper folder, run:

```sh
Rscript HerculanoHouzel_etal_2007_Table1_snapshot.R
Rscript HerculanoHouzel_etal_2007_Table1.R
```

The snapshot script captures the table from the frozen PMC full text (`fulltext.html`) and refuses to overwrite a differing frozen snapshot. It was run once for this build. On subsequent runs, run only `Rscript HerculanoHouzel_etal_2007_Table1.R`. The R script reads only its item snapshot for measurements and writes `HerculanoHouzel_etal_2007_Table1.csv` and the DOI-coded public TSV. The item definitions are in `reference_tables/`.

## Interpretation and checks

- The snapshot was cross-checked cell-for-cell against **both** the publisher PDF and the superseded eye-read snapshot: all 40 value cells (8 rows × 4 measures, plus the heading row) agree across all three. The PDF text layer is scrambled in reading order (columns come out as blocks, and ± prints with the U+2AFE glyph) but every digit is present and matches.
- **Saimiri non-neurons adjudicated.** The squirrel monkey's total non-neurons print **2,075.03 ×10^6** in the PMC full text and in the publisher PDF alike. Herculano-Houzel et al. (2015) Table 5 prints 2,073.03 ×10^6 for the same quantity. The one-digit difference is therefore in the 2015 re-report, not in this paper; the build takes 2,075.03 as printed, and the paper's percent-neuron figure (61%) fits both readings, so the text cannot arbitrate further. No guard is applied here — the merge's precedence pin lets the primary's printed value stand.
- **The macaque is *Macaca mulatta*.** Table 1 prints only "Macaque monkey"; the Fig. 1 caption says *M. fascicularis*, but the Methods state the animals were rhesus monkeys (*Macaca mulatta*, n = 2, Vanderbilt colony). The build follows the Methods, and on that reading the row agrees exactly with Herculano-Houzel et al. (2015) Table 5's *M. mulatta* row (brain 87.346 g, body 3,900 g, neurons 6,376.16 M, non-neurons 7,162.90 M). The 46.162 g *M. fascicularis* row in the 2015 table is a different record (source Gabi et al. 2010), not a disagreement.
- The capuchin is carried as *Sapajus apella*, the accepted name Herculano-Houzel et al. (2015) and the species key use (the HH 2006 build precedent); the name printed in the paper (Fig. 1) is *Cebus apella*. The merge's resolver treats *Cebus apella* as a separate species, so building under the printed name would leave the 2007 totals beside the 2015 re-reports instead of displacing them.
- The Methods state that for all animals only one hemisphere was processed and the result multiplied by 2, so the printed masses and totals are whole-brain values.
- Table 1 is whole-brain only. The structure-level values (cerebral cortex, cerebellum, remaining structures) behind this paper's scaling analyses — and behind most of Herculano-Houzel et al. (2015)'s 245 citations of this paper — are in the online supporting information (SI Table 2), which is not part of this item and has not been built.
- The snapshot was checked by the assistant against the PDF text and layout; human visual signoff remains pending in the registry. These are source measurements, not a normal-versus-condition contrast. No merge is performed by this build.
