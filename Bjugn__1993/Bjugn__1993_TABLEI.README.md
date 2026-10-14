# Bjugn__1993_TABLEI — printed TABLE I

## Source

Bjugn, R. (1993). The use of the optical disector to estimate the number of neurons, glial and endothelial cells in the spinal cord of the mouse — with a comparative note on the rat spinal cord. Brain Research, 627(1), 25–33. https://doi.org/10.1016/0006-8993(93)90744-8

PMID 8293301. The held PDF is the numerical source; PubMed verifies citation/DOI metadata only. This item is printed TABLE I, p.26 (PDF page 2). The rendered TABLE I caption and Methods references confirm Roman I, despite OCR TABLE 1. Existing item tokens are retained for owner resolution, not renamed automatically.

## Snapshot

`Bjugn__1993_TABLEI_snapshot.csv` is a frozen printed-layout grid: caption, notes, both header tiers, original column order, animal numbers 1–5, and separate Mean/SD/CV rows. Unicode mm³, 10⁶ and Σ preserve meaningful symbols; blank cells preserve group-header geometry. CSV preserves this logical layout losslessly without merged-cell styling; no Office conversion is needed. No Total footer or extra animals are invented.

Source reader: **Microsoft Copilot AI assistant**, **2026-10-10**, America/Los_Angeles (Pacific). Reading combined the existing PDF text layer with visual inspection of rendered held-PDF pages 25, 26, 28 and 31. An existing independent PDF text parser re-read all numeric cells/summary cells; rendered print resolved OCR decimal punctuation, Roman I and Σ. This is AI inspection, **not human curation**.

## Data readable / transformations

`Bjugn__1993_TABLEI.csv` is a **Python-generated analysis preview** from the saved frozen table/context, five rows, one per printed animal number. `Bjugn__1993_TABLEI.R` reads those frozen inputs and reproduces the transformation when a real R runtime is available; it never writes or regenerates either snapshot and contains no table-value literals. Original printed strings remain in the table snapshot.

Body mass (g), cord length (mm), and gray/white reference volumes (mm³) already use project units and are not normalized.

## Variables / context / joins

`reference_tables/Bjugn__1993_TABLEI_definitions.csv` has the exact ten-column dictionary schema, including `Source Note`. All analysis columns are covered; metadata Measure fields are blank and Reference is the exact item token. Anatomy descriptors are explicitly source-scoped, not a newly approved mapping into global keys.

`reference_tables/Bjugn__1993_TABLEI_context_snapshot.csv` contains **Methods/Discussion-derived** context, separate from printed table cells: adult albino male mice, Bom: NMRI, histology, cord limits, one nucleus per cell assumption, tissue processing and role/HOLD provenance. Species remains the printed common name **mouse**, from the paper title/Table II caption; no scientific binomial is guessed. Published strains and contextual species names are not inserted into frozen table cells.

`reference_tables/Bjugn__1993_TABLEI_source_summaries.csv` preserves printed Mean/SD/CV as cohort summaries, not additional observations. Join summaries by Reference + summary label + analysis column. `Bjugn__1993_TABLEI_SourceSummary.md` records legibility, OCR issues, summary rounding and remaining gates. The item-scoped references lookup contains only this original paper, not its entire bibliography.

**Primary, but the same five animals** in TABLE I and II. Join within this paper by publication token + printed animal number. Animal 2 can be linked to the paper's TABLE V; TABLE IV reports cohort summaries. No regional items are built or edited here. Never join future publications by row order, pool I/II as independent replicates, or add the source summaries as new animals. Rat comparisons cite an earlier study and are out of this bounded extraction.

No correction for volumetric changes during tissue processing was made by the author (p.31); none is added here. Ependymal cells are excluded from cell-number estimates. Animal 2's more extensive sampling does not create another animal or change million-scaled trait units.

## QA and online-database status

Source visual checks, independent PDF numeric reading, frozen→preview numeric/schema/role/unit checks and file hashes were performed with Python. This does **not** certify an R execution, canonical audit/dry-run/build/validation, or independent reviewer approval. No preexisting public TSV comparison is asserted.

**HOLD — not finished or public authority.** R runtime is absent; actual clean-session R tests (including source/sys.source self-location and base-parent environments), canonical exact-item audit/build/validate, owner source-label/DOI correction and independent review remain pending. The script checks `fr$ofile`/`fr$file` through its frame lookup before a validated own-basename `--file` fallback and uses qualified utils I/O. Public output is off by default, requires explicit owner/DOI/R gates and a fresh exact-name registry lookup, and was not attempted. No TSV, registry workbook, keys, merge, older upload or earlier batch artifact was changed.

The owner must correct existing TABLE II citation/DOI override from -9 to the **single article DOI 10.1016/0006-8993(93)90744-8** and refresh formula-generated authority. TABLE III/IV/V have the same article-wide DOI issue (-10/-11/-12); their files are untouched by this task. Do not invent one DOI per table or register new rows. Registry Human visual curation stays untouched.
