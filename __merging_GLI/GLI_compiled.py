"""
Merge grey-level index (GLI) items into __merging_GLI outputs.

Sources (all data_role = primary):
  - PalomeroGallagher_Zilles_2018_TableS3.csv   (area 44/45, per-specimen)
  - Semendeferi_etal_1998_TABLE4.csv            (area 13, species-level)
  - Semendeferi_etal_2001_TABLE3.csv            (area 10, species-level)
  - Sherwood_etal_2004_I_Table4.csv             (area 4/M1, species-level, agranular
                                                  -- no granular-layer stratum)
  - Zilles_etal_1986_Table2.csv                 (posterior cingulate areas 29/30/23/31,
                                                  species-level, 17 species; areas 29/30
                                                  are agranular -- no granular-layer stratum)

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

## Zilles et al. 1986 Table 2: grey-level indices for outer-main (O), granular (G, areas 23/31
## only), and inner-main (I) laminae of the posterior cingulate areas 29, 30, 23, and 31, 17
## species. No overall "all layers" mean is printed. The molecular layer (Table 1's "M" column)
## has no GLI in Table 2 -- the paper states it was too low/high-error to measure (p.519) -- so
## there is no molecular-layer stratum to carry here. O is mapped to supragranular and I to
## infragranular, matching this merge's layer-group convention (areas 29/30 are allo-/proiso-
## cortex and have no granular layer, so GLI_pct_mean_granular is NA for those two areas, same
## treatment as Sherwood's agranular M1). "Papio sp." is kept as published (genus-level only,
## not resolved to a binomial) -- a known limitation, not an error.
zilles2 = pd.read_csv(os.path.join(ROOT, "Zilles_etal_1986", "Zilles_etal_1986_Table2.csv"))
zilles_n_specimens = {
    "Perodicticus potto": 2, "Callithrix jacchus": 2, "Cercopithecus mitis": 3,
    "Macaca mulatta": 2, "Papio sp.": 2,
}  ## from Materials and Methods (p.514); all other species n=1.
zilles_areas = {
    "area29": ("area29_outer_main_GLI", None, "area29_inner_main_GLI", "area29_posterior_cingulate"),
    "area30": ("area30_outer_main_GLI", None, "area30_inner_main_GLI", "area30_posterior_cingulate"),
    "area23": ("area23_outer_main_GLI", "area23_granular_GLI", "area23_inner_main_GLI", "area23_posterior_cingulate"),
    "area31": ("area31_outer_main_GLI", "area31_granular_GLI", "area31_inner_main_GLI", "area31_posterior_cingulate"),
}
zilles_blocks = []
for area_key, (o_col, g_col, i_col, area_label) in zilles_areas.items():
    zilles_blocks.append(pd.DataFrame({
        "Species": zilles2["Species"],
        "species_as_published": zilles2["Species"],
        "specimen_as_published": zilles2["Species"],
        "area_as_published": area_label,
        "n_specimens": zilles2["Species"].map(lambda s: zilles_n_specimens.get(s, 1)),
        "GLI_pct_mean_all_layers": np.nan,
        "GLI_pct_mean_supragranular": zilles2[o_col],
        "GLI_pct_mean_granular": zilles2[g_col] if g_col else np.nan,
        "GLI_pct_mean_infragranular": zilles2[i_col],
        "source_location": f"Table 2, {area_key}",
        "data_role": "primary",
    }))
zilles_wide = pd.concat(zilles_blocks, ignore_index=True)
zilles_wide["source"] = "Zilles_etal_1986_Table2"
zilles_wide["source_role"] = "added_this_pass"

wide = pd.concat([pg, sem98, sem01, sherwood_wide, zilles_wide], ignore_index=True)

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
