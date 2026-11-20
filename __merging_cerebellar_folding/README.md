# Cerebellar folding merge

Two-team table, one team per measurement procedure — the procedures are not
interchangeable, so the teams' values are carried under **separate Measure
names and are never pooled**:

- **Heuer et al. 2023** — mid-section areas/lengths and folial measures from
  MRI section morphometry (7 Measures, Teams = "Heuer2023").
- **Ashwell 2020** — cerebellar foliation index (total pial surface area PSA
  ÷ external surface area ESA, both from histological sections) plus the PSA
  and ESA themselves (3 Measures, Teams = "Ashwell2020"; added 2026-11-19).

Both are also kept separate from neocortical gyrification (Zilles GI, Mota FI).

Run:

```sh
Rscript Heuer_etal_2023/Heuer_etal_2023_Data.R
Rscript __merging_cerebellar_folding/cerebellar_folding_compiled.R
```

The output uses the standard merge-long schema consumed by the Shiny app
(`std_merge()` dataset "Cerebellar folding": every Measure in the long file
surfaces as its own app variable, so the Ashwell Measures need no app change).
