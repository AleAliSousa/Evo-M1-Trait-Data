# Cortical-layer thickness merge - M1 first

This merge compiles the layer-thickness tables that accompany the Jacobs comparative neuronal-
morphology lineage while keeping them separate from soma, dendrite and spine traits.

## Initial source set

| Source | Species/aggregation | Regions retained | Source granularity |
|---|---|---|---|
| Jacobs et al. 2015 Table 1 | giraffe | M1, V1 | three-subadult species summary |
| Jacobs et al. 2016 Table 1 | newborn giraffe, newborn elephant | M1, V1, frontal, occipital | one specimen per species |
| Johnson et al. 2016 Table 1 | Siberian tiger, clouded leopard | M1, V1, prefrontal | one tiger; two-leopard species summary |
| Peruffo et al. 2019 Table 2 | sheep | M1 | six individuals plus printed mean |
| Hutsler et al. 2005 reported values | 13-species and order summaries | M1 | group summaries only |

The first four sources provide species-level M1 data. Hutsler is appended only to
`cortical_layers_m1_long.csv` with `taxon_level` equal to `order` or `cross-species summary`; it is
never promoted into the species-wide output.

## Outputs

- `cortical_layers_all_regions_long.csv`: 175 rows from the four focal source tables, including
  every published region.
- `cortical_layers_m1_species_long.csv`: 119 species-level M1 rows, including individual sheep.
- `cortical_layers_m1_long.csv`: the species-level rows plus six compatible Hutsler group summaries.
- `cortical_layers_m1_observations_wide.csv`: 12 M1 observations, retaining six individual sheep
  and the paper's sheep mean.
- `cortical_layers_m1_species_summary_wide.csv`: six default source summaries for comparative use.
- `cortical_layers_m1_qa.csv`: printed total minus the sum of printed layer values.
- `cortical_layers_peruffo_mean_reconciliation.csv`: printed Average versus the arithmetic mean of
  the six displayed sheep.
- `cortical_layers_peruffo_proportion_reconciliation.csv`: printed percentages versus displayed
  layer thickness divided by displayed total.

## Merge rules

1. `region` is explicit. M1 is `primary motor cortex`; V1, prefrontal, frontal and occipital rows
   remain available but are not mixed into M1.
2. `age_class` and `age_detail` are explicit. Newborn, subadult and adult giraffe records remain
   separate observations.
3. `observation_level` and `n_specimens` distinguish individuals, single-specimen summaries and
   multi-specimen summaries.
4. Layer-IV absence is categorical (`layer_status = absent`) with a missing numerical value. It is
   not silently converted to zero. This matters because Hutsler's pooled M1 sample has a nonzero
   mean layer-IV proportion even though all four focal M1 sources describe agranular cortex.
5. `merge_default = FALSE` for the six individual Peruffo sheep and for Hutsler group summaries.
   The printed Peruffo six-animal mean is the default row, preventing double counting.
6. Published totals and layer means are retained independently. Small nonzero QA differences are
   expected when the paper rounded or averaged them separately; no total is recomputed.
7. Peruffo's printed Average and percentages are also retained independently because they do not
   always reproduce simple calculations from the displayed individual rows.

## Rebuild

Run from the repository root:

```sh
Rscript Jacobs_etal_2015/Jacobs_etal_2015_Table1.R
Rscript Jacobs_etal_2016/Jacobs_etal_2016_Table1.R
Rscript Johnson_etal_2016/Johnson_etal_2016_Table1.R
Rscript Peruffo_etal_2019/Peruffo_etal_2019_Table2.R
Rscript __merging_cortical_layers/cortical_layers_compiled.R
```

Each source build writes a local CSV and DOI-named public TSV. `__ReadMe.xlsx` already contains the
Jacobs 2015 Table 1 item. The three new registry rows are staged in
`__ReadMe_rows_to_add_cortical_layers.csv`; they have not been inserted automatically because the
registry's formula columns must be filled in Excel without overwriting cached formulas.

## EndNote audit

The EndNote SQLite records and attachment index were queried by title and DOI. Only Jacobs 2015 was
present. The other three PDFs were obtained from open institutional or publisher copies and stored
in their source folders.
