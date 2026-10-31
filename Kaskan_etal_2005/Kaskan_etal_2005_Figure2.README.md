# Kaskan_etal_2005_Figure2

## Source
Kaskan, P. M., Franco, E. C. S., Yamada, E. S., Silveira, L. C. L.,
Darlington, R. B., & Finlay, B. L. (2005). Peripheral variability and
central constancy in mammalian visual system evolution. *Proc R Soc Lond
B*, 272, 91-100. doi:10.1098/rspb.2004.2925

Registry Item **Figure 2**, printed p. 94 (PDF page 5). Local copy:
`Kaskan_etal_2005/Kaskan-2005-Peripheral variability and central.pdf`.

## What this item is - and what it deliberately is not
Figure 2 plots **only fitted regression lines**. There is not a single data
point in either panel, so there is nothing to digitise and this item is
**not** a figure digitisation (contrast `Kaskan_etal_2005_Figure3`, whose
panels do carry species-level scatter and which was digitised, with
caveats).

What Figure 2 *does* publish is printed text: the eight fitted equations
with their r-squared values, and three slope-difference tests. Those
printed statistics are the item. They appear nowhere else in the paper or
its electronic appendices.

The earlier judgement recorded in `Kaskan_etal_2005_Figure3.README.md` -
that "Figure 2 (which truly shows only contrast-regression lines, no raw
points) remains out of scope" - was about ingesting Figure 2 as
*measurement* data, and that judgement still stands: see Data role below.
Building the printed statistics for provenance is a different thing and is
what has been done here.

## Pipeline
Printed figure legend -> **constructed** snapshot -> analysis csv -> public TSV.

| file | role |
|---|---|
| `Kaskan_etal_2005_Figure2_snapshot.csv` | frozen constructed source (caption + 8 printed equations + locus line) |
| `Kaskan_etal_2005_Figure2.R` | reads the snapshot, splits the equations, writes CSV + public TSV |
| `Kaskan_etal_2005_Figure2.csv` | analysis rows (8 x 17) |
| `reference_tables/Kaskan_etal_2005_Figure2_definitions.csv` | data dictionary (canonical 10-column schema) |
| `reference_tables/Kaskan_etal_2005_Figure2_slope_comparisons.csv` | the three slope-difference tests printed in the same legend |
| `__Public/comparative-data/10.1098%2Frspb.2004.2925_Figure2.tsv` | public copy |

## The constructed snapshot and reader provenance
The snapshot freezes the printed legend's first sentences as the caption
row, then one row per printed equation in the order the legend lists them
(V1, Vtot, S1, SStot, A1, Atot, M, Mtot), each with the panel it is drawn
in, the label printed beside that line in the panel, the equation exactly
as printed, and the r-squared exactly as printed - including the two that
are printed to two decimals rather than three (Atot 0.93, M 0.86). A
closing row records the printed locus.

The equations were **typed from the page image**, not scraped. The PDF has
a text layer but it is unusable for this passage: it renders "=" as U+00BC,
the decimal point as ":", and the minus sign as U+0003, it emits the
superscript 2 of r-squared and the "tot" subscripts as free-floating words
at their own coordinates, and the two-column layout interleaves the
Figure 3 legend into the middle of the Figure 2 one. A page image was
rendered at 400 dpi with `pdftools::pdf_convert` and the legend read
zoomed. Reader: AI assistant (Claude, Anthropic), 2026-10-31. **Human
visual curation of the eight equations against printed p. 94 is pending**
and matters more than usual here precisely because the text layer cannot
corroborate them.

## Two cautions that travel with these numbers
1. **The drawn intercepts are not the printed intercepts.** The legend
   states that "The intercepts of the lines have been adjusted for easier
   visualization of the relative slope". Only the equations are usable;
   anything measured off the plotted lines is not. `intercept_plotted_is_adjusted`
   is TRUE on every row to keep that attached to the data.
2. **These are contrast regressions.** Both axes are phylogenetically
   independent contrasts, so the slopes are not ordinary species-level
   allometric slopes and the intercepts have no species-level meaning.

## Data role
`secondary` on every row, and **not merged**. These are fitted statistics
over values measured by other studies (the per-species areas are compiled
in Electronic Appendix A, built here as `Kaskan_etal_2005_TableS1`), and
`PROJECT_SCOPE_AND_DATASET_ROADMAP.md` excludes ingesting secondary slopes
as a measurement team. There are no per-row reference keys to resolve: the
legend cites no sources, and the underlying per-species sources are already
carried, per species and per area, by the TableS1 build and its
`reference_tables/Kaskan_etal_2005_TableS1_source_match.csv`. No
references file was therefore created for this item.

## Table checks

The legend has no internal arithmetic - slopes and r-squared values are
not additive and there is no total - so no sum check exists and none was
invented. The legend does make one claim the printed numbers can confirm:
"The slopes for primary and total visual cortices are greatest." The
reader checks it per panel, exact.

Result of the recorded run (`Rscript --vanilla`, 2026-10-31):
**2 pass, 0 mismatch**. In panel a the steepest of the four printed slopes
is V1 (1.086, against M 0.84, A1 0.697, S1 0.664) and in panel b it is
Vtot (1.27, against Mtot 1.044, Atot 0.895, SStot 0.796). A mismatch here
would have meant a mis-transcription or a wrong panel assignment.

A transcription guard that looked for each frozen equation in the PDF text
layer was written first and then **removed**: the layer's font-encoding
damage and floating superscripts made it fail on well-transcribed rows, so
it was measuring the text layer rather than the transcription. Reporting
that is better than keeping a check whose failures mean nothing.

## Pending
Human visual curation of the eight equations and three tests against
printed p. 94; owner paste of `Kaskan_etal_2005_Figure2_registry_row.xlsx`.
