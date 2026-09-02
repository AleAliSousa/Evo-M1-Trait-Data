# van Haarlem et al. 2026 — CFF dataset (visual temporal resolution, 237 species)

van Haarlem CS, Hynes C, Jackson AL, Mitchell KJ, O'Connell RG, Healy K (2026). *Pace of ecology
drives the tempo of visual perception across the animal kingdom.* Nat Ecol Evol.
doi:10.1038/s41559-026-02994-7.

Registry (`__ReadMe.xlsx`): Item **`Haarlem_etal_2026_CFFdataset`**, encoded
`10.1038%2Fs41559-026-02994-7_CFFdataset`. Stage cells to set (Snapshot = "none - digital-native
(Haarlem_et_al_cff_dataset_21_10_2025.csv; SHA-256
bc9bfd6f923c4e58e69e7aafefe02d1793d5a3a62c7d673d835747205afc1f26)").

## What the data are
**280 published critical-flicker-fusion (CFF, Hz) measurements** for 237 species across 16
classes (insects 58, fish 50, crustaceans 48, mammals 38, birds 25, elasmobranchs 21, reptiles
18, others) — 22 species carry multiple rows (multiple primary studies). Method per row:
electrophysiology (221) / behavioural (59). Authors' ecology covariates (habitat, foraging light
level, mode of life) and body mass (g; basis in `body_mass_ref`, often FishBase size classes)
ride along. `primary_reference` holds each value's source study verbatim — the per-primary audit
hook.

## Source → Data readable (digital-native; no snapshot file)
`Haarlem_et_al_cff_dataset_21_10_2025.csv` frozen as-is (SHA-256 above; UTF-8 BOM).
`Haarlem_etal_2026_CFFdataset.R` → `Haarlem_etal_2026_CFFdataset.csv` (**use this**). Columns in
`reference_tables/Haarlem_etal_2026_CFFdataset_definitions.csv`. Built offline 2026-08-31
(Python mirror; no R in sandbox) — re-run the .R in RStudio to confirm.

## Data role — SECONDARY compilation (registry Taxon group: review)
Reviews are roadmaps: if CFF becomes a merged trait, build the high-value primaries from
`primary_reference` and prefer them; this item then serves as the comparison fixture. Note the
overlap in spirit with the sensory Route-B item (`deSousa__2022_Data`, quarantined VA) — both are
compilation-layer sensory datasets kept out of merges.

Pipeline: Source (digital-native) ✅ → Data readable ✅ → Registry stage cells ⬜ → R rerun ⬜ → Merge N/A (compilation)
