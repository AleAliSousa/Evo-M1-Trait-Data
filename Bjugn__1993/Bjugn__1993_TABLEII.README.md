# Bjugn__1993_TABLEII — printed TABLE II

## Source

Bjugn, R. (1993). The use of the optical disector to estimate the number of neurons, glial and endothelial cells in the spinal cord of the mouse — with a comparative note on the rat spinal cord. Brain Research, 627(1), 25–33. https://doi.org/10.1016/0006-8993(93)90744-8

PMID 8293301. The held PDF is the numerical source; PubMed verifies citation/DOI metadata only. This item is printed TABLE II, p.28 (PDF page 4). The rendered TABLE I caption and Methods references confirm Roman I, despite OCR TABLE 1. Existing item tokens are retained for owner resolution, not renamed automatically.

## Snapshot

`Bjugn__1993_TABLEII_snapshot.csv` is a frozen printed-layout grid: caption, notes, both header tiers, original column order, animal numbers 1–5, and separate Mean/SD/CV rows. Unicode mm³, 10⁶ and Σ preserve meaningful symbols; blank cells preserve group-header geometry. CSV preserves this logical layout losslessly without merged-cell styling; no Office conversion is needed. No Total footer or extra animals are invented.

Source reader: **Microsoft Copilot AI assistant**, **2026-10-10**, America/Los_Angeles (Pacific). Reading combined the existing PDF text layer with visual inspection of rendered held-PDF pages 25, 26, 28, 29–30 and 31. An existing independent PDF text parser re-read all numeric cells/summary cells; rendered print resolved OCR decimal punctuation, Roman I and Σ. This is AI inspection, **not human curation**.

## Data readable / transformations

`Bjugn__1993_TABLEII.csv` is a **Python-generated analysis preview** from the saved frozen table/context, five rows, one per printed animal number. `Bjugn__1993_TABLEII.R` reads those frozen inputs and reproduces the transformation when a real R runtime is available; it never writes or regenerates either snapshot and contains no table-value literals. Original printed strings remain in the table snapshot and in the `*_as_printed_10e6` columns.

Each gray/white Σ/G/E/N/U value is an estimated total in 10⁶ cells. The R code multiplies by 1e6 for absolute estimated cell counts. These are not counted nuclei samples, densities, optical-fractionator totals, or tissue volume. Gray and white matter stay separate; unidentified U is not glia or zero; endothelial E includes pericytes and smooth muscle cells. Σ must not be added again to G/E/N/U.

### Neuron-classification caution

**N means cells classified as neurons by the author's morphological criteria, not a confirmed count of all true neurons.** In the Discussion, *Cell classification* (printed pp.29–30; PDF pages 5–6), the author reports that no clear-cut neuron-identification criteria could be found. The classification used nucleolar, cytoplasmic/Nissl-body and nuclear-membrane morphology. Neurons not meeting those criteria may have been assigned to G or U, while glial cells may have entered neuronal categories 2 or 3. Estimates for individual cell categories therefore require caution. The author states that the estimated **total number of cells is not affected by this classification ambiguity**; that statement does not establish the identity of every cell counted as N or eliminate other methodological limitations.

N, G, U and Σ remain exactly as published: no redistribution, correction or inferred true-neuron count is made. This source-semantic caution is recorded in the existing `SourceVisualCheck` provenance field of the context file, read and carried by the unchanged R script. The Python preview was regenerated from the unchanged printed-table snapshot and updated context; **all 50 printed million-scaled strings and all 50 absolute cell-count values are unchanged**. Only five repeated provenance metadata cells changed; no columns or animals were added. AI source inspection is not human curation, and R was not executed.

## Variables / context / joins

`reference_tables/Bjugn__1993_TABLEII_definitions.csv` has the exact ten-column dictionary schema, including `Source Note`. All analysis columns are covered; metadata Measure fields are blank and Reference is the exact item token. Anatomy descriptors are explicitly source-scoped, not a newly approved mapping into global keys.

`reference_tables/Bjugn__1993_TABLEII_context_snapshot.csv` contains **Methods/Discussion-derived** context, separate from printed table cells: adult albino male mice, Bom: NMRI, histology, cord limits, one nucleus per cell assumption, tissue processing and role/HOLD provenance. Species remains the printed common name **mouse**, from the paper title/Table II caption; no scientific binomial is guessed. Published strains and contextual species names are not inserted into frozen table cells.

`reference_tables/Bjugn__1993_TABLEII_source_summaries.csv` preserves printed Mean/SD/CV as cohort summaries, not additional observations. Join summaries by Reference + summary label + analysis column. `Bjugn__1993_TABLEII_SourceSummary.md` records legibility, OCR issues, summary rounding and remaining gates. The item-scoped references lookup contains only this original paper, not its entire bibliography.

**Primary, but the same five animals** in TABLE I and II. Join within this paper by publication token + printed animal number. Animal 2 can be linked to the paper's TABLE V; TABLE IV reports cohort summaries. No regional items are built or edited here. Never join future publications by row order, pool I/II as independent replicates, or add the source summaries as new animals. Rat comparisons cite an earlier study and are out of this bounded extraction.

No correction for volumetric changes during tissue processing was made by the author (p.31); none is added here. Ependymal cells are excluded from cell-number estimates. Animal 2's more extensive sampling does not create another animal or change million-scaled trait units.

## QA and online-database status

Source visual checks, independent PDF numeric reading, frozen→preview numeric/schema/role/unit checks and file hashes were performed with Python. This does **not** certify an R execution, canonical audit/dry-run/build/validation, or independent reviewer approval. No preexisting public TSV comparison is asserted.

**HOLD — not finished or public authority.** R runtime is absent; actual clean-session R tests (including source/sys.source self-location and base-parent environments), canonical exact-item audit/build/validate, owner source-label/DOI correction and independent review remain pending. The script checks `fr$ofile`/`fr$file` through its frame lookup before a validated own-basename `--file` fallback and uses qualified utils I/O. Public output is off by default, requires explicit owner/DOI/R gates and a fresh exact-name registry lookup, and was not attempted. No TSV, registry workbook, keys, merge, older upload or earlier batch artifact was changed.

The owner must correct existing TABLE II citation/DOI override from -9 to the **single article DOI 10.1016/0006-8993(93)90744-8** and refresh formula-generated authority. TABLE III/IV/V have the same article-wide DOI issue (-10/-11/-12); their files are untouched by this task. Do not invent one DOI per table or register new rows. Registry Human visual curation stays untouched.
