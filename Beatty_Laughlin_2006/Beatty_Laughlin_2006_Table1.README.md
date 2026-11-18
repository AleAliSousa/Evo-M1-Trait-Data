# Beatty & Laughlin 2006 — Table 1 (mouse strain cortical / non-cortical volumes)

Beatty J, Laughlin RE (2006). *Genomic regulation of natural variation in
cortical and noncortical brain volume.* BMC Neuroscience 7: 16.
doi:10.1186/1471-2202-7-16. PMID 16503985; PMCID PMC1402304.

Table **1** — neocortical (cortical) and non-cortical brain volumes for
**34 BXD recombinant inbred strains** of *Mus musculus* plus the parental
strains **C57BL/6J** and **DBA/2J** (36 strain rows; strain means,
N = 3–5 animals). Both the authors' in-vivo estimates and their
size-regressed values are given.

## What we built

- **Frozen sources:** publisher PDF, Europe PMC full-text XML, and the
  publisher's figure files (the article has no supplementary data files).
- **Reformat:** `Beatty_Laughlin_2006_Table1.R` transcribes Table 1 and
  writes:
  - `Beatty_Laughlin_2006_Table1.csv` (36 rows, volumes in mm³)
  - `../__Public/comparative-data/10.1186%2F1471-2202-7-16_Table1.tsv` (public, DOI-encoded
    — name is the expected Item encoded; see Registry)
- **Definitions:** `reference_tables/Beatty_Laughlin_2006_Table1_definitions.csv`.
- **Reader:** the CSV/TSV were produced by Muse (Buddy), Michael
  Proulx's AI assistant, by parsing the frozen full-text XML table
  programmatically (36/36 rows, C57BL/6J spot values verified against the
  article PDF). The R script was run in an isolated copy on 2026-11-18; its CSV and TSV matched the committed files by cell.

## Data role and caveats

- **Primary, strain-level.** The volumes are the authors' own
  measurements. A species-level *Mus musculus* value requires choosing a
  strain; Castillo-Morales et al. (2016) used C57BL/6J (cortical
  115.59 mm³, total 477.60 mm³).
- **In-vivo estimates** are shrinkage-corrected by the authors (measured
  volumes × fresh brain weight / fixed total volume); non-cortical =
  total − cortical, with total estimated from fresh brain weight at
  specific gravity ≈ 1.00 (the 1 g = 1 cm³ convention — see
  `_COMMON_CALCULATIONS.md`).
- **Regressed columns are size-corrected values for QTL mapping**, not
  volumes; they are flagged `derived` in the definitions and must not be
  pooled with measured volumes.

## Registry

The public TSV name above is the expected Item encoded
(10.1186%2F1471-2202-7-16_Table1). The registry row was added on 2026-11-18; descriptive metadata remain incomplete. Merge ingestion is pending.
