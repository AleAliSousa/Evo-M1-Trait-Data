# Mooney_etal_2012_Text — selected prose observations

**Stage: PREPARED / R_PENDING.** Analysis CSV prepared with an independent Python rebuild. Rscript is unavailable in this environment: no R execution, clean R build, dataset-builder dry run or validation has occurred. No public TSV is supplied or authorized by this delivery. All rows are **SECONDARY**, with `merge_eligible = FALSE`; do not add this review item to any primary-data merge.

## Source → frozen snapshot

Mooney, T. A., Yamato, M., & Branstetter, B. K. (2012). *Hearing in Cetaceans: From Natural History to Experimental Biology*. Advances in Marine Biology, 63, 197–246. https://doi.org/10.1016/B978-0-12-394282-1.00004-1

Held source: `mooney_2012.pdf`, SHA-256 `04803eb03508006c0d60be1b9e4da09abb739c5d39a1189ca12f9e8012bc05b3`. The Microsoft Copilot AI assistant read the actual PDF using installed pypdf, captured selected values with source-anchored regular expressions, and visually inspected original-page renders made with installed pypdfium2 on 2026-10-10. The extraction/check scripts and page images remain in private session audit material; they are not public build dependencies. No packages were installed. This is AI verification, **not human visual curation**.

`Mooney_etal_2012_Text_snapshot.csv` is a **constructed text snapshot**, not a published table. It freezes printed literals, sentence locators, page/section, qualifiers, citation keys and necessary interpretive context. Blank printed-unit/scientific-name cells are meaningful. The reader R script reads this separate frozen file and never regenerates it. Scope is deliberately bounded, not a book transcription or figure digitization:

- Section 4.1, printed p.208 / PDF p.12: later/earlier killer-whale high-frequency limits (120 and 32 kHz); neonate Risso’s dolphin high-frequency limit (150 kHz) and lowest threshold (49.5 dB at 90 kHz).
- Section 5.7, printed p.222 / PDF p.26: bottlenose dolphin MAA 0.9 horizontal and 0.7 vertical; receiving 3-dB beam widths at 30/60/120 kHz, horizontal 59.1°/32.0°/13.7° and vertical 30.4°/22.7°/17.0°.
- Section 8, printed p.230 / PDF p.34: blue-whale recorded vocalization down to 12 Hz; North Atlantic right-whale (*Eubalaena glacialis*) **approximately** 10 Hz to 22 kHz anatomical prediction.
- Method/unit context only: Figure 4.2 on p.204, relevant Table 4.1 method labels, pp.205 and 209–210, and pressure-unit distinction on p.228. The existing Table4.1 files are not changed.

## Data readable → transformations

The analysis CSV has **15 long-form observations, 32 columns**, ordered by source page/passage; rows are not 15 species or independent animals. `record_id` joins context to observations. `value_as_published` retains precision, while `value` converts frequency-valued observations kHz × 1000 to Hz. `frequency_Hz` similarly converts the test frequency; dB and angular values are not converted. No means, range interpolations, plot digitizations or inferred durations were added.

The classes distinguish measured hearing limits, measured threshold, measured spatial acuity, receiving beam widths, recorded vocalization frequency and anatomical hearing prediction. `measured_hearing` is false for the last three, and **every** class is excluded from primary merging. The two right-whale rows are linked endpoints of one approximate prediction, not independent hearing tests. Risso rows describe the same neonate; killer rows are different literature versions/studies, not a species mean. The 120-kHz prose endpoint cannot be assigned to behaviour versus AEP or an individual from the selected passage; this ambiguity is explicitly retained. Sample size, stimulus duration and endpoint response/dB criteria are labelled as not supplied where unavailable, rather than guessed.

### Critical units and source versions

- Figure 4.2’s y-axis visibly reads **SPL (dB re:1μPa)**, supporting the 49.5-dB Risso threshold’s underwater pressure reference. pypdf text extraction renders μ as `m`; it must not be interpreted as millipascal. This is **not** air 20 μPa, and **not** sound exposure μPa² s. The Greek μ and superscript ² on p.228 were visually checked; no exposure values were extracted.
- The MAA sentence actually prints **0.9 and 0.7 without degree symbols**. Snapshot unit cells remain blank. `value_unit = degree` is an explicit angular-context assignment, supported by the adjacent degree-labelled angular comparison, not a claim that the source prints 0.9°/0.7°.
- Receiving beam widths are a **3-dB directivity measure** with echolocation relevance, not standard MAA/spatial acuity. Degree symbols for all six were visually verified despite text-layer `/C14` glyphs.
- Killer-whale text says 120 versus 32 kHz; Table4.1 instead prints 100 and 31 kHz. The prose values are preserved as their own version and unspecified endpoint criterion; do not silently reconcile them with the existing table.
- Blue-whale 12 Hz is **sound production**, not a hearing audiogram or low-frequency hearing limit. Right-whale endpoints are **anatomical predictions from basilar membranes**, not behavioural or AEP limits.
- The registry’s existing ITD ms/μs flag is outside this extraction. No ITD datum was built or corrected.

## Variables, species and references

`reference_tables/Mooney_etal_2012_Text_definitions.csv` uses the fixed ten columns `Code, Definition, Structure, Measure, Stat, role, taxon, Reference, Note, Source Note`; all analysis columns are covered and `Reference` is this exact item name. Metadata have no measured `Measure`; method rows explain observation level and units.

Printed common names remain unchanged. Only the selected right-whale sentence prints a scientific name; all other `scientific_name_as_published` cells remain blank. No inline common-to-binomial canonicalization or shared species-key edit was made. Any future accepted-name mapping must use the appropriate collection-scoped central key after owner review, preserving these printed names.

`reference` contains the passage’s author/year keys in join-ready parenthetical form. `reference_tables/Mooney_etal_2012_Text_references.csv` includes **only seven cited works used by these observations**, with exact matching `ref_key`; bibliography spelling is preserved, joining layout-only line wraps. Split future multi-reference cells on `; ` and join on `ref_key`. The primary works themselves have not been ingested or reverified. The context table binds `applies_to_record` (split on `; `) to `record_id`.

## Checks and pending online-database step

Independent Python checks read the original PDF again, compare the captured printed numbers and frequency/plane pairing to the frozen source, and rebuild the analysis CSV from the snapshot. Numeric conversions, pressure-reference class, approximation flags, reference joins, dictionary schema/coverage, names, secondary gates and preservation hashes are checked in executable code. Zero mismatches refers to these **Python/source checks only**, not R output parity or the project validator. AI inspected PDF pages 8, 12, 26, 32 and 34; the human-curation registry cell remains blank.

A fresh full live registry read on 2026-10-10 matched exactly `Mooney_etal_2012_Text`, confirmed SECONDARY and a blank Human visual curation cell. The retrieval snapshot is not continuing code authority. The R script derives `folder`, `base` and `item_name` from itself. It resolves the innermost `source()`/`sys.source()` frame before `--file=` (which can name an Rscript wrapper), then falls back to direct Rscript or RStudio. CSV I/O uses explicit `utils::` namespaces to support the canonical builder’s `baseenv()`-parent execution environment. These call-path fixes were checked statically only; runtime verification remains R_PENDING. It rereads mounted `__ReadMe.xlsx` by **Item name**, obtains `item_encoded` without a hardcoded DOI filename, and defaults to withholding public output.

Owner next steps, on a current repository with R and project dependencies:

1. Re-read the current registry and confirm one exact item row, no duplicate name, SECONDARY role and valid current encoded stem. Apply only owner-approved descriptive updates, never generated columns.
2. Run `Rscript Mooney_etal_2012_Text.R` in a clean R session with public export disabled; compare its analysis CSV to the prepared CSV and inspect warnings/errors. R/registry/dataset-builder validation remains pending here.
3. Use the canonical dataset-builder audit/dry-run/validation workflow. An initial missing-TSV invariant is expected while public output is withheld; resolve any other findings first. Human visual curation is a separate owner action.
4. Only after the owner confirms the R checks and current registry gate, set `EVOM1_TEXT_PUBLIC_EXPORT=YES_AFTER_VALIDATION` for the controlled export, then perform final full dataset-builder validation including TSV-name/content invariants before publication. The script writes only to the existing repo-level `__Public/comparative-data/`, never the paper folder. Do not label FINISHED before this succeeds.

No registry, shared key, root documentation, merges, GitHub or shared/public source folder was modified by this prepared artifact delivery.
