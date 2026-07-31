# Medina-González 2026 — joint angular excursion in terrestrial mammals

Source folder for a broad-coverage **locomotion / gait** source feeding `__merging_behaviour`
(candidate #7 in `SCOUTING_candidate_papers_20260731.md`; kept per curator, 2026-07-31). The
widest-coverage locomotion source scouted — extends gait/locomotion far beyond the current
primate-leaning set (Wimberly, Granatosky).

## Source (freeze before cleaning)

Medina-González, P. (2026). *Joint Angular Excursions and Angular Range Utilization During
Stance-Phase Locomotion in Terrestrial Mammals: A Comparative Morphofunctional Data Set.* Journal of
Experimental Zoology Part A. DOI **10.1002/jez.70069**.
Data: **Zenodo doi:10.5281/zenodo.15425733** ("Supplementary Data … Joint Angular Excursion and
Efficiency in Terrestrial Mammals", published 2025-05-15; FONDECYT 11231111).

- **What it contributes:** stance-phase joint angular excursions (touchdown / midstance / toe-off for
  six limb joints) and an **angular utilization index (AUI %)** for **182 terrestrial mammal species
  across 15 orders**, each classified by **limb posture, body mass, top speed, and locomotor habit**.
- **Frozen source:** the Zenodo dataset (digital-native → download IS the frozen copy). Could not be
  pulled in the scaffolding session (network policy blocked Zenodo at the egress proxy; no R runtime).
  Download locally; keep verbatim; write the DOI-coded public TSV
  `__Public/comparative-data/10.1002%2Fjez.70069_Data.tsv` (invariant 2). Check the Zenodo license
  before redistributing the TSV.

## Scope for the trait table — summary columns only

The per-joint excursion angles are too granular for the correlatable trait table; **keep them in the
frozen source**. Expose the species-level summaries in the reader:

| trait table column | source | note |
|---|---|---|
| `Angular_utilization_index` | AUI % | headline morphofunctional summary |
| `Limb_posture` | posture class | plantigrade / digitigrade / unguligrade (categorical) |
| `Top_speed` | top speed | continuous |
| `Locomotor_habit` | habit class | categorical |

## Build steps

1. Reader `____EvoM1_TraitTable/EvoM1_read_gait_excursion_medina.R` (scaffolded) — reads the public
   TSV, resolves species via `_keys`, writes `____EvoM1_TraitTable/gait_excursion_medina.xlsx`.
   **Confirm the exact source column headers** at the `TODO(curator)` marker.
2. `reference_tables/MedinaGonzalez_2026_definitions.csv` (scaffolded).
3. Register in `__ReadMe.xlsx` Sheet1: `Item name = MedinaGonzalez_2026_Data`,
   `Item encoded = 10.1002%2Fjez.70069_Data`, `Data role = primary`
   (`secondary` for the columns compiled from published sources — flag per column if needed),
   `Main Trait(s) = limb kinematics / locomotor posture`, `Taxon group = Mammals`, `Team = Medina`.

## Wire into `__merging_behaviour/behaviour_compiled.R` (only after the xlsx exists)

- Add `Medina = "Medina"` to `TEAM`; add `"Limb_posture"`, `"Locomotor_habit"` to `CATEG`
  (categorical measures are not min/max-summarised).
- Add `grab()` lines for each exposed column and matching `META` rows
  (`mclass = "locomotion"`; `Angular_utilization_index`/`Top_speed` numeric, the two classes
  categorical), all single-source `list(c("medina","primary"))`.

### Construct note

`Limb_posture` overlaps conceptually with Wimberly's `Foot_Posture` but they are **different codings
from different sources** — keep as a distinct `Measure` (do not silently key onto `Foot_Posture`).
Curator may later decide to reconcile the categorical schemes.
