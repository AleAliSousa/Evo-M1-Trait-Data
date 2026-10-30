# Cerebral metabolic-rate recovery — 2026-10-23

Recovered the Kaufman and Karbowski source corrections, public table exports, primary-reference catalogs, value-to-reference links, source-aware merge, arm-ambiguity report, and independent merge validator from the older uncommitted checkout. Integrated them against `main` at `eacfad3b` and retained the newer paper-scoped species resolver. Added the missing Kaufman `Capra` key so its genus-only label continues to resolve to *Capra aegagrus hircus*.

## Superseded and retained files

- The old `cerebral_metabolic_rate_compiled.R` wrapper remains absent, following current `main`; the Python builder is the canonical entry point.
- The old `__ShinyApp/data/cerebral_metabolic_rate_long.csv` copy remains absent. Current Shiny code reads the canonical merge from `__merging_cerebral_metabolic_rate/`; the validator accepts that layout.
- Current `__ShinyApp/build_data.R` and its no-duplicate-copy policy were retained. The prior source checkout's comment-only Shiny edit was superseded.
- The four principal merge outputs were rebuilt on current `main` and are byte-identical to the recovered checkout: long, wide, unfiltered, and dedupe report.
- The restricted comparison driver was already compatible. Its three output artifacts were regenerated from the recovered provenance table in the restricted repository.

## Validation and differences from earlier results

`build_primary_reference_catalogs.py`, `build_cerebral_metabolic_rate_merge.py`, and `validate_cerebral_metabolic_rate_merge.py` completed. The validator confirms 2,161 provenance rows, 1,444 primary-pool rows, 235 merged cells across 14 species, 335 resolved primary works, 2,361 value-reference links, 44 dedupe decisions, and 77 quarantined arm groups (157 rows). No compiler averages, derived totals, estimates, or unresolved multirow arm groups enter the primary-only means.

The saved restricted findings predated this recovery: they reported 1,915 comparison groups and zero shared groups. Regeneration now finds 1,839 groups, 55 shared groups, 54 direct one-to-one pairs, and 190 review rows. The shift follows recovered reference resolution, source corrections, condition/arm classification, and conservative exclusions; the detailed records are in the restricted comparison CSVs.

## Remaining scientific uncertainties

- Resolve 77 within-primary study-arm groups before adding their 157 quarantined rows to any mean.
- Review 26 same-source value differences beyond reported precision and one many-to-one match. Shared work is counted once while disagreements remain visible.
- Investigate three Zimmer 1975 records with unresolved bibliography identity and 25 rows citing secondary sources without row-level primary lineage.
- Review the restricted audit's 10 region conflicts and two taxonomy conflicts before harmonizing those cells.

The public and restricted checkouts retain their unrelated pre-existing uncommitted changes. This recovery remains uncommitted for review.
