# Cerebellar folding merge

Dedicated, single-team table for Heuer et al. 2023. Run:

```sh
Rscript Heuer_etal_2023/Heuer_etal_2023_Data.R
Rscript __merging_cerebellar_folding/cerebellar_folding_compiled.R
```

The output uses the standard merge-long schema consumed by the Shiny app. These measurements are
kept separate from Ashwell 2020's foliation index and from neocortical gyrification because the
measurement procedures are not interchangeable.
