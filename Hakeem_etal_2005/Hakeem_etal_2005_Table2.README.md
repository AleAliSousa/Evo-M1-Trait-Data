# Hakeem_etal_2005_Table2

Hakeem, A. Y., Hof, P. R., Sherwood, C. C., Switzer, R. C., III, Rasmussen, L. E. L., &
Allman, J. M. (2005). Brain of the African elephant (*Loxodonta africana*): Neuroanatomy from
magnetic resonance images. *The Anatomical Record Part A*, 287A, 1117-1127.
doi:10.1002/ar.a.20255

Source snapshot: `Hakeem_etal_2005_Table2_snapshot.csv` (hand-transcribed, verbatim copy of the
printed Table 2, "Elephant brain volume measurements," p. 1126 of the article PDF).

## What we built
The paper folder previously had no source PDF at all (flagged as genuinely missing); the source
PDF was subsequently supplied. This item had no snapshot, CSV, R script, README, or definitions.
Built now:

- **Source:** the article's own Table 2 (p. 1126), transcribed directly from the PDF text layer.
- **Build:** `Hakeem_etal_2005_Table2.R` reads the frozen snapshot and writes:
  - `Hakeem_etal_2005_Table2.csv` (6 rows x 2 columns)
  - `__Public/comparative-data/10.1002%2Far.a.20255_Table2.tsv` (public, DOI-encoded, added now —
    matches the registry's `Item encoded`)
- **Definitions:** `reference_tables/Hakeem_etal_2005_Table2_definitions.csv` (added now).

## Data role
**Primary.** Six brain-structure volumes (whole brain, neocortical gray, neocortical white,
cerebellar gray, cerebellar white, other cerebellar structures) for a single adult female African
elephant specimen, measured from postmortem MRI segmented in the Amira software package (manual +
semiautomated tools). No replicate/SD values are printed — this is a single-specimen table. The
paper's own Table 1 (p. 1125, "Gray matter volume vs. cross-sectional area of corpus callosum")
is not a separate registry item — only Table 2 is tracked here — but note for cross-checking that
Table 1's elephant row repeats this table's neocortical gray volume (1,378.7 cm³) for its
corpus-callosum ratio calculation.

## Checks
- 6 rows, 2 columns, matching the printed table exactly.
- Whole-brain volume (3,886.7 cm³) and neocortical gray volume (1,378.7 cm³) are internally
  consistent with the elephant row of the paper's own Table 1 (p. 1125), which repeats the same
  neocortical gray value (1,378.7 cm³) for its corpus-callosum ratio calculation.

## Extraction / build record
Transcribed directly from the article PDF's Table 2 (p. 1126) by Microsoft Copilot (AI assistant)
on 2026-09-25, after the user supplied the previously-missing source PDF. The CSV, R script,
public TSV, README, and definitions file were all built in this pass. No prior build existed for
this item.
