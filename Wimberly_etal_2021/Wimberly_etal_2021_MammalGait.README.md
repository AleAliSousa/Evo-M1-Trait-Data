# Wimberly et al. 2021 — mammalian walking-gait dataset

Wimberly AN, Slater GJ, Granatosky MC (2021). *Evolutionary history of quadrupedal walking gaits
shows mammalian release from locomotor constraint.* Proc. R. Soc. B 288: 20210937.
doi:10.1098/rspb.2021.0937

Source data: **`mammal_gait.txt`** — quantitative symmetrical walking-gait data for 154 mammal
species (duty factor, limb phase, gait category, foot posture) plus size and habitat, assembled by
the authors largely from freely available internet videos to nearly double the number of species
with quantitative gait data.

## Naming note
The registry Item-name formula strips spaces and underscores from the Item number, so the item token
is **`MammalGait`** (Item number = `Mammal Gait`). All built files use the base
`Wimberly_etal_2021_MammalGait`; the public TSV is `10.1098%2Frspb.2021.0937_MammalGait.tsv`.

## What we built (focal traits)
Gait-mechanics traits plus context; the analysis transforms (logs, arcsines) stay in the snapshot:

- `Duty_Factor` — mean stance duty factor (focal gait trait)
- `Phase` — limb phase / diagonality (focal gait trait)
- `Gait` — symmetrical gait category (DSDC / LSDC / LSLC)
- `Foot_Posture` — plantigrade / digitigrade / unguligrade (locomotor morphology)
- `Habitat` — arboreal / terrestrial substrate use (**secondary**; substrate is primary in Granatosky2018)
- `Hindlimb_Length.mm`, `Body_Mass.g` — size (**secondary**; body mass compiled elsewhere)

## Source -> snapshot -> CSV
- **Source:** `mammal_gait.txt` (tab-separated, kept in this folder).
- **Snapshot:** `Wimberly_etal_2021_MammalGait_snapshot.xlsx` (sheet `MammalGait_snapshot`) — a frozen,
  faithful copy of the source, all 13 original columns (the blank first header is named
  `Species_printed`). Golden rule: freeze before cleaning.
- **Reformat:** `Wimberly_etal_2021_MammalGait.R` reads the snapshot, selects the focal columns,
  harmonises species names against `_keys` (printed name preserved as `Species`, accepted binomial in
  `species_sci`), and writes:
  - `Wimberly_etal_2021_MammalGait.csv` (analysis-ready)
  - `__Public/comparative-data/10.1098%2Frspb.2021.0937_MammalGait.tsv` (public, DOI-encoded)

## Species names
Printed names preserved verbatim in `Species` (underscores -> spaces); accepted binomials in
`species_sci` via the project key. Of 154 species, **59 resolve** to a canonical binomial already in
the project (42 direct in `_keys/species_reference.csv`, 17 via `_keys/Stephan/species_key.csv`
spokes); the remaining **95** are new to the project (mostly non-primate mammals outside the brain
dataset) and are kept as their cleaned printed binomial — consistent with the Granatosky2018 build.

## Data role
**Primary** for the gait traits (duty factor, limb phase, gait category, foot posture). `Habitat`,
`Hindlimb_Length.mm` and `Body_Mass.g` are **secondary** (context / already compiled elsewhere).

## Using it with Granatosky 2018
Both are locomotion tables keyed on `species_sci`, but they measure **different** traits — Wimberly =
gait *mechanics*, Granatosky = locomotor *repertoire* (diversity index, intermembral index). So they
**join side-by-side as correlatable traits**, they are *not* combined/averaged as one trait, and
there is no double-counting. Harmonised overlap = **27 species** (mostly primates plus a few arboreal
mammals). Note the shared author (Granatosky) but the datasets are independent measurements;
`Body_Mass` and substrate overlap conceptually, so use Granatosky's substrate/mass as primary and
treat Wimberly's as secondary when both are present.

## Registry (added 2026-07-19)
Row added to `__ReadMe.xlsx` -> `Sheet1` (surgical XML edit; shared formulas extended to the new row):

| column | value |
|---|---|
| Citation (col A) | Wimberly, A. N., Slater, G. J., & Granatosky, M. C. (2021). ... https://doi.org/10.1098/rspb.2021.0937 |
| Item number (col D) | `Mammal Gait` |
| Source format (col V) | `dataset` |
| Team (col Y) | `Granatosky` |
| Main Trait(s) (col AI) | `locomotion (walking gait)` |
| Data role (col AL) | `both` |

`Item name` -> `Wimberly_etal_2021_MammalGait`; `Item encoded` -> `10.1098%2Frspb.2021.0937_MammalGait`
(cached values written directly so the pipeline reads them without opening Excel).

## Checks
- Analysis CSV = 154 rows (one per species), matching the source. No comparison script: this is a
  first-party compilation with no independent curated copy to audit against.
