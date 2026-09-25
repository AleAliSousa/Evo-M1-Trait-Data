# Garwicz_etal_2009_TableS2

Garwicz, M., Christensson, M., & Psouni, E. (2009). A unifying model for timing of walking onset
in humans and other mammals. *Proceedings of the National Academy of Sciences*, 106(51), 21889-21893.
doi:10.1073/pnas.0905777106

Source snapshot: `Garwicz_etal_2009_TableS2_snapshot.csv` (frozen page-6 extraction from
`0905777106si.pdf`, produced by the sibling item's `Garwicz_etal_2009_TableS1.R`, which extracts both
supplementary tables — S1 (page 5, taxonomy) and S2 (page 6, database) — in a single `tabulapdf` pass).

## What we built
The folder had the frozen snapshot already extracted but no final CSV, R script, README, definitions,
or public TSV for this item. Built now:

- **Source:** `0905777106si.pdf`, page 6, "Table S2. Database for multiple-regression model" (24
  species).
- **Build:** `Garwicz_etal_2009_TableS2.R` reads the frozen snapshot, renames columns to their spelled-
  out form, splits each measure's printed literature-reference code "(n)" (or "(n, m)") into a
  companion "`<column> Ref`" column, converts the missing-value marker "—" to blank (Neonatal Brain
  Mass, reported for only some species), strips thousands-separator commas, and coerces the six numeric
  columns. Writes:
  - `Garwicz_etal_2009_TableS2.csv` (24 rows x 13 columns)
  - `__Public/comparative-data/10.1073%2Fpnas.0905777106_TableS2.tsv` (public, DOI-encoded, added now
    — matches the registry's `Item encoded`)
- **Definitions:** `reference_tables/Garwicz_etal_2009_TableS2_definitions.csv` (added now).

## Data role
**Primary.** Per-species brain mass (absolute and neonatal), body mass, gestation length, walking-onset
age (from both birth and conception), precocial/altricial status, and hindlimb standing posture
(plantigrade-capable vs. not) — the trait database the paper's walking-onset regression model was built
from.

## Scope note
Unlike the sibling item `Garwicz_etal_2009_TableS1` (which merges taxonomy onto the printed database
and outputs binomial species names), this item preserves Table S2 as its own distinct printed table:
species are identified only by the common ("lay term") name exactly as printed, with **no** binomial
merge applied. For binomial names by lay term, see `Garwicz_etal_2009_TableS1`.

## Column notes (from the article's own Table S2 footnote)
- **HSP** (Hindlimb Standing Position): differentiates species that can assume a plantigrade hindlimb
  stance (`Plant.`) from those that cannot (`Nonplant.`). The paper notes that of the species listed as
  plantigrade, only chimpanzees, gorillas, and humans actually walk with plantigrade posture — the
  others walk/run digitigrade. Elephants are listed `Nonplant.` because their heel is supported above
  the ground by a connective-tissue pad, making them mechanically plantigrade during force transmission.
- **Walking onset (Postconception days)** = Gestation (days) + Walking onset (Postnatal days), as
  printed in the source table (not re-derived here).
- Reference codes point to the paper's own 23-entry numbered bibliography printed beneath Table S2 (not
  reproduced in the CSV/TSV; consult the source PDF for full citations).

## Checks
- 24 rows, matching the printed table's species count and content (values cross-checked directly
  against the article PDF's own page-6 text, including all footnote reference codes).

## Extraction / build record
The frozen snapshot was already in place (produced by the sibling TableS1 build's PDF extraction pass).
The CSV, R script, public TSV, README, and definitions file were built and uploaded by Microsoft Copilot
(AI assistant) on 2026-09-25, reading the existing snapshot and cross-checking every value against the
source PDF page. No values were re-transcribed from the PDF; the snapshot's numbers were used as-is.
