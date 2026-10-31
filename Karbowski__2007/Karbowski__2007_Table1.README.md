# Karbowski__2007_Table1

## Source
Karbowski, J. (2007). Global and regional brain metabolic scaling and its
functional consequences. *BMC Biol*, 5, 18. https://doi.org/10.1186/1741-7007-5-18

Registry Item **Table 1**, printed p. 4 of the PDF. Local copy:
`Karbowski__2007/Karbowski-2007-Global and regional.pdf`.

## Why this item exists
The folder already carries the paper's supplementary Tables S1-S23 (the
compiled per-species CMRO2 / CMRglc values). Table 1 of the main paper is
the gap: it is the paper's headline result, the specific scaling exponent
of regional CMRglc against brain volume for 23 brain structures, with the
95% confidence interval, R2, p-value and the number of species in each
fit. It is the row-level summary that everything else in the paper (and
the "exponents are uniform at about -0.15" claim) rests on.

## Pipeline
Printed table -> snapshot -> analysis csv -> public TSV.

| file | role |
|---|---|
| `Karbowski__2007_Table1_snapshot.csv` | frozen source, printed layout |
| `Karbowski__2007_Table1.R` | reads the snapshot, writes CSV + public TSV |
| `Karbowski__2007_Table1.csv` | analysis rows (23 x 16) |
| `reference_tables/Karbowski__2007_Table1_definitions.csv` | data dictionary |
| `reference_tables/Karbowski__2007_Table1_references.csv` | 48 source citations |
| `__Public/comparative-data/10.1186%2F1741-7007-5-18_Table1.tsv` | public copy |

## Snapshot and reader provenance
The snapshot keeps the printed caption line, the printed header row, all
27 printed body rows in printed order (23 fitted rows plus the four
value-less group headers *Basal ganglia*, *Limbic system*, *Brain stem*,
*White matter*), the printed indentation of the sub-structure rows as two
leading spaces, the exponent and its SD together in one cell as printed
(`-0.15 ± 0.03`), the confidence interval as printed (`-0.22 to -0.08`,
including the printed `-0.00` at Mammillary body), printed trailing zeros,
and the printed footnote about the t-test.

The source is a born-digital BMC PDF with a reliable text layer. The
values were read by an AI assistant (Claude, Anthropic), 2026-10-31, from
that text layer and then checked cell by cell against a 300 dpi page image
rendered with `pdftools::pdf_convert`; the two agreed everywhere.
**Human visual curation is still pending.**

## Data role: secondary, and what that means here
`Data role` is **secondary** and stays secondary. Table 1 contains no new
measurement. Each row is an ordinary-least-squares fit over the per-species
CMRglc values that Karbowski compiled from other laboratories (the
supplementary tables) against brain volume taken from Hofman [41] and
Stephan et al [100] "or from the source" (Methods, p. 9). The exponents
must never be ingested as primary evidence, and the compiled CMRglc values
must never be re-ingested through this table: the primary reports are
named in `source_refs`.

## Per-row source references
Table 1 prints no reference keys of its own, so the provenance had to be
recovered rather than copied. Each printed structure corresponds to exactly
one supplementary table, by the structure name printed in that table's
caption (Table S3 "Visual cortex ...", S13 "Thalamus ...", and so on); the
`Hypothalamus` / `Mammillary body`, `Superior colliculus` / `Inferior
colliculus` and `Corpus callosum` / `Internal capsule` pairs are the two
printed subdivisions of S15, S22 and S23 respectively. `Cerebral cortex`
maps to S11, which is explicitly "Data for Fig. 2E in the main text" but
prints N (number of cortical areas) instead of a Reference column; per the
Methods (p. 9) that cortex average is the mean over the eight cortical
areas, so its sources are the union of S3-S10.

The build script therefore derives `source_refs` at run time from the
sibling `Karbowski__2007_TableS<N>.csv` files - the keys are never typed
into the script. The 46 distinct keys so recovered, plus the two
brain-volume keys, are resolved to verbatim bibliography entries in
`reference_tables/Karbowski__2007_Table1_references.csv`; every one of the
46 was already present, with its numbered-reference locator, in the
sibling `Karbowski__2007_TablesS1-S23_references.csv`, so no citation was
re-typed. Two keys in that set are not row-level experimental reports
(Clarke & Sokoloff 1994, a *Basic Neurochemistry* chapter, and Sokoloff
1984, a monograph); their `note` carries that over from the sibling
catalogue. Spelling variants that the supplement prints inconsistently
("Blin"/"Bline", "Nehlig"/"Nehling") and qualifier variants ("…, auditory",
"…, CA1+CA3", "…, estim.") are kept as separate `ref_key` rows because
that is how the data column prints them; they resolve to the same work.

## Table checks

Table 1 has no internal arithmetic relation - exponents and R2 are not
additive and there is no total row - so no within-table check was
invented. It does, however, carry one externally checkable column:
`Species (n)` must equal the number of distinct species in the
supplementary table the row was fitted to. That is what certifies the
structure -> supplementary-table map above, so the reader runs it into
`table_checks`, exact (tolerance 0).

Result of the recorded run (`Rscript --vanilla`, 2026-10-31):
**23 pass, 0 mismatch** - all 23 printed `Species (n)` values reproduce
exactly, including the cortex row (7) against S11 and both subdivisions of
S15, S22 and S23. No printed value was altered and no erratum is raised.

## Units and interpretation
The exponents are dimensionless slopes of log(CMRglc per unit mass) on
log(brain volume); SD and the confidence-interval bounds are in the same
units as the slope. No unit conversion applies. The exponents are
*specific* (mass-specific) exponents: Karbowski's total-metabolism
exponent of 0.86 is a different quantity and is not in this table.

## Pending
Human visual curation of all 23 x 6 printed cells against p. 4; owner
paste of `Karbowski__2007_Table1_registry_row.xlsx`.
