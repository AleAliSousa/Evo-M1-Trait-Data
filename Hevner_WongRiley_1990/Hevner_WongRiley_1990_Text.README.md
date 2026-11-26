# Hevner_WongRiley_1990_Text

**2026-11-26 public completion.** The item now has an exact row in the main `__ReadMe.xlsx` registry. Running `LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 Rscript --vanilla Hevner_WongRiley_1990/Hevner_WongRiley_1990_Text.R` wrote `__Public/comparative-data/10.1523%2FJNEUROSCI.10-04-01331.1990_Text.tsv`. Earlier “not registered” or “public TSV pending” statements below describe the initial build date. Human source review remains as separately recorded.


**Item name** `Hevner_WongRiley_1990_Text` · **Item number** `data from text` · **Item encoded** `10.1523%2FJNEUROSCI.10-04-01331.1990_Text` (derived; the registry is the authority — see the name mismatch below) — NOT yet registered as an item in `__ReadMe.xlsx`; registry row to paste: `Hevner_WongRiley_1990_Text_registry_row.xlsx`.

Hevner, R. F., & Wong-Riley, M. T. T. (1990). Regulation of cytochrome oxidase protein levels by functional activity in the macaque monkey visual system. *The Journal of Neuroscience*, 10(4), 1331-1340. <https://doi.org/10.1523/JNEUROSCI.10-04-01331.1990>

**Item full original title:** Values printed in RESULTS, "Densitometric analyses" (p. 1335 right column; p. 1337 left column, top): percent CO-staining enrichment of puffs over interpuffs (normal layers 2-3) and percent decrease of TTX-eye (light) over untreated-eye (dark) ocular dominance columns (layer 4C), by CO histochemistry and CO immunohistochemistry.

## Source

PDF in this folder: `Hevner-1990-Regulation of cytochrome oxidase p.pdf` (scanned pages, OCR text layer). DOI verified against CrossRef on 2026-11-18 (see the Table1 README).

## Folder-name / registry-name mismatch (needs owner decision)

The registry formula for a two-author paper yields the publication name **`Hevner_WongRiley_1990`** — and `__ReadMe.xlsx` already carries a citation-only placeholder row for this paper with `Publication name = Hevner_WongRiley_1990`, `Item name = Hevner_WongRiley_1990_` (no Item number, trailing underscore, `Item encoded = 10.1523%2FJNEUROSCI.10-04-01331.1990_`, public-TSV match `notfound`). The folder the owner created is **`Hevner_WongRiley_1990`**, and per instructions it was not renamed; every file in it is named from the folder (`Hevner_WongRiley_1990_Table1*`, `Hevner_WongRiley_1990_Text*`), and `_keys/General/species_key.csv` rows use `source_publication = Hevner_WongRiley_1990`.

Consequence: once the registry row is pasted, column J will read `Hevner_WongRiley_1990_Table1`, which does **not** equal the build script's self-derived `item_name` (`Hevner_WongRiley_1990_Table1`), so the registry lookup in the build script will keep stopping. The registry is the authority; the owner must choose one of
(a) rename the folder and its files (and the `source_publication` key rows) to `Hevner_WongRiley_1990`, or
(b) keep `Hevner_WongRiley_1990` and make the registry name match (outside this build's remit).
Nothing was renamed here. (Other publication names currently without a folder: `Hardus_etal_2008`, `Heffner_Heffner_2010_a`, `Heffner_etal_2001_b`, `Koay_etal_1998_a`, `Lewitus_etal_2012_a`, `Püschel_etal_2026`, `Smaers_etal_2011_a`, `Young_etal_2013_a`.)

## Why a Text item

There is no printed table for these four values: Table 1 prints the relative optical densities, and the RESULTS text alone prints the authors' percentage form (32 %, 19 %, 20 %, 21 %) with the significance statements. Following `__HOWTO_make_a_snapshot.md` "When there is no table", the snapshot is **constructed**: one row per printed value, with the journal page, the location, the sentence quoted verbatim, and the printed significance sentence in its own column. The percentages are exact restatements of the Table 1 ratios (`value_status = restatement_of_Table1_ratio`; cross-item check 4/4 pass), so for analysis prefer `Hevner_WongRiley_1990_Table1`; this item documents the printed percentages and their direction. For the complete inventory of quantitative content in the paper (and what was not captured — LGN laminae and between-layer V1 differences are described only ordinally), see the Table1 README.

## Pipeline

```
Source (PDF pages 5 and 7; J Neurosci 10: 1335, 1337)
  -> Hevner_WongRiley_1990_Text_snapshot.R   writes the frozen, constructed snapshot
  -> Hevner_WongRiley_1990_Text_snapshot.csv   FROZEN: 5 rows x 11 cols (header + 4 values)
  -> Hevner_WongRiley_1990_Text.R   parse + sign + classify
  -> Hevner_WongRiley_1990_Text.csv   4 rows x 26 cols  ("use this")
  -> __Public/comparative-data/10.1523%2FJNEUROSCI.10-04-01331.1990_Text.tsv   (written by the build once registered under a matching Item name)
  -> reference_tables/Hevner_WongRiley_1990_Text_definitions.csv
  -> internal_checks/Hevner_WongRiley_1990_Text_internal_check.R / .csv   (cross-item: percentages vs Table 1)
```

## Who read the values, when, and how it was checked

**Hand transcription** (HOWTO method 5) by an AI assistant (Claude) on 2026-11-18 from 200-dpi renders of PDF pages 5 and 7, zoomed on the two passages (p. 5: lower part of both columns, "Densitometric analyses"; p. 7: top of the left column). The OCR text layer breaks the digits here ("2 1%", "0.00 1") and was used only to locate the passages. Both sentences were read in full and typed verbatim into `Hevner_WongRiley_1990_Text_snapshot.R` (freezes, refuses to overwrite a differing copy).

The build script `Hevner_WongRiley_1990_Text.R` reads the frozen file and contains no values. Run with `Rscript` (conda env `evom1-r`, `LC_ALL=en_US.UTF-8`) from a clean session on 2026-11-18; it stopped, as expected for an unregistered item, at the registry lookup after writing the analysis CSV.

### Constructed snapshot and analysis CSV

* Snapshot columns: `text_row, page, location, passage_as_printed, value_printed, units_printed, subjects_as_printed, region_as_printed, stain_method_as_printed, significance_as_printed, cited_ref`. One sentence carries two values, so the sentence is repeated on two rows. `cited_ref` is empty on every row (all values are the paper's own).
* CSV adds: `stain_method` / `stain_target`, `condition` (control / TTX), `cortical_layer` ("layers 2 and 3" — RESULTS p. 1334 places the puffs there; "layer 4C" — named in the p. 1337 sentence), `compartment_comparison`, `CO_relOD_pct_difference` (signed: + puff over interpuff; - light column below dark column), `value_status`, `n_readings` (25), `n_animals` (7 / 3, METHODS p. 1331), `species_as_published`, `Species`, `data_role`, `note`.
* **Observation level:** percent differences between printed group means (pooled over animals and sections); not species means.

## Table checks

All four checks need the sibling Table 1 snapshot and therefore live in `internal_checks/` (HOWTO 7b): `internal_checks/Hevner_WongRiley_1990_Text_internal_check.R` (read-only), result in `internal_checks/Hevner_WongRiley_1990_Text_internal_check.csv`. Result of an actual R run (2026-11-18): **4 pass, 0 mismatch, 0 not evaluable**. No in-script `table_checks` (none can be made from this snapshot alone).

| check | basis | observed | printed | difference | tolerance | status |
|---|---|---|---|---|---|---|
| `puff_enrichment_histochemistry` | Table 1 Puff / Histochemistry: 100 x (relOD - 1) vs RESULTS p. 1335 "32% darker" | 32 | 32 | 0 | 0.5 | pass |
| `puff_enrichment_immunohistochemistry` | Table 1 Puff / Immunohistochemistry: 100 x (relOD - 1) vs "19% darker" | 19 | 19 | 0 | 0.5 | pass |
| `light_column_decline_histochemistry` | Table 1 Light column / Histochemistry: 100 x (1 - relOD) vs RESULTS p. 1337 "20% decreased" | 20 | 20 | 0 | 0.5 | pass |
| `light_column_decline_immunohistochemistry` | Table 1 Light column / Immunohistochemistry: 100 x (1 - relOD) vs "the decrease was 21%" | 21 | 21 | 0 | 0.5 | pass |

## Data role

**primary**: this paper's own measurements (restated from its own Table 1; do not double-count with the Table1 item in a merge — use one or the other).

## Species names

As for the Table1 item: `species_as_published` = "Macaca fascicularis" (control rows) or "TTX-treated macaques (2 M. radiata, 1 M. fascicularis)" (TTX rows), resolved through the `Hevner_WongRiley_1990` rows of `_keys/General/species_key.csv` to Macaca fascicularis and the genus-level anchor Macaca sp.

## Units

Percent (dimensionless). No conversion.

## Human visual check of snapshot

Pending human RA. A person should read the two sentences on pp. 1335 and 1337 against `passage_as_printed` and the four `value_printed` cells, and record `DDMMYYYY_initials` in `__ReadMe.xlsx`.

<!-- errata:begin -->
<!-- errata:end -->
