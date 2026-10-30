# Medina-González 2026 — joint angular excursion in terrestrial mammals

Source folder for a broad-coverage **locomotion / gait** source feeding `__merging_behaviour`
(candidate #7 in `PROJECT_SCOPE_AND_DATASET_ROADMAP.md`; kept per curator, 2026-07-31). The
widest-coverage locomotion source scouted — extends gait/locomotion far beyond the current
primate-leaning set (Wimberly, Granatosky).

## Source (freeze before cleaning)

Medina-González, P. (2026). *Joint Angular Excursions and Angular Range Utilization During
Stance-Phase Locomotion in Terrestrial Mammals: A Comparative Morphofunctional Data Set.* Journal of
Experimental Zoology Part A. DOI **10.1002/jez.70069**.

- **What it contributes:** stance-phase joint angular excursions (touchdown / midstance / toe-off for
  six limb joints) and an **angular utilization index (AUI %, per-limb)** for **182 records / 77
  terrestrial mammal species across 15+ orders**, each classified by limb posture, body mass, top
  speed, and locomotor habit.
- **Frozen source — built 2026-09 from the journal's own online supplement, not Zenodo.** The Zenodo
  deposit (doi:10.5281/zenodo.15425733) remains **restricted** (rechecked 2026-08-15: seven files
  described, none downloadable to unauthenticated clients — that blocker is unrelated to this build
  and still applies to that specific record). Instead, three of the paper's supplementary files were
  obtained directly from the published article page, onlinelibrary.wiley.com/doi/10.1002/jez.70069:
  - `jez70069-sup-0001-supplementary_file_1.xlsx` — Supplementary File 1, source list for the
    joint-angle extraction (per row: order, species, source).
  - `jez70069-sup-0002-supplementary_file_2.xlsx` — Supplementary File 2, locomotor-habit
    classification + justification, one row per record.
  - `jez70069-sup-0003-supplementary_file_3.xlsx` — Supplementary File 3, the joint-excursion /
    TAE / angular-excursion-efficiency data (the paper's own "Data" item, 49 columns).

  All three are **digital-native** (journal-supplied XLSX) → per `__HOWTO_build_a_dataset_file.md`
  §0a invariant 1 the untouched downloads **are** the frozen source, kept verbatim in this folder —
  no derived `_snapshot` was made.

## Granularity — per-record, not per-species

All three files carry **182 rows** but only **77 unique species** (many species have multiple
individuals/records). Files 2 and 3 align 1:1 by row position (`N°` == `ID`; Order/Species/
Locomotor-habit verified identical across the two). File 1's row order does **not** match Files 2/3
(it appears grouped by species for display, not one-to-one with the individual records) and its
blank `Source name` cells do not reduce to a clean per-species or per-contiguous-block fill (113
contiguous species-runs vs. 77 species; 46 runs cite no source at all) — kept exactly as printed,
no forward-fill/inference (never silently corrected).

## What got built

Registered in `__ReadMe.xlsx` as three parallel items (`Data role = both`), matching the paper's own
Supplementary File numbering:

| file | Item name | role | output |
|---|---|---|---|
| Supplementary File 1 | `MedinaGonzález__2026_SupplementaryFile1` | provenance documentation (per-row source citations) | `MedinaGonzález__2026_SupplementaryFile1.R` → `.csv` + `__Public/comparative-data/10.1002%2Fjez.70069_SupplementaryFile1.tsv` (+ a `reference_tables/MedinaGonzález__2026_references.csv` copy used internally) |
| Supplementary File 2 | `MedinaGonzález__2026_SupplementaryFile2` | the paper's own locomotor-habit classification + justification | `MedinaGonzález__2026_SupplementaryFile2.R` → `.csv` + `..._SupplementaryFile2.tsv` |
| Supplementary File 3 | `MedinaGonzález__2026_SupplementaryFile3` | the measured joint-kinematics / AUI data | `MedinaGonzález__2026_SupplementaryFile3.R` → `.csv` + `..._SupplementaryFile3.tsv` |

`Body_mass_kg` is kept as printed; a derived `Body_mass_g` (project unit) is added alongside it.
AUI has no single combined column in the source — the paper's own definition (Abstract: "AUI % =
TAE/∑JAE") is realised as two columns, `FL_Angular_Excursion_Efficiency_pct` and
`HL_Angular_Excursion_Efficiency_pct` (forelimb / hindlimb), both kept.

## Scope for the trait table — species-level summary columns only

The per-joint excursion angles are too granular for the correlatable trait table; **kept in the
frozen source / analysis CSV, not exposed**. `EvoM1_read_gait_excursion_medina.R` aggregates the
per-record SupplementaryFile3 table to one row per species (mean of numeric summaries; first non-missing category)
and writes:

| trait table column | source | note |
|---|---|---|
| `Angular_utilization_index_FL` | `FL_Angular_Excursion_Efficiency_pct` | forelimb AUI %, species mean across records |
| `Angular_utilization_index_HL` | `HL_Angular_Excursion_Efficiency_pct` | hindlimb AUI %, species mean across records |
| `Limb_posture` | `Posture` | plantigrade / digitigrade / sub-unguligrade / unguligrade / mixed |
| `Top_speed` | `Top_speed_class` | categorical (slow/medium/fast) — the source has no continuous top-speed value |
| `Locomotor_habit` | `Locomotor_habit` | categorical |

## Registration

Registered in `__ReadMe.xlsx` Sheet1 (rows 258–260) as three items, pasted by the owner with the
accent fixed throughout: `MedinaGonzález__2026_SupplementaryFile1/2/3`, `Item encoded =
10.1002%2Fjez.70069_SupplementaryFile{1,2,3}`, `Data role = both`. `Main Trait(s) = limb kinematics
/ locomotor posture`; `Taxon group = Mammals`; `Team = Medina`. All three builds resolve
`item_encoded` directly from the registry now (no fallback warning).

## Wired into `__merging_behaviour/behaviour_compiled.R`

- Added `medina = "Medina"` to `TEAM`; added `"Limb_posture"`, `"Locomotor_habit"` to `CATEG`
  (categorical measures are not min/max-summarised).
- Added `grab()` lines for `Angular_utilization_index_FL`, `Angular_utilization_index_HL`,
  `Limb_posture`, `Top_speed`, `Locomotor_habit`, all single-source `list(c("medina","primary"))`.

### Construct note

`Limb_posture` overlaps conceptually with Wimberly's `Foot_Posture` but they are **different
codings from different sources** — kept as a distinct `Measure` (not keyed onto `Foot_Posture`).
Curator may later decide to reconcile the categorical schemes.

### Naming

Folder and every live cross-reference use the accented `MedinaGonzález__2026` (double underscore),
matching the author's own spelling and the project convention already used for e.g.
`BarbeitoAndrés_etal_2019` / `Zilles_Rehkämper_1988` (accented names preserved in Publication
name / Item name). The one place that still needs a manual fix is `__ReadMe.xlsx`'s Citation cell
(see Registration above) — everything else in this build uses the accented form throughout.
