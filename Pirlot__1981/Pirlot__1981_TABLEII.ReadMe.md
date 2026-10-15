# Pirlot__1981_TABLEII

## Status: XLSX reader repair, NOT FINISHED

The bounded reader repair of 2026-10-14 switches the input to the existing manual XLSX snapshot and makes the single owner-authorized correction and number checks explicit in R. The manual XLSX, analysis CSV, public TSV, registry, keys and merges are unchanged by this preparation. Clean-R audit/build/validate and human visual curation remain pending; no registry invariant is claimed passed.

## Source → snapshot

Pirlot, P. (1981). A quantitative approach to the marsupial brain in an eco-ethological perspective. *Revue Canadienne de Biologie*, 40(2), 229–250. PMID:7280305 (registry `DOI (or Alt)`: `PMID%3A7280305`).

Locus: **TABLE II**, printed pp. 234–236 (PDF pages 6–8 of `pirlot_1981.pdf`, held unchanged). The printed caption reads: "This table presents the actual volumes in cubic mm for 12 brain components and their sum making up total brain for each species. The last line is the sum of RH and PY …".

Source format: library-supplied scan with an Adobe Paper Capture OCR text layer. The table pages are legible as images, but the OCR text layer is unreliable for numbers.

The reader uses the existing manual `Pirlot__1981_TABLEII_snapshot.xlsx`, Sheet1, not the normalized CSV snapshot. The XLSX is left unchanged: all three printed parts, species and higher-group header rows, 12 component rows, the printed `66.0` medulla value, total-brain line and RH + PY line remain the raw evidence. The reader transposes only the analysis view. Excel snapshot supplied/manually arranged by Alexandra de Sousa, received 2026-10-14; original transcription date not separately known; no full human-cell-review certification inferred.

The physical contract is species row 9; components rows 10–21 in printed order; total row 24 (blank label); RH + PY row 25 (multiline label and brace). Species columns are C:Q, U:AE and AI:AJ; component-label columns are A, S and AG. The item-scoped parser accepts only the printed `BO`/`Bo` and `Hi`/`HI`/`H` label variants; it does not normalize taxa or reinterpret higher-group headers.

## Snapshot → data readable

Run `Pirlot__1981_TABLEII.R` in a clean R session. It:
1. reads Sheet1 `A1:AJ25` positionally as text, validates all three panel headers/component sequences, and strictly parses 336 nonmissing component values plus both printed summary lines;
2. requires 28 unique nonblank taxon labels in panel order and preserves the original 12 component columns/units;
3. computes raw component totals and RH + PY, comparing exact integer tenths (the source's one-decimal precision), without suppressing missing values or using adaptive tolerances;
4. requires the unique exact `Didelphis marsupialis` row, raw O = 66.0, raw total 5985.0 and other-11 sum 5919.0; computes 6485.0 − 5919.0 = 566.0, asserts that candidate, and applies only the owner's approved `O_mm3` correction;
5. retains `O_mm3_raw`, sets `O_mm3_corrected`, recomputes the total after correction, and retains printed/calculated summaries and before/after match flags as metadata; warns about unresolved total or RH + PY mismatches without balancing any values;
6. derives `source` and filenames from its own saved filename, writes `Pirlot__1981_TABLEII.csv`, and writes `<Item encoded>.tsv` (registry: `PMID%3A7280305_TABLEII`) to `__Public/comparative-data/` if the existing exact-name registry lookup succeeds.

Printed/calculated summaries, raw medulla provenance and check flags have blank `Measure` fields and metadata roles in the definitions. They must not be ingested as independent primary variables alongside the 12 components. No other component is corrected and no units are converted.

Method (pp. 232–233): component volumes come from Nissl-stained serial sections (10–40 µm). Neuronal fields were photographed, cut out of the prints and weighed; the author preferred this to an electronic area analyser. Between 115 and 130 sections were used per brain, following Stephan, Bauchot & Andy (1970). Appendix B of the paper discusses problems in delimiting some components.

Component codes (author's list, p. 233): BO bulbus olfactorius; N neocortex; RH rhinencephalon; PY pyriform cortex; S septum; Di diencephalon; STR striatum; Hi hippocampus; M mesencephalon; C cerebellum; O medulla oblongata; Sz schizocortex.

Units: mm³ (absolute volumes).

Observation level: **one row per taxon**. The printed column labels are genus-level or collapsed versions of the Table I specimen names (e.g. `Philander`, `Didelphis aurita`), and each column corresponds to the sectioned (`S`) specimen(s) in `Pirlot__1981_TABLEI`. [TO CHECK: whether any column pools more than one sectioned specimen. Table I lists one `S` specimen per taxon in most cases.] Species keys need resolving: see the note in `reference_tables/Pirlot__1981_TABLEII_definitions.csv`.

Data role: **primary** (the author's own volumetric measurements).

## Known limitations

- **Unresolved printed-total mismatches:** *Caluromys* has 4295.1 printed vs 4294.1 calculated (calculated minus printed −1.0); *Schoinobates* 4604.3 vs 4604.7 (+0.4); *Vombatus* 52645.7 vs 52615.7 (−30.0). All printed totals and all component values remain unchanged; the reader retains false match flags and warns. It does not decide which total/component is wrong or make balancing corrections.
- **One owner-authorized correction:** *Didelphis marsupialis* O (medulla), manual XLSX cell I20, remains `66.0` in the frozen source and `O_mm3_raw`. Its 12 raw components sum to 5985.0, not the printed total 6485.0 (I24). The other 11 sum to 5919.0, so the total implies 566.0. The owner explicitly authorizes that one corrected analysis value (`O_mm3 = 566.0`, already present in the earlier analysis CSV), visibly flagged by `O_mm3_corrected`. The corrected components sum to 6485.0; RH + PY is independently checked as 805.6 + 378.0 = 1183.6 (I25). This is an owner-confirmed/sum-inferred correction, not evidence from a new independent source or a formal published erratum, and is a specific exception to the default keep-print publication-error rule.
- **RH vs PY:** the paper treats RH and PY separately but sums them for comparison with bat studies, where PY is not separated (caption).
- **Duplicate specimen:** the *Didelphis marsupialis* specimen (P313) is the same animal used as the opossum comparison in `Pirlot_Nelson_1978_TABLE3`. Its values are not independent observations.

## QA and online database

Expected arithmetic: 24 of 28 raw component totals match the printed total; after the one approved correction, 25 match and the three unresolved mismatches above remain. All 28 RH + PY sums match. These checks are implemented inside the R reader, not supplied as hardcoded measurement arrays.

R/Rscript is unavailable in the preparation environment: no R parse, execution, canonical build/validate or human visual curation is claimed. The authoritative discrepancy record is `reference_tables/Pirlot__1981_errata.csv`; its generated README/definitions renderings are pending a real R run. The factual notes here are not manually fabricated generated errata blocks.

Expected analysis rows: **28**. Definitions: `reference_tables/Pirlot__1981_TABLEII_definitions.csv`. Registry public TSV: `PMID%3A7280305_TABLEII.tsv`.

Pending: clean R build/validate; human visual curation; species-key resolution.
