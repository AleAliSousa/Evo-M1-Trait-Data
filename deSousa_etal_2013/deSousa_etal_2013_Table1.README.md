# deSousa_etal_2013_Table1

## Source
de Sousa, A. A., et al. (2013). Lamination of the lateral geniculate nucleus of catarrhine primates. Brain Behav Evol 81(2),93-108. Registry Item **Table 1**; DOI/PMID-coded TSV `10.1159%2F000346495_Table1.tsv`.

**lateral geniculate nucleus (LGN) lamination volumes.** Volumes in mm³ (body weight g, brain weight mg). Part of the **Stephan/Düsseldorf histological-volume collection**.

## Pipeline
source PDF → `deSousa_etal_2013_Table1_snapshot.xlsx` (sheet `Table1`) →
`deSousa_etal_2013_Table1.R` → `deSousa_etal_2013_Table1.csv` (+ TSV).
The item also reads `reference_tables/deSousa_etal_2013_Table1_precision_lookup.csv`
for established values carried at finer precision than this table prints.

Structures: Corpus geniculatum laterale.

## Preparation → `deSousa_etal_2013_Table1.csv`
The snapshot now follows the eight printed columns and 20 species rows in their
source order, with the caption, `NA` cells, residuals, and footnote. The R reader
filters the species without an LGN value, converts cm³ to mm³ and g to mg, joins
the separate precision lookup by exact species label, checks that each lookup
value agrees within the table's rounding, then sorts the analysis rows. This
rebuild reproduces the previous analysis CSV cell for cell. The lookup preserves
legacy curated values; its finer precision has not been independently verified
against another publication in this pass.

## Laterality — the published LGN volumes are 2 × the LEFT side

**The printed LGN volumes are already doubled, and this paper never says so.** The convention is
stated only in the companion paper, de Sousa et al. (2010) *J Hum Evol*, Methods:

> "In all statistical analyses, left V1 and left LGN volumes were doubled to estimate the total (left
> plus right hemisphere) volumes of V1 and LGN for each specimen because the volumes of V1 (Amunts et
> al., 2007a) and LGN (H. Frahm, unpublished observation) apparently do not exhibit major asymmetries."

The 2013 Methods say only that *"A minimum of one left hemisphere was investigated per species,
although both right and left hemispheres were investigated for most specimens."* The evidence that
Table 1 inherits the 2010 doubling is that its LGN values reproduce de Sousa 2010 Supplementary
Table 2 — documented there as 2 × left — exactly for the species they share: *Homo sapiens* 0.335,
*Pongo pygmaeus* 0.259, *Hylobates lar* 0.166 cm³.

**This is provenance, not an error.** The doubling is a deliberate estimator with a stated symmetry
argument, so the value is used exactly as published. It is registered in
`../__merging_volumes/laterality_known.csv` as `doubling = by_source`, which means:

- the standardized term is the plain both-sides `Corpus_geniculatum_laterale_Vol.mm3` (no `_left`
  suffix — the number legitimately stands for both hemispheres);
- the merge never doubles it again (`bilateral_stems_exclude`);
- each merged cell drawing on it is stamped `published_bilateral_estimate` in
  `volumes_flags.csv` — a **provenance** record, distinct from an `action = skip` veto in
  `volumes_select_value_flags.csv`. Nothing is omitted.

Contrast the merge's own doubling of one-side values (Bauernfeind left-only insula, Stephan
vestibular), which is flagged `estimated_bilateral_from_unilateral`. Same arithmetic, different
author. See README__merging.md "Hemispheres".

## Note
Snapshot corrected against the printed Table 1 text and page render on PDF p. 5
by Codex on 2026-11-27.
The redundant normalized CSV snapshot was removed. Run
`Rscript --vanilla deSousa_etal_2013/deSousa_etal_2013_Table1.R` from the
repository root. Human visual signoff remains pending. This item is used in
`__merging_volumes` (Tier 2, averaged with the Stephan-collection LGN).
