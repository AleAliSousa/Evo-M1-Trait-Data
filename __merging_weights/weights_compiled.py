"""
weights_compiled.py -- brain PART (sub-regional) wet-weight merge.

Compiles brain-part mass across species from three primary source tables,
distinct from __merging_brain_mass/ (whole-brain mass only -- not duplicated
here). Re-run after any source table changes.

Sources:
  1. Latimer__1942_TABLEI.csv              -- dog brain-part + spinal-cord weights, mg,
                                                sex-specific (measured). Rebuilt from the
                                                originally two-item split into ONE unified item
                                                matching the paper's single printed table.
  2. Latimer__1956_Table2.csv               -- brain stem / prosencephalon / cerebellum weights,
                                                mg, 10 taxa frog-to-human (7 measured by Latimer,
                                                3 secondary-cited: rat/baboon/man -- role follows
                                                each row's own data_role)
  3. HerculanoHouzel_etal_2015_Table1-4.csv -- cerebral cortex / cerebellum / RoB / olfactory
                                                bulb mass, g, many mammals (measured)
  4. Kverkova_etal_2018_TableS1.csv        -- part VOLUME as %-of-brain; part mass DERIVED as
                                                Brain_Mass.g x fraction (flagged role="derived")

Excluded (see README__merging.md for rationale):
  - HerculanoHouzel_etal_2015_Table5.csv    (whole-brain mass -- __merging_brain_mass's domain)
  - HerculanoHouzel_etal_2020_TABLE1/2.csv  (neuron counts only, no part-mass column)

Units: everything normalized to mg (project unit for brain-part weight; see
_skills/build-dataset-item/references/__HOWTO_build_a_dataset_file.md section 6).

Outputs (all in __merging_weights/):
  weights_long.csv         one row per (species, structure, source)
  weights_wide.csv         species x canonical-structure mean mass_mg
  weights_qa_dedupe.csv    cross-source agreement/disagreement report
"""
import pandas as pd, numpy as np, os

root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

latimer = pd.read_csv(f"{root}/Latimer__1942/Latimer__1942_TABLEI.csv")
latimer56 = pd.read_csv(f"{root}/Latimer__1956/Latimer__1956_Table2.csv")
hh1 = pd.read_csv(f"{root}/HerculanoHouzel_etal_2015/HerculanoHouzel_etal_2015_Table1.csv")
hh2 = pd.read_csv(f"{root}/HerculanoHouzel_etal_2015/HerculanoHouzel_etal_2015_Table2.csv")
hh3 = pd.read_csv(f"{root}/HerculanoHouzel_etal_2015/HerculanoHouzel_etal_2015_Table3.csv")
hh4 = pd.read_csv(f"{root}/HerculanoHouzel_etal_2015/HerculanoHouzel_etal_2015_Table4.csv")
kverkova = pd.read_csv(f"{root}/Kverkova_etal_2018/Kverkova_etal_2018_TableS1.csv")
hhkey = pd.read_csv(f"{root}/_keys/HerculanoHouzel/species_key.csv")

hh_map = dict(zip(hhkey.variant_name, hhkey.accepted_name))
def hh_species(name):
    return hh_map.get(name, name)

structure_map_latimer = {
    "Brain": None,                    # whole brain -- covered by __merging_brain_mass
    "Olfactory bulbs": "OlfactoryBulb",
    "Hemispheres and dien.": None,    # no canonical match yet -- gap
    "Prosencephalon": None,           # no canonical match yet -- gap
    "Mesencephalon": "Mesencephalon",
    "Cerebellum": "Cerebellum",
    "Medulla": "Medulla",
    "Rhombencephalon": None,          # no canonical match yet -- gap
    "Cord weight": "SpinalCord",
}

structure_map_latimer56 = {
    "brain_stem": None,        # no canonical "BrainStem" token yet -- gap
    "prosencephalon": None,    # same gap as the 1942 item
    "cerebellum": "Cerebellum",
}

rows = []

# 1. Latimer 1942 (unified brain+cord table) -- sexes kept as separate observations (see README);
# mass rows only (measure == "mass"); Body weight excluded (whole-organism, not a brain part);
# Cord length / Body length excluded (length, not mass).
for _, r in latimer.iterrows():
    structure_printed = r["structure_as_published"]
    if r["measure"] != "mass" or structure_printed in ("Brain", "Body weight"):
        continue
    canon = structure_map_latimer.get(structure_printed)
    rows.append({
        "Species": r["Species"], "species_as_published": r["species_as_published"],
        "canonical_structure": canon if canon is not None else "",
        "structure_as_published": structure_printed,
        "mass_mg": r["value_mean_mg"], "mass_se_mg": r["value_se_mg"],
        "n": r["n"], "sex": r["sex"], "unit_original": "mg", "conversion_factor_to_mg": 1,
        "role": "primary", "derivation": "measured",
        "source": "Latimer__1942_TABLEI.csv", "citation": "Latimer (1942)",
        "mapping_gap": "" if canon is not None else f"no canonical structure yet for '{structure_printed}'",
    })

# 1b. Latimer 1956 -- brain stem / prosencephalon / cerebellum, 10 taxa. Role follows each row's
# own data_role (7 taxa are Latimer's own dissections = primary; rat/baboon/man are the paper's
# own cited secondary values). Species left as printed for Frog/Turtle (no binomial given).
for _, r in latimer56.iterrows():
    for col, structure_key, canon_label in [
        ("weight_brain_stem_mg", "brain_stem", "BrainStem"),
        ("weight_prosencephalon_mg", "prosencephalon", "Prosencephalon"),
        ("weight_cerebellum_mg", "cerebellum", "Cerebellum"),
    ]:
        mass_mg = r[col]
        if pd.isna(mass_mg):
            continue
        canon = structure_map_latimer56[structure_key]
        species = r["Species"] if isinstance(r["Species"], str) and r["Species"] else r["species_as_published"]
        rows.append({
            "Species": species, "species_as_published": r["species_as_published"],
            "canonical_structure": canon if canon is not None else "",
            "structure_as_published": canon_label, "mass_mg": mass_mg, "mass_se_mg": np.nan,
            "n": np.nan, "sex": "", "unit_original": "mg", "conversion_factor_to_mg": 1,
            "role": r["data_role"], "derivation": "measured" if r["data_role"] == "primary" else f"secondary citation: {r['secondary_source']}",
            "source": "Latimer__1956_Table2.csv", "citation": "Latimer (1956)",
            "mapping_gap": ("" if canon is not None else f"no canonical structure yet for '{canon_label}'")
                           + ("" if isinstance(r["Species"], str) and r["Species"] else " | no binomial given in source for this taxon"),
        })

# 2. Herculano-Houzel et al. 2015 Tables 1-4
hh_specs = [
    (hh1, "Cerebral cortex Mass, g", "Cerebral cortex Mass, g SD", "CerebralCortex", "Cerebral cortex",
     "HerculanoHouzel_etal_2015_Table1.csv"),
    (hh2, "Cerebellum Mass, g", "Cerebellum Mass, g SD", "Cerebellum", "Cerebellum",
     "HerculanoHouzel_etal_2015_Table2.csv"),
    (hh3, "RoB Mass, g", "RoB Mass, g SD", "RoB", "Rest of brain (RoB)",
     "HerculanoHouzel_etal_2015_Table3.csv"),
    (hh4, "Olfactory bulb Mass, g", "Olfactory bulb Mass, g SD", "OlfactoryBulb", "Olfactory bulb",
     "HerculanoHouzel_etal_2015_Table4.csv"),
]
for df, col, sdcol, canon, printed, srcfile in hh_specs:
    n_col = "Whole brain n" if "Whole brain n" in df.columns else ("Olfactory bulb n" if "Olfactory bulb n" in df.columns else None)
    for _, r in df.iterrows():
        mass_g = r[col]
        if pd.isna(mass_g):
            continue
        sd_g = r.get(sdcol, np.nan)
        rows.append({
            "Species": hh_species(r["Species"]), "species_as_published": r["Species"],
            "canonical_structure": canon, "structure_as_published": printed,
            "mass_mg": mass_g * 1000, "mass_se_mg": (sd_g * 1000) if pd.notna(sd_g) else np.nan,
            "n": r[n_col] if n_col else np.nan, "sex": "pooled/unspecified",
            "unit_original": "g", "conversion_factor_to_mg": 1000,
            "role": "primary", "derivation": "measured",
            "source": srcfile, "citation": "Herculano-Houzel et al. (2015)", "mapping_gap": "",
        })

# 3. Kverkova et al. 2018 -- derived part mass = Brain_Mass.g x %-of-brain volume fraction
kv_structure_map = {
    "Olfactory bulbs": "OlfactoryBulb", "Olfactory cortices": "OlfactoryCortices",
    "Neocortex": "Neocortex", "Entorhinal cortex": "EntorhinalCortex", "Hippocampus": "Hippocampus",
    "Amygdala": "Amygdala", "Striatum": "Striatum", "Septum": "Septum", "Thalamus": "Thalamus",
    "Hypothalamus": "Hypothalamus", "Cerebellum": "Cerebellum", "Tectum": "Tectum",
    "Tegmentum": "Tegmentum", "Medulla oblongata": "Medulla",
}
for _, r in kverkova.iterrows():
    brain_mass_g = r["Brain_Mass.g"]
    for printed, canon in kv_structure_map.items():
        pcol = f"{printed}_p.C.Brain"
        if pcol not in kverkova.columns:
            continue
        frac = r[pcol]
        if pd.isna(frac) or pd.isna(brain_mass_g):
            continue
        mass_g_derived = brain_mass_g * frac
        rows.append({
            "Species": hh_species(r["Species"]), "species_as_published": r["Species"],
            "canonical_structure": canon, "structure_as_published": printed,
            "mass_mg": mass_g_derived * 1000, "mass_se_mg": np.nan, "n": np.nan,
            "sex": "pooled/unspecified",
            "unit_original": "g (derived: Brain_Mass.g x p.C.Brain volume-fraction)",
            "conversion_factor_to_mg": 1000, "role": "derived",
            "derivation": (f"Brain_Mass.g({brain_mass_g}) x {printed}_p.C.Brain({frac}) -- "
                            "volume-fraction of brain applied to brain MASS as a "
                            "density-homogeneity approximation, not an independently measured part mass"),
            "source": "Kverkova_etal_2018_TableS1.csv", "citation": "Kverkova et al. (2018)",
            "mapping_gap": "",
        })

long_df = pd.DataFrame(rows)
long_df["mass_g"] = long_df["mass_mg"] / 1000.0
cols = ["Species", "species_as_published", "canonical_structure", "structure_as_published",
        "mass_mg", "mass_g", "mass_se_mg", "n", "sex", "unit_original", "conversion_factor_to_mg",
        "role", "derivation", "source", "citation", "mapping_gap"]
long_df = long_df[cols]
long_df.to_csv(f"{root}/__merging_weights/weights_long.csv", index=False)

# ---- wide summary + QA/dedupe report ----
canon_df = long_df[long_df["canonical_structure"] != ""].copy()
grp = canon_df.groupby(["Species", "canonical_structure"])

wide_records, qa_full = [], []
for (sp, struct), g in grp:
    primary = g[g.role == "primary"]
    use = primary if len(primary) > 0 else g
    wide_records.append({
        "Species": sp, "canonical_structure": struct,
        "mean_mass_mg": use["mass_mg"].mean(), "n_sources": g["source"].nunique(),
        "sources": "; ".join(sorted(g["source"].unique())),
        "roles_present": "; ".join(sorted(g["role"].unique())),
        "primary_preferred": len(primary) > 0,
    })
    if g["source"].nunique() > 1:
        vmin, vmax = g["mass_mg"].min(), g["mass_mg"].max()
        ratio = vmax / vmin if vmin > 0 else np.nan
        qa_full.append({
            "Species": sp, "canonical_structure": struct, "n_sources": g["source"].nunique(),
            "min_mass_mg": vmin, "max_mass_mg": vmax, "ratio_max_min": round(ratio, 4),
            "sources": "; ".join(sorted(g["source"].unique())),
            "roles": "; ".join(sorted(g["role"].unique())),
            "flag": "DISAGREEMENT>2x" if ratio >= 2 else "agree (<2x)",
        })

wide_long_style = pd.DataFrame(wide_records)
wide_df = wide_long_style.pivot(index="Species", columns="canonical_structure", values="mean_mass_mg").reset_index()
wide_df.columns = ["Species"] + [f"{c}_Mass.mg" for c in wide_df.columns[1:]]
wide_df.to_csv(f"{root}/__merging_weights/weights_wide.csv", index=False)

qa_df = pd.DataFrame(qa_full)
qa_df.to_csv(f"{root}/__merging_weights/weights_qa_dedupe.csv", index=False)

print(f"long={len(long_df)} wide={len(wide_df)} qa={len(qa_df)}")
