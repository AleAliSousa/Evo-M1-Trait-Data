# Orlin recommendations 4–9: completed source intake

Built 2026-10-26 from the local Orlin sources. Six previously unregistered papers now have publication folders, source PDFs, frozen table snapshots, reproducible R readers, analysis CSVs, DOI-coded public TSVs, definitions, provenance notes, and registry/catalog entries. Nine items contain 1,263 analysis rows; these rows are not a count of independent animals.

| Publication | Registered items | Analysis rows | Contribution |
|---|---|---:|---|
| Slomianka et al. 2013 | Table2, Table4 | 15 + 9 | Sengi hippocampal principal cells and dentate neurogenesis phenotypes; overlapping pooled/sex summaries |
| Meyer 1981 | TableI, TableII | 7 + 91 | Brain/body masses and 13 dissected brain components across seven taxa; mean ± SE |
| Stevens 2014 | DataS1 | 941 | Compiled primate delay choice and covariates; includes 96 indifference-point records |
| Nummela et al. 2013 | TableS2 | 119 | Sensory organ dimensions, ecology, and cell-level source provenance |
| West & Gundersen 1990 | Table1, Table2 | 5 + 25 | Five male human donors; five hippocampal neuron-containing reference layers |
| Slomianka & West 1989 | Table1 | 51 | Seventeen left-hemisphere structures/components in three groups of six wild mice |

## Interpretation and merge routing

These are additions to the source database and central variable catalog. The existing aggregate volume, isotropic-fractionator cell-count, and sensory-performance merges are unchanged. Source-specific mappings and eligibility decisions are needed before pooling these new measure families.

- Meyer reports **fixed tissue mass**, not volume. Preserve SE as SE. Human/sheep body masses are estimated; preparation differs across taxa. Amygdala plus pyriform cortex is a combined dissection region.
- Slomianka 2013 uses **left principal-cell counts (n=8)** and **right PCNA/DCX estimates (n=12)**. The side of the apoptotic estimates is not separately established. Pooled and sex-specific summaries overlap; neurogenesis markers are not interchangeable with total mature-neuron counts.
- Stevens is **entirely secondary**, including the behavioral records. Its ECV covariates reuse Isler et al. 2008 and should not enter a primary volume merge again. `type` is a common-name qualifier, not an observation statistic. The 941 records mix individual and aggregated source observations; preserve n, notes, and reference before any aggregation. Six of 148 source keys remain bibliographically unresolved or year-conflicted; the lookup records this explicitly.
- Nummela has **50 primary cribriform-area entries, 40 primary tympanic-area entries, and one mixed-source tympanic-area entry**. Eye data and ecological covariates are secondary. Organ dimensions are distinct from sensory thresholds. Three cited sources are supplied only as printed author/year because their full bibliography entries are absent from the supplied article.
- West & Gundersen volumes refer to **neuron-containing reference layers**, not complete hippocampal fields. Counts use stereology, not isotropic fractionation. Preserve the five donor identities, processed-tissue status, and unilateral scope; no unsupported bilateral estimate is produced.
- Slomianka & West volumes are **left-sided**. Preserve the two separate A. sylvaticus populations and overlapping layer/composite definitions. Body masses from Methods repeat across structure rows and are not new animals.

## Validation

All nine readers ran from saved source files. Repository validation: **78 PASS, 3 SKIP, no FAIL**; skips are absent errata files for items without recorded errata. Every output column has a definition, and every analysis CSV equals its public TSV after reading. Source manifests verify the frozen PDF/CSV bytes. Independent source-to-output comparisons cover **28,742 assertions**, including all extracted values, unit conversions, source keys, and per-cell provenance roles.

Seven source discrepancies/ambiguities are recorded in the publication errata files. Three wild-mouse component sums differ from printed combined volumes beyond rounding tolerance. The sengi granule-cell sampling mean exceeds its printed maximum. Nummela prints an undefined habitat code `A` for Galago senegalensis. West's density/count footnote conflicts with its column symbols. Apoptotic-cell laterality remains unresolved. Published numbers are retained, never adjusted to make checks pass. Meyer's two ratio-of-means differences are expected possibilities when the source reports means of ratios and are not labeled publication errors.

PDF transcriptions received an AI visual comparison; **human RA checks remain pending**. Stevens's untouched author CSV is marked “Not applicable: tabulated and digital already.” Numerical QA scripts and detailed results are retained under the restricted repository's `restricted_checks/orlin_next_six_2026-10-26/`.
