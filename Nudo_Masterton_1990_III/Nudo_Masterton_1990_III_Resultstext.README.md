# Nudo and Masterton 1990 III — bounded Results text
Nudo, R. J., & Masterton, R. B. (1990). Descending pathways to the spinal cord, III: Sites of origin of the corticospinal tract. *Journal of Comparative Neurology, 296*, 559–583. https://doi.org/10.1002/cne.902960405

Exact registered item (case-sensitive): `Nudo_Masterton_1990_III_ResultsText`.

## Source → Constructed TEXT snapshot → Preview
This is a **constructed text snapshot**, not a published data table or a figure digitization. It holds **36 facts** from quantitative Results paragraphs at printed pp. **567, 569, 570–571**: total CST-origin cortical area, Region A and Region B summaries and named extrema. Short source excerpts, original numeric literals, printed units and source criteria are retained before cleaning. Page-spanning Region B prose is explicitly located. A shared minimum is represented once for each of its two named taxa and preserves the shared quoted fragment; these are not two independent animal measurements. The item is deliberately bounded, not a complete 22-species matrix. Region C/C′ quantitative paragraphs and every figure are **not extracted**.

## Observation and methods limits
The Methods (p. 560) reports **103 attempted adults, 56 accepted individuals, 22 species and 20 genera**, 14 families, seven orders and two subclasses. 26 incomplete-hemisection individuals were excluded (including six individuals in rock hyrax and armadillo), as were 21 with possible dorsal-column HRP intrusion. Rock hyrax mentioned later is not an accepted measurement cohort member. Methods' seven orders conflicts with Results' eight: both statements are retained without reconciliation. The 1988 53-animal roster is not reused as the 1990 denominator.

Raw HRP was placed at a C1–C2 hemisection; after three days/72 hours and TMB processing, systematic sections were plotted and soma profiles counted. Counts were expanded for sampling and corrected using the Methods formula `C=t/[t+d(1-e)]` (Abercrombie-type correction). They are **corrected HRP-labeled soma-profile estimates**, not all neurons, a census of the unlabeled CST population, or axon/synapse counts. Surface density means cells per **mm²**, never mm³. Dominant hemisphere is contralateral in typical species and ipsilateral in mole and three hedgehogs. No doubling or inference of exact non-dominant projection fractions: hemisection depth and HRP spread were uncontrolled.

`n_taxa` and its qualifier are separate from `n_individuals`. A multispecies summary is not an individual or a species mean. Named species extrema are selected facts, not complete genus means; their per-fact animal denominators are **unknown**. Repeated 56-animal study context is not additional sampling.

## Scientific holds — preserve, never repair
- **Every ± term:** statistic undefined in the checked Methods/Results; keep `uncertainty_as_printed` and HOLD, never label SD or SEM from its magnitude.
- **Region B p. 570 really prints `430 ± 71 cells per mm²` and `2.5 ± 8.6 mm²`.** Rendered-page verification confirms the OCR literals; the apparent contradictions are source-level, not a license to silently change them to 43.0 or 25. The raw means remain with `HOLD_PRINTED_REGION_B_INTERNAL_CONFLICT`.
- **Absolute-area extrema print reciprocal units:** Region A `912/mm²`, `0.9/mm²`; Region B `159/mm²`, `0.4/mm²`. Their literals are retained in `ambiguous_literal_value`, with canonical `area_mm2` blank and `HOLD_PRINTED_AREA_UNIT_CONFLICT`. No correction to mm² is applied without external source clarification.
- Censored phrases `less than 5%` and `over 25%` retain `<`/`>` and their bounds separately; numeric trait columns remain blank for censored rows. No threshold imputation, recomputed counts or derived areas.
- Region A is **not M1**: it includes frontal 6/4, parietal 3/1/2/5 and portions of 23/24 in primates. Region B is loosely SII and broader. Primate Region C is lateral Area 6; Glires C′ is different, not silently homologized. Anatomical labels remain source-operational, never silently mapped to canonical M1.

All rows remain `HOLD_SOURCE_OPERATIONAL_CST_NOT_M1` for merge/public release. Printed relative areas are retained as reported source facts, not treated as recomputed raw structure counts; source criterion distinguishes the 10.4% ratio to average neocortical area from a mean of individual percentages. Dictionary primary measurement roles indicate source origin, not permission to merge. Six sparse value columns represent source-reported surface area, percentages, corrected labeled-cell estimates and surface density; reference-only reciprocal-unit values are metadata.

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
