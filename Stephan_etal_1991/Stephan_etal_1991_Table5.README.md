# Stephan_etal_1991_Table5 — prepared source-backed item

Stephan, H., Baron, G., & Frahm, H. D. (1991). *Insectivora* (Vol. 1). Springer. https://doi.org/10.1007/978-1-4613-9124-1

Source: Table 5, printed 405–409 (extract PDF pages11–15). The held source is a 178-page tables/atlas extract starting printed395. Methods pages12–24 and the full bibliography are not held. The second available PDF has identical bytes and is not independent confirmation. Registry year stays1991 and the existing book DOI stays unchanged.

## Source → frozen evidence → analysis

An AI assistant transcribed the original scanned pages on2026-10-10, with the text layer used only as a reading aid. Actual rendered scans decided numerical glyphs, n columns, missing tokens, historical labels and footnotes. This is AI source reading, **not human visual curation**. A Python transformation read the frozen CSV and item-scoped context to generate the supplied analysis CSV preview; exhaustive numeric/missingness/schema/static checks were performed privately. No independent source is asserted.

The reader `Stephan_etal_1991_Table5.R` reads `Stephan_etal_1991_Table5_snapshot.csv` and `reference_tables/Stephan_etal_1991_Table5_context.csv`, performs every downstream parsing/transformation, preserves the printed label separately from its carried taxon block, and writes the analysis CSV plus a registry-named TSV when later executed in an authorised local repository. The supplied CSV is a Python-generated preview, not proof of R execution. Snapshot_record is a one-based CSV logical record index (embedded line wraps are inside a cell).

## What is retained

The caption says 53 species, not 53 records or animals. Every printed numerical subrow is retained: component/cohort summaries, author-pooled estimates, grand means, sex-specific summaries, between-sex median standards, definite-adult subsets, preserved-material rows, and inferred/estimated entries. Separate n_BoW/n_BrW and separate reported CV percentages stay separate. Unequal n is not repaired to paired samples. Printed n=0 means no measurement cases, not zero mass. Blank mass or CV stays missing. Printed pooled values and n (including Erinaceus 849 g/3367 mg, n=35/22) are not recomputed from other rows. Body g and brain mg already match project units: there is no ×1000 conversion.

The snapshot retains exact source text and line wraps. For the two Talpa component lines the source fragments are line-aligned as printed; context lists the shared block while the specific key-to-value allocation stays unresolved. Source-as-published is evidence; Reference_keys is the join-ready interpretation. Split Reference_keys on `; ` and join `ref_key` in this item's references CSV. Only keys actually used by rows or their footnotes are in that lookup. The complete numbered key is part of the published table snapshot, not a invented full bibliography. Collections F=Roger Fons, H=Rainer Hutterer, S=Heinz Stephan cooperation including Georg Baron (B): S/B is not proof of independent duplicate cohorts.

### Footnotes and contextual observations
- a: statistically significant sex differences lead to a male/female MEDIAN standard, not a new individual measurement or automatic arithmetic mean.
- b: Geogale is only secondary inferred data from Rehkämper et al. (1986).
- c: Hylomys prints estimated adult 57 g/1200 mg. The actual juvenile 31.4 g/957 mg used for brain composition belongs only in the separate contextual observations, not as another Table5 mass row. Cranial-capacity n=7 is not either printed weight n. Adult estimates must not promote the juvenile composition to adult/primary.
- d: the second Ruwenzorisorex line is uncertain determination, formerly Sylvisorex (lunaris?) in Fons et al. (1984). Preserve the uncertainty; do not reidentify.

### Typography
CSV cannot represent font weight. Explicit `**a)**` through `**d)**` encode the visibly bold footnote markers; these marks are retained in Source_as_published and separately extracted in context. Numeric type did not show a distinct bold standard selection in the held scans, including a higher-resolution check of printed405. Bold_numeric_evidence therefore remains unestablished and no numerical standard is chosen from row position, arithmetic, or matching another table. Resolve numeric typography before any standard-value selection.

## Join-ready interpretation and restrictions

Join the context and value gates using Row_ID. The definitions CSV has the fixed ten-column project schema, covers every analysis column, and records observation, unit, missingness and method limitations. Metadata Measure cells are blank. Printed historical taxonomy stays intact; accepted names await the Stephan collection-scoped key. No shared key or global map was edited. The row/value gates are deliberately FALSE throughout. A summary/CV/median/pooled value is not an independent new trait observation; collection-origin claims do not establish method comparability, specimen independence, or owner ingestion permission.

## Status and next local work

Prepared source/Python/static checks only. **R/Rscript unavailable: no R parse, clean-session execution, canonical audit/dry-run/build/validation, or FINISHED claim.** No public TSV is delivered and no shared scientific file upload or registry/merge change was attempted. Human_visual_curation remains blank and does not clear previous human evidence.

After owner review, stage this item in a complete private local repository with R and readxl. Execute the exact item script, not a folder call assumed to run both items: the canonical wrapper may select only the first reader. Confirm fresh exact Item name / Item encoded, compare numerical values (250 and250.0 equivalent) and missingness against the preview, compare printed source strings strictly, then run item-specific canonical validation. The R reader resolves source-frame ofile/file before --file fallback and qualifies utils I/O for the base-environment runner. Shared originals, registry, keys, merges, old handoffs and portable workflow were left unchanged. Any owner-paste proposal is separate and cannot clear protected/generated/human cells.
