# Korbo__1999_Text

**Item name** `Korbo__1999_Text` · **Item number** `Text` · **Item encoded** pending registration
(expected `10.1111%2Fj.1530-0277.1999.tb04039.x_Text`)

Korbo, L. (1999). Glial cell loss in the hippocampus of alcoholics. *Alcoholism: Clinical and Experimental Research*, 23(1), 164–168. <https://doi.org/10.1111/j.1530-0277.1999.tb04039.x>

**Item full original title:** glial-cell values printed in the RESULTS text (pp. 165–166).

## Source

Scanned journal PDF (Wiley download; text layer is OCR and interleaves the two columns with the
tables). Values were read from the page images and checked against the text layer where legible.
The supplied file is named `Korbo-2006-Glial Cell Loss in the Hippocampus.pdf`, but the article is
the **1999** paper (masthead: *Alcohol Clin Exp Res* Vol. 23, No. 1, January 1999, pp. 164–168;
download watermark DOI 10.1111/j.1530-0277.1999.tb04039.x). **Single author (Lise Korbo)**, hence
the folder `Korbo__1999`. Copied into this folder with its original filename.

**Groups.** `Controls` / `control group` = **healthy control group**: 5 males, 34–56 y (mean 44), no
history of mental or neurological disease or alcohol abuse; causes of death acute myocardial
infarction, aneurysm of the aorta, one "had been killed", pulmonary embolism. `Alcoholics` = 5 male alcoholics,
36–53 y (mean 44), no Wernicke–Korsakoff syndrome, 4 with liver cirrhosis. **Left hippocampus only.**
Optical fractionator, 70 µm glycolmethacrylate sections, modified Giemsa; z-shrinkage 2–3% (negligible).

## Constructed snapshot (data from text)

The hippocampal **glia** totals are printed only in running text (per-subregion glia appear only in
Fig. 2, not digitised). `Korbo__1999_Text_snapshot.csv` is a constructed snapshot: one record per
printed value, with the full sentence verbatim, page, section and a transcription note.

| record | sentence location | value |
|---|---|---|
| T01–T04 | RESULTS, p. 166, right column, 1st paragraph ("In the control group, the total number of glial cells …") | 256 million; 56% astrocytes, 32% oligodendrocytes, 12% microglia |
| T05 | same paragraph, next-but-one sentence | glia/neuron ratio 11.5 (average over regions, granule cell layer excepted) |
| T06 | RESULTS, p. 165, first sentence | 37% loss of glia in alcoholics (p < 0.05) |
| T07–T09 | p. 166, left column | astrocytes −42% (p < 0.025), oligodendrocytes −39%, microglia −14% |
| T10 | p. 166, left column | glia per neuron −33% in alcoholics (p < 0.01) |

Transcribed by an **AI assistant (Claude) on 2026-11-11** from page renders (300–500 dpi); each
sentence was matched against the text layer, and the build checks that every printed value occurs
verbatim inside its own sentence.

**Groups.** `control group` = the **healthy control group** (T01–T04; T05 sits in the same
paragraph and names no group, `group_role` = `healthy control (paragraph context)`). T06–T10 describe
the alcoholic group relative to controls. Group wording is kept as printed in `group_as_printed`.

## Build

`Korbo__1999_Text.R` parses the records and adds **three derived rows** (D01–D03, `derived = 1`):
control astrocytes, oligodendrocytes and microglia = 256 million × printed % = 143.36, 81.92 and
30.72 million. The paper does not print these; they inherit the rounding of the whole-number
percentages (±0.5 percentage point = ±1.3 million). Use T01 for the printed total.

## Table checks

T02 + T03 + T04 = 100 (tolerance 1.5). **Actual R run 2026-11-11: 1 pass.**

Note (not an error): T05 (11.5) ≠ T01 / Table 1 total (256 / 40.2 = 6.4), because T05 averages regional
ratios excluding the granule cell layer, and glia were counted over a larger territory than neurons.

## Data role

**Proposed: `primary`** (D01–D03 derived, flagged).

## Species names

The paper prints no binomial; the species is `human` (title/text), kept verbatim in
`species_as_published`. No `_keys/` file was edited. A proposed row (`human` → *Homo sapiens*,
NCBI 9606, collection General) is in `reference_tables/Korbo__1999_species_key_proposed.csv`; adopt it
into `_keys/General/species_key.csv` before this item enters a species-resolving merge. The
counting method should also be recorded in `_keys/cell_count_methods/source_methods.csv`
(proposed: `STEREO_DISECTOR` — optical fractionator, target `cell_counts_histology`) — not done here (no `_keys/` edits).

## Registration

Not yet in `__ReadMe.xlsx`. The proposed Sheet1 row is `Korbo__1999_Text_registry_row.xlsx` in this folder
(see its HOW_TO_PASTE sheet). Until the owner pastes it and runs `_tools/file_list.R`, the build
writes the CSV only and prints `not yet registered - TSV skipped`; once `Item encoded` resolves,
the same script writes `__Public/comparative-data/<Item encoded>.tsv`.

## Human visual check of snapshot

Pending. An AI assistant transcribed and checked the snapshot against the page images. A human
still needs to compare each record's sentence and value with pp. 165–166 and record
`DDMMYYYY_initials` in the `Human visual check of snapshot` column.
