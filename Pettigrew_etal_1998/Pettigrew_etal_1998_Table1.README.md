# Pettigrew_etal_1998_Table1 — prepared, R validation pending

Pettigrew, J. D., Manger, P. R., & Fine, S. L. B. (1998). *The sensory world of the platypus*. Philosophical Transactions of the Royal Society of London B, 353, 1199–1210. DOI: [10.1098/rstb.1998.0276](https://doi.org/10.1098/rstb.1998.0276).

## Source → frozen snapshot

Source PDF: `Pettigrew-1998-The sensory world of the platyp.pdf`, SHA-256 `82577386b109659d847865c7b3c4b1dd26c845109e63aed0b83dadb3f264fb40`. Table 1 is on PDF page 3 / printed page 1201. The caption is “Cortical magnification factors at different recording sites on cortex”.

Reader: **Microsoft Copilot AI assistant**, 10 October 2026, America/Los_Angeles. The source is a legible printed PDF table, not a native CSV. Values were captured from its layout text and checked against a `pdftoppm` rendering. Meaning-bearing glyphs (en dash, minus exponent) were transcribed from the rendered page, not inherited from corrupted extraction. This is AI visual inspection, **not human visual curation**; that registry field remains blank. The publication year stays 1998.

`Pettigrew_etal_1998_Table1_snapshot.csv` is a four-column printed-layout capture: caption row, original headers, Vr/Vc group rows and nine recording-site-pair rows, all in printed order. CSV holds this layout without merged cells: original multi-line headers are rejoined within their cells, with no semantic loss. Distances keep their printed decimal notation; every `ca.` stays in the receptive-field column. No source-external species or provenance fields were inserted into this snapshot. The snapshot was frozen before the R reader and analysis CSV were created.

## Analysis-ready CSV and R

`Pettigrew_etal_1998_Table1.R` reads the frozen file by position, carries forward Vr/Vc, parses pair identifiers, converts numeric text and represents `ca.` with a row-level approximation flag. **Every magnification factor is the printed value**, not a recalculated distance/angle quotient. Values remain in mm, degrees and mm/degree; magnification is linear, not cortical surface area.

`Pettigrew_etal_1998_Table1.csv` has **9 rows** and 17 columns. It was materialized by a separate **Python parity implementation** of the documented R transformations. Numeric/ordering/schema/source checks passed; this does **not** establish that R has executed or that the canonical builder has passed. No Rscript is available in this session; no R audit, dry run, build or validate was run.

The self-locating R script checks the innermost matching `source()`/`sys.source()` frame first (`ofile` or `file`), before direct `Rscript --file=` or RStudio fallbacks. It therefore resolves this reader rather than an Rscript wrapper, and supports console `source()`. The script derives `folder`, `base`, `item_name`, `item_encoded`, and uses `final.dataframe`. The CSV/table readers and writers use explicit `utils::` qualification so they resolve under the canonical builder’s `new.env(parent = baseenv())`. These call-path corrections are statically reviewed, not R-executed. On each future run it rereads the registry and resolves authority by **Item name only**, with no hardcoded DOI or row-number fallback. The public writer defaults to withheld. After an R-capable curator runs the canonical audit/dry-run/build/validate and confirms registry authority, explicit publication uses `EVOM1_ALLOW_PUBLIC_TSV=validated`; before that, do not create or upload a public TSV.

## Provenance, species and join-ready resources

- `reference_tables/Pettigrew_etal_1998_Table1_definitions.csv`: exact 10-column dictionary, including all output columns and method/observation-level notes.
- `..._context.csv`: authors’ “We calculated this from the data of figure 3” claim, page/role/overlap gates. Acknowledgements credit Leah Krubitzer and Marcello Rosa for visual-cortex mapping data. These are primary **author-reported calculations**, not new independent recording data.
- `..._references.csv`: only the cited contextual source `Krubitzer, this issue`; full bibliographic entry is absent, explicitly unresolved. Do not substitute the listed Krubitzer et al. 1995 somatosensory paper. Join `source_ref_key` to `ref_key`, splitting multi-citations on `; ` when present.
- `..._species_context.csv`: `platypus` is preserved as the source common name. `Ornithorhynchus anatinus` is printed in cited-work titles on p.1209 and is documented as context, not silently inserted as a canonical mapping.
- `Pettigrew_etal_1998_species_key_proposal.csv`: owner-only proposal for the existing `_keys/General/species_key.csv`, pending collection/mapping confirmation. No key was edited or mapping applied.

Observation level is **recording-site pair within one cortical visual area**, not a species mean or one animal per row. Adjacent pairs share sites. Do not pool these rows as nine independent observations. Table 2 is a contextual summary of overlapping visual information, not independent data; all its existing files were left byte-for-byte unchanged.

## Registry and release state

Fresh live registry read matched exactly one `Pettigrew_etal_1998_Table1` by Item name; current encoded code is `10.1098%2Frstb.1998.0276_Table1`. Current schema has 34 named columns, A:AH. Proposed descriptive updates are in the task handoff JSON; no registry edit occurred. `Data role` remains primary, with author-calculated/contributed-data provenance explicit. Root `__ReadMe.xlsx`, keys, merges and the shared repository were not modified.

**Status: PREPARED — R_PENDING; public TSV withheld; shared publication not attempted; no FINISHED claim.** Build/shared-write authorization already exists. Shared publication was deliberately not attempted in this batch because of earlier approval conflicts and current R/source gates, not because owner permission is absent. No orphan paper-folder TSV, no private candidate TSV, no public export and no merge was created. QA and source renders are retained as private session audit material outside the public paper folder, per the public/private boundary. Human visual curation and species-key approval remain pending.
