# Schmidt_etal_1984_text

**Status: PREPARED / R_PENDING — not FINISHED, not R-validated, not publicly exported.**

## Source → snapshot
Schmidt, S., Türke, B., & Vogler, B. (1984). Behavioural audiogram from the bat, Megaderma lyra (Geoffroy, 1810; Microchiroptera). Myotis, 21–22 (1983–1984), 62–66.

Registry citation year 1984 retained; source header Myotis 21-22, 1983-1984.

Actual PDF: `schmidt_etal_1984.pdf`, SHA-256 `f86be7df885d9f0d6b9892c07b249c68be63426e0af058b75c6a358cb1cabf3d`. Materialized from `https://alleninstitute.sharepoint.com/sites/MammalianM1/Shared%20Documents/General/Species/Evo-M1-Trait-Data/Schmidt_etal_1984/schmidt_etal_1984.pdf`; the source download manifest supplies its file ID and URL. The registry item is resolved by exact Item name, never row position. Cached encoded stem `Myotis%3A21-22%3A62-66_text` is descriptive only; current live validation is still pending.

Reader: **Microsoft Copilot AI assistant**, 2026-10-10, America/Los_Angeles (Pacific). This is AI source reading and visual checking, **not human visual curation**. Human visual curation stays blank; a human has not reviewed these new products. Reader identity is corrected consistently in this README, the result manifest, constructed context metadata and derived analysis. Only the recorder identity label was revised; source snapshots and every scientific/context value remain unchanged.

The existing `Schmidt_etal_1984_text_snapshot.csv` was frozen before this task and retained **byte-for-byte**. This task did not claim its original transcription authorship. The AI assistant rechecked its 12 values, signs, units and source meanings against the scan (printed pp. 63–64 and 66). Snapshot SHA-256: `e76496279331152d4715412c8776e1d6beebb39108821fa058766f215b61fc91`. No snapshot rewrite.

## Snapshot → data readable
- `Schmidt_etal_1984_text.R` is self-locating and reads the snapshot, then joins immutable `Schmidt_etal_1984_text_context.csv` by exact `Trait`; no source values or contextual sample/criterion data are hardcoded in the reformat script.
- Context is constructed source evidence from the paper's methods/results, with separate exact loci. It contains sample sizes, durations, criteria, approximation flags and explicit merge gates. Do not overwrite it during a build.
- `Schmidt_etal_1984_text.csv` is a **Python-prepared preview** (12 rows, 40 columns), not an R-generated artifact. Python re-read both frozen inputs and checked every numerical transformation. The R source remains unexecuted.
- Long format preserves source order and printed scientific/common names. Numeric parsing removes a degree glyph and normalizes minus signs; original value string remains. Source `value`/`unit` are preserved. Separate `frequency_Hz` is computed only for Hz/kHz observations (kHz × 1000), and `threshold_dB_SPL` only for dB SPL observations. Linked threshold frequencies/intervals are populated only where printed; overall ultrasonic threshold-range endpoints keep these frequency links blank. The protocol tested-band metadata must not be mistaken for the frequency assigned to an individual threshold. A blank numeric cell for a categorical result is intentional; blank inapplicable metadata are not extraction artifacts.
- Every analysis column and every measurement key is classified in `reference_tables/Schmidt_etal_1984_text_definitions.csv`, fixed ten-column schema. Metadata carry empty Measure fields; measure-specific keys carry unit/method-aware classes. No new central standardized-term mapping is asserted.
- `reference_tables/Schmidt_etal_1984_text_references.csv` is item-scoped: join `source_ref_key` to `ref_key`; not the whole bibliography.

## Interpretation and exclusions
- The 1–130 kHz endpoints describe the reported sensitive/tested band under two different behavioral paradigms. They are **not 60-dB SPL range limits**.
- Sonic thresholds: five bats, 75% correct from a fitted Gaussian error function, 100-ms pure-tone bursts. The reported threshold is 68 dB SPL at 1 kHz; the 16–22 kHz plateau is about **−5 dB SPL**.
- Ultrasonic thresholds: continuous tones, main curve from one animal with a separate corroborating animal; repeated incorrect responses define a session threshold and trial-count-weighted means combine days. Do not pool these as two measured animals or apply the sonic criterion.
- Overall ultrasonic −17 to −3 dB SPL is a text summary, not a bound on every threshold. The minor peak is explicitly **+2.4 dB SPL at 50 kHz**. The >90 kHz flank is a descriptive reference, not an exact hearing endpoint.
- Discussion 16 to about 100 kHz is qualitative, with no specified cutoff. Only −5 and the about-100 endpoint have explicit approximation flags.
- Full scientific name comes from the title/abstract. The results abbreviate it as M.lyra; source values and notes retain their existing provenance. No figure digitization, best-frequency inference, or threshold interpolation was done.
- The cached encoded stem `Myotis%3A21-22%3A62-66_text` is a **constructed local key, not a DOI**. Registry 1984 and the printed 1983–1984 volume span both remain visible.

## Species / merge notes
No inline canonical species mapping. Proposed collection-scoped species-key additions must be reviewed centrally: retain `Megaderma lyra` as variant_name for publication token `Schmidt_etal_1984`; accepted name and sensory collection destination remain owner/central-key decisions. No `_keys`, merges, registry, root files or other paper folders were changed. All rows originate in the primary paper; primary status does not erase within-paper overlap or method incompatibility. No merge was run.

## QA and runtime limits
- AI scan visual checks and exact source-locus inspection completed; numeric Python preview checks completed. Private working evidence is outside the repository; no public comparison folder was added.
- `Rscript` is absent. **No R audit, dry run, build, script execution, validation, or seven-invariant pass is claimed.** No dependency installation attempted.
- Static call-path compatibility fix: this new reader checks source-frame `ofile` and `file` before command-line fallback, and uses `utils::read.csv`, `utils::write.csv` and `utils::write.table` for the builder's `new.env(parent=baseenv())` context. This fixes the identified static blockers only; actual canonical/Rscript execution remains pending.
- Canonical `_tools/dataset_builder/load_dataset_builder.R`, `audit_dataset_item.R`, `build_dataset_item.R`, and `validate_dataset_item.R` were read statically. The builder chooses the first `.R` and first CSV/README/definitions/snapshot in a paper folder, not an exact requested item. This is especially unsafe in Heffner's existing multi-item folder: do not interpret a folder-level pass as this item's validation. Shared tool fixes are outside scope and were not made.
- Shared publication not attempted in this prepared batch; older upload approvals unaffected; R and live-code checks pending. No candidate/public TSV was written, including inside this paper folder. The user authorized remaining builds; this batch's no-shared-write execution policy avoids interfering with older pending approvals. Filename conflict review, R execution, item-specific validation and human curation remain pending.

## Runtime handoff under the existing user authorization (not executed)
1. Place package contents beside the unchanged source PDF in the registered repository folder; re-read current live `__ReadMe.xlsx` and resolve exact Item name. Do not alter formula/generated columns.
2. With R and `readxl` available, run the exact `Schmidt_etal_1984_text.R` from a clean session. Default behavior writes the analysis CSV only and warns that public output is withheld. Compare its cells against the delivered Python preview.
3. When shared publication is scheduled after R, live-code and conflict checks under the existing authorization, `EVOM1_ALLOW_PUBLIC_TSV=YES` permits the script's canonical `__Public/comparative-data/<fresh Item encoded>.tsv` write; an existing destination is refused, not overwritten. No fallback/alternative TSV path exists.
4. Load the canonical dataset-builder layer for the pre-build folder audit, but validate this item using **explicit** `Schmidt_etal_1984_text.csv`, snapshot, README, definitions and fresh registry/TSV paths; do not use the first-file selection as evidence. R results, public export, human curation and central species keys must be reported separately before FINISHED is considered.
