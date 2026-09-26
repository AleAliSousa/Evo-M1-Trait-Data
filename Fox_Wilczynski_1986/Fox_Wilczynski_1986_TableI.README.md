# Fox_Wilczynski_1986_TableI

Fox, J. H., & Wilczynski, W. (1986). Allometry of major CNS divisions: towards a reevaluation
of somatic brain-body scaling. *Brain, Behavior and Evolution*, 28(4), 157-169.
doi:10.1159/000118700

Source snapshot: `Fox_Wilczynski_1986_TableI_snapshot.csv` (hand-transcribed, verbatim copy of
the printed Table I, "Rodent weight data (means ± SD)," p. 162 of the article PDF).

## What we built
The paper folder previously had no source PDF at all (flagged as genuinely missing); the source
PDF was subsequently supplied. This item had no snapshot, CSV, R script, README, or definitions.
Built now:

- **Source:** the article's own Table I (p. 162), transcribed directly from the PDF page image
  (the printed table is badly OCR-mangled in the text layer, so values were read from the
  rendered page image instead) and cross-checked against the log/log plot in Figure 2 on the
  same page, which shows the same five species in the same rank order for each measure.
- **Build:** `Fox_Wilczynski_1986_TableI.R` reads the frozen snapshot and writes:
  - `Fox_Wilczynski_1986_TableI.csv` (5 rows x 14 columns)
  - `__Public/comparative-data/10.1159%2F000118700_TableI.tsv` (public, DOI-encoded, added now —
    matches the registry's `Item encoded`)
- **Definitions:** `reference_tables/Fox_Wilczynski_1986_TableI_definitions.csv` (added now).

## Species and sample sizes
The printed table gives only mean ± SD per row, not N. Sample sizes were taken from the
Materials and Methods text (p. 161): "22 male and 22 female CD-1 mice, 8 male Mongolian gerbils
(*Meriones unguiculatus*), [17] male hamsters, and 8 female Sprague-Dawley rats." The hamster
species binomial in the running text is OCR-garbled beyond confident recovery ("Criulus
cricems"); it is recorded here as "Hamster" with a note flagging the likely candidates
(*Mesocricetus auratus* or *Cricetus cricetus*) rather than guessing a binomial. This should be
resolved against the original print copy if the exact species matters downstream.

## Column abbreviations (defined in Materials and Methods, p. 161)
- **WB** = whole brain weight (analytical balance)
- **CB** = cerebellum weight (dissected and weighed separately)
- **FB** = total forebrain weight (diencephalon + telencephalon complement)
- **BS** = total brainstem weight (mesencephalon + rest complement)
- **SCA** = spinal cord cross-sectional area, derived from weighed tracings of projected 40x
  images of 20-micron sections taken at the rostral-most end of the spinal cord

## Data role
**Primary.** Directly measured rodent body and brain-division weights (5 species/sex groups),
gathered by gross dissection and analytical weighing of formalin-fixed brains, used in the
paper's own allometric regressions. The registry's recommendation notes to extract Table I only
as primary data and not to duplicate the Stephan et al. (1970) insectivore/primate data the paper
cites for comparison (that data lives in its own Stephan-authored registry items) — this item
contains only the paper's own newly collected rodent measurements.

## Checks
- 5 rows (2 mouse sex-groups + gerbil + hamster + rat), 14 columns (paired mean/SD for each of
  6 measures, plus N), matching the printed table exactly.
- Rank order across species for each measure cross-checked against the shape of the log/log
  regression lines in Figure 2 (same page) — consistent.

## Extraction / build record
Transcribed directly from the article PDF's Table I page image (p. 162) by Microsoft Copilot
(AI assistant) on 2026-09-25, after the user supplied the previously-missing source PDF. The CSV,
R script, public TSV, README, and definitions file were all built in this pass. No prior build
existed for this item.
