# Semendeferi_etal_1998_TABLE5

## Source

Semendeferi, K., Armstrong, E., Schleicher, A., Zilles, K., & Van Hoesen, G. W. (1998). Limbic frontal cortex in hominoids: a comparative study of area 13. Am J Phys Anthropol, 106(2), 129-155. https://doi.org/10.1002/(SICI)1096-8644(199806)106:2<129::AID-AJPA3>3.0.CO;2-L

Locus: TABLE 5, printed p.147, one-based PDF page 19, in `semendeferi_etal_1998.pdf`. Original PDF is preserved; it is not redistributed in this prepared package. Other original publication tables, snapshots, and build files are untouched.

## Snapshot

`Semendeferi_etal_1998_TABLE5_snapshot.csv` is a frozen printed-layout transcription. Caption, headings, species/group order, numeric strings, thousands separators, decimal precision, footnote marker and text are preserved. Newlines capture wrapped headers/notes. CSV holds this layout without loss of meaningful cell organization; no Excel conversion or second snapshot is needed.

SourceReader: **Microsoft Copilot AI assistant**. SourceReadDate: **2026-10-10** (America/Los_Angeles). Values were extracted from the retrieved PDF text layer and visually checked cell by cell against rendered original pages by that assistant. Human visual curation remains blank; an AI page check is not human approval. Source is a legible text-layer journal PDF.

## Data readable

`Semendeferi_etal_1998_TABLE5.csv` is an independently prepared Python preview, **not an R-executed build**. `Semendeferi_etal_1998_TABLE5.R` reads the frozen snapshot and the item-scoped context CSV; it never regenerates the snapshot or hardcodes measured data. It derives `folder`, `base`, and `item_name` from its validated own filename, prioritizes source/sys.source frames over a wrapper's command arguments, and uses namespace-qualified utils I/O so sourcing into a base-environment child is supported in design but not runtime-certified.

The preview has 6 rows and 23 columns. Numeric cleaning removes thousands separators or parses decimal strings; all published measurement units are retained. Printed common names stay unchanged, with no guessed binomials and no changes to collection-specific species or anatomical keys.

## Variables and interpretation

The SE heading is retained as `SE_as_published`. Its adjacency to density suggests a density statistic, but the inspected Neuronal counts Methods (pp.133–134) do not explicitly attach SE to a target or give its unit. No SE of total count or SD is invented; statistical-target use remains held. Printed totals are copied directly, never recalculated from TABLE 2 density × volume and never doubled.

The observation level is **single_individual_right_hemisphere_estimate**. One right hemisphere from one biological individual contributes per species. Multiple disectors/locations do not create independent animals; qualitative sample sizes are not the quantitative n. Primary means newly measured in the study, not an independently sampled species mean. Individual identifiers and inter-study overlap remain unresolved. `merge_eligible` is FALSE and species-level pooling is held until provenance and compatibility are established. No merge, species averaging, or key mutation was performed.

Context that is outside the printed table is in `reference_tables/Semendeferi_etal_1998_TABLE5_context.csv`, keyed by `species_as_published`, with source locators. The fixed ten-column dictionary `reference_tables/Semendeferi_etal_1998_TABLE5_definitions.csv` covers every output column and `Method:observation_level`. There are no per-value secondary citations in this table, so no secondary-reference lookup is invented.

## Checks

AI visual source check and an independent original-PDF-text-to-preview Python comparison found zero measured-cell discrepancies (18 numeric cells), with original species and layer order retained. Numeric source and preview values were compared in code. Dictionary coverage, row/column shape, frozen-source distinction and preservation hashes were checked independently in Python. Any non-value interpretation caveats above remain active.

**Rscript is absent.** No R clean-session run, canonical builder audit, dry run, build, validation, or CSV–TSV R parity certification is claimed. The canonical wrapper's first-script/first-output limitation remains unchanged and needs item-scoped attention at local validation; no shared runner was modified.

## Online database

Status: **PREPARED / R_PENDING / PUBLIC_TSV_WITHHELD**. No public TSV, registry edit, GitHub publication, shared upload or merge was performed.

Cached registry Item name: `Semendeferi_etal_1998_TABLE5`. Cached Item encoded: `10.1002%2F(SICI)1096-8644(199806)106%3A2%3C129%3A%3AAID-AJPA3%3E3.0.CO;2-L_TABLE5`. This legacy encoded string is retained exactly, not normalized, and is informational only. Before public export, re-read current mounted Sheet1 by exact Item name and use its current Item encoded. The script's default run writes only its analysis CSV. Only after an owner completes a clean R run and item-scoped canonical validation may `EVOM1_SEMENDEFERI_PUBLIC_EXPORT=YES_AFTER_VALIDATION` be enabled; the script then requires a fresh unique primary registry row and the existing repo-level public directory. Human visual curation still requires a human and is not auto-filled.
