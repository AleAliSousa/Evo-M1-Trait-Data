# Isler & van Schaik 2012 — supplementary data workbook

Isler K, van Schaik CP (2012). *Allomaternal care, life history and brain size evolution in mammals.* Journal of Human Evolution 63:52–63. DOI: 10.1016/j.jhevol.2012.03.009.

## Source and build

The journal file `1-s2.0-S0047248412000577-mmc2.xls` is born-digital evidence. Its item-named `_snapshot.xls` is a byte-identical copy, not a resaved workbook. Sheet1 has a title row, a two-level header, and **445 species × 25 published columns**. Sheet2 and Sheet3 are empty. The build reads positions to preserve the male/others subheaders beneath provisioning and carrying.

The existing registry authoritatively names the item `Isler_vanSchaik_2012_1-s2.0-S0047248412000577-mmc2.xls`; that somewhat unusual name is preserved. Its `.R` reader writes the analysis CSV and the DOI-encoded public TSV. It then invokes `Isler_vanSchaik_2012_build_references.py` to enrich the data and rebuild the item-scoped citation links from the frozen source-list and bibliography snapshots. The public TSV is written after that enrichment. The original underscore-delimited species name and Excel row number remain available on every row. Shared-resolver taxonomy is recorded separately; unmatched names remain unresolved.

## Data role and units

**Secondary compilation. No value is eligible for the primary-only pool.** The source column explicitly says `Brain size [g or cc]`. The build retains the numeric value, original numeric lexeme and mixed-unit label, and records `unresolved_per_row`; it does not manufacture weighed mass, tissue volume, or a conversion factor. Body mass is in g. Published gestation/weaning days, reproduction/lifespan years, helping scores and categorical ecology codes retain their units. PCA columns are derived metadata, not fresh measurements. The authors prefer sex-specific female values when available, but supply no per-row sex field; that blanket policy is not promoted into a claim that every row is female.

## What the references establish

Main Methods/Data points to **Isler & van Schaik 2009a**, *The expensive brain: a framework for explaining evolutionary changes in brain size*, JHE 57:392–400, DOI 10.1016/j.jhevol.2009.04.009, for the brain/body/life-history compilation. The workbook supplies **no species-specific brain-size references**. The 2009a citation is resolved, but its original per-species brain lineage remains open. The 2009a paper's indexed methods also describe a compilation; citing it cannot turn these rows into original experimental measurements.

Supplementary Information **section 1.3** is specifically a source list for social behavior, breeding system, ecology and life history. It must not be repurposed as a brain-reference column. The build resolves all **105 item-cited keys** (including the separate 2009a brain/body key) to full local bibliography citations or an explicit collection reference, and creates **12,092 links**. Most links represent *candidate sources within an explicitly published scope*, not a statement that each work independently measured every variable. Numbered species links are expanded against the workbook's `Species number`; restricted ranges such as 419–424 and 431–436 are respected. Multi-work cells are kept as multiple reference links, never duplicated observations. The original source block, raw citation and locator accompany each link.

`reference_tables/*_references.csv` begins with the house columns `ref_key,cited_in_column,citation,note` and also records stable cited-work IDs, type/level, resolution status and evidence. `*_value_reference_links.csv` is the authoritative many-to-many link table. `*_source_scope_reference_links.csv` preserves the source statements. An empty-header `*_primary_references.csv` is intentional: no experimental primary is established merely by matching author and year. Journal-article primary status stays unverified until the cited source is inspected. There are zero unresolved bibliography aliases, but **445 brain-source primary chains remain unresolved**.

The reference lists are separately built as their two existing registered items; see their READMEs. The full bibliography contains 143 entries, but only the works actually linked to this dataset occur in the dataset's item-scoped lookup.

## Checks and remaining work

The reader checks 445 unique published names, species numbers exactly 1–445, and a nonmissing size value on every row. Citation foreign keys all resolve; no scope link is eligible for primary-only pooling. Original values and row order were reconciled independently against the XLS. There is no published additive table total. Categorical 0, 0.5 and 1 scores are retained without replacing missing values by zero.

The owner supplied the **2009a SOM** on 2026-10-29; it is now in `Isler_vanSchaik_2009`. It gives broad source lists and compilation policies, but no per-species brain/body values or source map. It explicitly describes a mixture of endocranial volumes (approximately two thirds) and fresh-brain masses (one third). These proportions and order-level tendencies do not determine any particular row's type. Exact per-species source attribution therefore remains open after retrieving the SOM.

A report-only candidate search is now runnable in the restricted repository at `restricted_checks/Isler_vanSchaik_2012/comparison`. It compares this available 445-species workbook with source-level brain/body records, preserves physical bases and raw units, retains later reprints as such, tests the Mace correction as a hypothesis, and maintains an evidence-review queue. It also uses the 2006 appendix's explicit skull-capacity method statements. Numerical agreement does not assign original source, specimen identity or measurement type, and this check makes no public data changes.

## Extraction and build record

Built by Codex on 2026-10-29 using readxl for the untouched XLS and pdfplumber for the accompanying reference PDF. The source-list page's two columns and a wrapped citation were checked visually; the bibliography uses a reproducible hanging-indent extraction. The R readers ran from clean sessions. Registry filenames were read from the live workbook by item name; metadata-update rows are supplied separately. No shared registry, primary merge, or deployment was overwritten.
