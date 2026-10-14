# Heffner_Heffner_1992_c_ResultsText

**Status: PREPARED / R_PENDING — not FINISHED, not R-validated, not publicly exported.**

## Source → snapshot
Heffner, R. S., & Heffner, H. E. (1992). Hearing and sound localization in blind mole rats (Spalax ehrenbergi). Hearing Research, 62(2), 206–216. https://doi.org/10.1016/0378-5955(92)90188-S

Published 1992; Hearing Research 62(2), 206-216; DOI 10.1016/0378-5955(92)90188-S.

Actual PDF: `heffner_heffner_1992_scan.pdf`, SHA-256 `e8432797086c3fd80f5f76e905d6dcf906d11745e57c83b9e0d0748d25d24d6c`. Materialized from `https://alleninstitute.sharepoint.com/sites/MammalianM1/Shared%20Documents/General/Species/Evo-M1-Trait-Data/Heffner_Heffner_1992_c/heffner_heffner_1992_scan.pdf`; the source download manifest supplies its file ID and URL. The registry item is resolved by exact Item name, never row position. Cached encoded stem `10.1016%2F0378-5955(92)90188-S_ResultsText` is descriptive only; current live validation is still pending.

Reader: **Microsoft Copilot AI assistant**, 2026-10-10, America/Los_Angeles (Pacific). This is AI source reading and visual checking, **not human visual curation**. Human visual curation stays blank; a human has not reviewed these new products. Reader identity is corrected consistently in this README, the result manifest, constructed context metadata and derived analysis. Only the recorder identity label was revised; source snapshots and every scientific/context value remain unchanged.

`Heffner_Heffner_1992_c_ResultsText_snapshot.csv` is a newly constructed text snapshot, transcribed by the AI assistant from the scan's Results pp. 209–210 on 2026-10-10. Exact loci accompany every row; the abstract confirms the four audiogram summaries. OCR/text aided location only; scan images confirmed numerical glyphs and protocol. `29°` and `180°` retain degree glyphs in the frozen Value field. The categorical failure is source wording, not a numerical trait. All values were frozen before reformatting.

## Snapshot → data readable
- `Heffner_Heffner_1992_c_ResultsText.R` is self-locating and reads the snapshot, then joins immutable `Heffner_Heffner_1992_c_ResultsText_context.csv` by exact `Trait`; no source values or contextual sample/criterion data are hardcoded in the reformat script.
- Context is constructed source evidence from the paper's methods/results, with separate exact loci. It contains sample sizes, durations, criteria, approximation flags and explicit merge gates. Do not overwrite it during a build.
- `Heffner_Heffner_1992_c_ResultsText.csv` is a **Python-prepared preview** (7 rows, 40 columns), not an R-generated artifact. Python re-read both frozen inputs and checked every numerical transformation. The R source remains unexecuted.
- Long format preserves source order and printed scientific/common names. Numeric parsing removes a degree glyph and normalizes minus signs; original value string remains. Source `value`/`unit` are preserved. Separate `frequency_Hz` is computed only for Hz/kHz observations (kHz × 1000), and `threshold_dB_SPL` only for dB SPL observations. Linked threshold frequencies/intervals are populated only where printed; overall ultrasonic threshold-range endpoints keep these frequency links blank. The protocol tested-band metadata must not be mistaken for the frequency assigned to an individual threshold. A blank numeric cell for a categorical result is intentional; blank inapplicable metadata are not extraction artifacts.
- Every analysis column and every measurement key is classified in `reference_tables/Heffner_Heffner_1992_c_ResultsText_definitions.csv`, fixed ten-column schema. Metadata carry empty Measure fields; measure-specific keys carry unit/method-aware classes. No new central standardized-term mapping is asserted.
- `reference_tables/Heffner_Heffner_1992_c_ResultsText_references.csv` is item-scoped: join `source_ref_key` to `ref_key`; not the whole bibliography.

## Interpretation and exclusions
- Primary study of two blind mole rats, one male and one female. Printed species `Spalax ehrenbergi` is retained without mapping to a modern taxon or splitting a species complex.
- The four audiogram summaries are **54 Hz and 5.9 kHz at 60 dB SPL**, best frequency **1 kHz**, lowest threshold **32 dB SPL**. These repeat the already-built registered `Heffner_Heffner_1992_c_TABLEI` blind-mole-rat row. They stay primary by origin but carry overlap and **deduplication gates**; never count text and table as independent data.
- Both animals could not localize a single **100-ms** noise burst at **180°** separation. The categorical value has no numeric magnitude: missing numeric `value` means not applicable, not zero. The 180° is the tested separation, not an extracted threshold for brief sound.
- **29°** is printed for a **train of THREE 700-ms noise bursts separated by 100 ms**. It is not a brief-sound MAA and not a single 700-ms stimulus. The source defines the acuity threshold at corrected detection performance 0.50.
- The scan also explicitly prints **average threshold 180° for a single 400-ms noise burst**, and inability to discriminate 90° above chance. This exact prose value is included; no figure digitization was needed. Do not substitute this result for the 29° long-train condition.
- Abstract's broad “0.5 s or longer” summary is not a universal performance boundary. Results and methods specify stimulus and criterion; individual A/B performance values were not reconstructed. Corrected performance is Hit rate − (False alarm rate × Hit rate), not raw percent correct.
- No extra anatomical/eye-diameter or tested-extreme values were promoted to species traits in this hearing-results item.

## Species / merge notes
No inline canonical species mapping. Proposed collection-scoped species-key additions must be reviewed centrally: retain `Spalax ehrenbergi` as variant_name for publication token `Heffner_Heffner_1992_c`; accepted name and sensory collection destination remain owner/central-key decisions. No `_keys`, merges, registry, root files or other paper folders were changed. All rows originate in the primary paper; primary status does not erase within-paper overlap or method incompatibility. No merge was run.

## QA and runtime limits
- AI scan visual checks and exact source-locus inspection completed; numeric Python preview checks completed. Private working evidence is outside the repository; no public comparison folder was added.
- `Rscript` is absent. **No R audit, dry run, build, script execution, validation, or seven-invariant pass is claimed.** No dependency installation attempted.
- Static call-path compatibility fix: this new reader checks source-frame `ofile` and `file` before command-line fallback, and uses `utils::read.csv`, `utils::write.csv` and `utils::write.table` for the builder's `new.env(parent=baseenv())` context. This fixes the identified static blockers only; actual canonical/Rscript execution remains pending.
- Canonical `_tools/dataset_builder/load_dataset_builder.R`, `audit_dataset_item.R`, `build_dataset_item.R`, and `validate_dataset_item.R` were read statically. The builder chooses the first `.R` and first CSV/README/definitions/snapshot in a paper folder, not an exact requested item. This is especially unsafe in Heffner's existing multi-item folder: do not interpret a folder-level pass as this item's validation. Shared tool fixes are outside scope and were not made.
- Shared publication not attempted in this prepared batch; older upload approvals unaffected; R and live-code checks pending. No candidate/public TSV was written, including inside this paper folder. The user authorized remaining builds; this batch's no-shared-write execution policy avoids interfering with older pending approvals. Filename conflict review, R execution, item-specific validation and human curation remain pending.

## Runtime handoff under the existing user authorization (not executed)
1. Place package contents beside the unchanged source PDF in the registered repository folder; re-read current live `__ReadMe.xlsx` and resolve exact Item name. Do not alter formula/generated columns.
2. With R and `readxl` available, run the exact `Heffner_Heffner_1992_c_ResultsText.R` from a clean session. Default behavior writes the analysis CSV only and warns that public output is withheld. Compare its cells against the delivered Python preview.
3. When shared publication is scheduled after R, live-code and conflict checks under the existing authorization, `EVOM1_ALLOW_PUBLIC_TSV=YES` permits the script's canonical `__Public/comparative-data/<fresh Item encoded>.tsv` write; an existing destination is refused, not overwritten. No fallback/alternative TSV path exists.
4. Load the canonical dataset-builder layer for the pre-build folder audit, but validate this item using **explicit** `Heffner_Heffner_1992_c_ResultsText.csv`, snapshot, README, definitions and fresh registry/TSV paths; do not use the first-file selection as evidence. R results, public export, human curation and central species keys must be reported separately before FINISHED is considered.
