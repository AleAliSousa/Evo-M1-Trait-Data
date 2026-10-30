# Kaskan et al. 2005 Table S1 and keyed references

`Kaskan_etal_2005_TableS1.R` reads `Kaskan_etal_2005_TableS1_snapshot.xlsx` directly. The workbook remains the frozen snapshot. The script extracts the full table-heading citation key (a-t), separates superscript letters from common names, joins both the short heading citation and full bibliographic reference to each species row, and writes CSV plus registry-coded public TSV.

`Kaskan_etal_2005_References_snapshot.csv` contains only the 20 references explicitly keyed a-t in the Table S1 heading. Full citations were transcribed from the main paper's References section; no references were invented. `Kaskan_etal_2005_References.R` validates and writes `Kaskan_etal_2005_References.csv`.

The cortical-area values are names/presence information, not surface-area measurements.

## Output columns

18 columns. Beyond the 13 transcribed from the table, the build adds
`species_as_published`, `table_heading_citation`, `full_reference` and `source`; all are
documented in `Kaskan_etal_2005_TableS1_definitions.csv`. Every one of the 30 rows carries both
reference columns. A row keyed to two letters (`e,f`; `o,p`; `o,q`) gets both citations joined
with `; `.

The 20 citations parsed out of the table heading were checked against the 20 hand-transcribed in
`Kaskan_etal_2005_References.csv` — all 20 match exactly, so the heading key and the transcription
corroborate each other.

## Snapshot repair, 2026-09-28

Ten cells of `Kaskan_etal_2005_TableS1_snapshot.xlsx` were corrected against the printed
supplement (`pb050091supp.pdf`). The pre-repair workbook is kept at
`archive/Kaskan_etal_2005_TableS1_snapshot_pre_repair_20260928.xlsx`. These were defects in the
PDF-to-workbook transcription, not features of the printed page:

- **`E4`, `E5`** — Callithrix jacchus's `visual_other` is printed over two lines, `MT, DM, FST,`
  then `VPP`. The extraction left `VPP` on the following row, so Callithrix lost it and
  Cheirogaleus medius gained it. Restored to `MT, DM, FST, VPP` and `MT`.
- **`E7`, `G26:G32`** — eight em-dashes dropped by the extraction, leaving blanks. Each is a row
  where the printed line carries one fewer field than the table has columns, and both earlier
  transcriptions (`archive/Kaskan_etal_2005_TableS1_snapshot.csv` and the 2026-09-25 CSV) agree on
  the em-dash. Restored.

Two printed features are deliberately **kept as the paper has them**, so the output now differs
from the 2026-09-25 CSV in these cells:

- spacing around `+` — the paper prints `AI + R`, `SI + SII`, `M + Pre M` (as `þ` in the PDF's
  font encoding); the earlier CSV had collapsed these to `AI+R` etc.
- `Cryptosis parva` — the paper's own misprint for *Cryptotis parva* (least shrew). The printed
  form stays in `species_as_published`; `species` carries the accepted binomial, per the
  convention in `deSousa_etal_2010` and `Finlay_etal_2006`.
- Garnett's greater bush baby keeps the PDF's typographic apostrophe (U+2019).
