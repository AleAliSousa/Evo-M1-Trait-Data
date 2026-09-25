# Boddy_etal_2012_brainbodydatabasev2

Boddy, A. M., McGowen, M. R., Sherwood, C. C., Grossman, L. I., Goodman, M., & Wildman, D. E. (2012).
Comparative analysis of encephalization in mammals reveals relaxed constraints on anthropoid primate
and cetacean brain scaling. *Journal of Evolutionary Biology*, 25(5), 981-994.
doi:10.1111/j.1420-9101.2012.02491.x

Source snapshot: `brain_body_database_v2.txt` (frozen tab-delimited snapshot; the supplied TXT file is
already a clean, well-formed table and is used directly as source data — no separate snapshot file is
generated).

## What we built
The folder had a working CSV, R script, and public TSV already in place (1,998 species rows across
Mammalia), but no README or definitions file. Now documented to convention:

- **Source:** `brain_body_database_v2.txt`, a compiled cross-mammal brain/body-mass database (Boddy et
  al.'s supplementary encephalization-scaling compilation), read directly as the frozen snapshot.
- **Build:** `Boddy_etal_2012_brainbodydatabasev2.txt.R` reads the tab-delimited snapshot, appends a
  constant `source_dataset` tag, and writes:
  - `Boddy_etal_2012_brainbodydatabasev2.txt.csv` (1,998 rows × 15 columns)
  - `__Public/comparative-data/10.1111%2Fj.1420-9101.2012.02491.x_brainbodydatabasev2.txt` (public,
    DOI-encoded, already present — matches the registry's `Item encoded`)
- **Definitions:** `reference_tables/Boddy_etal_2012_brainbodydatabasev2.txt_definitions.csv` (added
  now, describing all 15 columns).

## Data role
**Primary compiled dataset.** Per-species brain volume/mass and body mass, with standard deviations,
sex, individual count, age class, and a per-row `Source` citation to the underlying primary literature
the compilation drew from (not resolved to full citations here — Boddy et al. do not republish full
bibliographic entries for each compiled source in this table).

## Scope note
This is a distinct item from the sibling `Boddy_etal_2012_TableS1` (the paper's own supplementary
encephalization-quotient table, `jeb_2491_sm_tables1.xlsx`) — `brainbodydatabasev2` is the underlying
raw brain/body compilation the paper's EQ analysis was built from, not the EQ results themselves.

## Checks
- 1,998 data rows, 15 columns, matches the frozen snapshot exactly aside from the appended
  `source_dataset` column.
- Column headers unchanged from the source TXT file.

## Extraction / build record
The CSV, R script, and public TSV were already in place and working. This README and the definitions
file were added by Microsoft Copilot (AI assistant) on 2026-09-25, reading the existing `.R` script and
source snapshot to document the pipeline. No values were re-transcribed or changed.
