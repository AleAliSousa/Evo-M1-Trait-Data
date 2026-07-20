# Baker_etal_2025 — Build Handoff

*Last updated: 2026-07-20. Scope: Evo-M1-Trait-Data comparative-trait repo.*

## What this is

**Baker, Barton & Venditti 2025** — "Human dexterity and brains evolved hand in hand," *Communications Biology*, DOI [10.1038/s42003-025-08686-5](https://doi.org/10.1038/s42003-025-08686-5). A **secondary compilation** of primate hand morphology and dexterity, built to house convention in `Baker_etal_2025/`.

- **Item name:** `Baker_etal_2025_SupplementaryData1`
- **Source:** the MOESM3 xlsx supplement, 2 sheets — `Data` (178 taxa) and `References` (40 numbered primary sources + 3 global behavioural sources).
- **Main traits:** hand morphology & dexterity. Also carries brain/body/neocortex/cerebellum columns sourced from the Venditti/Barton and Stephan–Frahm lineages.

## Build state — DONE

The source table is fully built and reproducible.

**Reference resolution (this is a secondary paper).** Data-cell reference tokens in the `Bone References` (1–25, 40) and `Brain References` (26–39) columns key into sheet 2. The build keeps raw tokens in `Bone_References` / `Brain_References`, expands short citations in the `*_References_resolved` columns, and transcribes full primaries to `reference_tables/Baker_etal_2025_references.csv`. Special cases: ref 6 = Rolian pers. comm.; ref 32 = Stephan/Frahm volume series.

**Restricted data — important.** Ref 40 = Lemelin 1996 dissertation is **restricted**. 26 taxa have hand values withheld (marked `*` in source) → parsed to `NA` and flagged `bone_data_restricted=TRUE`. Values are left in the published **log10** units (mm/g/cm³) and are **not** back-transformed.

**Outputs produced:** `snapshot.xlsx`, the reproducible `.R` script (sandbox has no R, so CSV/TSV were generated in Python to match the R logic — R remains canonical), the `.csv` (178×45), the DOI TSV in `__Public/comparative-data/`, plus README and definitions.

**Registry (`__ReadMe.xlsx`, row 5) — FILLED** via surgical inline-string XML edit (deliberately **not** an openpyxl round-trip, because cols E–M are live formulas and M5 is an array formula). Progress=FINISHED, Snapshot, Data-readable file, Source Type=xlsx, Main Trait(s)=hand morphology & dexterity, Data role=secondary, etc. **Team left blank** on purpose, matching the other secondary compilations (Caspar / Heldstab / Granatosky) — Team tags primary collection lineages, not secondary compilations. Backup saved as `__ReadMe.pre_bakerfill.bak.xlsx`.

**Known loose end in the registry:** `Item in directory FileList` still shows `notfound` because the FileList sheet (sheet2) has not been updated with the new TSV. That's a separate manual step.

## Species overlap (dexterity combinability)

Join is on `Species` binomial, normalized `Genus species`. Baker is dexterity-central and overlaps the already-built datasets:

- Caspar_etal_2022 handedness — **28** shared species
- Heldstab_etal_2016 manipulation complexity — **27** shared
- ManyPrimates_2022 cognition/predictors — **32** shared
- Granatosky_2018 locomotion — **62** shared
- 16 species have Baker + handedness + manipulation together

Taxonomy watch-outs: Sapajus / Cebus apella and Pongo pygmaeus / abelii synonymy (see the specimen-taxon-tracking notes). Baker's brain/body/neocortex/cerebellum values come from Venditti 2024 / Barton & Venditti 2014 / the Stephan–Frahm series, overlapping the volume-merge lineage.

## OPEN — fold Baker into the Shiny trait table

This is the work that was paused to restart as a new task. It is **not** started.

**Target architecture** (per the shiny-app build): behaviour is a keyed merge, `__merging_behaviour/behaviour_long.csv` (schema like `body_ecology_long`), loaded by the app via `std_merge(GH$behaviour, …, "Behaviour")`. Inputs are `____EvoM1_TraitTable/*.xlsx` files (columns `species_sci`, `Species`, `<measures>`), each written by an `EvoM1_read_*.R`; `behaviour_compiled.R` holds `grab()` / `META` / `TEAM` for each measure.

**Steps to add Baker:**

1. New `EvoM1_read_dexterity_baker.R` → `dexterity_baker.xlsx`.
2. Add `grab()` + `META` + `TEAM` rows in `behaviour_compiled.R`.
3. If merging tool-use, add Baker as a source under a multi-source `Tool_use` measure (currently Heldstab-only, presence 0/1).

Brain/body/neocortex/cerebellum do **not** belong here (they go through the volume/mass merges); binocularity is sensory, not dexterity. No R in the build env, so materialize via a Python port with the R scripts canonical; the user runs `Rscript __ShinyApp/build_data.R` to reproduce and push.

### Two scope decisions still needed (asked, deferred)

1. **Which Baker vars to expose.** Candidates: `Tool_use` / `Tool_manufacture` / `True_tool_use` (Bentley-Condit 2010), `peak_workspace` (Feix 2015), `relative_size` / `real_size` (derived), and the raw 24 log10 hand-bone lengths.
2. **Whether Baker `Tool_use` merges keyed with Heldstab's `Tool_use` or stays a separate column.** Heldstab's `manipulation.xlsx` columns are `Manipulation_complexity` / `Tool_use` / `Extractive_foraging` (37 spp).

## Note for whoever picks this up

The full Evo-M1-Trait-Data repo was **not** mounted in the session that produced this handoff (only `Baron_etal_1983` was accessible), so this document is written from the build record, not from a live re-read of the files. Re-mount the repo root before continuing the Shiny fold.
