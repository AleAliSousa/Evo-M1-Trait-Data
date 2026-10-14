# Rivara et al. 2003 — Table 1 (prepared, not R-validated)

**Item:** `Rivara_etal_2003_Table1`. **State:** `OWNERREGISTRY_UPDATE_REQUIRED`, `R_EXECUTION_PENDING`, `PUBLIC_TSV_WITHHELD`, `HOLD_SOURCE_UNCERTAINTY_NO_MERGE`.

## Source → frozen capture

Rivara, C.-B., Sherwood, C. C., Bouras, C., & Hof, P. R. (2003). *Stereologic characterization and spatial distribution patterns of Betz cells in the human primary motor cortex*. Anatomical Record Part A, 270A(2), 137–151. DOI [10.1002/ar.a.10015](https://doi.org/10.1002/ar.a.10015), printed on p.137. Title and citation agree with the registered Candidate A06; no new bibliographic authority was invented.

Actual held source: `Rivara-2003-Stereologic characterization and s.pdf` in the existing `Rivara_etal_2003/` source folder. The only item captured is **TABLE 1. Betz cell and pyramidal cell numbers and volumes**, printed p.143, PDF page 7. No other figure, table or prose measurement item is built. The PDF and page renders are not redistributed in this package.

`Rivara_etal_2003_Table1_snapshot.csv` is the single frozen source: an eight-field padded layout carrying both original blocks, repeated printed headers, Cases A–F in original order, separate Mean/SD/CV rows, meaningful blanks, thousands separators and decimal places, and the complete table note. The four-column volume block uses four trailing empty padding fields; that padding adds no source information. Blank CE summary cells and blank count-block CV Betz-% cell remain blank. Headers are not enriched with untabulated species, context or units.

**SourceReader:** Microsoft Copilot AI assistant. **SourceReadDatePacific:** 2026-10-10, America/Los_Angeles. Text-layer numeric extraction was checked by actually reading rendered printed Table 1, Methods p.138 and Results p.141. Publication-year data stay **2003**. No human visual curation is assumed: that field is blank. Source-format legibility is recorded in the existing Source format field, not an invented quality column.

## Interpretation, methods and scope

Methods p.138 specifies six deceased elderly individuals, five women and one man, 75–96 years old, with no recorded neurological or psychiatric disorder, from the University of Geneva geriatric department. **Only the left hemispheres were used.** Table letters are case identifiers; ages and sex are not assigned to individual A–F rows. Histology used immersion fixation and Nissl-stained sections. Methods pp.138–140 and Results p.141 identify **optical fractionator** for neuronal numbers and **rotator** for cellular volume, not the provisional registry's nucleator.

Counts estimate the neuronal populations of **left primary motor cortex (area 4), layer Vb**, not whole brain, all M1 layers, the corticospinal tract, or combined L+R. The two blocks describe the same six cases, not twelve independent specimens. Betz cells are distinct from the table's other/non-Betz pyramidal cells. Total pyramidal count includes both; it is not total neurons, and interneurons were not included.

Cell volumes are **individual neuronal soma size in µm³**, with each case's population mean, not regional cortical volume. µm³ is retained as a cell-size unit: there is no forced ×1000 gross-brain-volume conversion. A later explicit soma-size conversion to mm³ would be ×10⁻⁹, never ×1000. No count scaling or hemispheric doubling is applied.

CE means **coefficient of error**, not SEM, SD or CV. SD is across-case standard deviation; CV is dimensionless coefficient of variation. Counts and soma-volume Mean/SD keep cells/µm³; CV rows for these columns are dimensionless. Summary CE cells are blank because no CE summaries are printed.

## Analysis and references

- `Rivara_etal_2003_Table1.csv`: **six individual-case rows**, joining the two printed blocks on case_id. Primary count/soma-size columns are distinguished in the fixed ten-column dictionary from information-only CE and published-derived percentage/ratio columns.
- `reference_tables/Rivara_etal_2003_Table1_published_summary.csv`: **three published reference rows**, Mean/SD/CV, joined on `Ref` + `summary_key`, then selected by `summary_statistic`. `data_role = secondary` explicitly prevents treating these reference summaries as independent patients or new primary records.
- `..._context.csv`: source-written specimen, laterality, population, age-range, method, units, reader, uncertainty, collection and overlap context. The original term **humans** comes from Methods; title uses Human. No inline conversion to Homo sapiens or species-key edit is made.
- `..._measurement_map.csv`: block/header-position mapping and primary/info/derived distinctions. The R reader uses this item-scoped resource, rather than hardcoding numerical data.
- `..._definitions.csv`: exact ten-column schema `Code, Definition, Structure, Measure, Stat, role, taxon, Reference, Note, Source Note`; all case and summary Codes covered, including exact `Ref`, `observation_level`, CE and publication year. Method rows specify dimensionality, derived-measure retention and reader provenance.
- `..._references.csv`: present primary citation plus the explicitly bounded Jacobs overlap warning. Table 1 has no per-case secondary-source citation keys. No untabulated source references are invented.

The printed 12.2% is an across-case published summary, **not** the ratio of the mean counts. The printed 20.4 is the published mean of the case volume ratios, **not** silently replaced by the ratio of mean soma sizes. Printed case percentages and ratios remain as published. No summary is recomputed into the public data.

Jacobs et al. 2018's quoted human 125,290 count and approximately 86,685 µm³ soma size refer to this **same original measurement source**, not a newly independent replicate. Preserve upstream provenance and never average both citations as independent human observations. This package neither builds a Jacobs item nor invents its unverified bibliography.

## Source uncertainty: preserve printed values, HOLD interpretation

Actual Table 1 prints case E non-Betz pyramidal count **1,873,740**; Results p.141 gives a maximum **1,673,740** in prose. The table value is retained. The table's maximum Betz soma mean is **113,125.2 µm³**, whereas Results prose gives **113,146**. No prose-based repair is applied. Results prose gives the Betz soma mean as **86,685 µm³**, whereas Table 1 prints **86,685.9 µm³**; this lower-precision prose presentation does not replace the table value. All three count Mean/SD/CV series match independent case arithmetic at printed precision, including means **125,290** Betz cells and **1,026,630** other pyramidal cells across the same six left hemispheres. Four other published summaries differ from recomputation using the rounded case entries: Betz-% mean, other-pyramidal volume mean/SD and volume-ratio CV. Rounding order or underlying precision may explain some differences: the mean of unrounded case percentages rounds to the published 12.2, while the mean of the rounded printed percentages rounds to 12.3. We do not infer an error from that difference. The volume-summary differences remain explicitly unresolved. Diagnostics live in the preparation audit, not the publication package; none permits a transcriber to silently correct the frozen table.

The published count Mean row remains **125,290.0 / 1,026,630.0 / 1,151,920.0 / 12.2**. Volume Mean remains **86,685.9 / 4,274.0 / 20.4**, SD **19,934.0 / 438.3 / 4.6**, CV **0.23 / 0.10 / 0.23**. The frozen source and published reference preserve these values even when independent case arithmetic differs. An owner scientific decision is required before pooling or trait compilation.

## Verification actually performed versus pending

**Performed:** actual visual PDF reading; text-to-frozen value/shape checks; independent Python frozen-snapshot-to-preview reconstruction; case arithmetic, all 18 numeric case CE values, nine blank summary CE cells, dictionary Code/schema coverage, reference exactness, and SHA-256/readback checks.

**Not performed:** R execution, R parser validation, clean-session R build, canonical audit, dry run, build/validator, public TSV export, species-key registration or merging. Both R and Rscript are definitively absent from PATH in this environment. The CSVs are **Python-generated prepared previews**, not claimed as R products or R parity. The `.R` is a prepared reader which must be executed and reviewed by the owner in an R-equipped environment.

No comparison/check folder is included in the public-style package. Checks and manifests remain separate preparation-audit artifacts, consistent with REPO_BOUNDARY's placement principle. Canonical source/repository instructions and disposition register were read; none were altered.

## Correct the EXISTING provisional row — do not register a duplicate

`reference_tables/Rivara_etal_2003_Table1_existing_registry_row_correction.csv` uses the freshly verified **34 current header names (A:AH)** from the header-only registry evidence, eTag revision **977**. It is a proposal for the existing **Candidate A06**, not a new registration row. Human visual curation stays blank. All generated fields (including B/E:L) stay blank and must **not** be pasted over the live formulas. Header verification is **not full item authority or public-export permission**: the exact item row must be freshly read before future publication. Match current live headers and the Item name by name, not cached positions.

1. Find the existing row by exact `Item name = Rivara_etal_2003_Betzcells`, not by cached row number. The prior Item number was explicitly provisional because the paper was unread.
2. Change editable **Item number to `Table1`** and apply named descriptive updates from the proposal. Keep the confirmed citation/DOI, replace obsolete holdings/unread notes and nucleator method, and retain the source/R/HOLD blockers.
3. **Do not add a second row.** Run `_tools/file_list.R` and recalculate generated fields. Expected generated Item name is `Rivara_etal_2003_Table1`; freshly verify authoritative Item encoded and public-file match. This package proposes no encoded authority or encoded TSV filename.
4. Install prepared files into the existing paper folder. In an R-equipped environment, source the reader cleanly (ordinary `source()`, canonical `sys.source(..., envir = new.env(parent = baseenv()))`, or `Rscript`). Its file-before---file self-location and qualified utils I/O support those modes without relying on a pre-attached package search path.
5. Initially leave `EVOM1_RIVARA_R_GATE` unset: the reader writes local case/summary CSVs but withholds public TSV. Independently verify R output against the snapshot, resolve the recorded scientific HOLD and complete owner pre-export review. Only then explicitly set `EVOM1_RIVARA_R_GATE=OWNER_VERIFIED_R_BUILD_AND_VALIDATION` for an owner-authorized rerun. No setting is made by this package. The gate is manual authorization, **not** evidence that validation has happened.
6. Public writing additionally requires a **fresh**, unique registry match on the script's own derived Item name, authoritative printed Table1 label, nonempty safe Item encoded, and mounted repo-level `__Public/comparative-data/`. Missing or old registry match produces **no public export and no fallback filename**. Run canonical audit/build/validator in the corrected repository and record actual results; do not infer PASS from the Python preview. Summaries remain reference-only and are never public trait TSV rows.

No original workbook, generated formulas, source PDF, keys, merge scripts, prior approval runs, old ZIPs, earlier sensory packages, or pinned portable runner are changed. This cortical item is **not** added to or claimed covered by the earlier portable-13 run. Delivery uses only output-surface CopyArtifact; no shared upload, GitHub or other outgoing writes are made.
