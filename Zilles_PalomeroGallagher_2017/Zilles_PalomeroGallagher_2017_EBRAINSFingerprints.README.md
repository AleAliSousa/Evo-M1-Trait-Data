# Zilles & Palomero-Gallagher 2017 folder — EBRAINS receptor-density fingerprints (constructed source via siibra)

Home paper: Zilles K, Palomero-Gallagher N (2017). *Multiple Transmitter Receptors in Regions and Layers of
the Human Cerebral Cortex.* Front. Neuroanat. 11:78. doi:10.3389/fnana.2017.00078.

Registry (`__ReadMe.xlsx`): **registered.** Item name **`Zilles_PalomeroGallagher_2017_EBRAINSFingerprints`**
(Item number "EBRAINS Fingerprints"; the registry formula strips spaces and underscores from the Item
number, so the name `..._EBRAINS_fingerprints` used in the build brief cannot be produced by the workbook
and `EBRAINSFingerprints` is used instead). The registered encoded name is `10.3389%2Ffnana.2017.00078_EBRAINSFingerprints`.

## ⚠️ Owner decision — constructed EBRAINS source placed in a paper folder
The values in this item are **not printed in the 2017 paper**. They are the per-area receptor-density
fingerprint datasets that the Jülich group (Palomero-Gallagher, Zilles, Amunts et al.) deposited in the
EBRAINS Knowledge Graph, **each with its own DOI (10.25493/...)**, which siibra exposes as
`ReceptorDensityFingerprint` features of the Julich-Brain Cytoarchitectonic Atlas. They were placed here
because they are the same laboratory's autoradiography values for the same areas (several of the 2017
areas — 3b, V1/hOc1, V2/hOc2, FG1, FG2, PFt, PFm, PGa, PGp, 44, 45, 4/4p, 41/TE 1.0 — have an EBRAINS
counterpart) and the brief asked for them in this folder. **If the item is registered under the 2017
citation, the public TSV will be coded with the paper DOI although the data are 34 separately-DOI'd
datasets.** The owner may prefer a dedicated folder (e.g. `EBRAINS_receptor_fingerprints` or one per
dataset), in which case move this item's four files + `reference_tables/Zilles_PalomeroGallagher_2017_EBRAINSFingerprints_*`
there unchanged. The per-dataset DOIs are carried on every row (`dataset_doi`) and in
`reference_tables/Zilles_PalomeroGallagher_2017_EBRAINSFingerprints_references.csv` whatever the decision.

## What the data are
**531 rows = 42 fingerprint features × their receptors** (5, 14, 15 or 16 receptors each), **34 distinct
EBRAINS datasets (DOIs)**, 24 Julich-Brain anchors. Per row: `julich_area` (siibra anchor),
`dataset_locus` (what the dataset measures — whole area, dorsal/ventral part, or hippocampal stratum),
`dataset_name`, `dataset_version` (v1.0 / v2.0), `receptor` (harmonised), `receptor_ebrains` (as in the
source), **`density_fmol_mg_protein`** (mean), `sd`, `dataset_doi`, `dataset_id`, `feature_id`,
`source_tsv`, `parcellation`.

- Cortical datasets (22 features, all v1.0, 15–16 receptors): 3b, 44 dorsal, 44 ventral, 45, 4p, 7A, FG1,
  FG2, PF, PFcm, PFm, PFop, PFt, PGa, PGp, TE 1.0, TE 2.1, hOc1, hOc2 dorsal, hOc2 ventral, hOc3d, hOc3v.
- Hippocampal datasets: CA1 / CA2 / CA3 / DG whole (v1.0 with 5 receptors, v2.0 with 14) and the
  *stratum cellulare* and *stratum moleculare* of CA (v1.0 and v2.0 each, every one anchored to CA1, CA2
  and CA3 at once — so the three anchors carry identical values from that dataset; 6 features per CA
  anchor, 2 for DG). Pick a `dataset_locus` ×
  `dataset_version` before using hippocampal rows; do not average across them.
- Receptor harmonisation to the Supplementary Table 2 item: `BZ` → `GABAA/BZ`; `mGluR2_3` and
  `mGluR2/3` → `mGluR2/3` (extra receptor, present in 11 datasets, not in the 2017 table). The 15 other
  labels are identical to the 2017 names (AMPA, NMDA, kainate, GABAA, GABAB, M1, M2, M3, alpha4beta2,
  alpha1, alpha2, 5-HT1A, 5-HT2, D1).
- Unit: **fmol/mg protein** (EBRAINS "fmol/mg"), kept.
- Sample sizes and specimen details are on each dataset's KG page (`ebrains_page` in the snapshot), not in
  the TSVs; not transcribed here.

## Source → Snapshot → Data readable  (constructed snapshot)
- **Reader**: `Zilles_PalomeroGallagher_2017_EBRAINSFingerprints_snapshot.py` (Python, siibra 1.0.1-alpha.27, environment
  `neuro-atlas`), run 2026-11-15 by the AI assistant (Claude). It queries
  `siibra.features.get(julich-brain 3.0, "ReceptorDensityFingerprint")`, and for every feature writes one row
  per receptor with the values as siibra parsed them (`mean`, `std`, `unit`), plus feature id, KG dataset
  id / name / DOI(s), KG page and the data-proxy TSV URL. Nothing is typed in the script; rows are sorted
  by anchor and feature id for a reproducible file; it refuses to overwrite a differing frozen copy
  (`--force` to override, then note the change here).
- **Snapshot**: `Zilles_PalomeroGallagher_2017_EBRAINSFingerprints_snapshot.csv` (531 rows). Regenerated from siibra on
  2026-11-15 and compared with the exploratory fetch kept in `ebrains_downloads/` (same session, same
  siibra): identical values, dataset names, DOIs and source-TSV URLs for all 42 features / 531 rows.
- **Build**: `Zilles_PalomeroGallagher_2017_EBRAINSFingerprints.R` (reads the snapshot only) → **`Zilles_PalomeroGallagher_2017_EBRAINSFingerprints.csv`**
  (use this) → public TSV after registration. Cleaning done there: receptor harmonisation; `dataset_locus`
  and `dataset_version` parsed from the dataset name; numeric mean / sd. Column meanings:
  `reference_tables/Zilles_PalomeroGallagher_2017_EBRAINSFingerprints_definitions.csv`. Dataset citations (one row per DOI,
  join on `dataset_doi` = `ref_key`): `reference_tables/Zilles_PalomeroGallagher_2017_EBRAINSFingerprints_references.csv`.
- Network: siibra needs GitHub (configuration), data-proxy.ebrains.eu (TSVs) and the KG metadata mirrors
  gitlab.ebrains.eu / jugit.fz-juelich.de (dataset names/DOIs; the latter had to be allow-listed).

No table check applies (no printed totals); no independent transcription exists to compare against
beyond the exploratory fetch above. Cross-checking the EBRAINS values against the 2017 Supplementary
Table 2 for the shared areas is an analysis, not a build step — the two sources use different area
definitions (Julich-Brain probabilistic areas vs the 2017 sample) and are not expected to be identical.

## Layer-resolved features siibra exposes for Julich-Brain (follow-up pointer)
Recorded in `ebrains_downloads/layer_feature_counts.json` (probe of 2026-11-15, siibra 1.0.1a27,
Julich-Brain 3.0.3): `ReceptorDensityProfile` — 7 features / 7 areas (laminar receptor-density profiles
along cortical depth; candidate for a layer-resolved receptor item); `LayerwiseCellDensity` — 12
features / 12 areas (BigBrain cell densities per layer; candidate for a cell-density item);
`CellDensityProfile` — 1 feature / 1 area; `LayerwiseBigBrainIntensities` and `BigBrainIntensityProfile`
raised `NoMapAvailableError` in this environment (BigBrain map not fetchable). Not built here.

## Related keys
- `_keys/General/species_key.csv` — row for `Zilles_PalomeroGallagher_2017` (Homo sapiens, 9606) covers
  this item too.

Pipeline: Source → Snapshot ✅ (generated 2026-11-15) → Data readable ✅ → definitions ✅ → references ✅ →
README ✅ → registry row ✅ → public TSV ✅. Running `LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 Rscript --vanilla Zilles_PalomeroGallagher_2017/Zilles_PalomeroGallagher_2017_EBRAINSFingerprints.R` on 2026-11-26 wrote 531 rows to `__Public/comparative-data/10.3389%2Ffnana.2017.00078_EBRAINSFingerprints.tsv`. The registry and item file continue to flag that the 2017 paper is a home citation rather than the source of the measurements; each row carries its actual EBRAINS dataset DOI.
