# Fu_etal_2013_Table1

Fu, Y., Rusznák, Z., Herculano-Houzel, S., Watson, C., & Paxinos, G. (2013). Cellular composition
characterizing postnatal development and maturation of the mouse brain and spinal cord. *Brain
Structure and Function*, 218(6), 1337-1354. doi:10.1007/s00429-012-0462-x

Source snapshot: `Fu_etal_2013_Table1.xlsx` (hand-transcribed, verbatim copy of the article's printed
Table 1, retained as the frozen snapshot).

## What we built
The folder had a completed transcription (`Fu_etal_2013_Table1.xlsx`) sitting alongside an
abandoned/incomplete draft (`Fu_etal_2013_paper.xlsx`, flagged internally with the note "*replace
with numbers from text of the paper" and missing the Pituitary gland row) — no CSV, R script, README,
or definitions had been built from either. Built now from the complete transcription:

- **Source:** `Fu_etal_2013_Table1.xlsx`, cross-checked sentence-for-sentence against Table 1 as
  printed in the article PDF (`Fu-2013-Cellular composition characterizing po.pdf`, page 6) — all 7
  structure rows and 18 data columns match exactly, including the Pituitary gland row that the
  abandoned draft omitted.
- **Build:** `Fu_etal_2013_Table1.R` reads the snapshot, flattens the printed two-row header (metric
  name + age-window sub-header) into 18 single-row column names of the form
  `<Metric>_wk<start>to<end>`, and writes:
  - `Fu_etal_2013_Table1.csv` (7 rows x 19 columns)
  - `__Public/comparative-data/10.1007%2Fs00429-012-0462-x_Table1.tsv` (public, DOI-encoded, added
    now — matches the registry's `Item encoded`)
- **Definitions:** `reference_tables/Fu_etal_2013_Table1_definitions.csv` (added now, describing all 19
  columns).

## Data role
**Primary.** Table 1 is a significance/direction summary, not a table of raw measurements: each cell
codes the direction and statistical significance of an age-related change (mass, neuron number,
non-neuron number, neuron density, non-neuron density, and non-neuron/neuron ratio) across three
pairwise age-window comparisons (4-to-15, 15-to-40, and 4-to-40 weeks), for six CNS structures plus the
pituitary gland. Underlying numeric values (means ± SEM) are reported only in the article's figures and
running text, not in Table 1 itself, and are not reconstructed here.

## Symbol code (carried through verbatim from the source table)
- `↑` / `↑↑` / `↑↑↑` — increase, significant at p<0.05 / p<0.01 / p<0.001
- `↓` / `↓↓` / `↓↓↓` — decrease, significant at p<0.05 / p<0.01 / p<0.001
- `–` (en dash) — no statistically significant change
- `NA` — not applicable (the pituitary gland has no NeuN-based neuron/non-neuron split; per the
  article's own footnote a, its `NumNonNeurons_*` and `DensityNonNeurons_*` columns instead report the
  pituitary's total cell number and density)

## Checks
- 7 rows (Cerebellum, Isocortex, Hippocampus, Olfactory bulb, Rest of the brain, Spinal cord, Pituitary
  gland), 19 columns (Structure + 18 significance-code columns), matching the printed table exactly.
- Verified against the article PDF's own Table 1 (page 6) and its footnotes, which define the arrow/NA
  coding scheme.

## Extraction / build record
The frozen snapshot (`Fu_etal_2013_Table1.xlsx`) was already transcribed and complete. The CSV, R
script, public TSV, README, and definitions file were built and uploaded by Microsoft Copilot (AI
assistant) on 2026-09-25, reading the existing xlsx snapshot and cross-checking it against the source
PDF. No values were re-transcribed or changed. The incomplete `Fu_etal_2013_paper.xlsx` draft in the
same folder was not used as a source and should be considered superseded — it can be removed by a
maintainer with delete access.
