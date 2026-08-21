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

**Registry refresh:** run `_tools/file_list.R`; it rebuilds `AUTO_Public_TSV_FileList` directly
from `__Public/comparative-data/*.tsv`. Never add the filename to the workbook manually.

## Species overlap (dexterity combinability)

Join is on `Species` binomial, normalized `Genus species`. Baker is dexterity-central and overlaps the already-built datasets:

- Caspar_etal_2022 handedness — **28** shared species
- Heldstab_etal_2016 manipulation complexity — **27** shared
- ManyPrimates_2022 cognition/predictors — **32** shared
- Granatosky_2018 locomotion — **62** shared
- 16 species have Baker + handedness + manipulation together

Taxonomy watch-outs: Sapajus / Cebus apella and Pongo pygmaeus / abelii synonymy (see the specimen-taxon-tracking notes). Baker's brain/body/neocortex/cerebellum values come from Venditti 2024 / Barton & Venditti 2014 / the Stephan–Frahm series, overlapping the volume-merge lineage.

## DONE (2026-07-20) — Baker folded into the Shiny behaviour trait table

Completed as its own task. Scope decisions (below) were resolved by the user: **expose all** candidate
variables, and **key Tool_use** as one multi-source measure (Heldstab primary + Baker secondary).

What was built:

- **`____EvoM1_TraitTable/EvoM1_read_dexterity_baker.R`** (canonical) → **`dexterity_baker.xlsx`**
  (178 taxa; `species_sci` resolved via `_keys`). Exposes `Tool_Use`, `Tool_Manufacture`,
  `True_Tool_Use`, `peak_workspace`, `relative_size`, `real_size`, and the **19** `log10_*_mm`
  hand-bone lengths. (Note: **19**, not 24 — digit 1/thumb has no intermediate phalanx; the earlier
  "24" was wrong.) No R in the build env, so the xlsx was materialized by a Python port; the R script
  is canonical.
- **`__merging_behaviour/behaviour_compiled.R`** edited: added `baker` to `TEAM`; added
  `Tool_Manufacture`/`True_Tool_Use` to `CATEG`; added the Baker `grab()` calls (incl. a loop over the
  bone columns); added `META` rows; and set `Tool_use` priority to `heldstab`(primary)+`baker`(secondary).
- **Regenerated** `behaviour_long.csv` / `behaviour_observations_long.csv` / `behaviour_wide.csv`
  (Python port matching the R logic) and copied `behaviour_long.csv` into `__ShinyApp/data/`. New
  measure classes: `manipulation` (tool-use presence) and `hand_morphology` (workspace/size/bones).
- **Verified:** 13 pre-existing measures are **byte-identical** to the pre-Baker baseline (zero
  regression); `Tool_use` grew 37→188 species with the resolved value unchanged on all 37 baseline
  species (Heldstab primary wins) and Baker-only species flagged `secondary`/`primary_used=False`.
  Table is now **2,760 rows over 406 species, 38 measures**.

Rebuild path unchanged: user runs `Rscript __ShinyApp/build_data.R` to reproduce from the canonical R
scripts and push. The app has no measure whitelist, so the new measures appear automatically under the
**Behaviour** dataset.

### Historical note — the original OPEN plan (now completed)

The work below was paused to restart as a new task; it has since been done as described above.

**Target architecture** (per the shiny-app build): behaviour is a keyed merge, `__merging_behaviour/behaviour_long.csv` (schema like `body_ecology_long`), loaded by the app via `std_merge(GH$behaviour, …, "Behaviour")`. Inputs are `____EvoM1_TraitTable/*.xlsx` files (columns `species_sci`, `Species`, `<measures>`), each written by an `EvoM1_read_*.R`; `behaviour_compiled.R` holds `grab()` / `META` / `TEAM` for each measure.

**Steps to add Baker:**

1. New `EvoM1_read_dexterity_baker.R` → `dexterity_baker.xlsx`.
2. Add `grab()` + `META` + `TEAM` rows in `behaviour_compiled.R`.
3. If merging tool-use, add Baker as a source under a multi-source `Tool_use` measure (currently Heldstab-only, presence 0/1).

Brain/body/neocortex/cerebellum do **not** belong here (they go through the volume/mass merges); binocularity is sensory, not dexterity. No R in the build env, so materialize via a Python port with the R scripts canonical; the user runs `Rscript __ShinyApp/build_data.R` to reproduce and push.

### Two scope decisions — RESOLVED 2026-07-20

1. **Which Baker vars to expose.** → **All of them** (tool-use set + peak_workspace + relative/real_size
   + the 19 log10 bone lengths). Candidates were: `Tool_use` / `Tool_manufacture` / `True_tool_use` (Bentley-Condit 2010), `peak_workspace` (Feix 2015), `relative_size` / `real_size` (derived), and the raw 24 log10 hand-bone lengths.
2. **Whether Baker `Tool_use` merges keyed with Heldstab's `Tool_use` or stays a separate column.** → **Keyed** as one multi-source measure (Heldstab primary, Baker secondary). Heldstab's `manipulation.xlsx` columns are `Manipulation_complexity` / `Tool_use` / `Extractive_foraging` (37 spp).

## Note for whoever picks this up

The full Evo-M1-Trait-Data repo was **not** mounted in the session that produced this handoff (only `Baron_etal_1983` was accessible), so this document is written from the build record, not from a live re-read of the files. Re-mount the repo root before continuing the Shiny fold.
