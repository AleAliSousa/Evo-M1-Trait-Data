# __merging_cell_counts_histology

Cells counted **in tissue sections**: densities, totals and ratios of neurons and glia, across species and regions. One row per printed statistic (long format). Started on 4 November 2026 with Munger et al. 2022, Table 4.

> **Checked in R (4 Nov 2026, 17:16 PST).** The script was written without R, and the first outputs came from a Python mirror. The owner's run of `cell_counts_histology_compiled.R` reproduced them byte for byte: all seven output files and the "Cell counts (histology)" rows of `_keys/variable_domain.csv`.

## Why this merge is separate

The counting method decides which merge a value goes to. This was an owner decision on 4 November 2026 (review RV-2026-005 in `_keys/cell_count_methods/expert_reviews.csv`).

| Merge | What is counted |
|---|---|
| **this folder** | Cells counted in sections. Design-based stereology (optical fractionator, disector) comes first. Model-based profile counts are kept but **off by default**. |
| the isotropic-fractionator merge (`__merging_cell_counts_isotropic_fractionator`) | Nuclei counted in homogenates (isotropic or flow fractionator). |

Methods are **never pooled here**. Every app label ends with its method tag, for example `[stereology]`, so the app cannot average a stereology density with a fractionator density. Combining methods is reserved for a separate, opt-in pooled product, and only where a rule in `_keys/cell_count_methods/pooling_rules.csv` allows it. Rule PR00 is "never" by default. PR01, for totals, cites Bahney & von Bartheld 2014: fractionator counts were about 100% of stereology counts in primate white matter.

## What comes in, and who decides

The method key decides what comes in, not this script. That key is `_keys/cell_count_methods/source_methods.csv`. Each row whose `target_merge` is `cell_counts_histology` names an item, an R filter on that item's public TSV, the counting method and a treatment. A blank filter covers the rows that no more specific row of the same item claims.

| treatment | here |
|---|---|
| `include`, `include_flagged`, `include_own_label` | loaded; `merge_default` TRUE (shown in the app) |
| `off_by_default` | loaded; `merge_default` FALSE (kept in the table, hidden in the app) |
| `not_merged`, `exclude`, `queued`, `route_elsewhere` | not loaded |

An item is compiled once it also has a term map in `standardized_term_by_reference/`. Routed items without a term map are listed in `cell_counts_histology_qa_pending.csv`. That file is this merge's to-do list. On 4 November 2026 it held 30 rows (29 items), and every one of those items already has a public TSV.

Experts change a method or a treatment in `_keys/cell_count_methods/`, with a row in `expert_reviews.csv`, and then re-run this script. Nothing in this folder needs editing for that.

## Files

| File | Role |
|---|---|
| `cell_counts_histology_compiled.R` | the build script (inputs, rules and outputs are listed in its header) |
| `standardized_term_by_reference/<Item>_standardized_terms.csv` | one term map per item: what each TSV column (or row) means |
| `measures.csv` | measure vocabulary: unit, label suffix and definition template (`density` = cells/mm3, `fraction_of_glia`, `number`, `glia_neuron_ratio`, ...) |
| `cell_classes.csv` | cell-class vocabulary (`glia`, `astrocyte`, `neuron`, ...). A marker (GFAP, EAAT2, NeuN) is recorded separately and never pooled across. |
| `regions.csv` | allowed region/layer pairs, their layer code for labels, and the app `Structure` |
| `region_crosswalk.csv` | printed region → region/layer, for tables whose region is a column (empty so far) |
| `method_tags.csv` | method family (from `_keys/cell_count_methods/methods.csv`) → the tag in labels |
| `value_flags.csv` | value-level notes, such as table/text discrepancies. Source values are kept and flagged, never corrected or balanced. |
| `cell_counts_histology_long.csv` | **the dataset**, read by the app as "Cell counts (histology)" |
| `cell_counts_histology_label_definitions.csv` | a definition for each app label, picked up by `_keys/build_variable_definitions.R` |
| `cell_counts_histology_coverage.csv` | species × quantity, with the sources behind each |
| `cell_counts_histology_qa_pending.csv` | routed here, no term map yet |
| `cell_counts_histology_qa_routing.csv` | for each compiled item, how many TSV rows went where (all targets, so nothing goes missing) |
| `cell_counts_histology_qa_overlaps.csv` | the same quantity for the same species from more than one source |
| `cell_counts_histology_qa_species.csv` | species the house resolver could not place |

The script also writes the `_keys/variable_domain.csv` rows for the dataset "Cell counts (histology)". It replaces those rows on every run and leaves every other line byte for byte.

## Labels

`<region>_<layer code>_<cell class>[_<marker>]_<measure> [<method tag>] (<unit>)`

| Munger 2022 Table 4 row | label (app) | label until 4 Nov 2026 (Supplementary sources) |
|---|---|---|
| Total glia density layer I (Gv) | `PFC_area9_L1_glia_density [stereology] (cells/mm3)` | `PFC_area9_L1_glia_density (cells/mm3)` |
| Total glia density WM (Gv) | `PFC_area9_WM_glia_density [stereology] (cells/mm3)` | `PFC_area9_WM_glia_density (cells/mm3)` |
| GFAP-ir astrocyte density layer I (GFAPv) | `PFC_area9_L1_astrocyte_GFAP_density [stereology] (cells/mm3)` | `PFC_area9_L1_GFAP_astrocyte_density (cells/mm3)` |
| GFAP-ir astrocyte density WM (GFAPv) | `PFC_area9_WM_astrocyte_GFAP_density [stereology] (cells/mm3)` | `PFC_area9_WM_GFAP_astrocyte_density (cells/mm3)` |
| GFAPv/Gv layer I | `PFC_area9_L1_astrocyte_GFAP_fraction_of_glia [stereology] (ratio)` | `PFC_area9_L1_GFAP_astrocyte_to_glia_ratio (ratio)` |
| GFAPv/Gv WM | `PFC_area9_WM_astrocyte_GFAP_fraction_of_glia [stereology] (ratio)` | `PFC_area9_WM_GFAP_astrocyte_to_glia_ratio (ratio)` |
| EAAT2-ir astrocyte density WM (EAAT2v) | `PFC_area9_WM_astrocyte_EAAT2_density [stereology] (cells/mm3)` | `PFC_area9_WM_EAAT2_astrocyte_density (cells/mm3)` |

`variable_domain.csv` gives each label a `poolable_family` (for example `glia_density`) and a `poolable_group` (`glia_density__stereology`). If a fractionator or profile-count version of the same quantity arrives, the app's Plot tab will warn that the bases differ.

## Munger et al. 2022, Table 4 (first source)

- **In:** 7 of the 12 variables, giving 28 species means plus 28 SDs (56 rows; n = 6–7 individuals, chimpanzee EAAT2 n = 4). The variables are total glia (Nissl) and GFAP-immunoreactive astrocyte density in layer I and the white matter, GFAPv/Gv in both, and EAAT2-immunoreactive astrocyte density in the white matter. The method is the optical fractionator (`STEREO_OPTICAL_FRACTIONATOR`); the classification is **proposed** (AI assistant) and not yet reviewed.
- **Not in:** the 3 astrocyte soma volumes, which go to the cell-morphology merge later and stay in Supplementary sources until then, and the 2 GLUT1 vessel measures, which stay in Supplementary sources. `cell_counts_histology_qa_routing.csv` shows the split: 28 / 12 / 8 TSV rows.
- **Region:** Brodmann area 9 (dorsolateral prefrontal cortex), **not M1**. Layer I and the white matter beneath area 9 (app structure `FrontalWhite`).
- **Flags (values kept as printed):**
  - Chimpanzee white-matter glia: Table 4 prints 267,012 per mm3; the Discussion gives 287,469.
  - Human white-matter glia: Table 4 prints 120,832; the text gives 120,833.
  - GFAPv/Gv is the mean of per-animal ratios, so it is not the ratio of the two density means.
- **Checked (4 Nov 2026):** all 28 printed cells were parsed independently ("mean ± SD (n)"). Mean, SD and n match the merged rows exactly.

## Writing a term map (the next sources)

There is one CSV per item, with these columns: `Reference, term_type, Original_Term, Standardized_Term, statistic, cell_class, marker, region, layer, unit, note`.

- Every TSV column needs a `column` row. Map it to `DROP` if it is not used.
- Column roles:
  - `Species`
  - `species_printed`
  - `row_key`
  - `statistic` (the `statistic` field gives mean, sd, se, median, min, max or value)
  - `n` (the `unit` field gives the basis, e.g. individuals)
  - `region_printed`
  - `measure_printed`
  - `value_printed`
  - `unit_printed`
  - `specimen_id` (rows become `individual`)
  - `hemisphere`
  - `sex`
  - `age`
  - `note`
  - `DROP`
- **Long-shaped tables** (one row per variable, like Munger) have one `row_key` column. Each routed key value then needs a `row_value` row giving its measure, cell class, marker, region, layer and unit.
- **Wide tables** (one column per measure, like most species tables) map each value column directly to a measure code and fill in `statistic`, `cell_class`, `marker`, `region`, `layer` and `unit`.
- The unit must equal the measure's unit in `measures.csv`; per-mm2 and per-mg values are different measures. A region/layer pair must exist in `regions.csv`; add the row there first.

Next candidates, all routed and published:
- Lewitus et al. 2012 Table 4 and Table S1A;
- Lewitus et al. 2012b Table 2 and Table S3;
- Bjugn 1993;
- West & Gundersen 1990;
- Slomianka et al. 2013;
- Sherwood et al. 2020 Supplementary Table 2.

Sherwood et al. 2006 Table 2 and Semendeferi et al. 1998 Table 5 come in **off by default** (`STEREO_DISECTOR`, treatment set in the key).

## Run

```sh
Rscript __merging_cell_counts_histology/cell_counts_histology_compiled.R
Rscript _keys/build_variable_definitions.R
```

Then run Update_ShinyApp. The app reads `cell_counts_histology_long.csv` directly; nothing is copied into `__ShinyApp/data/`.

Checks for a run:
- `cell_counts_histology_long.csv` should have the same 56 rows and values.
- The routing file should read 28 / 12 / 8.
- The pending file should list 30 rows.
- `variable_domain.csv` should end with the same 7 "Cell counts (histology)" rows.

The first R run (4 Nov 2026) matched on every point. After any later change, the R output is authoritative.

## Provenance

Built on 4 November 2026 by an AI assistant (Microsoft Copilot) for Alexandra de Sousa (owner). It follows the counting-method split she decided that day, and her rule that sources are kept, discrepancies flagged and nothing balanced. Patterns are taken from `__merging_cell_morphology` (term maps, `resolve_species`) and `__merging_supplementary` (the `variable_domain` step).
