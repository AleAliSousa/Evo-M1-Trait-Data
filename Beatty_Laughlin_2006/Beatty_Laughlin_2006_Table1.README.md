# Beatty & Laughlin 2006 — Table 1 (mouse strain cortical / non-cortical volumes)

Beatty J, Laughlin RE (2006). *Genomic regulation of natural variation in
cortical and noncortical brain volume.* BMC Neuroscience 7: 16.
doi:10.1186/1471-2202-7-16. PMID 16503985; PMCID PMC1402304.

Table **1** — neocortical (cortical) and non-cortical brain volumes for
**34 BXD recombinant inbred strains** of *Mus musculus* plus the parental
strains **C57BL/6J** and **DBA/2J** (36 strain rows; strain means,
N = 3–5 animals). Both the authors' in-vivo estimates and their
size-regressed values are given.

## Source → Snapshot → Data readable → Online database

- **Source:** the publisher's full-text XML of the article (Europe PMC,
  PMCID PMC1402304), frozen in this folder as `fulltext.xml`, with the
  publisher PDF (`1471-2202-7-16.pdf`) held as provenance. The article
  has no supplementary data files; all data are in the main-text tables.
- **Snapshot:** `Beatty_Laughlin_2006_Table1_snapshot.csv` — Table 1
  captured exactly as published (printed column headers, strain order,
  values in mm³) by `Beatty_Laughlin_2006_Table1_snapshot.R`, which reads
  the frozen XML (snapshot method 2, publisher's machine-readable table)
  and refuses to overwrite a differing frozen copy. Captured and
  cross-checked against the publisher PDF by Buddy (AI assistant) on
  2026-11-18 (36/36 rows; C57BL/6J cortical 115.59 mm³ matches the
  printed table and the value Castillo-Morales et al. 2016 cite).
- **Data readable:** `Beatty_Laughlin_2006_Table1.R` reads **only** the
  snapshot and writes `Beatty_Laughlin_2006_Table1.csv` (36 rows) and
  the public TSV. The script runs clean under Rscript and reproduces
  the committed CSV/TSV exactly.
- **Definitions:** `reference_tables/Beatty_Laughlin_2006_Table1_definitions.csv`.
- **Online database:** public TSV `10.1186%2F1471-2202-7-16_Table1.tsv`
  in `__Public/comparative-data/`; registry row in `__ReadMe.xlsx`
  (Item name `Beatty_Laughlin_2006_Table1`).

## Data role and caveats

- **Primary, strain-level.** The volumes are the authors' own
  measurements. A species-level *Mus musculus* value requires choosing a
  strain; Castillo-Morales et al. (2016) used C57BL/6J (cortical
  115.59 mm³, total 477.60 mm³). The table names no species; every row
  is *Mus musculus*, the paper's subject, recorded on every row of the
  analysis CSV.
- **In-vivo estimates** are shrinkage-corrected by the authors (measured
  volumes × fresh brain weight / fixed total volume); non-cortical =
  total − cortical, with total estimated from fresh brain weight at
  specific gravity ≈ 1.00 (the 1 g = 1 cm³ convention — see
  `_COMMON_CALCULATIONS.md`).
- **Regressed columns are size-corrected values for QTL mapping**, not
  volumes; they are flagged `derived` in the definitions and must not be
  pooled with measured volumes.
