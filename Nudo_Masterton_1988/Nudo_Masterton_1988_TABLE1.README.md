# Nudo and Masterton 1988 — TABLE 1: sampling roster
Nudo, R. J., & Masterton, R. B. (1988). Descending pathways to the spinal cord: A comparative study of 22 mammals. *Journal of Comparative Neurology, 277*, 53–79. https://doi.org/10.1002/cne.902770105

Exact registered item: `Nudo_Masterton_1988_TABLE1`.

## Source → Snapshot → Data readable
Printed p. **57**, **TABLE 1. Species and Genera Represented**. The three-column CSV snapshot retains the caption, original headers, all 22 rows in order, printed hyphens and abbreviations, and genus-only `Rattus`. There are no printed grouping rows or additional blank scientific labels to invent. OCR Latin-name errors were resolved against the image, including `Didelphis virginiana`, `E. albiventris`, `Citellus tridecemlineatus` and `Callithrix jacchus`. The armadillo label actually prints **`Dasypus novemcictus`** (without the expected n before ct); the source spelling is retained, not silently normalized to `novemcinctus`. Historical labels and abbreviated genera are likewise not replaced by accepted modern names.

The preview has **22 roster entries and 53 accepted subjects**. `n_individuals` is sampling metadata. Every design/sample count has dictionary `role=info` and blank `Measure`; there are **zero neuron/tract trait variables**. Data origin is primary sampling metadata, not a quantitative M1-vs-brainstem contrast or gap-filled neuron quantity.

## Methods context (p. 55)
94 animals were attempted; 41 were excluded and **53 retained**. The 22 species represent 19 genera, 14 families, eight orders and two subclasses. 15 species were selected for successive kinship and seven for convergent systems. Least shrew and rock hyrax were excluded in 1988 and must not enter the accepted Table 1 roster. Repeated `study_accepted_individuals` is context: do not sum it per row or add 94 to an accepted corpus. The 1990 paper uses its own different accepted cohort.

Table 2 is a vertebrate-class presence/absence compilation, **not built here** and not a source of quantitative neuron counts. Retain Table 1 as sample metadata and keep it out of cell-count or tract-quantity merges. Proposed existing-row descriptive corrections remain owner decisions.

## Reader and release state
Transcribed by **Microsoft Copilot AI assistant** on **2026-10-10**, America/Los_Angeles (Pacific), from the held source PDF. Layout OCR was used as a finding aid; the relevant PDF pages were rendered and visually checked by the AI assistant. **Human visual curation: NOT PERFORMED.** This is not a human RA check and source legibility is not a quality rating.

**PREPARED — NOT FINISHED.** The analysis CSV is a Python-generated preview from the frozen source, not an executed R build. Rscript is unavailable. Canonical `audit_dataset_item`, dry-run `build_dataset_item`, actual build and `validate_dataset_item` are all **NOT RUN**. Python source/preview/schema/hash checks do not discharge the R gate.

## Frozen-source build
The `.R` reads the frozen snapshot and item-scoped context (and quantity map where supplied); it does not regenerate the snapshot or contain the numeric observations. Names and files are derived from its own basename. The locator is file-first and accepts its own `source`/`sys.source` frame or own `--file`, never the caller driver's filename. CSV reading/writing uses `utils::` for the canonical builder's `baseenv()` execution.

## Public boundary and gates
No public TSV or private candidate TSV is supplied. No source PDF, visual image, private QA report, taxonomy-key change, merge or registry edit is part of this package. These are already-registered items: correct only the existing descriptive row after owner review, not a second row. Public filenames must be resolved afresh by exact `Item name` from authoritative `__ReadMe.xlsx`; no invented or cached DOI fallback. Future export requires a clean R run, canonical audit/dry-run/build/validation, human source review and scientific disposition, plus owner-controlled `EVOM1_SPINAL_NUDO_RELEASE=OWNER_VERIFIED_R_SOURCE_SCHEMA_AND_SCIENTIFIC_GATES`. The gate is not set here. It must not be enabled merely to make a validation check pass. Only a mounted repository-level `__Public/comparative-data` can receive a later TSV. No orphan paper-folder TSV.

Suggested future sequence after installing this package in its matching paper folder:
```r
source("_tools/dataset_builder/load_dataset_builder.R")
audit_dataset_item(item_dir)
build_dataset_item(item_dir, item_name, dry_run = TRUE)
# Clean local source()/sys.source() parity and human/source/scientific approval first.
# Only after all owner release gates may a public build be attempted:
build_dataset_item(item_dir, item_name, dry_run = FALSE)
# validate_dataset_item is called by the canonical build and must pass all invariants.
```
With publication withheld, TSV validation is expected not to pass; do not claim FINISHED.

No accepted-taxonomy remapping was applied. Any future mapping must use an existing collection-specific species key while retaining the exact printed labels. Related Nudo/Masterton papers share an experimental lineage: do not assume independent cohorts or assume the same individuals without a specimen crosswalk. Secondary citations describing methods are not new observations and are not ingested as additional data.
