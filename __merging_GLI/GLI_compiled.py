"""
Merge grey-level index (GLI) items into __merging_GLI outputs.

Sources (all data_role = primary):
  - PalomeroGallagher_Zilles_2018_TableS3.csv   (area 44/45, per-specimen)
  - Semendeferi_etal_1998_TABLE4.csv            (area 13, species-level)
  - Semendeferi_etal_2001_TABLE3.csv            (area 10, species-level)
  - Sherwood_etal_2004_I_Table4.csv             (area 4/M1, species-level, agranular
                                                  -- no granular-layer stratum)

Run from repo root:  python __merging_GLI/GLI_compiled.py
"""
import os
import pandas as pd
import numpy as np

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.dirname(os.path.abspath(__file__))

pg = pd.read_csv(os.path.join(ROOT, "PalomeroGallagher_Zilles_2018", "PalomeroGallagher_Zilles_2018_TableS3.csv"))
pg["source"] = "PalomeroGallagher_Zilles_2018_TableS3"
pg["source_role"] = "founder"

sem98 = pd.read_csv(os.path.join(ROOT, "Semendeferi_etal_1998", "Semendeferi_etal_1998_TABLE4.csv"))
sem98["source"] = "Semendeferi_etal_1998_TABLE4"
sem98["source_role"] = "added_this_pass"

sem01 = pd.read_csv(os.path.join(ROOT, "Semendeferi_etal_2001", "Semendeferi_etal_2001_TABLE3.csv"))
sem01["source"] = "Semendeferi_etal_2001_TABLE3"
sem01["source_role"] = "added_this_pass"

## Sherwood et al. 2004(I) Table 4: M1 (area 4) is agranular cortex -- layers II/III/V/VI only,
## no layer IV/granular stratum. Already built (pre-existing item, FINISHED before this session);
## remapped onto the same species x area x stratum schema (supragranular = mean(II,III),
## infragranular = mean(V,VI), granular = NA, all_layers = printed "Cortical mean").
sherwood = pd.read_csv(os.path.join(ROOT, "Sherwood_etal_2004_I", "Sherwood_etal_2004_I_Table4.csv"))
species_key = {
    "Macaca fascicularis": "Macaca fascicularis", "Papio anubis": "Papio anubis",
    "Pongo pygmaeus": "Pongo pygmaeus", "Gorilla gorilla": "Gorilla gorilla",
    "Pan troglodytes": "Pan troglodytes", "Homo sapiens": "Homo sapiens",
}
sherwood_wide = pd.DataFrame({
    "Species": sherwood["Species"].map(species_key),
    "species_as_published": sherwood["Species"],
    "specimen_as_published": sherwood["Species"],
    "area_as_published": "area4_M1",
    "n_specimens": sherwood["n"],
    "GLI_pct_mean_all_layers": sherwood["Cortical mean"],
    "GLI_pct_mean_supragranular": sherwood[["Layer II", "Layer III"]].mean(axis=1),
    "GLI_pct_mean_granular": np.nan,   ## agranular cortex -- no layer IV
    "GLI_pct_mean_infragranular": sherwood[["Layer V", "Layer VI"]].mean(axis=1),
    "source_location": "Table 4 (\"GLI values for each cortical layer\"), M1",
    "data_role": "primary",
})
sherwood_wide["source"] = "Sherwood_etal_2004_I_Table4"
sherwood_wide["source_role"] = "added_this_pass"

wide = pd.concat([pg, sem98, sem01, sherwood_wide], ignore_index=True)

STRATUM_COLS = {
    "GLI_pct_mean_all_layers": "all_layers",
    "GLI_pct_mean_supragranular": "supragranular",
    "GLI_pct_mean_granular": "granular",
    "GLI_pct_mean_infragranular": "infragranular",
}

long_rows = []
for _, row in wide.iterrows():
    for col, stratum in STRATUM_COLS.items():
        val = row[col]
        if pd.isna(val):
            continue
        long_rows.append({
            "Species": row["Species"],
            "species_as_published": row["species_as_published"],
            "specimen_as_published": row["specimen_as_published"],
            "area_as_published": row["area_as_published"],
            "n_specimens": row["n_specimens"],
            "stratum": stratum,
            "GLI_pct": val,
            "source": row["source"],
            "source_role": row["source_role"],
            "source_location": row["source_location"],
            "data_role": row["data_role"],
        })
gli_long = pd.DataFrame(long_rows)
gli_long.to_csv(os.path.join(OUT, "GLI_long.csv"), index=False)
print(f"GLI_long.csv: {len(gli_long)} rows")

qa = (gli_long.groupby(["Species", "area_as_published", "stratum"], as_index=False)
      .agg(GLI_pct_species_mean=("GLI_pct", "mean"),
           n_specimens_contributing=("GLI_pct", "size"),
           source=("source", "first")))
qa.to_csv(os.path.join(OUT, "GLI_species_area_stratum_comparison_qa_long.csv"), index=False)

qa_wide = qa.pivot_table(index=["Species", "source"], columns=["area_as_published", "stratum"],
                          values="GLI_pct_species_mean")
qa_wide.columns = ["_".join(c) for c in qa_wide.columns]
qa_wide = qa_wide.reset_index()
qa_wide.to_csv(os.path.join(OUT, "GLI_species_area_stratum_comparison_qa_wide.csv"), index=False)
print(f"QA wide table: {qa_wide.shape[0]} species x source rows")
