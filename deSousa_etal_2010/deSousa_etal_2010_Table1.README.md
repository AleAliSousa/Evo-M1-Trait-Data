# deSousa_etal_2010_Table1

## Source
de Sousa, A. A., et al. (2010). Hominoid visual brain structure volumes... J Hum Evol 58(4),281-292. Registry Item **Table 1**; DOI/PMID-coded TSV `10.1016%2Fj.jhevol.2009.11.011_Table1.tsv`.

**hominoid visual brain structure volumes.** Volumes in mm³ (body weight g, brain weight mg). Part of the **Stephan/Düsseldorf histological-volume collection**.

## Pipeline
raw → snapshot → R → usable csv/tsv. Files: `deSousa_etal_2010_Table1_snapshot.xlsx` (sheet `Table1`), `deSousa_etal_2010_Table1.R` → `deSousa_etal_2010_Table1.csv` (+ TSV), `reference_tables/deSousa_etal_2010_Table1_definitions.csv`, `comparison/deSousa_2010.csv` (curated source, audited).

Structures: Neocortex, Area striata grey matter, Corpus geniculatum laterale, Total brain net volume.

## Preparation → `deSousa_etal_2010_Table1.csv`
One row per specimen. Values are taken from the curated comparison CSV `deSousa_2010.csv` (the audited journal data) and laid out journal-style in the snapshot; the reformat cleans names and types values (already mm³). Verified against the comparison CSV: **0 value mismatches**.

The 29 paper rows and their 29 dissertation-code aliases are registered in
`_keys/specimen_crosswalk/specimen_crosswalk.csv`. Measure provenance is split:
V1/LGN are de Sousa measurements; 15 neocortex values were supplied by Carol
MacLeod. The restricted comparison reproduces all 15 MacLeod neocortex and
brain-volume values within one-decimal publication rounding. Direct Frahm
identifier overlap is limited to `1548` and `A375`/`375`; it is audited in the
restricted companion rather than used to relabel every value as Frahm data.

## Laterality — Table 1 is LEFT and **undoubled**; Supp. Table 2 is the doubled version

All measurements are from the left hemisphere: *"We used sections from the left hemispheres of adult
specimens."* Table 1 prints those left values **as measured**, so `left_V1_volume_cm3` and
`left_LGN_volume_cm3` keep the `_left` suffix in the merge and can never be averaged against a
both-sides volume.

The doubling happens in the **same paper's Supplementary Table 2**, per Methods:

> "In all statistical analyses, left V1 and left LGN volumes were doubled to estimate the total (left
> plus right hemisphere) volumes of V1 and LGN for each specimen because the volumes of V1 (Amunts et
> al., 2007a) and LGN (H. Frahm, unpublished observation) apparently do not exhibit major asymmetries."

Verified arithmetic — Supp. Table 2 V1 = 2 × mean(Table 1 left V1):

| Species | mean left V1 (Table 1) | × 2 | Supp. Table 2 V1 |
|---|---|---|---|
| *Homo sapiens* | 7.63 | 15.26 | 15.2 |
| *Pan troglodytes* | 4.143 | 8.29 | 8.3 |
| *Pan paniscus* | 5.80 | 11.60 | 11.6 |
| *Gorilla gorilla* | 4.55 | 9.10 | 9.1 |
| *Pongo pygmaeus* | 4.133 | 8.27 | 8.2 |
| *Hylobates lar* | 2.05 | 4.10 | 4.1 |

(LGN does not reproduce as cleanly from the printed table because Table 1 rounds LGN to 1 d.p. and the
specimen subset with LGN differs from the subset with V1; the doubling is the same.)

Both tables are registered in `../__merging_volumes/laterality_known.csv` — Table 1 as
`doubling = none`, Supp. Table 2 as `doubling = by_source`. This is **provenance, not a veto**: the
doubling is a deliberate estimator with a stated symmetry argument, so nothing is omitted. Supp.
Table 2 is not currently in any merge, but its term map already points V1 at the unsuffixed
`Area_striata_grey_matter_Vol.mm3`, so the registry row is what stops it being treated as a bilateral
measurement if it is ever ingested. `bilateral_stems_exclude` likewise stops the merge doubling
Table 1's left values into a second, redundant estimate of the same measurement.

## Note
Snapshot built from the curated `deSousa_2010.csv`; detailed visual fidelity to the printed PDF table layout is a light follow-up (values are the audited source). Used in `__merging_volumes` (Tier 2 (averaged)).
