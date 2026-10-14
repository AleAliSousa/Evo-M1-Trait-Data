# Pettigrew_etal_1998_Text — prepared, R validation pending

Pettigrew, J. D., Manger, P. R., & Fine, S. L. B. (1998). *The sensory world of the platypus*. Philosophical Transactions of the Royal Society of London B, 353, 1199–1210. DOI: [10.1098/rstb.1998.0276](https://doi.org/10.1098/rstb.1998.0276).

## Source → constructed frozen snapshot

Source PDF: `Pettigrew-1998-The sensory world of the platyp.pdf`, SHA-256 `82577386b109659d847865c7b3c4b1dd26c845109e63aed0b83dadb3f264fb40`. **Microsoft Copilot AI assistant** read and transcribed the bounded registered text facts on 10 October 2026, America/Los_Angeles, checking layout text against `pdftoppm` rendered pages. This is AI inspection, not human visual curation; that registry field remains blank. The publication year is retained as 1998.

`Pettigrew_etal_1998_Text_snapshot.csv` is explicitly **constructed from prose/legend**, not a published table. It was saved before the R reader and analysis output. Each of nine records retains the exact source value, unit phrase, qualifier, passage/excerpt, PDF/printed page and any local printed citation keys. Extraction notes document interpretation separately.

### Bounded facts and loci

- **Figure 2 legend**, PDF p.3 / journal p.1201 (**not Figure 1**): peak retinal ganglion-cell density 4000 per square millimetre; centroperipheral density gradient 3.5:1; approximately 40 000 total ganglion cells in the illustrated left retina.
- Section 3(b), PDF p.2 / p.1200: retinally estimated visual acuity 2 cycles deg⁻¹. No approximation word is printed in that sentence, but this is an anatomical estimate, not a behavioural observation.
- Section 2, PDF p.2 / p.1200: electrophysiological most sensitive frequency around 4 kHz and upper level around 15 kHz, attributed jointly to `Gates et al. 1974; Krubitzer, this issue`.
- Section 5(b)(ii), PDF p.7 / p.1205: recalled 40 000 bill electroreceptors, with no explicit local source citation or approximation marker. A rounded-looking recalled count is not promoted to precise new measurement data.
- Section 5(b)(i), PDF p.6 / p.1204: individual-afferent thresholds around 1–2 **mV cm⁻¹**, one spike per stimulus, attributed to `Gregory et al. (1987b)`; whole-animal directional coordinated responses at fields “as low as” 50 **µV cm⁻¹**, without an explicit local citation.

### Micro/milli voltage resolved visually

The text layer corrupts the micro glyph and extracts the whole-animal threshold as `50 mVcmÿ1`. **The rendered PDF clearly prints 50 µV cm⁻¹ on p.1204 and repeats 50 µV cm⁻¹ on p.1205.** On p.1204 (and its repetition on p.1205) the afferent range is genuinely **1–2 mV cm⁻¹**. These source units were established by looking at the page, not inferred from registry metadata or the 20–40 discrepancy. The literal source units remain in both snapshot and analysis output.

## Analysis CSV and R transformation

`Pettigrew_etal_1998_Text.csv` contains **9 long-format rows**, 25 columns, four primary author-presented retinal statements and five conservatively secondary review/literature statements. Numeric storage uses `value` or `value_lower`/`value_upper`, always accompanied by `measure_code`, `unit`, `stat`, method/source context and `data_role`.

`Pettigrew_etal_1998_Text.R` reads the frozen source and joins `..._context.csv` by `record_id` without reordering records. All numbers come from frozen inputs. It removes printed thousands spaces, parses 3.5:1 to a dimensionless 3.5, keeps printed 1–2 range endpoints without an invented midpoint, types page/year fields and assigns explicit units. Only electrical thresholds receive additional normalized columns: **1 mV/cm = 1000 µV/cm**; the afferent bounds become 1000–2000 µV/cm and whole-animal value remains 50 µV/cm. These are conversions of the same rows, not independent observations.

The analysis CSV was materialized through a separate **Python parity implementation**. Source, numeric, units, range, schema, citation and ordering checks passed. Rscript is unavailable: **no R execution, R audit/dry run/build/validate occurred** and Python is not advertised as R validation.

The self-locating script checks the innermost matching `source()`/`sys.source()` frame first (`ofile` or `file`), before direct `Rscript --file=` or RStudio fallbacks. It resolves this reader rather than an Rscript wrapper and supports console `source()`. It derives `folder`, `base`, `item_name`, `item_encoded` and writes `final.dataframe`. The CSV/table readers and writers use explicit `utils::` qualification so they resolve under the canonical builder’s `new.env(parent = baseenv())`. These call-path corrections are statically reviewed, not R-executed. Future runs reread `__ReadMe.xlsx` and match Item name, never a cached row number or a guessed DOI. Public writing defaults to withheld; a curator may opt in with `EVOM1_ALLOW_PUBLIC_TSV=validated` only after canonical R checks and fresh authoritative registry confirmation.

## Provenance and non-interchangeability gates

`reference_tables/Pettigrew_etal_1998_Text_context.csv` is item-scoped and joins one-to-one on `record_id`. It distinguishes author-presented primary retina data from electrophysiological hearing literature and electroreceptive afferent literature. The recalled receptor count and whole-animal threshold have unresolved upstream origin: they are **secondary/HOLD_SOURCE_UNCERTAINTY**, not silently assigned to a nearby reference or treated as new observations. Resolving these origins is an owner/upstream-source task, not a reason to guess. Hearing retains its unresolved `Krubitzer, this issue` citation and remains HOLD for primary-source ingestion.

`..._references.csv` includes **only the three keys actually used in the bounded data**: Gates et al. 1974, Krubitzer, this issue, and Gregory et al. (1987b). Split `source_ref_key` on `; `, join each token to `ref_key`. Gates and Gregory entries preserve the p.1209 bibliography; the latter retains the printed 1987b / volume 408 rather than silently repairing bibliographic details. The `Krubitzer, this issue` full entry is absent and is explicitly unresolved, not replaced with the unrelated 1995 somatosensory entry. Blank keys on two review statements remain blank with named HOLD reasons; they do not imply primary data.

`..._definitions.csv` uses the exact 10-column schema and defines every output column, all nine long-table measure codes and methods. Generic numeric storage fields are metadata (`Measure` blank): trait identity/stat/role lives in the measure-code rows. Source anatomical terms are labelled as source terms, not unapproved canonical ontology assignments.

No different modalities or observation levels are collapsed: retina density, retina count, density ratio, estimated acuity, hearing frequencies, bill receptor count, afferent spike thresholds and coordinated whole-animal behavioural thresholds remain distinct. Hearing values are **NOT 60-dB SPL behavioural limits**. Retinal totals are not bilateral neuron counts. Whole-animal and afferent thresholds are not exchangeable.

Text acuity 2 cycles/deg overlaps Table 2's platypus value 1.8 cycles/deg; this is a contextual rounded estimate, not an independent replicate or an overwrite. No Table 2 magnification/ratio values or additional paper facts were extracted. Existing Table 2 files remain byte-identical.

## Species, registry and release

Source `platypus` is preserved. `..._species_context.csv` documents the printed binomial `Ornithorhynchus anatinus` in cited Gates 1974 / Manger & Pettigrew 1995 titles on p.1209; it is context, not an inline canonical map. `Pettigrew_etal_1998_species_key_proposal.csv` proposes the existing `_keys/General/species_key.csv` only, requiring owner confirmation because registry Collection is blank. No key or merge was edited.

Fresh live lookup by Item name matched one `Pettigrew_etal_1998_Text`, encoded `10.1098%2Frstb.1998.0276_Text`; header schema has 34 named columns A:AH. Item-level `Data role` remains both. Proposed descriptive updates are keyed by Item name in the task handoff JSON. No root registry edit or shared upload occurred.

**Status: PREPARED — R_PENDING; public TSV withheld; shared publication not attempted; no FINISHED claim.** Build/shared-write authorization already exists. Shared publication was deliberately not attempted in this batch because of earlier approval conflicts and current R/source gates, not because owner permission is absent. No orphan/local candidate/public TSV and no merge were created. Human visual curation, upstream-origin clarification and species-key approval remain pending. QA and source renders are retained as private session audit material outside the paper folder, not in a public comparison directory.
